{$A+,B-,D+,E-,F-,G-,I+,L+,N+,O-,P-,Q-,R-,S+,T-,V+,X+}
{$M 65520,0,655360}
Unit UMouse;
{-------------------------------}INTERFACE{---------------------------------}
Uses graph,dos;
Const
Color   :integer   =  5;
Var
  Point          :   Pointer;
  Size           :   integer;
  Reg            :   Registers;
  WorkDriver     :   integer;
  CountKeyMouse  :   integer;
  MouseButton    :   integer;
  MouseX         :   integer;
  MouseY         :   integer;
  MouseMove      :   Boolean;
  X_Mouse        :   integer;
  Y_Mouse        :   integer;
  dX,dY          :   integer;

Function  MouseIn(X1,Y1,X2,Y2: Integer): Boolean;
Procedure SaveImageMousePointer(X1,Y1,X2,Y2:Integer);
Procedure RestoreImageMousePointer(X1,Y1:Integer);
Procedure WriteMousePointer(X,Y:Integer);
Procedure ReadMouseXY(Var X,Y,NambKey:Integer);
Procedure ShowMouse;
Procedure HideMouse;
Procedure Mouse;
Procedure MyInitGraph;
Function  MousePressed:Boolean;
Procedure DoneMouse;
Procedure WriteMouseAndSave;
Procedure SetStepToPixel(Hor,Ver: Integer);
Procedure MouseWindow(X1,Y1,X2,Y2:Integer);
VAR
DriverP     :    integer;
ModeP       :    integer;
ErrorInt    :    Integer;



{-----------------------------}IMPLEMENTATION{-------------------------------}
Procedure SetStepToPixel(Hor,Ver: Integer);
begin
  With Reg do
    begin
      ax := $0F;
      cx := Hor and $7FFF;
      dx := Ver and $7FFF;
      Intr($33,Reg)
    end
end;
{----------------------------------------------------------------------------}
Procedure WriteMouseAndSave;
 begin
  SaveImageMousePointer(MouseX,MouseY,MouseX+6,MouseY+12);
  WriteMousePointer(MouseX,MouseY)
 end;

Function MousePressed: Boolean;
begin
  with Reg do
    begin
      ax := $3;
      Intr($33,Reg);
      MousePressed := bx<>0
    end
end;   {MousePressed}
{----------------------------------------------------------------------------}
Function MouseIn(X1,Y1,X2,Y2: Integer): Boolean;
begin
   with Reg do
    begin
      ax := $3;
      Intr($33,Reg);
      MouseIn := (cx>=X1) and (cx<=X2) and
                 (dx>=Y1) and (dx<=Y2)
    end
end;   {MouseIn}
{---------------------------------------------------------------------------}
Procedure ShoWMouse;
 Var
 I:Byte;
 X,Y:Integer;
 begin
  X:=MouseX;
  Y:=MouseY;
  GetImage(X,Y,X+6,Y+12,Point^);
  SetColor(Color);
  for i:=0 to 10 do PutPixel(x+0,y+i,Color);
  for i:=1 to 9 do  PutPixel(x+1,y+i,Color);
  for i:=2 to 8 do  PutPixel(x+2,y+i,Color);
  for i:=3 to 7 do  PutPixel(x+3,y+i,Color);
  for i:=4 to 6 do  PutPixel(x+4,y+i,Color);
  for i:=5 to 5 do  PutPixel(x+5,y+i,Color);
  PutPixel(x+3,y+7,Color);
  PutPixel(x+3,y+8,Color);
  PutPixel(x+3,y+9,Color);
  PutPixel(x+3,y+10,Color);
  PutPixel(x+4,y+8,Color);
  PutPixel(x+4,y+9,Color);
  PutPixel(x+4,y+10,Color);
  PutPixel(x+4,y+11,Color);
  PutPixel(x+5,y+10,Color);
  PutPixel(x+5,y+11,Color);
  PutPixel(x+5,y+12,Color);
 end;
{---------------------------------------------------------------------------}
Procedure HideMouse;
 begin
  PutImage(MouseX,MouseY, Point^, copyPut);
 end;
{---------------------------------------------------------------------------}
Procedure MyInitGraph;
Begin
  DriverP:=detect;
  DriverP:=InstallUserDriver('Svga256',nil);{Vesa is bad}
  ModeP:=3;{3 for vesa-1024x768, 2 for vesa-800x600,
            3 for svga-800x600, 4 for svga-1024x768}
  InitGraph(DriverP,ModeP,'');
  ErrorInt:=GraphResult;
  IF ErrorInt<>0 then
  begin
   Writeln('ошибка:',GraphErrorMsg(ErrorInt));
   Exit
  end
