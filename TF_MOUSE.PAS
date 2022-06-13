{+----------------------------------------+
 | Программа, демонстрирующая возможности |
 |            модуля F_Mouse.             |
 +----------------------------------------+}
Uses CRT,DOS,Graph,F_Mouse,F_GrText,F_Text;
const
  t1 = ' Демонстрация возможностей модуля F_Mouse ';
  t2 = '  Состояние мыши: ';
  t3: array [1..4] of String[22] =
       ('Координаты: X=   Y=   ','Левая кнопка  :',
        'Правая кнопка :','Средняя кнопка:');
  NItem = 3;
  t4: array [1..NItem] of String[24] =
       (' Изменить указатель (F1)','   Сменить режим (F2)',
        ' Завершить работу (Esc)');
type
  ItemT = array [1..NItem] of MouseItemType;
const
  Items: ItemT =(
 (X1: 9; Y1: 4; X2:35; Y2: 6; Butt: LeftButton; Key:59 shl 8),
 (X1:44; Y1: 4; X2:68; Y2: 6; Butt: LeftButton; Key:60 shl 8),
 (X1:26; Y1:18; X2:51; Y2:20;Butt: LeftButton; Key:27));
  Text: Boolean = True;
var
  k,n,b,x,y,bb,xx,yy: Integer;
  Font: Pointer;
  FontSize: Word;
type
  GotoXYType = procedure(X,Y: Byte);
  ColorsType = procedure(Text,Back: Byte);
  SetWindowType = procedure(X1,Y1,X2,Y2,Border: Byte;
                	   Header: String;Clip,Build,Play: Boolean);
  ChangeCursorType = procedure;
var
  Colors: ColorsType;
  GotoXY: GotoXYType;
  SetWindow: SetWindowType;
  ChangeCursor: ChangeCursorType;

Procedure SetScreen;
  {Создает экран в текстовом или графическом режиме}
begin
{Создаем основное окно}
  Colors(Black,LightGray);
  SetWindow(1,1,80,25,DoubleBorder,t1,True,False,False);
{Создаем элементы выбора}
  Colors(Black,Green);
  for k := 1 to NItem do with Items[k] do
    begin
      SetWindow(X1,Y1,X2,Y2,SingleBorder,'',True,False,False);
      Write(t4[k])
    end;
{Создаем панель статуса}
  Colors(White,Red);
  SetWindow(24,9,55,16,DoubleBorder,t2,True,False,False);
  n := (30-Length(t2)) div 2;
  for k := 1 to 4 do
    begin
      GotoXY(n-3,k+1);
      Write(t3[k])
    end
end;   {SetScreen}
{--------------------------}
Procedure ChangeTextCursor; Far;
  {Изменяет курсор в текстовом режиме}
const
  t = ' Выберите символ для указателя мыши ';
var
  k: Byte;
  n,x,y: Integer;
begin
{Создаем окно выбора}
  HideMouse;
  PutWindow(8,7,73,12,White,Blue,
            DoubleBorder,1,t,True,False,False);
{Выводим в нем все символы, кроме Bel,BS,LF,CR}
  for k := 1 to 255 do
    if k in [7,8,10,13] then
      Write(' ')
    else
      Write(chr(k));
{Формируем пределы перемещения указателя}
 MouseWindow(MouseGraphCooX(9),MouseGraphCooY(8),
          MouseGraphCooX(72),MouseGraphCooY(11));
{Цикл до нажатия левой кнопки}
  ShowMouse;
  repeat
    GetMouseState(b,x,y)
  until b and LeftButton=0;
  Repeat
    GetMouseState(b,x,y);
  until b and LeftButton<>0;
  HideMouse;
{Определяем выбранный символ}
  x := MouseTextCooX(x)-8;
  y := MouseTextCooY(y)-7;
  x := (y-1)*64+x;
  if x>255 then
    x := 1;
{Меняем форму курсора}
  MouseTextCursor($FF00,$7F00+x);
{Восстанавливаем экран}
  GetWindow(1);
  MouseScreen;
  ShowMouse
end;   {ChangeTextCursor}
{--------------------------}
{Глобальные определения для обработчика событий от мыши,
 используемого в режиме выбора графического указателя}
const
  DX = 40;    		{Шаг смещения изображений}
  NCur = 4;   		{Количество изображений}
var
  kk,         		{Ранее выбранное изображение}
  x0,         		{Левая граница изображения}
  y0,y1: Integer; 	{Вертикальные границы}
  PP: Pointer;    	{Изображение указателя}
  SizePP: Word;   	{Его размеры в памяти}

Procedure MouseHandler(Mask,Buttons,X,Y,dDX,DY: Integer);  Far;
  {Отслеживает перемещения мыши и инвертирует изображение,
	на которое указывает в данный момент указатель мыши}
var
  k: Integer;           {Текущее изображение}
