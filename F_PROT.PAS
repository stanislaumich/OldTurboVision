{===============} Unit F_Prot; {================}
{
+---------------------------------------------+
| Модуль используется  для защиты программ от |
| нелегального копирования. Мобильный вариант |
| программы защищается с помощью ключевой ди- |
| скеты, стационарный вариант - за счет  кон- |
| троля даты создания ПЗУ.                    |
+---------------------------------------------+}
                     INTERFACE
Procedure ProtCheck(var P1,P2; var Res: Integer);
  {Проверяет легальность копии:
   Р1 - адрес процедуры NORMA;
   P2 - адрес процедуры ALARM;
   Res - результат работы:
     0: был вызов NORMA;
     1: был вызов ALARM;
     2: не вставлена дискета.
     Любое другое значение может быть только
     при трассировке программы}

Function SetOnHD: Integer;
  {Устанавливает копию на жесткий диск.
   Возвращает:
    -1 - не вставлена дискета;
    -2 - не мастер-дискета;
    -3 - защита от записи или ошибка записи;
    -4 - программа не скопирована на ЖД;
    -5 - ошибка доступа к ЖД;
    -6 - исчерпан лимит установок;
    -7 - программа уже установлена;
    >=0 - количество оставшихся установок}

Function RemoveFromHD: Integer;
  {Удаляет копию с жесткого диска
   Возвращает:
    -1 - не вставлена дискета;
    -2 - не мастер-дискета;
    -3 - защита от записи или ошибка записи ГД;
    -4 - программа не скопирована на ЖД;
    -5 - ошибка доступа к ЖД;
    >=0 - количество оставшихся установок}

                  IMPLEMENTATION
Uses DOS,F_Disk;
type
  TDate = array [1..4] of Word;
  TKey = record case Byte of
  0:(
    Hard: Word;        	{Ключ для шифровки данных}
    Dat : TDate);      	{Дата создания ПЗУ}
  1:(KeyW: array [1..5] of Word);
  end;
const
  TRK = 40;         	{Номер дорожки}
  HED = 0;          	{Номер головки}
  SEC = 1;          	{Номер сектора}
  SIZ = 1;          	{Код размера секторов}
  ETracks = 40;     {Эталонное количество дорожек на дискете}
  ETrackSiz = 9;    {Эталонное количество секторов на дорожке}
  Key:TKey = (KeyW:(0,0,0,0,0)); {Ключ стационарной программы}
{------------------}
Procedure TrassBlock1;
  {Макрос для борьбы с трассировкой
   с помощью модификации команды}
inline(
{@0:}
  $0E/                  {push cs}
  $E8/$00/$00/          {call @1}
{@1:}
  $5B/                  {pop  bx}
  $83/$EB/$04/          {sub  bx,@1-@0}
  $07/                  {pop  es}
  $53/                  {push bx}
  $B4/$C3/              {mov  ah,$C3}
  $26/$88/$67/$11/$90/  {mov  es:[bx+@2-@0],ah}
{@2:}
  $90/                  {nop}
  $B4/$90/              {mov  ah,$90}
  $26/$88/$67/$11/$90/  {mov  es:[bx+@2-@0],ah}
  $5B);                 {pop  bx}
{------------------}
Procedure TrassBlock2;
  {Борьба с трассировкой с помощью
   контроля времени}
var
  t1,t2: LongInt;
label
  Loop;
begin
Loop:
  t1 := MemL[0:$046C];
  t2 := 0;
  while MemL[0:$046C]=t1 do;
  while MemL[0:$046C]<t1+2 do
    inc(t2);
  if t2<500 then
    goto Loop;
  TrassBlock1
end;  {TrassBlock2}
{-------------------}
type
  TBuf = array [1..256] of Byte;
