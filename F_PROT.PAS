{===============} Unit F_Prot; {================}
{
+---------------------------------------------+
| ����� �ᯮ������  ��� ����� �ணࠬ� �� |
| �������쭮�� ����஢����. ������� ��ਠ�� |
| �ணࠬ�� ���頥��� � ������� ���祢�� ��- |
| ᪥��, ��樮���� ��ਠ�� - �� ���  ���- |
| �஫� ���� ᮧ����� ���.                    |
+---------------------------------------------+}
                     INTERFACE
Procedure ProtCheck(var P1,P2; var Res: Integer);
  {�஢���� �����쭮��� �����:
   �1 - ���� ��楤��� NORMA;
   P2 - ���� ��楤��� ALARM;
   Res - १���� ࠡ���:
     0: �� �맮� NORMA;
     1: �� �맮� ALARM;
     2: �� ��⠢���� ��᪥�.
     �� ��㣮� ���祭�� ����� ���� ⮫쪮
     �� ����஢�� �ணࠬ��}

Function SetOnHD: Integer;
  {��⠭�������� ����� �� ���⪨� ���.
   �����頥�:
    -1 - �� ��⠢���� ��᪥�;
    -2 - �� �����-��᪥�;
    -3 - ���� �� ����� ��� �訡�� �����;
    -4 - �ணࠬ�� �� ᪮��஢��� �� ��;
    -5 - �訡�� ����㯠 � ��;
    -6 - ���௠� ����� ��⠭����;
    -7 - �ணࠬ�� 㦥 ��⠭������;
    >=0 - ������⢮ ��⠢���� ��⠭����}

Function RemoveFromHD: Integer;
  {������ ����� � ���⪮�� ��᪠
   �����頥�:
    -1 - �� ��⠢���� ��᪥�;
    -2 - �� �����-��᪥�;
    -3 - ���� �� ����� ��� �訡�� ����� ��;
    -4 - �ணࠬ�� �� ᪮��஢��� �� ��;
    -5 - �訡�� ����㯠 � ��;
    >=0 - ������⢮ ��⠢���� ��⠭����}

                  IMPLEMENTATION
Uses DOS,F_Disk;
type
  TDate = array [1..4] of Word;
  TKey = record case Byte of
  0:(
    Hard: Word;        	{���� ��� ��஢�� ������}
    Dat : TDate);      	{��� ᮧ����� ���}
  1:(KeyW: array [1..5] of Word);
  end;
const
  TRK = 40;         	{����� ��஦��}
  HED = 0;          	{����� �������}
  SEC = 1;          	{����� ᥪ��}
  SIZ = 1;          	{��� ࠧ��� ᥪ�஢}
  ETracks = 40;     {�⠫����� ������⢮ ��஦�� �� ��᪥�}
  ETrackSiz = 9;    {�⠫����� ������⢮ ᥪ�஢ �� ��஦��}
  Key:TKey = (KeyW:(0,0,0,0,0)); {���� ��樮��୮� �ணࠬ��}
{------------------}
Procedure TrassBlock1;
  {����� ��� ����� � ����஢���
   � ������� ����䨪�樨 �������}
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
  {���졠 � ����஢��� � �������
   ����஫� �६���}
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
  P: Pointer;   {��뫪� �� �०��� ���}
  Buf: TBuf;    {���� �⥭��/����� ᥪ��}
  R: registers; {��������}
{------------------}
Function DiskettPrepare(var DSK: Byte): Boolean;
type
  DBT_Type = record                     {������� ⠡���� ��ࠬ��஢ ��᪥��}
    Reserv1 : array [0..2] of Byte;
    SizeCode: Byte;                     {��� ࠧ��� ᥪ��}
    LastSect: Byte;                     {������⢮ ᥪ�஢ �� ��஦��}
    Reserv2 : array [5..10] of Byte
  end;
var
  Info: TDisk;
  DBT,OldDBT:^DBT_Type;
