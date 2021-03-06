{
+----------------------------------------------+
| ��ଠ�஢���� ��஦�� ���⠭����묨 ᥪ�- |
| ࠬ� � ������� ���뢠���  $13. �ᯮ������ |
| ��᪮��� 5 1/4 ��� � ०��� 360 �����.    |
|   �� �ணࠬ�� ��⮢�� ��᪥�� ��� ࠡ���   |
|             � ���㫥� F_Prot.                |
+----------------------------------------------+}
Program Diskett;
Uses DOS,F_disk;
const
  TRK = 40; 		        {����� ���⠭���⭮� ��஦��}
  DSK = 0;  		        {����� ��᪠}
  SIZ = 1;  		        {��� ࠧ��� ᥪ��}
type
  PDBT_Type =^DBT_Type;  	{�����⥫� �� ���}
  {������ ��ࠬ��஢ ��᪥��}
  DBT_Type = record
    Reserv1 : array [0..2] of Byte;
    SizeCode: Byte; 	        {��� ࠧ��� ᥪ��}
    LastSect: Byte; 	        {������⢮ ᥪ�஢ �� ��஦��}
    Reserv2 : array [5..7] of Byte;
    FillChar: Char; 	{������-�������⥫� �ଠ�஢����}
    Reserv3 : Word
  end;
  {������� ���� �ଠ�஢����}
  F_Buf = record
    Track: Byte;     	{����� ��஦��}
    Head : Byte;     	{����� �������}
    Sect : Byte;     	{����� ᥪ��}
    Size : Byte      	{��� ࠧ���}
  end;
var
  Old: PDBT_Type;    	{�����⥫� �� ��室��� ���}
{-------------------}
PROCEDURE Intr13(var R: registers; S: String);
 {���頥��� � ���뢠��� 13 � ���������� �訡��
 (CF=1 - �ਧ��� �訡��). �᫨ �訡�� �����㦥��,
  ���⠥� ��ப� S � �����蠥� ࠡ��� �ணࠬ��}
BEGIN
  Intr($13,R);
  if R.Flags and FCarry<>0 then
  if R.ah <> 6 then        {������㥬 �訡�� �� ᬥ�� ⨯� ��᪥��}
    begin
      WriteLn(S);
      SetIntVec($1E,Old);  {����⠭�������� ����� ���}
      Halt
    end
END;  {Intr13}
{------------------}
FUNCTION AccessTime(DSK,TRK: Byte): Real;
  {������� �६� ����㯠 � ��஦�� � �����頥� ���
   	᢮�� १���⮬(� ᥪ㭤��)}

var
  E: array [1..9*512] of Byte;
  t,k: LongInt;
  R: registers;
BEGIN
   t := MemL[0:$046C];
   while t=MemL[0:$046C] do;
   for k := 1 to 10 do with R do
     begin
       ah := 2;
       al := 9;
       ch := TRK;
       cl := 1;
       dh := 0;
       dl := DSK;
       es := seg(E);
       bx := ofs(E);
       Intr13(R,'Error')
     end;
   AccessTime := (MemL[0:$046C]-t-1)*0.055
END;
{------------------}
var
  B: array [1..9] of F_Buf;   	        {���� ��� �ଠ�஢����}
  k,N: Integer;           		{���稪 横��}
  R: registers;          		{��������}
  DBT: PDBT_Type;        		{�����⥫� �� ����� ���}
  C,D: array [1..1024] of Byte; 	{����� �⥭��/�����}
  Size: Word;            		{����� ᥪ��}
  Info: TDisk;
BEGIN  {������� �ணࠬ��}
{�஢��塞 ����� � ���� � ����ࠨ���� �ࠩ���}
  GetDiskInfo(DSK,Info);
  if Disk_Error then
    begin
      WriteLn('�訡�� ����㯠 � ����');
      Halt
    end;
{����砥� ����� ᥪ�� � �����}
  case SIZ of
    0: Size := 128;
    1: Size := 256;
    2: Size := 512;
    3: Size := 1024
  else
    WriteLn('�������⨬� ��� ����� ᥪ��')
  end;

