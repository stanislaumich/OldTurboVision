{$A+,B-,D+,E-,F-,G+,I+,L+,N-,P-,Q-,R-,S+,T-,V+,X+,Y+}
Unit UApp;
{--------------------------------}INTERFACE{--------------------------------}
Uses Crt,Graph,URect,UMouse,UEvent,UHorMenu,UVerMenu,UConst,UStatus;
Const
 ExitCondition : Boolean =  False;
 MaxX          : Integer = 639;
 MaxY          : Integer = 479;
{----------------------------------}TYPE{-----------------------------------}
  PApplication  =  ^TApplication;
  TApplication  =  OBJECT
                    PStaticObjects   :  PRect;
                    PModalObjects    :  PRect;
                    Modal            :  Boolean;
                    SystemMenu       :  PHorizontalMenu;
                    StatusLine       :  PStatusLine;
                    Constructor INIT;
                    Destructor  DONE;
                    Procedure   SHUT;
                    Procedure   InsertStatic(Var Com:PRect);
                    Procedure   InsertModal(Com:PRect);
                    Procedure   InsertMenu(Com:PHorizontalMenu);
                    Procedure   DoneModal;
                    Procedure   Run;
                    Procedure   Handler(Var Event:Word);   virtual;
                    Procedure   Idle;                      Virtual;
                   END;

Var Event  :   Word;


{----------------------------}IMPLEMENTATION{-------------------------------}
Constructor TApplication.Init;
 Var
  w: array[1..4] of PointType ;
  i:integer;
 begin
  First:=True;
  GetDefaultPalette(Pal);
  GetFillPattern(ListPattern);
  DoneModalF:=False;
  MaxX:=GetMaxX;
  MaxY:=GetMaxY;
  PModalObjects :=NIL;
  PStaticObjects:=NIL;
  SystemMenu:=NIL;
  StatusLine:=NIL;
  Modal:=False;
  SetTextStyle(SmallFont,HorizDir,4);
  SetStepToPixel(4,4);
  InsMode:=False;
  Result:=$FFFF;
  MouseWindow(0,0,MaxX,MaxY)
 end;
{----------------------------------------------------------------------------}
Destructor  TApplication.Done;
 Var
  P:PRect;
 begin
  If PModalObjects<>NIL then Dispose(PModalObjects, Done);
  If SystemMenu   <>NIL then Dispose(SystemMenu,Done);
  If StatusLine   <>Nil then Dispose(StatusLine,Done);
  If PStaticObjects<>NIL then
   begin
    While PStaticObjects^.Next<>NIL do
     begin
      P:=PStaticObjects^.Next;
      Dispose(PStaticObjects,Done);
      PStaticObjects:=P
     end;
    Dispose(PStaticObjects)
   end;
  DoneMouse;
  CloseGraph
 end;
{----------------------------------------------------------------------------}
Procedure   TApplication.SHUT;
 begin
 end;
{----------------------------------------------------------------------------}
Procedure TApplication.InsertStatic;
 var
  P:PRect;
 begin
  P:=PStaticObjects;
  If P<>NIL then
   begin
    While P^.Next<>NIL do P:=P^.Next;
    P^.Next:=Com
   end
  else PStaticObjects:=Com
 end;
{----------------------------------------------------------------------------}
Procedure TApplication.InsertModal;
 begin
  Modal:=True;
  If PModalObjects = NIL then PModalObjects:=Com
                         else Exit
 end;
{----------------------------------------------------------------------------}
Procedure TApplication.DoneModal;
 begin
  HideMouse;
  Modal:=False;
  If PModalObjects = NIL then Exit
                        Else
                         Begin
                          {PModalObjects^.Hide;}
                          Dispose(PModalObjects, Done);
                          PModalObjects := Nil
                         end;
  ClearEvent(Event);
  WriteMouseAndSave
 end;
{----------------------------------------------------------------------------}
Procedure TApplication.Handler;
VAR p:PRect;
 begin
  If Modal then
   begin
    PModalObjects^.Handler(Event);
    If (SystemMenu<>Nil)and(MouseMove) then
    With SystemMenu^ do
      If MouseIn(X1,Y1,X2,Y2+2) then Draw(Common);
   end
  else
   begin
    SystemMenu^.Handler(Event);
    If Not EventClear(Event) then
     Begin
      P:=PStaticObjects;
      if P<>NIL then
       begin
        While P^.next<>Nil do
         begin
          P^.Handler(Event);
          P:=P^.Next
         end;
        P^.Handler(Event)
       end
     End
   end; {поправить тут мышу}
   If (Result=cmEmpty)and(MouseMove) then
    begin
     SetColor(scBack);
     Line(SystemMenu^.X1,SystemMenu^.Y2,SystemMenu^.X2,SystemMenu^.Y2);
    end;
   If Result = cmEmpty then WriteMousePointer(MouseX,MouseY);
   If Result = cmExit  then ExitCondition:=True;
 end;
{`````````````````````````````Procedure Run`````````````````````````````````}

Procedure TApplication.Run;
 Var
  C:char;
  P:PRect;
  M:PVerticalMenu;
  i:integer;
 Begin
  {If SystemMenu<>NIL then SystemMenu^.Draw(0);}
  repeat
   Mouse;
   Event:= MouseEvent;
     While KeyPressed Do
      begin
       Event:=KeyboardEvent;
       C:=ReadKey;
       if C=#0 then
        begin
         Extended:=True;
         ScanCode:=byte(ReadKey);
        end
       else
        begin
         Extended:=False;
         ScanCode:=Byte(C);
         CharCode:=C
        end
    end;
   If Extended and (ScanCode=AltXKey) and (Event=MouseEvent) then ExitCondition:=True
   else
    begin
   Handler(Event);
   If DoneModalF then
    begin
     DoneModalF:=False;
     DoneModal
    end;
   If First then
    begin
     SetColor(scBack);
     For i:=SystemMenu^.Y1 to SystemMenu^.Y2 do Line(SystemMenu^.X1,i,SystemMenu^.X1+12,i);
     First:=False;
    end;
   end;
   Idle
  until ExitCondition;
 end;

Procedure TApplication.InsertMenu;
 begin
  SystemMenu:=Com
 end;

Procedure TApplication.Idle;
 begin
 end;
END.

