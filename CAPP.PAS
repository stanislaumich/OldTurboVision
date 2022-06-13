Uses Dos,Crt,Graph,UApp,UVerMenu,UHorMenu,UMouse,UConst,UStatus,
     UEvent,UWind,UButton,UInput,UList,ULstItem,USpin,UProgres,URect;
{----------------------------------------------------------------------------}
CONST                   {Error in UInput if Щщ printing under kursor}
cmVerMenu1   = 1001;
cmVerMenu2   = 1002;
cmVerMenu3   = 1003;
cmVerMenu4   = 1004;
cmVerMenu5   = 1005;      {Error in USpinStr when Mouse Move under }
cmVerMenu6   = 1006;      { and doesn't change Spin^.Value if Input change}
cmVerMenu7   = 1007;
cmVerMenu8   = 1008;
cmVerMenu9   = 1009;
cmGuli       = 1501;
cmMandelbrot = 1502;
cmRedPalette   =1503;
cmGreenPalette =1504;
cmBluePalette  =1505;
cmCommonPalette=1506;
cmWindowForM   =1010;
cmChangeM      =1011;
cmChangeOXY    =1012;
cmWindowForChangeOXY    = 1013;
cmChangeOPQ             = 1014;
cmWindowForChangeOPQ    = 1015;
cmWindowForChangeColors = 1016;
cmChangeColors          = 1017;
cmLoadFile              = 1018;
cmSpinCommand           = 1019;
{}
cm1=1;
cm2=2;
cm3=3;
{}
VAR
tmpV : LongInt;
Sq,Hq,Mq: Integer;
V    : PWindow;
ChangeMInput,
ChangeOXMinInput,ChangeOYMinInput,
ChangeOXMaxInput,ChangeOYMaxInput,
ChangeOPMinInput,ChangeOQMinInput,
ChangeOPMaxInput,ChangeOQMaxInput,
ChangeColorsInput:PInput;
PProg:PRect;
S:PList;
Pos:integer;
{----------------------------------------------------------------------------}
TYPE
 MyApp  = Object(TApplication)
           Constructor Init;
           Destructor  Done;
           Procedure Handler(Var Event:Word);                         Virtual;
           Procedure VMenu1;
           Procedure VMenu2;
           Procedure VMenu3;
           Procedure VMenu4;
           Procedure Idle;                                            Virtual;
          end;
 PMyApp = ^MyApp;
{----------------------------------------------------------------------------}
VAR
 P:PMyApp;
 PMaxX,PMaxY:Integer;
{----------------------------------------------------------------------------}
Procedure Guli;
Const
 p=0.05;{0.05}
 q=1;   {1}
Var
 Nx,Ny,A,B                : integer;
 Dx,Dy,Xk,Yk,Xk1,Yk1,R    : real;
 Sk                       : Word;
 I                        : Integer;
begin
 A:=PMaxX;
 B:=PMaxY;
 Dx:=(Xmax-Xmin)/A;
 Dy:=(Ymax-Ymin)/B;
 For Ny:=21 to B do
  begin
  For Nx:=0 to A do
   begin
    Xk:=Xmin+Nx*Dx;
    Yk:=Ymin+Ny*Dy;
    Sk:=0;
    Repeat
     Xk:=Sqr(Xk)-Sqr(Yk){+Xk*Yk}+p;
     Yk:=2*Xk*Yk+q;
     R:=Sqr(Xk)+Sqr(Yk);
     Inc(Sk);
     If R>M  then PutPixel(Nx,Ny,Sk);
     If Sk>K then PutPixel(Nx,Ny,0);
    Until (R>M) or (Sk>K);
   end;
  PProg^.SetValue(NY)
 end;
 PProg^.SetValue(0)
end;
{----------------------------------------------------------------------------}
Procedure Mandelbrot;
Var
 NP,NQ,A,B  : integer;
 DP,DQ,Xk,Yk,Xk1,Yk1,R    : real;
 Sk:Word;
 P,Q     :real;
begin
 A:=PMaxX;
 B:=PMaxY;
 DP:=(Pmax-Pmin)/A;
 DQ:=(Qmax-Qmin)/B;
 For NQ:=21 to B do
  begin
  For NP:=0 to A do
   begin
    Xk:=0;Yk:=0;
    P:=Pmin+NP*DP;
    Q:=Qmin+NQ*DQ;
    Sk:=0;
    Repeat
     Xk:=Sqr(Xk)-Sqr(Yk)+p;
     Yk:=2*Xk*Yk+q;
     R:=Sqr(Xk)+Sqr(Yk);
     Inc(Sk);
     If R>M  then PutPixel(NP,NQ,Sk);
     If Sk>K then PutPixel(NP,NQ,0);
    Until (R>M) or (Sk>K);
   end;
  PProg^.SetValue(NQ);
 end;
 PProg^.SetValue(0)
end;
{----------------------------------------------------------------------------}
Procedure LoadFile;
 begin
  P^.DoneModal;
  DoneModalF:=False;
  V:=New(PWindow,Init(200,200,440,430,'Проверка Списка...'));
  V^.InsertCommand(New(PButton,Init(265,405,315,420,'Ok',   cmEmpty,cmEmpty,cmAbortModal)));
  V^.InsertCommand(New(PButton,Init(325,405,375,420,'Выход',cmEmpty,cmEmpty,cmAbortModal)));
  {S:=New(PSpin,Init(210,220,220,241,0,0,400,1,cmSpinCommand));}
  S:=New(PList,Init(210,220,430,395,False));
  V^.InsertCommand(S);
  S^.AddListItem(New(PListItem,Init(210,430,'List 1')));
  S^.AddListItem(New(PListItem,Init(210,430,'List 2')));
  S^.AddListItem(New(PListItem,Init(210,430,'List 3')));
  S^.AddListItem(New(PListItem,Init(210,430,'List 4')));
  V^.Draw(Common);
  P^.InsertModal(V);
  ClearEvent(Event);
  Result:=cmEmpty;
 end;

Procedure ChangeColors;
 var
  NewColors:Word;
 begin
  NewColors :=ChangeColorsInput^.GetStringAsWord;
  If ChangeColorsInput^.Correct then
   K :=NewColors;
  P^.DoneModal;
  ClearEvent(Event);
  Result:=cmEmpty;
 end;

Procedure WindowForChangeColors;
var
 KString:string;
begin
 P^.DoneModal;
 DoneModalF:=False;
 V:=New(PWindow,Init(200,200,440,280,'Изменение числа цветов'));
 V^.InsertCommand(New(PButton,Init(265,260,315,275,'Ok',   cmEmpty,cmEmpty,cmChangeColors)));
 V^.InsertCommand(New(PButton,Init(325,260,375,275,'Выход',cmEmpty,cmEmpty,cmAbortModal)));
 Str(K,KString);
 ChangeColorsInput:=New(PInput,Init(325,240,430,251,KString,Blue,White));
 V^.InsertCommand(ChangeColorsInput);
 SetColor(scFore);
 SetTextJustify(LeftText,CenterText);
 OutTextXY(205,245,'Новое число цветов :');
 V^.Text('Изменить число цветов ?');
 P^.InsertModal(V);
 ClearEvent(Event);
 Result:=cmEmpty;
end;

Procedure WindowForChangeOXY;
var
 XMinstr,XMaxstr,YMinStr,YMaxStr:String;
 begin
 P^.DoneModal;
 DoneModalF:=False;
 V:=New(PWindow,Init(100,200,540,280,'Изменение масштабов осей'));
 V^.InsertCommand(New(PButton,Init(265,260,315,275,'Ok',   cmEmpty,cmEmpty,cmChangeOXY)));
 V^.InsertCommand(New(PButton,Init(325,260,375,275,'Выход',cmEmpty,cmEmpty,cmAbortModal)));
 Str(XMax,XMaxStr);
 Str(YMax,YMaxStr);
 Str(XMin,XMinStr);
 Str(YMin,YMinStr);
 ChangeOXMinInput:=New(PInput,Init(210,215,350,226,XMinStr,Blue,White));
 ChangeOXMaxInput:=New(PInput,Init(390,215,530,226,XMaxStr,Blue,White));
 ChangeOYMinInput:=New(PInput,Init(210,236,350,247,YMinStr,Blue,White));
 ChangeOYMaxInput:=New(PInput,Init(390,236,530,247,YMaxStr,Blue,White));
 V^.InsertCommand(ChangeOxMinInput);
 V^.InsertCommand(ChangeOxMaxInput);
 V^.InsertCommand(ChangeOyMinInput);
 V^.InsertCommand(ChangeOyMaxInput);
 SetColor(scFore);
 SetTextJustify(LeftText,CenterText);
 OutTextXY(105,220,'X изменяется от :');
 OutTextXY(360,220,'до :');
 OutTextXY(105,240,'Y изменяется от :');
 OutTextXY(360,240,'до :');
 P^.InsertModal(V);
 ClearEvent(Event);
 Result:=cmEmpty;
 end;

Procedure ChangeOXY;
 var
 NewXMin,NewXMax,NewYMin,NewYMax:Real;
 begin
  HideMouse;
  NewXMin:=ChangeOXMinInput^.GetStringAsReal;
  If ChangeOXMinInput^.Correct then
   XMin :=NewXmin;

  NewXMax:=ChangeOXMaxInput^.GetStringAsReal;
  If ChangeOXMaxInput^.Correct then
   XMax :=NewXMax;

  NewYMin :=ChangeOYMinInput^.GetStringAsReal;
  If ChangeOYMinInput^.Correct then
   YMin:=NewYMin;

  NewYMax :=ChangeOYMaxInput^.GetStringAsReal;
  If ChangeOYMaxInput^.Correct then
   YMax :=NewYMax;

  P^.DoneModal;
  ClearEvent(Event);
  Result:=cmEmpty;
 end;

Procedure WindowForChangeOPQ;
var
 PMinstr,PMaxstr,QMinStr,QMaxStr:String;
 begin
 P^.DoneModal;
 DoneModalF:=False;
 V:=New(PWindow,Init(100,200,540,280,'Изменение масштабов осей'));
 V^.InsertCommand(New(PButton,Init(265,260,315,275,'Ok',   cmEmpty,cmEmpty,cmChangeOPQ)));
 V^.InsertCommand(New(PButton,Init(325,260,375,275,'Выход',cmEmpty,cmEmpty,cmAbortModal)));
 Str(PMax,PMaxStr);
 Str(QMax,QMaxStr);
 Str(PMin,PMinStr);
 Str(QMin,QMinStr);
 ChangeOPMinInput:=New(PInput,Init(210,215,350,226,PMinStr,Blue,White));
 ChangeOPMaxInput:=New(PInput,Init(390,215,530,226,PMaxStr,Blue,White));
 ChangeOQMinInput:=New(PInput,Init(210,236,350,247,QMinStr,Blue,White));
 ChangeOQMaxInput:=New(PInput,Init(390,236,530,247,QMaxStr,Blue,White));
 V^.InsertCommand(ChangeOPMinInput);
 V^.InsertCommand(ChangeOPMaxInput);
 V^.InsertCommand(ChangeOQMinInput);
 V^.InsertCommand(ChangeOQMaxInput);
 SetColor(scFore);
 SetTextJustify(LeftText,CenterText);
 OutTextXY(105,220,'P изменяется от :');
 OutTextXY(360,220,'до :');
 OutTextXY(105,240,'Q изменяется от :');
 OutTextXY(360,240,'до :');
 P^.InsertModal(V);
 ClearEvent(Event);
 Result:=cmEmpty;
 end;

Procedure ChangeOPQ;
 var
 NewPMin,NewPMax,NewQMin,NewQMax:Real;
 begin
  HideMouse;
  NewPMin:=ChangeOPMinInput^.GetStringAsReal;
  If ChangeOPMinInput^.Correct then
   PMin :=NewPmin;

  NewPMax:=ChangeOPMaxInput^.GetStringAsReal;
  If ChangeOPMaxInput^.Correct then
   PMax :=NewPMax;

  NewQMin :=ChangeOQMinInput^.GetStringAsReal;
  If ChangeOQMinInput^.Correct then
   QMin:=NewQMin;

  NewQMax :=ChangeOQMaxInput^.GetStringAsReal;
  If ChangeOQMaxInput^.Correct then
   QMax :=NewQMax;

  P^.DoneModal;
  ClearEvent(Event);
  Result:=cmEmpty;
 end;

Procedure MakeMWindow;
var
 MString:string;
begin
 P^.DoneModal;
 DoneModalF:=False;
 V:=New(PWindow,Init(200,200,440,280,'Изменение свойства М...'));
 V^.InsertCommand(New(PButton,Init(265,260,315,275,'Ok',   cmEmpty,cmEmpty,cmChangeM)));
 V^.InsertCommand(New(PButton,Init(325,260,375,275,'Выход',cmEmpty,cmEmpty,cmAbortModal)));
 Str(M,MString);
 ChangeMInput:=New(PInput,Init(310,240,430,251,MString,Blue,White));
 V^.InsertCommand(ChangeMInput);
 SetColor(scFore);
 SetTextJustify(LeftText,CenterText);
 OutTextXY(205,245,'Новое значение М=');
 V^.Text('Изменить параметр М ?');
 P^.InsertModal(V);
 ClearEvent(Event);
 Result:=cmEmpty;
end;

Procedure SetRedPalette;
 var i:integer;
 begin
  P^.StatusLine^.Text('Подождите, идёт замена палитры...');
  HideMouse;
  P^.DoneModal;
  For i:=0 to 15 do
   With RedPalette[i] do
    SetRGBPalette(ColorNum,R,G,B);
  ClearEvent(Event);
  Result:=cmEmpty;
  P^.StatusLine^.Clear
 end;

Procedure SetGreenPalette;
 var i:integer;
 begin
  P^.StatusLine^.Text('Подождите, идёт замена палитры...');
  HideMouse;
  P^.DoneModal;
  For i:=0 to 15 do
   With GreenPalette[i] do
    SetRGBPalette(ColorNum,R,G,B);
  ClearEvent(Event);
  Result:=cmEmpty;
  P^.StatusLine^.Clear
 end;

Procedure SetBluePalette;
  var i:integer;
  begin
   P^.StatusLine^.Text('Подождите, идёт замена палитры...');
   HideMouse;
   P^.DoneModal;
   For i:=0 to 15 do
    With BluePalette[i] do
     SetRGBPalette(ColorNum,R,G,B);
   ClearEvent(Event);
   Result:=cmEmpty;
   P^.StatusLine^.Clear
  end;

Procedure SetCommonPalette;
 var i:integer;
 begin
  P^.StatusLine^.Text('Подождите, идёт восстановление палитры...');
  HideMouse;
  P^.DoneModal;
  For i:=0 to 15 do
   With CommonPalette[i] do
     SetRGBPalette(ColorNum,R,G,B);
  ClearEvent(Event);
  Result:=cmEmpty;
  P^.StatusLine^.Clear
 end;

Procedure ChangeM;
 var NewM:Word;
 begin
  HideMouse;
  NewM :=ChangeMInput^.GetStringAsWord;
  If ChangeMInput^.Correct then M :=NewM;
  P^.DoneModal;
  ClearEvent(Event);
  Result:=cmEmpty;
 end;
{----------------------------------------------------------------------------}
Procedure MyApp.Idle;
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

Constructor MyApp.Init;
 var
  i,j:integer;
 begin
  HideMouse;
  Inherited Init;
  Pos:=MaxX-52;
  InsertMenu(New(PHorizontalMenu,Init(1,1,MaxX-2,19)));
  With SystemMenu^ do begin
   InsertItem(New(PHorItem,Init(3,3,63,17,    'Файл',   cmVerMenu1)),NotLast);
   InsertItem(New(PHorItem,Init(67,3,127,17,  'Функция',cmVerMenu2)),NotLast);
   InsertItem(New(PHorItem,Init(131,3,191,17, 'Масштаб',cmVerMenu3)),NotLast);
   InsertItem(New(PHorItem,Init(195,3,255,17, 'Рисунок',cmVerMenu4)),Last);
   ReInit;
  end;
  StatusLine:=New(PStatusLine,Init(1,MaxY-20,MaxX-1,MaxY-1));
  PMaxX:=MaxX;
  PMaxY:=MaxY-22;
  PProg:=New(PProgressBar,Init(MaxX-150,MaxY-16,MaxX-60,MaxY-6,PMaxY));
  InsertStatic(PProg);
 end;

Procedure MyApp.VMenu1;
 Var
  M:PVerticalMenu;
 begin
  M:=New(PVerticalMenu,Init(1,22,106,77));
  M^.InsertItem(New(PVerItem,Init(3,24,104,39,'Сохранить      Alt-S',cmEmpty)),   NotLast);
  M^.InsertItem(New(PVerItem,Init(3,42,104,57,'Загрузить      Alt-L',cmLoadFile)),NotLast);
  M^.InsertItem(New(PVerItem,Init(3,60,104,75,'Выход             Alt-X',cmExit)),    Last);
  M^.ReInit;
  InsertModal(M);
  Result:=cmEmpty;
  WriteMouseAndSave
 end;

Procedure MyApp.VMenu2;
 Var
  M:PVerticalMenu;
 begin
  M:=New(PVerticalMenu,Init(65,22,210,95));
  M^.InsertItem(New(PVerItem,Init(67,24,208,39,'Текущая функция'        ,cmEmpty     )),NotLast);
  M^.InsertItem(New(PVerItem,Init(67,42,208,57,'Изменить функцию'       ,cmEmpty     )),NotLast);
  M^.InsertItem(New(PVerItem,Init(67,60,208,75,'Нарисовать Жюли'        ,cmGuli      )),NotLast);
  M^.InsertItem(New(PVerItem,Init(67,78,208,93,'Нарисовать Мандельброта',cmMandelbrot)),Last);
  M^.ReInit;
  InsertModal(M);
  Result:=cmEmpty;
  ShowMouse
 end;

Procedure MyApp.VMenu3;
 Var
  M:PVerticalMenu;
 begin
  M:=New(PVerticalMenu,Init(129,22,239,131));
  M^.InsertItem(New(PVerItem,Init(131,24,237,39,  '(Ж) Оси OX и OY',  cmWindowForChangeOXY )),NotLast);
  M^.InsertItem(New(PVerItem,Init(131,42,237,57,  '(Ж) Значения P,Q', cmEmpty     )),NotLast);
  M^.InsertItem(New(PVerItem,Init(131,60,237,75,  '(М) Оси OP и OQ',  cmWindowForChangeOPQ )),NotLast);
  M^.InsertItem(New(PVerItem,Init(131,78,237,93,  '(М) Значения X,Y', cmEmpty     )),NotLast);
  M^.InsertItem(New(PVerItem,Init(131,96,237,111, 'Количество Цветов',cmWindowForChangeColors )),NotLast);
  M^.InsertItem(New(PVerItem,Init(131,114,237,129,'Свойство M',       cmWindowForM)),Last);
  M^.ReInit;
  InsertModal(M);
  Result:=cmEmpty;
  ShowMouse
 end;

Procedure MyApp.VMenu4;
 Var
  M:PVerticalMenu;
 begin
  M:=New(PVerticalMenu,Init(193,22,300,113));
  M^.InsertItem(New(PVerItem,Init(195,24,298,39,'Количество цветов',cmEmpty         )),NotLast);
  M^.InsertItem(New(PVerItem,Init(195,42,298,57,'Красная палитра',  cmRedPalette    )),NotLast);
  M^.InsertItem(New(PVerItem,Init(195,60,298,75,'Зелёная палитра',  cmGreenPalette  )),NotLast);
  M^.InsertItem(New(PVerItem,Init(195,78,298,93,'Синяя палитра',    cmBluePalette   )),NotLast);
  M^.InsertItem(New(PVerItem,Init(195,96,298,111,'Обычная палитра', cmCommonPalette )),Last);
  M^.ReInit;
  InsertModal(M);
  Result:=cmEmpty;
  ShowMouse
 end;

Procedure MyApp.Handler;
 begin
  Inherited Handler(Event);
  Case Result of
   cmVerMenu1   : VMenu1;
   cmVerMenu2   : VMenu2;
   cmVerMenu3   : VMenu3;
   cmVerMenu4   : VMenu4;
   cmAbortModal : begin
                   DoneModalF:=True;
                   WriteMouseAndSave;
                   Result:=cmEmpty
                  end;
   cmGuli       : begin
                   StatusLine^.Text('Подождите, рисуется множество Жюли...');
                   HideMouse;
                   DoneModal;
                   Guli;
                   ClearEvent(Event);
                   Result:=cmEmpty;
                   StatusLine^.Clear;
                   WriteMouseAndSave
                  end;
   cmMandelbrot : begin
                   StatusLine^.Text('Подождите, рисуется множество Мандельброта...');
                   HideMouse;
                   DoneModal;
                   Mandelbrot;
                   ClearEvent(Event);
                   Result:=cmEmpty;
                   StatusLine^.Clear;
                   WriteMouseAndSave
                  end;
  cmRedPalette  : SetRedPalette;
 cmGreenPalette : SetGreenPalette;
  cmBluePalette : SetBluePalette;
cmCommonPalette : SetCommonPalette;
   cmWindowForM : MakeMWindow;
      cmChangeM : ChangeM;
cmWindowForChangeOXY : WindowForChangeOXY;
    cmChangeOXY : ChangeOXY;
cmWindowForChangeOPQ : WindowForChangeOPQ;
    cmChangeOPQ : ChangeOPQ;
cmWindowForChangeColors : WindowForChangeColors;
  cmChangeColors: ChangeColors;
  cmLoadFile    : LoadFile;
  cmSpinCommand : begin end;
  end;
 end;

Destructor MyApp.Done;
 begin
  Inherited Done
 end;
{----------------------------------------------------------------------------}
var xx:Pointer;
    ax:Longint;
{----------------------------------------------------------------------------}
begin
P:=New(PMyApp,Init);
P^.Run;
P^.Done;
end.
