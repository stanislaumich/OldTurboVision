Program Consol;
Uses Crt,Umouse,Graph;
Var I,P,X,Y   :Integer;
    S1    :Word;
    MaxX,MaxY:Word;
    ColorLight, ColorDark :Word ;

Procedure Save;
Var
 X,Y : Integer;
 S   : Word;
 Fv  : File of Byte;
Begin
 Assign(Fv,'Consol.gam');
 Rewrite(Fv);
 For X:=0 to 1023 do
  For Y:=0 to 767 do
   begin
    S:=GetPixel(X,Y);
    Write(Fv,Byte(s));
   end;
 Close(FV)
End;

Procedure WriteVert(X1,Y1:Integer;St:String);
 Var
  I,X,Y:Integer;
 begin
  X:=X1;Y:=Y1;
  For I:=1 to Length(St) do
   begin
    OutTextXY(X,Y,St[I]);
    Y:=Y+3+TextHeight(St)
   end
 end;


Begin
{---------------------------BackGround--------------------------------------}
 P:=0;
 MaxX:=GetMaxX;
 MaxY:=GetMaxY;                               {SetRGB}
 For I:=40 to 50 do
  begin
   SetRGBPalette(I,10+P,P+100*2,0);
   P:=P+2;
  end;
                                {End of RGB}
 S1:=40;
 For I:=S1 to S1+9 do
  begin
   SetColor(I);
   Line(I-S1,I-S1,MaxX-I+S1,I-S1);       {Big Window}
   Line(I-S1,I-S1,I-S1,MaxY-I+S1);
   Line(I-S1,MaxY+S1-I,MaxX-I+S1,MaxY+S1-I);
   Line(MaxX+S1-I,MaxY+S1-I,MaxX+S1-I,I-S1);

   SetColor((S1+10)-I+S1);                      {Inside Window}
   Line(I-S1+10,I-S1+10,MaxX-10-I+S1,I-S1+10);
   Line(I-S1+10,I-S1+10,I-S1+10,MaxY-149-I+S1);
   Line(I-S1+10,MaxY-149-I+S1,MaxX-10-I+S1,MaxY-149-I+S1);
   Line(MaxX-10-I+S1,MaxY-149-I+S1,MaxX-10-I+S1,I-S1+10);
  end;


  For I:=0 To 138 do
   begin
    SetColor(50);
    Line(10,MaxY-148+I,MaxX-10,MaxY-148+i);
   end;

  S1:=40;
  For I:=S1 to S1+10 do
   begin
    SetColor((S1+10)-i+S1);
    Line(MaxX-624+I-S1,MaxY-148+I-S1,MaxX-374-I+S1,MaxY-148+I-S1);
    Line(MaxX-624+I-S1,MaxY-148+I-S1,MaxX-624+I-S1,MaxY-10-I+S1);
    Line(MaxX-624+I-S1,MaxY-10+S1-I,MaxX-374-I+S1,MaxY-10+S1-I);
    Line(MaxX-374+S1-I,MaxY-10+S1-I,MaxX-374+S1-I,MaxY-148+I-S1);
   end;

  For X:=0 to MaxX do
   begin
    For Y:=0 to MaxY do
     begin
      If GetPixel(X,Y)<>0 then begin
                                I:=Random(10);
                                Case I of
                                        1:  PutPixel(X,Y,42);
                                        3:  PutPixel(X,Y,44);
                                        7:  PutPixel(X,Y,46);
                                end;

     end;
   end;
   end;
  For X:=MaxX-613 to MaxX-385 do
   For Y:= MaxY-137 to MaxY-21  do
    PutPixel(X,Y,0);
  SetColor(6);
  Rectangle(MaxX-613,MaxY-137,MaxX-385,MaxY-19);
  SetColor(6);
  MoveTo(20,20);
  LineRel(MaxX-40,0);
  LineRel(0,MaxY-179);
  LineRel(40-MaxX,0);
  LineRel(0,179-MaxY);
{-------------------------------SideBar--------------------------------------}
  ColorLight:= 7{66};
  ColorDark := 0 ;
  SetLineStyle(SolidLn, 0, ThickWidth);
  For I:=0 to 2 do        {three Key}
   begin
    MoveTo(20,658+I*47);
    SetColor(ColorLight);
    LineRel(0,-36);
    LineRel(100,0);
    SetColor(ColorDark);
    LineRel(0,36);
    LineRel(-100,0);
   end;
  For I:=0 to 1 do        {Left-Right Hand}
   begin
    MoveTo(362+i*290,MaxY-15);
    SetColor(ColorLight);
    LineRel(0,-130);
    LineRel(35,0);
    SetColor(ColorDark);
    LineRel(0,130);
    LineRel(-35,0);
   end;
   {Action Points}
   SetLineStyle(SolidLn, 0, ThickWidth);
   MoveTo(130,MaxY-15);
   SetColor(ColorLight);
   LineRel(0,-130);
   LineRel(35,0);
   SetColor(ColorDark);
   LineRel(0,130);
   LineRel(-35,0);
   MoveTo(132,MaxY-14);
   SetColor(ColorDark);
   LineRel(0,-129);
   LineRel(31,0);
   SetColor(ColorLight);
   LineRel(0,126);
   LineRel(-31,0);
   {Return }
   MoveTo(970,MaxY-15);
   SetColor(ColorLight);
   LineRel(0,-60);
   LineRel(35,0);
   SetColor(ColorDark);
   LineRel(0,60);
   LineRel(-35,0);
   MoveTo(970,MaxY-85);
   SetColor(ColorLight);
   LineRel(0,-60);
   LineRel(35,0);
   SetColor(ColorDark);
   LineRel(0,60);
   LineRel(-35,0);
   SetLineStyle(SolidLn, 0, NormWidth);
   {Texts}
   SetColor(15);
   SetTextStyle(SmallFont,HorizDir,6);
   SetTextJustify(CenterText,CenterText);
   OutTextXY(70,636,'Инвентарь');
   OutTextXY(70,683,'Характер.');
   OutTextXY(70,730,'Компьютер');
   WriteVert(380,MaxY-120,'Левая');
   WriteVert(670,MaxY-127,'Правая');
  Repeat
   Mouse
  Until  KeyPressed;



End.