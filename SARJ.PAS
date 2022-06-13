Uses Dos,Crt,Graph,UApp,UVerMenu,UHorMenu,UMouse,UConst,UStatus,
     UEvent,UWind,UButton,UInput,UList,ULstItem,USpin,UProgres,URect;
{----------------------------------------------------------------------------}
                                    CONST
cmVerMenu1   = 1001;
cmVerMenu2   = 1002;
cmVerMenu3   = 1003;
cmVerMenu4   = 1004;
cmVerMenu5   = 1005;
cmVerMenu6   = 1006;
cmVerMenu7   = 1007;
cmVerMenu8   = 1008;
cmVerMenu9   = 1009;
cmAbout      = 1010;
{----------------------------------------------------------------------------}
                                    TYPE
 MyApp  = Object(TApplication)
           Constructor   Init;
           Destructor    Done;
           Procedure     Handler(Var Event:Word);  Virtual;
           Procedure     VMenu1;
           Procedure     VMenu2;
           Procedure     VMenu3;
           Procedure     VMenu4;
           Procedure     Idle;                     Virtual;
          end;{of object MyApp}
 PMyApp = ^MyApp;
{----------------------------------------------------------------------------}
                                    VAR
P                      : PMyApp;
PMaxX,PMaxY            : Integer;
Sq,Hq,Mq               : Integer;
PProg                  : PRect;
Pos                    : integer;
{----------------------------------------------------------------------------}