begin
{�஢��塞 ����稥 ��᪥��}
  DSK := 0;     		        {��稭��� � ��᪠ A:}
  repeat
    TrassBlock1;
    GetDiskInfo(DSK,Info);
    if Disk_Error then
      if DSK=0 then
        DSK := 1  	                {�����塞 ��� ��᪠ �:}
      else
        DSK := 2  	                {�������� � �訡���}
  until not Disk_Error or (DSK=2);
  TrassBlock2;
  if Disk_Error then
    begin    		                {��� ����㯠 �� � �:, �� � �:}
      DiskettPrepare := False;
      Exit
    end;
{�஢��塞 ⨯ ��᪥��}
  TrassBlock1;
  with Info do
    begin
      if (Tracks<>ETracks) or
         (TrackSiz<>ETrackSiz) then
        begin  {�� �⠫���� ⨯}
          DiskettPrepare := False;
          DSK := 3;
          Exit
        end;
{�����⠭�������� ���}
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
  {�஢���� �����쭮��� �����쭮� �����}
var
  k,n: Word;
begin
{�����⠢������ ��᪥��}
  if DiskettPrepare(DSK) then
    begin
{��⠥� ���祢�� ᥪ��}
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
            begin {�஢��塞 ᮤ�ন��� ᥪ��}
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
  {�஢���� �����쭮��� ��樮��୮� �����}
var
  k: Word;
  Date :^TDate;
  Legal: Boolean;
label
  ExitL;
begin
{�����஢뢠�� ����}
  TrassBlock1;
  with Key do for k := 2 to 5 do
    KeyW[k] := KeyW[k] xor KeyW[1];
{�஢��塞 ���� ����⮢����� ���}
  TrassBlock2;
  k := 1;
  Date := ptr($F000,$FFF5);
  repeat
    Legal := Date^[k]=Key.Dat[k];
    inc(k)
  until not Legal or (k=5);
  LegalHD := Legal;
  TrassBlock1;
{�஢��塞 ��᪥��}
  if Legal then
    DSK := 0
  else
    Legal := LegalDiskett(DSK);
  LegalHD := Legal
end;  {LegalHD}
{-------------------}
Procedure ProtCheck(var P1,P2; var Res: Integer);
  {�஢���� �����쭮��� �����:
   P1 - ���� ��楤��� NORMA;
   �2 - ���� ��楤��� ALARM;
   Res - १���� ࠡ���:
     0: �� �맮� NORMA;
     1: �� �맮� ALARM;
     2: �� ��⠢���� ��᪥�.
     �� ��㣮� ���祭�� ����� ���� ⮫쪮
     �� ����஢�� �ணࠬ��}
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
  {������ ���� ���祢��� ᥪ��}
var
  k,n: Word;
begin
  TrassBlock1;
  Randomize;
  for k := 2 to 254 do
    Buf[k] := Random(256);
  Buf[1] := Random(255)+1;      {���� ��� ��஢��}
  {$R-}
  Buf[17] := Inst;              {���稪 ��⠭����}
  Buf[200] := Limit;            {����� ��⠭����}
  n := 0;                       {������ ��}
  for k := 2 to 255 do
    n := n+Buf[k];
  Buf[256] := n mod 256;        {����஫쭠� �㬬�}
{����㥬 �� �����}
  for k := 2 to 256 do
    Buf[k] := Buf[k] xor Buf[1];
  {$R+}
end;  {HidnSec}
{------------------}
Function SetOnHD: Integer;
  {��⠭�������� ��樮����� �����
  �� ���⪨� ���. �����頥�:
    -1 - �� ��⠢���� ��᪥�;
    -2 - �� �����-��᪥�;
    -3 - ���� �� ����� ��� �訡�� ����� ��;
    -4 - �ணࠬ�� �� ᪮��஢��� �� ��;
    -5 - �訡�� ����㯠 � ��;
    -6 - ���௠� ����� ��⠭����;
    -7 - �ணࠬ�� 㦥 ��⠭������.
    >=0 - ������⢮ ��⠢���� ��⠭����}
