{+----------------------------------------+
 | �ணࠬ��, ������������� ���������� |
 |            ����� F_Mouse.             |
 +----------------------------------------+}
Uses CRT,DOS,Graph,F_Mouse,F_GrText,F_Text;
const
  t1 = ' ���������� ���������⥩ ����� F_Mouse ';
  t2 = '  ����ﭨ� ���: ';
  t3: array [1..4] of String[22] =
       ('���न����: X=   Y=   ','����� ������  :',
        '�ࠢ�� ������ :','�।��� ������:');
  NItem = 3;
  t4: array [1..NItem] of String[24] =
       (' �������� 㪠��⥫� (F1)','   ������� ०�� (F2)',
        ' �������� ࠡ��� (Esc)');
type
  ItemT = array [1..NItem] of MouseItemType;
const
  Items: ItemT =(
 (X1: 9; Y1: 4; X2:35; Y2: 6; Butt: LeftButton; Key:59 shl 8),
 (X1:44; Y1: 4; X2:68; Y2: 6; Butt: LeftButton; Key:60 shl 8),
 (X1:26; Y1:18; X2:51; Y2:20;Butt: LeftButton; Key:27));
  Text: Boolean = True;
var
  k,n,b,x,y,bb,xx,yy: Integer;
  Font: Pointer;
  FontSize: Word;
type
  GotoXYType = procedure(X,Y: Byte);
  ColorsType = procedure(Text,Back: Byte);
  SetWindowType = procedure(X1,Y1,X2,Y2,Border: Byte;
                	   Header: String;Clip,Build,Play: Boolean);
  ChangeCursorType = procedure;
var
  Colors: ColorsType;
  GotoXY: GotoXYType;
  SetWindow: SetWindowType;
  ChangeCursor: ChangeCursorType;

Procedure SetScreen;
  {������� ��࠭ � ⥪�⮢�� ��� ����᪮� ०���}
begin
{������� �᭮���� ����}
  Colors(Black,LightGray);
  SetWindow(1,1,80,25,DoubleBorder,t1,True,False,False);
{������� �������� �롮�}
  Colors(Black,Green);
  for k := 1 to NItem do with Items[k] do
    begin
      SetWindow(X1,Y1,X2,Y2,SingleBorder,'',True,False,False);
      Write(t4[k])
    end;
{������� ������ �����}
  Colors(White,Red);
  SetWindow(24,9,55,16,DoubleBorder,t2,True,False,False);
  n := (30-Length(t2)) div 2;
  for k := 1 to 4 do
    begin
      GotoXY(n-3,k+1);
      Write(t3[k])
    end
end;   {SetScreen}
{--------------------------}
Procedure ChangeTextCursor; Far;
  {������� ����� � ⥪�⮢�� ०���}
const
  t = ' �롥�� ᨬ��� ��� 㪠��⥫� ��� ';
var
  k: Byte;
  n,x,y: Integer;
begin
{������� ���� �롮�}
  HideMouse;
  PutWindow(8,7,73,12,White,Blue,
            DoubleBorder,1,t,True,False,False);
{�뢮��� � ��� �� ᨬ����, �஬� Bel,BS,LF,CR}
  for k := 1 to 255 do
    if k in [7,8,10,13] then
      Write(' ')
    else
      Write(chr(k));
{��ନ�㥬 �।��� ��६�饭�� 㪠��⥫�}
 MouseWindow(MouseGraphCooX(9),MouseGraphCooY(8),
          MouseGraphCooX(72),MouseGraphCooY(11));
{���� �� ������ ����� ������}
  ShowMouse;
  repeat
    GetMouseState(b,x,y)
  until b and LeftButton=0;
  Repeat
    GetMouseState(b,x,y);
  until b and LeftButton<>0;
  HideMouse;
{��।��塞 ��࠭�� ᨬ���}
  x := MouseTextCooX(x)-8;
  y := MouseTextCooY(y)-7;
  x := (y-1)*64+x;
  if x>255 then
    x := 1;
{���塞 ��� �����}
  MouseTextCursor($FF00,$7F00+x);
{����⠭�������� ��࠭}
  GetWindow(1);
  MouseScreen;
  ShowMouse
