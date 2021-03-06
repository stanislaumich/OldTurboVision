{$X+,T-}
{
+----------------------------------------------+
|   �ணࠬ�� ����஫� �ᯮ��塞�� 䠩��� ��   |
|  ����������� ��ࠦ���� ��������� ����ᮬ. |
|   �� ����᪥ �������� ANTIVIR ���樨�����  |
|    ��������� ०��, �� ����᪥ ��������    |
|  ANTIVIR /AUTO �����⢫���� ��⮬���᪨� |
| ����஫� 䠩���, ��ࠬ���� ������ �࠭����  |
|           � 䠩�� ANTIVIR.DAT.               |
+----------------------------------------------+}
Uses F_Anti, {����砥� ��⮪���஫� �ணࠬ��}
     CRT, DOS, F_Disk, Memory, StdDlg, MsgBox,
     HelpFile, {��� ����� � ��室��� ⥪�� �室�� � ���⠢�� TV � ���筮
               �ᯮ�������� � ��⠫��� \bp\examples\dos\tvdemos}
     App, Dialogs, Objects, Drivers,Views, Menus;
{
+----------------------------------------------+
|          �������� ��।������              |
+----------------------------------------------+
}
type
  {����⥫� ࠧ���� ��}
  Part_Type = record
    BootF: Byte;    {���� ��⨢���� ࠧ����}
    BegHd: Byte;    {������� ��� ��砫� ࠧ����}
    BegSC: Word;    {ᥪ��/樫����}
    Sys  : Byte;    {��� ��⥬�}
    EndHd: Byte;    {������� ��� ���� ࠧ����}
    EndSC: Word;    {ᥪ��/樫����}
    Secs : LongInt; {�⭮�⥫�� ����� ��砫쭮�� ᥪ��}
    Size : LongInt; {����� ࠧ���� � ᥪ���}
  end;  {Part_Type}
  {������� ����㧮筮�� ᥪ��}
  BootSecType = record
    a: array [0..$1BD] of Byte;
    Part: array [1..4] of Part_Type;
    b: array [1..2] of Byte
  end;
  {���� ᥪ�� 䠩��}
  LType = record case Byte of
   1: (Boot: BootSecType);
   2: (W: array [1..256] of Word);
  end;
  {���ᠭ�� �����᪮�� ��᪠ � ��������� ��娢���� 䠩��}
  TLogicD = record
    BHd: Byte;      {��砫쭠� �������}
    BSC: Word;      {�����-樫����}
    Space: LongInt; {��ꥬ � ᥪ���}
  end;


  {���ᠭ�� �������� �� � १�ࢭ�� 䠩��}
  TStruc = record
    BHd: Byte;
    BSC: Word;
    Sec: BootSecType
  end;
  {���ᠭ�� 䠩�� � ��娢��� 䠩��}
  CheckType = record
    Name: PathStr;    		{������ ��� 䠩��}
    Sec0: LType;      		{�⠫�� ��ࢮ�� ᥪ��}
    Siz0: LongInt     		{�⠫����� ����� 䠩��}
  end;
  {��������� ��娢���� 䠩��}
  THead = record
  case Byte of
  0:(
    HD   : String[7];     	{'�NTIVIR'}
    BIOS : LongInt;       	{�����.�㬬� BIOS}
    Int13: Pointer;       	{���� �室� � Int13}
    NDisk: Byte;          	{������⢮ ��}
    SecTr: Byte;          	{# ᥪ�஢ �� ��஦��}
    Heads: Byte;          	{������⢮ �������}
    LDisk: array [1..48]of TLogicD; 	{��뫪� �� �� � �� ����⥫�}
    Beg13: array [1..SizeOf(CheckType)-27-
      48*SizeOf(TLogicD)] of Byte);	{��砫� Int13}
  1:(CT: CheckType)
  end;
{Turbo Vision �ணࠬ��, ���ᯥ稢���� ������}
  PVir =^TVir;
  TVir = object(TApplication)
    HelpFile: String;    		{��� Help-䠩��}
    Procedure InitStatusLine; Virtual;
    Procedure Run; Virtual;
    Procedure DoHelp;    		{�뤠�� �ࠢ��}
  end;
var
  F: File of CheckType;     	{��娢�� 䠩�}
  Head: THead;              	{��� ���������}
  FColl: PCollection;       	{��娢 � �����}
  BegDat: LongInt;              {��砫� 䠩����� ������ � ��娢�}
const
  Stop   : Boolean = True;  {�ਧ��� �⪠�� �� ����஫�}
  IsVirus: Boolean = False; {�ਧ��� �����㦥����� �����}
  Files  : Word = 0;        {���稪 䠩���}
  AntiV  : PVir = NIL;      {�����⥫� �� ������}
  FChange: Boolean = False; {�ਧ��� ��������� ������樨}
{
+-----------------------------------------------+
|    ����, ��楤��� � �㭪樨, ॠ�����騥     |
|    ����஫� ����㧮���  ᥪ�஢ � 䠩���    |
|        �� ��������� ��ࠦ���� ����ᠬ�        |
|     � ��祭�� ��ࠦ����� 䠩��� (ᥪ�஢)    |
+-----------------------------------------------+
}
PROCEDURE Msg(S: String);
  {����஫���� ⥪�騩 �����०�� � �뢮��� ᮮ�饭�� S
   � ������� Turbo Vision ��� �����஬ WriteLn}
var
  R: TRect;
  C: Char;
  AOpt: Word;

BEGIN
  if AntiV=NIL then
    begin   {����� ०�� �뢮��}
      WriteLn(S);
      Write('������ ���� �������...');
      C := ReadKey;
      While KeyPressed do
        C := ReadKey
    end
  else
    begin  {�뢮� � Turbo Vision}
      AOpt := mfOKButton;
      AOpt := MessageBox(S,NIL,AOpt)
    end
END;  {Msg}
{------------------}
PROCEDURE WriteFile(Source: CheckType);
  {�����뢠�� � 䠩� F ��।��� ������
   � ����஫���� �訡��}
var
  k: Integer;
BEGIN
  {$I-}
  Write(F,Source);
  {$I+}
  if IOResult<>0 then
    begin
      Msg('�訡�� ����� � ��娢�� 䠩�');
      Halt
    end
END;  {WriteFile}
{------------------}
PROCEDURE CheckErr(S: String);
  {�஢���� ����� ��᪠, �뢮��� ᮮ�饭�� S
  � ��⠭�������� ���, �᫨ Disk_Error=True}
BEGIN
  if not Disk_Error then
    Exit;
  Msg(S);
  Halt
END;  {CheckErr}
{------------------}
FUNCTION Equal(var A,B; Size: Word): Boolean;
  {�ࠢ������ Size ���� �� ��६�����
   � � � � �����頥� TRUE, �᫨ ��� ᮢ������}
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
  {���� ᮮ�饭�� S, �����頥� TRUE,�᫨ ����� ������ Y}
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
  {�����⢫�� ��१���� DOS}
BEGIN
  asm
    mov  ax,$F000  	{������� ��१���᪠}
    push ax        	{����頥� ��� � �⥪}
    mov  ax,$FFF0  	{���饭��}
    push ax        	{����頥� � �⥪}
    retf           	{��१���� ���}
  end
END;  {ReStartDos}
{-------------------}
const
  Int13Addr: Pointer=NIL; {���� Int13 � BIOS}
  Old62: Pointer=NIL;     {���� ����� $62}
{-------------------}
PROCEDURE RWSecInt13(Op,Hd,SC: Word; var Targ);
{��⠥� ��� �����뢠�� ��᮫��� ᥪ�� �� �
 ������� �����।�⢥����� �맮�� Int13 �� BIOS}

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
  {��뢠���� � ��砥 �����㦥��� ��������� � ������� ��}
var
  k: Integer;
  F1: File of TStruc;
  c: CheckType;
  Boot: BootSecType;
  S,ss: String;
Procedure Save(H: Byte; SC: Word);
  {�����뢠�� ��᮫��� ���न����
   ᥪ�� � ᠬ ᥪ�� � 䠩� F1}
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
    '�����㦥�� ��������� � ������� ���⪮�� ��᪠, ����� ����� ����',
    '᫥��⢨�� ��ࠦ���� �� ����ᮬ!',
    '��祭�� ����㧮筮�� ����� �᭮���� �� ����⠭������� �������� ��',
    '� ⮬ ����, � ����� ��� �뫠 � ������� ᮧ����� ��娢���� 䠩��.',
    '�� ������ ����� ������ �����ࠢ��� �। ��襬� ��, �᫨ ��娢�� 䠩�',
    'ᮤ�ন� �訡���� ���ଠ�� (���ਬ��, ���� �� ��㣮�� ��) ��� �� ���뢠��',
    '����� ࠧ������ ���⪮�� ��᪠ �� �����᪨� ࠧ����.',
    '���������� ��१���㧨�� DOS � �⠫����� ��᪥�� � 㡥������ � ⮬, �� �����',
    '����⢨⥫쭮 ������� (� ������� AIDSTEST, PCTOOLS � �.�.).');
