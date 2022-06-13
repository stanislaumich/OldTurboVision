Unit UHorMenu;
{===============================}INTERFACE{=================================}
Uses Crt,Graph,URect,UMouse,UEvent,UConst;
Const
 Last    =  true;
 NotLast =  False;
 F10     : Boolean = false;

Type
 Proc      =    Procedure;
 PHorItem     =    ^THorItem;
 THorItem     =     Object(TRECT)
                  Tx,Ty        :  Integer;
                  WasOnMe      :  Boolean;
                  MyConst      :  Word;
                  Constructor Init(aX1,aY1,aX2,aY2:Integer;aHeader:strin;
                                   Con:Word);
                  Destructor  Done;                         Virtual;
                  Procedure   Draw(Select:Byte);            Virtual;
                  Procedure   Handler(var Event:Word);      Virtual;
                 End;
  StrArr = array [0..10] of strin;
  PHorizontalMenu    = ^THorizontalMenu;
  THorizontalMenu    =  object(TRect)
                        ItemsNum     : byte;
                        Curr         : PRect;
                        Items        : PRect;
                        Constructor Init(ax1,ay1,ax2,ay2:integer);
                        Destructor  Done;                       Virtual;
                        Procedure   Draw(f:byte);               Virtual;
                        Procedure   Handler(Var Event:Word);    Virtual;
                        Procedure   NextItem(var aCurr:PRect);  Virtual;
                        Procedure   PrevItem(var aCurr:PRect);  Virtual;
                        Procedure   InsertItem( C:PRect;
                                              LastItem:Boolean);Virtual;
                        Procedure  ReInit;                      Virtual;

                       end;


Var
 CurrF10:PRect;
 P:TRect;
{____________________________}IMPLEMENTATION{________________________________}
{---------------------------- THorizontalItem -------------------------------}
Constructor THorItem.Init;
 Begin
  Inherited Init(ax1,ay1,ax2,ay2,False);
  Tx:=(X1+(x2-x1) div 2);
  Ty:=(Y1+(y2-y1) div 2);
  SetTextJustify(CenterText,CenterText);
  Header:=aHeader;
  SetColor(scFore);
  OutTextXY(Tx,Ty,Header);
  Draw(Common);
  WasOnMe:=false;
  MyConst:=Con;
  Next:=Nil;
  Next:=Nil
 End;
{----------------------------------------------------------------------------}
Destructor THorItem.Done;
 Begin
  Inherited Done
 End;
{----------------------------------------------------------------------------}
Procedure THorItem.Draw;
 var i:integer;
 Begin
  Case Select   of
   Common       : begin{Common view}
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
     end{case}
 End;
{----------------------------------------------------------------------------}
Procedure THorItem.Handler;
var
 PS,IS:PRect;
 i,j:integer;
 Begin
   Case Event Of
    MouseEvent   :  If MouseIn(X1,Y1,X2,Y2) then
                     Begin
                      If MouseIn(X2-12,Y1,X2,Y2) and MouseMove then
                       begin
                        For J:=Next^.Y1-1 to Next^.Y2+1 do
                         For i:=Next^.X1-1 to Next^.X1+4 do PutPixel(i,j,scBack)
                       end;
                      If Not WasOnMe then begin
                                          {Draw before common---------------}
                                          PS:=Next;
                                          IS:=Next^.Next;
                                          While IS^.Next^.Next<>PS do IS:=IS^.Next;
                                          IS^.Draw(Common);
                                          {---------------------------------}
                                           Draw(Selected);
                                           WasOnMe:=True
                                          end;
                      If MouseMove then begin
                                         {Draw before common---------------}
                                         PS:=Next;
                                         IS:=Next^.Next;
                                         While IS^.Next^.Next<>PS do IS:=IS^.Next;
                                         IS^.Draw(Common);
                                         {---------------------------------}
                                         HideMouse;
                                         Draw(Selected);
                                         ShowMouse;
                                        end;
                      If MouseButton = 1 then
                       begin
                        HideMouse;
                        Draw(Pressed);
                        Delay(Pause);
                        Result:=MyConst;
                        SetColor(scBack);
                        for i:=y1-1 to y2+1 do line(X1-1,i,x2+1,i);
                        SetColor(scFore);
                        SetTextJustify(CenterText,CenterText);
                        OutTextXY(Tx,Ty,Header);
                        Draw(Common);
                       end;
                      ClearEvent(Event)
                     End
                     else
                      Begin
                       If WasOnMe then
                       begin
                        Draw(Common);
                        WasOnMe:=False
                       end;
                      End;
    KeyboardEvent: If Not Extended then Case ScanCode of
                                         EnterKey: Begin
                                                   HideMouse;
                                                   Draw(Pressed);
                                                   Delay(Pause);
                                                   ClearEvent(Event);
                                                   Result:=MyConst;
                                                   Draw(Common);
                                                   end;
                                        end
                                      else
                                       case ScanCode of
                                         DownKey: Begin
                                                   HideMouse;
                                                   Draw(Pressed);
                                                   Delay(Pause);
                                                   ClearEvent(Event);
                                                   Result:=MyConst;
                                                   Draw(Common)
                                                   end;
                                        end;
    InternalEvent:  ;
   end
 End;