end;   {ChangeTextCursor}
{--------------------------}
{�������� ��।������ ��� ��ࠡ��稪� ᮡ�⨩ �� ���,
 �ᯮ��㥬��� � ०��� �롮� ����᪮�� 㪠��⥫�}
const
  DX = 40;    		{��� ᬥ饭�� ����ࠦ����}
  NCur = 4;   		{������⢮ ����ࠦ����}
var
  kk,         		{����� ��࠭��� ����ࠦ����}
  x0,         		{����� �࠭�� ����ࠦ����}
  y0,y1: Integer; 	{���⨪���� �࠭���}
  PP: Pointer;    	{����ࠦ���� 㪠��⥫�}
  SizePP: Word;   	{��� ࠧ���� � �����}

Procedure MouseHandler(Mask,Buttons,X,Y,dDX,DY: Integer);  Far;
  {��᫥������ ��६�饭�� ��� � ��������� ����ࠦ����,
	�� ���஥ 㪠�뢠�� � ����� ������ 㪠��⥫� ���}
var
  k: Integer;           {����饥 ����ࠦ����}
begin
  k := (x-X0) div DX;
  if k<1 then
    k := 1;
  if k>NCur then
    k := NCur;
  if k=kk then
    Exit;     {����饥 ����ࠦ���� �� ����������}
{��ᨬ ��஥ � �뤥�塞 ����� ����ࠦ����}
  PutImage(x0+(2*kk-1)*DX div 2,y0,PP^,NormalPut);
  GetImage(x0+(2*k-1)*DX div 2,y0,x0+(2*k+1)*DX div 2,y1,PP^);
  PutImage(x0+(2*k-1)*DX div 2,y0,PP^,NotPut);
  kk := k
end;   {MouseHandler}
{--------------------------}
Procedure ChangeGraphCursor; Far;
  {������� ����� � ����᪮� ०���}
const
  t = ' �롥�� 㪠��⥫�: ';
var
  x,y,x1: Integer;
  Size,b: Word;
  p: Pointer;
  Cur: array [1..NCur,0..1,0..15] of Word;
  Proc: MouseHandlerType;
{-------------}
Procedure PutCur(N: Byte);
  {�������� ����ࠦ���� � ����� ���孥� 㣫�
   ��࠭� � �ନ��� ��᪨ 㪠��⥫�}
var
  x,y: Byte;
  b: Word;
begin
  for y := 0 to 15 do
    begin
      b := 0;
      for x := 0 to 15 do
        if GetPixel(x,y)<>GetBkColor then
          b := b or ($8000 shr x);
      Cur[N,1,y] := b;
      Cur[N,0,y] := not b
    end;
  ClearViewPort