BEGIN
  {�।�०���� �� ���᭮��}
  for k := 1 to 9 do
    begin
      GotoXY((80-Length(t[k])) div 2,WhereY);
      WriteLn(t[k])
    end;
  Write(#7);  			{��㪮��� ᨣ���}
  if Okay(#13#10'��१���㧨�� DOS') then
    ReStartDOS;  		{��१���㦠�� ���}
  Write('����� (Y/N,Enter=N)? ');
  if UpCase(ReadKey)<>'Y' then
    Halt;
  {����訢��� �㡫�஢���� �� �� � ��⮢��
   䠩� � ����ﬨ ��ࠦ����� ᥪ�஢}
  S := '';
  if Okay('���࠭��� ����� �������� ���� ��᪥�') then
    repeat
      Write('��⠢�� ��᪥�� � ����⮩ ��१�� � ������ ��� ��: ');
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

  {����⠭�������� �������� ��}
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
  {��१���㦠�� ���}
  ReStartDOS
END;  {Alarm}
{------------------}
PROCEDURE CheckBoots;
  {�஢���� �������� ��. Head 㦥 ᮤ�ন�
   �஢�७�� ��������� ��娢���� 䠩��}
var
  c: CheckType;
  ch:^CheckType;
  Buf: LType;
  k: Word;
BEGIN {CheckBoots}
  {��⠭�������� � ����� $62 BIOS-����
   �室� � ��砫� ��ࠡ�⪨ ���뢠��� Int13,
   �⮡� �������� Stealth-������}
  GetIntVec($62,Old62); {���ᠥ� ����� $62}
  SetIntVec($62,Head.Int13);
  WriteLn;
  WriteLn('��� ����筮�� �����襭�� ࠡ��� '+
           '�ணࠬ�� ������ ESC');
  WriteLn;
  WriteLn('��⨢����� ����஫� ����⥫�� �������� ��:');
  WriteLn('�������','�����/樫����':20);
  {�஢��塞 ��뫪� � ����⥫� ��}
  with Head do
  for k := 1 to NDisk do with LDisk[k] do
    begin
      Write(BHD:4,BSC:17);
      RWSecInt13(2,BHd,BSC,Buf);
      Read(F,c);
      if Equal(c.Sec0,Buf,512) then
        WriteLn('��ଠ':20)
      else
        begin
          Writeln('�������!':20);
          Alarm  {�����㦥�� ���������}
        end
    end;
  {��ଠ�쭮� �����襭�� �஢�ન}
  SetIntVec($62,Old62);
  Int13Addr := NIL;
  BegDat := FilePos(F);
  {������塞 �������� ��娢�묨 䠩����}
  WriteLn;
  WriteLn('��⠥��� ��娢�� 䠩� ANTIVIR.DAT...');
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
  {����頥� � ��娢 �⠫�� 䠩�� FNAME}
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
   Msg('�訡�� ����㯠 � 䠩�� '+FName)
  else
    begin
      {�᪠�� � ��娢� ���������� 䠩�:}
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
      {�����⮢��� ��।��� ������:}
      New(ch);
      ch^.Name := FName;
      ch^.Siz0 := FileSize(FF);
      sz := 512;         		{����� ����� �⥭��}
      if ch^.Siz0<512 then
        sz := ch^.Siz0;  		{���� ����� 512 ����}
      FillChar(ch^.Sec0,512,0);
      BlockRead(FF,ch^.Sec0,sz,nz);
      Close(FF);
      if nz<>sz then
        Msg('�訡�� �⥭�� �� 䠩�� '+ch^.Name)
      else if not LowMemory then
        begin
          FColl^.Insert(ch);
          FChange := True
        end
      else
        k := MessageBox('���௠�� ����㯭�� ������',NIL,0)
    end
END;  {SetFile}
{------------------}
PROCEDURE BuildArch;
  {������� ��娢�� 䠩�}
var
  k,S13,O13,h,s: Word;
  c: CheckType;
  ch:^CheckType;
  DIn: TDisk;
BEGIN
  ReWrite(F);
  if IOResult <> 0 then
    begin
      WriteLn('���������� ������/ᮧ���� 䠩� ������');
      Halt
    end;
  {������� ��������� 䠩��}
  with Head do
    begin
      Hd := 'ANTIVIR';
      {������뢠�� �� BIOS}
      BIOS := 0;
      for k := 0 to $FFFF do
        BIOS := BIOS+Mem[$F000:k];
{��।��塞 �室 � Int13}
      asm
        mov ah,$13
        Int $2F
        push ds  		{�������}
        push dx  		{���饭��}
        Int $2F  		{����⠭�������� Int13}
        pop bx  		{���饭��}
        pop ax   		{�������}
        mov S13,ax
        mov O13,bx
      end;
      Int13 := Ptr(S13,O13);
      Move(Int13^,Beg13,SizeOf(Beg13));
      NDisk := 0;       		{������⢮ ��᪮�}
    end;  {with Head}
{������㥬 �������� ��}
  GetMasterBoot(c.Sec0);
  if not Disk_Error then
   with Head,c,Sec0.Boot do
    begin  {���� ��� �� ���� ��}
      h := 0;
      s := 1;
      Seek(F,1);
      GetDiskInfo(2,DIn);
      SecTr := DIn.TrackSiz;
      Heads := DIn.Heads;
{���� �� �ᥬ ��: h,s - ���� ��뫪�}
      repeat
        {���������� ���� ��뫪� � ���������}
        inc(NDisk);
        with LDisk[NDisk] do
          begin
            BHd := h;
            BSC := s;
            Space := 1
          end;
{��⠥� ��뫪� �� ��।��� ��}
        GetAbsSector($80,h,s,c.Sec0.Boot);
        {���࠭塞 �� � ��娢�}
        Name := '';
        Siz0 := 0;
        Write(F,c);
{�饬 �����⮩ ����⥫� ��}
        k := 1;
        while (Part[k].BegSC=0) and (k<4) do
          inc(k);
        if Part[k].BegSC<>0 then with Part[k] do
          begin
            {���������� ���� ����⥫� � Head}
            inc(NDisk);
            with LDisk[NDisk] do
              begin
                BHd := BegHd;
                BSC := BegSC;
                Space := Size
              end;
{���������� ��뫪� �� ᫥���騩 ��}
            inc(k);
            h := Part[k].BegHd;
            s := Part[k].BegSC;
{���������� ����⥫� � ��娢�}
            Name := '';
            Siz0 := 0;
            with LDisk[Ndisk] do
             GetAbsSector($80,BegHd,BegSC,Sec0);
            Write(F,c);
          end {�᫨ �����⮩ ����⥫�}
      until S=0
    end;  {���� ��� �� ���� ��}
{�����뢠�� ��������� ��娢�}
  BegDat := FilePos(F);
  Seek(F,0);
  Write(F,Head.CT);
  Seek(F,BegDat);
{���頥� COMMAND.COM}
  SetFile(GetEnv('COMSPEC'));
END;  {BuildHead}
{------------------}
FUNCTION CheckHead: Boolean;
  {�஢���� ��������� ��娢���� 䠩��}
var
  s: String;
  k: Word;
  Sum: LongInt;
  DI: TDisk;
BEGIN
  {������뢠�� �� BIOS}
  Sum := 0;
  for k := 0 to $FFFF do
    Sum := Sum+Mem[$F000:k];
{����砥� �������⨢�� ��ࠬ���� ��}
  GetDiskInfo(2,DI);
{��⠥� ��������� ��娢�}
  Read(F,Head.CT);
  {�஢��塞 ���}
  s := 'ANTIVIR';
  with Head do
    if (Hd<>s) or (Sum<>BIOS) or
      not Equal(Beg13,Int13^,SizeOf(Beg13)) or
      (SecTr<>DI.TrackSiz) or (Heads<>DI.Heads)
      then begin
        WriteLn('��娢�� 䠩� ᮤ�ন� �訡��� �����!');
        if not Okay('������� ���� ��娢') then
          Halt
        else
          CheckHead := False
      end
    else
      CheckHead := True
END;  {CheckHead}
{------------------}
FUNCTION Auto: Boolean;
  {����஫���� ��ࠬ���� ���饭��, ���뢠�� ��� ᮧ����
	DAT-䠩�. �����頥� TRUE, �᫨ �����㦥� ���� /AUTO}

var
  s: String;
  k,j: Byte;
  AF: Boolean;  {���� ���� /AUTO}
  c: CheckType absolute Head;
  S13,O13: Word;
  DI: TDisk;
label
  SetF,ErrHd;
const
  tx='��娢�� 䠩� ᮤ�ন� �訡��� �����. '+
				'������� ���� 䠩�';
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
                      		{s = ������ ��� DAT-䠩��}
  {��⮢�� �������� ���� 䠩���}
  FColl := New(PCollection, Init(100,10));
  {��ନ�㥬 ᯨ᮪ ��᪮��� ����⥫��}
  GetListDisk(Disks);
  Assign(F,s);
{$I-}
  Reset(F);     		{�஢��塞 ����⢮����� ��娢�}
{$I+}
  if (IOResult<>0) or
      not CheckHead then
    BuildArch    	{�������, �᫨ ��� ��娢�}
  else           	{���� �������}
    CheckBoots;  	{�஢��塞 �������� ��}
  Auto := AF
END;  {Auto}
{------------------}
PROCEDURE Dialog;
  {�����⢫�� ������ � ���짮��⥫��.�����頥� STOP=TRUE, 
   �᫨ ���짮��⥫� �⪠����� �� ����஫�. �ᯮ����
   �।�⢠ ������⥪� Turbo Vision}

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
  {�����⢫�� ����஫� 䠩��� �� �⠫����,
   �࠭�騬�� � ������樨 FColl}
var
  FF: File;
Function Cure(Sec0,Sec: LType): Byte;
  {�஢���� ⨯ 䠩�� � �ᯮ�������
   � ��� ����� � �����頥�:
   0 - ����� � ��砫� EXE-䠩�� (�� 㤠�����)
   1 - ����� � ���� EXE ��� COM-䠩��
   2 - ����� � ��砫� COM-䠩��
   3 - ���짮��⥫� �� ࠧ�訫 㤠���� �����}
var
  C: Byte;
  Eq: Boolean;
begin
  with Sec0 do
    if W[1]=$5A4D then 	{�᫨ EXE-䠩�,�஢��塞 ᥣ���� �窨 ����᪠}
      if W[12]>=Sec.W[12] then
        C := 0  		{� ��砫� ��� �।��� 䠩��}
      else
        C := 1  		{� ���� 䠩��}
    else
   {�᫨ COM-䠩�,�஢��塞 ����� �������� ᥪ��:}
      begin
        if Equal(W[128],Sec.W[128],256) then
          C := 1 	{��� ��������� - ����� � ����}
        else
          C := 2 	{����� ������� - � ��砫�}
      end;
  if C=0 then
    WriteLn('����� ����� 㤠����, �.�.',
           		' �� �ᯮ����� � ��砫� EXE-䠩��!')
  else
    if not Okay('������� �����')
      then C := 3;
  Cure := C
end;  {Cure}
{--------}
Procedure ReWriteFile(Siz0: LongInt);
  {��१����뢠�� ����ࠦ����� ���� COM-䠩��
   �� ���� ����� ���ᨬ��쭮 �������묨 �������}
var
  Sour,Dest,FSize: LongInt;
  Size: Word;
  P: Pointer;
begin
  Reset(FF,1);
  Seek(FF,0);
  FSize := FileSize(FF);
  Sour := FSize-Siz0; 	{����� �����}
  Dest := 0;             {��砫� 䠩��}
  repeat    		{��९���� ����ࠦ����� ����
              		� ��砫� 䠩�� (�� ���� �����)}
    Size := 65520;
    if FSize < Size then
      Size := FSize;
    if Size > MaxAvail then
      Size := MaxAvail;
    GetMem(P,Size);
    Seek(FF,Sour);         	{�ய�᪠�� �����}
    BlockRead(FF,P^,Size); 	{��⠥� ��⠫쭮�}
    Seek(FF,Dest);
    BlockWrite(FF,P^,Size);
    Sour := Sour+Size;
    Dest := Dest+Size;
    FSize := FSize-Size;
    FreeMem(P,Size)
  until FSize=0;
  Truncate(FF);        		{��ᥪ��� ����� ����}
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
  tx1 = '��⨢����� ����஫� 䠩��� (ESC - �⮯):';
  tx2 = '����� �� �����㦥�.';
  tx3 = '�஢���� �����饭�� 䠩��!';
  tx4 = '����� ����� ���� १������,'+
        ' ४������� ��१���㧨�� ��⥬�!';
  tx5 = '��१���㧨�� ���';
BEGIN {Check}
  if FColl^.Count=0 then
    Exit;      			{��� 䠩��� � ������樨}
  Int13Addr := Head.Int13;
  SetIntVec($62,Head.Int13);
  WriteLn(' ':(80-Length(tx1)) div 2,tx1);
  Files := 0;  			{���稪 �஢�७��� 䠩���}
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
        WriteLn('   �訡�� ����㯠 � 䠩�� ',Name)
      else
        begin
          {����頥� � ����஫� ��।���� 䠩��}
          GotoXY(1,WhereY);
          Write(' ':79);     		{��ࠥ� ��ப�}
          GotoXY(10,WhereY);
          Write(Name,' ');   		{�뢮��� ��� 䠩��}
          inc(Files);        		{���稪 䠩���}
          {��⠥� ���� ᥪ�� 䠩��}
          sz := 512;
          if FileSize(FF)<512 then
            sz := FileSize(FF); 		{����� �⥭��}
          BlockRead(FF,Sec,sz,nz);
          if sz<>nz then
            begin
              WriteLn(
               '�訡�� �⥭�� �� 䠩�� ',Name);
              Close(FF);
              goto Next
            end;
          {����஫��㥬 䠩�:}
          if not Equal(Sec,Sec0,sz) then
            Goto VirDet;   		{������� - �����!}
          Close(FF);
          goto Next;       		{�᫨ ��� �⫨稩}
VirDet:   {�����㦥� �����:}
          WriteLn('��ࠦ��!'#7);
          IsVirus := True;
          {���訢��� ࠧ�襭�� �
           ��稬, �᫨ �� ��������}
          case Cure(Sec0,Sec) of
          0: goto Next; {����� � ��砫�EXE-䠩�� �� 㤠����}
          1:            {����� � ���� 䠩��}
            begin
              {����⠭�������� ���� ᥪ��}
SetBeg:       Seek(FF,0);
              BlockWrite(FF,Sec0,sz,nz);
              {����⠭�������� ��砫��� �����}
              if sz=nz then
                begin
                  Seek(FF,Siz0);
                  Truncate(FF); 	{��ᥪ��� �����}
                  Close(FF)
                end
              else
                begin
                  Close(FF);
                  WriteLn('�訡�� ����� � 䠩� ',ch^.Name)
                end
            end;
          2:        		{����� � ��砫� COM-䠩��}
            begin
              {��६�頥� �ணࠬ�� �����}
              ReWriteFile(ch^.Siz0);
              {� ����⠭�������� �� ��砫�}
              Goto SetBeg;
            end;
          3:begin 	{���짮��⥫� ����⨫ ��祭��}
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
  {����頥� �� �⮣�� �஢�ન}
  Write(#13'�஢�७� ',Files,' 䠩���. ');
  if not IsVirus then
    WriteLn(tx2)
  else
    begin
      WriteLn(tx3);
      WriteLn(tx4);
      if OKay(tx5) then
        begin         		{��१���᪠�� ���}
          Close(f);   		{���࠭塞 ��娢}
          ReStartDOS
        end
    end;
  WriteLn('(C) 1992 �. �.�.��஭��':80)
END;  {Check}
{
+----------------------------------------------+
|      ����, ����⠭�� � ����ணࠬ�� ���      |
|  ॠ����樨 ������� �।�⢠�� Turbo Vision  |
+----------------------------------------------+
}
const  {������� ��� �������}
  cmQui = 199;   {��室}
  cmSet = 200;   {�������� ����}
  cmDel = 201;   {������� �������騩}
  cmRun = 203;   {�믮����� �஢���}
  cmFresh=204;   {�������� ���ଠ��}
  cmAll = 205;   {����� ��}
  cmCD  = 206;   {������� ��⠫��}
  cmCDW = 207;   {������� ���� �롮� 䠩���}
  cmEXE = 208;   {������� COM �� EXE � �������}
type
  {�᭮���� ���������� ����}
  PDWT=^DWT;
  DWT = object(TDialog)
    Procedure HandleEvent(var Event: TEvent);Virtual;
    Procedure AddFiles;
    Procedure DelFiles;
    Procedure FreshFiles;
  end;

  {��஫��� ᯨ᪠ 䠩���}
  PFileListBox = ^TFileListBox;
  TFileListBox = object(TListBox)
    PFL: PStringCollection;  		{�������� ����}
    MarkL: Byte;             		{����� ��થ�}
    Procedure HandleEvent(var Event: TEvent);Virtual;
    Procedure GetDir(WC: String);
    Procedure MarkF(var s: String);
    Procedure DemarkF(var s: String);
    Procedure SetAll;
  end;

  {��ப� ����� �����/��᪨ 䠩��}
  PInpLine = ^TInpLine;
  TInpLine = object(TInputLine)
    Procedure HandleEvent(var Event: TEvent);Virtual;
  end;

  {���� ०��� ���������� 䠩���}
  PAddFileBox = ^TAddFileBox;
  TAddFileBox = object(TDialog)
    WildC: String;       			{��᪠}
    PL   : PFileListBox; 			{��஫��� ᯨ᪠}
    PInL : PInpLine;     			{��ப� ����� ��᪨}
    PDir : PStaticText;  			{��� ��⠫���}
    Procedure HandleEvent(var Event: TEvent);Virtual;
    Procedure SetFiles;
  end;

  {���� ०��� 㤠����� 䠩���}
  PDelFileBox =^TDelFileBox;
  TDelFileBox = object(TDialog)
    PL: PFileListBox;   {��஫��� ᯨ᪠}
    Procedure HandleEvent(var Event: TEvent);Virtual;
  end;

  {���� �ࠢ�筮� �㦡�}
  PMyHelpWindow =^TMyHelpWindow;
  TMyHelpWindow = object(THelpWindow)
    Procedure HandleEvent(var Event: TEvent);Virtual;
    Function GetPalette: PPalette; Virtual;
  end;
{+----------------------------------------------+
 |            ������� ��ப� ����� �          |
 |            �᭮���� ���������� ����          |
 +----------------------------------------------+}
PROCEDURE TVir.InitStatusLine;
  {��ନ��� ��ப� �����}
var
  R: TRect;
BEGIN
  GetExtent(R);
  R.A.Y := pred(R.B.Y); {R - ���न������ப� �����}
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0,$FFFF,
      NewStatusKey('~ESC~ ��室 � ��� = �⮯',kbF10,cmQuit,
      NewStatusKey('   ~F1~ ��ࠢ�筠� �㦡�', 					kbF1,cmHelp,NIL)),
    NIL)));
END; {TVir.InitStatusLine}
{------------------}
PROCEDURE TVir.Run;
  {������� � �ᯮ���� �᭮���� ���������� ����}
var
  DW: PDWT;
  R : TRect;
  Cntrl: Word;
const
  c1 = '�ணࠬ�� ����� �ᯮ��塞�� 䠩���';
  c2 = '(C) 1992, �.�.��஭��';
  cn = -5;   {����� �࠭�� �鸞 ������}
BEGIN
  Stop := True;
  {������� ���� � ������騬� ������ﬨ}
  R.Assign(5,5,75,14);
  DW := New(PDwt,
    Init(R,''));
  R.Assign(1,1,69,4);
  DW^.Insert(New(PStaticText,Init(R,#13#3+c1+#13+#3+c2)));
  {��⠢�塞 ������}
  R.Assign(cn+7,6,cn+18,8);
  DW^.Insert(New(PButton,Init
          (R,' ~S~ �⮯ ',cmCancel,bfNormal)));
  R.Assign(cn+18,6,cn+31,8);
  DW^.Insert(New(PButton,Init
          (R,'~A~ ��������',cmSet,bfDefault)));
  R.Assign(cn+31,6,cn+44,8);
  DW^.Insert(New(PButton,Init
          (R,'~D~ ������� ',cmDel,bfNormal)));
  R.Assign(cn+44,6,cn+58,8);
  DW^.Insert(New(PButton,Init
          (R,'~F~ ��������',cmFresh,bfNormal)));
  R.Assign(cn+58,6,cn+72,8);
  DW^.Insert(New(PButton,Init
          (R,'~R~ ����஫�',cmRun,bfNormal)));
  DW^.HelpCtx := 1;
  Cntrl := Desktop^.ExecView(DW);
END;  {TVir.Run}
{------------------}
FUNCTION TMyHelpWindow.GetPalette;
  {��⮢�� �㦭�� ������� ��� �ࠢ��}
const
  P = #16#17#18#19#20#47#21#13;
  C: String[8] = P;
BEGIN
  GetPalette := @C
END;
{------------------}
PROCEDURE TMyHelpWindow.HandleEvent;
  {��ࠡ��뢠�� ������� F5 ��� �뤠�
   ������� cmZoom (�ᯠ���� ����)}
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
  {�����⢫�� ����� � ���⥪�⭮-����ᨬ��   �ࠢ�筮� �㦡�}
var
  C: Word;
  HF: PHelpFile;
  HS: PDosStream;
  HW: PMyHelpWindow;
BEGIN
  {���뢠�� DOS-��⮪:}
  HS := New(PDosStream,Init(HelpFile, stOpenRead));
  {������� � ���樨�㥬��������� ��ꥪ� THelpFile:}
  HF := New(PHelpFile, Init(HS));
  if HS^.Status=stOk then
    begin
  {C������ ���� �ࠢ�筮� �㦡� � ��뢠��
   ��� � ��⮪�� HS � ⥪�騬 ���⥪�⮬: }
      HW := New(PMyHelpWindow,Init(HF, GetHelpCtx));
      if ValidView(HW) <> NIL then
        begin
          C := ExecView(HW); {�뤠�� �ࠢ��}
          Dispose(HW)        {����塞 ����}
        end
    end
  else
    begin
      Dispose(HF, Done);
      if MessageBox('��� ����㯠 � 䠩�� '+
        HelpFile,NIL,mfError+mfOKButton)=0 then;
    end
END;  {DoHelp}
{------------------}
PROCEDURE DWT.HandleEvent(var Event: TEvent);
  {��ࠡ��稪 ᮡ�⨩ �᭮����� ����. �������⭥�⠭����� 


   �������, � ⠪�� ��ࠡ��뢠�⪫���� Left � Right    ��� ᬥ�� 
��⨢���⨪�����}
BEGIN {DWT.HandleEvent}
  TDialog.HandleEvent(Event);
  case Event.What of
  evCommand:  {��ࠡ�⪠ ���⠭������ ������}
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
  evKeyboard: {������ Left-Right}
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
|  ��ࠡ�⪠ ������� "�������� 䠩�"  |
+-------------------------------------+
}
PROCEDURE DWT.AddFiles;
  {���ᯥ稢��� �롮� 䠩��� �� ᯨ᪠ �
   ����頥� ��࠭�� 䠩�� � ��娢}
var
  R,RR : TRect;        {���न����}
  Path0: String;       {��砫�� ��⠫��}
  PW   : PAddFileBox;  {���� �롮� 䠩���}
  ASB  : PScrollBar;   {����� �஫���}
  P    : PView;        {�ᯮ����⥫�� ��������}
const
  c1 = '�ᯮ���� ������ �����';
  c11= ' � Insert ��� �롮� 䠩��';
  c2 = 'ESC - �⪠������ � ���';
  WildCard: String = '*.*';
BEGIN
  GetDir(0,Path0); {Path0- ��⠫�� �� 㬮�砭��}
  {������� ���������� ���� �롮� 䠩���}
  R.Assign(0,0,80,23);
  PW := New(PAddFileBox, Init(R, ''));
  PW^.WildC := WildCard;
  {��⠢�塞 ������騩 ⥪��}
  R.Assign(1,1,79,4);
  PW^.Insert(New(PStaticText,Init(R,#3+c1+c11+#13#3+c2)));
  R.Assign(1,4,79,5);
  PW^.PDir := New(PStaticText,Init(R,#3+'��⠫��  '+path0));
  PW^.Insert(PW^.PDir);
  {��⠢�塞 ��ப� �롮� �����/��᪨}
  R.Assign(25,7,52,8);
  PW^.PInL := New(PInpLine, Init(R,40));
  with PW^.PInL^ do
    State := State or sfCursorVis;
  PW^.PInL^.Data^ := WildCard;
  PW^.Insert(PW^.PInL);
  R.Assign(25,6,52,7);
  P := New(PLabel,Init(R,'~M~ ��᪠ 䠩���:',PW^.PInL));
  PW^.Insert(P);
  R.Assign(52,7,54,8);
  P := New(PHistory, Init(R,PW^.PInL,1));
  PW^.Insert(P);
  {��⠢�塞 �஫��� ᯨ᪠ 䠩���}
  R.Assign(2,10,77,19);
  RR.Assign(77,10,78,19);
  ASB := New(PScrollBar,Init(RR));
  PW^.Insert(ASB);
  New(PW^.PL,Init(R,4,ASB));
  PW^.PL^.GetDir(WildCard);
  PW^.Insert(PW^.PL);
  PW^.PL^.MarkL := 15;
  R.Assign(2,9,77,10);
  P := New(PLabel,Init(R,'~L~ ���᮪ 䠩���:',PW^.PL));
  PW^.Insert(P);
  {��⠢�塞 ������}
  R.Assign(1,20,11,22);
  PW^.Insert(New(PButton, 	Init(R,'~S~ �⮯',cmCancel,bfNormal)));
  R.Assign(11,20,28,22);
  PW^.Insert(New(PButton,
    	Init(R,'~A~ ����� ��',cmAll,bfNormal)));
  R.Assign(28,20,49,22);
  PW^.Insert(New(PButton, 	Init(R,'~D~ ������� ��⠫��',cmCD,bfNormal)));
  R.Assign(49,20,63,22);
  PW^.Insert(New(PButton,
    	Init(R,'~R~ ��������',cmRun,bfNormal)));
  R.Assign(64,20,77,22);
  PW^.Insert(New(PButton,
    	Init(R,'~E~ EXE/COM',cmEXE,bfNormal)));
  PW^.HelpCtx := 2;
  {�믮��塞 ������}
  DeskTop^.ExecView(PW);
  Dispose(PW,Done);
  ChDir(path0) {����⠭�������� ⥪�騩 ��⠫��}
END   {AddFiles};
{------------------}
PROCEDURE TAddFileBox.HandleEvent;
  {��ࠡ��稪 ᮡ�⨩ ���� �롮� 䠩���}
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
    cmCDW:begin  {�������� ��᪠ �롮� 䠩���}
L1:
            S := PInL^.Data^; {����� ��᪠}
            PL^.List := NIL;
            {����塞 ��������}
            Dispose(PL^.PFL, Done);
            WildC := S;
            {������� ����� ��������}
            PL^.GetDir(S)
          end;
    cmCD: begin  {������� ��⠫��}
            {�롨ࠥ� ���� ���/��⠫��:}
            New(PCD, Init(0,0));
            c := DeskTop^.ExecView(PCD);
            GetDir(0,s);
         {s - ��� ������ ��⠫���.����塞 ��஥ ��� �� ����}
            Dispose(PDir,Done);
            R.Assign(1,4,79,5);
            {������� ����� ���}
            PDir := New(PStaticText,Init(R,#3+'��⠫��  '+s));
            Insert(PDir);
            Goto L1;
          end;
    cmAll: begin     {����� �� 䠩��}
All:         PL^.SetAll;
             PL^.Draw
           end;
    cmRun: SetFiles; {�������� 䠩�� � ��娢}
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
  {����頥� � ��娢 ��࠭�� 䠩��}
var
  S,ss: String;
  k: Integer;
  R: TRect;
  p: PWindow;
  PS: PString;
BEGIN
  {����頥� � ���������� 䠩���:}
  R.Assign(15,10,65,13);
  P := New(PWindow,Init(R,'���������� 䠩�:',0));
  DeskTop^.Insert(P);
  {�롨ࠥ� �� ������樨 ��祭� 䠩��:}
  with PL^,PFL^ do
  for k := 0 to pred(count) do
    begin
      s := GetText(k,255);
      if s[Length(s)] = #251 then
        begin    {��࠭ ��।��� ��祭� 䠩�}
          DemarkF(s);            {����塞 ����}
          System.GetDir(0,ss);
          if ss[Length(ss)] <> '\' then
            ss := ss+'\';
          ss := ss+s; {������塞 ������� ���᪠}
          {������� ���}
          R.Assign(1,1,48,2);
          P^.Insert(New(PStaticText,Init(R,#3+ss)));
          SetFile(ss);  {����頥� 䠩� � ��娢}
          PS := At(k);
          PS^ := s
        end
    end;
  Dispose(P,Done);
  PL^.Draw
END;  {TAddFileBox.SetFiles}
{------------------}
PROCEDURE TInpLine.HandleEvent;
  {��ࠡ��稪 ᮡ�⨩ ��ப� ����� ����� ���
   ��᪨ �롮� 䠩���: �뤠�� ������� cmCDW,
   �᫨ ������� ����� �����}
BEGIN
  TInputLine.HandleEvent(Event);
  if (Event.What = evKeyDown) and
     (Event.KeyCode = kbEnter) then
    Message(Owner,evBroadcast,cmCDW,@Self)
END;  {TInpLine.HandleEvent}
{-------------------}
PROCEDURE TFileListBox.SetAll;
  {�������� �ਧ����� �롮� ����� ��� 䠩���}
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
  {��ନ��� �������� �� ���� 䠩���⥪�饣� ��⠫���}
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
  {��ࠡ��稪 ᮡ�⨩ ���� �롮� 䠩���:
   �ᯮ���� ������� Insert ��� ����⪨ 䠩��}
var
  S: String;
BEGIN
  TListBox.HandleEvent(Event);
  if (Event.What = evKeyDown) then
  case Event.KeyCode of
    kbIns: begin  {����� ������ Insert}
      S := GetText(Focused,255);{����砥� �롮�}
      PFL^.AtFree(Focused);     	{����塞 䠩��� ������樨}
      if S[Length(s)] =#251 then
        DemarkF(s)             	{���ࠥ� ������}
      else
        MarkF(s);            	{������塞 ������}
      PFL^.Insert(NewStr(S)); 	{��⠢�塞 � ����}
      Event.KeyCode := kbDown;	{�����㥬 ᤢ��}
      Draw;                   	{㪠��⥫� ����}
      TListBox.HandleEvent(Event);
    end;
    kbGrayPlus: 			{���� "+" ��� "����� ��"}
      Message(@Self,evCommand,cmAll,@Self)
  end
END;  {TFileListBox.HandleEnent}
{------------------}
PROCEDURE TFileListBox.MarkF(var s: String);
  {����頥� � ��ப� S ��થ� �롮�}
BEGIN
  while Length(s)<MarkL do
    s := s+' ';
  s := s+#251
END;
{-----------------}
PROCEDURE TFileListBox.DemarkF(var s: String);
  {������ ��થ� �롮� �� ��ப� S}
BEGIN
  while (s[Length(s)]=#251) or (s[Length(s)]=' ') do
    System.Delete(s,Length(s),1)
END;
{
+------------------------------------+
|  ��ࠡ�⪠ ������� "������� 䠩�"  |
+------------------------------------+
}
PROCEDURE DelFile(ss: String);
  {������ 䠩� � ������ SS �� ��娢�}
var
  n : Integer;
  ch: ^CheckType;
BEGIN
  {�饬 �㦭� 䠩� � ��娢�:}
  n := 0;
  repeat
    ch := FColl^.At(n);
    inc(n)
  until (ch^.Name=ss);
  dec(n);
  {����塞 ������}
  FColl^.AtDelete(n);
  FChange := True
END;  {DelFile}
{------------------}
PROCEDURE DWT.DelFiles;
  {������ 䠩�� �� ��娢�}
var
  R: TRect;
  PD: PDelFileBox;
  ASB: PScrollBar;
  k: Integer;
  ch: ^CheckType;
const
  c1 = '�ᯮ���� ������ �����';
  c11= ' � Insert ��� �롮� 䠩��';
  c2 = 'ESC - �⪠������ � ���';
BEGIN
  {��ନ�㥬 ����}
  R.Assign(0,0,80,23);
  PD := New(PDelFileBox, Init(R,''));
  {��⠢�塞 �஫��� ��娢��� 䠩���}
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
  PD^.Insert(New(PLabel, 	Init(R,'~L~ ���᮪ ��娢��� 䠩���:',PD^.PL)));
  {��⠢�塞 ������}
  R.Assign(1,20,15,22);
  PD^.Insert(New(PButton,
      	Init(R,'~S~ �⮯',cmCancel,bfNormal)));
  R.Assign(16,20,35,22);
  PD^.Insert(New(PButton,
      	Init(R,'~A~ ����� ��',cmAll,bfNormal)));
  R.Assign(36,20,50,22);
  PD^.Insert(New(PButton,
      	Init(R,'~R~ �������',cmRun,bfNormal)));
  {������� �������� ���� 䠩��� }
  PD^.PL^.PFL := New(PStringCollection,Init(10,5));
  for k := 0 to pred(FColl^.Count) do
  with PD^.PL^.PFL^ do
    begin
      ch := FColl^.At(k);
      Insert(NewStr(ch^.Name))
    end;
  PD^.PL^.NewList(PD^.PL^.PFL);
  PD^.HelpCtx := 3;
  {�믮��塞}
  DeskTop^.ExecView(PD);
  Dispose(PD,Done)
END;  {DelFiles}
{----------------------}
PROCEDURE TDelFileBox.HandleEvent;
  {��ࠡ��稪 ᮡ�⨩ ���� 㤠����� 䠩��(��)}
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
      P := New(PWindow,Init(R,'�������� 䠩�:',0));
      DeskTop^.Insert(P);
      with PL^,PFL^ do
      for k := 0 to pred(count) do
        begin
          s := GetText(k,255);
          if s[Length(s)] = #251 then
            begin 		{���쪮 ��� ����祭��� 䠩���}
            {����塞 ࠤ���� � �஡��� � �����}
              while (s[Length(s)]=#251) or
                    (s[Length(s)]=' ') do
                System.Delete(s,Length(s),1);
              {����頥� ��� 㤠�塞��� 䠩��}
              R.Assign(1,1,48,2);
              P^.Insert(New(PStaticText,Init(R,#3+s)));
              DelFile(s)  	{����塞 �� ��娢�}
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
| ��ࠡ�⪠ ������� "�������� ���ଠ��" |
+-----------------------------------------+
}
PROCEDURE DWT.FreshFiles;
  {�������� ���ଠ�� � ��娢�}
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
  P := New(PWindow,Init(R,'�����⠭���������� 䠩�:',0));
  DeskTop^.Insert(P);
  k := 0;
  while k<FColl^.Count do
    begin
      ch := FColl^.At(k);
      with ch^ do
        begin
          R.Assign(1,1,48,2);
          {�뢮��� ��� 䠩��}
          P^.Insert(New(PStaticText,Init(R,#3+Name)));
          Assign(FF,Name);
          {$I-}
          Reset(FF,1);
          {$I+}
          if IOResult <> 0 then
       {�訡�� ����㯠 - 㤠�塞 䠩� �� ��娢�}
            begin
NotAcc:       if MessageBox(
              '��� ����㯠 � 䠩�� '+Name+#13+
              '����� ����஫� �� 䠩���?',NIL,
              mfYesButton+mfNoButton)=cmYes then
                begin
                  FColl^.AtDelete(k);
                  FChange := True
                end
            end
          else  {��ଠ�쭮� ����⨥ 䠩��}
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
              else {���� �� �⠥���}
                MessageBox('�訡�� ����㯠 '+
                        '� 䠩�� '+Name,NIL,0);
              System.Close(FF)
            end
        end; {with ch^}
      inc(k)
    end;  {while k<FColl^.Count}
  Dispose(P,Done)
END;  {FreshFiles}
{
+-----------------------------+
|  �᭮���� �ணࠬ�� AntiVir |
+-----------------------------+
}
var
  k: Word;
  ch:^CheckType;
BEGIN {AntiVir}
  {�஢��塞 ��ࠬ���� ���饭��}
  if not Auto then
    Dialog          	{������ � ���짮��⥫��}
  else
    Stop := False;  	{�� �뫮 �������}
  if not Stop then
    Check;          	{����஫��㥬 䠩��}
  {�᫨ �������� �����﫠��, ��९��뢠�� ��� ��娢�� 䠩�}
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
  Close(F)          {����뢠�� DAT-䠩�}
END.  {AntiVir} 


