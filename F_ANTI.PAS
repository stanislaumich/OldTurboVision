{===============} UNIT F_Anti; {================}
{+-----------------------------------------------+
 | ����� ᮤ�ন� �ணࠬ�� ����஫� ���������� |
 | ��ࠦ���� �ᯮ��塞��� EXE-䠩�� ��������� |
 | ����ᮬ. �⠫���� ��������� 䠩�� � ��� ���- |
 | �� ������������  �� ��ࢮ� ����᪥ �ணࠬ�� |
 | � ⨯���஢�����  ����⠭�  HEAD.  �᫨ 䠪� |
 | ��ࠦ����  ��⠭�����, �ணࠬ�� ᮮ�頥�  �� |
 | �⮬, ��७���  ����� �� ����  �ᯮ�祭���� |
 | ����ᮬ  ���������  䠩��  �  ����⠭�������� |
 |                  ����� 䠩��.                 |
 +-----------------------------------------------+}
                   INTERFACE
var
  CheckVirusResult: Integer;
  {������� ࠡ��� �ணࠬ��:
    = 0: ����� �� �����㦥�;
    = 1: ��⠭������ ���� 䠩��;
    =-1: ����� 㤠��� � ࠧ�襭�� ���짮��⥫�;
    =-2: ����� 㤠��� ��⮬���᪨;
    =-3: ����஫� �����஢�� ���箬 /NOANTI;
    =-4: ����� �ᯮ����� � ��砫� 䠩��,㤠����� ����������}
                 IMPLEMENTATION
Uses DOS, CRT;
var
  fff: file;
Procedure CheckFile;
type
  {��������� EXE-䠩��}
  HeadExeType = record case Byte of
  0:(
    Sign   : Word; {�������� 'MZ' = $5A4D}
    PartPag: Word; {����� ��������� ᥪ��}
    PageCnt: Word; {������⢮ ᥪ�஢}
    ReloCnt: Word; {������⢮ ������⮢ � ⠡��� ��६�饭��}
    HdrSize: Word; {����� ��������� � ��ࠣ���}
    MinMem : Word; {��������� ࠧ��� ���}
    MaxMem : Word; {���ᨬ���� ࠧ��� ���}
    ReloSS : Word; {��砫쭮� ���祭��ᥣ���� �⥪� SS}
    ExeSP  : Word; {��砫쭮� ���祭�㪠��⥫� �⥪� SP}
    ChkSum : Word; {����஫쭠� �㬬���� ᫮� 䠩��}
    ExeIP  : Word; {���饭�� �窨����᪠ �ணࠬ��}
    ReloCS : Word; {��砫쭮� ���祭��ᥣ���� ���� CS}
    TablOff: Word; {���饭�� ⠡���� ��६�饭��}
    Overlay: Word; {����� ���૥� (0 ��� ������� �ணࠬ��)});
  1: (Hem: array [1..14] of Word)
  end;  {HeadExe}
  {���� ����ࠦ������ 䠩��}
  KeyType = record
    HE: HeadExeType;  {��������� 䠩��}
    HL: LongInt;      {��室��� ����� 䠩��}
    HF: Boolean;      {���� ��⠭���� ����}
    Key: Word         	{���� ��� ��஢��}
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
  {������ �����㦥��� �����}
var
  c: Char;
  p: ^Byte;
  Delta: LongInt;

Procedure WriteVirFile;
  {��९��뢠�� 䠩� f � 䠩� ff
   ���ᨬ��쭮 �������묨 �������}
var
  k,L: LongInt;
  p:^Byte;
begin
  L := FileSize(f);     	{L - ������ᠭ�� ���⮪ 䠩��}
  repeat
    k := MaxAvail;
    if k > 65520 then
      k := 65520;
    if k > L then
      k := L;
    GetMem(p,k);       	        {k - ����� ���� ��१����}
    BlockRead(f,p^,k);
    BlockWrite(ff,p^,k);
    FreeMem(p,k);
    dec(L,k)
  until L = 0
end;  {WriteVirFile}


Procedure FileInit;
  {������� १�ࢭ�� ����� ��ࠦ������ 䠩��}
begin
  {�����塞 ���७�� 䠩�� �� VIR:}
  Name := copy(Name,1,pos('.',Name));
  Assign(ff,Name+'VIR');
  ReWrite(ff,1);    	{ff - ����� 䠩�� � ���७��� VIR}
  Seek(f,0);
  WriteVirFile;     	{��९��뢠�� 䠩�}
  Close(ff)