{���४��㥬 ⠡���� ��ࠬ��஢ ��᪥��. ��᪮��� ��室��� ��� ����� ����
� ���, ������ �� ����� � ��� � �����塞 �㦭� ��������}
  Old := ptr(MemW[0:$1E*4+2],MemW[0:$1E*4]);
  New(DBT);
  DBT^:= Old^;        	{����砥� ����� ��� � ���}
  SetIntVec($1E,DBT); 	{�����塞 ��뫪� �� ���}
  with DBT^ do
    begin
      SizeCode := SIZ;
      LastSect := 9;
      FillChar := '+'
    end;
  with R do
    begin
{����뢠�� ��᪮���}
      ax := 0;
      dl := DSK;
      Intr13(R,'�訡�� ����㯠 � ����');
{��⮢�� ���� �ଠ�஢���� � �����
 䠪�஬ �।������ ᥪ�஢}
      for k := 1 to 9 do 	{��� ������� �� 9 ᥪ�஢:}
      with B[k] do
        begin
          Track := TRK; 	{㪠�뢠�� ����� ��஦��}
          Head  := 0;           {����� �������}
          Sect  := 10-k;        {����� ᥪ��
                 	        (� ���⭮� ��᫥����⥫쭮��)}
          Size  := SIZ          {� ��� ࠧ���}
        end;
{��ଠ��㥬 ��஦��}
      ah :=$05;    	{��� ����樨 �ଠ�஢����}
      al :=9;      	{������� 9 ᥪ�஢}
      ch := TRK;   	{�� ��஦�� TRK}
      cl := 1;     	{��稭�� � ᥪ�� 1}
      dh := 0;     	{�� �����孮�� 0}
      dl := DSK;   	{��᪠ DSK}
      es := seg(B);	{ES:BX - ���� ����}
      bx := ofs(B);
      Intr13(R,'�訡�� �ଠ�஢����');
{������塞 ᥪ�� ��砩�묨 �᫠��}
      Randomize;
      for k := 2 to 255 do
	C[k] := Random(256);
{����訢��� ������⢮ ���⠫��権 �� ��}
      Write('���-�� ��⠭���� �� ��: ');
      ReadLn(C[200]);
      C[17] := 0;
{��⠥� ����஫��� �㬬�}
      N := 0;
      for k := 2 to 255 do
	N := N+C[k];
      C[256] := N mod 256;
{����㥬 ᥪ��}
      C[1] := Random(255)+1;
      for k := 2 to 256 do
	C[k] := C[k] xor C[1];
{�����뢠�� ᥪ��}
      ah := $03;    	{��� ����樨 �����}
      al := 1;      	{������� 1 ᥪ��}
      ch := TRK;    	{�� ��஦�� TRK}
      cl := 1;      	{��稭�� � ᥪ�� 1}
      dh := 0;      	{�� �����孮�� 0}
      dl := DSK;    	{��� DSK}
      es := seg(C); 	{���� ���� C ��� �����}
      bx := ofs(C);
      Intr13(R,'�訡�� �����');
{��⠥� ᥪ��}
     ah := $02;     	{��� ����樨 �⥭��}
     al := 1;
     ch := TRK;
     cl := 1;
     dh := 0;
     dl := DSK;
     es := seg(D);  	{���� ���� D ��� �⥭��}
     bx := ofs(D);
     Intr13(R,'�訡�� �⥭��')
    end;
{�஢��塞 ᮢ�������}
   for k := 1 to Size do
     if c[k]<>d[k] then
       begin
         WriteLn('��ᮢ������� ������');
         SetIntVec($1E,Old);
         Halt
       end;
   WriteLn('������� � �஢�७� ',TRK+1,
     		'-� ��஦�� � ᥪ�ࠬ� �� ',Size,' ����');
{�����塞 �६� ����㯠 � ����� ��஦��}
   Write('�६� ����㯠 � ���⮩ ��஦��: ');
   WriteLn(AccessTime(DSK,TRK):6:2,' c');
{�����塞 �६� ����㯠 � �⠭���⭮� ��஦��}
   DBT^.SizeCode := 2; {����뢠�� �⠭������ 					����� ᥪ�� � ���}
   Write('����� � ���筮� ��஦��: ');
   WriteLn(AccessTime(DSK,20):6:2,' c');
{����⠭�������� ����� ���}
   SetIntVec($1E,Old)
END.
