Unit UStatus;
{--------------------------------}INTERFACE{---------------------------------}
Uses Graph,UConst,URect;
Type
 PStatusLine   =  ^TStatusLine;
 TStatusLine   =  Object(TRect)
                   Tx,Ty:integer;
  Constructor Init(aX1,aY1,aX2,aY2:integer);
  Procedure   Text(st:String);
  Procedure   Clear;
 end;




{-----------------------------}IMPLEMENTATION{-------------------------------}
Constructor TStatusLine.Init;
 begin
  Inherited Init(aX1,aY1,aX2,aY2,False);
  Inherited Draw(Common);
  SetColor(scBorderRight);
  Line(X1+1,Y1+1,X1+1,Y2-1);
  Line(X1+1,Y1+1,X2-1,Y1+1);
  SetColor(scBorderLeft);
  Line(X2-1,Y2-1,X1+1,Y2-1);
  Line(X2-1,Y2-1,X2-1,Y1+1);
  Tx:=X1+5;
  Ty:=Y1+((Y2-Y1)div 2);
 end;
{----------------------------------------------------------------------------}
Procedure TStatusLine.Text;
 begin
  SetTextJustify(LeftText,CenterText);
  OutTextXY(Tx,Ty,St);
  Header:=St
 end;
{----------------------------------------------------------------------------}
Procedure TStatusLine.Clear;
var
 I  :  integer;
 begin
  SetColor(scBack);
  MoveTo(Tx,Ty);
  For I:=1 to 80 do OutText(#255)
 end;
{----------------------------------------------------------------------------}
END.