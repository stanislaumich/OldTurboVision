Unit ULstItem;{BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB}
{-------------------------------}INTERFACE{----------------------------------}
Uses Graph,UConst;
TYPE
 Strin      = String[50];
 PListItem  = ^TListItem;
 TListItem  = Object
 X1,X2      : Integer;
 Text       : Strin;
 Height     : Integer;
 Prev,Next  : PListItem;
Constructor Init(aX1,aX2:Integer;aText:strin);
Destructor  Done;
Procedure   Draw(Y:integer;F:Byte);
END;{TListItem}

{----------------------------}IMPLEMENTATION{--------------------------------}
Constructor TListItem.Init;
 begin
  X1:=aX1;
  X2:=aX2;
  Text:=aText;
  Height:=TextHeight(Text);
  Next:=Nil;
  Prev:=Nil
 end;
{----------------------------------------------------------------------------}
Destructor TListItem.Done;
 begin

 end;
{----------------------------------------------------------------------------}
Procedure TListItem.Draw;
 begin
  Case F of
     Common : begin
               SetFillPattern(ListPattern,lcBack);
               SetTextJustify(LeftText,BottomText);
               Bar(X1,Y,X2,Y+Height);
               SetColor(lcFore);
               OutTextXy(X1,Y,Text)
              end;
   Selected : begin
               SetFillPattern(ListPattern,lcSelectedBack);
               SetTextJustify(LeftText,BottomText);
               Bar(X1,Y,X2,Y+Height);
               SetColor(lcSelectedFore);
               OutTextXy(X1,Y,Text)
              end;
  end{Case}
 end;
{----------------------------------------------------------------------------}

END.{EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE}