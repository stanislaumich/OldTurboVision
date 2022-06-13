{$R-}
Unit UWind;
{--------------------------------}INTERFACE{---------------------------------}
Uses UConst,Graph,UMouse,URect,UEvent,UButton;
Type
 PWindow    =  ^TWindow;
 TWindow    =  object(TRect)
                HeaderHeight    :   Integer;
                Commands        :   PRect;
                Tx,Ty           :   Integer;
                TextStr         :   String;
                Constructor Init(ax1,ay1,ax2,ay2:integer;aHeader:String);
                Procedure  Handler(var Event:Word);      Virtual;
                Destructor Done;                         Virtual;
                Procedure  Draw(F:Byte);                 Virtual;
                Procedure  InsertCommand( C:PRect);      Virtual;
                Procedure  SendEvent(var Event:Word);    Virtual;
                Procedure  Text(aText:string);
               end;



{-----------------------------}IMPLEMENTATION{-------------------------------}
Constructor TWindow.Init;
 begin
  HideMouse;
  HideMouse;
  Inherited Init(ax1,ay1,ax2,ay2,True);
  Tx:=X1+((X2-X1)div 2);
  Ty:=Y1+25;
  HeaderHeight := TextHeight(AHeader)+2;
  Header := aHeader;
  Draw(0);
  Commands:=Nil;
  WriteMouseAndSave
 end;

Destructor TWindow.Done;
 Var
  P:PRect;
 begin
  Hide;
  While Commands<>NIL do
   begin
    P:=Commands^.Next;
    Dispose(Commands,Done);
    Commands:=P
   end;
    {Dispose(Commands,Done)}
  Inherited Done
 end;

Procedure TWindow.Draw;
 Var i:byte;
 begin
  Inherited Draw(0);
  (*SetColor(scBorderLeft);
  Line(x2{-1},y2{-1},x2{-1},y1{+1}+HeaderHeight);
  Line(x2{-1},y2{-1},x1{+1},y2{-1});
  SetColor(scBorderRight);
  Line(x1{+1},y1{+1}+HeaderHeight,x2{-1},y1{+1}+HeaderHeight);
  Line(x1{+1},y1{+1}+HeaderHeight,x1{+1},y2{-1});*)
  SetColor(HeaderBackColor);
  For i:=Y1 to Y1+HeaderHeight-1 do Line(x1,i,x2-1,i);
  SetColor(HeaderForeColor);
  Line(X1,Y1+HeaderHeight,X2,Y1+HeaderHeight);
  SetTextJustify(LeftText,CenterText);
  OutTextXY(x1+4,Y1+(HeaderHeight div 2)-1,Header);
  SetColor(scBack);
  For i:=Y1+HeaderHeight+1 to Y2 do Line(x1,i,x2-1,i);
 end;

Procedure TWindow.SendEvent;
 var
  P  :  PRect;
 begin
  P:=Commands;
  While P<>Nil do
   begin
    P^.Handler(Event);
    P:=P^.Next
   end;
 ClearEvent(Event)
 end;

Procedure TWindow.Handler;
 begin
  Case Event of
   MouseEvent   :begin
                  If MouseIn(X1+2,Ty-6,X2-2,Ty+12)and MouseMove then{For text redrawing}
                   begin
                    SetTextJustify(CenterText,CenterText);
                    SetColor(scFore);
                    OutTextXy(Tx,Ty,TextStr)
                   end;
                 end ;
   KeyboardEvent:begin
                  If Extended then
                   {Case ScanCode of

                   end}
                  Else Case ScanCode of
                   EscKey : DoneModalF:=True;
                   TabKey:;
                  end
                 end ;
   InternalEvent: ;
  end;{Case Event}
  SendEvent(Event);
 end;

Procedure TWindow.InsertCommand;
 var
  P:PRect;
 begin
  If Commands=NIL then Commands:=C
   else
    begin
     P:=Commands;
     If P^.Next<>NIL then
      begin
       {P:=P^.Next;
       While P^.Next<>NIL do
        P:=P^.Next}
       Repeat
        P:=P^.Next
       until P^.Next=Nil
      end;
     P^.Next:=C
    end
 end;
{----------------------------------------------------------------------------}
Procedure Twindow.Text;
 begin
  SetTextJustify(CenterText,CenterText);
  TextStr:=aText;
  OutTextXy(Tx,Ty,aText)
 end;
END.