var
  DSK: Byte;                   {���}
  F: file;                     {���� � �ணࠬ���}
  Date:^TDate;                 {��� ���}
  NameF: String;               {��� 䠩�� � �ணࠬ���}
  W: array [1..5] of Word;     {��������� 䠩��}
  n: Word;                     {���稪}
  L: LongInt;                  {�������� ᬥ饭��}
  Inst: Byte;                  {������⢮ ��⠭����}
label
  ErrWrt;
begin
  TrassBlock1;
  if Key.Hard<>0 then
    begin
      SetOnHD :=-7;
      Exit
    end;
{�஢��塞 १����⭮��� �ணࠬ��}
  NameF := FExpand(ParamStr(0));
  if NameF[1] in ['A','B'] then
    begin
      SetOnHD := -4;
      Exit
    end;
{�஢��塞 ��᪥��}
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
    begin    {���௠� ����� ��⠭����}
      SetOnHD := -6;
      Exit
    end;
{���������� ���� ����⮢����� ���}
  TrassBlock1;
  Date := ptr($F000,$FFF5);
  Key.Dat := Date^;
{����㥬 ��ࠬ����}
  Randomize;
  with Key do
    while Hard=0 do Hard := Random($FFFF);
  for n := 2 to 5 do with Key do
    KeyW[n] := KeyW[n] xor Hard;
{���뢠�� 䠩� � �ணࠬ���}
  TrassBlock1;
  Assign(F,NameF);
  Reset(F,1);
{��⠥� ��������� 䠩��}
  BlockRead(F,W,SizeOf(W),n);
  if n<>SizeOf(W) then
    begin
      SetOnHD := -5;
      Exit
    end;
{�饬 � 䠩�� ��������� Hard}
  R.ah := $62;
  MSDOS(R);
  P := @Key;
  L := round((DSeg-R.bx-16+W[5])*16.0)+ofs(P^);
  Seek(F,L);
{�����뢠�� � 䠩�}
  TrassBlock1;
  BlockWrite(F,Key,SizeOf(Key),n);
  if n<>SizeOf(Key) then
    begin
      SetOnHD := -5;
      Close(F);
      Exit
    end;
{����㥬 ���祢�� ᥪ��}
  Inst := Buf[200]-Buf[17]-1;
  HidnSec(Buf,Buf[17]+1,Buf[200]);
{�����뢠�� �� ��᪥�� ���� ����}
  TrassBlock1;
  if not DiskettPrepare(DSK) then
    begin  {�訡�� ����㯠 � ��᪥�:㤠�塞 ��⠭����}
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
{��ଠ�쭮� �����襭��}
  SetOnHD := Inst;
  SetIntVec($1E,P);
  Close(F)
end;  {SetOnHD}
{------------------}
Function RemoveFromHD: Integer;
  {������ ��樮����� �����.
   �����頥�:
    -1 - �� ��⠢���� ��᪥�;
    -2 - �� �����-��᪥�;
    -3 - ���� �� ����� ��� �訡�� ����� ��;
    -4 - �ணࠬ�� �� ᪮��஢��� �� ��;
    -5 - �訡�� ����㯠 � ��;
    >=0 - ������⢮ ��⠢���� ��⠭����}
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
{��ࠥ� 䠩� � �ணࠬ��� �� ��}
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
{����⮦��� ��������� 䠩��}
  FillChar(B,512,0);
  BlockWrite(F,B,512,n);
  if n<>512 then
    begin
      RemoveFromHD := -5;
      Exit
    end;
  Close(F);
  Erase(F);  {����� 䠩�}
{����㥬 ���祢�� ᥪ��}
  Inst := Buf[200]-Buf[17]+1;
  HidnSec(Buf,Buf[17]-1,Buf[200]);
{�����뢠�� �� ��᪥�� ���� ����}
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
