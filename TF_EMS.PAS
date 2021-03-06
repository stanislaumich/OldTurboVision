{
 +------------------------------------+
 | ���������� �᭮���� ���������⥩ |
 |            ����� F_EMS            |
 +------------------------------------+
}
Uses CRT,Graph,F_EMS,F_Text;
type
  TV = array [0..MaxInt div 2-1] of LongInt;
var
  All,Pages: Word;
  k,j,x: LongInt;
  Vec: TEMSVector;
  Tex: TEMSText;
  Scr: TEMSScreen;
  t: LongInt;
  d,r,e: Integer;
  PV: array [0..40] of ^TV;
  Sz: LongInt;
  Sum: Comp;
  f: file;
  ft: Text;
  s,ss: String;
  Err: Boolean;
  c: Char;
const
  LPage=16*1024;
label
  L1,L2;
Function HexW(X: Word): String;
  {�����頥� 16-�筮� ����ᠭ�� �}
const
  HS: array [0..15] of Char = '0123456789ABCDEF';
var
  S: String;
  k: Byte;
begin
  S := '';
  for k := 3 downto 0 do
    S := S+HS[(X shr (k*4)) and 15];
  HexW := S
end;  {HexW}
{-------------------}
Procedure GetTime;
  {����頥� � t ��⥬��� �६�,
   ��ࠢ������ �� �࠭��� 55-�� ���ࢠ��}
begin
  t := MemL[0:$46C];
  while t=MemL[0:$46C] do;
end;  {GetTime}
{-------------------}
begin   {�᭮���� �ணࠬ��}
  {�஢��塞 ����稥 EMM}
  If not IsEMS then
    begin
      WriteLn('��� EMS-����� ��� �� ��⠭����� EMM');
      Halt
    end;
  Colors(LightGray,Black);
  ClrScr;
{����頥� ����� ���ᨨ, ����� � ����㯭�� ������}
  WriteLn('�ᯮ������ EMM ���ᨨ ',GetEMMVersion);
  WriteLn('   ������� ���� �⮡ࠦ���� $',HexW(EMSSeg));
  GetEMSInfo(All,Pages);
  WriteLn('   �ᥣ� ��࠭��   : ',All,' (',
                  round(All*16.0*1024),' ����)');
  Sz := round(Pages*16.0*1024);
  WriteLn('   �������� ��࠭��: ',Pages,' (',Sz,' ����)');
{��।��塞 ������⢮ � 16-������� ��࠭�� � ���}
  x := MaxAvail div LPage;
  if x>Pages then x := Pages;  {�ࠢ������ � EMM}
{���।��塞 � ��� ���ᨢ� �� 4096 ������� 楫�� �ᥫ}
  dec(x);
  for k := 0 to x do
    if MaxAvail>=LPage then
      GetMem(PV[k],LPage);
  x := k;
  Sz :=succ(x)*LPage div 4;
  WriteLn('������� ���ᨢ �� ',Sz,' ������� 楫�� �ᥫ � ���...');
  GetTime;                  {��ᥪ��� �६�}
  for j := 0 to x do
    for k := 0 to LPage div 4-1 do
      begin
        PV[j]^[k] := j*(LPage div 4)+k;
        if PV[j]^[k] mod 1000=0 then
          begin
            Write(PV[j]^[k]:10);
            GotoXY(1,WhereY)
          end
      end;
  {������뢠�� ��� �㬬�}
  WriteLn('������뢠�� ��� �㬬�...');
  Sum := 0;
  for j := 0 to x  do
    for k := 0 to LPage div 4-1 do
      begin
        Sum := Sum+PV[j]^[k];
        if PV[j]^[k] mod 1000=0 then
          begin
            Write(PV[j]^[k]:10);
            GotoXY(1,WhereY)
          end
      end;
  WriteLn('�㬬� ������⮢ = ':30,Sum:11:0,',�६� ��� = ',
         (MemL[0:$46C]-t)*55/1000:5:2,' ᥪ㭤');
  {�᢮������� ����}
  for k := 0 to x do
    FreeMem(PV[k],LPage);
  {������� ���ᨢ � EMS}
  WriteLn('��� �� ���ᨢ � EMS-�����...');
  Vec.Init(4,0,Sz-1);  {4-����� �������;0..Sz-1 - �������}
  if not EMSErrorFlag then with Vec do
    begin             	{�᫨ ᮧ��� �ᯥ譮}
      GetTime;        	{��ᥪ��� �६�}
      for k := 0 to Sz-1 do
        begin
          SetItem(k,k); 	{����頥� ��।��� ��-�}
          if k mod 1000=0 then
            begin      	{����頥� � ������ 1000-�}
              Write(k:10);
              GotoXY(1,WhereY)
            end
        end;
    {����塞 �㬬� ������⮢}
    WriteLn('�㬬��㥬 ��������...');
      Sum := 0;
      for k := 0 to Sz-1 do
        begin
          Sum := Sum+LongIntItem(k);
          if k mod 1000=0 then
	    begin      	{����頥� � ������ 1000-�}
              Write(k:10);
              GotoXY(1,WhereY)
            end
        end
    end
  else
    Halt;
  WriteLn('�㬬� ������⮢ = ':30,Sum:11:0,', �६� ��� = ',
         (MemL[0:$46C]-t)*55/1000:5:2,' ᥪ㭤');
  WriteLn('���࠭塞 ���ᨢ � 䠩�� TESTEMS.$$$...');
  Assign(f,'testems.$$$');
  {$I-}
  ReWrite(f,1);
  {$I+}
  if IOResult<>0 then
    begin
      WriteLn('�訡�� �� ᮧ����� 䠩��!');
      Vec.Done;
      Goto L1
    end;
  Vec.Store(f);    	{���࠭塞 ���ᨢ}
  if EMSErrorFlag then
    begin          	{�뫠 �訡�� �� ��࠭����}
      Vec.Done;
      Goto L1
    end;
  Vec.Done;        	{�᢮������� EMS}
  {��⠥� ���ᨢ �� 䠩��}
  WriteLn('��⠥� ���ᨢ �� 䠩��...');
  Seek(f,0);      	{��砫� 䠩��}
  Vec.Load(f);    	{����㦠�� ���ᨢ}
  Close(f);
  if EMSErrorFlag then
    Goto L1;      	{�뫠 �訡��}
  WriteLn('�� ࠧ ������뢠�� ��� �㬬�...');
  Sum := 0;
  for k := 0 to Sz-1 do
    begin
      Sum := Vec.LongIntItem(k)+Sum;
      if k mod 500=0 then
      begin
        Write(k:10);
        GotoXY(1,WhereY)
      end
  end;
