Unit UVerMenu;
{--------------------------------}INTERFACE{---------------------------------}
Uses Crt,Graph,URect,UMouse,UEvent,UConst;
Type
  Strin  = string[30];
  StrArr = array [0..10] of strin;
  PVerticalMenu    = ^TVerticalMenu;
  TVerticalMenu    =  object(TRect)
                        ItemsNum     : byte;
                        Curr         : PRect;
                        Items        : PRect;
                        Constructor Init(aX1,aY1,aX2,aY2:integer);
                        Destructor  Done;                       Virtual;
                        Procedure   Draw(F:Byte);               Virtual;
                        Procedure   Handler(Var Event:Word);    Virtual;
                        Procedure   NextItem(aCurr:PRect);      Virtual;
                        Procedure   PrevItem(aCurr:PRect);      Virtual;
                        Procedure   ReInit;                     Virtual;
                        Procedure   InsertItem( C:PRect;
                                              LastItem:Boolean);Virtual;
                       end;
 PVerItem     =  ^TVerItem;
 TVerItem     =  Object (TRect)
                  Tx,Ty        :  Integer;
                  MyConst      :  Word;
                  WasOnMe      :  Boolean;
                  Constructor Init(aX1,aY1,aX2,aY2:Integer;aHeader:strin;Con:Word);
                  Destructor  Done;                         Virtual;
                  Procedure   Draw(Select:Byte);            Virtual;
                  Procedure   Handler(var Event:Word);      Virtual;
                 End;
VAR
 P:TRect;
 CurrFont  :   integer;

{------------------------------}IMPLEMENTATION{------------------------------}
Constructor TVerItem.Init;
 Begin
  Inherited Init(aX1,aY1,aX2,aY2,False);
  TX:=X1+2;
  TY:=((Y2-Y1)div 2)+Y1;
  Header:=aHeader;
  MyConst:=Con;
  WasOnMe:=False;
  Next:=Nil
 End;
{----------------------------------------------------------------------------}
Destructor TVerItem.Done;
 Begin
  Inherited Done
 End;
{----------------------------------------------------------------------------}
Procedure TVerItem.Draw;
 var i:integer;
 Begin
  Case Select of
  Common       : begin{Common view}
                   SetColor(scFore);
                   SetTextJustify(LeftText,CenterText);
                   OutTextXY(tx,ty,Header);
                   SetColor(scBack);
                   Line(X1-1,Y1-1,X1-1,Y2+1);
                   Line(X1-1,Y1-1,X2+1,Y1-1);
                   Line(X2+1,Y2+1,X1-1,Y2+1);
                   Line(X2+1,Y2+1,X2+1,Y1-1);
                  end;
   Selected     : begin{Selected}
                   SetColor(scBorderLeft);
                   Line(X1-1,Y1-1,X1-1,Y2+1);
                   Line(X1-1,Y1-1,X2+1,Y1-1);
                   SetColor(scBorderRight);
                   Line(X2+1,Y2+1,X1-1,Y2+1);
                   Line(X2+1,Y2+1,X2+1,Y1-1);
                   Next^.Draw(Common)
                  end;
   Pressed      : begin{Pressed}
                   SetColor(scBorderRight);
                   Line(X1-1,Y1-1,X1-1,Y2+1);
                   Line(X1-1,Y1-1,X2+1,Y1-1);
                   SetColor(scBorderLeft);
                   Line(X2+1,Y2+1,X1-1,Y2+1);
                   Line(X2+1,Y2+1,X2+1,Y1-1);
                  end;
  End
 End;
{----------------------------------------------------------------------------}
Procedure TVerItem.Handler;
Var P,I:PRect;
 Begin
   Case Event Of
    MouseEvent   :  If MouseIn(X1,Y1,X2,Y2) then
                     Begin
                      If Not WasOnMe then begin
                                           {Draw before common---------------}
                                           P:=Next;
                                           I:=Next^.Next;
                                           While I^.Next^.Next<>P do I:=I^.Next;
                                           I^.Draw(Common);
                                           {---------------------------------}
                                           Draw(Selected);
                                           WasOnMe:=True;
                                           Next^.Draw(Common)
                                          end;
                      If MouseMove then begin
                                         {Draw before common---------------}
                                         P:=Next;
                                         I:=Next^.Next;
                                         While I^.Next^.Next<>P do I:=I^.Next;
                                         I^.Draw(Common);
                                         {---------------------------------}
                                         Draw(Selected);
                                         Next^.Draw(Common);
                                         WriteMousePointer(MouseX,MouseY)
                                        end;
                      If MouseButton = 1 then
                       begin
                        Draw(Pressed);
                        WriteMousePointer(MouseX,MouseY);
                        Result:=MyConst;
                        WriteMousePointer(MouseX,MouseY);
                        DoneModalF:=True;
                       end;
                      ClearEvent(Event)
                     End
                     else If WasOnMe then WasOnMe:=False;
    KeyboardEvent: If Not Extended then Case scancode of
                                         EnterKey: Begin
                                                   Draw(Pressed);
                                                   ClearEvent(Event);
                                                   Result:=MyConst;
                                                   DoneModalF:=True
                                                   end;
                                        end;
    InternalEvent:  ;
   end
 End;

