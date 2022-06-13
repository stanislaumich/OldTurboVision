Uses Graph, CRT, DOS;
const
  fontwith=15;
type
  FontType   = array [0..255, 0..FontWith] of byte;
  ReadKType  = (LeftK, RightK, UpK, DownK, F1K, F2K, F3K, F4K, F5K,
                AltF4, AltF5, F6K, F7K, F8K, EnterK, ESCK, Err);
const
  wdw  = 10;                     {ширина клетки раб. поля}
  htw  = 8;                      {высота клетки раб. поля}
  wdt  = 15;                     {ширина клетки таблицы}
  htt  = 20;                     {высота клетки таблицы}
  xw   = wdw;                    {левая граница раб. поля}
  F1f : Boolean = false;         {флаг режима F1}
  F2f : Boolean = false;         {флаг режима F2}
  iw  : byte = 0;                {гориз.коорд.пикселя в раб.поле}
  jw  : byte = 0;                {вертик. коорд. пикселя}
  iF1 : byte = 4;                {гориз. коорд. режима F1}
  jF1 : byte = 1;                {вертик. коорд.}
  iF2 : byte = 8;                {гориз. коорд. режима F2}
  jF2 : byte = 0;                {вертик. коорд.}
  Cng : Boolean = false;         {флаг изменения шрифта}
  FlagFont : Boolean = false;    {флаг считанного шрифта}
  InpName = '14x9.FON';          {имя входного файла}
  OutName = '14X9.NEW';          {имя выходного файла}
var
  f    : file of FontType;
  Font : FontType;               {таблица знакогенератора}
  FntC : array [-4..100] of byte; {образ очередного символа:
                         первые 4 байта - служебные, собственно
                         образ начинается с байта с номером 0}
  yw   : integer;                {верхняя граница раб.поля}
  xt   : integer;                {левая граница таблицы}
  yt   : integer;                {верхняя граница таблицы}
  brdr : pointer;                {ук-ль на рамку для раб.поля}
  pw   : pointer;                {ук-ль на клетку для раб.поля}
  pw0  : pointer;
  pc   : pointer;                {ук-ль на символ}
  pt   : pointer;                {ук-ль на клетку таблицы}
  i, j : integer;                {рабочие переменные}
  x, y : integer;
  FontB : array [0..FontWith, 0..7] of Boolean; {массив признаков
                                          светящихся пикселей}
