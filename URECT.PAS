Unit URect;
{--------------------------------}INTERFACE{---------------------------------}
Uses Graph,UMouse,UEvent,UConst;
{----------------------------------------------------------------------------}
Type
 PRect    =   ^TRect;
 TRect    =   object
               X1,X2,Y1,Y2   :    Integer;
               UpIm,DoIm     :    ^Word;
               Size          :    LongInt;
               Next          :    PRect;
               SaveFlag      :    Boolean;
               Header        :    Strin;
               Correct       :    Boolean;
Constructor Init(ax1,ay1,ax2,ay2:integer;SFlag:Boolean);
Destructor  Done;                                                     Virtual;
Procedure   Show;                                                     Virtual;
Procedure   Hide;                                                     Virtual;
Procedure   Draw(F:byte);                                             Virtual;
Procedure   Handler(Var Event:Word);                                  Virtual;
Procedure   InsertItem(C:PRect;LastItem:Boolean);                     Virtual;
Procedure   ReInit;                                                   Virtual;
Procedure   SetValue(Value:Longint) ;                                 Virtual;
              end;

{-----------------------------}IMPLEMENTATION{-------------------------------}
Procedure TRect.InsertItem;
 begin
 end;
{----------------------------------------------------------------------------}
Procedure TRect.Draw;
  var
  i:integer;
 begin
  If f=1 then
   begin   {Selected}
    SetColor(scBorderLeft);
    Line(x2+1,y2+1,x2+1,y1-1);
    Line(x2+1,y2+1,x1-1,y2+1);
    SetColor(scBorderRight);
    Line(x1-1,y1-1,x2+1,y1-1);
    Line(x1-1,y1-1,x1-1,y2+1);
   end
  else
   begin
    SetColor(scBorderRight);
    Line(x2+1,y2+1,x2+1,y1-1);
    Line(x2+1,y2+1,x1-1,y2+1);
    SetColor(scBorderLeft);
    Line(x1-1,y1-1,x2+1,y1-1);
    Line(x1-1,y1-1,x1-1,y2+1);
   end;
 end;
{----------------------------------------------------------------------------}
Procedure TRect.Show;
 begin
  If SaveFlag then begin
  GetImage(X1-1,Y1-1,X2+1,Y2+1,DoIm^);
  PutImage(X1-1,Y1-1, UpIm^, copyPut) end
 end;
{----------------------------------------------------------------------------}
Procedure TRect.Hide;
 begin
  If SaveFlag then
  PutImage(X1-1,Y1-1, DoIm^, copyPut)
 end;
{----------------------------------------------------------------------------}
Constructor TRect.Init;
 var
  i:integer;
 begin
  X1:=ax1;
  X2:=ax2;
  Y1:=ay1;
  Y2:=ay2;
  SaveFlag:=sFlag;
  If SaveFlag then
   begin
    Size:=ImageSize(X1-1,Y1-1,X2+1,Y2+1);
    GetMem(UpIm,Size);
    GetMem(DoIm,Size);
    GetImage(X1-1,Y1-1,X2+1,Y2+1,DoIm^);
   end;
  SetColor(scBack);
  For I:=Y1 to Y2 do Line(X1,i,X2,i);
  TRect.Draw(0);
  if SaveFlag then GetImage(X1-1,Y1-1,X2+1,Y2+1,UpIm^);
  Next:=nil
 end;
{----------------------------------------------------------------------------}
Procedure TRect.Handler;
 begin
 end;
{----------------------------------------------------------------------------}
Procedure TRect.ReInit;
 begin
 end;
{----------------------------------------------------------------------------}
Destructor TRect.Done;
 begin
  If SaveFlag then
   begin
    FreeMem(UpIm,Size);
    FreeMem(DoIm,Size);
   end
 end;

Procedure TRect.SetValue;
 begin

 end;
END.
