Uses F_Anti,F_Disk;
type
  {Описатель раздела ЖД}
  Part_Type = record
    BootF: Byte;    {Флаг активности раздела}
    BegHd: Byte;    {Головка для начала раздела}
    BegSC: Word;    {сектор/цилиндр}
    Sys  : Byte;    {Код системы}
    EndHd: Byte;    {Головка для конца раздела}
    EndSC: Word;    {сектор/цилиндр}
    Secs : LongInt; {Относительный номерначального сектора}
    Size : LongInt; {Длина раздела в секторах}
  end;  {Part_Type}
  {Структура загрузочного сектора}
  BootSecType = record
    a: array [0..$1BD] of Byte;
    Part: array [1..4] of Part_Type;
    b: array [1..2] of Byte
  end;
  {Описание структуры ЖД в резервном файле}
  TStruc = record
    BHd: Byte;
    BSC: Word;
    Sec: BootSecType
  end;
const
  tx: array [1..5] of String=(
    'Эта программа предназначена для восстановления структуры жесткого диска,',
    'испорченной в результате работы программы ANTIVIR',
    'и сохраненной в файле VIRDAT.$V$',
    'Используйте вызов с указанием маршрута поиска файла VIRDAT.$V$, например',
    '  SET$V$ A:\');
var
  Name: String;
  F: File of TStruc;
  LD: array [1..48] of TStruc;
  k: Byte;
  Err: Boolean;
  Count: Byte;
BEGIN
  if ParamCount<>1 then
    begin
      for k := 1 to 5 do
        WriteLn(tx[k]);
      Halt
    end;
  Name := ParamStr(1);
  for k := 1 to Length(Name) do
    Name[k] := UpCase(Name[k]);
  k := Pos('VIRDAT',Name);
  if k<>0 then
    Delete(Name,k,Length(Name)-k);
  if Name[Length(Name)]<>'\' then
    Name := Name+'\';
  Name := Name+'VIRDAT.$V$';
  {$I-}
  Assign(F,Name);
  Reset(F);
  {$I+}
  if IOResult<>0 then
    begin
      WriteLn('Нельзя открыть файл ',Name);
      Halt;
    end;
  Count := 0;
  Err := False;
  while not (Err or EOF(F)) do
    begin
      inc(Count);
      {$I-}
      Read(F,LD[Count]);
      {$I+}
      Err := IOResult<>0
    end;
  Close(F);
  if odd(k) or Err then
    begin
      WriteLn('Ошибка в данных файла '+
        Name);
      Halt
    end;
  for k := 1 to Count do with LD[k] do
    begin
      SetAbsSector($80,BHd,BSC,Sec);
      if Disk_Error then
        begin
          WriteLn('Ошибка записи на '+
            'жесткий диск!');
          Halt
        end
    end;
  {Сообщаем об окончании}
  Write('Структура ЖД восстановлена. '+
    'Перезагружать ДОС (Y/N,Enter=Y)? ');
  ReadLn(Name);
  if (Name<>'n') or (Name<>'N') then
    asm
      mov  ax,$F000  {Сегмент перезапуска}
      push ax        {Помещаем его в стек}
      mov  ax,$FFF0  {Смещение}
      push ax        {Помещаем в стек}
      retf           {Перезапуск ДОС}
    end
END.