(*
procedure write(c:char);
var
  r:registers;
begin
  with r do
    begin
      ah:=10;
      ah:=ord(c);
      bh:=0;
      cx:=1;
      intr($10,r)
    end
end;
*)
{---------------------------------------------------------------}
PROCEDURE Build;
{
 Обеспечивает поиск в каталоге и чтение шрифта из файла с именем
"8x8.fnt" (процедура  ReadFont),  формирование рабочего поля
(процедура  BuildWork)  и  подготовку и формирование таблицы
(процедура  BuildTable).  Выводит верхнюю строку-подсказку.
}
{---------------------------------------------------------------}
  PROCEDURE ReadFont;
  {
    Читает данные из файла  "8x8.fnt"  в переменную  Font.
    Если файл не обнаружен, обнуляет эту переменную.
  }
  BEGIN  {начало процедуры  READFONT}
    for i := 0 to 255 do
      for j := 0 to FontWith do  Font[i, j] := 0;
    assign (f, InpName);
    {$I-}  reset (f);  {$I+}
    if IOResult = 0 then
      begin
        read (f, Font);
        Close (f);
        FlagFont := true
      end;
  END    {конец процедуры  READFONT};
{---------------------------------------------------------------}
  PROCEDURE BuildWork;
  {
    Подготавливает рабочее поле в левой части экрана:
    расчерчивает поле 8x8 и готовит образ пустой
    клетки (указатель  pw0) и память для мигания (pw).
  }
  BEGIN  {начало процедуры  BUILDWORK}
    yw := (GetMaxY - htw*(FontWith+1) - 9) div 2;
    for i := 0 to FontWith+1 do
      begin
        Line (xw, yw+i*htw, xw+wdw*8, yw+i*htw);
        if i<=8 then Line (xw+i*wdw, yw, xw+i*wdw, yw+htw*(FontWith+1))
      end;
    GetMem (pw, ImageSize (xw+1, yw+1, xw+wdw, yw+htw));
    GetMem (pw0, ImageSize (xw+1, yw+1, xw+wdw, yw+htw));
    GetImage (xw+1, yw+1, xw+wdw, yw+htw, pw0^)
  END    {конец процедуры  BUILDWORK};
{---------------------------------------------------------------}
  PROCEDURE BuildTable;
  {
    Определяет координаты и расчерчивает поле  16x16  для
    таблицы знакогенератора.  Читает стандартный шрифт из
    первой половины  ASCII-кoдoв и помещает его в левую
    часть таблицы.  Если был считан файл  "8x8.fnt" (признак
    в переменной  FlagFont), то формируется и правая половина
    таблицы. B указателе  pc^  сохраняется память для переноса
    символов из таблицы в рабочее поле и обратно.  B указателе
    pt^  резервируется память для выделения клетки таблицы.
  }
  var
    is, k : integer;
    l,m:byte;
  BEGIN  {начало процедуры BUILDTABLE}
    xt := GetMaxX - 16*wdt - xw - 1;
    yt := (GetMaxY - 16*htt - 8) div 2 + 8;
    for i := 0 to 16 do
      begin
        Line (xt, yt+i*htt, xt+16*wdt, yt+i*htt);
        Line (xt+i*wdt, yt, xt+i*wdt, yt+16*htt)
      end;
    Rectangle (xt-1, yt-1, xt+8*wdt-1, yt+16*htt+1);
    RectAngle (xt+8*wdt+1, yt-1, xt+16*wdt+1,yt+16*htt+1);
    is := ImageSize (0, 0, 7, FontWith);
    GetImage (0, 0, 7, FontWith, FntC);{гoтoвит служебные байты в FntC}
    GetMem (pc, is);
{
  Цикл подготовки символов: сначала каждый символ выводится в
  левый верхний угол экрана, затем переносится на нужное место
  в таблице.  Символы 7, 8, 10 и 13 выводятся процедурой
  OUTTEXT, т.к. процедура  WRITE  обрабатывает их особым образом.
}
    HighVideo;
    for i := 0 to {8*succ(ord(FlagFont))-}15 do
      for j := 0 to 15 do
        begin
          k := i*16 + j;
          GotoXY(1,1);
          case k of
          7,8,10,13: OutTextXY(0,0,chr(k));
          else write(chr(k));
          end;

          for l:=0 to FontWith do                   {вертикаль}
            begin
              Font[k,l]:=0;
              for m:=0 to 7 do                        {горизонталь}
                if GetPixel(m,l)<>black then
                  Font[k,l]:=Font[k,l] xor (128 shr m)
            end;
          GetImage (0, 0, 7, FontWith, pc^);
          PutImage (0, 0, pc^, XORPut);
          PutImage (xt+i*wdt+(wdt-8) div 2 +1,
                    yt+j*htt+(htt-FontWith-1) div 2 +1, pc^, NormalPut);
        end;
    GetMem (pt, ImageSize (0, 0, wdt, htt))
  END    {конец процедуры  BUILDTABLE};

{---------------------------------------------------------------}
const
  tx = 'F1 - Get char;   F2 - Put char;   F3 - Quit';
BEGIN   {начало процедуры  BUILD}
  ReadFont;
  BuildWork;
  BuildTable;
  GotoXY ((80 - TextWidth(tx) div 8) div 2 + 1, 1);
  system.write (tx);
  Rectangle(0, 16, GetMaxX, GetMaxY)
