Uses F_Anti,F_Disk;
type
  {����⥫� ࠧ���� ��}
  Part_Type = record
    BootF: Byte;    {���� ��⨢���� ࠧ����}
    BegHd: Byte;    {������� ��� ��砫� ࠧ����}
    BegSC: Word;    {ᥪ��/樫����}
    Sys  : Byte;    {��� ��⥬�}
    EndHd: Byte;    {������� ��� ���� ࠧ����}
    EndSC: Word;    {ᥪ��/樫����}
    Secs : LongInt; {�⭮�⥫�� ����ୠ砫쭮�� ᥪ��}
    Size : LongInt; {����� ࠧ���� � ᥪ���}
  end;  {Part_Type}
  {������� ����㧮筮�� ᥪ��}
  BootSecType = record
    a: array [0..$1BD] of Byte;
    Part: array [1..4] of Part_Type;
    b: array [1..2] of Byte
  end;
  {���ᠭ�� �������� �� � १�ࢭ�� 䠩��}
  TStruc = record
    BHd: Byte;
    BSC: Word;
    Sec: BootSecType
  end;
const
  tx: array [1..5] of String=(
    '�� �ணࠬ�� �।�����祭� ��� ����⠭������� �������� ���⪮�� ��᪠,',
    '�ᯮ�祭��� � १���� ࠡ��� �ணࠬ�� ANTIVIR',
    '� ��࠭����� � 䠩�� VIRDAT.$V$',
    '�ᯮ���� �맮� � 㪠������ ������� ���᪠ 䠩�� VIRDAT.$V$, ���ਬ��',
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
      WriteLn('����� ������ 䠩� ',Name);
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
      WriteLn('�訡�� � ������ 䠩�� '+
        Name);
      Halt
    end;
  for k := 1 to Count do with LD[k] do
    begin
      SetAbsSector($80,BHd,BSC,Sec);
      if Disk_Error then
        begin
          WriteLn('�訡�� ����� �� '+
            '���⪨� ���!');
          Halt
        end
    end;
  {����頥� �� ����砭��}
  Write('������� �� ����⠭������. '+
    '��१���㦠�� ��� (Y/N,Enter=Y)? ');
  ReadLn(Name);
  if (Name<>'n') or (Name<>'N') then
    asm
      mov  ax,$F000  {������� ��१���᪠}
      push ax        {����頥� ��� � �⥪}
      mov  ax,$FFF0  {���饭��}
      push ax        {����頥� � �⥪}
      retf           {��१���� ���}
    end
END.
