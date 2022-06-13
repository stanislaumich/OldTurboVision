Unit USpin;
{--------------------------------}INTERFACE{---------------------------------}
Uses UEvent,UConst,URect,UMouse,Graph,UButton;
Const
 UpPressed=99;
 DoPressed=98;
TYPE
 PSpin   =  ^TSpin;
 TSpin   =  Object (TRect)
             Value         :  LongInt;
             VMin,VMax     :  LongInt;
             Step          :  LongInt;
             UpBut,DoBut   :  PButton;
             Command       :  Word;
Constructor Init(aX1,aY1,aX2,aY2:Integer;aVMin,StartValue,aVMax,aStep:Word;MyCommand:Word);
Destructor  Done;Virtual;
Procedure   Handler(Var Event:Word);Virtual;
Procedure   Draw(F:Byte);Virtual;
Procedure   CheckCommand;Virtual;
End;


{-----------------------------}IMPLEMENTATION{-------------------------------}
Constructor TSpin.Init;
 begin
  X1:=aX1;
  X2:=aX2;
  Y1:=aY1;
  Y2:=aY2;
  If Not Odd(Y2-Y1) then Inc(Y2);
  Value:=StartValue;
  VMax:=aVMax;
  VMin:=aVMin;
  Step:=aStep;
  UpBut:=New(PButton,Init(X1,Y1,X2,Y1+((Y2-Y1)DIV 2)-1,#4,cmEmpty,cmEmpty,UpPressed));
  DoBut:=New(PButton,Init(X1,Y1+((Y2-Y1)DIV 2)+2,X2,Y2,#3,cmEmpty,cmEmpty,DoPressed));
  Command:=MyCommand;
  Draw(Common);
  Next:=NIL
 end;
{----------------------------------------------------------------------------}
Destructor TSpin.Done;
 begin
  UpBut^.Done;
  DoBut^.Done;
 end;
{----------------------------------------------------------------------------}
Procedure TSpin.Draw;
 begin
  UpBut^.Draw(Common);
  DoBut^.Draw(Common);
 end;
{----------------------------------------------------------------------------}
Procedure TSpin.Handler;
 begin
  Case Event Of
   MouseEvent : If MouseIn(X1,Y1,X2,Y2) and MousePressed then
                 begin
                  UpBut^.Handler(Event);
                  DoBut^.Handler(Event);
                  Case Result of
                   DoPressed: If (Value-Step)>=VMin then Value:=Value-Step;
                   UpPressed: If (Value+Step)<=VMax then Value:=Value+Step;
                  end;{Case}
                  Result:=Command
                 end;
  end
 end;
{----------------------------------------------------------------------------}
Procedure TSpin.CheckCommand;
 begin
  Case Result of
   DoPressed: If (Value-Step)>=VMin then Value:=Value-Step;
   UpPressed: If (Value+Step)<=VMax then Value:=Value+Step;
  end{Case}
 end;
END.{------------------------------------------------------------------------}