end;   {PutCur}
{-------------}
begin  {ChangeGraphCursor}
{��⮢�� ���� 16�16 � ����� ���孥� 㣫� ��࠭�}
  Size := ImageSize(0,0,15,15);
  GetMem(P,Size);
  GetImage(0,0,15,15,P^);
  SetViewPort(0,0,15,15,ClipOn);
  ClearViewPort;
{��⮢�� ��᪨ 㪠��⥫��}
  HideMouse;
  if InitMouse then
    ShowMouse;           {����砥��⠭���⭮� ����ࠦ����}
  SetMouseItem(NItem,Items);
  MouseGotoXY(0,0);      {�⠭����� 㪠��⥫�}
  PutCur(1);
  HideMouse;
  Circle(8,8,4);         {��㦮�}
  PutCur(2);
  Line(0,8,15,8);        {��४��⨥}
  Line(8,0,8,15);
  PutCur(3);
  Rectangle(0,0,15,15);  {�����⨪}
  PutPixel(7,7,15);
  PutCur(4);
  SetViewPort(0,0,GetMaxX,GetMaxY,ClipOn);
{��⮢�� ���� ��� ���� 㪠��⥫��}
  PutImage(0,0,P^,NormalPut);
  FreeMem(P,Size);
  x0 := GraphCooX(9);
  y0 := GraphCooY(7);
  x1 := GraphCooX(36);
  y1 := GraphCooY(10);
  Size := ImageSize(x0,y0,x1,y1);
  GetMem(P,Size);
  GetImage(x0,y0,x1,y1,P^);
  Colors(White,Blue);
  SetWindow(9,7,35,9,DoubleBorder,t,True,False,False);
{�뢮��� ����ࠦ���� 㪠��⥫��}
  y1 := y0+16;
  for kk := 1 to NCur do
    for y := 0 to 15 do
      begin
        x1 := x0+kk*DX;
        b := Cur[kk,1,y];
        for x := 0 to 15 do
          if b and ($8000 shr x)<>0 then
            PutPixel(x1+x,y1+y,White)
      end;
{��⠭�������� �।��� ��६�饭�� 㪠��⥫�}
  y0 := y0+16;
  y1 := y1+16;
  MouseWindow(x0,y0,x1+DX,y1);
{�뤥�塞 ��ࢮ� ����ࠦ����}
  SizePP := ImageSize(x0+DX div 2,y0,x0+3*DX div 2,y1);
  GetMem(PP,SizePP);
  GetImage(x0+DX div 2,y0,x0+3*DX div 2,y1,PP^);
  PutImage(x0+DX div 2,y0,PP^,NotPut);
  kk := 1;
{��⠭�������� ᢮� ��ࠡ��稪 ᮡ�⨩}
  SetMouseHandler(1,MouseHandler);
{���� �� ������ ����� ������}
  repeat
    GetMouseState(k,x,y)
  until k and LeftButton<>0;
{����塞 ��ࠡ��稪 ᮡ�⨩}
  ClearMouseHandler;
  FreeMem(PP,SizePP);
{��ନ�㥬 ���� 㪠��⥫�}
  kk := (x-x0) div DX;
  if kk>NCur then
    kk := NCur;
  if kk<1 then
    kk := 1;
  MouseGraphCursor(Cur[kk,0,0],0,0);
{����⠭�������� ��࠭}
  PutImage(x0,y0-16,P^,NormalPut);
  FreeMem(P,Size);
  MouseWindow(0,0,GetMaxX,GetMaxY);
  F_GrText.Window(25,10,54,15);
  Colors(White,Red);
  ShowMouse
end;   {ChangeGraphCursor}
{--------------------------}
Procedure SetTextScreen;
  {������� ⥪�⮢� ��࠭}
begin
  if not Text then

    begin  			{�� ����᪨� ०��}
      FreeMem(Font,FontSize);  	{����塞 ����}
      GraphWriteOff; 	        {����⠭�������� ����/�뢮�}
      CloseGraph; 	        {���室�� � ⥪�⮢��� ०���}
      Text := True
    end;
{����뢠�� �㦭� ��� ⥪�⮢��� ०��� ��楤���}
  GotoXY := F_Text.GotoXY;
  Colors := F_Text.Colors;
  SetWindow := F_Text.SetWindow;
  ChangeCursor := ChangeTextCursor;
{��⠭�������� �⠭����� �����樥�� ������}
  TextRatioY := 8;
{������� ⥪�⮢� ��࠭}
  SetScreen
end; {SetTextScreen}
{--------------------------}
Procedure SetGraphScreen;
  {������� ����᪨� ��࠭}
var
  d,r: Integer;
  h: Byte;
  Name: String;
  F: File;
