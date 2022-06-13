{$X+,R-}
{+----------------------------------------------+
 |    Редактор векторных шрифтов формата CHR    |
 +----------------------------------------------+
}
Uses CRT,Graph,F_GrText,F_Mouse;
{
  Глобальные определения
}
type
  TChar4 = array [1..4] of Char;
  TFontHead = record            {Структура заголовка шрифта}
  case Byte of
  0:(FontFileID: TChar4);
  1:(B: array [1..128] of byte);
  end;
  TFontPara = record            {Блок параметров шрифта}
  case Byte of
  0:(
    ParPrefix : Char;  		{Символ "+"}
    CharsCount: Word;  		{Количество символов в шрифте}
    Reserv1   : Byte;  		{Не используется}
    FirstChar : Byte;  		{Код первого символа}
    DataOffset: Word;  		{Смещение до векторных команд первого символа}
    FillFlag   : Byte; 		{Флаг заливки}
    UpperMargin: Byte; 		{Высота символов}
    Reserv2    : Byte; 		{Не используется}
    LowerMargin: ShortInt; 	{Нижняя кромка}
    Reserv3 : array [1..5] of Byte;);
  1:(H2: array [1..16] of Byte)
  end;
  TOffst = array [0..255] of Word;   	{Смещения}
  TWidth = array [0..255] of Byte;   	{Ширины}
  TChars = array [0..255] of Pointer;	{Данные}
  TLengD = array [0..255] of Word;   	{Длина}
  AW = array [1..255] of Word;
  TCooE = record            	        {Векторы рабочего поля}
    X1,Y1,X2,Y2: Integer;
  end;
  TMouseMask = array [0..1,0..15] of Word;
var
  FontHead: TFontHead; 	{Заголовок файла}
  HeaderSize: Word;    	{Смещение блока параметров}
  FontPara: TFontPara; 	{Параметры шрифта}
  FileSize: Word;   	{Длина загружаемой части файла}
  AFileSize: Byte;  	{Положение FileSize}
  Offsets : TOffst; 	{Таблица смещений}
  Widths  : TWidth; 	{Таблица ширин}
  Chars   : TChars; 	{Указатели на данные}
  LengD   : TLengD; 	{Длина данных в байтах}
  F       : File;   	{CHR-файл}
  FName   : String; 	{Имя файла}
  MaxW    : Byte;   	{Максимальная ширина символа}
  MaxH    : Byte;   	{Полная высота символа}
  {------------ Рабочее поле ------------}
  XE      : Integer;	{Левый верхний угол WE}
  YE      : Integer;
  XE2     : Integer;	{Правый нижний угол WE}
  YE2     : Integer;
  YB      : Integer;	{Ордината базовой линии}
  WidthX  : Integer;	{Правая граница символа}
  DXE     : Integer;	{Ширина клетки WE}
  DYE     : Integer;	{Высота клетки WE}
  NVecE   : Word;   	{Количество векторов в WE}
  VecE: array [1..250] of TCooE; 	{Векторы в WE}
  {------------- Окно повтора -------------}
  XR,YR: Integer;   	                {Координаты окна повтора}
  WR: Pointer;      	                {Образ пустого окна повтора}
  {---------- Таблица символов ------------}
  XT  : Integer;		        {Левый верхний угол таблицы символов}
  YT  : Integer;
  DXT : Integer;		        {Ширина клетки таблицы символов}
  DYT : Integer;		        {Высота клетки}
  {---------------- Мышь ------------------}
  dXm,dYm : Integer;	                {Границы мыши в рабочем поле}
  CurM: TMouseMask; 	                {Стандартная маска указателя}
  CurE: TMouseMask; 	                {Маска в рабочем поле}
  MouseF  : Boolean;	                {Флаг формы указателя мыши}
