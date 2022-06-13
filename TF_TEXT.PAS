{+--------------------------------------------+
 | Пример использования средств модуля F_Text |
 +--------------------------------------------+}
Uses CRT,F_Text;
var
  c: Char;
  k,j: Byte;
  Size: Word;
  P: Pointer;
  OldAtt: Byte;
  m: array [0..7] of Word;
  x,y,u,d: Byte;
  Page: Byte;
BEGIN
{Выводим таблицу сегментов
 всех доступных страниц}
  for k := 0 to 7 do
    begin
      SetActivePage(k);
      m[k] := MemW[$0040:$004E];
      Mem[$B800:m[k]] := 13;
      if Mem[$B800:m[k]]<>13 then
        m[k] := 0
    end;
  SetActivePage(0);
  ClrScr;
  WriteLn('Сегментные адреса видеостраниц:');
  WriteLn('Страница  Сегмент');
  for k := 0 to 7 do
    WriteLn(k,m[k]:16);


{Запрашиваем номер страницы}
  Write('Введите номер страницы: ');
  ReadLn(Page);


{Готовимся к работе: уточняем параметры
 видеорежима, переназначаем стандартный вывод
 и активизируем страницу}
  InitText;
  PageWriteOn;
  SetActivePage(Page);
  Page := GetActivePage;  {Проверяемактивную страницу}


{Устанавливаем стандартные цвета и очищаем экран}
  Colors(LightGray,Black);
  ClrScr;


{Заполняем экран фоновыми сообщениями}
  for k := 1 to 24 do
    for j := 1 to 8 do
      Write('Строка ',k:2,' ');
  {Неполная последняя строка}
  for j := 1 to 7 do
    Write('Строка 25 ');


{Запоминаем состояние экрана}
  Size := PageSaveSize;
  GetMem(P,Size);
  SavePage(Page,P^);


{Создаем окно в центре экрана}
  Colors(Yellow,Blue);      {Задаем цвета}
  CursorOff;                {Убираем курсор}
  SetWindow(20,10,60,14,DoubleBorder,'',True,True,True);


{Выводим в нем сообщения}
  WriteLn('Страница N ':25,Page);
  WriteLn('    Смещайте окно клавишами курсора');
  Write('ESC - выход':25);


{Запоминаем атрибуты окна}
  OldAtt := Pages[Page].Attrib;


{Цикл перемещения окна клавишами курсора и
 Home,End,PgUp,PgDn. Продолжается до тех пор,
 пока не будет нажата клавиша Esc}
  repeat
    while not KeyPressed do
      begin  {Меняем атрибуты окна в ожидании
              нажатия любой клавиши}
        for k := 1 to 10 do
          if not KeyPressed then
            Delay(50);
        SetWindAttribute(Page,
           PackAttribute(Random(255),Random(8)))
      end;
    {Восстанавливаем старые атрибуты}
    SetWindAttribute(Page,OldAtt);
    c := ReadKey;
    if c<>#27 then
      if c=#0 then
        case ord(ReadKey) of
          71: WindMoveRel(Page,-1,-1,P^,False);
          72: WindMoveRel(Page,0,-1,P^,False);
          73: WindMoveRel(Page,1,-1,P^,False);
          75: WindMoveRel(Page,-1,0,P^,False);
          77: WindMoveRel(Page,1,0,P^,False);
          79: WindMoveRel(Page,-1,1,P^,False);
          80: WindMoveRel(Page,0,1,P^,False);
          81: WindMoveRel(Page,1,1,P^,False)
       end
  until c=#27;


{Завершаем работу программы}
  PageWriteOff;         		{Восстанавливаем драйвер}
  CursorOn;             		{Включаем курсор}
  SetActivePage(0);     		{Переходимв основную страницу}
  Window(1,1,80,25);        	{Полный экран}
  Colors(LightGray,Black);  	{Стандартные цвета}
  ClrScr;                   	{Очищаем экран}
  FreeMem(P,Size)
END. 