Procedure MyApp.Idle;  {Out time}
 var
  h,m,s,s1 : Word;
  STime,st : String;
  I        : Integer;
 begin
  GetTime(H,M,S,s1);
  If Hq<>H then
   begin
    SetTextJustify(LeftText,CenterText);
    Str(H,Stime);
    STime:=STime+':';
    If Byte(STime[0])=1 then STime:='0'+STime;
    SetColor(scBack);
    OutTextXY(Pos+i,StatusLine^.Ty,#255#255#255);
    SetColor(scFore);
    OutTextXY(Pos,StatusLine^.Ty,STime);
    Hq:=H
   end;
   If Mq<>M then
   begin
    SetTextJustify(LeftText,CenterText);
    Str(M,Stime);
    If Byte(STime[0])=1 then STime:='0'+STime;
    STime:=STime+':';
    SetColor(scBack);
    OutTextXY(Pos+15,StatusLine^.Ty,#255#255#255);
    SetColor(scFore);
    OutTextXY(Pos+15,StatusLine^.Ty,STime);
    Mq:=M
   end;
   If Sq<>S then
   begin
    SetTextJustify(LeftText,CenterText);
    Str(S,Stime);
    If Byte(STime[0])=1 then STime:='0'+STime;
    SetColor(scBack);
    OutTextXY(Pos+30,StatusLine^.Ty,#255#255#255);
    SetColor(scFore);
    OutTextXY(Pos+30,StatusLine^.Ty,STime);
    Sq:=S
   end
end;
{----------------------------------------------------------------------------}
Constructor MyApp.Init;
 var
  i,j:integer;
 begin
  HideMouse;
  Inherited Init;
  Pos:=MaxX-52;
  InsertMenu(New(PHorizontalMenu,Init(1,1,MaxX-2,19)));
  With SystemMenu^ do begin
   InsertItem(New(PHorItem,Init(3,3,63,17,    'Файл',     cmVerMenu1)),NotLast);
   InsertItem(New(PHorItem,Init(67,3,127,17,  'Архивация',cmVerMenu2)),NotLast);
   InsertItem(New(PHorItem,Init(131,3,191,17, 'Сервис',   cmVerMenu3)),NotLast);
   InsertItem(New(PHorItem,Init(195,3,255,17, 'Помощь',cmVerMenu4)),Last);
   ReInit;
  end;
  StatusLine:=New(PStatusLine,Init(1,MaxY-20,MaxX-1,MaxY-1));
  PMaxX:=MaxX;
  PMaxY:=MaxY-22;
  PProg:=New(PProgressBar,Init(MaxX-150,MaxY-16,MaxX-60,MaxY-6,PMaxY));
  InsertStatic(PProg);
 end;

Procedure MyApp.VMenu1; {file}
 Var
  M:PVerticalMenu;
 begin
  M:=New(PVerticalMenu,Init(1,22,126,77));
  M^.InsertItem(New(PVerItem,Init(3,24,124,39,'Вывести список    Alt-L',cmEmpty)),   NotLast);
  M^.InsertItem(New(PVerItem,Init(3,42,124,57,'Изменить каталог Alt-D',cmEmpty)),NotLast);
  M^.InsertItem(New(PVerItem,Init(3,60,124,75,'Выход                    Alt-X',cmExit)),    Last);
  M^.ReInit;
  InsertModal(M);
  Result:=cmEmpty;
  WriteMouseAndSave
 end;

Procedure MyApp.VMenu2;    {archive}
 Var
  M:PVerticalMenu;
 begin
  M:=New(PVerticalMenu,Init(65,22,210,95));
  M^.InsertItem(New(PVerItem,Init(67,24,208,39,'Архивировать'      ,cmEmpty )),NotLast);
  M^.InsertItem(New(PVerItem,Init(67,42,208,57,'Разархивировать'   ,cmEmpty )),NotLast);
  M^.InsertItem(New(PVerItem,Init(67,60,208,75,'Сведения об архиве',cmEmpty )),NotLast);
  M^.InsertItem(New(PVerItem,Init(67,78,208,93,'aaaaaaa',           cmEmpty)),Last);
  M^.ReInit;
  InsertModal(M);
  Result:=cmEmpty;
  ShowMouse
 end;

Procedure MyApp.VMenu3;  {servise}
 Var
  M:PVerticalMenu;
 begin
  M:=New(PVerticalMenu,Init(129,22,239,131));
  M^.InsertItem(New(PVerItem,Init(131,24,237,39,  '',cmEmpty )),NotLast);
  M^.InsertItem(New(PVerItem,Init(131,42,237,57,  '',cmEmpty )),NotLast);
  M^.InsertItem(New(PVerItem,Init(131,60,237,75,  '',cmEmpty )),NotLast);
  M^.InsertItem(New(PVerItem,Init(131,78,237,93,  '',cmEmpty )),NotLast);
  M^.InsertItem(New(PVerItem,Init(131,96,237,111, '',cmEmpty )),NotLast);
  M^.InsertItem(New(PVerItem,Init(131,114,237,129,'',cmEmpty )),Last);
  M^.ReInit;
  InsertModal(M);
  Result:=cmEmpty;
  ShowMouse
 end;

Procedure MyApp.VMenu4;{help}
 Var
  M:PVerticalMenu;
 begin
  M:=New(PVerticalMenu,Init(193,22,300,113));
  M^.InsertItem(New(PVerItem,Init(195,24,298,39,'Об авторе',cmAbout )),NotLast);
  M^.InsertItem(New(PVerItem,Init(195,42,298,57,'',         cmEmpty )),NotLast);
  M^.InsertItem(New(PVerItem,Init(195,60,298,75,'',         cmEmpty )),NotLast);
  M^.InsertItem(New(PVerItem,Init(195,78,298,93,'',         cmEmpty )),NotLast);
  M^.InsertItem(New(PVerItem,Init(195,96,298,111,'',        cmEmpty )),Last);
  M^.ReInit;
  InsertModal(M);
  Result:=cmEmpty;
  ShowMouse
 end;
{----------------------------------------------------------------------------}
Procedure SetWindowForAbout;
 var
  Height,Width  :  Word;
  X0,Y0         :  Word;
  V             :  PWindow;
 begin
  Width:=(MaxX+1) div 2;
  Height:=(MaxY+1) div 3;
  X0:=((MaxX+1)div 2)-(Width div 2);
  Y0:=((MaxY+1)div 2)-(Height div 2);
  P^.DoneModal;
  DoneModalF:=False;
  V:=New(PWindow,Init(X0,Y0,X0+Width,Y0+Height,'Об авторе'));
  V^.InsertCommand(New(PButton,Init(265,Y0+Height-20,315,Y0+Height-5,'Ok',   cmEmpty,cmEmpty,cmAbortModal)));
  V^.InsertCommand(New(PButton,Init(325,Y0+Height-20,375,Y0+Height-5,'Выход',cmEmpty,cmEmpty,cmAbortModal)));
  P^.InsertModal(V);
  ClearEvent(Event);
  Result:=cmEmpty;
 end;
{----------------------------------------------------------------------------}
Procedure MyApp.Handler;
 begin
  Inherited Handler(Event);
  Case Result of
   cmVerMenu1   : VMenu1;
   cmVerMenu2   : VMenu2;
   cmVerMenu3   : VMenu3;
   cmVerMenu4   : VMenu4;
   cmAbout      : SetWindowForAbout;
   cmAbortModal : begin
                   DoneModalF:=True;
                   WriteMouseAndSave;
                   Result:=cmEmpty
                  end;
  end;
 end;

Destructor MyApp.Done;
 begin
  Inherited Done;
  CloseGraph
 end;
{----------------------------------------------------------------------------}

begin
 P:=New(PMyApp,Init);
 P^.Run;
 P^.Done;
end.
