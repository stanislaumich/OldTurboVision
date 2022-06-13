{
 +------------------------------------+
 | Демонстрация основных возможностей |
 |            модуля F_EMS            |
 +------------------------------------+
}
Uses CRT,Graph,F_EMS,F_Text;
type
  TV = array [0..MaxInt div 2-1] of LongInt;
var
  All,Pages: Word;
  k,j,x: LongInt;
  Vec: TEMSVector;
  Tex: TEMSText;
  Scr: TEMSScreen;
  t: LongInt;
  d,r,e: Integer;
  PV: array [0..40] of ^TV;
  Sz: LongInt;
  Sum: Comp;
  f: file;
  ft: Text;
  s,ss: String;
  Err: Boolean;
  c: Char;
const
  LPage=16*1024;
label
  L1,L2;
Function HexW(X: Word): String;
  {Возвращает 16-ричное написание Х}
const
  HS: array [0..15] of Char = '0123456789ABCDEF';
var
  S: String;
  k: Byte;
begin
  S := '';
  for k := 3 downto 0 do
    S := S+HS[(X shr (k*4)) and 15];
  HexW := S
end;  {HexW}
{-------------------}
Procedure GetTime;
  {Помещает в t системное время,
   выравненное на границу 55-мс интервала}
begin
  t := MemL[0:$46C];
  while t=MemL[0:$46C] do;
end;  {GetTime}
{-------------------}
begin   {Основная программа}
  {Проверяем наличие EMM}
  If not IsEMS then
    begin
      WriteLn('Нет EMS-памяти или не установлен EMM');
      Halt
    end;
  Colors(LightGray,Black);
  ClrScr;
{Сообщаем номер версии, общую и доступную память}
  WriteLn('Используется EMM версии ',GetEMMVersion);
  WriteLn('   Сегмент окна отображения $',HexW(EMSSeg));
  GetEMSInfo(All,Pages);
  WriteLn('   Всего страниц   : ',All,' (',
                  round(All*16.0*1024),' байт)');
  Sz := round(Pages*16.0*1024);
  WriteLn('   Свободно страниц: ',Pages,' (',Sz,' байт)');
{Определяем количество Х 16-Кбайтных страниц в куче}
  x := MaxAvail div LPage;
  if x>Pages then x := Pages;  {Уравниваем с EMM}
{Распределяем в куче массивы из 4096 длинных целых чисел}
  dec(x);
  for k := 0 to x do
    if MaxAvail>=LPage then
      GetMem(PV[k],LPage);
  x := k;
  Sz :=succ(x)*LPage div 4;
  WriteLn('Создаем массив из ',Sz,' длинных целых чисел в куче...');
  GetTime;                  {Засекаем время}
  for j := 0 to x do
    for k := 0 to LPage div 4-1 do
      begin
        PV[j]^[k] := j*(LPage div 4)+k;
        if PV[j]^[k] mod 1000=0 then
          begin
            Write(PV[j]^[k]:10);
            GotoXY(1,WhereY)
          end
      end;
  {Подсчитываем его сумму}
  WriteLn('Подсчитываем его сумму...');
  Sum := 0;
  for j := 0 to x  do
    for k := 0 to LPage div 4-1 do
      begin
        Sum := Sum+PV[j]^[k];
        if PV[j]^[k] mod 1000=0 then
          begin
            Write(PV[j]^[k]:10);
            GotoXY(1,WhereY)
          end
      end;
  WriteLn('Сумма элементов = ':30,Sum:11:0,',время счета = ',
         (MemL[0:$46C]-t)*55/1000:5:2,' секунд');
  {Освобождаем кучу}
  for k := 0 to x do
    FreeMem(PV[k],LPage);
  {Создаем массив в EMS}
  WriteLn('Тот же массив в EMS-памяти...');
  Vec.Init(4,0,Sz-1);  {4-длина элемента;0..Sz-1 - индексы}
  if not EMSErrorFlag then with Vec do
    begin             	{Если создан успешно}
      GetTime;        	{Засекаем время}
      for k := 0 to Sz-1 do
        begin
          SetItem(k,k); 	{Помещаем очередной эл-т}
          if k mod 1000=0 then
            begin      	{Сообщаем о каждом 1000-м}
              Write(k:10);
              GotoXY(1,WhereY)
            end
        end;
    {Вычисляем сумму элементов}
    WriteLn('Суммируем элементы...');
      Sum := 0;
      for k := 0 to Sz-1 do
        begin
          Sum := Sum+LongIntItem(k);
          if k mod 1000=0 then
	    begin      	{Сообщаем о каждом 1000-м}
              Write(k:10);
              GotoXY(1,WhereY)
            end
        end
    end
  else
    Halt;
  WriteLn('Сумма элементов = ':30,Sum:11:0,', время счета = ',
         (MemL[0:$46C]-t)*55/1000:5:2,' секунд');
  WriteLn('Сохраняем массив в файле TESTEMS.$$$...');
  Assign(f,'testems.$$$');
  {$I-}
  ReWrite(f,1);
  {$I+}
  if IOResult<>0 then
    begin
      WriteLn('Ошибка при создании файла!');
      Vec.Done;
      Goto L1
    end;
  Vec.Store(f);    	{Сохраняем массив}
  if EMSErrorFlag then
    begin          	{Была ошибка при сохранении}
      Vec.Done;
      Goto L1
    end;
  Vec.Done;        	{Освобождаем EMS}
  {Читаем массив из файла}
  WriteLn('Читаем массив из файла...');
  Seek(f,0);      	{Начало файла}
  Vec.Load(f);    	{Загружаем массив}
  Close(f);
  if EMSErrorFlag then
    Goto L1;      	{Была ошибка}
  WriteLn('Еще раз подсчитываем его сумму...');
  Sum := 0;
  for k := 0 to Sz-1 do
    begin
      Sum := Vec.LongIntItem(k)+Sum;
      if k mod 500=0 then
      begin
        Write(k:10);
        GotoXY(1,WhereY)
      end
  end;
