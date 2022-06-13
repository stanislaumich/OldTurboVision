USES crt,GRAPH,DOS;
VAR
  Size,WorkDriver,CountKeyMouse                    :WORD;
  NamKey,DriverP,ModeP,I,X_Mouse,Y_Mouse,X_Ms,Y_Ms :INTEGER;
  ErrorInt                                         :BYTE;

  Reg                                              :REGISTERS;
  Point                                            :POINTER;
  ia                                                :integer;
{ ******************** Процедура инициализации графики ********************* }
Procedure Int_Gr;
Begin
  DriverP:=Detect; InitGraph(DriverP,ModeP,'');
  ErrorInt:=GraphResult;
  IF ErrorInt<>0 then
  begin
   Writeln('ошибка:',GraphErrorMsg(ErrorInt));
   Exit
  end
End;

{************************ Процедура сохранения окна *************************}
Procedure SaveWind(X1,Y1,X2,Y2:Integer);
Begin
  Size:=ImageSize(X1,Y1,X2,Y2);
  GetMem(Point,Size);
  GetImage(X1,Y1,X2,Y2,Point^);
End;

{*********************** Процедура востановления окна ***********************}
Procedure RestoreWind(X1,Y1:Integer);
Begin
  PutImage(X1,Y1, Point^, copyPut);
  FreeMem(Point,Size)
End;

Procedure WriteSinglMouse(X,Y:Integer);
var
 color :word;
 j     :integer;
procedure MyPutPixel(x,y:integer);
 begin
  PutPixel(x,y,color)
 end;
Begin
 color:=1;
 SetColor(color);
  {
  For I:=0 to 6 do Line(X-I,Y+I,X+I,Y+I);
  For I:=6 to 12 do Line(X-3,Y+I,X+3,Y+I);
   }
  for i:=0 to 10 do MyPutPixel(x+0,y+i);
  for i:=1 to 9 do  MyPutPixel(x+1,y+i);
  for i:=2 to 8 do  MyPutPixel(x+2,y+i);
  for i:=3 to 7 do  MyPutPixel(x+3,y+i);
  for i:=4 to 6 do  MyPutPixel(x+4,y+i);
  for i:=5 to 5 do  MyPutPixel(x+5,y+i);
  MyPutPixel(x+3,y+7);
  MyPutPixel(x+3,y+8);
  MyPutPixel(x+3,y+9);
  MyPutPixel(x+3,y+10);

  MyPutPixel(x+4,y+8);
  MyPutPixel(x+4,y+9);
  MyPutPixel(x+4,y+10);
  MyPutPixel(x+4,y+11);

  MyPutPixel(x+5,y+10);
  MyPutPixel(x+5,y+11);
  MyPutPixel(x+5,y+12);
End;

Procedure WriteWind;
 begin
  line(10,10,200,10);
  line(10,10,10,200);
  line(200,200,10,200);
  line(200,200,200,10);
  line(10,25,200,25);
  outtextxy(15,15,'Window');
  line(190,12,198,12);
  line(190,23,198,23);
  line(190,12,190,23);
  line(198,12,198,23);
  line(192,14,196,22);
  line(192,22,196,14);

 end;



Procedure ReadMouseXY(Var X,Y,NambKey:Integer);
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

Procedure ResetDriverMouse;
Begin
  With Reg do
  begin
    AX:=0;
    Intr($33,Reg);
    WorkDriver:=AX;
    CountKeyMouse:=BX;
  end
End;

Procedure Mouse;
Begin
  ReadMouseXY(X_Mouse,Y_Mouse,NamKey);
  X_Ms:=X_Mouse;
  Y_Ms:=Y_Mouse;
  SaveWind(X_Mouse,Y_Mouse,X_Mouse+6,Y_Mouse+12);
  WriteSinglMouse(X_Mouse,Y_Mouse);
  Repeat
   ReadMouseXY(X_Mouse,Y_Mouse,NamKey);
   IF X_Mouse<1 then
    X_Mouse:=0;
   IF X_Mouse>633 then
    X_Mouse:=633;
   IF ((X_Mouse<>X_Ms)or (Y_Mouse<>Y_Ms))then
    begin
     RestoreWind(X_Ms,Y_Ms);
     SaveWind(X_Mouse,Y_Mouse,X_Mouse+6,Y_Mouse+12);
     WriteSinglMouse(X_Mouse,Y_Mouse);
    end;
    X_Ms:=X_Mouse;
    Y_Ms:=Y_Mouse;
  Until (NamKey=1)or(NamKey<>0);
 RestoreWind(X_Ms,Y_Ms);
End;


BEGIN
  Int_Gr;
  SetBKColor(0);
  SetColor(15);
  ResetDriverMouse;
  writewind;
  ia:=1;
  repeat
   if keypressed then exit;
   Mouse;
   if namkey>0 then namkey:=1;
   if namkey<>0 then begin
    setbkcolor(ia);
    inc(ia);
    if ia=16 then ia:=0;
  end;
  until false;
END.