begin
  k := (x-X0) div DX;
  if k<1 then
    k := 1;
  if k>NCur then
    k := NCur;
  if k=kk then
    Exit;     {Текущее изображение не изменилось}
{Гасим старое и выделяем новое изображение}
  PutImage(x0+(2*kk-1)*DX div 2,y0,PP^,NormalPut);
  GetImage(x0+(2*k-1)*DX div 2,y0,x0+(2*k+1)*DX div 2,y1,PP^);
  PutImage(x0+(2*k-1)*DX div 2,y0,PP^,NotPut);
  kk := k
end;   {MouseHandler}
{--------------------------}
Procedure ChangeGraphCursor; Far;
  {Изменяет курсор в графическом режиме}
const
  t = ' Выберите указатель: ';
var
  x,y,x1: Integer;
  Size,b: Word;
  p: Pointer;
  Cur: array [1..NCur,0..1,0..15] of Word;
  Proc: MouseHandlerType;
{-------------}
Procedure PutCur(N: Byte);
  {Сканирует изображение в левом верхнем углу
   экрана и формирует маски указателя}
var
  x,y: Byte;
  b: Word;
begin
  for y := 0 to 15 do
    begin
      b := 0;
      for x := 0 to 15 do
        if GetPixel(x,y)<>GetBkColor then
          b := b or ($8000 shr x);
      Cur[N,1,y] := b;
      Cur[N,0,y] := not b
    end;
  ClearViewPort
end;   {PutCur}
{-------------}
begin  {ChangeGraphCursor}
{Готовим окно 16х16 в левом верхнем углу экрана}
  Size := ImageSize(0,0,15,15);
  GetMem(P,Size);
  GetImage(0,0,15,15,P^);
  SetViewPort(0,0,15,15,ClipOn);
  ClearViewPort;
{Готовим маски указателей}
  HideMouse;
  if InitMouse then
    ShowMouse;           {Получаемстандартное изображение}
  SetMouseItem(NItem,Items);
  MouseGotoXY(0,0);      {Стандартный указатель}
  PutCur(1);
  HideMouse;
  Circle(8,8,4);         {Кружок}
  PutCur(2);
  Line(0,8,15,8);        {Перекрестие}
  Line(8,0,8,15);
  PutCur(3);
  Rectangle(0,0,15,15);  {Квадратик}
  PutPixel(7,7,15);
  PutCur(4);
  SetViewPort(0,0,GetMaxX,GetMaxY,ClipOn);
{Готовим окно для меню указателей}
  PutImage(0,0,P^,NormalPut);
  FreeMem(P,Size);
  x0 := GraphCooX(9);
  y0 := GraphCooY(7);
  x1 := GraphCooX(36);
  y1 := GraphCooY(10);
  Size := ImageSize(x0,y0,x1,y1);
  GetMem(P,Size);
  GetImage(x0,y0,x1,y1,P^);
  Colors(White,Blue);
  SetWindow(9,7,35,9,DoubleBorder,t,True,False,False);
{Выводим изображения указателей}
  y1 := y0+16;
  for kk := 1 to NCur do
    for y := 0 to 15 do
      begin
        x1 := x0+kk*DX;
        b := Cur[kk,1,y];
        for x := 0 to 15 do
          if b and ($8000 shr x)<>0 then
            PutPixel(x1+x,y1+y,White)
      end;
{Устанавливаем пределы перемещения указателя}
  y0 := y0+16;
  y1 := y1+16;
  MouseWindow(x0,y0,x1+DX,y1);
{Выделяем первое изображение}
  SizePP := ImageSize(x0+DX div 2,y0,x0+3*DX div 2,y1);
  GetMem(PP,SizePP);
  GetImage(x0+DX div 2,y0,x0+3*DX div 2,y1,PP^);
  PutImage(x0+DX div 2,y0,PP^,NotPut);
  kk := 1;
{Устанавливаем свой обработчик событий}
  SetMouseHandler(1,MouseHandler);
{Цикл до нажатия левой кнопки}
  repeat
    GetMouseState(k,x,y)
  until k and LeftButton<>0;
{Удаляем обработчик событий}
  ClearMouseHandler;
  FreeMem(PP,SizePP);
{Формируем новый указатель}
  kk := (x-x0) div DX;
  if kk>NCur then
    kk := NCur;
  if kk<1 then
    kk := 1;
  MouseGraphCursor(Cur[kk,0,0],0,0);
{Восстанавливаем экран}
  PutImage(x0,y0-16,P^,NormalPut);
  FreeMem(P,Size);
  MouseWindow(0,0,GetMaxX,GetMaxY);
  F_GrText.Window(25,10,54,15);
  Colors(White,Red);
  ShowMouse
end;   {ChangeGraphCursor}
{--------------------------}
Procedure SetTextScreen;
  {Создает текстовый экран}
