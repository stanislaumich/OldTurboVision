{+---------------------------------------+
 |  �ਬ�� �ᯮ�짮����� ����� F_GrText |
 +---------------------------------------+}
Uses CRT,Graph,F_GrText;
const
  DX = 50;       		{��ਭ� ⥪�⮢��� ����}
  DY = 11;       		{���� ⥪�⮢��� ����}
  t1: String='����� � ��� ��⥬� �ணࠬ��஢����';
  t2: String='��࡮ ��᪠�� ';
  Grad = Pi/180; 		{��ॢ�� �ࠤ��/ࠤ���}
var
  D,R,E: Integer;
  Angle: Integer;  		{���� ������ �㪢}
  x1,y1,x2,y2: Integer; 	{���न���� ����}
  F: File;       		{���� � ���⮬}
  FT: Text;      		{���� � ⥪�⮬ �ணࠬ��}
  N: Integer;
  P: Pointer;    		{�����⥫� �� ����}
  S: String;
  k,H: Byte;
  C: Char;
begin
{���樨�㥬 ��䨪�}
  D := Detect;
  InitGraph(D,R,'');
  E := GraphResult;
  if E<>grOk then
    begin
      WriteLn(GraphErrorMsg(E));
      Halt
    end;
{�뢮��� ⥪�� ��楤�ன OutString}
  if RegisterChrFile('trip.chr')>0 then
    begin
      y1 := succ(GetMaxY) div 20;
      x1 := 12*y1;
      x2 := Length(t1);
      y2 := GetMaxY-2*y1;
      while x1<y2 do
      begin
        MoveTo(0,x1);
        for k := 1 to x2 do
          begin
            Angle := Round(30*sin(grad*(k*360/x2)));
            OutString(t1[k],1,Angle,0.9,1);
          end;
        inc(x1,y1)
      end;
      MoveTo(2*GetMaxX div 7,GetMaxY-3*y1);
      for k := 1 to Length(t2) do
        OutString(t2[k],1,0,1,1)
    end;
{�롨ࠥ� �㦭� ����}
  case D of
    CGA: H := 8;
    EGA: H := 14;
    VGA: H := 16;
    else
         H := 8;
  end;
{��⮢�� ��� 䠩��, ᮤ�ঠ饣� ����}
  Str(H,S);
  S := '8x'+S+'.fnt'; 			{��� 䠩��}
{���뢠�� 䠩� � ���⮬}
  Assign(F,S);
  Reset(F,1);
{����ࢨ�㥬 ������ � ��㧨� ����}
  GetMem(P,FileSize(F));
  BlockRead(F,P^,FileSize(F));
  Close(F);
{��������㥬 ���� � ���墠�뢠�� ����-�뢮�}
  SetFont(p,8,H);
  GraphWriteOn;
(*{������� ⥪�⮢�� ����}
  TextColor(Yellow);
  TextBackGround(Blue);
  SetWindow ((GetMaxChar-DX) div 2,2,(GetMaxChar+DX) div 2,
    (GetMaxLine+DY) div 3,DoubleBorder,
    ' ������ ���� ������� ',True,False,False);
{���뢠�� 䠩� � ⥪�⮬ �ணࠬ��}
  S := copy(ParamStr(0),1,pos('.',ParamStr(0)))+'pas';
  Assign(FT,S);
  Reset(FT);
{��⠥� 䠩� � �뢮��� ��� � ����}
  for N := 1 to DY do
    begin
      ReadLn(FT,S);
      WriteLn(S)
    end;
  Close(FT);
{���� ����⢨� ���짮��⥫�}
  while not KeyPressed do;
  while KeyPressed do
    C := ReadKey;
{��頥� ⥪�⮢�� ���� � ������ ��ப�}
  ClrScr;
  WriteLn('������ �ந������ ⥪��');
  ReadLn(S);
{�������� ���� � ��� ���� � ����}
  Scrolling(-DY div 2);
  *)
  WriteLn('����� ᬥ饭 �� ',-DY div 2,' ��ப');
  WriteLn('������ ���� �������...');
  C := ReadKey;
{�����蠥� ࠡ��� �ணࠬ��}
  GraphWriteOff;
  CloseGraph
end.


