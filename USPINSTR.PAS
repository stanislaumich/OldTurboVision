Unit USpinStr;
{--------------------------------}INTERFACE{---------------------------------}
Uses UEvent,UConst,URect,UMouse,Graph,USpin,UInput;
TYPE
 PSpinStr   =  ^TSpinStr;
 TSpinStr   =  Object (TInput)
                Spin  :  Pspin;

Constructor Init(aX1,aY1,aX2,aY2:Integer;St:string;acFore,acBack:integer;
                 aVMin,StartValue,aVMax,aStep:Word;MyCommand:Word);
Destructor  Done;                              Virtual;
Procedure   Handler(Var Event:Word);           Virtual;
Procedure   Draw(F:Byte);                      Virtual;

End;


{-----------------------------}IMPLEMENTATION{-------------------------------}
Constructor TSpinStr.Init;
 begin
  Inherited Init(aX1,aY1,aX2-12,aY2,St,acFore,acBack);
  Spin:=New(PSpin,Init(aX2-9,aY1,aX2,aY2,aVMin,StartValue,aVMax,aStep,MyCommand));
  Draw(Common)
 end;
{----------------------------------------------------------------------------}
Destructor TSpinStr.Done;
 begin
  Spin^.Done;
  Inherited Done
 end;
{----------------------------------------------------------------------------}
Procedure TSpinStr.Draw;
 begin
  Spin^.Draw(Common);
  Str(Spin^.Value,WorkString);
  KursPos:=Length(WorkString)+1;
  KursX:=X1+TextWidth(WorkString)+2;
  SetColor(cBack);
  SetFillPattern(FillPattern,cBack);
  SetTextJustify(LeftText,CenterText);
  Bar(X1,Y1,X2,Y2);
  SetColor(cFore);
  OutTextXY(Tx,Ty,WorkString);
 end;
{----------------------------------------------------------------------------}
Procedure TSpinStr.Handler;
var
 St:string;
 C:integer;
 D:Word;
 begin
  Spin^.Handler(Event);
  Inherited Handler(Event);
  If Result=Spin^.Command then
   begin
    Result:=cmEmpty;
    Draw(Common)
   end;
  If MouseIn(Spin^.X1,Spin^.Y1,Spin^.X2,Spin^.Y2) and MouseMove then
   begin
    Val(St,D,C);
    If C=0 then Spin^.Value:=D
   end;
 end;
{----------------------------------------------------------------------------}
END.{------------------------------------------------------------------------}