begin
  if Text then
{���樨�㥬 ��䨪�}
  begin
    d := Detect;
    InitGraph(d,r,'e:\tp\bgi');
    if GraphResult<>grOk then
      Exit;
{�롨ࠥ� ���� � ����ᨬ��� �� ࠧ�襭�� ��࠭�}
    case GetMaxY of
      349: h := 14; {EGA 8x14}
      479: h := 19; {VGA 8x19}
    else
           h := 8   {��稥 8x8}
    end;
{����㦠�� ���� �� 䠩�� 8xH.fnt}
    Str(h,Name);
    Name := '8x'+Name+'.fnt';
    Assign(F,Name);
    {$I-}
    Reset(F,1);
    {$I+}
    if IOResult<>0 then
      Exit;
    FontSize := FileSize(F);
    GetMem(Font,FontSize);
    BlockRead(F,Font^,FontSize,r);
    Close(F);
    if r<>FontSize then
      begin
        FreeMem(Font,FontSize);
        Exit
      end;
{��������㥬 ���� � ��७����砥� ����/�뢮�}
    SetFont(Font,8,h);
    GraphWriteOn;
    Text := False
  end;
{����뢠�� �㦭� ��� ����᪮�� ०��� ��楤���}
  GotoXY := F_GrText.GotoXY;
  Colors := F_GrText.Colors;
  SetWindow := F_GrText.SetWindow;
  ChangeCursor := ChangeGraphCursor;
{������ �����樥�� ������ ���⨪��쭮�� ��������� 
 㪠��⥫� ��� � ⥪�⮢� ࠧ���: �� ࠢ�� ���� ����}
  TextRatioY := h;
{������� ����᪨� ��࠭}
  SetScreen
end;  {SetGraphScreen}
{--------------------------}
begin  {�᭮���� �ணࠬ��}
  CursorOff;      {����塞 �����}
  SetTextScreen;  {��ନ�㥬 ⥪�⮢� ��࠭}
{���樨�㥬 ����. ��� ��楤��� �ᥣ�� ᫥��� �����⢫���
	��᫥ ��⠭���� ��� ᬥ�� ०��� ࠡ��� ��ᯫ��}
  if not InitMouse then
    Halt;
  ShowMouse;
{����뢠�� �������� �롮�}
  SetMouseItem(NItem,Items);
{�᭮���� 横� ࠡ��� �த�������� �� �롮�
 		������� "�������� ࠡ���" ��� ������ Esc}
 {���������� ��砫쭮� ���ﭨ� ���}
  GetMouseState(b,x,y);
  While(True) do {"��᪮����" 横�}
  begin
  {�஢��塞 �롮� ������⮢}
    if KeyOrMousePressed then
    case ReadKeyOrMouse of  {���� �롮�}
      #27: Halt;            {�sc}
      #0: case ReadKeyOrMouse of
        #59: ChangeCursor;  {F1-�������� �����}
        #60: begin          {F2-������� ०��}
               HideMouse;   {���ࠥ� ���� ��। ᬥ��� ०���}
               if Text then
                 SetGraphScreen  {�� ⥪�⮢� ०��}
               else
                 SetTextScreen;  {�� ����᪨� ०��}
               if InitMouse then {���樨�㥬 ���� ��᫥ ᬥ�� ०���!}
                 ShowMouse;
               SetMouseItem(NItem,Items) {������ 㪠�뢠�� �������� �롮�,
                                    �.�. ��� ���뢠���� �� ���樠樨 ���}
             end;
      end  {case}
    end; {case}
  {����砥� ⥪�饥 ���ﭨ� ���}
    GetMouseState(bb,xx,yy);
    if (bb<>b) or (xx<>x) or (yy<>y) then
      begin  		{����ﭨ� ���������� - ᮮ����}
        b := bb;
        x := xx;
        y := yy;
        GotoXY(n+11,2);
        Write(MouseTextCooX(x):2);
        GotoXY(n+16,2);
        Write(MouseTextCooY(y):2);
        GotoXY(n+13,3);
        if b and LeftButton<>0 then
          Write('�����  ')
        else
          Write('���饭�');
        GotoXY(n+13,4);
        if b and RightButton<>0 then
          Write('�����  ')
        else
          Write('���饭�');
        GotoXY(n+13,5);
        if NumButton=3 then
          if b and CenterButton<>0 then
            Write('�����  ')
          else
            Write('���饭�');
      end  {if (bb<>0) or...}
  end  {while TRUE}
end.


