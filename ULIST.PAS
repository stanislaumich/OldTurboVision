Unit UList;
{---------------------------------}INTERFACE{--------------------------------}
Uses UConst,URect,Graph,ULstItem;
TYPE
 PList = ^TList;
 TList = Object(TRect)
          FillPattern  :  FillPatternType;
          FirstLineShow,
          LastLineShow :  Integer;
          ListIndex    :  Integer;
          Items        :  PListItem;
          NumOfItems   :  Integer;
          Curr         :  PListItem;

 Constructor Init(aX1,aY1,aX2,aY2:Integer;SFlag:Boolean);
 Destructor  Done;          Virtual;
 Procedure   Draw(F:Byte);  Virtual;
 Procedure   InsertListItem(Item:PListItem;Pos:integer);Virtual;
 Procedure   DeleteListItem(Pos:integer);Virtual;
 Procedure   AddListItem(Item:PListItem);   Virtual;
 Procedure   Sort;          Virtual;
 Function    SortCondition(l1,l2:TListItem):Boolean;Virtual;
 Procedure   Handler(Var Event:Word);Virtual;

 END;{TLIST}
{------------------------------}IMPLEMENTATION{------------------------------}
Constructor TList.Init;
 begin
  Inherited Init(aX1,aY1,aX2,aY2,SFlag);
  Items:=NIL;
  Draw(Selected);
  NumOfItems:=0
 end;
{----------------------------------------------------------------------------}
Destructor TList.Done;
var
 I:PListItem;
 begin
  I:=Items;
  While Items<>Nil do
   begin
    Items:=Items^.Next;
    Dispose(I,Done);
    I:=Items;
   end;
  Inherited Done
 end;
{----------------------------------------------------------------------------}
Procedure TList.InsertListItem;
var
 I:Integer;
 begin
  If NumOfItems<32767 then
   begin
    I:=0;
    Curr:=Items; {Search last}
    While (Curr^.Next<>NIL) or (I<>Pos) do
     begin
      Curr:=Curr^.Next;
      Inc(I)
     end;
    {Insert}
    Item^.Next:=Curr^.Next;
    Item^.Prev:=Curr;
    Curr^.Next^.Prev:=Item;
    Curr^.Next:=Item;
    Curr:=Item;
    Inc(NumOfItems)
   end
 end;
{----------------------------------------------------------------------------}
Procedure TList.AddListItem;
 begin
  If NumOfItems<32767 then
   begin
    {add to end}
    Curr:=Items; {Search last}
    While Curr<>NIL do Curr:=Curr^.Next;
    {Insert}
    Item^.Next:=Nil;
    Item^.Prev:=Curr;
    Curr^.Next:=Item;
    Curr:=Item;
    Inc(NumOfItems)
   end
 end;
{----------------------------------------------------------------------------}
Procedure TList.DeleteListItem;
var
 i:integer;
 Item:PListItem;
 begin
  If Pos>NumOfItems then Exit;
  If NumOfItems>1 then
   begin
    {Search}
    I:=1;
    Curr:=Items; {Search last}
    While (Curr^.Next<>NIL) or (I<Pos-1) do
     begin
      Curr:=Curr^.Next;
      Inc(I)
     end;
    {Delete}
    Item:=Curr^.Prev;
    Item^.Next:=Curr^.Next;
    Curr^.Next^.Prev:=Item;
    Dispose(Curr);
    Curr:=Item;
    Dec(NumOfItems)
   end
 end;
{----------------------------------------------------------------------------}
Procedure TList.Sort;
 begin

 end;

Function TList.SortCondition;
 begin
  SortCondition:=False{Not Change}
 end;
{----------------------------------------------------------------------------}
Procedure TList.Draw;
Var
 I:PListItem;
 Ic:Integer;
 Y:Integer;
 begin
  Inherited Draw(Selected);
  I:=Items;
  Y:=Y1+1;
  While I<>Nil do
   begin
    If I<>Curr then I^.Draw(Y,Common)
      else I^.Draw(Y,Selected);
    Y:=Y+TextHeight(I^.Text);
    I:=I^.Next;
   end;
 end;
{----------------------------------------------------------------------------}
Procedure Tlist.Handler;
 begin
 end;
END.{EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE}