{$R-}
Unit UInput;
{--------------------------------}INTERFACE{---------------------------------}
Uses Crt,Graph,UConst,URect,UEvent,UMouse;
TYPE
 PInput   =  ^TInput;
 TInput   =  OBJECT(TRect)
                 WorkString : String;
                 cFore,cBack: Integer;
                 Tx,Ty      : Integer;
                 KursPos : Byte;{Position in string}
                 KursX      : Integer;
                 KursY      : Integer;
                FillPattern : FillPatternType;
                 Focused    : Boolean;
Constructor Init(aX1,aY1,aX2,aY2:Integer;St:string;acFore,acBack:integer);
Destructor  Done;                             Virtual;
Procedure   Handler(Var Event:Word);          Virtual;
Function    GetString       : String;
Function    GetStringAsReal : Real;
Function    GetStringAsWord : Word;
Procedure   Draw(F:Byte);                     Virtual;
                end;{OBJECT}



{-----------------------------}IMPLEMENTATION{-------------------------------}
Constructor TInput.Init;
 begin
  X1:=aX1;
  X2:=aX2;
  Y1:=aY1;
  Y2:=aY2;
  Inherited Draw(1);
  Tx:=X1+4;
  Ty:=Y1+((Y2-Y1)div 2);
  cFore:=acFore;
  cBack:=acBack;
  WorkString:=St;
  If WorkString='' then WorkString:=' ';
  SetColor(cBack);
  GetFillPattern(FillPattern);
  SetFillPattern(FillPattern,cBack);
  Bar(X1,Y1,X2,Y2);
  SetColor(cFore);
  SetTextJustify(LeftText,CenterText);
  OutTextXY(Tx,Ty,WorkString);
  KursPos:=Length(WorkString)+1;
  KursX:=X1+TextWidth(WorkString)+2;
  KursY:=Ty;
  {OutTextXY(KursX,KursY,Kursor);}
  Kursor:=Kurs1;
  Focused:=False;
  Next:=NIL;
  InsMode:=True
 end;
{----------------------------------------------------------------------------}
Destructor TInput.Done;
 begin

 end;
{----------------------------------------------------------------------------}
Procedure TInput.Handler;
{KursPos : Byte;Position in string}
 begin
  SetTextJustify(LeftText,CenterText);
  Case Event Of
   MouseEvent    : If Not Focused And MouseIn(X1,Y1,X2,Y2)And(MouseButton=1) then
                    begin
                     SetColor(cFore);
                     OutTextXY(KursX,KursY,Kursor);
                     Focused:=True
                    end
                    Else If Focused and Not MouseIn(X1,Y1,X2,Y2)and(MouseButton=1) then
                     begin
                      Focused:=False;
                      SetColor(cBack);
                      OutTextXY(KursX,KursY,Kursor);
                     end;
   KeyboardEvent : If Focused then
                    begin
                     If Extended then
                      Case ScanCode of
                       RightKey   :  IF KursPos<Length(WorkString)+1 then
                                      begin
                                       SetColor(cBack);
                                       OutTextXY(KursX,KursY,Kursor);
                                       KursX:=KursX+TextWidth(WorkString[KursPos]);
                                       SetColor(cFore);
                                       OutTextXY(KursX,KursY,Kursor);
                                       Inc(KursPos)
                                      end;
                        LeftKey   : IF KursPos>1 then
                                     begin
                                       SetColor(cBack);
                                       OutTextXY(KursX,KursY,Kursor);
                                       KursX:=KursX-TextWidth(WorkString[KursPos-1]);
                                       SetColor(cFore);
                                       OutTextXY(KursX,KursY,Kursor);
                                       Dec(KursPos)
                                     end;
                        EndKey    : begin
                                     SetColor(cBack);
                                     OutTextXY(KursX,KursY,Kursor);
                                     KursPos:=Length(WorkString);
                                     KursX:=X1+TextWidth(WorkString)+2;
                                     SetColor(cFore);
                                     OutTextXY(KursX,KursY,Kursor);
                                    end;
                        DelKey    :begin
                                    SetColor(cBack);
                                    OutTextXY(KursX,KursY,Kursor);
                                    Delete(WorkString,KursPos,1);
                                    SetColor(cBack);
                                    SetFillPattern(FillPattern,cBack);
                                    Bar(X1,Y1,X2,Y2);
                                    SetColor(cFore);
                                    SetTextJustify(LeftText,CenterText);
                                    OutTextXY(Tx,Ty,WorkString);
                                    OutTextXY(KursX,KursY,Kursor);
                                   end;
                        HomeKey   :begin
                                    SetColor(cBack);
                                    OutTextXY(KursX,KursY,Kursor);
                                    KursX:=Tx-2;
                                    KursPos:=1;
                                    SetColor(cFore);
                                    OutTextXY(KursX,KursY,Kursor);
                                   end;
                        InsKey    : If InsMode then
                                                begin
                                                 SetColor(cBack);
                                                 OutTextXY(KursX,KursY,Kursor);
                                                 InsMode := Not InsMode;
                                                 Kursor:=Kurs2;
                                                 SetColor(cFore);
                                                 OutTextXY(KursX,KursY,Kursor)
                                                end
                                               else
                                                begin
                                                 SetColor(cBack);
                                                 OutTextXY(KursX,KursY,Kursor);
                                                 InsMode := Not InsMode;
                                                 Kursor:=Kurs1;
                                                 SetColor(cFore);
                                                 OutTextXY(KursX,KursY,Kursor)
                                                end;
                      end{Case}
                     Else
                      Case ScanCode Of
                        BackKey   :  IF KursPos>1 then
                                      begin
                                       SetColor(cBack);
                                       OutTextXY(KursX,KursY,Kursor);
                                       KursX:=KursX-TextWidth(WorkString[KursPos-1]);
                                       Dec(KursPos);
                                       Delete(WorkString,KursPos,1);
                                       SetColor(cBack);
                                       SetFillPattern(FillPattern,cBack);
                                       Bar(X1,Y1,X2,Y2);
                                       SetColor(cFore);
                                       SetTextJustify(LeftText,CenterText);
                                       OutTextXY(Tx,Ty,WorkString);
                                       OutTextXY(KursX,KursY,Kursor);
                                      end;
                       EnterKey   :  ;
                         EscKey   :  ;
                       Else If InsMode then
                                        begin
                                         If (TextWidth(WorkString)+7+X1<X2)
                                          then
                                           begin
                                            SetColor(cBack);
                                            OutTextXY(KursX,KursY,Kursor);
                                            Insert(CharCode,WorkString,KursPos);
                                            KursX:=KursX+TextWidth(WorkString[KursPos]);
                                            Inc(KursPos);
                                            SetColor(cBack);
                                            SetFillPattern(FillPattern,cBack);
                                            Bar(X1,Y1,X2,Y2);
                                            SetColor(cFore);
                                            SetTextJustify(LeftText,CenterText);
                                            OutTextXY(Tx,Ty,WorkString);
                                            OutTextXY(KursX,KursY,Kursor);
                                           end
                                          end
                                       else If (KursX<X2-5)
                                        then
                                         begin
                                          SetColor(cBack);
                                          OutTextXY(KursX,KursY,Kursor);
                                          If KursPos<=Length(WorkString)then
                                           WorkString[KursPos]:=CharCode
                                          else
                                           WorkString:=WorkString+CharCode;
                                           {Insert(CharCode,WorkString,Length(WorkString));}
                                          KursX:=KursX+TextWidth(WorkString[KursPos]);
                                          Inc(KursPos);
                                          SetColor(cBack);
                                          SetFillPattern(FillPattern,cBack);
                                          Bar(X1,Y1,X2,Y2);
                                          SetColor(cFore);
                                          SetTextJustify(LeftText,CenterText);
                                          OutTextXY(Tx,Ty,WorkString);
                                          OutTextXY(KursX,KursY,Kursor);
                                         end
                                       end{If Focused}
                    end{Case};
   InternalEvent :  ;
  end
 end;
{----------------------------------------------------------------------------}
Function TInput.GetString;
 Var
  Code:Integer;
 begin
  Correct:=True;
  GetString := WorkString
 end;
{----------------------------------------------------------------------------}
Function TInput.GetStringAsReal;
 Var
  Code : Integer;
  R    : Real;
 begin
  Val(WorkString,R,Code);
  Correct:=(Code=0);
  If Correct then GetStringAsReal := R
             else GetStringAsReal := 0.0

 end;
{----------------------------------------------------------------------------}
Function TInput.GetStringAsWord;
 Var
  Code : Integer;
  W    : Word;
 begin
  Val(WorkString,W,Code);
  Correct:=(Code=0);
  If Correct then GetStringAsWord := W
             else GetStringAsWord := 0
 end;
{----------------------------------------------------------------------------}
Procedure TInput.Draw;
 begin
  Inherited Draw(1);
  SetColor(cBack);
  SetFillPattern(FillPattern,cBack);
  Bar(X1,Y1,X2,Y2);
  SetColor(cFore);
  SetTextJustify(LeftText,CenterText);
  OutTextXY(Tx,Ty,WorkString);
 end;
END.{------------------------------------------------------------------------}