WriteLn('Сумма = ':30,Sum:11:0);
  Vec.Done;
L1:
  {Определяем длину файла с текстом программы}
  s := {copy(ParamStr(0),1,Pos('.',ParamStr(0)))+'pas';}
       'f_ems.int';
  Assign(f,s);
  Reset(f,1);
{Определяем количество SZ требуемых ему страниц}
  Sz := (FileSize(f)+LPage-1) div LPage;
  Close(f);
  Assign(ft,s);
  Reset(ft);
{Создаем объект TEMSText}
  WriteLn('Создаем объект TEMSText');
  Tex.Init(Sz*Lpage);
  if EMSErrorFlag then
    Halt;
{Читаем файл и записываем его в TEMSText}
  WriteLn('Помещаем в него файл '+S);
  while not (EOF(ft) or EMSErrorFlag) do
    begin
      ReadLn(ft,s);         	{Читаем строку}
      Tex.SetItem(s)        	{Помещаем ее в EMS}
    end;
  if EMSErrorFlag then
    Goto L2;
  {Проверяем записанное}
  Reset(ft);             		{Начало файла}
  Tex.Pos := 0;          		{Начало текста в EMS}
  for k := 1 to 16 do
    WriteLn;             		{Готовим место для окон}
  Colors(Yellow,Blue);   		{Цвет вывода}
  SetWindow(1,10,80,23,1,' Исходный файл: '+
	#196#196#196#196#196#196#196#196#196#196#196#196#196+
	#196#196#196' Текст в EMS: ',True,False,False);
  while not EOF(ft) do
    begin
      ReadLn(ft,s);
      ss := Tex.GetItem;
      Err := s<>ss;
      if Length(s)>38 then
	s[0] := #38;
      While Length(s)<39 do
	s := s+' ';
      s := s+ss;
      if Length(s)>77 then
	s[0] := #77;
      WriteLn(s);
      if Err then
	begin
	  Write(#7);
	  c := ReadKey;
	  while c=#0 do c := ReadKey
	end
    end;
  Tex.Done;
  Colors(LightGray,Black);
  Window(1,1,80,25);
  GotoXY(1,25);
L2:
  {Проверка объекта TEMSScreen}
  Write('Сохраняем копию текстового экрана. ');
  Scr.Init;
  if not EMSErrorFlag then
    Scr.PutScreen;    	{Сохраняем копию в EMS}
  if EMSErrorFlag then
    Halt;          	{Была ошибка}
  x := WhereX;     	{Запоминаем положение курсора}
  WriteLn('Нажмите любую клавишу...');
  if ReadKey=#0 then k := ord(ReadKey);
  {Создаем окно в центре экрана и заполняем его
   случайным цветом}
  ClrScr;
  SetWindow(10,7,70,18,2,' Нажмите любую клавишу...',
            				False,True,False);
  while not KeyPressed do
    begin
      GotoXY(Random(59)+2,Random(10)+2);
      TextBackground(Random(8));
      Write(' ')
    end;
  if ReadKey=#0 then k := ord(ReadKey);
  Scr.GetScreen;    	{Восстанавливаем экран}
  Window(1,1,80,25);
  TextBackground(Black);
  GotoXY(x,25);
  Scr.Done;
  {Проверяем графический режим}
  WriteLn(#13#10'Для перехода в графический '+
               'режим нажмите любую клавишу...');
  if ReadKey=#0 then k := ord(ReadKey);
  d := detect;
  InitGraph(d,r,'');
  e := GraphResult;
  if e <> 0 then
    begin         		{Ошибка инициации графики}
      WriteLn(GraphErrorMsg(e));
      Halt
    end;
{Инициируем Scr заново - новый режим экрана!}
  Scr.Init;
  Line(0,0,GetMaxX,GetMaxY); 	{Диагональные линии}
  Line(0,GetMaxY,GetMaxX,0);
  Scr.PutScreen;      		{Сохраняем изображение}
  while not (KeyPressed or EMSErrorFlag) do
    begin
      ClearDevice;    		{Очищаем экран}
      Scr.GetScreen;  		{Восстанавливаеми зображение}
    end;
  Scr.Done;
  CloseGraph;
end.