begin
  if not Text then

    begin  			{Был графический режим}
      FreeMem(Font,FontSize);  	{Удаляем шрифт}
      GraphWriteOff; 	        {Восстанавливаем ввод/вывод}
      CloseGraph; 	        {Переходим к текстовому режиму}
      Text := True
    end;
{Указываем нужные для текстового режима процедуры}
  GotoXY := F_Text.GotoXY;
  Colors := F_Text.Colors;
  SetWindow := F_Text.SetWindow;
  ChangeCursor := ChangeTextCursor;
{Устанавливаем стандартный коэффициент пересчета}
  TextRatioY := 8;
{Создаем текстовый экран}
  SetScreen
end; {SetTextScreen}
{--------------------------}
Procedure SetGraphScreen;
  {Создает графический экран}
var
  d,r: Integer;
  h: Byte;
  Name: String;
  F: File;
begin
  if Text then
{Инициируем графику}
  begin
    d := Detect;
    InitGraph(d,r,'e:\tp\bgi');
    if GraphResult<>grOk then
      Exit;
{Выбираем шрифт в зависимости от разрешения экрана}
    case GetMaxY of
      349: h := 14; {EGA 8x14}
      479: h := 19; {VGA 8x19}
    else
           h := 8   {Прочие 8x8}
    end;
{Загружаем шрифт из файла 8xH.fnt}
    Str(h,Name);
    Name := '8x'+Name+'.fnt';
    Assign(F,Name);
    {$I-}
    Reset(F,1);
    {$I+}
    if IOResult<>0 then
      Exit;
    FontSize := FileSize(F);
    GetMem(Font,FontSize);
    BlockRead(F,Font^,FontSize,r);
    Close(F);
    if r<>FontSize then
      begin
        FreeMem(Font,FontSize);
        Exit
      end;
{Регистрируем шрифт и переназначаем ввод/вывод}
    SetFont(Font,8,h);
    GraphWriteOn;
    Text := False
  end;
{Указываем нужные для графического режима процедуры}
  GotoXY := F_GrText.GotoXY;
  Colors := F_GrText.Colors;
  SetWindow := F_GrText.SetWindow;
  ChangeCursor := ChangeGraphCursor;
{Задаем коэффициент пересчета вертикального положения 
 указателя мыши в текстовый размер: он равен высоте шрифта}
  TextRatioY := h;
{Создаем графический экран}
  SetScreen
end;  {SetGraphScreen}
{--------------------------}
begin  {Основная программа}
  CursorOff;      {Удаляем курсор}
  SetTextScreen;  {Формируем текстовый экран}
{Инициируем мышь. Эту процедуру всегда следует осуществлять
	после установки или смены режима работы дисплея}
  if not InitMouse then
    Halt;
  ShowMouse;
{Указываем элементы выбора}
  SetMouseItem(NItem,Items);
{Основной цикл работы продолжается до выбора
 		элемента "Завершить работу" или нажатия Esc}
 {Запоминаем начальное состояние мыши}
  GetMouseState(b,x,y);
  While(True) do {"Бесконечный" цикл}
  begin
  {Проверяем выбор элементов}
    if KeyOrMousePressed then
    case ReadKeyOrMouse of  {Есть выбор}
      #27: Halt;            {Еsc}
      #0: case ReadKeyOrMouse of
        #59: ChangeCursor;  {F1-Изменить курсор}
        #60: begin          {F2-Сменить режим}
               HideMouse;   {Убираем мышь перед сменой режима}
               if Text then
                 SetGraphScreen  {Был текстовый режим}
               else
                 SetTextScreen;  {Был графический режим}
               if InitMouse then {Инициируем мышь после смены режима!}
                 ShowMouse;
               SetMouseItem(NItem,Items) {Заново указываем элементы выбора,
                                    т.к. они сбрасываются при инициации мыши}
             end;
      end  {case}
    end; {case}
  {Получаем текущее состояние мыши}
    GetMouseState(bb,xx,yy);
    if (bb<>b) or (xx<>x) or (yy<>y) then
      begin  		{Состояние изменилось - сообщить}
        b := bb;
        x := xx;
        y := yy;
        GotoXY(n+11,2);
        Write(MouseTextCooX(x):2);
        GotoXY(n+16,2);
        Write(MouseTextCooY(y):2);
        GotoXY(n+13,3);
        if b and LeftButton<>0 then
          Write('нажата  ')
        else
          Write('отпущена');
        GotoXY(n+13,4);
        if b and RightButton<>0 then
          Write('нажата  ')
        else
          Write('отпущена');
        GotoXY(n+13,5);
        if NumButton=3 then
          if b and CenterButton<>0 then
            Write('нажата  ')
          else
            Write('отпущена');
      end  {if (bb<>0) or...}
  end  {while TRUE}
end.