WriteLn('�㬬� = ':30,Sum:11:0);
  Vec.Done;
L1:
  {��।��塞 ����� 䠩�� � ⥪�⮬ �ணࠬ��}
  s := {copy(ParamStr(0),1,Pos('.',ParamStr(0)))+'pas';}
       'f_ems.int';
  Assign(f,s);
  Reset(f,1);
{��।��塞 ������⢮ SZ �ॡ㥬�� ��� ��࠭��}
  Sz := (FileSize(f)+LPage-1) div LPage;
  Close(f);
  Assign(ft,s);
  Reset(ft);
{������� ��ꥪ� TEMSText}
  WriteLn('������� ��ꥪ� TEMSText');
  Tex.Init(Sz*Lpage);
  if EMSErrorFlag then
    Halt;
{��⠥� 䠩� � �����뢠�� ��� � TEMSText}
  WriteLn('����頥� � ���� 䠩� '+S);
  while not (EOF(ft) or EMSErrorFlag) do
    begin
      ReadLn(ft,s);         	{��⠥� ��ப�}
      Tex.SetItem(s)        	{����頥� �� � EMS}
    end;
  if EMSErrorFlag then
    Goto L2;
  {�஢��塞 ����ᠭ���}
  Reset(ft);             		{��砫� 䠩��}
  Tex.Pos := 0;          		{��砫� ⥪�� � EMS}
  for k := 1 to 16 do
    WriteLn;             		{��⮢�� ���� ��� ����}
  Colors(Yellow,Blue);   		{���� �뢮��}
  SetWindow(1,10,80,23,1,' ��室�� 䠩�: '+
	#196#196#196#196#196#196#196#196#196#196#196#196#196+
	#196#196#196' ����� � EMS: ',True,False,False);
  while not EOF(ft) do
    begin
      ReadLn(ft,s);
      ss := Tex.GetItem;
      Err := s<>ss;
      if Length(s)>38 then
	s[0] := #38;
      While Length(s)<39 do
	s := s+' ';
      s := s+ss;
      if Length(s)>77 then
	s[0] := #77;
      WriteLn(s);
      if Err then
	begin
	  Write(#7);
	  c := ReadKey;
	  while c=#0 do c := ReadKey
	end
    end;
  Tex.Done;
  Colors(LightGray,Black);
  Window(1,1,80,25);
  GotoXY(1,25);
L2:
  {�஢�ઠ ��ꥪ� TEMSScreen}
  Write('���࠭塞 ����� ⥪�⮢��� ��࠭�. ');
  Scr.Init;
  if not EMSErrorFlag then
    Scr.PutScreen;    	{���࠭塞 ����� � EMS}
  if EMSErrorFlag then
    Halt;          	{�뫠 �訡��}
  x := WhereX;     	{���������� ��������� �����}
  WriteLn('������ ���� �������...');
  if ReadKey=#0 then k := ord(ReadKey);
  {������� ���� � 業�� ��࠭� � ������塞 ���
   ��砩�� 梥⮬}
  ClrScr;
  SetWindow(10,7,70,18,2,' ������ ���� �������...',
            				False,True,False);
  while not KeyPressed do
    begin
      GotoXY(Random(59)+2,Random(10)+2);
      TextBackground(Random(8));
      Write(' ')
    end;
  if ReadKey=#0 then k := ord(ReadKey);
  Scr.GetScreen;    	{����⠭�������� ��࠭}
  Window(1,1,80,25);
  TextBackground(Black);
  GotoXY(x,25);
  Scr.Done;
  {�஢��塞 ����᪨� ०��}
  WriteLn(#13#10'��� ���室� � ����᪨� '+
               '०�� ������ ���� �������...');
  if ReadKey=#0 then k := ord(ReadKey);
  d := detect;
  InitGraph(d,r,'');
  e := GraphResult;
  if e <> 0 then
    begin         		{�訡�� ���樠樨 ��䨪�}
      WriteLn(GraphErrorMsg(e));
      Halt
    end;
{���樨�㥬 Scr ������ - ���� ०�� ��࠭�!}
  Scr.Init;
  Line(0,0,GetMaxX,GetMaxY); 	{���������� �����}
  Line(0,GetMaxY,GetMaxX,0);
  Scr.PutScreen;      		{���࠭塞 ����ࠦ����}
  while not (KeyPressed or EMSErrorFlag) do
    begin
      ClearDevice;    		{��頥� ��࠭}
      Scr.GetScreen;  		{����⠭��������� ���ࠦ����}
    end;
  Scr.Done;
  CloseGraph;
end.