const
  ChangeF: Boolean = False; 	        {Флаг изменения шрифта}
  Head: TChar4 = ('P','K',#8,#8);

PROCEDURE OutChar(X0,Y0: Integer; C: Byte; DX,DY: Real);
  {Выводит символ С в позицию X,Y с масштабом DX,DY}
var
  PW:^AW;
  k: Integer;
  x,y: Integer;
Procedure Vector(W: Word);
  {Рисует очередной вектор символа}
var
  xx,yy: Integer;
  op: Word;
begin
  {Выделяем код операции}
  op := W and $8080;
  if op=0 then
    Exit;
  W := W xor op;
  {Выделяем координаты}
  yy := W shr 8;
  xx := W and $FF;
  if xx>63 then
    xx := xx-128;
  if yy>63 then
    yy := yy-128;
  {Поучаем координаты второй точки}
  xx := X0+Round(xx*DX);
  yy := Y0-Round(yy*DY);
  {Выполняем операцию}
  if op=$8080 then
    Line(X,Y,XX,YY);
  X := XX;
  Y := YY
end;  {Vector}
{---------}
BEGIN  {OutChar}
  if LengD[C]=0 then
    Exit;               {Блокируем вывод не определенных символов}
  Y0 := Y0-DYT div 4;
  X := X0;        	{Точка отсчета координат}
  Y := Y0;
  PW := Chars[C]; 	{Описатель символа}
  {Вычерчиваем символ}
  for k := 1 to LengD[C] div 2 do
    Vector(PW^[k])
END;  {OutCharXY}
{-------------------}
PROCEDURE ClearWinEd;
  {Очищает рабочее поле}
var
  X,Y: Integer;
BEGIN
 SetViewPort(XE-dXm,YE-dYm,XE2+dXm,YE2+dYm,True);
 ClearViewPort;
 SetViewPort(0,0,GetMaxX,GetMaxY,True);
 {Выводим вертикали}
  for X := 0 to MaxW do  			
    for Y := 0 to MaxH do
      PutPixel(XE+X*DXE,YE+Y*DYE,White);
  {Выводим базовую линию}
  SetColor(Cyan);
  YB := YE+succ(FontPara.UpperMargin)*DYE;
  Line(XE,YB,XE2,YB);
  {Выводим указатель границы символа}
  WidthX := XE;
  Line(XE,YE,XE,YE2);
  {Обводим рамкой}
  SetColor(White);
  Rectangle(XE-dXm,YE-dYm,XE2+dXm,YE2+dYm)
END;  {ClearWE}
{-------------------}
PROCEDURE Init;
  {Запрашивает и вводит имя CHR-файла,вводит данные из 
   файла,инициирует графику и создает экран}


Procedure FontRead(var Dest; Size: Word);
  {Читает из файла F в переменную Dest Sizeбайт и контролирует результат.
   При ошибке аварийно завершает программу}
var
  k: Word;
begin
  BlockRead(F,Dest,Size,k);
  if k=Size then
    Exit;
  WriteLn('Ошибка при чтении данных из файла!');
  Halt
end;  {FontRead}
{--------}
Procedure NameInput(var FName: String);
  {Вводит и проверяет имя CHR-файла}
label
  Loop,HeadErr;
var
  k: Byte;
begin
  Write('Программа редактирования векторных BGI-шрифтов формата CHR. ');
  WriteLn('(C) 1993 В.В.Фаронов');
  {Проверяем параметры обращения}
  if ParamCount<>0 then
    FName := ParamStr(1)
  else
    FName := '';
  if FName='' then
    begin
Loop:  {Сюда возврат при ошибке в имени}
      Write('Введите имя CHR-файла (*.CHR): ');
      ReadLn(FName);
      if FName = '' then
        begin  				{Пустой ввод}
          Write('Cоздать новый шрифт (Y/N)? ');
          ReadLn(FName);
          if (FName='') or
             (UpCase(FName[1])<>'Y') then
            Halt;
          FName := '';
          Exit
        end
    end;
  {Проверяем существование файла}
  if Pos('.',FName)=0 then
    FName := FName+'.CHR';
  {$I-}  		{Отключаем контроль IOError}
  Assign(F,FName);
  Reset(F,1);       	{Пытаемся открыть файл}
  {$I+}  		{Восстанавливаем контроль IOError}
  if IOResult<>0 then
    begin
      WriteLn('Файл '+FName+' не найден');
      Goto Loop
    end;
  {Читаем заголовок файла}
  FontRead(FontHead,SizeOf(FontHead));
  if FontHead.FontFileID<>Head then
    begin
      WriteLn('Ошибка в заголовке файла!');
      Goto Loop
    end;
  {Ищем смещение блока параметров и длину файла}
  with FontHead do
    begin
      k := 5;  {Начинаем с пятого байта}
      while (k<SizeOf(FontHead)) and(B[k]<>$1A) do inc(k);
      if B[k]=$1A then
        begin
          HeaderSize := B[k+1]+B[k+2] shl 8;
          FileSize   := B[k+7]+B[k+8] shl 8;
          AFileSize := k+7;
          {Читаем блок параметров}
          Seek(F,HeaderSize);
          FontRead(FontPara,SizeOf(FontPara));
          if FontPara.ParPrefix='+' then
            Exit  		{Нормальный выход}
          else    		{Нет префикса параметров}
            Goto HeadErr
        end
    end;
  {Не найден терминатор CopyrightEnd}
HeadErr:
  Close(F);
  WriteLn('Ошибка в заголовке файла!');
  Goto Loop
end;  {NameInput}

Procedure ReadData;
  {Читает данные из файла}
var
  k: Integer;
  LastChar: Byte;
begin
  with FontPara do
    begin
      LastChar := FirstChar+CharsCount-1;
      {Заполняем таблицу смещений}
      for k := 0 to 255 do
        if k in [FirstChar..LastChar] then
          FontRead(Offsets[k],2)
        else
          Offsets[k] := 0;
      {Заполняем таблицу ширин}
      MaxW := 0;
      for k := 0 to 255 do
        if k in [FirstChar..LastChar] then
          begin
            FontRead(Widths[k],1);
            if Widths[k]>MaxW then
              MaxW := Widths[k]
          end
        else
          Widths[k] := 0;
      if MaxW<20 then
        MaxW := 20;
      {Готовим память и считываем данные}
      for k := 0 to 255 do
        LengD[k] := 0;  {Обнуляем таблицу длин}
      for k := FirstChar to LastChar do
        begin
          if k=LastChar then
          LengD[k] := FileSize-Offsets[k]-FontPara.DataOffset
          else
            LengD[k] := Offsets[k+1]-Offsets[k];
          if LengD[k]<>0 then
            begin
              GetMem(Chars[k],LengD[k]);
              FontRead(Chars[k]^,LengD[k])
            end
        end;
      Close(F);
    end;  {with FontData}
end;  {ReadData}
{--------}
Procedure BuildScreen;
  {Переводит дисплей в графический режим,
   вычисляет константы и создает экран}

Procedure PutCur(var Cur: TMouseMask);
  {Сканирует изображение в левом верхнем углу
   экрана и формирует маску указателя мыши}
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
      Cur[1,y] := b;
      Cur[0,y] := not b
    end
end;   {PutCur}
{---------}
var
  D,R,E,k,n,X,Y: Integer;
  c: Byte;
  S: String;
  Sz: Word;
  FF: File;
  Font: Pointer;
const
  Txt: array [1..6] of String[10]=(
    'Из таблицы',
    'В таблицу',
    'Очистить',
    'Образец',
    'Сохранить',
    'Конец');
  Items: array [1..6] of MouseItemType=(
    (X1:1; Y1:1; X2:13; Y2:2; Butt: LeftButton; Key:1 shl 8),
    (X1:14; Y1:1; X2:25; Y2:2;Butt: LeftButton; Key:2 shl 8),
    (X1:26; Y1:1; X2:37; Y2:2;Butt: LeftButton; Key:3 shl 8),
    (X1:38; Y1:1; X2:49; Y2:2;Butt: LeftButton; Key:4 shl 8),
    (X1:50; Y1:1; X2:61; Y2:2;Butt: LeftButton; Key:5 shl 8),
    (X1:61; Y1:1; X2:80; Y2:2;Butt: LeftButton; Key:6 shl 8));
begin {BuildScreen}
  {Переходим в графику}
  D := Detect;        		{Автоопределение драйвера}
  InitGraph(D,R,'');  		{Инициируем графику}
  E := GraphResult;   		{Проверяем результат}
  if E<>0 then
    begin             		{Есть ошибка}
      WriteLn(GraphErrorMsg(E));
      Halt
    end;
  {Выбираем шрифт в зависимости от разрешения экрана}
  case GetMaxY of
    199: c := 8;  		{CGA 8x8}
    349: c := 14; 		{EGA 8x14}
    479..1024: c := 19; 	{VGA,SVGA 8x19}
  else
	 c := 8   		{Прочие 8x8}
  end;
  with FontPara do
    MaxH := UpperMargin-LowerMargin+1;
  {Определяем границы рабочего поля}
  DYE := succ(GetMaxY) div (5*MaxH div 4);  {Высота клетки}
  DXE := succ(GetMaxX) div (2*MaxW); 	{Ширина клетки}
  XE  := DXE div 3;    			{Смещение слева}
  YE  := 2*c;          			{Смещение сверху}
  XE2 := XE+MaxW*DXE;    		{Правый нижний угол}
  YE2 := YE+MaxH*DYE;


  {Определяем размеры указателя мыши
   в рабочем поле и формируем его маски}
  dXm := XE;
  dYm := DYE div 3;
  {Проверяем наличие мыши}
  if not InitMouse then
    begin   			{Нет мыши - завершаем работу}
      CloseGraph;
      WriteLn('Нет мыши - программа не может работать');
      Halt
    end;
  {Готовим стандартный указатель}
  ShowMouse;
  MouseGotoXY(0,0);  		{В левый верхний угол}
  PutCur(CurM);      		{Получить образ}
  HideMouse;
  {Указатель-квадратик для рабочего поля}
  Rectangle(0,0,2*dXm,2*dYm);
  PutCur(CurE);      		{Получить образ}
  {Расчерчиваем рабочее поле}
  ClearWinEd;
  {Готовим координаты окна повторения символа}
  XR :=(XE2-XE) div 2;
  YR := GetMaxY-MaxH;
  sz := ImageSize(XR,YR,XR+MaxW,YR+MaxH);
  GetMem(WR,sz);
  GetImage(XR,YR,XR+MaxW,YR+MaxH,WR^);
  {Создаем таблицу символов}
  XT := XE+(MaxW+1)*DXE; 	{Левый верхний}
  YT := YE;			{угол таблицы символов}
  DXT := GetMaxX div 32;  	{Шаг по горизонту}
  DYT := GetMaxY div 20;  	{Шаг по вертикали}
  SetColor(White);        	{Белый цвет}
  for n := 0 to 255 do    	{Выводим символы}
  with FontPara do
    begin
      X := XT+(n mod 16)*DXT;
      Y := YT+(n div 16)*DYT;
      if LengD[n]<>0 then
	begin
	  SetColor(White);
	  OutChar(X,Y+DYT,n,DXT/MaxW,DYT/(MaxH+5))
	end
      else
	begin  			{Выводим недостающие символы}
	  SetColor(DarkGray);
	  OutTextXY(X,Y+DYT-8,chr(n))
        end
    end;
  {Загружаем шрифт из файла 8xH.fnt}
  Str(c,S);
  S := '8x'+S+'.fnt';
  Assign(FF,S);
  {$I-}
  Reset(FF,1);
  {$I+}
  if IOResult<>0 then
    begin
      CloseGraph;
      WriteLn('Нет шрифтового файла '+S);
      Halt
    end;
  Sz := System.FileSize(FF);
  GetMem(Font,Sz);
  BlockRead(FF,Font^,Sz,r);
  Close(FF);
  if r<>Sz then
    begin
      CloseGraph;
      WriteLn('Ошибка чтения файла '+S);
      Halt
    end;
 {Регистрируем шрифт и переназначаем ввод/вывод}
  SetFont(Font,8,c);
  GraphWriteOn;
  {Выводим строку меню}
  Colors(Black,LightGray);
  for k := 1 to 6 do with Items[k] do
    begin
    SetWindow(X1,Y1,X2,Y2-1,EmptyBorder,
              Txt[k],False,False,False);
    end;
  {Инициируем мышь}
  SetMouseItem(6,Items);
  ShowMouse;  		{Показываем указатель мыши}
  TextRatioY := c;
end;  {BuildScreen}
{--------}
Procedure NewFile(var FName: String);
  {Создает новый CHR-файл}
var
  Name: String;
  HH: ShortInt;
  H,k: Byte;
  Y: String[1];
const
  t1='Максимальная высота символов от базовой линии: ';
  t2='Расстояние до нижней кромки символа: ';
  t3='Максимальная ширина: ';
  t4='    font V1.1 Jan 12, 1989';
  t5=#13#10;
  t6='Copyright (c) 1987,1988 Borland International';
begin
  {Вводим в диалоге параметры шрифта}
  repeat
    Write('Введите 4-буквенное имя шрифта: ':55);
    ReadLn(Name);
    while Length(Name)<4 do
      Name := Name+'0';
    Name[0] := chr(4);
    for k := 1 to 4 do
      Name[k] := UpCase(Name[k]);
    Write(t1:55);
    ReadLn(H);
    H := H and 63;
    Write(t2:55);
    ReadLn(HH);
    if HH>0 then
      HH := -HH;
    Write(t3:55);
    ReadLn(MaxW);
    MaxW := MaxW and 63;
    MaxH := H-HH;
    WriteLn;
    WriteLn('Будет создан шрифт с именем '+
            Name+' со следующими параметрами:');
    WriteLn(t1:55,H);
    WriteLn(t2:55,HH);
    WriteLn(t3:55,MaxW);
    Write('Согласны (Y/N, умлч.Y)? ');
    ReadLn(Y);
  until (Y<>'') or (UpCase(Y[1])<>'N');
  {Готовим заголовок}
  for k := 1 to 128 do
    FontHead.B[k] := 0;
  for k := 1 to 16 do
    FontPara.H2[k] := 0;
  FName := Name+'.CHR';
  with FontHead do
    begin
      FontFileID := Head;
      Name := 'BGI '+Name+t4+t5+t6+t5+#0;
      for k := 1 to Length(Name) do
        B[k+4] := ord(Name[k]);
      AFileSize := k+12;
      Name := #$80#0+FName;
      Name[0] := #$1A;  			{CopyrightEnd}
      Name[7] := #0;    			{Lo[FileSize]}
      Name[8] := #0;    			{Hi[FileSize]}
      Name[9] := #1;    			{V1.}
      Name[10] := #0;
      Name[11] := #1;    			{V.1}
      for k := 0 to 11 do
        B[AFileSize-7+k] := ord(Name[k]);
    end;
  {Готовим блок параметров}
  with FontPara do
    begin
      ParPrefix := '+';
      CharsCount := 0;
      FirstChar := 0;
      DataOffset := 16;
      FillFlag := 0;
      UpperMargin := H;
      LowerMargin := HH
    end;
  {Готовим таблицу длин}
  for k := 0 to 255 do
    LengD[k] := 0;
  Assign(F,FName)
end;
{---------}
BEGIN  {Init}
  repeat
    NameInput(FName);  	{Вводим и контролируем имя файла}
    if FName<>'' then
      ReadData        	{Читаем данные из файла}
    else
      NewFile(FName)   	{Создаем новый файл}
  until FName<>'';
  BuildScreen {Создаем экран}
END;  {Init}
{-------------------}
PROCEDURE SaveFont;
  {Сохраняет шрифт в файле}
Procedure Alarm;
  {Сообщает об ошибке записи}
var
  X2,Y2,X1,Y1: Integer;
  Sz: Word;
  P: Pointer;
  C: Char;
begin
  HideMouse;
  Colors(White,Red);
  Window(15,12,65,14);
  GetWindGraphCoo(X1,Y1,X2,Y2);
  Sz := ImageSize(X1,Y1,X2,Y2);
  GetImage(X1,Y1,X2,Y2,P^);
  SetWindow(15,12,65,14,2,' Нажмите любую клавишу ',True,True,True);
  Write('Ошибка доступа к файлу!':37);
  ShowMouse;
  while not KeyPressed or not MousePressed do;
  while KeyPressed do
    C := ReadKey;
  While MousePressed do;
  HideMouse;
  PutImage(X1,Y1,P^,NormalPut);
  ShowMouse;
  FreeMem(P,Sz)
end;  {Alarm}
{---------}
Function WriteFile(var Source; S: Word): Boolean;
  {Записывает в файл S байт из переменной
   Source и контролирует результат}
var
  k: Word;
begin
  BlockWrite(F,Source,S,k);
  WriteFile := S=k;
  if S<>k then
    Alarm
end;
{---------}
var
  k: Integer;
  MinChr,MaxChr: Byte;
  W,Offs,PredO: Word;
BEGIN
  if not ChangeF then
    Exit;
  {Определяем начальный символ}
  MinChr := 0;
  while (MinChr<255) and (LengD[MinChr]=0) do
    inc(MinChr);
  if MinChr=255 then
    Exit;
  {Определяем последний символов}
  MaxChr := MinChr;
  k := MaxChr;
  while k<=255 do
    begin
      if LengD[k]<>0 then
        MaxChr := k;
      inc(k)
    end;
  {Корректируем пустые символы и подсчитываем
   длину загружаемой части}
  FileSize := 0;
  for k := MinChr to MaxChr do
    if LengD[k]=0 then
      begin  {Пустой символ}
        Widths[k] := Widths[MinChr];
        inc(FileSize,LengD[MinChr])
      end
    else
      inc(FileSize,LengD[k]);
  {Определяем смещение в файле}
  Offs := 3*(MaxChr-MinChr+1)+16;
  {Корректируем описатель шрифта}
  with FontPara do
    begin
      FirstChar := MinChr;
      CharsCount:= MaxChr-MinChr+1;
      DataOffset:= Offs;
      FileSize := FileSize+16+3*CharsCount
    end;
  {Записываем заголовок}
  With FontHead do
    begin
      B[AFileSize] := Lo(FileSize);
      B[AFileSize+1] := Hi(FileSize)
    end;
  {Готовим файл}
  {$I-}
  Rewrite(F,1);
  {$I+}
  if IOResult<>0 then
    begin
      Alarm;
      Exit
    end;
  if not WriteFile(FontHead,SizeOf(FontHead))
    then Exit;
  {Записываем описатель}
  if not WriteFile(FontPara,SizeOf(FontPara))
    then Exit;
  {Записываем таблицу смещений}
  PredO := Offs;
  for k := MinChr to MaxChr do
    begin
      W := Offs-PredO;
      if LengD[k]<>0 then
        inc(Offs,LengD[k])
      else
        inc(Offs,LengD[MinChr]);
      if not WriteFile(W,2) then
        Exit
    end;
  {Записываем таблицу ширин}
  for k := MinChr to MaxChr do
    if not WriteFile(Widths[k],1) then
      Exit;
  {Записываем данные}
  for k := MinChr to MaxChr do
    if LengD[k]<>0 then
      if not WriteFile(Chars[k]^,LengD[k]) then
        Exit
      else
    else
      if not WriteFile(Chars[k]^,LengD[MinChr])then Exit;
  Close(F);   {Все в порядке}
  ChangeF := False
END;  {SaveFont}
{-------------------}
PROCEDURE Run;
  {Основная работа: чтение мыши или клавиатуры
   и вызов нужных процедур}
var
  BM,XM,YM,B,X,Y: Integer;
  x0g,y0g,x1g,y1g: Integer; 	{Координаты резиновой нити}
  MPF: Boolean;   		{Флаг резиновой нити}
  PW:^AW;
  W,op: Word;
Procedure RepChar;
  {Повторяет символ в окне повтора}
var
  k: Word;
begin
  {Стираем старое изображение}
  PutImage(XR,YR,WR^,NormalPut);
  {Формируем новое}
  SetWriteMode(NormalPut);
  SetColor(White);
  for k := 1 to NVecE do
    with VecE[k],FontPara do
      Line(XR+X1 div DXE,YR+MaxH+LowerMargin-
          (YB-Y1) div DYE,XR+X2 div DXE,
          YR+MaxH+LowerMargin-(YB-Y2) div DYE);
end;
{---------}
Function Tabl(var N: Byte): Boolean;
  {Выбирает символ из таблицы. Возвращает
   номер символа или False для правой кнопки}
var
  X,Y,k,xx,yy,ddx,ddy: Integer;
  NX,NY,NXX,NYY: Byte;
  Sz: Word;
  P: Pointer;
begin
  HideMouse;
  ddx := DXT div 2; 		{Половина ширины}
  ddy := DYT div 2; 		{Половина высоты}
  X := XT+ddx;      		{Начальный символ}
  Y := YT+ddy;
  NX := 0;          		{Номер столбца}
  NY := 0;          		{Номер строки}
  MouseGotoXY(X,Y);
  MouseWindow(X,Y,X+16*DXT,Y+16*DYT);
  {Выделяем символ}
  Sz := ImageSize(X-ddx,Y-ddx,X+ddx,Y+ddx);
  GetMem(P,sz);
  GetImage(X-ddx,Y-ddy,X+ddx,Y+ddy,P^);
  PutImage(X-ddx,Y-ddy,P^,NotPut);
  while MousePressed do; 		{Сбрасываем кнопку}
  {Перемещаемся по таблице до нажатия на кнопку мыши}
  while not MousePressed do
    begin
      GetMouseState(k,xx,yy); 	{Текущее положение}
      NXX := (xx-XT) div DXT;
      NYY := (yy-YT) div DYT;
      if (NX<>NXX) or (NY<>NYY) then
        begin           		{Перешли в новую клетку}
          PutImage(X-ddx,Y-ddy,P^,NormalPut);
          Window(1,1,80,25);
          GotoXY(60,25);
          TextColor(White);
          TextBackGround(LightRed);
          Write(NYY*16+NXX:4,' ');
          NX := NXX;
          NY := NYY;
          X := XT+NX*DXT+ddx;
          Y := YT+NY*DYT+ddy;
          GetImage(X-ddx,Y-ddy,X+ddx,Y+ddy,P^);
          PutImage(X-ddx,Y-ddy,P^,NotPut);
        end
    end;
  {Нажата кнопка: восстанавливаем экран}
  PutImage(X-ddx,Y-ddy,P^,NormalPut);
  FreeMem(P,sz);
  GotoXY(60,25);
  Write('     ');
  GetMouseState(k,xx,yy); 	{k - нажатая кнопка}
  while MousePressed do;  	{Ждем отпускания}
  N := NY*16+NX;
  Tabl := k=LeftButton;
  ShowMouse;
  MouseScreen  			{Освобождаем мышь}
end;  {Tabl}
{---------}
Procedure ClearWE;
  {Очищает рабочее поле}
begin
  ClearWinEd;
  PutImage(XR,YR,WR^,NormalPut);
  NVecE := 0;
  WidthX := 0
end;
{---------}
Procedure GetChar;
  {Берет символ из таблицы}
var
  k: Integer;
  N: Byte;
  W,op: Word;
  xx,yy: ShortInt;
begin
  if not Tabl(N) then
    Exit;      			{Выход по правой кнопке}
  ClearWE;        		{Очищаем рабочее поле}
  PW := Chars[N]; 		{Адрес описателей}
  X := 0;         		{Начальные координаты пера}
  Y := 0;
  SetColor(Yellow);
  SetWriteMode(XORPut);
  {Цикл по командам}
  for k := 1 to LengD[N] div 2 do
    begin
      W := PW^[k];       		{Очередное слово}
      op := W and $8080; 		{Код операции}
      W := W xor op;
      xx := W and 127;   		{Координата X}
      yy := W shr 8;     		{Координата Y}
      if yy>63 then
        yy := yy-128;
      if op=$8080 then
        begin            		{Команда чертить}
          inc(NVecE);    		{Колич.векторов}
          with VecE[NVecE] do
            begin        		{Формируем новый вектор}
              X1 := XE+X*DXE;
              Y1 := YB-Y*DYE;
              X2 := XE+xx*DXE;
              Y2 := YB-yy*DYE;
              {Чертим линию в рабочем поле}
              Line(X1,Y1,X2,Y2)
            end;
        end;
      X := xx;      		{Новое положение пера}
      Y := yy
    end;
  {Чертим правую границу символа}
  WidthX := XE+Widths[N]*DXE;
  SetColor(Cyan);
  Line(WidthX,YE,WidthX,YE2);
  {Повторяем символ в окне повтора}
  RepChar
end;  {GetChar}
{---------}
Procedure SetChar;
  {Помещает символ в таблицу}
var
  k: Integer;
  N: Byte;
  W,op: Word;
  Data: AW;
  X,Y,XX1,YY1,XX2,YY2: ShortInt;
  Xc,Yc: Integer;
begin
  if not Tabl(N) then
    Exit;
  {Удаляем старый описатель}
  if LengD[N]<>0 then
    FreeMem(Chars[N],LengD[N]);
  Widths[N] := (WidthX-XE) div DXE;
  LengD[N] := 0;
  {Цикл по векторам}
  X := 0;
  Y := 0;
  for k := 1 to NVecE do with VecE[k] do
    begin
      XX1 := (X1-XE) div DXE;
      XX2 := (X2-XE) div DXE;
      YY1 := (YB-Y1) div DYE;
      YY2 := (YB-Y2) div DYE;
      if (X<>XX1) or (Y<>YY1) then
        begin {команда перехода}
          if YY1<0 then
            inc(YY1,128);
          inc(LengD[N]);
          Data[LengD[N]] := YY1 shl 8+XX1 or $80
        end;
      X := XX2;
      Y := YY2;
      if YY2<0 then
        inc(YY2,128);
      inc(LengD[N]);
      Data[LengD[N]] := YY2 shl 8+XX2 or $8080;
    end;
  {Формируем переход в конец символа}
  inc(LengD[N]);
  Data[LengD[N]] := Widths[N] or $80;
  inc(LengD[N]);
  Data[LengD[N]] := 0;  		{Конец команд}
  {Записываем в память}
  LengD[N] := 2*LengD[N];
  GetMem(Chars[N],LengD[N]);
  Move(Data,Chars[N]^,LengD[N]);
  {Чертим символ в таблице}
   HideMouse;
   Xc := XT+(N mod 16)*DXT;
   Yc := YT+(N div 16)*DYT;
   SetFillStyle(SolidFill,Black);
   Bar(Xc,Yc,Xc+DXT-1,Yc+DYT-1);
   SetColor(White);
   SetWriteMode(NormalPut);
   OutChar(Xc,Yc+DYT,N,DXT/MaxW,DYT/(MaxH+5));
   SetColor(Yellow);
   SetWriteMode(XORPut);
   ShowMouse;
   ChangeF := True
end;  {SetChar}
{---------}
Function Ned(var x,y: Integer): Boolean;
  {Возвращает TRUE и координаты узла,
   если мышь попала в его окрестности}
var
  Is: Boolean;
begin
  Is := False;
  y := YE;
  repeat
    x := XE;
    repeat
      Is := MouseIn(x-dXm,y-dYm,x+dXm,y+dYm);
      if not Is then
        inc(x,DXE)
    until Is or (x>XE2);
    if not Is then
      inc(y,DYE)
  until Is or (y>YE2);
  Ned := Is
end;  {Ned}
{---------}
Procedure MouseInNed;
  {Проверяет отметку мышью узла сетки}
var
  XN,YN: Integer;
begin
  if not Ned(XN,YN) then
    Exit;    {Не попали в узел}
  HideMouse;
  while MousePressed do;
  MouseGotoXY(XN,YN);
  if not MPF then
    begin    {Запоминаем узел}
      MPF := True;
      X0g := XN;
      Y0g := YN;
      X1g := X0g;
      Y1g := Y0g;
      SetColor(Yellow);
      SetWriteMode(XORPut);
      MouseWindow(XE,YE,XE2,YE2);
      MouseGraphCursor(CurE,dXm,dYm);
      ShowMouse
    end
  else
    begin  {Формируем новый вектор}
      MPF := False;
      if (x0g<>x1g) or (y0g<>y1g) then
        Line(x0g,y0g,x1g,y1g);
      MouseScreen;
      if (X0g<>XN) or (Y0g<>YN) then
        begin {Помещаем очередной вектор}
          inc(NVecE);
          with VecE[NVecE] do
            begin
              X1 := X0g;
              Y1 := Y0g;
              X2 := XN;
              Y2 := YN;
              Line(x1,y1,x2,y2);
              RepChar
            end;
          {Проверяем ширину символа}
          if X0g>XN then
            XN := X0g;
          if XN>WidthX then
            begin  {Смещаем правую границу}
              SetColor(Cyan);
              SetWriteMode(XORPut);
              Line(WidthX,YE,WidthX,YE2);
              WidthX := XN+4*DXE;
              if WidthX>XE2 then
                WidthX := XE2;
              Line(WidthX,YE,WidthX,YE2);
              SetColor(Yellow);
            end;
          MouseGraphCursor(CurM,0,0);
          ShowMouse
        end
    end
end;  {MouseInNed}
{---------}
Procedure MouseInLine;
  {Проверяет отметку вектора}
var
  x1m,y1m,x2m,y2m,dx,dy,x,y,n: Integer;
  Is,Sign: Boolean;
  k: Word;
  k0,y0: Real;
label
  Loop;
begin
  if MPF then
    begin {Уничтожаем резиновую нить}
      HideMouse;
      MPF := False;
      if (X0g<>X1g) or (Y0g<>Y1g) then
        Line(X0g,Y0g,X1g,Y1g);
      MouseGraphCursor(CurM,0,0);
      ShowMouse;
      MouseScreen;
      Exit
    end;
  if NVecE=0 then
    Exit;  {Пустое рабочее поле}
Loop:
  GetMouseState(x,x1m,y1m);
  if (not MousePressed) and MouseF then
    begin
      HideMouse;
      MouseGraphCursor(CurM,0,0);
      ShowMouse;
      MouseScreen;
      MouseF := False;
      Exit
    end;
  x2m := x1m+dXm;
  y2m := y1m+dYm;
  x1m := x1m-dXm;
  y1m := y1m-dYm;
  {Проверяем все векторы}
  n := 1;
  Is := False;
  repeat
    with VecE[n] do
    if (x1=x2) and (x1>=x1m) and (x1<=x2m) then
      {Вертикальный вектор}
      Is := ((y1>=y2m) and (y2<=y1m)) or
            ((y1<=y1m) and (y2>=y2m))
    else
    if (y1=y2) and (y1>=y1m) and (y1<=y2m) then
      {Горизонтальный вектор}
      Is := ((x1>=x1m) and (x2<=x2m)) or
            ((x1<=x2m) and (x2>=x1m))
    else                			{Наклонный вектор}
    if (((y1>=y2m) and (y2<=y1m)) or((y1<=y1m) and 
       (y2>=y2m))) and(((x1>=x1m) and (x2<=x2m)) or 
       ((x1<=x2m) and (x2>=x1m))) then
    begin
      k0 := (y2-y1)/(x2-x1);
      y0 := y1-k0*x1;
      for x := x1m to x2m do if not Is then
        begin
          y := Round(k0*x+y0);
          Is := (y>=y1m) and (y<=y2m);
          if not Is then
            if x=x1m then
              Sign := y<y1m
            else
            Is:= (Sign and (y>y1m)) or (not Sign and (y<y1m))
        end
    end;
    if not Is then
      inc(n)
  until Is or (n>NVecE);
  if Is then
    begin   			{Удаляем вектор}
      HideMouse;
      SetColor(Yellow);
      SetWriteMode(XORPut);
      with VecE[N] do
        Line(x1,y1,x2,y2);  	{Стираем линию}
      if NVecE>1 then       	{Перемещаем векторы}
        for  N := N to NVecE-1 do
          VecE[N] := VecE[N+1];
      dec(NVecE);
      RepChar;
      if NVecE>1 then
        begin
          MouseGraphCursor(CurE,dXm,dYm);
          MouseWindow(XE-dXm,YE-dYm,XE2+dXm,YE2+dYm);
          MouseF := True
        end
      else
        begin
          MouseGraphCursor(CurM,0,0);
          MouseScreen;
          MouseF := False
        end;
      ShowMouse;
      if MouseF then
        Goto Loop
    end
  else if MouseF then
    Goto Loop
  else if (WidthX>=x1m) and (WidthX<=x2m) then
    begin   			{Перемещаем правую границу}
      SetColor(Cyan);
      SetWriteMode(XORPut);
      HideMouse;
      MouseGraphCursor(CurE,dXm,dYm);
      ShowMouse;
      MouseWindow(XE,YE,XE2,YE2);
      while MousePressed do
        begin
          GetMouseState(n,x1m,y1m);
          if XE+DXE*Round((x1m-XE)/DXE)<>WidthX then
            begin
              HideMouse;
              Line(WidthX,YE,WidthX,YE2);
              WidthX := XE+DXE*Round((x1m-XE)/DXE);
              Line(WidthX,YE,WidthX,YE2);
              ShowMouse
            end
        end;
      MouseScreen;
      HideMouse;
      MouseGraphCursor(CurM,0,0);
      ShowMouse
    end
end;
{---------}
Procedure MouseMove;
  {Контролирует перемещение мыши}
begin
  if MPF and ((XM<>X1g) or (YM<>Y1g)) then
    begin  			{Формируем резиновую нить}
      HideMouse;
      if (X0g<>X1g) or (Y0g<>Y1g) then
      Line(X0g,Y0g,X1g,Y1g); 	{Стираем старую}
      X1g := XM;     		{Новые координаты конца}
      Y1g := YM;
      if (X0g<>X1g) or (Y0g<>Y1g) then
      Line(X0g,Y0g,X1g,Y1g);
      ShowMouse
    end;
end;  {MouseMove}
{---------}
Procedure Pattern;
  {Выбирает и помещает в рабочее поле образец}
var
 X,Y,xx,yy: Integer;
 k,op,W: Word;
 PW:^AW;
 N: Byte;
begin
  if not Tabl(N) then
    Exit;      			{Выход по правой кнопке}
  SetColor(LightGray);
  PW := Chars[N]; 		{Адрес описателей}
  X := XE;         		{Начальные координаты пера}
  Y := YB;
  {Цикл по командам}
  for k := 1 to LengD[N] div 2 do
    begin
      W := PW^[k];       		{Очередное слово}
      op := W and $8080; 		{Код операции}
      W := W xor op;
      xx := W and 127;   		{Координата X}
      yy := W shr 8;     		{Координата Y}
      if yy>63 then
        yy := yy-128;
      xx := XE+xx*DXE;
      yy := YB-yy*DYE;
      if op=$8080 then
        Line(X,Y,xx,yy);
      X := xx;      		        {Новое положение пера}
      Y := yy
    end;
  SetColor(Yellow)
end;
{---------}
BEGIN  {Run}
  SetWriteMode(XORPut);
  NVecE := 0;   			{Нет векторов в WE}
  MPF := False; 			{Мышь не нажималась}
  SetColor(Yellow);
  GetMouseState(BM,XM,YM);  	{Начальноесостояние мыши}
  While True do  	{Бесконечный цикл до команды "Конец"}
    begin
      {Проверяем выбор меню и клавиатуру}
      if KeyOrMousePressed then
      case ReadKeyOrMouse of
        #0: case ReadKeyOrMouse of
              #1:GetChar;
              #2:SetChar;
              #3:ClearWE;
              #4:Pattern;
              #5:SaveFont;
              #6: Exit;
            end;
      end;
    {Проверяем текущее состояние мыши}
      GetMouseState(B,X,Y);
      if (B<>BM) or (X<>XM) or (Y<>YM) then
        if MousePressed and
           MouseIn(XE,YE,XE2,YE2) then
          case B of  		{Контролируем кнопки}
            LeftButton :MouseInNed;
            RightButton:MouseInLine;
          end
        else {Контролируем перемещение}
          MouseMove;
      XM := X;
      YM := Y;
      BM := B
    end
END;  {Run}

PROCEDURE Done;
BEGIN
  SaveFont;
  CloseGraph;
END;  {Done}
{-------------------}
BEGIN  {Главная программа}
  Init;  	{Инициация шрифта и экрана}
  Run;   	{Редактирование или создание символов}
  Done   	{Завершение работы}
END. 