var
  P: Pointer;   {Ссылка на прежнюю ТПД}
  Buf: TBuf;    {Буфер чтения/записи сектора}
  R: registers; {Регистры}
{------------------}
Function DiskettPrepare(var DSK: Byte): Boolean;
type
  DBT_Type = record                     {Структура таблицы параметров дискеты}
    Reserv1 : array [0..2] of Byte;
    SizeCode: Byte;                     {Код размера сектора}
    LastSect: Byte;                     {Количество секторов на дорожке}
    Reserv2 : array [5..10] of Byte
  end;
var
  Info: TDisk;
  DBT,OldDBT:^DBT_Type;
begin
{Проверяем наличие дискеты}
  DSK := 0;     		        {Начинаем с диска A:}
  repeat
    TrassBlock1;
    GetDiskInfo(DSK,Info);
    if Disk_Error then
      if DSK=0 then
        DSK := 1  	                {Повторяем для диска В:}
      else
        DSK := 2  	                {Закончить с ошибкой}
  until not Disk_Error or (DSK=2);
  TrassBlock2;
  if Disk_Error then
    begin    		                {Нет доступа ни к А:, ни к В:}
      DiskettPrepare := False;
      Exit
    end;
{Проверяем тип дискеты}
  TrassBlock1;
  with Info do
    begin
      if (Tracks<>ETracks) or
         (TrackSiz<>ETrackSiz) then
        begin  {Не эталонный тип}
          DiskettPrepare := False;
          DSK := 3;
          Exit
        end;
{Переустанавливаем ТПД}
      TrassBlock1;
      GetIntVec($1E,P);
      OldDBT := P;
      New(DBT);
      DBT^:=OldDBT^;
      with DBT^ do
        begin
          SizeCode := SIZ;
          LastSect := ETrackSiz
        end;
      SetIntVec($1E,DBT)
    end;
  DiskettPrepare := True
end;  {DiskettPrepare}
{------------------}
Function LegalDiskett(var DSK: Byte): Boolean;
  {Проверяет легальность мобильной копии}
var
  k,n: Word;
begin
{Подготавливаем дискету}
  if DiskettPrepare(DSK) then
    begin
{Читаем ключевой сектор}
      TrassBlock1;
      with R do
        begin
          ah := 2;
          al := 1;
	  ch := TRK;
          cl := SEC;
          dh := HED;
          dl := DSK;
          es := seg(Buf);
          bx := ofs(Buf);
          Intr($13,R);
          SetIntVec($1E,P);
          if (Flags and FCarry)<>0 then
            begin
              LegalDiskett := False;
              DSK := 4;
              Exit
            end
          else
            begin {Проверяем содержимое сектора}
              for k := 2 to 256 do
                Buf[k] := Buf[k] xor Buf[1];
	      N := 0;
              {$R-}
              for k := 2 to 255 do
                N := N+Buf[k];
	      if (N mod 256=Buf[256]) then
                begin
                  DSK := 0;
                  LegalDiskett := True
                end
              else
                begin
                  DSK := 4;
                  LegalDiskett := False
                end
            end
        end
    end
  else
    LegalDiskett := False
end;  {LegalDiskett}
{------------------}
Function LegalHD(var DSK: Byte): Boolean;
  {Проверяет легальность стационарной копии}
var
  k: Word;
  Date :^TDate;
  Legal: Boolean;
label
  ExitL;
begin
{Расшифровываем ключ}
  TrassBlock1;
  with Key do for k := 2 to 5 do
    KeyW[k] := KeyW[k] xor KeyW[1];
{Проверяем дату изготовления ПЗУ}
  TrassBlock2;
  k := 1;
  Date := ptr($F000,$FFF5);
  repeat
    Legal := Date^[k]=Key.Dat[k];
    inc(k)
  until not Legal or (k=5);
  LegalHD := Legal;
  TrassBlock1;
{Проверяем дискету}
  if Legal then
    DSK := 0
  else
    Legal := LegalDiskett(DSK);
  LegalHD := Legal