END     {конец процедуры  BUILD};
{---------------------------------------------------------------}
PROCEDURE Work;
{
  Готовит вспомогательный массив-признак пикселей  FontB,
  затем в бесконечном цикле читает клавиатуру и передает
  управление соответствующей процедуре.
}
{---------------------------------------------------------------}
  FUNCTION RedK : ReadKType;
  {
    Обеспечивает мигание клетки раб.поля или выделенного символа
    до тех пор, пока не будет нажата очередная клавиша.  Преоб-
    разует код клавиши в тип  ReadKType.
  }
  const
    ReadKTable : array [0..13] of byte =
                       (75, 77, 72, 80, 59, 60, 61, 62, 63,
                       107, 108, 64, 65, 66);
    Temp = 5;                  {частота мигания}
  var
    p      : pointer;        {образ мигания}
    c1, c2 : char;
    RK     : ReadKType;
  BEGIN  {начало функции  REDK}
  { подготовить в  x, y - координаты, a в  p^ - образ
    для мигания:}
    if not (F1f or F2f) then
      begin
        x := xw + iw*wdw + 3;
        y := yw + jw*htw + 2;
        p := pw;
        GetImage (x, y, x+wdw-7, y+htw-4, p^)
      end
    else
      begin
        if F1f then
          begin
            x := xt + iF1*wdt;
            y := yt + jF1*htt
          end
        else
          begin
            x := xt + iF2*wdt;
            y := yt + jF2*htt
          end;
        p := pt;
        GetImage (x, y, x+wdt, y+htt, p^)
      end;
{  цикл сканирования клавиатуры }
    repeat
      while not KeyPressed do
        begin
          PutImage (x, y, p^, NotPut);
          for i := 1 to 50 do
            if not KeyPressed then delay (Temp);
          PutImage (x, y, p^, NormalPut);
          if not KeyPressed then
            for i := 1 to 50 do
              if not KeyPressed then delay (Temp)
        end;
{  опознать клавишу в соответствии c типом  ReadKType}
      RK := Err;
      c1 := ReadKey;
      if ord(c1) = 0 then c2 := ReadKey else c2 := chr(0);
      if ord(c1) = 13 then RK := EnterK
      else if ord(c1) = 27 then RK := ESCK
      else if ord(c1) = 0 then
        for i := 0 to 13 do
          if ord(c2) = ReadKTable[i] then RK := ReadKType(i);

{ продолжить сканирование, если клавиша не соответствует
   типу  ReadKType}
    until RK <> Err;
    RedK := RK
  END    {конец функции  REDK};
{---------------------------------------------------------------}
  PROCEDURE MoveXY (x : integer);
  {
    Переводит указатель в рабочем поле или таблице:
      1 - налево;  2 - направо;  3 - вверх;  4 - вниз.
  }
{---------------------------------------------------------------}
    PROCEDURE Left  (var i : byte; a, b : byte);
    begin
      if i = a then i := b else dec (i)
    end;
{---------------------------------------------------------------}
    PROCEDURE Right (var i : byte; a, b : byte);
    begin
      if i = b then i := a else inc (i)
    end;
{---------------------------------------------------------------}
    PROCEDURE Up    (var i : byte; a : byte);
    begin
      if i = 0 then i := a else dec (i)
    end;
{---------------------------------------------------------------}
    PROCEDURE Down  (var i : byte; a : byte);
    begin
      if i = a then i := 0 else inc (i)
    end;
{---------------------------------------------------------------}
  BEGIN  {начало процедуры  MOVEXY}
    if F1f then
      begin
        case x of
          1 : Left  (iF1, 0, 15);
          2 : Right (iF1, 0, 15);
          3 : Up    (jF1, 15);
          4 : Down  (jF1, 15)
        end;
        GotoXY (76, 1); system.write (iF1*16 + jF1 : 3)
      end
    else if F2f then
      begin
        case x of
          1 : Left  (iF2, 0, 15);
          2 : Right (iF2, 0, 15);
          3 : Up    (jF2, 15);
          4 : Down  (jF2, 15)
        end;
        GotoXY (76, 1); system.write (iF2*16 + jF2 : 3)
      end
    else
      begin
        case x of
          1 : Left  (iw, 0, 7);
          2 : Right (iw, 0, 7);
          3 : Up    (jw, FontWith);
          4 : Down  (jw, FontWith)
        end
      end
  END    {конец процедуры  MOVEXY};
{---------------------------------------------------------------}
  PROCEDURE CopyChar;
  {
    Копирует символ в виде матрицы 3x3 знака в центре экрана.
  }
  BEGIN  {начало процедуры  COPYCHAR}
    x := xw + 8*wdw + 1;
    x := x + (xt - x - 24) div 2;
    y := (GetMaxY - 3*(FontWith+1)) div 2;
    for i:=0 to FontWith do
      for j:=0 to 7 do
        if FontB[i,j] then PutPixel(x+j,y+i,white)
        else PutPixel(x+j,y+i,black);
    GetImage(x,y,x+7,y+FontWith,Fntc);
    for i := 0 to 2 do
      for j := 0 to 2 do
        PutImage (x + 8*j, y + (FontWith+1)*i, FntC, NormalPut);
{    Rectangle (x-1, y-1, x+25, y+3*(FontWith+1)+1)}
  END    {конец процедуры  COPYCHAR};



