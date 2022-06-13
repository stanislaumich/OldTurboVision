{===============} UNIT F_Anti; {================}
{+-----------------------------------------------+
 | Модуль содержит программу контроля возможного |
 | заражения исполняемого EXE-файла компьютерным |
 | вирусом. Эталонный заголовок файла и его дли- |
 | на запоминаются  при первом запуске программы |
 | в типизированной  константе  HEAD.  Если факт |
 | заражения  установлен, программа сообщает  об |
 | этом, переносит  копию на место  испорченного |
 | вирусом  заголовка  файла  и  восстанавливает |
 |                  длину файла.                 |
 +-----------------------------------------------+}
                   INTERFACE
var
  CheckVirusResult: Integer;
  {Результат работы программы:
    = 0: вирус не обнаружен;
    = 1: установлена защита файла;
    =-1: вирус удален с разрешения пользователя;
    =-2: вирус удален автоматически;
    =-3: контроль блокирован ключом /NOANTI;
    =-4: вирус расположен в начале файла,удаление невозможно}
                 IMPLEMENTATION
Uses DOS, CRT;
var
  fff: file;
Procedure CheckFile;
type
  {Заголовок EXE-файла}
  HeadExeType = record case Byte of
  0:(
    Sign   : Word; {Сигнатура 'MZ' = $5A4D}
    PartPag: Word; {Часть неполного сектора}
    PageCnt: Word; {Количество секторов}
    ReloCnt: Word; {Количество элементов в таблице перемещения}
    HdrSize: Word; {Длина заголовка в параграфах}
    MinMem : Word; {Минимальный размер кучи}
    MaxMem : Word; {Максимальный размер кучи}
    ReloSS : Word; {Начальное значениесегмента стека SS}
    ExeSP  : Word; {Начальное значениуказателя стека SP}
    ChkSum : Word; {Контрольная суммавсех слов файла}
    ExeIP  : Word; {Смещение точкизапуска программы}
    ReloCS : Word; {Начальное значениесегмента кода CS}
    TablOff: Word; {Смещение таблицы перемещения}
    Overlay: Word; {Номер оверлея (0 для главной программы)});
  1: (Hem: array [1..14] of Word)
  end;  {HeadExe}
  {Ключ незараженного файла}
  KeyType = record
    HE: HeadExeType;  {Заголовок файла}
    HL: LongInt;      {Исходная длина файла}
    HF: Boolean;      {Флаг установки ключа}
    Key: Word         	{Ключ для шифровки}
  end;
  s8 = String[8];
const
  H: KeyType =
    (HE: (Hem:(0,0,0,0,0,0,0,0,0,0,0,0,0,0));
     HL: 0;
     HF: False;
     Key: 0);
  Key: array [1..4] of s8 =
    ('/NOANTI','/NOQUERY','/NOALARM','/NOCOPY');
var
  f,ff: file;
  Name: String;
  NoAnti, NoQuery, NoAlarm, NoCopy: Boolean;
  Offset: Word;
  Head: KeyType;

Procedure AntiAIDS;
  {Удаляет обнаруженный вирус}
var
  c: Char;
  p: ^Byte;
  Delta: LongInt;

Procedure WriteVirFile;
  {Переписывает файл f в файл ff
   максимально возможными блоками}
var
  k,L: LongInt;
  p:^Byte;
begin
  L := FileSize(f);     	{L - незаписанный остаток файла}
  repeat
    k := MaxAvail;
    if k > 65520 then
      k := 65520;
    if k > L then
      k := L;
    GetMem(p,k);       	        {k - длина буфера перезаписи}
    BlockRead(f,p^,k);
    BlockWrite(ff,p^,k);
    FreeMem(p,k);
    dec(L,k)
  until L = 0
end;  {WriteVirFile}


Procedure FileInit;
  {Создает резервную копию зараженного файла}
begin
  {Изменяем расширение файла на VIR:}
  Name := copy(Name,1,pos('.',Name));
  Assign(ff,Name+'VIR');
  ReWrite(ff,1);    	{ff - копия файла с расширением VIR}
  Seek(f,0);
  WriteVirFile;     	{Переписываем файл}
  Close(ff)
end;  {FileInit}

const
  txt1='Вирус расположен в начале файла.';
  txt2=' Удаление невозможно.';
  txt3=#13#10'Нажмите любую клавишу...';
