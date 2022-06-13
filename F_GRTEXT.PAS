{$N+,E+}
{=============} Unit F_GrText; {===============}
{
    Модуль поддержки текстового ввода/вывода
              в графическом режиме.
}
{----------------------------------------------}
                  INTERFACE
{----------------------------------------------}
Uses DOS,Graph,CRT;
const
  AppHandle: Boolean = True; 	{Флаг управления
                                аппаратной поддержкой CGA/EGA/VGA}
  ESCFlag  : Boolean = False;	{Флаг завершения ввода по ESC}
{
  Следующие константы используются для указания
  типа рамки при обращении к процедуре SETWINDOW.
}
const
  EmptyBorder  = 0; 	{Стереть рамку}
  SingleBorder = 1; 	{Рамка из одинарных линий}
  DoubleBorder = 2; 	{Рамка из двойных линий}
{
  Следующий массив определяет символы псевдографики
  для вычерчивания рамок (альтернативная кодировка)
}
const
  BorderChar: array [0..2,1..6] of Char =
      ((#32,  #32,  #32,  #32,  #32,  #32),
       (#218, #196, #191, #179, #192, #217),
       (#201, #205, #187, #186, #200, #188));

Procedure ClrScr;
  {Очищает текстовое окно или экран}

Procedure Colors(Text,Back: Byte);
  {Устанавливает цвета для текстового вывода}

Function GetMaxChar: Byte;
  {Возвращает максимальное количество
   символов на строке}

Function GetMaxLine: Byte;
  {Возвращает максимальное количество строк на экране}

Procedure GetWindGraphCoo(var X1,Y1,X2,Y2: Integer);
  {Возвращает графические координаты текстового окна}

Procedure GotoXY(X,Y: Byte);
  {Перемещает курсор в заданную позицию}

Function GraphCooX(X: Byte): Integer;
  {Возвращает графическую координату по заданной
   горизонтальной текстовой координате}

Function GraphCooY(Y: Byte): Integer;
  {Возвращает графическую координату по заданной
   вертикальной текстовой координате}

Procedure GraphWriteOn;
  {Переназначает стандартные каналы ввода/вывода
   на процедуры GraphWrite и GraphRead}

Procedure GraphWriteOff;
 {Восстаналивает стандартные каналы ввода/вывода}

Procedure SetFont(Fnt: Pointer; X,Y: Byte);
  {Устанавливает текущий шрифт для текстового ввода/вывода}

Procedure Scrolling(N: Integer);
  {Осуществляет сдвиг содержимого окна вверх или вниз:
   N - количество строк, на которые сдвигается
       окно (N < 0 - сдвиг вниз)}

Procedure TextBackGround(Color: Byte);
  {Устанавливает цвет фона для символов}

Procedure TextColor(Color: Byte);
  {Устанавливает цвет символов}

Function TextCooX(X: Integer): Byte;
  {Возвращает ближайшую текстовую координату по
  заданной горизонтальной графической координате}

Function TextCooY(Y: Integer): Byte;
  {Возвращает ближайшую текстовую координату по
   заданной вертикальной графической координате}

Function WhereX: Byte;
  {Возвращает горизонтальную координату курсора}

Function WhereY: Byte;
  {Возвращает горизонтальную координату курсора}

Procedure Window(X1,Y1,X2,Y2: Byte);
  {Устанавливает текстовое окно}

Procedure SetWindow(X1,Y1,X2,Y2,Border: Byte;
      		Header: String; Clip,Build,Play: Boolean);
  {Устанавливает окно, очищает его и обводит рамкой}

Function RegisterCHRFile(S: String): Integer;
  {Регистрирует векторный шрифт, содержащийся в файле
   с именем S, и возвращает порядковый номер шрифта}

Function RegisterCHRFont(Font: Pointer): Integer;
  {Регистрирует векторный шрифт, загруженный в память
   по адресу Font, и возвращает порядковый номер шрифта}

Procedure OutString(S: String; Font: Integer;
				Angle: Integer; MX,MY: Real);
  {Выводит с помощью векторного шрифта Font строку S с
   поворотом на угол Angle и с масштабными коэффициентами MX,MY}

{----------------------------------------------}
                IMPLEMENTATION
{----------------------------------------------}
type
  aob = array [0..MaxInt] of Byte;
const
  ChangeWR: Boolean = False;    {Признак замены драйвера вывода}
  Font: ^aob = NIL;       	{Адрес массива шрифта}
  TCol: Byte = LightGray; 	{Цвет символов}
  BCol: Byte = Black;     	{Цвет фона}

var
  OldOut, OldInp: Text;
  Xt: Byte;   		{Горизонтальная координата курсора}
  Xg: Integer;
  Yt: Byte;   		{Вертикальная координата курсора}
  Yg: Integer;
  X1t,Y1t,X2t,Y2t: Byte; 	{Коор-ты активного окна}
  X1g,Y1g,X2g,Y2g: Integer;
  MaxChar: Byte;  	{Длина текстовой строки экрана}
  MaxLine: Byte;   	{Количество строк на экране}
  XF: Byte;        	{Ширина символа в пикселах}
  YF: Byte;        	{Высота символа в пикселах}
  Adapter: Byte;   	{Признак аппаратуры адаптера}

Procedure WriteChar(X,Y: Integer; Ch: Byte);
  {Выводит символ с кодом Ch в позицию X,Y}
var
  k: Integer;
  b: Byte;
  j: Byte;
begin
  for k := 0 to pred(YF) do
    begin
      b := Font^[Ch*YF+k];
      case Adapter of
      0: 		{Вывод без аппаратной поддержки}
      begin
        for j := 0 to 7 do
          if b and (128 shr j)<>0 then
            PutPixel(X*XF+j,Y+k,TCol)
          else if BCol<>0 then
            PutPixel(X*XF+j,Y+k,BCol)
      end;
      1: 		{Аппаратная поддержка EGA/VGA}
      asm
      {Вычисляем адрес байта в видеопамяти}
        mov  ax,$A000
        mov  es,ax     	{es = $A000}
        mov  bx,y      	{bx = y}
        add  bx,k      	{bx = (y+k)}
        mov  cl,4
        shl  bx,cl
        mov  dx,bx     	{dx = (y+k)*16}
        mov  cl,2
        shl  bx,cl     	{bx = (y+k)*64}
        add  bx,dx    	{bx = (y+k)*80}
        add  bx,x      	{bx = (y+k)*80+x}
      {Устанавливаем режим записи 2}
        mov  dx,$3CE
        mov  al,5
        out  dx,al
        inc  dx
        mov  al,2
        out  dx,al
      {Разрешаем изменять только биты символа}
        mov  dx,$3CE
        mov  al,8
        out  dx,al
        inc  dx
        mov  al,b      	{Разрешены биты символа}
        out  dx,al

      {Выводим символ}
        mov  al,es:[bx]
        mov  al,TCol
        mov  es:[bx],al
      {Проверяем фоновый цвет}
        mov  dl,BCol
        cmp  dl,0
        je   @0
{Изменяем биты фона для создания фонового цвета}
        mov  dx,$3CE
        mov  al,8     		{Регистр маски битов}
        out  dx,al
        inc  dx
        mov  al,b      		{Разрешить изменение}
        not  al       		{разрядов фона}
        out  dx,al
      {Выводим фон}
        mov  al,es:[bx]
        mov  al,BCol
        mov  es:[bx],al 		{Устанавливаем все биты}
      @0:
      end;
    end
  end
end;   {WriteChar}
{-------------------------}
Function GraphRead(var F: TextRec): Integer; Far;
  {Осуществляет ввод текста для процедур Read/ReadLn}
var
  X0t    : Byte;    	{Начальное положение курсора}
  YUp,YDn: Integer; 	{Размер курсора}
  InsFlag: Boolean; 	{Флаг режима вставки}
  Cur    : Pointer; 	{Изображение курсора}
  Back   : Pointer; 	{Фон курсора}
  S      : String;  	{Строка ввода}
  C      : Char;    	{Очередной символ}
const
  CSize: Word = 0;
Procedure SetCursor;
  {Устанавливает форму курсора}
var
  FillInfo: FillSettingsType;
begin
  if CSize<>0 then
    begin
      FreeMem(Back,CSize);
      FreeMem(Cur,CSize)
    end;
  YDn := Yg+YF-1;
  if InsFlag then
    YUp := YDn - 2
  else
    YUp := Yg;
  CSize := ImageSize(Xg,YUp,Xg+XF-1,YDn);
  GetMem(Back,CSize);
  GetImage(Xg,YUp,Xg+XF-1,YDn,Back^);
  GetFillSettings(FillInfo);
  SetFillStyle(SolidFill,TCol);
  Bar(Xg,YUp,Xg+XF-1,YDn);
  with FillInfo do
    SetFillStyle(Pattern,Color);
  GetMem(Cur,CSize);
  GetImage(Xg,YUp,Xg+XF-1,YDn,Cur^);
  PutImage(Xg,YUp,Back^,NormalPut);
end;   {SetCursor}
{---------}
Procedure Cursor;
  {Создает изображение мигающего курсора}
var
  k: Integer;
const
  D = 10;
begin
  GetImage(Xg,YUp,Xg+XF-1,YDn,Back^);
  while not KeyPressed do
    begin
      PutImage(Xg,YUp,Cur^,NormalPut);
      for k := 1 to 10 do
        if not KeyPressed then
          Delay(D);
      PutImage(Xg,YUp,Back^,NormalPut);
      for k := 1 to 10 do
        if not KeyPressed then
          Delay(D)
    end
end;   {Cursor}
{--------}
Procedure Home;
  {Курсор - в начало строки ввода}
begin
  GotoXY(X0t,WhereY);
end;   {Home}
{--------}
Procedure Left;
  {Курсор - на символ влево}
begin
  if WhereX>X0t then
    GotoXY(WhereX-1,WhereY)
end;   {Left}
{--------}
Procedure Right;
  {Курсор - на символ вправо}
begin
  if WhereX-X0t<Length(s) then
    GotoXY(WhereX+1,WhereY)
end;   {Right}
{--------}
Procedure EndKey;
  {Курсор - в конец строки}
begin
  GotoXY(X0t+Length(s),WhereY)
end;   {EndKey}
{--------}
Procedure Ins;
  {Переключение режима ввода}
begin
  InsFlag := not InsFlag;
  SetCursor
end;  {Ins}
{--------}
Procedure WriteString;
  {Восстанавливает ввод после редактирования}
var
  k: Byte;
begin
  for k := 1 to Length(S) do
    WriteChar(X1t+X0t+k-3,Yg,ord(S[k]));
  WriteChar(X1t+X0t+Length(S)-2,Yg,32)
end;
{--------}
Procedure Del;
  {Забить символ с курсором}
var
  n: Byte;
begin
  n := WhereX-X0t;
  if n<Length(S) then
    begin
      Delete(S,n+1,1);
      WriteString
    end
end;  {Del}
{--------}
Procedure BackSpace;
  {Забить символ слева от курсора}
var
  n: Byte;
begin
  n := WhereX-X0t;
  if n>=1 then
    begin
      Delete(S,n,1);
      WriteString;
      GotoXY(WhereX-1,WhereY)
    end
end; {Backspace}
{--------}
Procedure AnyChar;
var
  n: Byte;
begin
  n := WhereX-X0t;
  if n=Length(S) then
    if X1t+X0t+Length(S)<=X2t then
      S := S+c
    else
  else
    if InsFlag and (X1t+X0t+Length(S)<=X2t) then
      Insert(C,S,n+1)
    else
      S[n+1] := C;
  WriteString;
  GotoXY(WhereX+1,WhereY)
end;   {AnyChar}
{--------}
Procedure Enter;
  {Завершает ввод по клавише Enter}
var
  k: Byte;
begin
  with F do
    begin
      for k := 1 to Length(S) do
        BufPtr^[BufEnd+k-1] := S[k];
      BufEnd := Length(S);
      if BufEnd=0 then
        begin
          BufEnd := 1;
          BufPtr^[0] := ' '
        end
    end;
  GotoXY(1,WhereY+1)
end;   {Enter}
{--------}
Procedure ESC;
  {Выход по клавише ESC}
begin
  with F do
    begin
      BufEnd := 1;
      BufPtr^[0] := ' ';
      ESCFlag := True
    end
end;   {ESC}
{--------}
begin  {GraphRead}
  with F do if (Mode=fmInput) and (BufEnd=0) then
    begin
      X0t := WhereX;
      s := '';
      InsFlag := True;
      ESCFlag := False;
      SetCursor;
      repeat
        Cursor;
        c := ReadKey;
        case c of
        #0: case ord(ReadKey) of
            71: Home;
            75: Left;
            77: Right;
            79: EndKey;
            82: Ins;
            83: Del;
            else
              c := #0
            end;
        #8: BackSpace;
        #13: Enter;
        #27: ESC;
        else
          AnyChar
        end;
      until (c=#13) or (c=#27);
      FreeMem(Back,CSize);
      FreeMem(Cur,CSize);
      CSize := 0
    end;
  GraphRead := 0
end;   {GraphRead}
{-------------------------}
Function GraphWrite(var F: TextRec): Integer; Far;
  {Осуществляет вывод текста}
var
  Drv,Mode: Integer;
  k: Integer;
  Reg: Registers;
begin
  if Font=NIL then
    exit;
  DetectGraph(Drv,Mode);
  if AppHandle and (Drv in [3..5,9]) then
    Adapter := 1   	{EGA,VGA}
  else
    Adapter := 0;	{Другие типы или нет AppHandle}
  with F do
    if (Mode=fmOutput) and (BufPos>0) then
    begin
      for k := 0 to BufPos-1 do
        case BufPtr^[k] of
        #7: with Reg do
          begin  		{Звук}
            ah := $E;
            al := 7;
            Intr($10,Reg)
          end;
        #8: if k>BufEnd then
          begin  		                {Забой слева от курсора}
            WriteChar(Xt-2,Yg,32);
            GotoXY(WhereX-1,WhereY)
          end;
        #10: if Yt+1 in [Y1t..Y2t] then  	{Перевод строки}
               GotoXY(WhereX,WhereY+1);
        #13:     			        {Возврат каретки}
          GotoXY(1,WhereY);
        else
          begin
            WriteChar(Xt-1,Yg,ord(BufPtr^[k]));
            if Xt+1 in [X1t..X2t] then
              GotoXY(WhereX+1,WhereY)
            else if Yt+1 in [Y1t..Y2t] then
              GotoXY(1,WhereY+1)
          end
        end;
      BufPos := 0
    end;
  GraphWrite := 0
end;  {GraphWrite}
{-------------------------}
Function Zero(var F: TextRec): Integer; Far;
  {Заглушка для функций Open/Close}
begin
  Zero := 0
end;   {Zero}
{-------------------------}
Function Flush(var F: TextRec): Integer; Far;
  {Обнуляет буфер ввода}
begin
  with F do
    begin
      BufPos := 0;
      BufEnd := 0
    end;
  Flush := 0
end;
{-------------------------}
Procedure ClrScr;
  {Очищает текстовое окно или экран}
var
  FillInfo: FillSettingsType;
begin
  if Font<>NIL then
    begin
      GetFillSettings(FillInfo);
      SetFillStyle(SolidFill,BCol);
      Bar(X1g,Y1g,X2g,Y2g);
      with FillInfo do
        SetFillStyle(Pattern,Color);
      GotoXY(1,1)
    end
end;   {ClrScr}
{-------------------------}
Procedure Colors(Text,Back: Byte);
  {Устанавливает цвета для текстового вывода}
begin
  TextColor(Text);
  TextBackGround(Back)
end;   {Colors}
{--------------------------}
Function GetMaxChar: Byte;
  {Возвращает максимальное количество
   символов на строке}
begin
  GetMaxChar := MaxChar
end;   {GetMaxChar}
{-------------------------}
Function GetMaxLine: Byte;
  {Возвращает максимальное количество строк}
begin
  GetMaxLine := MaxLine
end;   {GetMaxLine}
{-------------------------}
Procedure GetWindGraphCoo(var X1,Y1,X2,Y2: Integer);
  {Возвращает графические координаты текстового окна}
begin
  X1 := X1g;
  Y1 := Y1g;
  X2 := X2g;
  Y2 := Y2g
end;   {GetWindGraphCoo}
{-------------------------}
Procedure GotoXY(X,Y: Byte);
  {Перемещает курсор в заданную позицию}
begin
  if (Font<>NIL) and (X in [1..MaxChar]) and
   (Y in [1..MaxLine]) and (X<=X2t-X1t+1) and
   (Y<=Y2t-Y1t+1) then
    begin
      Xt := X+X1t-1;
      Yt := Y+Y1t-1;
      Xg := GraphCooX(Xt);
      Yg := GraphCooY(Yt)
    end
end;   {GotoXY}
{-------------------------}
Function GraphCooX(X: Byte): Integer;
  {Возвращает графическую координату по заданной
   горизонтальной текстовой координате}
begin
  if Font<>NIL then
    GraphCooX := pred(X)*XF
  else
    GraphCooX := -1
end;   {GraphCooX}
{-------------------------}
Function GraphCooY(Y: Byte): Integer;
  {Возвращает графическую координату по заданной
   вертикальной текстовой координате}
begin
  if Font<>NIL then
    GraphCooY := pred(Y)*YF
  else
    GraphCooY := -1
end;   {GraphCooY}
{-------------------------}
Procedure GraphWriteOn;
  {Переназначает стандартные каналы ввода/вывода
   на процедуры GraphWrite и GraphRead}
begin
  if not ChangeWR then
    begin
      Move(Output,OldOut,SizeOf(Output));
      with TextRec(Output) do
        begin
          OpenFunc  := @Zero;
          CloseFunc := @Zero;
          FlushFunc := @GraphWrite;
          InOutFunc := @GraphWrite
        end;
      Move(Input,OldInp,SizeOf(Input));
      with TextRec(Input) do
        begin
          OpenFunc  := @Zero;
          CloseFunc := @Zero;
          FlushFunc := @Flush;
          InOutFunc := @GraphRead
        end;
      ChangeWR := True
    end
end;   {GraphWriteOn}
{-------------------------}
Procedure GraphWriteOff;
 {Восстаналивает стандартные каналы ввода/вывода}
begin
  if ChangeWR then
    begin
      Move(OldOut,Output,SizeOf(Output));
      Move(OldInp,Input,SizeOf(Input));
      ChangeWR := False
    end
end;   {GraphWriteOff}
{-------------------------}
Procedure SetFont(Fnt: Pointer; X,Y: Byte);
  {Устанавливает текущий шрифт для текстового ввода/вывода}
begin
  Font := Fnt;
  MaxChar := succ(GetMaxX) div X;
  MaxLine := succ(GetMaxY) div Y;
  XF := X;
  YF := Y;
  Window(1,1,MaxChar,MaxLine)
end;   {SetFont}
{-------------------------}
Procedure Scrolling(N: Integer);
  {Осуществляет сдвиг содержимого окна вверх или вниз:
   N - количество строк, на которые сдвигается окно
  (N < 0 - сдвиг вниз)}
var
  k: Byte;
  x,y: Word;
  LineSize: Word;
  P: Pointer;
  FillInfo: FillSettingsType;
begin
  GetFillSettings(FillInfo);
  SetFillStyle(SolidFill,BCol);
  LineSize := ImageSize(x1g,y1g,x2g,y1g+YF);
  if abs(N)>=Y2t-Y1t+1 then
    Bar(x1g,y1g,x2g,y2g) 		{Очистить окно}
  else if N>0 then
    begin                               {Сдвиг вверх}
      GetMem(P,LineSize);
      for k := 0 to Y2t-Y1t-N do
        begin
          GetImage(x1g,y1g+(N+k)*YF,x2g,y1g+(N+k+1)*YF,P^);
          PutImage(x1g,y1g+k*YF,P^,NormalPut)
        end;
      FreeMem(P,LineSize);
      Bar(x1g,y2g-N*YF,x2g,y2g)
    end
  else if N<0 then
    begin  			{Сдвиг вниз}
      GetMem(P,LineSize);
      N := abs(N);
      for k := Y2t-Y1t-N downto 1 do
        begin
          GetImage(x1g,y1g+(k-1)*YF,x2g,y1g+k*YF,P^);
          PutImage(x1g,y2g-(Y2t-Y1t-N-k+1)*YF,P^,NormalPut)
        end;
      FreeMem(P,LineSize);
      Bar(x1g,y1g,x2g,y1g+N*YF)
    end;
  with FillInfo do
    SetFillStyle(Pattern,Color)
end;   {Scrolling}
{------------------------}
Procedure TextBackGround(Color: Byte);
  {Устанавливает цвет фона для символов}
begin
  BCol := Color
end;   {TextBackGround}
{-------------------------}
Procedure TextColor(Color: Byte);
  {Устанавливает цвет символов}
begin
  TCol := Color
end;   {TextColor}
{-------------------------}
Function TextCooX(X: Integer): Byte;
  {Возвращает ближайшую текстовую координату по
  заданной горизонтальной графической координате}
begin
  if (Font<>NIL) and (X in [0..GetMaxX]) then
    TextCooX := round(X/MaxChar)+1
  else
    TextCooX := 0
end;   {TextCooX}
{-------------------------}
Function TextCooY(Y: Integer): Byte;
  {Возвращает ближайшую текстовую координату по
   заданной вертикальной графической координате}
begin
  if (Font<>NIL) and (Y in [0..GetMaxY]) then
    TextCooY := round(Y/MaxLine)+1
  else
    TextCooY := 0
end;   {TextCooY}
{-------------------------}
Function WhereX: Byte;
  {Возвращает горизонтальную координату курсора}
begin
  if Font<>NIL then
    WhereX := Xt-X1t+1
  else
    WhereX := 0
end;   {WhereX}
{-------------------------}
Function WhereY: Byte;
  {Возвращает горизонтальную координату курсора}
begin
  if Font<>NIL then
    WhereY := Yt-Y1t+1
  else
    WhereY := 0
end;   {WhereY}
{-------------------------}
Procedure Window(X1,Y1,X2,Y2: Byte);
  {Устанавливает текстовое окно}
begin
  if (Font<>NIL) and (X1 in [1..MaxChar]) and
    (Y1 in [1..MaxLine]) and (X2 in [1..MaxChar])
    and (Y2 in [1..MaxLine]) and (X2>=X1)
    and (Y2>=Y1) then
   begin
     Xt := X1;
     Yt := Y1;
     Xg := XF*pred(Xt);
     Yg := YF*pred(Yt);
     X1t := X1;
     Y1t := Y1;
     X2t := X2;
     Y2t := Y2;
     X1g := XF*pred(X1t);
     Y1g := YF*pred(Y1t);
     X2g := XF*X2t;
     Y2g := YF*Y2t
   end
end;   {Window}
{-------------------------}
Procedure SetWindow(X1,Y1,X2,Y2,Border: Byte;
      		Header: String; Clip,Build,Play: Boolean);
  {Устанавливает окно, очищает его и обводит рамкой}
const
  TonBeg = 400;
  TonEnd = 800;
  Pause  = 5;
  N      = 20;
var
  k,X,xx1,yy1,xx2,yy2,dx,dy: Byte;
  dt: Integer;
begin
  if (Font<>NIL) and (X1 in [1..MaxChar]) and
    (Y1 in [1..MaxLine]) and (X2 in [1..MaxChar])
    and (Y2 in [1..MaxLine]) and (X2>=X1)and (Y2>=Y1) then
   begin
     if Build and ((X2-X1>=4) or (Y2-Y1>=4)) then
       begin
         X := (X2-X1) div 2;
         if X>1 then
           begin
             xx1 := X1+X-1;
             xx2 := X1+X+1
           end
         else
           begin
             xx1 := X1;
             xx2 := X2
           end;
         X := (Y2-Y1) div 2;
         if X>1 then
           begin
             yy1 := Y1+X-1;
             yy2 := Y1+X+1
           end
         else
           begin
             yy1 := Y1;
             yy2 := Y2
           end;
         dx := (X2-X1) div N;
         if dx=0 then
           dx := 1;
         dy := (Y2-Y1) div N;
         if dy=0 then
           dy := 1;
         dt := (TonEnd-TonBeg) div N;
         for k := 0 to N-1 do
           begin
             if Play then
               Sound(TonBeg+k*dt);
             Window(xx1,yy1,xx2,yy2);
             ClrScr;
             if xx1>X1 then
               dec(xx1,dx);
             if xx2<X2 then
               inc(xx2,dx);
             if yy1>Y1 then
               dec(yy1,dy);
             if yy2<Y2 then
               inc(yy2,dy);
           end;
         NoSound
       end;
     Window(X1,Y1,X2,Y2);
     ClrScr;
     if Border in [0..2] then
       begin
         Write(BorderChar[Border,1]);
         for k := 2 to X2-X1 do
           Write(BorderChar[Border,2]);
         Write(BorderChar[Border,3]);
         for k := 2 to Y2-Y1 do
           begin
             GotoXY(1,k);
             Write(BorderChar[Border,4]);
             GotoXY(X2-X1+1,k);
             Write(BorderChar[Border,4])
           end;
         GotoXY(1,Y2-Y1+1);
         Write(BorderChar[Border,5]);
         for k := 2 to X2-X1 do
           Write(BorderChar[Border,2]);
         Write(BorderChar[Border,6])
       end;
     if Length(Header)>0 then
       begin
         if Length(Header)>X2-X1-2 then
           Header[0] := chr(X2-X1-2);
         GotoXY((X2-X1-Length(Header)) div 2+2,1);
         Write(Header)
       end;
     if Clip then
       Window(X1+1,Y1+1,X2-1,Y2-1)
   end
end;   {SetWindow}
{+--------------------------------------------+
 |   Поддержка вывода сообщений векторными    |
 |                шрифтами                    |
 +--------------------------------------------+}
type
  PFontDesc =^TFontDesc;
  TFontDesc = record      	{Описатель шрифта}
    NextFont: PFontDesc;  	{Ссылка на следующий}
    NFont   : Integer;    	{Номер шрифта}
    Name: record
    case Byte of
    0:(FName: String);    	{Имя файла}
    1:(Flag : Byte;       	{Флаг формата}
       Addrs: record      	{Адрес}
         sa,oa: Word
       end)
    end;
    FirstChr : Byte;      	{Первый символ}
    LastChar : Byte;      	{Последний символ}
    Height: ShortInt;     	{Высота от базы}
    Bottom: ShortInt;     	{Высота до низа}
    Offs: array [0..255] of Word; {Смещения}
    Leng: array [0..255] of Word; {Длины}
  end;
  TFontPara = record  		{Блок параметров шрифта}
    ParPrefix : Char; 		{Символ "+"}
    CharsCount: Word;  		{Количество символов в шрифте}
    Reserv1   : Byte;  		{Не используется}
    FirstChar : Byte;  		{Код первого символа}
    DataOffset: Word;  		{Смещение до векторных 
				команд первого символа}
    FillFlag   : Byte; 		{Флаг заливки}
    UpperMargin: Byte; 		{Высота символов}
    Reserv2    : Byte; 		{Не используется}
    LowerMargin: ShortInt; 	{Нижняя кромка}
    Reserv3 : array [1..5] of Byte
  end;
  THead = array [1..4] of Char;
const
  FontList: PFontDesc = NIL; 	{Список шрифтов}
  FontNumb: Integer = 0;     	{Количество шрифтов}
var
  FDesc: TFontDesc;
  F: File;
  Buf: array [1..128] of Byte; 	{Заголовок}
  Head: THead absolute Buf;
  FPar: TFontPara;             	{Параметры шрифта}
const
  Head0: THead = ('P','K',#8,#8);


Function RegisterCHRFile(S: String): Integer;
  {Регистрирует векторный шрифт, содержащийся в
   файле с именем S, и возвращает порядковый номер шрифта}
var
  k: Integer;
  Err: Boolean;
  P,PD: PFontDesc;
  ParOffs: Word;

Function ReadFile(var Dest; Size: Word): Boolean;
  {Читает Size байт из файла F в переменную Dest}
begin
  BlockRead(F,Dest,Size,k);
  ReadFile := k=Size
end;
{---------}
begin
  {Проверяем и корректируем имя}
  if pos('.',S)=0 then
    S := S+'.chr';
  {Проверяем по списку, чтобы исключить повторную регистрацию}
  if FontNumb<>0 then
    begin
      FDesc := FontList^;
      with FDesc do
      while (NextFont<>NIL) and (S<>Name.FName) do
        FDesc := NextFont^;
      if S=FDesc.Name.FName then
        begin  		{Найден в списке - вернуть номер}
          RegisterChrFile := FDesc.NFont;
          Exit
        end
    end;
  {Открываем файл}
  RegisterChrFile := -1;
  Assign(F,S);
  {$I-}
  Reset(F,1);
  {$I+}
  if IOResult<>0 then
    Exit;
  {Читаем заголовок}
  if not ReadFile(Buf,128) then
    Exit;
  RegisterChrFile := -2;
  if Head<>Head0 then
    Exit;    		{Неверный формат файла}
  {Ищем конец текста}
  repeat
    k := 1;
    while (k<=128) and (Buf[k]<>$1A) do
      inc(k);
    if k=129 then
      if not ReadFile(Buf,128) then
        Exit
  until Buf[k]=$1A;
  {Позиционируем файл на блок параметров}
  ParOffs := Buf[k+1]+Buf[k+2] shl 8;
  Seek(F,ParOffs);

  {Читаем параметры}
  if not ReadFile(FPar,16) or (FPar.ParPrefix<>'+') then
    Exit;
  {Резервируем память для описателя}
  RegisterChrFile := -3;
  if MaxAvail<SizeOf(TFontDesc) then
    Exit;  			{Нет памяти для регистрации}
  New(PD);
  {Формируем новый дескриптор}
  with PD^,FPar do
    begin
      NextFont := NIL;
      NFont := FontNumb+1;
      Name.FName := S;
      FirstChr := FirstChar;
      LastChar := FirstChar+CharsCount-1;
      Height := UpperMargin;
      Bottom := LowerMargin;
      {Читаем таблицу смещений}
      RegisterChrFile := -1;
      Seek(F,ParOffs+DataOffset-3*CharsCount);
      if not ReadFile(Offs[FirstChar],2*CharsCount) then
        begin
          Dispose(PD);
          Exit
        end;
      {Настраиваем смещения}
      for k := FirstChar to LastChar do
        Offs[k] := Offs[k]+ParOffs+DataOffset;
      {Формируем таблицу длин}
      for k := FirstChar to LastChar-1 do
        Leng[k] := Offs[k+1]-Offs[k];
      Leng[LastChar] := FileSize(F)-
        Offs[LastChar-1]-ParOffs
    end;
  {Формируем список описателей}
  if FontNumb=0 then
    FontList := PD         	{Список был пустым}
  else
    begin                  	{Ищем конец списка}
      P := FontList;       	{Начало списка}
      while P^.NextFont<>NIL do
        P := P^.NextFont;  	{Next=NIL - конец}
      P^.NextFont := PD
    end;
  inc(FontNumb);
  RegisterChrFile := FontNumb
end;  {RegisterChrFile}
{-------------------}
Function RegisterCHRFont(Font: Pointer): Integer;
  {Регистрирует векторный шрифт, загруженный в память
   по адресу Font, и возвращает порядковый номер шрифта}

type
  TByte = array [0..65534] of Byte;
var
  PH: ^THead;
  PP: ^TFontPara;
  PB: ^TByte absolute PH;
  P,PD: PFontDesc;
  k: integer;
  ParOffset: Word;
  FileSize: Word;
begin
  {Проверяем начало заголовка}
  PH := Font;
  RegisterChrFont := -2;
  if PH^<>Head0 then
    Exit;    			{Нет поля 'PK'#8#8}
  k := 4;    			{Ищем CopyrightEnd}
  while (PB^[k]<>$1A) and (k<256) do
    inc(k);
  if PB^[k]<>$1A then
    Exit;    		        {Не нашли терминатор в 256 байтах}
  {Проверяем блок параметров}
  ParOffset := PB^[k+1]+PB^[k+2] shl 8;
  FileSize := PB^[k+7]+PB^[k+8] shl 8;
  PP := Addr(PB^[ParOffset]);
  if PP^.ParPrefix<>'+' then
    Exit;  			{Нет префикса параметров}
  {Резервируем память для описателя}
  RegisterChrFont := -3;
  if MaxAvail<SizeOf(TFontDesc) then
    Exit;  			{Нет памяти для регистрации}
  New(PD);
  {Формируем новый дескриптор}
  with PD^,PP^ do
    begin
      NextFont := NIL;
      NFont := FontNumb+1;
      Name.Flag  := 0;     		{Шрифт - в памяти}
      k := ParOffset+DataOffset;
      Name.Addrs.sa := seg(PB^[k]);  	{Адрес}
      Name.Addrs.oa := ofs(PB^[k]);  	{шрифта}
      FirstChr := FirstChar;
      LastChar := FirstChar+CharsCount-1;
      Height := UpperMargin;
      Bottom := LowerMargin;
      {Переносим таблицу смещений}
      k := ParOffset+DataOffset-3*CharsCount;
      Move(PB^[k],Offs[FirstChar],2*CharsCount);
      {Формируем таблицу длин}
      for k := FirstChar to LastChar-1 do
        Leng[k] := Offs[k+1]-Offs[k];
      Leng[LastChar] := FileSize-Offs[LastChar-1]
    end;
  {Формируем список описателей}
  if FontNumb=0 then
    FontList := PD         		{Список был пустым}
  else
    begin                  		{Ищем конец списка}
      P := FontList;       		{Начало списка}
      while P^.NextFont<>NIL do
        P := P^.NextFont;  		{Next=NIL - конец}
      P^.NextFont := PD
    end;
  inc(FontNumb);
  RegisterChrFont := FontNumb
end;  {RegisterChrFont}
{-------------------}
Procedure OutString(S: String; Font: Integer;
                  Angle: Integer; MX,MY: Real);
  {Выводит с помощью векторного шрифта Font строку S с
   поворотом на угол Angle и с масштабными коэффициентами MX,MY}
var
  x0,y0: Integer; {Начало очередного символа}
  Ang: Real;
Procedure OutChar(var V);
  {Выполняет векторные команды V}
var
  Vec: array [1..MaxInt] of Word absolute V;
  k,op: Word;
Procedure Coo(X,Y: Integer; var xx,yy: Integer);
  {Осуществляет поворот координат X,Y на угол
   Angle и возвращает новые координаты xx,yy}
var
  r,a: Single;
begin
  {Переводим в полярные координаты}
  r := sqrt(1.0*x*x+1.0*y*y);
  if x=0 then if y<0 then
    a := -pi/2
  else
    a := pi/2
  else
    a := arctan(y/x);
  a := a+Ang;   {Поворот координат}
  {Вычисляем новые координаты}
  yy := Round(r*sin(a));
  xx := Round(r*cos(a))
end;  {Coo}
{---------}
var
  x,y,x1,y1,xx,yy: Integer;
begin  {OutChar}
  k := 1;
  x := x0;
  y := y0;
  repeat
    op := Vec[k] and $8080;
    xx := Vec[k] and $7F;
    yy := (Vec[k] shr 8) and $7F;
    if yy>63 then
      yy := yy-128;
    {Учитываем масштабные коэффициенты}
    xx := Round(xx*MX);
    yy := Round(yy*MY);
    {Поворачиваем на угол Angle}
    Coo(xx,yy,x1,y1);
    x1 := x0+x1;
    y1 := y0-y1;
    {Вычерчиваем вектор}
    if op=$8080 then
      Line(x,y,x1,y1);
    {Переходим в новую точку}
    if op<>0 then
      begin
        x := x1;
        y := y1
      end;
    {Проверяем конец команд}
    if op=0 then
      begin   		{Готовим вывод следующего}
        x0 := x;
        y0 := y
      end
    else
      inc(k)
  until Op=0
end;  {OutChar}
{---------}
var
  F: File;
  k,j: Word;
  c: Byte;
  Buf: array [1..1000] of Word;
  P: PFontDesc;
  PB: Pointer;
begin {OutString}
  {Ищем регистрацию шрифта}
  if (FontNumb=0) or
     (Font>FontNumb) or (S='') then
    Exit;  		{Нет ни одного шрифта, пустая
            		строка или неверный номер шрифта}
  P := FontList;
  {Переводим угол в радианы}
  Ang := Angle*pi/180;
  for k := 1 to Font-1 do
    P := P^.NextFont;
  with P^ do
    begin
      if Name.FName<>'' then
        begin
          Assign(F,Name.FName);
          {$I-}
          Reset(F,1);
          {$I+}
          if IOResult<>0 then
            Exit;  		{Ошибка доступа к файлу}
        end;
      x0 := GetX;  		{Текущие координаты}
      y0 := GetY;
      for k := 1 to Length(S) do
        begin
          c := ord(S[k]);
          if c in [FirstChr..LastChar] then
            if Name.FName<>'' then
              begin 		{Берем шрифт из файла}
                {$I-}
                Seek(F,Offs[c]);
                BlockRead(F,Buf,Leng[c],j);
                {$I+}
                if (IOResult=0) and (Leng[c]=j) then
                OutChar(Buf)
              end
            else  		{Шрифт загружен в память}
              with Name.Addrs do
              begin
                PB := ptr(sa,oa+Offs[c]);
                OutChar(PB^)
              end
        end;
      MoveTo(x0,y0);
      if Name.FName<>'' then
        Close(F)
    end
end;  {OutString}
{============} end. {F_GrText}  {=============}