{------------------------------ TVerticalItem -------------------------------}
{}
Constructor TVerticalMenu.Init;
 var
 i,max,aStripeHeight :integer;
 begin
  Inherited Init(ax1,ay1,ax2,ay2,True);
  Items:=Nil
 end;
{----------------------------------------------------------------------------}
Procedure TVerticalMenu.ReInit;
 Var
  I,P:PRect;
 begin
  I:=Items;
  Draw(Common);
  Curr:=Items;
  Items^.Draw(Selected);
  Delay(Pause)
 end;
{----------------------------------------------------------------------------}
Procedure TVerticalMenu.Draw;
 var
  P,I : PRect;
 begin
  Inherited Draw(Common);
  I:=Items;
  P:=I;
  If I<>Nil then
   begin
    while I^.Next<>P do
     begin
      I^.Draw(Common);
      I:=I^.Next;
     end;
   I^.Draw(Common);
  end
 end;
{----------------------------------------------------------------------------}
Destructor TVerticalMenu.Done;
 var P,I:PRect;
 begin
  Hide;
  I:=Items;
  P:=Items;
  If Items<>Nil then
   Begin
    While I^.Next<>P do
     begin
      I:=Items^.Next;
     { Items^.Hide;}
      Dispose(Items,Done);
      Items:=I
     end;
    Dispose(Items,Done)
   end;
  Inherited Done;
 end;
{----------------------------------------------------------------------------}
Procedure TVerticalMenu.NextItem;
 begin
  Curr^.Draw(Common);
  Curr:=Curr^.Next;
  Curr^.Draw(Selected);
 end;
{----------------------------------------------------------------------------}
Procedure TVerticalMenu.PrevItem;
 Var I:Prect;
 begin
  I:=Curr;
  While I^.Next<>Curr do I:=I^.Next;
  Curr^.Draw(Common);
  Curr:=I;
  Curr^.Draw(Selected);
 end;
{----------------------------------------------------------------------------}
Procedure TVerticalMenu.InsertItem;
 var I:PRect;
 begin
  I:=Items;
  If I=Nil then
   begin
    Items:=C;
    If LastItem then Items^.Next:=Items
                Else Items^.Next:=Nil;
   end
  Else
   begin
    While I^.Next<>Nil do I:=I^.Next;
    I^.Next:=C;
    I:=I^.Next;
    If LastItem then I^.Next:=Items
                Else I^.Next:=Nil;
   end;

 end;
{----------------------------------------------------------------------------}
Procedure TVerticalMenu.Handler;
var I,P:PRect;
 begin
    Case Event of
     MouseEvent    : If MouseIn(x1,y1,x2,y2) then
                       begin
                        I:=Items;
                        P:=Items;
                        If I<>Nil Then
                         Begin
                          While I^.Next<>P do
                           begin
                            I^.Handler(Event);
                            If EventClear(Event) then begin
                                                       Exit;
                                                       Curr:=i
                                                      end
                                                 else I:=I^.Next
                           end;
                          I^.Handler(Event);
                        ClearEvent(Event)
                       end;
                       {If (Not EventClear(Event)) and
                         MouseMove then Draw(0)}
                      end
                      Else If MousePressed then
                       begin
                        Result:=cmEmpty;
                        DoneModalF:=True
                       end;
     KeyboardEvent : If Extended then Case ScanCode of
                                        UpKey   : begin
                                                   Draw(0);
                                                   PrevItem(Curr);
                                                   end;
                                        DownKey : begin
                                                   Draw(0);
                                                   NextItem(Curr);
                                                  end;
                                       end{Case}
                                  else Case ScanCode of
                                        EnterKey : Begin
                                                    Curr^.Handler(Event);
                                                    Hide;
                                                    {DoneModalF:=True}
                                                   end;
                                        EscKey   : begin
                                                    Hide;
                                                    Result:=cmEmpty;
                                                    DoneModalF:=True
                                                   End
                                       End

    end{Case}
 end;{Handler}
END.