begin {AntiAIDS}
  if not NoCopy then
    FileInit;  		{Создаем резервную копию файла}
  if Head.HE.ReloCS > H.HE.ReloCS then
    begin   			{Вирус в конце файла}
      {Восстанавливаем эталонный заголовок:}
      Seek(f,0);
      BlockWrite(f,H.HE,SizeOf(H.HE));
      {Восстанавливаем эталонную длину:}
      Seek(f,H.HL);
      Truncate(f);                      {Отсекаем вирус}
      if NoAlarm or NoQuery then
        CheckVirusResult := -2  	{Удален автоматически}
      else
        CheckVirusResult := -1  	{Удален с разрешения}
    end
  else
    begin
      if not NoAlarm then
        begin
          Write(txt1,txt2,txt3);
          c := ReadKey;
          if c = #0 then
            c := ReadKey
        end;
      CheckVirusResult := -4   	{Вирус не удален}
    end
end;  {AntiAIDS}
{------------------}
Procedure Check;
  {Осуществляет контроль заголовка файла}
var
  k: Byte;
  s: String[1];
begin  {Check}
  CheckVirusResult := 0;
  {Дешифруем ключ:}
  with H,H.HE do
    for k := 1 to 14 do
      Hem[k] := Hem[k] xor Key;
  {Проверяем заголовок:}
  k := 1;
  while (CheckVirusResult=0) and (k <= 14) do
    begin
      if H.HE.Hem[k] <> Head.HE.Hem[k] then
        CheckVirusResult := -1;
      inc(k)
    end;
  if CheckVirusResult =-1 then
    begin              		{Обнаружен факт заражения}
      if NoAlarm then
        AntiAIDS
      else
        begin
          WriteLn('Файл ',Name,' заражен вирусом!'#7);
          if NoQuery then
            AntiAIDS
          else
            begin
              Write('Удалять вирус (Y/N, умлч.Y)? ');
              s := '';
              ReadLn(s);
              if (s='') or (UpCase(s[1])<>'N')
                then AntiAIDS
              else
                CheckVirusResult := -3
            end
        end
    end
end;   {Check}
{------------------}
Procedure Save;
  {Запоминает заголовок файла в константе HEAD}
var
  s: LongInt;
  r: registers;
  p: Pointer;
begin {Save}
  with Head,Head.HE do
    begin
      HL := FileSize(f); 	{Получаем длину файла}
      HF := True;        	{Устанавливаемпризнак контроля}
      r.AH := $62;
      MSDOS(r);   	        {Получаем в r.BX сегмент PSP}
      p := @H;
      s := round((DSeg-r.BX-16+HdrSize)*16.0)+ofs(p^);
        {s - смещение ключа H от начала файла}
    end;
  Seek(f,s); 		{Позиционируем файл на начало ключа}
  {Шифруем ключ:}
  Randomize;
  Head.Key := Random($FFFF);
  with Head,Head.HE do
    for s := 1 to 14 do
      Hem[s] := HE.Hem[s] xor Key;
  {Запоминаем ключ в файле}
  BlockWrite(f,Head,SizeOf(H));
  CheckVirusResult := 1
end;  {Save}
{------------------}
Function UpString(s: String): string;
  {Преобразует символы строки S в верхний регистр}
var
  k: Byte;
begin {UpString}
  for k := 1 to Length(s) do
    s[k] := UpCase(s[k]);
  UpString := s
end;  {UpString}
{------------------}
Procedure GetParams;
  {Получить параметры запуска}
var
  k,j: Byte;
begin
  {Анализ ключей команды запуска:}
  NoAnti  := False;
  NoQuery := False;
  NoAlarm := False;
  NoCopy  := False;
  for k := 1 to ParamCount do
    for j := 1 to 4 do
      if UpString(ParamStr(k)) = Key[j] then
        case j of
          1: NoAnti  := True;
          2: NoQuery := True;
          3: NoAlarm := True;
          4: NoCopy  := True
        end;
end;  {GetParams}
begin {CheckFile}
  Name := ParamStr(0);   	{Name содержит полное имя файла}
  GetParams;    		{Получаем параметры вызова}
  if NoAnti then
    CheckVirusResult :=-3
  else
    begin
      Assign(f,Name);
      Reset(f,1);    	{Длина блока равна 1 байт}
      BlockRead(f,Head,SizeOf(H));    {Читаем заголовок файла}
      if H.HF then
        Check        	{Проверяем заголовок файла}
      else
        Save;        	{Запоминаем заголовок}
      Close(f)
    end
end;  {CheckFile}
{
  Все действия осуществляются установочной частью модуля:
}
begin
  CheckFile
end.  {F_Anti}