End;
{---------------------------------------------------------------------------}
Procedure SaveImageMousePointer;
Begin
  GetImage(X1,Y1,X2,Y2,Point^);
End;
{---------------------------------------------------------------------------}
Procedure DoneMouse;
 begin
  FreeMem(Point,Size)
 end;
{---------------------------------------------------------------------------}
Procedure RestoreImageMousePointer;
Begin
  PutImage(X1,Y1, Point^, copyPut);
End;
{---------------------------------------------------------------------------}
Procedure WriteMousePointer;
var
 i     : integer;
 j     :integer;
Begin
  SetColor(Color);
  for i:=0 to 10 do PutPixel(x+0,y+i,Color);
  for i:=1 to 9 do  PutPixel(x+1,y+i,Color);
  for i:=2 to 8 do  PutPixel(x+2,y+i,Color);
  for i:=3 to 7 do  PutPixel(x+3,y+i,Color);
  for i:=4 to 6 do  PutPixel(x+4,y+i,Color);
  for i:=5 to 5 do  PutPixel(x+5,y+i,Color);
  PutPixel(x+3,y+7,Color);
  PutPixel(x+3,y+8,Color);
  PutPixel(x+3,y+9,Color);
  PutPixel(x+3,y+10,Color);
  PutPixel(x+4,y+8,Color);
  PutPixel(x+4,y+9,Color);
  PutPixel(x+4,y+10,Color);
  PutPixel(x+4,y+11,Color);
  PutPixel(x+5,y+10,Color);
  PutPixel(x+5,y+11,Color);
  PutPixel(x+5,y+12,Color);
End;
{---------------------------------------------------------------------------}
Procedure ReadMouseXY;
Begin
  With Reg do
  begin
    AX:=3;
    Intr($33,Reg);
    NambKey:=BX;
    X:=CX;
    Y:=DX
  end
End;
{---------------------------------------------------------------------------}
Procedure ResetMouse;
Begin
  With Reg do
  begin
    AX:=0;
    Intr($33,Reg);
    WorkDriver:=AX;
    CountKeyMouse:=BX;
  end;
 ReadMouseXY(X_Mouse,Y_Mouse,MouseButton);
 Size:=ImageSize(X_Mouse,Y_Mouse,X_Mouse+6,Y_Mouse+12);
 GetMem(Point,Size);
 SaveImageMousePointer(X_Mouse,Y_Mouse,X_Mouse+6,Y_Mouse+12);
End;
{---------------------------------------------------------------------------}
Procedure Mouse;
var st:string;
Begin
   ReadMouseXY(X_Mouse,Y_Mouse,MouseButton);
   IF X_Mouse<1 then X_Mouse:=0;
   IF X_Mouse>GetMaxX-6 then X_Mouse:=GetMaxX-6;
   IF Y_Mouse<1 then Y_Mouse:=0;
   IF Y_Mouse>GetMaxY-12 then Y_Mouse:=GetMaxY-12;
   MouseMove:=not((X_Mouse=MouseX)and(Y_Mouse=MouseY));
   dX:=X_Mouse-MouseX;
   dY:=Y_Mouse-MouseY;
   IF MouseMove then
    begin
     PutImage(MouseX,MouseY, Point^, copyPut);
     GetImage(X_Mouse,Y_Mouse,X_Mouse+6,Y_Mouse+12,Point^);
     WriteMousePointer(X_Mouse,Y_Mouse);
    end;
    MouseX:=X_Mouse;
    MouseY:=Y_Mouse;
End;
{----------------------------------------------------------------------------}
Procedure MouseWindow(X1,Y1,X2,Y2: Integer);
  {Задает координаты области перемещения указателя.
	X1...Y2 - виртуальные координаты}
begin
 with Reg do
  begin
   ax := $7;
   cx := X1;
   dx := X2;
   Intr($33,Reg);
   ax := $8;
   cx := Y1;
   dx := Y2;
   Intr($33,Reg)
  end
 end;   {MouseWindow}
{---------------------------------------------------------------------------}
BEGIN
MyInitGraph;
ResetMouse
END.