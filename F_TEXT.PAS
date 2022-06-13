{============}    Unit F_Text;    {=============}
{+---------------------------------------------+
 | В этот модуль входят подпрограммы поддержки |
 | многостраничного вывода в текстовом режиме  |
 +---------------------------------------------+}
                   INTERFACE
{-----------------------------------------------}
Uses CRT, DOS;
{
  Следующие константы используются для указания
  типа рамки при обращении к процедурам BORDER,
  SETWINDOW и PUTWINDOW.
}
const
  EmptyBorder  = 0; {Стереть рамку}
  SingleBorder = 1; {Рамка из одинарных линий}
  DoubleBorder = 2; {Рамка из двойных линий}
{
  Следующий массив определяет символы
  псевдографики для вычерчивания рамок
  (альтернативная кодировка)
}
  BorderChar: array [0..2,1..6] of Char =
      ((#32,  #32,  #32,  #32,  #32,  #32),
       (#218, #196, #191, #179, #192, #217),
       (#201, #205, #187, #186, #200, #188));
type
  PageType = record      {Описатель страницы}
  case Byte of
  0:(Attrib   : Byte;    {Атрибут символов}
     CLineUp  : Byte;    {Верхняя строка курсора}
     CLineDown: Byte;    {Нижняя строка курсора}
     CVisible : Boolean; {Признаквидимого курсора}
     WBondUp  : Word;    {Левый верхнийугол окна}
     WBondDown: Word);   {Правый нижний угол}
  1:(PagePar: array [1..8] of Byte)
  end;
const
  Pages: array [0..7] of PageType =
  ((PagePar:(7,6,7,1,0,0,79,24)),
   (PagePar:(7,6,7,1,0,0,79,24)),
   (PagePar:(7,6,7,1,0,0,79,24)),
   (PagePar:(7,6,7,1,0,0,79,24)),
   (PagePar:(7,6,7,1,0,0,79,24)),
   (PagePar:(7,6,7,1,0,0,79,24)),
   (PagePar:(7,6,7,1,0,0,79,24)),
   (PagePar:(7,6,7,1,0,0,79,24)));
{
  Адрес регистра статуса адаптера CGA
}
  PortCGA = $3DA;
{
  Начало видеопамяти для CGA/EGA/VGA
}
  BegVideo = $B800;
{
  Следующие константы зависят от режима работы и типа
адаптера. Значения по умолчанию соответствуют CGA/EGA/VGA
в режиме CO80. Эти значения  можно переопределить с помощью
процедуры InitText
}
const
  MaxPage : Byte = 3;    		{Максимальный номер страницы}
  MaxChar : Byte = 80;   		{Количество символов в строке}
  MaxLine : Byte = 25;   		{Количество строк на экране}
  PageSize: Word = 4000; 		{Размер видимой страницы}
  VSize   : Word = 4096; 		{Полный размер страницы}
  VMemory : Word = BegVideo; 	        {Адрес видеопамяти}
  VMW: array [0..15] of Word =
   ($0000,BegVideo,$1000,BegVideo,$2000,BegVideo,
    $3000,BegVideo,$4000,BegVideo,$5000,BegVideo,
    $6000,BegVideo,$7000,BegVideo);
{
  Массив VMP содержит адреса всех видеостраниц.
  Значения по умолчанию соответствуют адаптерам
  CGA/EGA/VGA в режиме CO80. Эти значения можно
  переопределить с помощью процедуры InitText
}
var
  VMP: array [0..7] of Pointer absolute VMW;
{
*-----------------------------------------------*
|         Подпрограммы управления цветом        |
*-----------------------------------------------*
}
PROCEDURE ChangeAttribute(Page,X1,Y1,X2,Y2,OldAtt,NewAtt: Byte);
  {Меняет атрибут OLDATT на значение NEWATT в
   прямоугольнике X1...Y2 страницы PAGE}

PROCEDURE Colors(Text,Back: Byte);
  {Устанавливает цвет текста TEXT и фона BACK   в текущей странице}

PROCEDURE PageColors (Page,Text,Back: Byte);
  {Устанавливает цвет текста TEXT и фона BACK в странице PAGE}

FUNCTION PackAttribute(Text,Back: Byte): Byte;
  {Упаковывает два цвета в байт атрибута}

PROCEDURE SetAttribute(Page,X1,Y1,X2,Y2,Attr: Byte);
  {Заменяет атрибут всех символов
   в прямоугольнике  X1...Y2 страницы PAGE на значение Attr}

PROCEDURE UnPackAttribute(Attr: Byte; var Text,Back: Byte);
  {Распаковывает байт атрибутаи возвращает два цвета}
{
*----------------------------------------------*
|        Подпрограммы управления курсором      |
*----------------------------------------------*
}
PROCEDURE CursorOff;
  {Отключает курсор в активной странице}

PROCEDURE CursorOn;
  {Включает курсор в активной странице}

PROCEDURE CursorOnOff (Page: Byte; Vis: Boolean);
  {Устанавливает признак видимости курсора:
  PAGE - номер страницы;
  VIS  - признак видимости}

PROCEDURE GetCursor (Page: Byte; var X,Y,Up,Down: Byte);
  {Возвращает координаты курсора:
  PAGE - номер страницы;
  X,Y - возвращаемые координаты (отсчет от 1,1);
  Up, Down - размер курсора в строках развертки}

FUNCTION GetCursorVisible(Page: Byte): Boolean;
  {Возвращает признак видимости курсора}

PROCEDURE PutCursor(Page,X,Y: Byte);
  {Устанавливает требуемое положение курсора.
  PAGE - номер страницы;
  X,Y - координаты курсора (отсчет от 1,1)}

PROCEDURE SetCursorLine(Page,Up,Down: Byte);
  {Устанавливает размер курсора}
{
*----------------------------------------------*
|  Подпрограммы управления текстовым выводом   |
*----------------------------------------------*
}
PROCEDURE Border (Page,X1,Y1,X2,Y2,Bord: Byte);
  {Обводит рамкой заданную прямоугольную область
   страницы PAGE:
    X1..Y2 - координаты окна;
    BORD - константа 0..2, указывающая тип рамки.
  Символы рамки выводятся c текущими атрибутами}

PROCEDURE CopyChar (Page: Byte; Cr: Char;
                    Attr: Byte; Count: Word);
  {Записывает несколько копий символа, начиная
   с позиции, на которую указывает курсор :
    PAGE  - номер 0..MaxPage  страницы;
    CR    - копируемый символ;
    ATTR  - его атрибуты;
    COUNT - количество копий символа.
  Символ записывается с указанными атрибутами,
  курсор не меняет своего положения}

PROCEDURE GetChar (Page: Byte;var Cr: Char; var Attr: Byte);
  {Читает символ и его атрибуты:
    PAGE - номер  0..MaxPage  страницы,
           откуда нужно прочитать символ;
    CR   - прочитанный символ;
    ATTR - его атрибуты}

PROCEDURE InitText;
  {Переопределяет константы, зависящие от адаптера и режима
   его работы. Содержимое экрана не меняется}

PROCEDURE MoveFromScreen (var Source, Destin;Count: Word);
  {Читает данные из видеопамяти :
  SOURCE - адрес считываемой видеопамяти;
  DESTIN - имя переменной,куда будут прочитаны данные;
  COUNT  - объем считываемой информации в байтах}

PROCEDURE MoveToScreen (var Source, Destin;Count: Word);
  {Записывает данные в видеопамять :
  SOURCE - переменная, содержащая записываемую информацию;
  DESTIN - адрес фрагмента видеопамяти;
  COUNT  - объем записываемой информации}

PROCEDURE PageWriteOn;
  {Переназначает стандартный канал вывода на процедуру
   PAGEWRITE, поддерживающую вывод в любую страницу}

PROCEDURE PageWriteOff;
  {Восстанавливает стандартный канал вывода}

PROCEDURE PutChar (Page: Byte; Cr: Char);
  {Записывает символ на место,указываемое курсором:
   PAGE - номер 0..MaxPage страницы;
   CR  - записываемый символ;
  Символ записывается с текущими атрибутами,
  курсор не меняет своего положения}

PROCEDURE WriteChar (Page: Byte; Cr: Char);
  {Выводит символ и сдвигает курсор.
   Используются текущие атрибуты}
{*-----------------------------------------------*
 |Многостраничные варианты подпрограмм модуля CRT|
 *-----------------------------------------------*}
PROCEDURE ClrEOL;
  {Удаляет остаток строки справа от курсора
   в активной странице}

PROCEDURE ClrScr;
  {Очищает текущее окно (страницу)}

PROCEDURE DelLine;
  {Удаляет строку в активной странице}

PROCEDURE GotoXY(X,Y: Byte);
  {Устанавливает курсор в активной странице}

PROCEDURE InsLine;
  {Вставляет пустую строку в активной странице}

PROCEDURE TextBackGround(Color: Byte);
  {Устанавливает цвет фонав активной странице}

PROCEDURE TextColor(Color: Byte);
  {Устанавливает цвет символовв активной странице}

FUNCTION WhereX: Byte;
  {Возвращает горизонтальную координату курсора
   в активной странице}

FUNCTION WhereY: Byte;
  {Возвращает вертикальную координату курсора
   в активной странице}

PROCEDURE Window(X1,Y1,X2,Y2: Byte);
  {Устанавливает окно в активной странице}
{*----------------------------------------------*
 |        Подпрограммы управления страницами    |
 *----------------------------------------------*}
FUNCTION GetActivePage: Byte;
  {Возвращает номер активной текстовой страницы}

PROCEDURE GetPage (Page: Byte; var Destin);
  {Копирует текстовую страницу в оперативную память:
  PAGE   - номер копируемой страницы;
  DESTIN - переменная, куда будет копироваться страница}

PROCEDURE SwapPage (Source, Destin: Byte);
  {Копирует одну текстовую страницу в другую:
  SOURCE - номер страницы-источника информации;
  DESTIN - номер страницы-приемника}

FUNCTION PageSaveSize: Word;
  {Возвращает размер буфера, необходимый для
   сохранения текущего состояния видеостраницы}


PROCEDURE PutPage (var Source; Page: Byte);
  {Пересылает копию текстовой страницы
   из оперативной памяти в видеопамять:
  SOURCE - имя переменной, хранящей копию страницы;
  PAGE   - номер страницы-приемника информации}

PROCEDURE RestorePage(Page: Byte; var Buf);
  {Восстанавливает текущее состояние
   страницы PAGE по содержимому буфера BUF}

PROCEDURE SetActivePage(Page: Byte);
  {Устанавливает активной заданную текстовую
  страницу.  PAGE - номер страницы}

PROCEDURE SavePage(Page: Byte; var Buf);
  {Сохраняет текущее состояние страницы PAGE в буфере BUF}
{*----------------------------------------------*
 |        Подпрограммы управления окнами        |
 *----------------------------------------------*}
PROCEDURE ChangeWindAttribute(Page,OldAtt,NewAtt: Byte);
  {Заменяет в окне PAGE атрибут OLDATT
   на значение NEWATT}

PROCEDURE CopyWind(Page,X,Y: Byte;var Buf; LX,LY: Byte);
  {Переносит копию окна из памяти на страницу}

PROCEDURE GetWindow (Page: Byte);
  {Восстанавливает состояние экрана, бывшее перед
   обращением к процедуре PUTWINDOW:
    PAGE - номер страницы, куда была скопирована активная}

PROCEDURE PutWindow(X1,Y1,X2,Y2,Text,Back,Bord,Page: Byte;
                        Header: String;Clip,Build,Play: Boolean);
  {Сохраняет активную страницу в заданной
  текстовой странице, создает в активной странице окно с
  заданными атрибутами, очищает его и обводит рамкой:
    X1...Y2 - координаты окна;
    TEXT - цвет символов;
    BACK - цвет фона;
    BORD - константа, указывающая тип рамки;
    PAGE - номер 0..MaxPage страницы, куда
           будет скопирована активная страница;
    HEADER - заголовок окна;
    CLIP - признак границ (TRUE - исключая X1...Y2,
			  FALSE - включая границы X1...Y2);
    BUILD- признак развертывания окна;
    PLAY - надо ли сопровождать звуком}

PROCEDURE SaveWind(Page: Byte; var Buf; var LX,LY: Byte);
  {Сохраняет копию окна в буфере BUF}

PROCEDURE SetPageWindow (Page,X1,Y1,X2,Y2,Bord: Byte; 
			Header: String; Clip: Boolean);
  {Создает окно в странице PAGEи обводит его рамкой:
    PAGE - номер страницы;
    X1...Y2 - координаты окна;
    BORD - константа, указывающая тип рамки;
    HEADER - заголовок окна;
    CLIP - признак границ (TRUE - внутри X1...Y2,
           FALSE - включая границы X1...Y2).
  Символы рамки выводятся с текущими атрибутами,
  окно очищается}

PROCEDURE SetWindAttribute(Page,Attr: Byte);
  {Устанавливает новый атрибут окна}

PROCEDURE SetWindow (X1,Y1,X2,Y2,Bord: Byte;
       Header: String; Clip,Build,Play: Boolean);
  {Создает окно в активной страницеи обводит его рамкой:
    X1...Y2 - координаты окна;
    BORD - константа, указывающая тип рамки;
    HEADER - заголовок окна;
    CLIP - признак границ (TRUE - внутри X1...Y2,
           FALSE - включая границы X1...Y2);
    BUILD- признак развертывания окна;
    PLAY - надо ли сопровождать звуком.
  Символы рамки выводятся с текущими атрибутами,
  окно очищается}

PROCEDURE WindMoveTo(Page,X,Y: Byte;var Buf; ClipW: Boolean);
  {Перемещает окно в новое положение:
   PAGE - номер страницы;
   X,Y  - новые координаты левого верхнего угла;
   BUF  - вид экрана без окна;
   CLIPW- признак отсечки изображения}

PROCEDURE WindMoveRel(Page: Byte; DX,DY: Integer;
                      var Buf; ClipW: Boolean);
  {Смещает окно относительно прежнего положения:
   PAGE - номер страницы;
   DX,DY- приращения координат
          левого верхнего угла;
   BUF  - вид экрана без окна;
   CLIPW- признак отсечки изображения}


FUNCTION WindSize(Page: Byte): Word;
  {Возвращает размер буфера для сохранения окна}
{-----------------------------------------------}
                IMPLEMENTATION
{-----------------------------------------------}
var
  Reg: registers;
const
  ActivePage: Byte = 0;  {Номер активной страницы}
{
*----------------------------------------------*
|        Подпрограммы управления цветом        |
*----------------------------------------------*
}
PROCEDURE ChangeAttribute(Page,X1,Y1,X2,Y2,
                          OldAtt,NewAtt: Byte);
  {Меняет атрибут OLDATT на значение NEWATT
   в прямоугольнике X1...Y2 страницы PAGE}
var
  Buf: array [1..80,1..2] of Byte;
  k,j,Size: Byte;
BEGIN
  {Проверяем параметры обращения}
  if (Page<=MaxPage) and (X1 in [1..MaxChar])
    and (Y1 in [1..MaxLine])and (X2 in [1..MaxChar])
    and (Y2 in [1..MaxLine])and (X2>X1) and (Y2>Y1) then
    begin
      Size := (X2-X1+1)*2;  {Размер строкивидеобуфера}
      for k := Y1 to Y2 do  {Цикл по строкам}
        begin
        {Получаем копию видеопамяти}
          MoveFromScreen(Mem[VMemory:Page*VSize+
            (pred(k)*MaxChar+X1-1)*2],Buf,Size);
        {Меняем атрибут}
          for j := 1 to Size div 2 do
            if Buf[j,2] = OldAtt then
              Buf[j,2] := NewAtt;
        {Возвращаем в видеопамять}
          MoveToScreen(Buf,Mem[VMemory:Page*VSize+
            (pred(k)*MaxChar+X1-1)*2],Size)
        end
    end
END;   {ChangeAttribute}
{------------------------}
PROCEDURE Colors (Text,Back: Byte);
  {Устанавливает цвет текста TEXT
  и цвет фона BACK для активной страницы}
BEGIN
  PageColors(ActivePage,Text,Back)
END;
PROCEDURE PageColors (Page,Text,Back: Byte);
  {Устанавливает цвет текста TEXT
  и цвет фона BACK для страницы PAGE}
BEGIN
  if Page<=MaxPage then
    begin
      Pages[Page].Attrib := (Text and $8F) or
        ((Back and $7) shl 4) or (Back and $80);
      if Page=0 then
        begin
          CRT.TextColor(Text);
          CRT.TextBackGround(Back)
        end
    end
END   {Colors};
{------------------------}
PROCEDURE SetAttribute(Page,X1,Y1,X2,Y2,Attr: Byte);
  {Заменяет атрибут всех символовв прямоугольнике  X1...Y2


   страницы PAGE на значение Attr}
var
  Buf: array [1..80,1..2] of Byte;
  k,j,Size: Byte;
BEGIN
  {Проверяем параметры обращения}
  if (Page<=MaxPage) and (X1 in [1..MaxChar])
    and (Y1 in [1..MaxLine])and (X2 in [1..MaxChar])
    and (Y2 in [1..MaxLine])and (X2>X1) and (Y2>Y1) then
    begin
      Size := (X2-X1+1)*2;
      for k := Y1 to Y2 do
        begin
          MoveFromScreen(Mem[VMemory:Page*VSize+
            (pred(k)*MaxChar+X1-1)*2],Buf,Size);
          for j := 1 to Size div 2 do
            Buf[j,2] := Attr;
         MoveToScreen(Buf,Mem[VMemory:Page*VSize+
            (pred(k)*MaxChar+X1-1)*2],Size)
        end
    end
END;   {SetAttribute}
{--------------------}
FUNCTION PackAttribute(Text,Back: Byte): Byte;
  {Упаковывает два цвета в байт атрибута}
BEGIN
  PackAttribute := (Text and $8F) or
           ((Back and 7) shl 4) or (Back and $80)
END;   {PackAttrinute}
{--------------------}
PROCEDURE UnPackAttribute(Attr: Byte;
                          var Text,Back: Byte);
  {Распаковывает байт атрибута
  и возвращает два цвета}
BEGIN
  Text := Attr and $8F;
  Back := (Attr shr 4) and 7
END;   {UnPackAttribute}
{*----------------------------------------------*
 |        Подпрограммы управления курсором      |
 *----------------------------------------------*}
PROCEDURE CursorOff;
  {Отключает курсор в активной странице}
BEGIN
  with Reg do
    begin
      AH := 1;     {Управление курсором}
      CH := $20    {Убрать курсор}
    end;
  Intr($10,Reg);
  Pages[ActivePage].CVisible := False
END    {CursorOff};
{------------------------}
PROCEDURE CursorON;
  {Включает курсор в активной странице}
BEGIN
  with Reg,Pages[ActivePage] do
    begin
      AH := 1;         {Управление курсором}
      CH := CLineUp;   {Верхняя строка развертки}
      CL := CLineDown  {Нижняя строка}
    end;
  Intr($10,Reg);
  Pages[ActivePage].CVisible := True
END    {CursorOn};
{---------------------------}
PROCEDURE CursorOnOff(Page: Byte; Vis: Boolean);
  {Устанавливает признак видимости курсора}
BEGIN
  if Page<=MaxPage then
    if Page=ActivePage then
      case Vis of
        True : CursorOff;
        False: CursorOn
      end
    else
      Pages[Page].CVisible := Vis
END;   {CursorOnOff}
{-------------------------}
PROCEDURE GetCursor (Page: Byte;var X,Y,Up,Down: Byte);
  {Возвращает координаты и размер курсора:
  PAGE - номер страницы;
  X, Y - координаты (отсчет от 1,1);
  Up, Down - размер курсора}
BEGIN
  if Page<=MaxPage then with Reg,Pages[Page] do
    begin
      AH := 3;       	{Получаем положение курсора}
      BH := Page;      	{Номер страницы}
      Intr($10,Reg);
      X := succ(DL);   	{Преобразуем координаты}
      Y := succ(DH);   	{к началу в 1,1}
      Up := CLineUp;   	{Верхняя строка развертки}
      Down := CLineDown 	{Нижняя строка}
    end
END    {GetCursor};
{------------------------}
FUNCTION GetCursorVisible(Page: Byte): Boolean;
  {Возвращает признак видимости курсора}
BEGIN
  GetCursorVisible := Pages[Page].CVisible
END;   {GetCursorVisible}
{-----------------------}
PROCEDURE PutCursor(Page,X,Y: Byte);
  {Устанавливает требуемое положение курсора.
  PAGE - номер страницы;
  X, Y - координаты курсора (отсчет от 1,1)}
BEGIN
  {Проверяем параметры обращения}
  if (Page<=MaxPage)
      and (X in [1..MaxChar])
      and (Y in [1..MaxLine]) then with Reg do
        begin
          AH := 2;        	{Установить курсор}
          DH := pred(Y); 		{Преобразуем координаты}
          DL := pred(X);  	{к началу в 0,0}
          BH := Page;     	{Страница}
          Intr($10,Reg)
        end
END   {PutCursor};
{--------------------------}
PROCEDURE SetCursorLine(Page,Up,Down: Byte);
  {Устанавливает размер курсора}
BEGIN
 if Page in [0..MaxPage] then with Pages[Page] do
    begin
      CLineUp := Up;
      CLineDown := Down;
      if Page=ActivePage then
        SetActivePage(Page)
    end
END;   {SetCursorLine}
{*----------------------------------------------*
 |  Подпрограммы управления текстовым выводом   |
 *----------------------------------------------*}
var
  OldOutput: Text; {Сохраняетстандартный канал вывода}
const
  ChangeOut: Boolean = False; {Флаг замены канала вывода}


PROCEDURE WriteCharXY(Page,X,Y: Byte; Cr: Char);
  {Выводит символ на указанное место.Атрибуты берутся 


   из массива Attrib.Курсор остается на месте}
var
  Loc: Word;  		{Старое положение курсора}
BEGIN
  Loc := MemW[$0040:$0050+Page];
  with Reg do
    begin
      AH := 2;
      DL := X-1;
      DH := Y-1;
      BH := Page;
      Intr($10,Reg);   	{Переводим курсор}
      AH := $9;
      AL := ord(Cr);
      BL := Pages[Page].Attrib;
      BH := Page;
      CX := 1;
      Intr($10,Reg);     {Выводим символ}
      AH := 2;
      DX := Loc;
      BH := Page;
      Intr($10,Reg)   	{Курсор - на старое место}
    end;
  MemW[$0040:$0050+Page] := Loc
END;   {WriteCharXY}
{--------------------------}
FUNCTION ZeroFunc(var F: TextRec): Integer; Far;
  {Пустая процедура для операций OPEN/CLOSE}
BEGIN
  ZeroFunc := 0
END;   {ZeroFunc}
{--------------------------}
PROCEDURE Border (Page,X1,Y1,X2,Y2,Bord: Byte);
  {Обводит рамкойзаданную прямоугольную область экрана}
var
  i : Integer;
BEGIN
  {Проверяем параметры обращения}
  if not ((Page>MaxPage) or (X1<1) or (X2<=X1) or
          (Y1<1) or (Y2<=Y1) or (X2>MaxChar) or
          (Y2>MaxLine) or (Bord>2)) then
    begin
      WriteCharXY(Page,X1,Y1,BorderChar[Bord,1]);
      for i := 1 to X2-X1-1 do   		{Верхняя рамка}
        WriteCharXY(Page,X1+i,Y1,BorderChar[Bord,2]);
      WriteCharXY(Page,X2,Y1,BorderChar[Bord,3]);
      for i := 1 to Y2-Y1-1 do  		{Боковые стороны}
        begin
          WriteCharXY(Page,X1,Y1+i,BorderChar[Bord,4]);
          WriteCharXY(Page,X2,Y1+i,BorderChar[Bord,4])
        end;
      WriteCharXY(Page,X1,Y2,BorderChar[Bord,5]);
      for i := 1 to x2-x1-1 do   		{Нижняя рамка}
        WriteCharXY(Page,X1+i,Y2,BorderChar[Bord,2]);
      WriteCharXY(Page,X2,Y2,BorderChar[Bord,6])
    end
END    {Border};
{--------------------------}
PROCEDURE CopyChar(Page:Byte; Cr:Char;Attr:Byte; Count:Word);
  {Выводит несколько копий символа}
BEGIN
  if (Count>0) and (Page<=MaxPage) then
    with Reg do begin
      AH := 9;         {Вывод символа}
      AL := ord(Cr);   {Код символа}
      BL := Attr;      {Атрибут}
      BH := Page;      {Страница}
      CX := Count;     {Количество копий}
      Intr($10,Reg)
    end
END    {CopyChar};
{--------------------------}
PROCEDURE GetChar (Page: Byte;var Cr: Char; var Attr: Byte);
  {Читает символ, на который указывает курсор,и его атрибуты}
BEGIN
  if Page<=MaxPage then with Reg do
    begin
      AH := 8;         		{Читать символ}
      BH := Page;      		{Страница}
      Intr($10,Reg);
      Cr := chr(AL);   		{Символ}
      Attr := AH       		{Его атрибут}
    end
  else          			{Неверная страница}
    begin
      Cr   := chr(0);
      Attr := 0
    end
END    {GetChar};


PROCEDURE InitText;
  {Переопределяет константы, зависящие от адаптера и режима


   его работы. Содержимоеэкрана не меняется}
var
  k: Byte;
  Size: Word;
  Page: Byte;
BEGIN
{Определяем тип адаптера
 по байту оборудования ДОС}
  case (MemW[$0040:$0010] and $30) shr 4 of
    3: begin  			{MDA}
         MaxPage := 0;
         VMemory := $B000
       end;
    else begin  			{Остальные адаптеры}
         MaxPage := 3;
         VMemory := $B800
       end;
  end;
{Определяем режим работы адаптера}
  case Mem[$0040:$0049] of
    0,1: MaxChar := 40; 		{40x25}
    2,3: MaxChar := 80; 		{80x25}
    7  : begin          		{MDA}
           MaxChar := 80;
           VMemory := $B000
         end;
    else
      MaxChar := 80
  end;
{Вычисляем остальные константы}
  MaxLine := 25;
  PageSize := MaxLine*MaxChar*2;
  Page := ActivePage;
  for k := 0 to 7 do
    begin
      SetActivePage(k);
      VMW[2*k] := MemW[$0040:$004E]
    end;
  VSize := VMW[2]-VMW[0];
  SetActivePage(Page)
END;   {InitText}
{--------------------------}
PROCEDURE MoveFromScreen (var Source,Destin;Count: Word);
  {Читает данные из видеопамяти}
BEGIN
  if Count>0 then
  if not CheckSnow then
    Move(Source,Destin,Count)
  else
{Синхронизация переноса для адаптера CGA}
    asm
	lds  si,[Source] 	{DS:SI = адрес источника}
  	les  di,[Destin] 	{ES:DI = адрес приемника}
  	mov  cx,Count    	{Загружаем счетчик в CX}
  	cld              	{Направление передачи}
  	shr  cx,1        	{Заменяем байты на слова}
  	mov  dx,PortCGA       {Загружаем в DXадрес CGA-пopтa}
{ Отсюда начинается цикл чтения из видеопамяти,
   который продолжается во время обратного хода
   луча при горизонтальной развертке.
}
@1: 	cli        	{Закрываем прерывания}
@2:	in   al,dx 	{В начале очередного цикла}
  	test al,1    	{проверяем наличие обратного хода}
  	jne  @2      	{Ждем обратный ход}
  	lodsw        	{Получаем видеослово}
  	sti          	{Открываем прерывания}
  	stosw        	{Пишем видеослово в приемник}
  	loop @1        	{Продолжаем цикл}
    end
END; {MoveFromScreen}
{------------------------}
PROCEDURE MoveToScreen (var Source, Destin;Count: Word);
  {Записывает данные в видеопамять}
BEGIN
  if Count>0 then
  if not CheckSnow then
    Move (Source,Destin,Count)
  else
{Синхронизация переноса для адаптера CGA}
    asm
  	lds  si,[Source] 	{DS:SI = адрес источника}
  	les  di,[Destin] 	{ES:DI = адрес приемник}
  	mov  cx,Count    	{Грузим в CX счетчик}
  	cld              	{Направление передачи}
  	shr  cx,1       		{Переводим байты в слова}
  	mov  dx,PortCGA 	{Получаем в DXстатус CGA-пopтa}
  	mov  bl,9       	{Готовим в BL 
			 маску проверкиготовности}
{Отсюда начинается цикл записи в видеопамять, который 


 продолжается во время обратного хода луча при горизонтальной 


 развертке. Запись проходит при закрытых прерываниях.}
@3:	lodsw       	{Получаем в BP}
  	mov  bp,ax    	{очередное видеослово}
  	cli           	{Закрываем прерывания}
@4:	in   al,dx  	{Получаем статус видеопорта}
  	test al,1     	{Конец горизонтального хода?}
  	jne  @4       	{Нет - ждем}
  	mov  ax,bp    	{Переносим в AX видеослово}
  	stosw        	{Пишем его в видеопамять}
  	sti           	{Открываем прерывания}
  	loop @3       	{Продолжаем цикл}
    end
END;  {MoveToScreen}
{--------------------------}
FUNCTION PageWrite(var F: TextRec): Integer; Far;
  {Осуществляет вывод строки, подготовленнойпроцедурами 


   WRITE/WRITELN, в активнуювидеостраницу}
var
  k: Integer;
BEGIN
  with F,Pages[ActivePage] do
  if (Mode=fmOutput) and (BufPos>0) then
    begin
      for k := 0 to BufPos-1 do with Reg do
          WriteChar(ActivePage,BufPtr^[k]);
      BufPos := 0    	{Обнуляем буфер вывода}
    end;
  PageWrite := 0
END;   {PageWrite}
{--------------------------}
PROCEDURE PageWriteOff;
  {Восстанавливает стандартный канал вывода}
BEGIN
  if ChangeOut then
    begin
      move(OldOutput,Output,SizeOf(Output));
      ChangeOut := False
    end
END;   {PageWriteOff}
{------------------------}
PROCEDURE PageWriteOn;
  {Переназначает стандартный канал выводана процедуру 


   PAGEWRITE, поддерживающуювывод в любую страницу}
BEGIN
  if ChangeOut then
    Exit;  		{Блокируем повторную установку}
  ChangeOut := True;
  {Сохраняем старый драйвер:}
  move(Output,OldOutput,SizeOf(Output));
  with TextRec(Output) do
    begin   		{Назначаем новый драйвер:}
      OpenFunc  := @ZeroFunc;
      InOutFunc := @PageWrite;
      FlushFunc := @PageWrite;
      CloseFunc := @ZeroFunc;
    end
END;   {PageWriteOn}
{--------------------------}
PROCEDURE PutChar (Page: Byte; Cr: Char);
  {Записывает символ на место, указываемое курсором в 
   заданной странице. Курсорне меняет положения.Атрибуты 


   берутся из массива Attrib}
BEGIN
  if Page<=MaxPage then with Reg do
    begin
      AH := $9;
      AL := ord(Cr);
      BH := Page;
      BL := Pages[Page].Attrib;
      CX := 1;
      Intr($10,Reg)
    end
END    {PutChar};
{--------------------------}
PROCEDURE WriteChar (Page: Byte; Cr: Char);
  {Выводит символ и сдвигает курсор. Используются
   атрибуты из массива Attrib}
var
  X,Y,X1,Y1,X2,Y2,Size: Byte;
  Buf: array [1..80,1..2] of Char;
  VW,k: Word;
  P: Pointer;
BEGIN
  if Page<=MaxPage then with Reg,Pages[Page] do
    begin
      GetCursor(Page,X,Y,X1,Y1);
      {Смещение в странице}
      k := (Pred(Y)*MaxChar+Pred(X))*2;
      P := ptr(VMemory,VMW[Page*2]+k);
      VW := Pages[Page].Attrib shl 8+ord(Cr);
      case Cr of 		{Обрабатываем спецсимволы}
      #7: begin			{Звук}
            Sound(900);
            Delay(150);
            NoSound;
            Exit
          end;
      #8: if X>Lo(WBondUp)+2 then		{Back Space}
            dec(X,2)
          else if Y>Hi(WBondUp)+2 then
            begin
              X := Lo(WBondDown);
              dec(Y)
            end;
      #10: inc(X,80);			{LF}
      #13: X := Lo(WBondUp);		{CR}
      else
        MoveToScreen(VW,P^,2);
      end;
      Inc(X);                 		{Сдвигаем в строке}
      if X-1>Lo(WBondDown) then
      {Достигнута правая граница окна}
        begin
         X := Lo(WBondUp)+1; 		{Возвращаем к левой}
         inc(Y);        		    {границе на новой строке}
          if Y-1>Hi(WBondDown) then
            begin  {Достигли нижнюю границу}
 {Делаем прокрутку с помощью прямого обращенияк видеопамяти, 


  т.к. функция 6 работает толькос активной страницей}
              dec(Y);
              X1 := Lo(WBondUp);
              Y1 := Hi(WBondUp);
              X2 := Lo(WBondDown);
              Y2 := Hi(WBondDown);
              Size := 2*(X2-X1+1);
            for k := Y1+1 to Y2 do
              begin
               MoveFromScreen(Mem[VMemory:Page*
               		VSize+(k*MaxChar+X1)*2],Buf,Size);
               MoveToScreen(Buf,Mem[VMemory:Page*
               		VSize+((k-1)*MaxChar+X1)*2],Size)
              end;
              for k := 1 to 1+X2-X1 do
                Buf[k,1] := ' ';
              MoveToScreen(Buf,Mem[VMemory:Page*
                		VSize+(Y2*MaxChar+X1)*2],Size)
            end
        end;
      PutCursor(Page,X,Y)
    end
END;   {WriteChar}
{*-------------------------------------------------*
 | Многостраничные варианты подпрограмм модуля CRT |
 *-------------------------------------------------*}
PROCEDURE ClrEOL;
{Удаляет остаток строки справа от курсорав активной странице}
var
  X1,X2: Byte;
  P: Pointer;
  X,Y: Byte;
  Buf: array [1..80] of Word;
BEGIN
  GetCursor(ActivePage,X,Y,X1,X2);
  with Pages[ActivePage] do
    begin
      P := Ptr(VMemory,VMW[ActivePage*2]+
				(Pred(Y)*MaxChar+Pred(X))*2);
      X2 := PagePar[7]-X+2;
      for X := 1 to X2 do
        Buf[X] := 32+Attrib shl 8;
      MoveToScreen(Buf,P^,X*2)
    end
END;   {ClrEOL}
{--------------------------}
PROCEDURE ClrScr;
  {Очищает текущее окно (страницу)}
BEGIN
  with Pages[ActivePage],Reg do
    begin
      AH := 6;              {С помощью прокрутки}
      AL := 0;              {очищаем все окно}
      BH := Attrib;
      CL := Lo(WBondUp);
      CH := Hi(WBondUp);
      DL := Lo(WBondDown);
      DH := Hi(WBondDown);
      Intr($10,Reg);
      AH := 2;             {Устанавливаем курсор}
      BH := ActivePage;    {в левый верхний угол}
      DX := WBondUp;
      Intr($10,Reg)
    end
END;   {ClrScr}
{--------------------------}
PROCEDURE DelLine;
  {Удаляет строку в активной странице}
var
  k,
  S,            	{Длина строки окна}
  Y: Byte;      	{Номер строки с курсором}
  C: Word;      	{Смещение в памяти для левой границы окна}
  Buf: array [1..80,1..2] of Char; 	{Буфер строк}
  P: Pointer;
BEGIN
 {Стираем строку прокруткой окна вверх}
  with Pages[ActivePage] do
    begin
    {Определяем положение в видеопамяти 


	левой верхней границы окна}
      C := VMW[ActivePage*2]+PagePar[5]*2;
      Y := PagePar[6]+Pred(WhereY);
      S := (PagePar[7]-PagePar[5]+1)*2;
      {Переносим по строкам}
      for K := Y+1 to PagePar[8] do
        begin
          P := Ptr(VMemory,C+K*MaxChar*2);
          MoveFromScreen(P^,Buf,s);
          P := Ptr(VMemory,C+(K-1)*MaxChar*2);
          MoveToScreen(Buf,P^,s)
        end;
      {Готовим пустую строку}
      for K := 1 to 80 do
        begin
          Buf[k,1] := ' ';
          Buf[k,2] := chr(Attrib)
        end;
      {Выводим ее}
      P := Ptr(VMemory,C+PagePar[8]*MaxChar*2);
      MoveToScreen(Buf,P^,s)
    end
END;   {DelLine}

PROCEDURE GotoXY(X,Y: Byte);
  {Устанавливает курсор в активной странице}
BEGIN
  with Pages[ActivePage] do
    PutCursor(ActivePage,Lo(WBondUp)+X,Hi(WBondUp)+Y)
END;   {GotoXY}
{-------------------------}
PROCEDURE InsLine;
  {Вставляет пустую строку в активной странице}
var
  k,
  S,            {Длина строки окна}
  Y: Byte;      {Номер строки с курсором}
  C: Word;      {Смещение в памятидля левой границы окна}
  Buf: array [1..80,1..2] of Char; 	{Буфер строк}
  P: Pointer;
BEGIN
  with Pages[ActivePage] do
    begin
      {Определяем положение в видеопамяти
          левой верхней границы окна}
      C := VMW[ActivePage*2]+PagePar[5]*2;
      Y := PagePar[6]+Pred(WhereY);
      S := (PagePar[7]-PagePar[5]+1)*2;
      {Переносим по строкам}
      for K := PagePar[8]-1 downto Y do
        begin
          P := Ptr(VMemory,C+K*MaxChar*2);
          MoveFromScreen(P^,Buf,s);
          P := Ptr(VMemory,C+(K+1)*MaxChar*2);
          MoveToScreen(Buf,P^,s)
        end;
      {Готовим пустую строку}
      for K := 1 to 80 do
        begin
          Buf[k,1] := ' ';
          Buf[k,2] := chr(Attrib)
        end;
      {Выводим ее}
      P := Ptr(VMemory,C+Y*MaxChar*2);
      MoveToScreen(Buf,P^,s)
    end
END;   {InsLine}
{--------------------------}
PROCEDURE TextBackGround(Color: Byte);
  {Устанавливает цвет фонав активной странице}
BEGIN
  Pages[ActivePage].Attrib :=
 		(Pages[ActivePage].Attrib and $8F) or 
		((Color and $7) shl 4);
  if ActivePage=0 then
    CRT.TextBackGround(Color)
END;   {PageTextBackGround}
{--------------------------}
PROCEDURE TextColor(Color: Byte);
  {Устанавливает цвет символов
   в активной странице}
BEGIN
  Pages[ActivePage].Attrib :=
     (Pages[ActivePage].Attrib and $70) or (Color and $8F);
  if ActivePage=0 then
    CRT.TextColor(Color)
END;   {PageTextColor}
FUNCTION WhereX: Byte;
  {Возвращает горизонтальную координату курсора
   в активной странице}
var
  X,Y,U,D: Byte;
BEGIN
  GetCursor(ActivePage,X,Y,U,D);
  WhereX := X-Lo(Pages[ActivePage].WBondUp)
END;   {WhereX}
{--------------------------}
FUNCTION WhereY: Byte;
  {Возвращает вертикальную координату курсора
   в активной странице}
var
  X,Y,U,D: Byte;
BEGIN
  GetCursor(ActivePage,X,Y,U,D);
  WhereY := Y-Hi(Pages[ActivePage].WBondUp)
END;   {WhereY}
{--------------------------}
PROCEDURE Window(X1,Y1,X2,Y2: Byte);
  {Устанавливает окно в активной странице}
BEGIN
  {Проверяем параметры обращения}
 if (X1 in [1..MaxChar]) and (X2 in [1..MaxChar])
     and (X2>X1) and (Y1 in [1..MaxLine]) and
     (Y2 in [1..MaxLine]) and (Y2>Y1)
  then with Pages[ActivePage] do
    begin
      WBondUp := pred(X1)+pred(Y1) shl 8;
      WBondDown := pred(X2)+pred(Y2) shl 8;
      PutCursor(ActivePage,X1,Y1);
      if ActivePage=0 then
        CRT.Window(X1,Y1,X2,Y2)
    end
END;
{*----------------------------------------------*
 |       Подпрограммы управления страницами     |
 *----------------------------------------------*}
FUNCTION GetActivePage: Byte;
  {Возвращает номер активной текстовой страницы}
BEGIN
  GetActivePage := ActivePage
END    {GetActivePage};
{---------------------------}
PROCEDURE GetPage (Page: Byte; var Destin);
  {Копирует текстовую страницу в оперативную память}
BEGIN
  if Page<=MaxPage then
    MoveFromScreen(Mem[VMemory:VSize*page],
                   Destin,MaxChar*MaxLine*2)
END    {GetPage};
{------------------------}
FUNCTION PageSaveSize: Word;
  {Возвращает размер буфера, необходимый для
  сохранения текущего состояния видеостраницы}
BEGIN
  PageSaveSize := PageSize+SizeOf(PageType)
END;   {PageSaveSize}
{------------------------}
PROCEDURE PutPage (var Source; Page: Byte);
  {Пересылает содержимое оперативной памяти
  в страницу видеопамяти}
BEGIN
  if Page<=MaxPage then
    MoveToScreen(Source,Mem[VMemory:VSize*Page],
                              MaxChar*MaxLine*2)
END    {PutPage};
{--------------------------}
PROCEDURE RestorePage(Page: Byte; var Buf);
  {Восстанавливает текущее состояние
  страницы PAGE по содержимому буфера BUF}
var
  B: array [0..MaxInt] of Byte absolute Buf;
BEGIN
  if Page>MaxPage then Exit;
  MoveToScreen(B,VMP[Page]^,PageSize);
  Move(B[PageSize],Pages[Page],SizeOf(PageType));
  if Page=ActivePage then
    SetActivePage(ActivePage)
END;   {RestorePage}
{--------------------------}
PROCEDURE SavePage(Page: Byte; var Buf);
  {Сохраняет текущее состояниестраницы PAGE в буфере BUF}
var
  B: array [0..MaxInt] of Byte absolute Buf;
BEGIN
  if Page>MaxPage then Exit;
  MoveFromScreen(VMP[Page]^,B,PageSize);
  Move(Pages[Page],B[PageSize],SizeOf(PageType))
END;   {SavePage}
{------------------------}
PROCEDURE SetActivePage (Page : Byte);
  {Активизирует заданную текстовую страницу}
BEGIN
  if Page<=MaxPage then with Reg,Pages[Page] do
    begin
      AH := 5;             	{Установить страницу}
      AL := Page;          	{Номер страницы}
      ActivePage := Page;  	{КорректируемActivePage}
      Intr ($10,Reg);
      if CVisible then     	{Включаем/отключаем}
        CursorOn           	{курсор}
      else
        CursorOff;
      TextAttr := Attrib; 	{Устанавливаем атрибут}
      WindMin := WBondUp;  	{Текущее окно}
      WindMax := WBondDown
    end;
END    {SetActivePage};
{------------------------}
PROCEDURE SwapPage (Source, Destin: Byte);
{ Копирует одну текстовую страницу в другую }
var
  buf : array [1..2, 1..80] of Byte;
  i   : Integer;
BEGIN
  if (Source<=MaxPage) and (Destin<=MaxPage) then
  for i := 0 to MaxLine-1 do
    begin
      MoveFromScreen(Mem[VMemory:VSize*
         Source+i*MaxChar*2],buf,MaxChar*2);
      MoveToScreen(buf,Mem[VMemory:VSize*
         Destin+i*MaxChar*2],MaxChar*2)
    end
END    {SwapPage};
{*----------------------------------------------*
 |        Подпрограммы управления окнами        |
 *----------------------------------------------*}
PROCEDURE ChangeWindAttribute(Page,OldAtt,NewAtt: Byte);
  {Заменяет в окне атрибут OLDATTна значение NEWATT}
var
  X1,Y1,X2,Y2: Byte;
BEGIN
  if Page<=MaxPage then with Pages[Page] do
    begin
      X1 := Lo(WBondUp);
      Y1 := Hi(WBondUp);
      X2 := Lo(WBondDown)+2;
      Y2 := Hi(WBondDown)+2;
      ChangeAttribute(Page,X1,Y1,X2,Y2,OldAtt,NewAtt)
    end
END;   {ChangeWindAttribute}
{-----------------------}
PROCEDURE CopyWind(Page,X,Y: Byte; var Buf; LX,LY: Byte);
  {Переносит копию окна из памяти на страницу}
var
  X2,Y2,k: Byte;
  Size: Word;
  B: array [0..MaxInt] of Byte absolute Buf;
BEGIN
  if (X in [1..MaxChar]) and (Y in [1..MaxLine])
    and (Page<=MaxPage) then with Pages[Page] do
    begin
      X2 := X+LX-1;
      if X2>MaxChar then
        X2 := MaxChar;
      Y2 := Y+LY-1;
      if Y2>MaxLine then
        Y2 := MaxLine;
      Size := (X2-X+1)*2;
      for k := Y to Y2 do
        MoveToScreen(B[(k-Y)*LX*2],Mem[VMemory:Page*VSize+ 


			(pred(k)*MaxChar+X-1)*2],Size);
      WBondUp := X+Y shl 8;
      WBondDown := X2-2+(Y2-2) shl 8;
      if Page=ActivePage then
        SetActivePage(Page)
    end
END;   {CopyWind}
{------------------------}
PROCEDURE GetWindow (Page: Byte);
  {Восстанавливает состояние экрана, бывшее
  перед обращением к процедуре PUTWINDOW}
var
  X,Y,U,D: Byte;
BEGIN
  if (Page<=MaxPage) and (Page<>ActivePage) then
    begin
      SwapPage(Page,ActivePage);
      Move(Pages[Page],Pages[ActivePage],SizeOf(PageType));
      GetCursor(Page,X,Y,U,D);
      PutCursor(ActivePage,X,Y);
      SetCursorLine(ActivePage,U,D);
      SetActivePage(ActivePage)
    end
END    {GetWindow};


PROCEDURE PutWindow(X1,Y1,X2,Y2,Text,Back,Bord,Page: Byte; 


		   Header: String;Clip,Build,Play: Boolean);
 {Сохраняет текущий экран в текстовой странице PAGE и   организует окно с 
заданными атрибутами и рамкой}
var
  X,Y,U,D: Byte;
BEGIN
  if not ((Page>MaxPage) or (X1<1) or (X2<=X1) or(Y1<1) or 
    (Y2<=Y1) or (X2>MaxChar) or(Y2>MaxLine) or (Bord>2)) then
    begin
      SwapPage(ActivePage,Page);
      Move(Pages[ActivePage],Pages[Page],SizeOf(PageType));
      GetCursor(ActivePage,X,Y,U,D);
      PutCursor(Page,X,Y);
      SetCursorLine(Page,U,D);
      Colors(Text,Back);
      SetWindow(X1,Y1,X2,Y2,Bord,Header,Clip,Build,Play)
    end;
END    {PutWindow};
{------------------------}
PROCEDURE SaveWind(Page: Byte; var Buf; var LX,LY: Byte);
  {Сохраняет копию окна в буфере BUF}
var
  X1,Y1,X2,Y2: Byte;
  B: array [0..MaxInt] of Byte absolute Buf;
  k: Byte;
BEGIN
  if Page<=MaxPage then with Pages[Page] do
    begin
      X1 := Lo(WBondUp);
      Y1 := Hi(WBondUp);
      X2 := Lo(WBondDown)+2;
      Y2 := Hi(WBondDown)+2;
      LX := X2-X1+1;
      LY := Y2-Y1+1;
      for k := Y1 to Y2 do
        MoveFromScreen(Mem[VMemory:Page*VSize+
          (pred(k)*MaxChar+X1-1)*2],B[(k-Y1)*LX*2],LX*2)
    end
END;   {SaveWind}
{------------------------}
PROCEDURE SetPageWindow (Page,X1,Y1,X2,Y2,Bord: Byte; 
			Header: String;Clip: Boolean);
  {Создает окно в странице PAGEи обводит его рамкой}
var
  buf: array [1..80,1..2] of Byte;
  X,Y,Size,k: Byte;
BEGIN
  if not ((Page>MaxPage) or (X1<1) or (X2<=X1) or(Y1<1) or 
    (Y2<=Y1) or (X2>MaxChar) or(Y2>MaxLine) or (Bord>2)) then
    begin
{Очищаем прямоугольное окно на экране}
      Size := X2-X1+1;
      for Y := 1 to Size do
        begin
          buf[Y,1] := ord(' ');
          buf[Y,2] := Pages[Page].Attrib
        end;
      Size := Size+Size;
      for Y := Y1 to Y2 do
        MoveToScreen(Buf,Mem[VMemory:Page*VSize+
          (pred(Y)*MaxChar+pred(X1))*2],Size);
{Обводим его рамкой и выводим заголовок}
      if Bord<>EmptyBorder then
         Border(Page,X1,Y1,X2,Y2,Bord);
      if Length(Header)>0 then
        begin
          if Length(Header)>X2-X1-2 then
            Header[0] := chr(X2-X1-2);
          X := X1+(X2-X1-Length(Header)) div 2;
          for k := 1 to Length(Header) do
            WriteCharXY(Page,X+k,Y1,Header[k]);
        end;
{Корректируем границы внутрь прямоугольника
 X1...Y2, если признак Clip равен True}
      if Clip then
        begin
          inc(X1);
          inc(Y1);
          dec(X2);
          dec(Y2)
        end;
{Устанавливаем курсор в левую вершину
 и запоминаем координаты}
       dec(X1); 		{Преобразуем координаты}
       dec(Y1); 		{к началу в точке 0,0}
       dec(X2);
       dec(Y2);
       PutCursor(Page,X1+1,Y1+1);
       Pages[Page].WBondUp :=X1+Y1 shl 8;
       Pages[Page].WBondDown :=X2+Y2 shl 8;
       if Page=ActivePage then
         SetActivePage(Page)
     end
END    {SetPageWindow};
{------------------------}
PROCEDURE SetWindAttribute(Page,Attr: Byte);
  {Устанавливает новый атрибут окна}
var
  X1,Y1,X2,Y2: Byte;
BEGIN
  if Page<=MaxPage then with Pages[Page] do
    begin
      X1 := Lo(WBondUp);
      Y1 := Hi(WBondUp);
      X2 := Lo(WBondDown)+2;
      Y2 := Hi(WBondDown)+2;
      SetAttribute(Page,X1,Y1,X2,Y2,Attr)
    end
END;   {SetWindAttribute}
{------------------------}
PROCEDURE SetWindow (X1,Y1,X2,Y2,Bord: Byte;
       Header: String; Clip,Build,Play: Boolean);
  {Создает окно в активной страницеи обводит его рамкой}
var
  xx1,yy1,xx2,yy2,x,y,dx,dy,k: Byte;
  dt: Integer;
const
  TonBeg = 400;  		{Начальный тон}
  TonEnd = 800;  		{Конечный тон}
  Pause  = 5;
  N      = 10;
BEGIN
  if Build and ((x2-x1>=4) or (y2-y1>=4)) then
    begin
  {Начальное положение левого верхнего угла окна}
      x := (x2-x1) div 2;
      y := (y2-y1) div 2;
  {Количество промежуточных окон}
      dx := ((x2-x1) div 2) div N;
      dy := ((y2-y1) div 2) div N;
      if dx=0 then
        inc(dx);
      if dy=0 then
        inc(dy);
      if x>1 then
        begin
          xx1 := x1+x-1;
          xx2 := x2-x+1
        end
      else
        begin
          xx1 := x1;
          xx2 := x2
        end;
      if y>1 then
        begin
          yy1 := y1+y-1;
          yy2 := y2-y+1
        end
      else
        begin
          yy1 := y1;
          yy2 := y2
        end;
      {Изменение тона}
        dt := (TonEnd-TonBeg) div N;
      for k := 0 to N-1 do   		{Цикл построения}
        begin
          if Play then
            Sound(TonBeg+dt*k);   	{Включаем звук}
          SetPageWindow(ActivePage,
               	xx1,yy1,xx2,yy2,Bord,Header,Clip);
          {Увеличиваем границы окна}
          if xx1>x1 then
            dec(xx1,dx);
          if xx2<x2 then
            inc(xx2,dx);
          if yy1>y1 then
            dec(yy1,dy);
          if yy2<y2 then
            inc(yy2,dy);
          Delay(Pause)
        end;
      if Play then
        NoSound;
    end;
  SetPageWindow(ActivePage,X1,Y1,X2,Y2,Bord,Header,Clip)
END;   {SetWindow}
{------------------------}
PROCEDURE WindMoveRel(Page: Byte; DX,DY: Integer;
                      var Buf; ClipW: Boolean);
  {Смещает окно относительно прежнего положения:
   PAGE - номер страницы;
   DX,DY- приращения координатлевого верхнего угла;
   BUF  - вид экрана без окна;
   CLIPW- признак отсечки изображения}

var
  X,Y: Byte;
BEGIN
  if Page<=MaxPage then with Pages[Page] do
    begin
      X := Lo(WBondUp);
      Y := Hi(WBondUp);
      if X+DX<1 then
        X := 1
      else if X+DX>MaxChar then
        X := MaxChar
      else
        X := X+DX;
      if Y+DY<1 then
        Y := 1
      else if Y+DY>MaxLine then
        Y := MaxLine
      else
        Y := Y+DY;
      WindMoveTo(Page,X,Y,Buf,ClipW)
    end
END;   {WindMovRel}
{------------------------}
PROCEDURE WindMoveTo(Page,X,Y: Byte;var Buf; ClipW: Boolean);
  {Перемещает окно в новое положение:
   PAGE - номер страницы;
   X,Y  - новые координаты левого верхнего угла;
   BUF  - вид экрана без окна;
   CLIPW- признак отсечки изображения}
var
  X2,Y2,LX,LY: Byte;
  Cop: array [1..4000] of Byte;
BEGIN
  if (X in [1..MaxChar]) and (Y in [1..MaxLine])
     and (Page<=MaxPage) then with Pages[Page] do
    begin
{Копируем окно в буфер Cop}
      SaveWind(Page,Cop,LX,LY);
{Восстанавливаем вид страницы}
      MoveToScreen(Buf,VMP[Page]^,PageSize);
      if not ClipW then
{Корректируем положение}
        begin
          while X+LX-1>MaxChar do
            dec(X);
          while Y+LY-1>MaxLine do
            dec(Y)
        end;
{Переносим окно на новое место}
      CopyWind(Page,X,Y,Cop,LX,LY);
{Запоминаем новые границы окна}
      if Page=ActivePage then
        SetActivePage(Page)
    end
END;   {WindMoveTo}
{--------------------------}
FUNCTION WindSize(Page: Byte): Word;
  {Возвращает размер буфера для сохранения окна}
var
  X1,Y1,X2,Y2: Byte;
BEGIN
  if Page<=MaxPage then with Pages[Page] do
    begin
      X1 := Lo(WBondUp);
      Y1 := Hi(WBondUp);
      X2 := Lo(WBondDown)+2;
      Y2 := Hi(WBondDown)+2;
      WindSize := (X2-X1+1)*(Y2-Y1+1)*2
    end
  else
    WindSize := 0
END;   {WindSize}
{============}  END. {TextCRT}  {=============}
