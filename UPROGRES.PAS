Unit UProgres;
{--------------------------------}INTERFACE{---------------------------------}
Uses Crt,Graph,UMouse,UInput,UConst,UEvent;
TYPE
   PProgressBar  =  ^TProgressBar;
   TProgressBar  =  Object(TInput)
     VMax        :  Longint;
     VCurr       :  Longint;
     Step        :  Real;

Constructor Init(aX1,aY1,aX2,aY2:Integer;aVMax:Longint);
Destructor  Done;                                      Virtual;
Procedure   Draw(F:Byte);                              Virtual;
Procedure   Handler(Var Event:Word);                   Virtual;
Procedure   SetValue(aVCurr:Longint);                  Virtual;
   end;


{------------------------------}IMPLEMENTATION{------------------------------}
Constructor TProgressBar.Init;
 begin
  VMax:=aVMax;
  VCurr:=0;
  Inherited Init(aX1,aY1,aX2,aY2,'',Blue,White);
  Step:=(X2-X1)/VMax;
  Next:=NIL
 end;
{----------------------------------------------------------------------------}
Destructor TProgressBar.Done;
 begin
  Inherited Done
 end;
{----------------------------------------------------------------------------}
Procedure TProgressBar.Draw;
 begin
  SetFillPattern(ListPattern,scFore);
  Bar(X1,Y1,X1+Round(Step*VCurr),Y2)
 end;
{----------------------------------------------------------------------------}
Procedure TProgressBar.SetValue;
 begin
  If aVCurr>0 then
   begin
   VCurr:=aVCurr;
   Draw(0)
  end
  else
   begin
    VCurr:=0;
    SetFillPattern(ListPattern,lcBack);
    Bar(X1,Y1,X2,Y2)
   end
 end;
{----------------------------------------------------------------------------}
Procedure TProgressBar.Handler;
 begin
  Case Event of
   MouseEvent : If MouseIn(X1,Y1,X2,Y2) and MouseMove then
                 begin
                  Draw(Pressed);
                  ClearEvent(Event)
                 end
  end;
 end;
END.{------------------------------------------------------------------------}






