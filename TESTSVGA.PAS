Uses Crt,Graph,Umouse;
Var
 I,X,Y,ox,z,m:Integer;
 P:Word;
 a:Array(.1..3,1..74.)of word;
 c:Char;
 S:string;
Begin
 X:=1;
 While X<=64 do
  begin
   m:=x;
   For I:=1 to 64 do
     SetRGBPalette(I,X,I,0);
   X:=m;
   Y:=1;
   While Y<=64 do
    begin
    PutPixel(X+200,Y+200,Y);
    Z:=Y;
    Y:=Y+1;
    If KeyPressed or MousePressed  then  begin Y:=65;X:=65 end;
    end;
   Inc(X)
  end;
 SetColor(63);
 Str(m,s);
 OutTextXY(10,10,'  R= '+s);
 Str(z,s);
 OutTextXY(60,10,'  G= '+s);
 Str(0,s);
 OutTextXY(110,10,'  B= '+s);
 SetColor()
While Keypressed do c:=ReadKey;
 Repeat Until KeyPressed
End.