{---------------------------------------------------------------}
  PROCEDURE Enter;
  {
    B режиме редактирования инвертирует пиксель,
    в режиме F1 переносит выбранный символ в рабочее поле,
    в режиме F2 переносит символ в таблицу.
  }
{---------------------------------------------------------------}
    PROCEDURE GetChar;
    {
      Переносит выбранный в таблице символ в рабочее поле.
    }
    BEGIN  {начало процедуры  GETCHAR}
      x := xt + iF1*wdt + (wdt - 8) div 2 + 1;
      y := yt + jF1*htt + (htt - FontWith-1) div 2+1 ;
      GetImage (x, y, x+7, y+FontWith, FntC);
{ проверить образ по-битно и сформировать изображение в
  рабочем поле}
      for i := 0 to FontWith do
        for j := 0 to 7 do
           if GetPixel(x+j,y+i)<>black then
            begin
              PutImage (xw+j*wdw+1, yw+i*htw+1, pw0^, NOTPut);
              FontB[i, j] := true
            end
          else
            begin
              PutImage (xw+j*wdw+1, yw+i*htw+1, pw0^, NormalPut);
              FontB[i, j] := false
            end;
      CopyChar;
      GotoXY (76, 1);  system.write ('   ');
      F1f := false
    END    {конец процедуры  GETCHAR};
{---------------------------------------------------------------}
    PROCEDURE PutChar;
    {
      Помещает отредактированный символ в таблицу.
    }
var k:byte;
    BEGIN  {начало процедуры  PUTCHAR}
      x := xt + iF2*wdt + (wdt - 8) div 2 + 1;
      y := yt + jF2*htt + (htt - FontWith-1) div 2 + 1;
      PutImage (x, y, FntC, NormalPut);
{  скопировать символ в основную таблицу  Font }
      i := iF2*16 + jF2 ;
      for j := 0 to FontWith do
        begin
          Font[i, j] := 0;
          for k:=0 to 7 do
            if FontB[j,k] then Font[i,j]:=Font[i,j] or (128 shr k)
        end;
{ очистить рабочее поле }
      for i := 0 to FontWith do
        begin
          FntC[i] := 0;
          for j := 0 to 7 do
            begin
              PutImage (xw+j*wdw+1, yw+i*htw+1, pw0^, NormalPut);
              FontB[i, j] := false
            end;
        end;
      Cng := true;
      CopyChar;
      GotoXY (76, 1); system.write('   ');
      F2f := false
    END    {конец процедуры  PUTCHAR};
{---------------------------------------------------------------}
  BEGIN  {начало процедуры  ENTER}
    if F1f then GetChar
    else if F2f then PutChar
    else
      begin
        if FontB[jw, iw] then
          begin
            PutImage (xw+iw*wdw+1, yw+jw*htw+1, pw0^, NormalPut);
            FontB[jw, iw] := false
          end
        else
          begin
            PutImage (xw+iw*wdw+1, yw+jw*htw+1, pw0^, NOTPut);
            FontB[jw, iw] := true
          end;
        FntC[jw] := FntC[jw] xor (128 shr iw);
        CopyChar
      end
  END    {конец процедуры  ENTER};
{---------------------------------------------------------------}
  PROCEDURE Quit;
  {
    Завершает работу программы.
  }
  BEGIN
    if Cng then
      begin
        assign (f, OutName);
        rewrite (f);
        system.write (f, Font);
        Close (f)
      end;
    CloseGraph;
    Halt
  END;
{---------------------------------------------------------------}
var
  buf1,buf2 : array [1..16,0..FontWith] of byte;
  ib,jb,jjb,m,l:integer;
  name:string;
  c:char;