{--------------------------- THorizontalMenu --------------------------------}
Procedure THorizontalMenu.ReInit;
 begin
  Draw(Common);
  Delay(500)
 end;
{---------------------------------------------------------------------------}
Constructor THorizontalMenu.Init;
 var
  i :integer;
 begin
  Inherited Init(aX1,aY1,aX2,aY2,False);
  Items:=Nil;
  Curr:=Items;
  CurrF10:=Curr;
  SetColor(scBack);
  For i:=Y1 to Y2 do Line(X1,i,X1+6,i);
  Draw(Common)
 end;
{----------------------------------------------------------------------------}
Procedure THorizontalMenu.Handler;
var I,P:PRect;q:integer;
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
                               If EventClear(Event) then Exit
                                                    else I:=I^.Next
                              end;
                             I^.Handler(Event);
                          end;
                      {  If (Not EventClear(Event)) and
                            MouseMove then Draw(Common);}
                      end
                     else If MouseIn(X1,Y1,X2,Y2+10) then Draw(Common);
     KeyboardEvent : If Extended  then Case ScanCode of
                                        LeftKey :  If F10 then begin
                                                   Draw(0);
                                                   PrevItem(Curr);
                                                   ClearEvent(Event)
                                                   end;
                                        RightKey: If F10 then begin
                                                   Draw(0);
                                                   NextItem(Curr);
                                                   ClearEvent(Event)
                                                  end;
                                        DownKey : If F10 then
                                                   begin
                                                    Curr^.Handler(Event);
                                                    F10:=False  ;
                                                    ClearEvent(Event);
                                                    {WriteMouseAndSave ;
                                                    HideMouse}
                                                   end;
                                        F10key  :  If Not F10 then
                                                    begin
                                                     Draw(0);
                                                     Curr^.Draw(Selected);
                                                     CurrF10:=Curr;
                                                     F10:=True;
                                                     ClearEvent(Event)
                                                    end;
                                       end{Case}
                                  else Case ScanCode of
                                        EnterKey : Begin
                                                    If F10 then CurrF10^.Handler(Event);
                                                    F10:=False;
                                                    ClearEvent(Event)
                                                   end;
                                        EscKey   : begin
                                                    F10:=False;
                                                    I:=Items;
                                                    If I<>Nil then
                                                     Begin
                                                      While I^.Next<>Items do
                                                       begin
                                                        I^.Draw(Common);
                                                        I:=I^.Next
                                                       end;
                                                      I^.Draw(Common);
                                                     End;
                                                    ClearEvent(Event)
                                                   End
                                       End

    end;{Case}
  {If MouseMove then begin
     SetColor(scBack);
     Line(X1,Y2,X2,Y2);
   end;}
 end;{Handler}
{---------------------------------------------------------------------------}
Procedure THorizontalMenu.Draw;
 var
  P,I : PRect;
 begin
  Inherited Draw(Common);
  I:=Items;
  P:=I;
  If I<>Nil then
   begin
    while I^.Next<>p do
     begin
      I^.Draw(Common);
      I:=I^.Next;
     end;
   I^.Draw(Common);
  end
 end;

Destructor THorizontalMenu.Done;
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
      Dispose(Items,Done);
      Items:=I
     end;
    Dispose(Items,Done)
   end;
  Inherited Done;
 end;

Procedure THorizontalMenu.NextItem;
 begin
  Curr^.Draw(Common);
  Curr:=Curr^.Next;
  Curr^.Draw(Selected);
  CurrF10:=Curr
 end;

Procedure THorizontalMenu.PrevItem;
 Var I:Prect;
 begin
  I:=Curr;
  While I^.Next<>Curr do I:=I^.Next;
  Curr^.Draw(Common);
  Curr:=I;
  Curr^.Draw(Selected);
  CurrF10:=Curr
 end;

Procedure THorizontalMenu.InsertItem;
 var i:PRect;
 begin
  I:=Items;
  If Items=Nil then
   begin
    items:=c;
    If LastItem then Items^.Next:=Items
                Else Items^.Next:=Nil;
   end
  Else
   begin
    While I^.Next<>NIL do I:=I^.Next;
    I^.next:=C;
    I:=I^.Next;
    If LastItem then I^.Next:=Items
                Else I^.Next:=Nil;
   end;
  Curr:=Items;
 end;

END.