end;  {FileInit}

const
  txt1='����� �ᯮ����� � ��砫� 䠩��.';
  txt2=' �������� ����������.';
  txt3=#13#10'������ ���� �������...';
begin {AntiAIDS}
  if not NoCopy then
    FileInit;  		{������� १�ࢭ�� ����� 䠩��}
  if Head.HE.ReloCS > H.HE.ReloCS then
    begin   			{����� � ���� 䠩��}
      {����⠭�������� �⠫���� ���������:}
      Seek(f,0);
      BlockWrite(f,H.HE,SizeOf(H.HE));
      {����⠭�������� �⠫����� �����:}
      Seek(f,H.HL);
      Truncate(f);                      {��ᥪ��� �����}
      if NoAlarm or NoQuery then
        CheckVirusResult := -2  	{������ ��⮬���᪨}
      else
        CheckVirusResult := -1  	{������ � ࠧ�襭��}
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
      CheckVirusResult := -4   	{����� �� 㤠���}
    end
end;  {AntiAIDS}
{------------------}
Procedure Check;
  {�����⢫�� ����஫� ��������� 䠩��}
var
  k: Byte;
  s: String[1];
begin  {Check}
  CheckVirusResult := 0;
  {�����㥬 ����:}
  with H,H.HE do
    for k := 1 to 14 do
      Hem[k] := Hem[k] xor Key;
  {�஢��塞 ���������:}
  k := 1;
  while (CheckVirusResult=0) and (k <= 14) do
    begin
      if H.HE.Hem[k] <> Head.HE.Hem[k] then
        CheckVirusResult := -1;
      inc(k)
    end;
  if CheckVirusResult =-1 then
    begin              		{�����㦥� 䠪� ��ࠦ����}
      if NoAlarm then
        AntiAIDS
      else
        begin
          WriteLn('���� ',Name,' ��ࠦ�� ����ᮬ!'#7);
          if NoQuery then
            AntiAIDS
          else
            begin
              Write('������� ����� (Y/N, 㬫�.Y)? ');
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
  {���������� ��������� 䠩�� � ����⠭� HEAD}
var
  s: LongInt;
  r: registers;
  p: Pointer;
begin {Save}
  with Head,Head.HE do
    begin
      HL := FileSize(f); 	{����砥� ����� 䠩��}
      HF := True;        	{��⠭���������ਧ��� ����஫�}
      r.AH := $62;
      MSDOS(r);   	        {����砥� � r.BX ᥣ���� PSP}
      p := @H;
      s := round((DSeg-r.BX-16+HdrSize)*16.0)+ofs(p^);
        {s - ᬥ饭�� ���� H �� ��砫� 䠩��}
    end;
  Seek(f,s); 		{����樮���㥬 䠩� �� ��砫� ����}
  {����㥬 ����:}
  Randomize;
  Head.Key := Random($FFFF);
  with Head,Head.HE do
    for s := 1 to 14 do
      Hem[s] := HE.Hem[s] xor Key;
  {���������� ���� � 䠩��}
  BlockWrite(f,Head,SizeOf(H));
  CheckVirusResult := 1
end;  {Save}
{------------------}
Function UpString(s: String): string;
  {�८�ࠧ�� ᨬ���� ��ப� S � ���孨� ॣ����}
var
  k: Byte;
begin {UpString}
  for k := 1 to Length(s) do
    s[k] := UpCase(s[k]);
  UpString := s
end;  {UpString}
{------------------}
Procedure GetParams;
  {������� ��ࠬ���� ����᪠}
var
  k,j: Byte;
begin
  {������ ���祩 ������� ����᪠:}
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
  Name := ParamStr(0);   	{Name ᮤ�ন� ������ ��� 䠩��}
  GetParams;    		{����砥� ��ࠬ���� �맮��}
  if NoAnti then
    CheckVirusResult :=-3
  else
    begin
      Assign(f,Name);
      Reset(f,1);    	{����� ����� ࠢ�� 1 ����}
      BlockRead(f,Head,SizeOf(H));    {��⠥� ��������� 䠩��}
      if H.HF then
        Check        	{�஢��塞 ��������� 䠩��}
      else
        Save;        	{���������� ���������}
      Close(f)
    end
end;  {CheckFile}
{
  �� ����⢨� �����⢫����� ��⠭���筮� ����� �����:
}
begin
  CheckFile
end.  {F_Anti}
