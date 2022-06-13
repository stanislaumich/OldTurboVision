Unit UButton;
{================================}INTERFACE{=================================}
USES Crt,Graph,UApp,UMouse,UVermenu,URect,UConst,UEvent;
Const
 FocusedColor:integer=Blue;
TYPE
 Proc       =  Procedure;
 PButton    =  ^TButton;
 TButton    =   OBJECT(TRect)
                 Caption  :  String;
                 LastFoc  :  boolean;
                 Focused  :  boolean;
                 MyCommand:  Word;
                 CommandOnSetFocus,
                 CommandOnLostFocus:Word;
                Constructor Init(aX1,aY1,aX2,aY2:Integer;aCaption:string;
                                  aCommandOnSetFocus,
                                  aCommandOnLostFocus,
                                  aMyCommand:Word);
                Destructor  Done;                      Virtual;
                Procedure   Handler(var Event:Word);   Virtual;
                Procedure   Draw(F:Byte);              Virtual;
                END;{OBJECT}

{============================}IMPLEMENTATION{===============================}

Constructor TButton.Init;
 var
  xx2,yy2:integer;
 begin
  If (TextWidth(aCaption)>Ax2-Ax1) then
   xx2:=TextWidth(aCaption)+ax1+2 else XX2:=aX2;
  If (TextHeight(aCaption)>Ay2-Ay1) then
   yy2:=TextHeight(aCaption)+ay1+2 else YY2:=aY2;
  INHERITED Init(aX1,aY1,XX2,YY2,False);
  Caption:=aCaption;
  Focused:=False;
  LasTFoc:=Focused;
  CommandOnSetFocus:=aCommandOnSetFocus;
  CommandOnLostFocus:=aCommandOnLostFocus;
  MyCommand:=aMyCommand;
  Draw(0)
 end;

Destructor TButton.Done;
 begin
  Inherited Done
 end;

Procedure TButton.Handler;
 var i:integer;
 begin
  If MouseIn(x1,y1,x2,y2) then
   begin
    If Not LastFoc then
     begin
      Focused:=True;
      Result:=CommandOnSetFocus;
      Draw(0);
      LastFoc:=True
     end;
     Case Event of
      MouseEvent    : begin
                        If MouseButton=1 then
                         Begin
                          HideMouse;
                          Draw(1);
                          Result:=MyCommand;
                          Focused:=True;
                          Delay(Pause);
                          Draw(0);
                          WriteMouseAndSave;
                          ClearEvent(Event)
                         end;
                        If MouseMove then Draw(0)
                       end;
      KeyboardEvent : If  Not Extended and (ScanCode=EnterKey) then
                       Result:=MyCommand;
     end{Case}
   end{If Focused}
  else
   begin
    If MouseMove and MouseIn(x1-15,y1-15,x2+15,y2+15) then begin
                                                            Draw(0);
                                                            WriteMousePointer(MouseX,MouseY)
                                                           end;
    If LastFoc then
     begin
      Focused:=False;
      LastFoc:=False;
      Draw(0);
      Result:=CommandOnLostFocus
     end;
     Case Event of
      KeyboardEvent : If  Not Extended and (scanCode=EnterKey) and focused then
                       Result:=MyCommand
     end;{Case}
   end;
 end;{Handler}

Procedure TButton.Draw;
 var
  i:byte;
 begin
  If f=1 then
   begin   {Selected}
    SetColor(scBorderLeft);
    Line(x2+1,y2+1,x2+1,y1-1);
    Line(x2+1,y2+1,x1-1,y2+1);
    Line(x2,y2,x2,y1);
    Line(x2,y2,x1,y2);
    SetColor(scBorderRight);
    Line(x1-1,y1-1,x2+1,y1-1);
    Line(x1-1,y1-1,x1-1,y2+1);
    Line(x1,y1,x2,y1);
    Line(x1,y1,x1,y2);
   end
  else
   begin
    SetColor(scBorderRight);
    Line(x2+1,y2+1,x2+1,y1-1);
    Line(x2+1,y2+1,x1-1,y2+1);
    Line(x2,y2,x2,y1);
    Line(x2,y2,x1,y2);
    SetColor(scBorderLeft);
    Line(x1-1,y1-1,x2+1,y1-1);
    Line(x1-1,y1-1,x1-1,y2+1);
    Line(x1,y1,x2,y1);
    Line(x1,y1,x1,y2);
   end;
  SetColor(scFore);
  SetTextJustify(CenterText,CenterText);
  OutTextXY(x1+(X2-X1)div 2,Y1+(Y2-Y1)div 2,Caption)
 end;

END.