BEGIN  {начало процедуры  WORK}
  for i := 0 to FontWith do
    for j := 0 to 7 do
      FontB[i, j] := false;
  while true do
    case RedK of
      LeftK  : MoveXY (1);
      RightK : MoveXY (2);
      UpK    : MoveXY (3);
      DownK  : MoveXY (4);
      F1K    : begin
                 F1f := true; F2f := false
               end;
      F2K    : begin
                 F1f := false; F2f := true
               end;
      F3K    : Quit;
      F4K    : begin      {копирование вертикального ряда iF1 в буфер 1}
                 for ib:=1 to 16 do
                   for jb:=0 to FontWith do
                     buf1[ib,jb]:=Font[if1*16+ib-1,jb]
               end;
      F5K    : begin      {копирование iF1 в буфер 2}
                 for ib:=1 to 16 do
                   for jb:=0 to FontWith do
                     buf2[ib,jb]:=Font[if1*16+ib-1,jb]
               end;
      AltF4  : begin      {копирование из буфера 1 в ряд if2}
                 for ib:=1 to 16 do
                   begin
                     for jb:=0 to FontWith do
                       begin
                         Font[if2*16+ib-1,jb]:=buf1[ib,jb];
                         for jjb:=0 to 7 do
                           if (buf1[ib,jb] and (128 shr jjb))<>0 then
                           PutPixel(jjb,jb,white)
                       end;
                     GetImage(0,0,7,FontWith,FntC);
                     PutImage(0,0,FntC,XORPut);
                     x := xt + iF2*wdt + (wdt - 8) div 2 + 1;
                     y := yt + (ib-1)*htt + (htt - FontWith-1) div 2 + 1;
                     PutImage (x, y, FntC, NormalPut);
                   end
               end;
      AltF5  : begin      {копирование из буфера 2 в ряд if2}
                 for ib:=1 to 16 do
                   begin
                     for jb:=0 to FontWith do
                       begin
                         Font[if2*16+ib-1,jb]:=buf2[ib,jb];
                         for jjb:=0 to 7 do
                           if (buf2[ib,jb] and (128 shr jjb))<>0 then
                           PutPixel(jjb,jb,white)
                       end;
                     GetImage(0,0,7,FontWith,FntC);
                     PutImage(0,0,FntC,XORPut);
                     x := xt + iF2*wdt + (wdt - 8) div 2 + 1;
                     y := yt + (ib-1)*htt + (htt - FontWith-1) div 2 + 1;
                     PutImage (x, y, FntC, NormalPut);
                   end
               end;
      F6K    : begin      {чтение из файла}
                 GotoXY(5,24); write('Имя входного файла= ');
                 readln(name);
                 GotoXY(5,24); write('                                   ');
                 assign(f,name);
                 reset(f);
                 read(f,font);
                 close(f);
                 for i:=0 to 15 do
                   for j:=0 to 15 do
                     for m:=0 to FontWith do
                       for l:=0 to 7 do
                         if (font[i*16+j,m] and (128 shr l))<>0 then
                           PutPixel(xt+i*wdt+(wdt-8) div 2 +1+l,
                                    yt+j*htt+(htt-FontWith-1) div 2+1+m,white)
                         else
                           PutPixel(xt+i*wdt+(wdt-8) div 2 +1+l,
                                    yt+j*htt+(htt-FontWith-1) div 2+1+m,black);
               end;
      F7K    : begin      {запись в файл}
                 GotoXY(5,24); write('Имя выходного файла= ');
                 readln(name);
                 GotoXY(5,24); write('                                   ');
                 assign(f,name);
                 rewrite(f);
                 write(f,font);
                 close(f)
               end;
      f8K    : begin
                 GotoXY(1,1);
                 write('  - символ');
                 GotoXY(1,1);
                 readln(c);
                 GetImage(0,0,7,FontWith,FntC);
                 for i:=0 to FontWith do
                   for j:=0 to 7 do
                     begin
                       FontB[i,j]:=GetPixel(j,i)<>black;
                       PutImage (xw+j*wdw+1, yw+i*htw+1, pw0^, 4*ord(FontB[i,j]));
                     end;
                 copychar;
                 GotoXY(1,1);
                 write('          ');
               end;

      EnterK : Enter;
      ESCK   : begin
                 F1f := false; F2f := false
               end
    end  {case}
END    {конец процедуры  WORK};
{---------------------------------------------------------------}
var
  d, r, e : integer;
BEGIN   {начало основной программы}
  d := 0;  r := CGAHi;             { Установка графики высокого
                                        разрешения CGA-адаптера }
  InitGraph (d, r, 'd:\turbo\pascal');
  e := GraphResult;
  if e <> grOk then
    writeln (GraphErrorMSG (e))
  else
    begin
      DirectVideo := false;
      Build;
      Work
    end
{============} END   {конец основной программы}. {==============}

