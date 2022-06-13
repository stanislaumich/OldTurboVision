{+---------------------------------------+
 |  Пример использования модуля F_GrText |
 +---------------------------------------+}
Uses CRT,Graph,F_GrText;
const
  DX = 50;       		{Ширина текстового окна}
  DY = 11;       		{Высота текстового окна}
  t1: String='Лучшая в мире система программирования';
  t2: String='Турбо Паскаль ';
  Grad = Pi/180; 		{Перевод градус/радиан}
var
  D,R,E: Integer;
  Angle: Integer;  		{Угол поворота букв}
  x1,y1,x2,y2: Integer; 	{Координаты окон}
  F: File;       		{Файл со шрифтом}
  FT: Text;      		{Файл с текстом программы}
  N: Integer;
  P: Pointer;    		{Указатель на шрифт}
  S: String;
  k,H: Byte;
  C: Char;
begin
{Инициируем графику}
  D := Detect;
  InitGraph(D,R,'');
  E := GraphResult;
  if E<>grOk then
    begin
      WriteLn(GraphErrorMsg(E));
      Halt
    end;
{Выводим текст процедурой OutString}
  if RegisterChrFile('trip.chr')>0 then
    begin
      y1 := succ(GetMaxY) div 20;
      x1 := 12*y1;
      x2 := Length(t1);
      y2 := GetMaxY-2*y1;
      while x1<y2 do
      begin
        MoveTo(0,x1);
        for k := 1 to x2 do
          begin
            Angle := Round(30*sin(grad*(k*360/x2)));
            OutString(t1[k],1,Angle,0.9,1);
          end;
        inc(x1,y1)
      end;
      MoveTo(2*GetMaxX div 7,GetMaxY-3*y1);
      for k := 1 to Length(t2) do
        OutString(t2[k],1,0,1,1)
    end;
{Выбираем нужный шрифт}
  case D of
    CGA: H := 8;
    EGA: H := 14;
    VGA: H := 16;
    else
         H := 8;
  end;
{Готовим имя файла, содержащего шрифт}
  Str(H,S);
  S := '8x'+S+'.fnt'; 			{Имя файла}
{Открываем файл со шрифтом}
  Assign(F,S);
  Reset(F,1);
{Резервируем память и грузим шрифт}
  GetMem(P,FileSize(F));
  BlockRead(F,P^,FileSize(F));
  Close(F);
{Регистрируем шрифт и перехватываем ввод-вывод}
  SetFont(p,8,H);
  GraphWriteOn;
(*{Создаем текстовое окно}
  TextColor(Yellow);
  TextBackGround(Blue);
  SetWindow ((GetMaxChar-DX) div 2,2,(GetMaxChar+DX) div 2,
    (GetMaxLine+DY) div 3,DoubleBorder,
    ' Нажмите любую клавишу ',True,False,False);
{Открываем файл с текстом программы}
  S := copy(ParamStr(0),1,pos('.',ParamStr(0)))+'pas';
  Assign(FT,S);
  Reset(FT);
{Читаем файл и выводим его в окно}
  for N := 1 to DY do
    begin
      ReadLn(FT,S);
      WriteLn(S)
    end;
  Close(FT);
{Ждем действий пользователя}
  while not KeyPressed do;
  while KeyPressed do
    C := ReadKey;
{Очищаем текстовое окно и вводим строку}
  ClrScr;
  WriteLn('Введите произвольный текст');
  ReadLn(S);
{Сдвигаем ввод в низ окна и ждем}
  Scrolling(-DY div 2);
  *)
  WriteLn('Текст смещен на ',-DY div 2,' строк');
  WriteLn('Нажмите любую клавишу...');
  C := ReadKey;
{Завершаем работу программы}
  GraphWriteOff;
  CloseGraph
end.