end;  {LegalHD}
{-------------------}
Procedure ProtCheck(var P1,P2; var Res: Integer);
  {Проверяет легальность копии:
   P1 - адрес процедуры NORMA;
   Р2 - адрес процедуры ALARM;
   Res - результат работы:
     0: был вызов NORMA;
     1: был вызов ALARM;
     2: не вставлена дискета.
     Любое другое значение может быть только
     при трассировке программы}
type
  PType = Procedure;
var
  Norma: PType absolute P1;
  Alarm: PType absolute P2;
  DSK  : Byte;
label
  L1,L2;
begin
  Res := -1;
  TrassBlock1;
  if Key.Hard=0 then
    if LegalDiskett(DSK) then
      begin
        TrassBlock2;
L1:
        Norma;
        Res := 0
      end
    else
      begin
L2:
        TrassBlock2;
        if DSK=2 then
          Res := 2
        else
          begin
            Alarm;
            Res := 1
          end
      end
  else
    if LegalHD(DSK) then
        goto L1
      else
        goto L2
end;  {ProtCheck}
{------------------}
Procedure HidnSec(var Buf: TBuf; Inst,Limit: Byte);
  {Шифрует буфер ключевого сектора}
var
  k,n: Word;
begin
  TrassBlock1;
  Randomize;
  for k := 2 to 254 do
    Buf[k] := Random(256);
  Buf[1] := Random(255)+1;      {Ключ для шифровки}
  {$R-}
  Buf[17] := Inst;              {Счетчик установок}
  Buf[200] := Limit;            {Лимит установок}
  n := 0;                       {Подсчет КС}
  for k := 2 to 255 do
    n := n+Buf[k];
  Buf[256] := n mod 256;        {Контрольная сумма}
{Шифруем все данные}
  for k := 2 to 256 do
    Buf[k] := Buf[k] xor Buf[1];
  {$R+}
end;  {HidnSec}
{------------------}
Function SetOnHD: Integer;
  {Устанавливает стационарную копию
  на жесткий диск. Возвращает:
    -1 - не вставлена дискета;
    -2 - не мастер-дискета;
    -3 - защита от записи или ошибка записи ГД;
    -4 - программа не скопирована на ЖД;
    -5 - ошибка доступа к ЖД;
    -6 - исчерпан лимит установок;
    -7 - программа уже установлена.
    >=0 - количество оставшихся установок}
var
  DSK: Byte;                   {Диск}
  F: file;                     {Файл с программой}
  Date:^TDate;                 {Дата ПЗУ}
  NameF: String;               {Имя файла с программой}
  W: array [1..5] of Word;     {Заголовок файла}
  n: Word;                     {Счетчик}
  L: LongInt;                  {Файловое смещение}
  Inst: Byte;                  {Количество установок}
label
  ErrWrt;
begin
  TrassBlock1;
  if Key.Hard<>0 then
    begin
      SetOnHD :=-7;
      Exit
    end;
{Проверяем резидентность программы}
  NameF := FExpand(ParamStr(0));
  if NameF[1] in ['A','B'] then
    begin
      SetOnHD := -4;
      Exit
    end;
{Проверяем дискету}
  if not LegalDiskett(DSK) then
    begin
      case DSK of
      2: SetOnHD := -1;
      else
        SetOnHD := -2;
      end;
      Exit
    end;
  if (Buf[200]<>255) and (Buf[17]>=Buf[200]) then
    begin    {Исчерпан лимит установок}
      SetOnHD := -6;
      Exit
    end;
{Запоминаем дату изготовления ПЗУ}
  TrassBlock1;
  Date := ptr($F000,$FFF5);
  Key.Dat := Date^;
{Шифруем параметры}
  Randomize;
  with Key do
    while Hard=0 do Hard := Random($FFFF);
  for n := 2 to 5 do with Key do
    KeyW[n] := KeyW[n] xor Hard;
{Открываем файл с программой}
  TrassBlock1;
  Assign(F,NameF);
  Reset(F,1);
{Читаем заголовок файла}
  BlockRead(F,W,SizeOf(W),n);
  if n<>SizeOf(W) then
    begin
      SetOnHD := -5;
      Exit
    end;
{Ищем в файле положение Hard}
  R.ah := $62;
  MSDOS(R);
  P := @Key;
  L := round((DSeg-R.bx-16+W[5])*16.0)+ofs(P^);
  Seek(F,L);
{Записываем в файл}
  TrassBlock1;
  BlockWrite(F,Key,SizeOf(Key),n);
  if n<>SizeOf(Key) then
    begin
      SetOnHD := -5;
      Close(F);
      Exit
    end;
{Шифруем ключевой сектор}
  Inst := Buf[200]-Buf[17]-1;
  HidnSec(Buf,Buf[17]+1,Buf[200]);
{Записываем на дискету новый ключ}
  TrassBlock1;
  if not DiskettPrepare(DSK) then
    begin  {Ошибка доступа к дискете:удаляем установку}
