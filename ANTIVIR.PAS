{$X+,T-}
{
+----------------------------------------------+
|   Программа контроля исполняемых файлов на   |
|  возможность заражения компьютерным вирусом. |
|   При запуске командой ANTIVIR инициируется  |
|    диалоговый режим, при запуске командой    |
|  ANTIVIR /AUTO осуществляется автоматический |
| контроль файлов, параметры которых хранятся  |
|           в файле ANTIVIR.DAT.               |
+----------------------------------------------+}
Uses F_Anti, {Включаем автоконтроль программы}
     CRT, DOS, F_Disk, Memory, StdDlg, MsgBox,
     HelpFile, {Этот модуль в исходном тексте входит в поставку TV и обычно
               располагается в каталоге \bp\examples\dos\tvdemos}
     App, Dialogs, Objects, Drivers,Views, Menus;
{
+----------------------------------------------+
|          Глобальные определения              |
+----------------------------------------------+
}
type
  {Описатель раздела ЖД}
  Part_Type = record
    BootF: Byte;    {Флаг активности раздела}
    BegHd: Byte;    {Головка для начала раздела}
    BegSC: Word;    {сектор/цилиндр}
    Sys  : Byte;    {Код системы}
    EndHd: Byte;    {Головка для конца раздела}
    EndSC: Word;    {сектор/цилиндр}
    Secs : LongInt; {Относительный номер начального сектора}
    Size : LongInt; {Длина раздела в секторах}
  end;  {Part_Type}
  {Структура загрузочного сектора}
  BootSecType = record
    a: array [0..$1BD] of Byte;
    Part: array [1..4] of Part_Type;
    b: array [1..2] of Byte
  end;
  {Первый сектор файла}
  LType = record case Byte of
   1: (Boot: BootSecType);
   2: (W: array [1..256] of Word);
  end;
  {Описание логического диска в заголовке архивного файла}
  TLogicD = record
    BHd: Byte;      {Начальная головка}
    BSC: Word;      {Сектор-цилиндр}
    Space: LongInt; {Объем в секторах}
  end;


  {Описание структуры ЖД в резервном файле}
  TStruc = record
    BHd: Byte;
    BSC: Word;
    Sec: BootSecType
  end;
  {Описание файла в архивном файле}
  CheckType = record
    Name: PathStr;    		{Полное имя файла}
    Sec0: LType;      		{Эталон первого сектора}
    Siz0: LongInt     		{Эталонная длина файла}
  end;
  {Заголовок архивного файла}
  THead = record
  case Byte of
  0:(
    HD   : String[7];     	{'АNTIVIR'}
    BIOS : LongInt;       	{Контр.сумма BIOS}
    Int13: Pointer;       	{Адрес входа в Int13}
    NDisk: Byte;          	{Количество ЛД}
    SecTr: Byte;          	{# секторов на дорожке}
    Heads: Byte;          	{Количество головок}
    LDisk: array [1..48]of TLogicD; 	{Ссылки на ЛД и их описатели}
    Beg13: array [1..SizeOf(CheckType)-27-
      48*SizeOf(TLogicD)] of Byte);	{Начало Int13}
  1:(CT: CheckType)
  end;
{Turbo Vision программа, обеспечивающая диалог}
  PVir =^TVir;
  TVir = object(TApplication)
    HelpFile: String;    		{Имя Help-файла}
    Procedure InitStatusLine; Virtual;
    Procedure Run; Virtual;
    Procedure DoHelp;    		{Выдать справку}
  end;
var
  F: File of CheckType;     	{Архивный файл}
  Head: THead;              	{Его заголовок}
  FColl: PCollection;       	{Архив в памяти}
  BegDat: LongInt;              {Начало файловой области в архиве}
const
  Stop   : Boolean = True;  {Признак отказа от контроля}
  IsVirus: Boolean = False; {Признак обнаруженного вируса}
  Files  : Word = 0;        {Счетчик файлов}
  AntiV  : PVir = NIL;      {Указатель на диалог}
  FChange: Boolean = False; {Признак изменения коллекции}
{
+-----------------------------------------------+
|    Типы, процедуры и функции, реализующие     |
|    контроль загрузочных  секторов и файлов    |
|        на возможное заражение вирусами        |
|     и лечение пораженных файлов (секторов)    |
+-----------------------------------------------+
}
PROCEDURE Msg(S: String);
  {Контролирует текущий видеорежим и выводит сообщение S
   с помощью Turbo Vision или оператором WriteLn}
var
  R: TRect;
  C: Char;
  AOpt: Word;

BEGIN
  if AntiV=NIL then
    begin   {Обычный режим вывода}
      WriteLn(S);
      Write('Нажмите любую клавишу...');
      C := ReadKey;
      While KeyPressed do
        C := ReadKey
    end
  else
    begin  {Вывод в Turbo Vision}
      AOpt := mfOKButton;
      AOpt := MessageBox(S,NIL,AOpt)
    end
END;  {Msg}
{------------------}
PROCEDURE WriteFile(Source: CheckType);
  {Записывает в файл F очередную запись
   и контролирует ошибку}
var
  k: Integer;
BEGIN
  {$I-}
  Write(F,Source);
  {$I+}
  if IOResult<>0 then
    begin
      Msg('Ошибка записи в архивный файл');
      Halt
    end
END;  {WriteFile}
{------------------}
PROCEDURE CheckErr(S: String);
  {Проверяет статус диска, выводит сообщение S
  и останавливает счет, если Disk_Error=True}
BEGIN
  if not Disk_Error then
    Exit;
  Msg(S);
  Halt
END;  {CheckErr}
{------------------}
FUNCTION Equal(var A,B; Size: Word): Boolean;
  {Сравнивает Size байт из переменных
   А и В и возвращает TRUE, если они совпадают}
var
  X: array [1..65535] of Byte absolute A;
  Y: array [1..65535] of Byte absolute B;
  Res: Boolean;
  k  : Word;
BEGIN
  k := 1;
  repeat
    Res := X[k]=Y[k];
    inc(k)
  until not Res or (k>Size);
  Equal := Res
END;  {Equal}
{------------------}
FUNCTION Okay(s: String): Boolean;
  {Дает сообщение S, возвращает TRUE,если нажата клавиша Y}
var
  c: Char;
BEGIN {Okay}
  Write(s+' (Y/N,Enter=Y)? ');
  repeat
    c := UpCase(ReadKey);
    if KeyPressed then if ReadKey=' ' then;
    case c of
      #13: c := 'Y';
      'Y':;
      'N':;
      else Write(#7)
    end;
  until (c='Y') or (c='N');
  WriteLn(c);
  Okay := c='Y'
END;  {Okay}
{------------------}
PROCEDURE ReStartDOS;
  {Осуществляет перезапуск DOS}
BEGIN
  asm
    mov  ax,$F000  	{Сегмент перезапуска}
    push ax        	{Помещаем его в стек}
    mov  ax,$FFF0  	{Смещение}
    push ax        	{Помещаем в стек}
    retf           	{Перезапуск ДОС}
  end
END;  {ReStartDos}
{-------------------}
const
  Int13Addr: Pointer=NIL; {Адрес Int13 в BIOS}
  Old62: Pointer=NIL;     {Старый вектор $62}
{-------------------}
PROCEDURE RWSecInt13(Op,Hd,SC: Word; var Targ);
{Читает или записывает абсолютный сектор ЖД с
 помощью непосредственного вызова Int13 из BIOS}

var
  R: Registers;
BEGIN
  if Int13Addr<>NIL then with R do
    begin
      ah := Op;
      al := 1;
      dh := Hd;
      dl := $80;
      cx := SC;
      es := Seg(Targ);
      bx := Ofs(Targ);
      Intr($62,R);
      Disk_Error := Flags and FCarry<>0
    end
  else
    GetAbsSector($80,Hd,SC,Targ)
END;  {RWSecInt13}
{------------------}
PROCEDURE Alarm;
  {Вызывается в случае обнаружения изменений в структуре ЖД}
var
  k: Integer;
  F1: File of TStruc;
  c: CheckType;
  Boot: BootSecType;
  S,ss: String;
Procedure Save(H: Byte; SC: Word);
  {Записывает абсолютные координаты
   сектора и сам сектор в файл F1}
var
  LD: TStruc;
begin
  if S<>'' then with LD do
    begin
      BHD := H;
      BSC := SC;
      GetAbsSector($80,BHD,BSC,Sec);
      Write(F1,LD)
    end
end;
const
  t: array [1..9] of String[80]=(
    'Обнаружены изменения в структуре жесткого диска, которые могут быть',
    'следствием заражения ПК вирусом!',
    'Лечение загрузочного вируса основано на восстановлении структуры ЖД',
    'в том виде, в каком она была к моменту создания архивного файла.',
    'Эта операция может нанести непоправимый вред Вашему ПК, если архивный файл',
    'содержит ошибочную информацию (например, взят от другого ПК) или не учитывает',
    'новое разбиение жесткого диска на логические разделы.',
    'Рекомендую перезагрузить DOS с эталонной дискеты и убедиться в том, что вирус',
    'действительно существует (с помощью AIDSTEST, PCTOOLS и т.п.).');
BEGIN
  {Предупреждаем об опасности}
  for k := 1 to 9 do
    begin
      GotoXY((80-Length(t[k])) div 2,WhereY);
      WriteLn(t[k])
    end;
  Write(#7);  			{Звуковой сигнал}
  if Okay(#13#10'Перезагрузить DOS') then
    ReStartDOS;  		{Перезагружаем ДОС}
  Write('Лечить (Y/N,Enter=N)? ');
  if UpCase(ReadKey)<>'Y' then
    Halt;
  {Запрашиваем дублирование на ГД и готовим
   файл с копиями зараженных секторов}
  S := '';
  if Okay('Сохранить копию структуры ЖДна дискете') then
    repeat
      Write('Вставьте дискету с открытой прорезью и введите имя ГД: ');
      ReadLn(S);
      s[1] := UpCase(s[1]);
      if Length(s)=1 then
        s := s+':'
    until (s='A:') or (s='B:');
  if s<>'' then
    begin
      Assign(F1,s+'\VIRDAT.$V$');
      ReWrite(F1);
    end;

  {Восстанавливаем структуру ЖД}
  Seek(F,1);
  with Head do
    for k := 1 to NDisk do
      with LDisk[k] do
      begin
        Read(F,c);
        Save(BHd,BSC);
        RWSecInt13(3,BHd,BSC,c.Sec0)
      end;
  if S<>'' then
    Close(F1);
  {Перезагружаем ДОС}
  ReStartDOS
END;  {Alarm}
{------------------}
PROCEDURE CheckBoots;
  {Проверяет структуру ЖД. Head уже содержит
   проверенный заголовок архивного файла}
var
  c: CheckType;
  ch:^CheckType;
  Buf: LType;
  k: Word;
BEGIN {CheckBoots}
  {Устанавливаем в вектор $62 BIOS-адрес
   входа в начало обработки прерывания Int13,
   чтобы обмануть Stealth-вирусы}
  GetIntVec($62,Old62); {Спасаем вектор $62}
  SetIntVec($62,Head.Int13);
  WriteLn;
  WriteLn('Для досрочного завершения работы '+
           'программы нажмите ESC');
  WriteLn;
  WriteLn('Антивирусный контроль описателей структуры ЖД:');
  WriteLn('Головка','Сектор/цилиндр':20);
  {Проверяем ссылки и описатели ЛД}
  with Head do
  for k := 1 to NDisk do with LDisk[k] do
    begin
      Write(BHD:4,BSC:17);
      RWSecInt13(2,BHd,BSC,Buf);
      Read(F,c);
      if Equal(c.Sec0,Buf,512) then
        WriteLn('Норма':20)
      else
        begin
          Writeln('Изменен!':20);
          Alarm  {Обнаружены изменения}
        end
    end;
  {Нормальное завершение проверки}
  SetIntVec($62,Old62);
  Int13Addr := NIL;
  BegDat := FilePos(F);
  {Наполняем коллекцию архивными файлами}
  WriteLn;
  WriteLn('Читается архивный файл ANTIVIR.DAT...');
  while not EOF(F) do
    begin
      New(ch);
      Read(F,ch^);
      FColl^.Insert(ch);
      if KeyPressed and (ReadKey=#27) then
        Halt
    end;
  WriteLn
END;  {CheckBoots}
{------------------}
PROCEDURE SetFile(FName: String);
  {Помещает в архив эталон файла FNAME}
var
  ch: ^CheckType;
  k,nz,sz: Word;
  P   : Pointer;
  FF  : file;
BEGIN {SetFile}
  Assign(FF,FName);
  {$I-}
  Reset(FF,1);
  {$I+}
  if IOResult <> 0 then
   Msg('Ошибка доступа к файлу '+FName)
  else
    begin
      {Искать в архиве одноименный файл:}
      if FColl^.Count<>0 then
      begin
        k := 0;
        repeat
          ch := FColl^.At(k);
          inc(k);
        until (ch^.Name=FName) or(k=FColl^.Count);
        if ch^.Name=FName then
          Exit
      end;
      {Подготовить очередную запись:}
      New(ch);
      ch^.Name := FName;
      ch^.Siz0 := FileSize(FF);
      sz := 512;         		{Длина блока чтения}
      if ch^.Siz0<512 then
        sz := ch^.Siz0;  		{Файл меньше 512 байт}
      FillChar(ch^.Sec0,512,0);
      BlockRead(FF,ch^.Sec0,sz,nz);
      Close(FF);
      if nz<>sz then
        Msg('Ошибка чтения из файла '+ch^.Name)
      else if not LowMemory then
        begin
          FColl^.Insert(ch);
          FChange := True
        end
      else
        k := MessageBox('Исчерпана доступная память',NIL,0)
    end
END;  {SetFile}
{------------------}
PROCEDURE BuildArch;
  {Создает архивный файл}
var
  k,S13,O13,h,s: Word;
  c: CheckType;
  ch:^CheckType;
  DIn: TDisk;
BEGIN
  ReWrite(F);
  if IOResult <> 0 then
    begin
      WriteLn('Невозможно открыть/создать файл данных');
      Halt
    end;
  {Создаем заголовок файла}
  with Head do
    begin
      Hd := 'ANTIVIR';
      {Подсчитываем КС BIOS}
      BIOS := 0;
      for k := 0 to $FFFF do
        BIOS := BIOS+Mem[$F000:k];
{Определяем вход в Int13}
      asm
        mov ah,$13
        Int $2F
        push ds  		{Сегмент}
        push dx  		{Смещение}
        Int $2F  		{Восстанавливаем Int13}
        pop bx  		{Смещение}
        pop ax   		{Сегмент}
        mov S13,ax
        mov O13,bx
      end;
      Int13 := Ptr(S13,O13);
      Move(Int13^,Beg13,SizeOf(Beg13));
      NDisk := 0;       		{Количество дисков}
    end;  {with Head}
{Сканируем структуру ЖД}
  GetMasterBoot(c.Sec0);
  if not Disk_Error then
   with Head,c,Sec0.Boot do
    begin  {Есть хотя бы один ЖД}
      h := 0;
      s := 1;
      Seek(F,1);
      GetDiskInfo(2,DIn);
      SecTr := DIn.TrackSiz;
      Heads := DIn.Heads;
{Цикл по всем ЛД: h,s - адрес ссылки}
      repeat
        {Запоминаем адрес ссылки в заголовке}
        inc(NDisk);
        with LDisk[NDisk] do
          begin
            BHd := h;
            BSC := s;
            Space := 1
          end;
{Читаем ссылку на очередной ЛД}
        GetAbsSector($80,h,s,c.Sec0.Boot);
        {Сохраняем ее в архиве}
        Name := '';
        Siz0 := 0;
        Write(F,c);
{Ищем непустой описатель ЛД}
        k := 1;
        while (Part[k].BegSC=0) and (k<4) do
          inc(k);
        if Part[k].BegSC<>0 then with Part[k] do
          begin
            {Запоминаем адрес описателя в Head}
            inc(NDisk);
            with LDisk[NDisk] do
              begin
                BHd := BegHd;
                BSC := BegSC;
                Space := Size
              end;
{Запоминаем ссылку на следующий ЛД}
            inc(k);
            h := Part[k].BegHd;
            s := Part[k].BegSC;
{Запоминаем описатель в архиве}
            Name := '';
            Siz0 := 0;
            with LDisk[Ndisk] do
             GetAbsSector($80,BegHd,BegSC,Sec0);
            Write(F,c);
          end {если непустой описатель}
      until S=0
    end;  {есть хотя бы один ЛД}
{Записываем заголовок архива}
  BegDat := FilePos(F);
  Seek(F,0);
  Write(F,Head.CT);
  Seek(F,BegDat);
{Защищаем COMMAND.COM}
  SetFile(GetEnv('COMSPEC'));
END;  {BuildHead}
{------------------}
FUNCTION CheckHead: Boolean;
  {Проверяет заголовок архивного файла}
var
  s: String;
  k: Word;
  Sum: LongInt;
  DI: TDisk;
BEGIN
  {Подсчитываем КС BIOS}
  Sum := 0;
  for k := 0 to $FFFF do
    Sum := Sum+Mem[$F000:k];
{Получаем конструктивные параметры ЖД}
  GetDiskInfo(2,DI);
{Читаем заголовок архива}
  Read(F,Head.CT);
  {Проверяем его}
  s := 'ANTIVIR';
  with Head do
    if (Hd<>s) or (Sum<>BIOS) or
      not Equal(Beg13,Int13^,SizeOf(Beg13)) or
      (SecTr<>DI.TrackSiz) or (Heads<>DI.Heads)
      then begin
        WriteLn('Архивный файл содержит ошибочные данные!');
        if not Okay('Создать новый архив') then
          Halt
        else
          CheckHead := False
      end
    else
      CheckHead := True
END;  {CheckHead}
{------------------}
FUNCTION Auto: Boolean;
  {Контролирует параметры обращения, открывает или создает
	DAT-файл. Возвращает TRUE, если обнаружен ключ /AUTO}

var
  s: String;
  k,j: Byte;
  AF: Boolean;  {Флаг ключа /AUTO}
  c: CheckType absolute Head;
  S13,O13: Word;
  DI: TDisk;
label
  SetF,ErrHd;
const
  tx='Архивный файл содержит ошибочные данные. '+
				'Создать новый файл';
BEGIN {Auto}
  AF := False;
  for k := 1 to ParamCount do
    begin
      s := ParamStr(k);
      for j := 1 to Length(s) do
        s[j] := UpCase(s[j]);
      if s = '/AUTO' then
        AF := True
    end;
  s := copy(ParamStr(0),1,pos('.',ParamStr(0)))+'DAT';
                      		{s = полное имя DAT-файла}
  {Готовим коллекцию имен файлов}
  FColl := New(PCollection, Init(100,10));
  {Формируем список дисковых описателей}
  GetListDisk(Disks);
  Assign(F,s);
{$I-}
  Reset(F);     		{Проверяем существование архива}
{$I+}
  if (IOResult<>0) or
      not CheckHead then
    BuildArch    	{Создаем, если нет архива}
  else           	{Файл существует}
    CheckBoots;  	{Проверяем структуру ЖД}
  Auto := AF
END;  {Auto}
{------------------}
PROCEDURE Dialog;
  {Осуществляет диалог с пользователем.Возвращает STOP=TRUE, 
   если пользователь отказался от контроля. Использует
   средства библиотеки Turbo Vision}

BEGIN
  New(AntiV);
  with AntiV^ do
    begin
      Init;
      HelpFile := copy(ParamStr(0),1,pos('.',ParamStr(0)))+'HLP';
      RegisterHelpFile;
      Run;
      Done
    end;
  Dispose(AntiV)
END;  {Dialog}
{------------------}
PROCEDURE Check;
  {Осуществляет контроль файлов по эталонам,
   хранящимся в коллекции FColl}
var
  FF: File;
Function Cure(Sec0,Sec: LType): Byte;
  {Проверяет тип файла и расположение
   в нем вируса и возвращает:
   0 - вирус в начале EXE-файла (не удаляется)
   1 - вирус в конце EXE или COM-файла
   2 - вирус в начале COM-файла
   3 - пользователь не разрешил удалять вирус}
var
  C: Byte;
  Eq: Boolean;
begin
  with Sec0 do
    if W[1]=$5A4D then 	{Если EXE-файл,проверяем сегмент точки запуска}
      if W[12]>=Sec.W[12] then
        C := 0  		{В начале или середине файла}
      else
        C := 1  		{В конце файла}
    else
   {Если COM-файл,проверяем вторую половину сектора:}
      begin
        if Equal(W[128],Sec.W[128],256) then
          C := 1 	{Нет изменений - вирус в конце}
        else
          C := 2 	{Сектор изменен - в начале}
      end;
  if C=0 then
    WriteLn('Вирус нельзя удалить, т.к.',
           		' он расположен в начале EXE-файла!')
  else
    if not Okay('Удалять вирус')
      then C := 3;
  Cure := C
end;  {Cure}
{--------}
Procedure ReWriteFile(Siz0: LongInt);
  {Перезаписывает незараженную часть COM-файла
   на место вируса максимально возможными блоками}
var
  Sour,Dest,FSize: LongInt;
  Size: Word;
  P: Pointer;
begin
  Reset(FF,1);
  Seek(FF,0);
  FSize := FileSize(FF);
  Sour := FSize-Siz0; 	{Длина вируса}
  Dest := 0;             {Начало файла}
  repeat    		{Переписать незараженную часть
              		в начало файла (на место вируса)}
    Size := 65520;
    if FSize < Size then
      Size := FSize;
    if Size > MaxAvail then
      Size := MaxAvail;
    GetMem(P,Size);
    Seek(FF,Sour);         	{Пропускаем вирус}
    BlockRead(FF,P^,Size); 	{Читаем остальное}
    Seek(FF,Dest);
    BlockWrite(FF,P^,Size);
    Sour := Sour+Size;
    Dest := Dest+Size;
    FSize := FSize-Size;
    FreeMem(P,Size)
  until FSize=0;
  Truncate(FF);        		{Отсекаем лишнюю часть}
  Close(FF);
  Reset(FF,1)
end;  {ReWriteFile}
{--------}
var
  ch  : ^CheckType;
  Sec : LType;
  k,nz,sz: Word;
label
  VirDet,SetBeg,Next,Stop;
const
  tx1 = 'Антивирусный контроль файлов (ESC - стоп):';
  tx2 = 'Вирус не обнаружен.';
  tx3 = 'Проверьте незащищенные файлы!';
  tx4 = 'Вирус может быть резидентным,'+
        ' рекомендую перезагрузить систему!';
  tx5 = 'Перезагрузить ДОС';
BEGIN {Check}
  if FColl^.Count=0 then
    Exit;      			{Нет файлов в коллекции}
  Int13Addr := Head.Int13;
  SetIntVec($62,Head.Int13);
  WriteLn(' ':(80-Length(tx1)) div 2,tx1);
  Files := 0;  			{Счетчик проверенных файлов}
  for k := 0 to pred(FColl^.Count) do
    begin
      ch := FColl^.At(k);
      with ch^ do
      begin
      Assign(FF,Name);
      {$I-}
      Reset(FF,1);
      {$I+}
      if IOResult <> 0 then
        WriteLn('   Ошибка доступа к файлу ',Name)
      else
        begin
          {Сообщаем о контроле очередного файла}
          GotoXY(1,WhereY);
          Write(' ':79);     		{Стираем строку}
          GotoXY(10,WhereY);
          Write(Name,' ');   		{Выводим имя файла}
          inc(Files);        		{Счетчик файлов}
          {Читаем первый сектор файла}
          sz := 512;
          if FileSize(FF)<512 then
            sz := FileSize(FF); 		{Длина чтения}
          BlockRead(FF,Sec,sz,nz);
          if sz<>nz then
            begin
              WriteLn(
               'Ошибка чтения из файла ',Name);
              Close(FF);
              goto Next
            end;
          {Контролируем файл:}
          if not Equal(Sec,Sec0,sz) then
            Goto VirDet;   		{Изменен - вирус!}
          Close(FF);
          goto Next;       		{Если нет отличий}
VirDet:   {Обнаружен вирус:}
          WriteLn('заражен!'#7);
          IsVirus := True;
          {Спрашиваем разрешения и
           лечим, если это возможно}
          case Cure(Sec0,Sec) of
          0: goto Next; {Вирус в началеEXE-файла не удалять}
          1:            {Вирус в конце файла}
            begin
              {Восстанавливаем первый сектор}
SetBeg:       Seek(FF,0);
              BlockWrite(FF,Sec0,sz,nz);
              {Восстанавливаем начальную длину}
              if sz=nz then
                begin
                  Seek(FF,Siz0);
                  Truncate(FF); 	{Отсекаем вирус}
                  Close(FF)
                end
              else
                begin
                  Close(FF);
                  WriteLn('Ошибка записи в файл ',ch^.Name)
                end
            end;
          2:        		{Вирус в начале COM-файла}
            begin
              {Перемещаем программу вверх}
              ReWriteFile(ch^.Siz0);
              {И восстанавливаем ее начало}
              Goto SetBeg;
            end;
          3:begin 	{Пользователь запретил лечение}
               Close(FF);
               goto Next
             end
          end  {case Cure}
        end;  {if not Disk_Error}
Next:  if KeyPressed and (ReadKey=#27) then
          Goto Stop
      end  {with ch^}
    end;  {for k:=0 to}
Stop:
  SetIntVec($62,Old62);
  Int13Addr := NIL;
  {Сообщаем об итогах проверки}
  Write(#13'Проверено ',Files,' файлов. ');
  if not IsVirus then
    WriteLn(tx2)
  else
    begin
      WriteLn(tx3);
      WriteLn(tx4);
      if OKay(tx5) then
        begin         		{Перезапускаем ДОС}
          Close(f);   		{Сохраняем архив}
          ReStartDOS
        end
    end;
  WriteLn('(C) 1992 г. В.В.Фаронов':80)
END;  {Check}
{
+----------------------------------------------+
|      Типы, константы и подпрограммы для      |
|  реализации диалога средствами Turbo Vision  |
+----------------------------------------------+
}
const  {Команды для диалога}
  cmQui = 199;   {Выход}
  cmSet = 200;   {Поместить новый}
  cmDel = 201;   {Удалить существующий}
  cmRun = 203;   {Выполнить проверку}
  cmFresh=204;   {Обновить информацию}
  cmAll = 205;   {Выбрать все}
  cmCD  = 206;   {Сменить каталог}
  cmCDW = 207;   {Сменить маску выбора файлов}
  cmEXE = 208;   {Сменить COM на EXE и наоборот}
type
  {Основное диалоговое окно}
  PDWT=^DWT;
  DWT = object(TDialog)
    Procedure HandleEvent(var Event: TEvent);Virtual;
    Procedure AddFiles;
    Procedure DelFiles;
    Procedure FreshFiles;
  end;

  {Скроллер списка файлов}
  PFileListBox = ^TFileListBox;
  TFileListBox = object(TListBox)
    PFL: PStringCollection;  		{Коллекция имен}
    MarkL: Byte;             		{Длина маркера}
    Procedure HandleEvent(var Event: TEvent);Virtual;
    Procedure GetDir(WC: String);
    Procedure MarkF(var s: String);
    Procedure DemarkF(var s: String);
    Procedure SetAll;
  end;

  {Строка ввода имени/маски файла}
  PInpLine = ^TInpLine;
  TInpLine = object(TInputLine)
    Procedure HandleEvent(var Event: TEvent);Virtual;
  end;

  {Окно режима добавления файлов}
  PAddFileBox = ^TAddFileBox;
  TAddFileBox = object(TDialog)
    WildC: String;       			{Маска}
    PL   : PFileListBox; 			{Скроллер списка}
    PInL : PInpLine;     			{Строка ввода маски}
    PDir : PStaticText;  			{Имя каталога}
    Procedure HandleEvent(var Event: TEvent);Virtual;
    Procedure SetFiles;
  end;

  {Окно режима удаления файлов}
  PDelFileBox =^TDelFileBox;
  TDelFileBox = object(TDialog)
    PL: PFileListBox;   {Скроллер списка}
    Procedure HandleEvent(var Event: TEvent);Virtual;
  end;

  {Окно справочной службы}
  PMyHelpWindow =^TMyHelpWindow;
  TMyHelpWindow = object(THelpWindow)
    Procedure HandleEvent(var Event: TEvent);Virtual;
    Function GetPalette: PPalette; Virtual;
  end;
{+----------------------------------------------+
 |            Создаем строку статуса и          |
 |            основное диалоговое окно          |
 +----------------------------------------------+}
PROCEDURE TVir.InitStatusLine;
  {Формирует строку статуса}
var
  R: TRect;
BEGIN
  GetExtent(R);
  R.A.Y := pred(R.B.Y); {R - координатыстроки статуса}
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0,$FFFF,
      NewStatusKey('~ESC~ Выход в ДОС = Стоп',kbF10,cmQuit,
      NewStatusKey('   ~F1~ Справочная служба', 					kbF1,cmHelp,NIL)),
    NIL)));
END; {TVir.InitStatusLine}
{------------------}
PROCEDURE TVir.Run;
  {Создает и использует основное диалоговое окно}
var
  DW: PDWT;
  R : TRect;
  Cntrl: Word;
const
  c1 = 'Программа защиты исполняемых файлов';
  c2 = '(C) 1992, В.В.Фаронов';
  cn = -5;   {Левая граница ряда кнопок}
BEGIN
  Stop := True;
  {Создаем окно с поясняющими надписями}
  R.Assign(5,5,75,14);
  DW := New(PDwt,
    Init(R,''));
  R.Assign(1,1,69,4);
  DW^.Insert(New(PStaticText,Init(R,#13#3+c1+#13+#3+c2)));
  {Вставляем кнопки}
  R.Assign(cn+7,6,cn+18,8);
  DW^.Insert(New(PButton,Init
          (R,' ~S~ Стоп ',cmCancel,bfNormal)));
  R.Assign(cn+18,6,cn+31,8);
  DW^.Insert(New(PButton,Init
          (R,'~A~ Добавить',cmSet,bfDefault)));
  R.Assign(cn+31,6,cn+44,8);
  DW^.Insert(New(PButton,Init
          (R,'~D~ Удалить ',cmDel,bfNormal)));
  R.Assign(cn+44,6,cn+58,8);
  DW^.Insert(New(PButton,Init
          (R,'~F~ Обновить',cmFresh,bfNormal)));
  R.Assign(cn+58,6,cn+72,8);
  DW^.Insert(New(PButton,Init
          (R,'~R~ Контроль',cmRun,bfNormal)));
  DW^.HelpCtx := 1;
  Cntrl := Desktop^.ExecView(DW);
END;  {TVir.Run}
{------------------}
FUNCTION TMyHelpWindow.GetPalette;
  {Готовит нужную палитру для справки}
const
  P = #16#17#18#19#20#47#21#13;
  C: String[8] = P;
BEGIN
  GetPalette := @C
END;
{------------------}
PROCEDURE TMyHelpWindow.HandleEvent;
  {Обрабатывает клавишу F5 для выдачи
   команды cmZoom (распахнуть окно)}
BEGIN
  THelpWindow.HandleEvent(Event);
  if Event.What=evKeyboard then
    if Event.KeyCode=kbF5 then
      begin
        Message(@Self,evCommand,cmZoom,@Self);
        ClearEvent(Event);
      end
END;
{------------------}
PROCEDURE TVir.DoHelp;
  {Осуществляет доступ к контекстно-зависимой   справочной службе}
var
  C: Word;
  HF: PHelpFile;
  HS: PDosStream;
  HW: PMyHelpWindow;
BEGIN
  {Открываем DOS-поток:}
  HS := New(PDosStream,Init(HelpFile, stOpenRead));
  {Создаем и инициируемэкземпляр объекта THelpFile:}
  HF := New(PHelpFile, Init(HS));
  if HS^.Status=stOk then
    begin
  {Cоздаем окно справочной службы и связываем
   его с потоком HS и текущим контекстом: }
      HW := New(PMyHelpWindow,Init(HF, GetHelpCtx));
      if ValidView(HW) <> NIL then
        begin
          C := ExecView(HW); {Выдаем справку}
          Dispose(HW)        {Удаляем окно}
        end
    end
  else
    begin
      Dispose(HF, Done);
      if MessageBox('Нет доступа к файлу '+
        HelpFile,NIL,mfError+mfOKButton)=0 then;
    end
END;  {DoHelp}
{------------------}
PROCEDURE DWT.HandleEvent(var Event: TEvent);
  {Обработчик событий основного окна. Реализуетнестандартные 


   команды, а также обрабатываетклавиши Left и Right    для смены 
активностикнопок}
BEGIN {DWT.HandleEvent}
  TDialog.HandleEvent(Event);
  case Event.What of
  evCommand:  {Обработка нестандартных команд}
    begin
      case Event.Command of
        cmHelp: AntiV^.DoHelp;
        cmSet: AddFiles;
        cmDel: DelFiles;
        cmRun: begin
                 Stop := False;
                 TDialog.Done;
                 Event.Command := cmCancel;
                 Exit
               end;
        cmFresh: FreshFiles;
      else
        Exit
      end;
      ClearEvent(Event)
    end;
  evKeyboard: {Клавиши Left-Right}
    begin
      case Event.KeyCode of
        kbLeft:  SelectNext(True);
        kbRight: SelectNext(False);
      end;
        ClearEvent(Event)
    end;
  end
END;  {DWT.HandleEvent}
{
+-------------------------------------+
|  Обработка команды "Добавить файл"  |
+-------------------------------------+
}
PROCEDURE DWT.AddFiles;
  {Обеспечивает выбор файлов из списка и
   помещает выбранные файлы в архив}
var
  R,RR : TRect;        {Координаты}
  Path0: String;       {Начальный каталог}
  PW   : PAddFileBox;  {Окно выбора файлов}
  ASB  : PScrollBar;   {Полоса скроллера}
  P    : PView;        {Вспомогательные элементы}
const
  c1 = 'Используйте клавиши курсора';
  c11= ' и Insert для выбора файла';
  c2 = 'ESC - отказаться и выйти';
  WildCard: String = '*.*';
BEGIN
  GetDir(0,Path0); {Path0- каталог по умолчанию}
  {Создаем диалоговое окно выбора файлов}
  R.Assign(0,0,80,23);
  PW := New(PAddFileBox, Init(R, ''));
  PW^.WildC := WildCard;
  {Вставляем поясняющий текст}
  R.Assign(1,1,79,4);
  PW^.Insert(New(PStaticText,Init(R,#3+c1+c11+#13#3+c2)));
  R.Assign(1,4,79,5);
  PW^.PDir := New(PStaticText,Init(R,#3+'Каталог  '+path0));
  PW^.Insert(PW^.PDir);
  {Вставдяем строку выбора имени/маски}
  R.Assign(25,7,52,8);
  PW^.PInL := New(PInpLine, Init(R,40));
  with PW^.PInL^ do
    State := State or sfCursorVis;
  PW^.PInL^.Data^ := WildCard;
  PW^.Insert(PW^.PInL);
  R.Assign(25,6,52,7);
  P := New(PLabel,Init(R,'~M~ Маска файлов:',PW^.PInL));
  PW^.Insert(P);
  R.Assign(52,7,54,8);
  P := New(PHistory, Init(R,PW^.PInL,1));
  PW^.Insert(P);
  {Вставляем скроллер списка файлов}
  R.Assign(2,10,77,19);
  RR.Assign(77,10,78,19);
  ASB := New(PScrollBar,Init(RR));
  PW^.Insert(ASB);
  New(PW^.PL,Init(R,4,ASB));
  PW^.PL^.GetDir(WildCard);
  PW^.Insert(PW^.PL);
  PW^.PL^.MarkL := 15;
  R.Assign(2,9,77,10);
  P := New(PLabel,Init(R,'~L~ Список файлов:',PW^.PL));
  PW^.Insert(P);
  {Вставляем кнопки}
  R.Assign(1,20,11,22);
  PW^.Insert(New(PButton, 	Init(R,'~S~ Стоп',cmCancel,bfNormal)));
  R.Assign(11,20,28,22);
  PW^.Insert(New(PButton,
    	Init(R,'~A~ Выбрать все',cmAll,bfNormal)));
  R.Assign(28,20,49,22);
  PW^.Insert(New(PButton, 	Init(R,'~D~ Сменить каталог',cmCD,bfNormal)));
  R.Assign(49,20,63,22);
  PW^.Insert(New(PButton,
    	Init(R,'~R~ Добавить',cmRun,bfNormal)));
  R.Assign(64,20,77,22);
  PW^.Insert(New(PButton,
    	Init(R,'~E~ EXE/COM',cmEXE,bfNormal)));
  PW^.HelpCtx := 2;
  {Выполняем диалог}
  DeskTop^.ExecView(PW);
  Dispose(PW,Done);
  ChDir(path0) {Восстановливаем текущий каталог}
END   {AddFiles};
{------------------}
PROCEDURE TAddFileBox.HandleEvent;
  {Обработчик событий окна выбора файлов}
var
  s: String;
  PCD: PChDirDialog;
  c: Word;
  R: TRect;
  p: Pointer;
label
  L1,All;
BEGIN {TAddFileBox.HandleEvent}
  TDialog.HandleEvent(Event);
  case Event.What of
  evCommand: case Event.Command of
    cmHelp: AntiV^.DoHelp;
    cmExe: begin
             if PInl^.Data^='*.COM' then
               PInl^.Data^ := '*.EXE'
             else
               PInl^.Data^ := '*.COM';
             PInl^.Draw;
             goto L1
           end;
    cmCDW:begin  {Изменена маска выбора файлов}
L1:
            S := PInL^.Data^; {Новая маска}
            PL^.List := NIL;
            {Удаляем коллекцию}
            Dispose(PL^.PFL, Done);
            WildC := S;
            {Создаем новую коллекцию}
            PL^.GetDir(S)
          end;
    cmCD: begin  {Сменить каталог}
            {Выбираем новый диск/каталог:}
            New(PCD, Init(0,0));
            c := DeskTop^.ExecView(PCD);
            GetDir(0,s);
         {s - имя нового каталога.Удаляем старое имя из окна}
            Dispose(PDir,Done);
            R.Assign(1,4,79,5);
            {Сообщить новое имя}
            PDir := New(PStaticText,Init(R,#3+'Каталог  '+s));
            Insert(PDir);
            Goto L1;
          end;
    cmAll: begin     {Выбрать все файлы}
All:         PL^.SetAll;
             PL^.Draw
           end;
    cmRun: SetFiles; {Добавить файлы в архив}
  end;
  evKeyDown: case Event.KeyCode of
    kbLeft:  SelectNext(True);
    kbRight: SelectNext(False);
    kbGrayPlus: Goto All;
  end;  {case Event.KeyCode}
  end;  {case Event.What}
  ClearEvent(Event)
END;  {TAddFileBox.HandleEvent}
{-------------------}
PROCEDURE TAddFileBox.SetFiles;
  {Помещает в архив выбранные файлы}
var
  S,ss: String;
  k: Integer;
  R: TRect;
  p: PWindow;
  PS: PString;
BEGIN
  {Сообщаем о добавлении файлов:}
  R.Assign(15,10,65,13);
  P := New(PWindow,Init(R,'Добавляется файл:',0));
  DeskTop^.Insert(P);
  {Выбираем из коллекции меченые файлы:}
  with PL^,PFL^ do
  for k := 0 to pred(count) do
    begin
      s := GetText(k,255);
      if s[Length(s)] = #251 then
        begin    {Выбран очередной меченый файл}
          DemarkF(s);            {Удаляем метку}
          System.GetDir(0,ss);
          if ss[Length(ss)] <> '\' then
            ss := ss+'\';
          ss := ss+s; {Добавляем маршрут поиска}
          {Сообщить имя}
          R.Assign(1,1,48,2);
          P^.Insert(New(PStaticText,Init(R,#3+ss)));
          SetFile(ss);  {Помещаем файл в архив}
          PS := At(k);
          PS^ := s
        end
    end;
  Dispose(P,Done);
  PL^.Draw
END;  {TAddFileBox.SetFiles}
{------------------}
PROCEDURE TInpLine.HandleEvent;
  {Обработчик событий строки ввода имени или
   маски выбора файлов: выдает команду cmCDW,
   если изменен статус ввода}
BEGIN
  TInputLine.HandleEvent(Event);
  if (Event.What = evKeyDown) and
     (Event.KeyCode = kbEnter) then
    Message(Owner,evBroadcast,cmCDW,@Self)
END;  {TInpLine.HandleEvent}
{-------------------}
PROCEDURE TFileListBox.SetAll;
  {Дополняет признаком выбора имена всех файлов}
var
  S: String;
  k: Integer;
BEGIN
  with PFL^ do
  for k := 0 to pred(Count) do
    begin
      s := GetText(k,255);
      if s[Length(s)] <> #251 then
        MarkF(s)
      else
        DemarkF(s);
      AtFree(k);
      Insert(NewStr(s))
    end
END;  {TFileListBox.SetAll}
{------------------}
PROCEDURE TFileListBox.GetDir(WC: String);
  {Формирует коллекцию из имен файловтекущего каталога}
var
  SR: SearchRec;
  AllExe: Boolean;
label
  Rep;
BEGIN
  AllExe := WC='*.*';
  if AllExe then
    WC := '*.com';
  PFL := New(PStringCollection, Init(10,5));
Rep:
  FindFirst(WC,$27,SR);
  while DOSError = 0 do
    begin
      if (SR.Name<>'.') and (SR.Name<>'..') then
        PFL^.Insert(NewStr(SR.Name));
      FindNext(SR)
    end;
  if AllExe then
    begin
      AllExe := False;
      WC := '*.EXE';
      goto Rep
    end;
  Self.NewList(PFL)
END;
{-------------------}
PROCEDURE TFileListBox.HandleEvent;
  {Обработчик событий окна выбора файлов:
   использует клавишу Insert для пометки файла}
var
  S: String;
BEGIN
  TListBox.HandleEvent(Event);
  if (Event.What = evKeyDown) then
  case Event.KeyCode of
    kbIns: begin  {Нажата клавиша Insert}
      S := GetText(Focused,255);{Получаем выбор}
      PFL^.AtFree(Focused);     	{Удаляем файлиз коллекции}
      if S[Length(s)] =#251 then
        DemarkF(s)             	{Убираем пометку}
      else
        MarkF(s);            	{Добавляем пометку}
      PFL^.Insert(NewStr(S)); 	{Вставляем в колл}
      Event.KeyCode := kbDown;	{Имитируем сдвиг}
      Draw;                   	{указателя вниз}
      TListBox.HandleEvent(Event);
    end;
    kbGrayPlus: 			{Серый "+" как "Выбрать все"}
      Message(@Self,evCommand,cmAll,@Self)
  end
END;  {TFileListBox.HandleEnent}
{------------------}
PROCEDURE TFileListBox.MarkF(var s: String);
  {Помещает в строку S маркер выбора}
BEGIN
  while Length(s)<MarkL do
    s := s+' ';
  s := s+#251
END;
{-----------------}
PROCEDURE TFileListBox.DemarkF(var s: String);
  {Удаляет маркер выбора из строки S}
BEGIN
  while (s[Length(s)]=#251) or (s[Length(s)]=' ') do
    System.Delete(s,Length(s),1)
END;
{
+------------------------------------+
|  Обработка команды "Удалить файл"  |
+------------------------------------+
}
PROCEDURE DelFile(ss: String);
  {Удаляет файл с именем SS из архива}
var
  n : Integer;
  ch: ^CheckType;
BEGIN
  {Ищем нужный файл в архиве:}
  n := 0;
  repeat
    ch := FColl^.At(n);
    inc(n)
  until (ch^.Name=ss);
  dec(n);
  {Удаляем запись}
  FColl^.AtDelete(n);
  FChange := True
END;  {DelFile}
{------------------}
PROCEDURE DWT.DelFiles;
  {Удаляет файлы из архива}
var
  R: TRect;
  PD: PDelFileBox;
  ASB: PScrollBar;
  k: Integer;
  ch: ^CheckType;
const
  c1 = 'Используйте клавиши курсора';
  c11= ' и Insert для выбора файла';
  c2 = 'ESC - отказаться и выйти';
BEGIN
  {Формируем окно}
  R.Assign(0,0,80,23);
  PD := New(PDelFileBox, Init(R,''));
  {Вставляем скроллер архивных файлов}
  R.Assign(77,5,78,19);
  ASB := New(PScrollBar, Init(R));
  PD^.Insert(ASB);
  R.Assign(2,5,77,19);
  PD^.PL := New(PFileListBox, Init(R,2,ASB));
  PD^.Insert(PD^.PL);
  PD^.PL^.MarkL := 34;
  R.Assign(1,1,79,3);
  PD^.Insert(New(PStaticText,Init(R,#3+c1+c11+#13#3+c2)));
  R.Assign(2,4,77,5);
  PD^.Insert(New(PLabel, 	Init(R,'~L~ Список архивных файлов:',PD^.PL)));
  {Вставляем кнопки}
  R.Assign(1,20,15,22);
  PD^.Insert(New(PButton,
      	Init(R,'~S~ Стоп',cmCancel,bfNormal)));
  R.Assign(16,20,35,22);
  PD^.Insert(New(PButton,
      	Init(R,'~A~ Выбрать все',cmAll,bfNormal)));
  R.Assign(36,20,50,22);
  PD^.Insert(New(PButton,
      	Init(R,'~R~ Удалить',cmRun,bfNormal)));
  {Создаем коллекцию имен файлов }
  PD^.PL^.PFL := New(PStringCollection,Init(10,5));
  for k := 0 to pred(FColl^.Count) do
  with PD^.PL^.PFL^ do
    begin
      ch := FColl^.At(k);
      Insert(NewStr(ch^.Name))
    end;
  PD^.PL^.NewList(PD^.PL^.PFL);
  PD^.HelpCtx := 3;
  {Выполняем}
  DeskTop^.ExecView(PD);
  Dispose(PD,Done)
END;  {DelFiles}
{----------------------}
PROCEDURE TDelFileBox.HandleEvent;
  {Обработчик событий окна удаления файла(ов)}
var
  R: TRect;
  k: Integer;
  s: String;
  p: PWindow;
BEGIN
  TDialog.HandleEvent(Event);
  case Event.What of
  evCommand: case Event.Command of
  cmHelp: AntiV^.DoHelp;
  cmAll: begin
           PL^.SetAll;
           PL^.Draw;
           ClearEvent(Event)
         end;
  cmRun:
    begin
      R.Assign(15,10,65,13);
      P := New(PWindow,Init(R,'Удаляется файл:',0));
      DeskTop^.Insert(P);
      with PL^,PFL^ do
      for k := 0 to pred(count) do
        begin
          s := GetText(k,255);
          if s[Length(s)] = #251 then
            begin 		{Только для помеченных файлов}
            {Удаляем радикал и пробелы в имени}
              while (s[Length(s)]=#251) or
                    (s[Length(s)]=' ') do
                System.Delete(s,Length(s),1);
              {Сообщаем имя удаляемого файла}
              R.Assign(1,1,48,2);
              P^.Insert(New(PStaticText,Init(R,#3+s)));
              DelFile(s)  	{Удаляем из архива}
            end
        end;
      Dispose(P,Done);
      EndModal(cmCancel)
    end  {cmRun}
  end;  {case Event.Command}
  evKeyDown: case Event.KeyCode of
    kbLeft : SelectNext(True);
    kbRight: SelectNext(False)
  end  {case Event.KeyCode}
  end; {case Event.What}
  ClearEvent(Event)
END;  {TDelFileBox.HandleEvent}
{
+-----------------------------------------+
| Обработка команды "Обновить информацию" |
+-----------------------------------------+
}
PROCEDURE DWT.FreshFiles;
  {Обновляет информацию в архиве}
var
  disk: Byte;
  k: Integer;
  R: TRect;
  p: PWindow;
  ch: ^CheckType;
  DI: Dir_Type;
  FF: file;
  sz,nz: Word;
label
  NotAcc;
BEGIN
  R.Assign(15,10,65,13);
  P := New(PWindow,Init(R,'Переустанавливается файл:',0));
  DeskTop^.Insert(P);
  k := 0;
  while k<FColl^.Count do
    begin
      ch := FColl^.At(k);
      with ch^ do
        begin
          R.Assign(1,1,48,2);
          {Выводим имя файла}
          P^.Insert(New(PStaticText,Init(R,#3+Name)));
          Assign(FF,Name);
          {$I-}
          Reset(FF,1);
          {$I+}
          if IOResult <> 0 then
       {Ошибка доступа - удаляем файл из архива}
            begin
NotAcc:       if MessageBox(
              'Нет доступа к файлу '+Name+#13+
              'Убрать контроль за файлом?',NIL,
              mfYesButton+mfNoButton)=cmYes then
                begin
                  FColl^.AtDelete(k);
                  FChange := True
                end
            end
          else  {Нормальное открытие файла}
            begin
              sz := 512;
              if sz > FileSize(FF) then
                sz := FileSize(FF);
              FillChar(Sec0,512,0);
              BlockRead(FF,Sec0,sz,nz);
              if sz=nz then
                begin
                  Siz0 := FileSize(FF);
                  FChange := True
                end
              else {Файл не читается}
                MessageBox('Ошибка доступа '+
                        'к файлу '+Name,NIL,0);
              System.Close(FF)
            end
        end; {with ch^}
      inc(k)
    end;  {while k<FColl^.Count}
  Dispose(P,Done)
END;  {FreshFiles}
{
+-----------------------------+
|  Основная программа AntiVir |
+-----------------------------+
}
var
  k: Word;
  ch:^CheckType;
BEGIN {AntiVir}
  {Проверяем параметры обращения}
  if not Auto then
    Dialog          	{Диалог с пользователем}
  else
    Stop := False;  	{Не было диалога}
  if not Stop then
    Check;          	{Контролируем файлы}
  {Если коллекция изменялась, переписываем еев архивный файл}
  if FChange then
    begin
      Seek(F,BegDat);
      for k := 0 to pred(FColl^.Count) do
        begin
          ch := FColl^.At(k);
          Write(F,ch^)
        end;
      Truncate(F)
    end;
  Close(F)          {Закрываем DAT-файл}
END.  {AntiVir} 