ErrWrt:
      FillChar(Key,SizeOf(Key),0);
      Seek(F,L);
      BlockWrite(F,Key,SizeOf(Key),n);
      SetOnHD :=-3;
      Close(F);
      Exit
    end;
  with R do
    begin
      ah := 3;
      al := 1;
      ch := TRK;
      cl := SEC;
      dh := HED;
      dl := DSK;
      es := seg(Buf);
      bx := ofs(Buf);
      Intr($13,R);
      if (Flags and FCarry)<>0 then
        goto ErrWrt
    end;
{Нормальное завершение}
  SetOnHD := Inst;
  SetIntVec($1E,P);
  Close(F)
end;  {SetOnHD}
{------------------}
Function RemoveFromHD: Integer;
  {Удаляет стационарную копию.
   Возвращает:
    -1 - не вставлена дискета;
    -2 - не мастер-дискета;
    -3 - защита от записи или ошибка записи ГД;
    -4 - программа не скопирована на ЖД;
    -5 - ошибка доступа к ЖД;
    >=0 - количество оставшихся установок}
var
  k,n: Integer;
  NameF: String;
  B: array [1..512] of Byte;
  F: file;
  DSK,Inst: Byte;
begin
  TrassBlock1;
  if Key.Hard=0 then
    begin
      RemoveFromHD := -4;
      Exit
    end;
  if not LegalDiskett(DSK) then
    begin
      if DSK=2 then
	RemoveFromHD := -1
      else
	RemoveFromHD := -2;
      Exit
    end;
{Стираем файл с программой на ЖД}
  NameF := FExpand(ParamStr(0));
  if NameF[1] in ['A'..'B'] then
    begin
      RemoveFromHD := -4;
      Exit
    end;
  Assign(F,NameF);
  {$I-}
  Reset(F,1);
  {$I+}
  if IOResult<>0 then
    begin
      RemoveFromHD := -5;
      Exit
    end;
{Уничтожаем заголовок файла}
  FillChar(B,512,0);
  BlockWrite(F,B,512,n);
  if n<>512 then
    begin
      RemoveFromHD := -5;
      Exit
    end;
  Close(F);
  Erase(F);  {Стереть файл}
{Шифруем ключевой сектор}
  Inst := Buf[200]-Buf[17]+1;
  HidnSec(Buf,Buf[17]-1,Buf[200]);
{Записываем на дискету новый ключ}
  TrassBlock1;
  if not DiskettPrepare(DSK) then
    begin
      RemoveFromHD := -1;
      Exit
    end;
  with R do
    begin
      ah := 3;
      al := 1;
      ch := TRK;
      cl := SEC;
      dh := HED;
      dl := DSK;
      es := seg(Buf);
      bx := ofs(Buf);
      Intr($13,R);
      if (Flags and FCarry)<>0 then
        RemoveFromHD := -3
      else
        RemoveFromHd := Inst
    end;
end;  {RemoveFromHD}
{==============} end. {F_Prot} {================}
