{===============} Unit F_EMS; {================}
{+---------------------------------------------+
 | Этот модуль содержит объекты и подпрограммы |
 |          для работы с EMS-памятью           |
 +---------------------------------------------+}
{$X+,N+,E+}
                  INTERFACE
{-----------------------------------------------}
type
{----------  Базовый объект иерархии -----------}
  PEMSArea =^TEMSArea;
  TEMSArea = Object
    Handle: Word;    		{Дескриптор}
    MaxPag: Word;    		{Количество страниц}
    Size: LongInt;   		{Длина используемой памяти}
    Constructor Init(ASize: LongInt);
    Constructor Load(var F: File);
    Destructor Done; Virtual;
    Procedure EMSError(NError: Byte); Virtual;
    Procedure Store(var F: File); Virtual;
    Procedure WriteEMS(var Source; Dest,Sz: LongInt); Virtual;
    Procedure ReadEMS(Source: LongInt; var Dest;
                      		Sz: LongInt); Virtual;
      {-----------} Private {-----------}
    Function ReadFile(var F: File; var Dest;
             			Sz: Word): Boolean; Virtual;
    Function WriteFile(var F: File; var Source;
             			Sz: Word): Boolean; Virtual;
  end;
{----------  Одномерный массив в EMS  ----------}
  PEMSVector =^TEMSVector;
  TEMSVector = object(TEMSArea)
    ItemS : LongInt;     		{Длина элемента массива}
    MinInd: LongInt;     		{Минимальный индекс}
    MaxInd: LongInt;     		{Максимальный индекс}
    Constructor Init(ASize,Min,Max: LongInt);
    Constructor Load(var F: File);
    Procedure Store(var F: File); Virtual;
    Procedure SetItem(var Source; Index: LongInt);
    Procedure GetItem(var Dest; Index: LongInt);
    Function SingleItem(Index: LongInt): Single;
    Function DoubleItem(Index: LongInt): Double;
    Function RealItem(Index: LongInt): Real;
    Function ExtendedItem(Index: LongInt): Extended;
    Function IntegerItem(Index: LongInt): Integer;
    Function LongIntItem(Index: LongInt): LongInt;
    Function ByteItem(Index: LongInt): Byte;
  end;
{----------  Двумерный массив в EMS  ----------}
  PEMSMatrix =^TEMSMatrix;
  TEMSMatrix = object(TEMSVector)
    MinInd1: LongInt;     	{Минимальный индекс}
    MaxInd1: LongInt;     	{Максимальный индекс}
    MinInd2: LongInt;     	{Минимальный индекс}
    MaxInd2: LongInt;     	{Максимальный индекс}
    Constructor Init(ASize,Min1,Max1,Min2,Max2: LongInt);
    Constructor Load(var F: File);
    Procedure Store(var F: File); Virtual;
    Function GetVecIndex(Ind1,Ind2: LongInt): LongInt;
    Procedure SetItem(var Source;Ind1,Ind2: LongInt);
    Procedure GetItem(var Dest;Ind1,Ind2: LongInt);
    Function SingleItem(Ind1,Ind2: LongInt): Single;
    Function DoubleItem(Ind1,Ind2: LongInt): Double;
    Function RealItem(Ind1,Ind2: LongInt): Real;
    Function ExtendedItem(Ind1,Ind2: LongInt): Extended;
    Function IntegerItem(Ind1,Ind2: LongInt): Integer;
    Function LongIntItem(Ind1,Ind2: LongInt): LongInt;
    Function ByteItem(Ind1,Ind2: LongInt): Byte;
  end;
{----------  Многомерный массив в EMS  ---------}
  TIndexList = array [1..MaxInt div 2] of LongInt;
  TIndex = array [1..MaxInt div 6,1..3] of LongInt;
  PIndex =^TIndex;
  TIndexBond = array [1..MaxInt div 4,1..2] of LongInt;
  PEMSArray =^TEMSArray;
  TEMSArray = object(TEMSVector)
    NIndex: Word;     		{Количество измерений}
    Index : PIndex;
    Constructor Init(ASize: LongInt; NInd: Word; var Ind);
    Constructor Load(var F: File);
    Destructor Done; Virtual;
    Procedure Store(var F: File); Virtual;
    Function GetVecIndex(var Ind): LongInt;
    Procedure SetItem(var Source,Ind);
    Procedure GetItem(var Dest,Ind);
  end;
{---- Имитатор файла последовательного доступа ----}
  PEMSType =^TEMSType;
  TEMSType = object(TEMSArea)
    Pos: LongInt;   	{Текущая позиция от начала памяти}
    Constructor Init(ASize: Longint);
    Constructor Load(var F: File);
    Procedure Store(var F: File); Virtual;
    Procedure SetItem(var Source; Sz: LongInt);
    Procedure GetItem(var Dest; Sz: LongInt);
  end;
{--------  Имитатор текстового файла  ---------}
  PEMSText =^TEMSText;
  TEMSText = object(TEMSType)
    Procedure SetItem(S: String);
    Function GetItem: String;
  end;
{--------- Копия экрана в EMS-памяти  ---------}
  PEMSScreen =^TEMSScreen;
  TEMSScreen = object(TEMSArea)
    Mode: Byte;   		{Код режима}
    Constructor Init;
    Constructor Load(var F: File);
    Procedure Store(var F: File); Virtual;
    Procedure PutScreen;
    Procedure GetScreen;
  end;

var
  EMSStatus: Byte;  {Статус последней операции}

Function IsEMS: Boolean;
  {Возвращает TRUE, если в ПК имеется EMS-память}

Function GetEMMVersion: String;
  {Возвращает номер версии EMM в формате 'X.X'}

Function EMSSeg: Word;
  {Возвращает сегментную часть адреса окна EMS-памяти}

Procedure GetEMSInfo(var AllPage, Pages: Word);
  {Возвращает полное количество (AllPages)
   и количество незанятых (Pages) страниц}

Procedure NewEMSHandle(var Handle: Word;Pages: Word);
  {Открывает новый дескриптор Handle
   и связывает с ним Pages страниц EMS}

Procedure DisposeEMSHandle(var Handle: Word);
  {Удаляет дескриптор Handle и освобождает   связанную с ним память}

Procedure MapEMSPage(Handle,Physic,Logic: Word);
  {Картирует окно, связывая его Physic физическую страницу с
	Logic логической страницей дискриптора Handle}
const
  EMSErrorFlag     : Boolean   = False;
  RegHeadTEMSArea  : String[14]='F_EMS TEMSArea';
  RegHeadTEMSVector: String[14]='F_EMS TEMSVect';
  RegHeadTEMSMatrix: String[14]='F_EMS TEMSMatr';
  RegHeadTEMSArray : String[14]='F_EMS TEMSArra';
  RegHeadTEMSType  : String[14]='F_EMS TEMSType';
  RegHeadTEMSScreen: String[14]='F_EMS TEMSScre';
{-----------------------------------------------}
                IMPLEMENTATION
{-----------------------------------------------}
Uses DOS,Graph,F_Text;
var
  Reg: registers;
const
  EMSVer : Word = 0;  {Версия EMM; используется
                   	как флаг проверки наличия EMS}
  EMSS   : Word = 0;  {Сегмент окна}
  LPage=16*1024;      {Длина страницы}
{---------  Базовый объект иерархии ----------}
CONSTRUCTOR TEMSArea.Init(ASize: LongInt);
  {Создает объект TEMSArea. ASize - размер
   требуемой EMS-памяти в байтах}
var
  All,Pag: Word;
begin
  if not IsEMS then
    EMSError($A5)    		{Нет EMS}
  else
    begin
      EMSErrorFlag := False;
      Size := ASize;
      MaxPag := (Size+LPage-1) shr 14;
      GetEMSInfo(All,Pag);
      if MaxPag>Pag then
        EMSError($88)  		{Нет требуемых страниц}
      else
        begin
          NewEMSHandle(Handle,MaxPag);
          EMSError(EMSStatus)
        end
    end
end;  {TEMSArea.Init}
{-------------------}
Function TEMSArea.ReadFile(var F: File;
                 var Dest; Sz: Word): Boolean;
  {Читает Sz байт из файла F в
   переменную Dest и контролирует результат}
var
  K: Word;
begin
  BlockRead(F,Dest,Sz,K);
  if K<>Sz then
    begin
      EMSError($A7);
      ReadFile := False  {Ошибка при чтении}
    end
  else
    ReadFile := True     		{Нет ошибок}
end;  {ReadFile}
{-------------------}
CONSTRUCTOR TEMSArea.Load(var F: File);
  {Создает объект TEMSArea, считывая его изфайла F. Файл
   должен быть открыт на чтение с длиной блоков в 1 байт и
   позиционирован на место, где ранее был сохранен объект
   TEMSArea процедурой Store.}

var
  SRead,Rest: LongInt;
  S: String;
  All,k: Word;
  Stop: Boolean;
  P: Pointer;
begin
  if not IsEMS then
    EMSError($A5)    		{Нет EMS}
  else
    begin
      {Читаем заголовок объекта -
       строку RegHeadTEMSArea}
      EMSErrorFlag := False;
      Stop := False;    		{Флаг нормального чтения}
      if not ReadFile(F,S,SizeOf(RegHeadTEMSArea))
        or (S<>RegHeadTEMSArea) then
        EMSError($A6) 		{Ошибка чтения или несовпадение заголовка}
      else            		{Читаем поля MaxPag и Size}
        begin
          if not(ReadFile(F,MaxPag,2) and
            ReadFile(F,Size,4)) then
              Exit;  		{Была ошибка при чтении полей}
          {Проверяем доступную память}
          GetEMSInfo(All,k);
          if k<MaxPag then
            EMSError($88)   	{Нет нужной памяти}
          else
            begin
              {Пытаемся создать дескриптор}
              NewEMSHandle(Handle,MaxPag);
              if EMSStatus<>0 then
                EMSError(EMSStatus)
              else
                begin      	        {Читаем содержимое памяти}
                  Rest := Size; 	{Непрочитанный остаток}
                  P := Ptr(EMSSeg,0);  	{Адрес начала
                                        физической страницы окна}
                  All := 0;  	        {Начинаем с 0-й	логической страницы}
                  Stop := False;
                  while (Rest<>0) and not Stop do
                    begin
                      MapEMSPage(Handle,0,All);
                      EMSError(EMSStatus);
                      if EMSStatus<>0 then
                        Exit;   	{Ошибка картирования}
                      if Rest>LPage then
                        SRead := LPage
                      else
                        SRead := Rest;
                      Stop := not ReadFile(F,P^,SRead);
                      Dec(Rest,SRead);
                      Inc(All)
                    end
                end
            end
        end
    end
end;  {TEMSArea.Load}
{-------------------}
Function TEMSArea.WriteFile(var F: File;
               var Source; Sz: Word): Boolean;
  {Записывает Sz байт из переменной Source
   в файл F и контролирует результат}
var
  K: Word;
begin
  BlockWrite(F,Source,Sz,K);
  if K<>Sz then
    begin
      EMSError($A8);
      WriteFile := False  {Ошибка при записи}
    end
  else
    WriteFile := True     {Нет ошибок}
end;  {TEMSArea.WriteFile}
{-------------------}
Procedure TEMSArea.Store(var F: File);
  {Записывает объект TEMSArea в файл F. Файл должен быть
   открыт на запись с длиной блоков в 1 байт и позиционирован
   на нужное место (обычно - в конец файла).}
var
  SRead,Rest: LongInt;
  S: String;
  All,k: Word;
  Stop: Boolean;
  P: Pointer;
begin
  if not IsEMS then
    EMSError($A5)    	{Нет EMS}
  else
    begin
      {Записываем заголовок объекта - строку RegHeadTEMSArea}
      EMSErrorFlag := False;
      S := RegHeadTEMSArea;
      if WriteFile(F,S,SizeOf(RegHeadTEMSArea))
      then begin  	              {Записываем поля MaxPag и Size}
          if WriteFile(F,MaxPag,2) and
            WriteFile(F,Size,4) then
          begin    	              {Записываем содержимое памяти}
            Rest := Size;             {Незаписанный остаток}
            P := Ptr(EMSSeg,0);       {Адрес начала физической страницы окна}
            All := 0;                 {Начинаем с 0-й логической страницы}
            Stop := False;            {Признак ошибки}
            while (Rest<>0) and not Stop do
              begin
                MapEMSPage(Handle,0,All);
                EMSError(EMSStatus);
                if EMSStatus<>0 then
                  Exit;               {Ошибка картирования}
                if Rest>LPage then
                  SRead := LPage
                else
                  SRead := Rest;
                Stop:= not WriteFile(F,P^,SRead);
                Dec(Rest,SRead);
                Inc(All)
              end
          end
        end
    end
end;  {TEMSArea.Store}
{-------------------}
DESTRUCTOR TEMSArea.Done;
  {Уничтожает объект TEMSArea и освобождает связанную с ним память}
begin
  if not IsEMS then
    EMSError($A5)    {Нет EMS}
  else
    begin
      DisposeEMSHandle(Handle);
      EMSError(EMSStatus)
    end
end;  {TEMSArea.Done}
{-------------------}
Procedure TEMSArea.WriteEMS(var Source; Dest,Sz: LongInt);
  {Записывает Sz байт из переменной Source в EMS,
   начиная с позиции Dest байт от ее начала}
var
  Rest,Pos,k: LongInt;
  Pag: Word;
  PD,PS: Pointer;
  PW: record S,O: Word end absolute PS;
  Stop: Boolean;
begin
{$IFNDEF NOTCHECK}
  if (Sz<0) or (Dest+Sz>Size) then
    EMSError($AA)    		{Запись за границей памяти}
  else
{$endIF}
    begin
      Pag := Dest div LPage; 	        {Логическая страница}
      Pos := Dest mod LPage; 	        {Смещение в ней}
      PS := @Source;      	        {Указатель в источнике}
      PD := ptr(EMSS,Pos);   	        {Указатель в EMS}
      Stop := False;   		        {Флаг ошибки картирования}
      Rest := Sz;            	        {Остаток записи}
      repeat    			{Цикл по страницам EMS}
        MapEMSPage(Handle,0,Pag);	{Картируем окно}
        EMSError(EMSStatus);
        Stop := EMSStatus<>0;    	{Признак ошибки}
        if not Stop then
          begin
         {Определяем размер Sz очередного блока:}
            if Rest>LPage-Pos then
              Sz := LPage-Pos
            else
              Sz := Rest;
            Move(PS^,PD^,Sz);    	{Переносим блок}
            Dec(Rest,Sz);     	        {Уменьшаем остаток}
            Inc(Pag);        	        {Следующая логическая стр.}
            PD := ptr(EMSS,0);   	{Указатель -в ее начало}
            Pos := 0;
            Inc(PW.O,Sz);  	        {Смещение в источнике}
            {Нормализуем указатель PS источника:}
            PW.S := PW.S+(PW.O shr 4);
            PW.O := PW.O mod 16
          end
      until Stop or (Rest=0)
    end
end;  {TEMSArea.WriteEMS}
{-------------------}
Procedure TEMSArea.ReadEMS(Source: LongInt; var Dest; 					Sz: LongInt);
  {Читает Sz байт из EMS-памяти, начиная с байта
   Source от ее начала, в переменную Dest}
var
  Rest,Pos,k: LongInt;
  Pag: Word;
  PD,PS: Pointer;
  PW: record S,O: Word end absolute PD;
  Stop: Boolean;
begin
{$IFNDEF NOTCHECK}
  if (Sz<0) or (Source+Sz>Size) then
    EMSError($A9)    		{Чтение за границей памяти}
  else
{$endIF}
    begin
      Pag := Source div LPage; 	{Логическая страница}
      Pos := Source mod LPage; 	{Смещение в ней}
      PD := @Dest;       	{Указатель в приемнике}
      PS := ptr(EMSS,Pos);	{Указатель в источнике}
      Stop := False;   		{Флаг ошибки картирования}
      Rest := Sz;              	{Остаток чтения}
      repeat    			{Цикл по страницам EMS}
        MapEMSPage(Handle,0,Pag);	{Картируем окно}
        EMSError(EMSStatus);
        Stop := EMSStatus<>0;    	{Признак ошибки}
        if not Stop then
          begin
         {Определяем размер Sz очередного блока:}
            if Rest>LPage-Pos then
              Sz := LPage-Pos
            else
              Sz := Rest;
            Move(PS^,PD^,Sz);   {Переносим блок}
            Dec(Rest,Sz);     	{Уменьшаем остаток}
            Inc(Pag);        	{Следующая логическая стр.}
            PS := ptr(EMSS,0);
            Pos := 0;
            Inc(PW.O,Sz);  	{Смещение в приемнике}
            {Нормализуем указатель PD приемника:}
            PW.S := PW.S+(PW.O shr 4);
            PW.O := PW.O mod 16
          end
      until Stop or (Rest=0)
    end
end;  {TEMSArea.ReadEMS}
{-------------------}
Procedure TEMSArea.EMSError(NError: Byte);
  {Получает управление при ошибках EMM илипри выполнении 
   методов объекта. По умолчанию выводит сообщение с номером NError.}
const
  Msg: array [$80..$AD] of String =(
'Внутренняя ошибка EMM',
'Сбой EMS-платы',
'EMM занят обработкой предыдущего запроса',
'Неверный дескриптор окна',
'Запрошена неопределенная в данной версии EMM функция',
'Нет доступных дескрипторов окон',
'Ошибка при сохранении или восстановлении окна',
'Запрос распределения превышает общую EMS-память',
'Запрос распределения превышает число доступных страниц',
'Попытка создать дескриптор с нулевым количеством страниц',
'Дескриптор не располагает таким числом страниц',
'Попытка картировать больше 4 страниц',
'Переполнение области сохранения картирующего контекста',
'Попытка повторного сохранения картирующего контекста',
'Попытка восстановления несохраненного контекста',
'Не определен параметр подфункции',
'Неизвестный тип атрибутов',
'Нет аппаратной поддержки сохраняемых страниц',
'Источник и приемник информации '+
		'одновременно находятся в EMS-памяти',
'Размер приемника информации слишком мал',
'Стандартная память частично перекрывает расширенную память',
'Слишком большое смещение в перемещаемом блоке',
'Размер перемещаемого блока больше 1 Мбайт',
'Источник и приемник связаны с одним '+
  		'дескриптором и частично перекрываются',
'Недопустимый тип памяти источника или приемника',
'Неопознанная ошибка',
'Нет аппаратной поддержки альтернативной установки страниц',
'Исчерпаны все допустимые установки альтернативных регистров',
'Не поддерживается установка альтернативных регистров',
'Неправильная установка альтернативных регистров',
'Назначенные каналы прямого доступа '+
  		'к памяти (КПДП) не поддерживаются',
'Указанный КПДП не поддерживается',
'Дескриптор не поименован',
'Указанное имя дескриптора уже существует',
'Источник выходит за границу 1 Мбайт',
'Содержимое указанное области данных разрушено',
'Нет доступа к указанной функции',
'Нет EMS-памяти или не установлен драйвер EMM.SYS',
'Неверный формат файла',
'Ошибка при чтении объекта из файла',
'Ошибка при записи объекта в файл',
'Попытка чтения за границей доступной EMS-памяти',
'Попытка записи за границей доступной EMS-памяти',
'Неверные границы индексов',
'Размер элемента вектора не соответствует длине переменной',
'Изменен режим работы дисплея (объект TEMSScreen)'
);
begin
  if NError=0 then
    begin
      EMSErrorFlag := False;
      Exit
    end;
  EMSErrorFlag := True;
  if NError in [$80..$AD] then
    WriteLn(Msg[NError])
  else
    WriteLn('Ошибка номер ',NError)
end;  {TEMSArea.EMSError}
{----------  Одномерный массив в EMS  ----------}
CONSTRUCTOR TEMSVector.Init(ASize,Min,Max: LongInt);
  {Создает объект TEMSVector:
  ASize - размер элементов массива в байтах;
  Min,Max - границы индекса.}
var
  Sz: LongInt;
begin
  if Min>Max then
    begin
      EMSError($AB);     		{Неправильные границы}
      Exit
    end;
  Sz := ASize*(Max-Min+1); 	{Определяем размер}
  TEMSArea.Init(Sz);       	{Создаем TEMSArea}
  if not EMSErrorFlag then
    begin
      ItemS  := ASize;
      MinInd := Min;
      MaxInd := Max
    end
end;  {TEMSVector.Init}
{-------------------}
CONSTRUCTOR TEMSVector.Load(var F: File);
  {Создает объект TEMSVector - читает из файлабазовый объект 


   TEMSArea, затем заголовок иполя ItemS, MinInd, MaxInd.}
var
  S: String;
begin
  TEMSArea.Load(F);  {Загружаем из файлабазовый объект}
  if not EMSErrorFlag then
    if ReadFile(F,S,SizeOf(RegHeadTEMSVector))
       and (S=RegHeadTEMSVector) then
      begin
        if ReadFile(F,ItemS,4) then
        if ReadFile(F,MinInd,4) then
          ReadFile(F,MaxInd,4);
        if EMSErrorFlag then
          Done
      end
    else
      EMSError($A6)
end;  {TEMSVector.Load}
{-------------------}
Procedure TEMSVector.Store(var F: File);
  {Сохраняет вектор в файле - сначала сохраняетбазовый 
   объект, потом заголовок и поляItemS, MinInd, MaxInd.}

begin
  TEMSArea.Store(F);
  if not EMSErrorFlag then
    begin
      if WriteFile(F,RegHeadTEMSVector,
                		SizeOf(RegHeadTEMSVector)) then
      if WriteFile(F,ItemS,4) then
      if WriteFile(F,MinInd,4) then
        WriteFile(F,MaxInd,4)
    end
end;  {TEMSVector.}
{-------------------}
Procedure TEMSVector.SetItem(var Source;Index: LongInt);
{Помещает в EMS элемент с индексом Index из переменной Source}
begin
{$IFNDEF NOTCHECK}
  if (Index>MaxInd) or (Index<MinInd) then
    EMSError($AB)   {Неправильный индекс}
  else
{$endIF}
    WriteEMS(Source,(Index-MinInd)*ItemS,ItemS)
end;  {TEMSVector.SetItem}
{-------------------}
Procedure TEMSVector.GetItem(var Dest; Index: LongInt);
 {Читает из EMS элемент массива с индексом Index}
begin
{$IFNDEF NOTCHECK}
  if (Index>MaxInd) or (Index<MinInd) then
    EMSError($AB)   {Неправильный индекс}
  else
{$endIF}
    ReadEMS((Index-MinInd)*ItemS,Dest,ItemS)
end;  {TEMSVector.GetItem}
{-------------------}
Function TEMSVector.SingleItem(Index: LongInt): Single;
var
  X: Single;
begin
{$IFNDEF NOTCHECK}
  if ItemS<>SizeOf(Single) then
    EMSError($AC)   {Ошибка в длине элемента}
  else
{$endIF}
    begin
      GetItem(X,Index);
      SingleItem := X
    end
end;  {TEMSVector.SingleItem}
{-------------------}
Function TEMSVector.DoubleItem(Index: LongInt): Double;
var
  X: Double;
begin
{$IFNDEF NOTCHECK}
  if ItemS<>SizeOf(Double) then
    EMSError($AC)   {Ошибка в длине элемента}
  else
{$endIF}
    begin
      GetItem(X,Index);
      DoubleItem := X
    end
end;  {TEMSVector.DoubleItem}
{-------------------}
Function TEMSVector.RealItem(Index: LongInt): Real;
var
  X: Real;
begin
{$IFNDEF NOTCHECK}
  if ItemS<>SizeOf(Real) then
    EMSError($AC)   {Ошибка в длине элемента}
  else
{$endIF}
    begin
      GetItem(X,Index);
      RealItem := X
    end
end;  {TEMSVector.RealItem}
{-------------------}
Function TEMSVector.ExtendedItem(Index: LongInt): Extended;
var
  X: Extended;
begin
{$IFNDEF NOTCHECK}
  if ItemS<>SizeOf(Extended) then
    EMSError($AC)   {Ошибка в длине элемента}
  else
{$endIF}
    begin
      GetItem(X,Index);
      ExtendedItem := X
    end
end;  {TEMSVector.ExtendedItem}
{-------------------}
Function TEMSVector.IntegerItem(Index: LongInt): Integer;
var
  X: Integer;
begin
{$IFNDEF NOTCHECK}
  if ItemS<>SizeOf(Integer) then
    EMSError($AC)   {Ошибка в длине элемента}
  else
{$endIF}
    begin
      GetItem(X,Index);
      IntegerItem := X
    end
end;  {TEMSVector.IntegerItem}
{-------------------}
Function TEMSVector.LongIntItem(Index: LongInt): LongInt;
var
  X: LongInt;
begin
{$IFNDEF NOTCHECK}
  if ItemS<>SizeOf(LongInt) then
    EMSError($AC)   {Ошибка в длине элемента}
  else
{$endIF}
    begin
      GetItem(X,Index);
      LongIntItem := X
    end
end;  {TEMSVector.LongIntItem}
{-------------------}
Function TEMSVector.ByteItem(Index: LongInt): Byte;
var
  X: Byte;
begin
{$IFNDEF NOTCHECK}
  if ItemS<>SizeOf(Byte) then
    EMSError($AC)   {Ошибка в длине элемента}
  else
{$endIF}
    begin
      GetItem(X,Index);
      ByteItem := X
    end
end;  {TEMSVector.ByteItem}
{----------  Двумерный массив в EMS  ----------}
CONSTRUCTOR TEMSMatrix.Init(ASize,Min1,Max1, 					Min2,Max2: LongInt);
  {Создает объект TEMSMatrix:
  ASize - размер элементов массива в байтах;
  Min,Max - границы индекса.}
var
  Sz: LongInt;
begin
  if (Min1>Max1) or (Min2>Max2) then
    begin
      EMSError($AB);     {Неправильные границы}
      Exit
    end;
  {Преобразуеи к одномерному массиву от 0}
  Sz := (Max1-Min1+1)*(Max2-Min2+1)-1;
  TEMSVector.Init(Asize,0,Sz);
  if not EMSErrorFlag then
    begin
      MinInd1 := Min1;
      MaxInd1 := Max1;
      MinInd2 := Min2;
      MaxInd2 := Max2
    end
end;  {TEMSMatrix.Init}
{-------------------}
CONSTRUCTOR TEMSMatrix.Load(var F: File);
  {Создает объект TEMSMatrix - читает из файла
   объект TEMSVector, затем заголовок и
   поля MinInd1, MaxInd1, MinInd2, MaxInd2}
var
  S: String;
begin
  TEMSVector.Load(F);  {Загружаем из файлаобъект-родитель}
  if not EMSErrorFlag then
    if ReadFile(F,S,SizeOf(RegHeadTEMSMatrix))
       and (S=RegHeadTEMSMatrix) then
      begin
        if ReadFile(F,MinInd1,4) and
           ReadFile(F,MaxInd1,4) and
           ReadFile(F,MinInd2,4) then
          ReadFile(F,MaxInd2,4);
        if EMSErrorFlag then
          Done
      end
    else
      EMSError($A6)
end;  {TEMSMatrix.Load}
{-------------------}
Procedure TEMSMatrix.Store(var F: File);
  {Сохраняет вектор в файле - сначала сохраняетродительский 
   объект TEMSVector, потомзаголовок и поля  
   MinInd1, MaxInd1,MinInd2, MaxInd2}

begin
  TEMSVector.Store(F);
  if not EMSErrorFlag then
    begin
      if WriteFile(F,RegHeadTEMSMatrix,
                 	SizeOf(RegHeadTEMSMatrix)) then
      if WriteFile(F,MinInd1,4) then
      if WriteFile(F,MaxInd1,4) then
      if WriteFile(F,MinInd2,4) then
        WriteFile(F,MaxInd2,4)
    end
end;  {TEMSMatrix.Store}
{-------------------}
Function TEMSMatrix.GetVecIndex(Ind1,Ind2: LongInt): LongInt;
  {Преобразует индексы двумерного массива 
				киндексу одномерного от 0}


begin
  EMSErrorFlag := False;
{$IFNDEF NOTCHECK}
  if (Ind1>MaxInd1) or (Ind1<MinInd1) or
     (Ind2>MaxInd2) or (Ind2<MinInd2) then
    EMSError($AB)   {Неправильный индекс}
  else
{$endIF}
    GetVecIndex := (Ind1-MinInd1)* 			(MaxInd2-MinInd2)+Ind2-MinInd2
end;  {TEMSMatrix.GetVecIndex}
{-------------------}
Procedure TEMSMatrix.SetItem(var Source; Ind1,Ind2: LongInt);
  {Помещает в EMS элемент с индексами
  Ind1, Ind2 из переменной Source}
var
  Item: LongInt;
begin
  Item := GetVecIndex(Ind1,Ind2);
{$IFNDEF NOTCHECK}
  if not EMSErrorFlag then
{$endIF}
   TEMSVector.SetItem(Source,Item)
end;  {TEMSMatrix.SetItem}
{-------------------}
Procedure TEMSMatrix.GetItem(var Dest;Ind1,Ind2: LongInt);
  {Читает из EMS элемент массивас индексами Ind1,Ind2}
var
  Item: LongInt;
begin
  Item := GetVecIndex(Ind1,Ind2);
{$IFNDEF NOTCHECK}
  if not EMSErrorFlag then
{$endIF}
    TEMSVector.GetItem(Dest,Item)
end;  {TEMSMatrix.GetItem}
{-------------------}
Function TEMSMatrix.SingleItem(Ind1,Ind2: LongInt): Single;
var
  Item: LongInt;
begin
  Item := GetVecIndex(Ind1,Ind2);
{$IFNDEF NOTCHECK}
  if not EMSErrorFlag then
{$endIF}
    SingleItem := TEMSVector.SingleItem(Item)
end;  {TEMSMatrix.SingleItem}
{-------------------}
Function TEMSMatrix.DoubleItem(Ind1,Ind2: LongInt): Double;
var
  Item: LongInt;
begin
  Item := GetVecIndex(Ind1,Ind2);
{$IFNDEF NOTCHECK}
  if not EMSErrorFlag then
{$endIF}
    DoubleItem := TEMSVector.DoubleItem(Item)
end;  {TEMSMatrix.DoubleItem}
{-------------------}
Function TEMSMatrix.RealItem(Ind1,Ind2: LongInt): Real;
var
  Item: LongInt;

begin
  Item := GetVecIndex(Ind1,Ind2);
{$IFNDEF NOTCHECK}
  if not EMSErrorFlag then
{$endIF}
    RealItem := TEMSVector.RealItem(Item)
end;  {TEMSMatrix.RealItem}
{-------------------}
Function TEMSMatrix.ExtendedItem(Ind1,Ind2: LongInt): Extended;
var
  Item: LongInt;
begin
  Item := GetVecIndex(Ind1,Ind2);
{$IFNDEF NOTCHECK}
  if not EMSErrorFlag then
{$endIF}
    ExtendedItem := TEMSVector.ExtendedItem(Item)
end;  {TEMSMatrix.ExtendedItem}
{-------------------}
Function TEMSMatrix.IntegerItem(Ind1,Ind2: LongInt): Integer;
var
  Item: LongInt;
begin
  Item := GetVecIndex(Ind1,Ind2);
{$IFNDEF NOTCHECK}
  if not EMSErrorFlag then
{$endIF}
    IntegerItem := TEMSVector.IntegerItem(Item)
end;  {TEMSMatrix.IntegerItem}
{-------------------}
Function TEMSMatrix.LongIntItem(Ind1,Ind2: LongInt): LongInt;
var
  Item: LongInt;
begin
  Item := GetVecIndex(Ind1,Ind2);
{$IFNDEF NOTCHECK}
  if not EMSErrorFlag then
{$endIF}
    LongIntItem := TEMSVector.LongIntItem(Item)
end;  {TEMSMatrix.LongIntItem}
{-------------------}
Function TEMSMatrix.ByteItem(Ind1,Ind2: LongInt): Byte;
var
  Item: LongInt;
begin
  Item := GetVecIndex(Ind1,Ind2);
{$IFNDEF NOTCHECK}
  if not EMSErrorFlag then
{$endIF}
    ByteItem := TEMSVector.ByteItem(Item)
end;  {TEMSMatrix.ByteItem}
{---------  Многомерный массив в EMS  ----------}
CONSTRUCTOR TEMSArray.Init(ASize: LongInt; 				NInd: Word; var Ind);
  {Создает объект TEMSArray: сначала создаетбазовый объект 
   TEMSVector с индексом от 0,затем заполняет поле NInde,    резервирует 
памятьдля поля Index  и заполняет его   границами индексов}

var
  Indx: TIndexBond absolute Ind;
  Sz: LongInt;
  k,j: Word;
begin
  {Определяем общееколичество Sz элементов массива:}
  Sz := 0;
  EMSErrorFlag := False;
  for k := 1 to NInd do
    if Indx[k,1]>Indx[k,2] then
      EMSError($AB)
    else
      Sz := Sz+Indx[k,2]-Indx[k,1]+1;
  if not EMSErrorFlag then
    begin
      {Создаем базовый объект TEMSVector}
      TEMSVector.Init(ASize,0,Sz-1);
      if not EMSErrorFlag then
        begin
          GetMem(Index,NInd*12);
          {Вычисляем множители каждого измерения
           и формируем список границ Index^}
          Index^[NInd,3] := 1;  {Младший индекс}
          Index^[NInd,1] := Indx[NInd,1];
          Index^[NInd,2] := Indx[NInd,2];
          for k := NInd-1 downto 1 do
            begin
              Index^[k,1] := Indx[k,1];
              Index^[k,2] := Indx[k,2];
              Sz := 0;
              for j := k+1 to NInd do
                Sz := Sz+(Index^[j,2]- 				Index^[j,1]+1)*Index^[j,3];
              Index^[k,3] := Sz
            end;
          NIndex := NInd
        end
      end
end;  {TEMSArray.Init}
{-------------------}
DESTRUCTOR TEMSArray.Done;
  {Уничтожает объект TEMSArray - уничтожаетбазовый объект
   TEMSVector и освобождаетпамять Index^}

begin
  TEMSVector.Done;
  FreeMem(Index,NIndex*12)
end;  {TEMSArray.Done}
{-------------------}
CONSTRUCTOR TEMSArray.Load(var F: File);
  {Загружает объект TEMSArray из файла F -сначала загружает   базовый 
объект TEMSVector,затем читает заголовок 
   RegHeadTEMSArray, полеNIndex и список границ индексов}

var
  S: String;
  k,j: Integer;
begin
  TEMSVector.Load(F);
  if not EMSErrorFlag then
    if ReadFile(F,S,SizeOf(RegHeadTEMSArray)) and
       (S=RegHeadTEMSArray) and ReadFile(F,NIndex,2) then
      begin
        GetMem(Index,NIndex*12);
        for k := 1 to NIndex do
          begin
            ReadFile(F,Index^[k,1],4);
            ReadFile(F,Index^[k,2],4);
            ReadFile(F,Index^[k,3],4)
          end;
        if EMSErrorFlag then
          Done
      end
    else
      begin
        EMSError($A6);
        TEMSVector.Done
      end
end;  {TEMSArray.Load}
{-------------------}
Procedure TEMSArray.Store(var F: File);
  {Сохраняет объект TEMSArray в файле - сохраняет
 базовый объект TEMSVector, затем пишет
 заголовок, поле NIndex и список границ индексов}
var
  k: Word;
begin
  TEMSVector.Store(F);
  if not EMSErrorFlag then
  if WriteFile(F,RegHeadTEMSArray,SizeOf(RegHeadTEMSArray))
    and WriteFile(F,NIndex,4) then
      for k := 1 to NIndex do
        begin
          WriteFile(F,Index^[k,1],4);
          WriteFile(F,Index^[k,2],4);
          WriteFile(F,Index^[k,3],4)
        end
end;  {TEMSArray.Store}
{-------------------}
Function TEMSArray.GetVecIndex(var Ind): LongInt;
  {По текущим значениям списка индексов Ind
  вычисляет индекс для объекта TEMSVector}
var
  Indx: TIndexList absolute Ind;
  N: Longint;
  k: Word;
begin
  EMSErrorFlag := False;
  N := 0;
  for k := 1 to NIndex do
{$IFNDEF NOTCHECK}
    if (Indx[k]<Index^[k,1]) or
    (Indx[k]>Index^[k,2]) then
      EMSErrorFlag := True
    else
{$endIF}
      N := N+(Indx[k]-Index^[k,1])*Index^[k,3];
  if EMSErrorFlag then
    EMSError($AB)
  else
    GetVecIndex := N-1
end;  {TEMSArray.GetVecIndex}
{-------------------}
Procedure TEMSArray.SetItem(var Source,Ind);
  {Помещает значение Sourceв элемент многомерного массива}
var
  N: LongInt;
begin
  N := GetVecIndex(Ind);
{$IFNDEF NOTCHECK}
  if not EMSErrorFlag then
{$endIF}
    TEMSVector.SetItem(Source,N)
end;  {TEMSArray.SetItem}
{-------------------}
Procedure TEMSArray.GetItem(var Dest,Ind);
  {Возвращает в переменной Destэлемент многомерного массива}
var
  N: LongInt;
begin
  N := GetVecIndex(Ind);
{$IFNDEF NOTCHECK}
  if not EMSErrorFlag then
{$endIF}
    TEMSVector.GetItem(Dest,N)
end;  {TEMSArray.GetItem}
{----  Имитатор файла последовательного доступа  ----}
CONSTRUCTOR TEMSType.Init(ASize: LongInt);
  {Создает объект TEMSType: сначала создает базовый объект 
   TEMSArea, затем обнуляет поле Pos}

begin
  TEMSArea.Init(ASize);
  Pos := 0
end;  {TEMSType.Init}
{-------------------}
CONSTRUCTOR TEMSType.Load(var F: File);
  {Считывает объект TEMSType из файла F}
var
  S: String;
begin
  TEMSArea.Load(F);
  if not EMSErrorFlag then
    if ReadFile(F,S,SizeOf(RegHeadTEMSType)) and
       (S=RegHeadTEMSType) then
      ReadFile(F,Pos,4)
    else
      Done
end;  {TEMSType.Load}
{-------------------}
Procedure TEMSType.Store(var F: File);
  {Записывает объект в файл}
begin
  TEMSArea.Store(F);
  if not EMSErrorFlag and
    WriteFile(F,RegHeadTEMSType,SizeOf(RegHeadTEMSType))
    then
      WriteFile(F,Pos,4)
end;  {TEMSType.Store}
{------------------}
Procedure TEMSType.SetItem(var Source; Sz: LongInt);
  {Записывает в TEMSType очередной элемент}
begin
  WriteEMS(Source,Pos,Sz);
  if not EMSErrorFlag then
    inc(Pos,Sz)
end;  {TEMSType.}
{-------------------}
Procedure TEMSType.GetItem(var Dest; Sz: LongInt);
  {Читает из TEMSType очередной элемент}
begin
  ReadEMS(Pos,Dest,Sz);
  if not EMSErrorFlag then
    inc(Pos,Sz)
end;  {TEMSType.}

{-------  Имитатор текстового файла  --------}
Procedure TEMSText.SetItem(S: String);
  {Помещает в EMS-память (начиная с позиции
  Pos от ее начала) строку S}
begin
  TEMSType.SetItem(S,Length(S)+1)
end;  {TEMSText.SetItem}
{-------------------}
Function TEMSText.GetItem: String;
  {Читает из EMS-памяти очередную строку}
var
  L: Byte;
  S: String;
begin
  TEMSType.GetItem(L,1);
  if not EMSErrorFlag then
    begin
      s[0] := chr(L);
      TEMSType.GetItem(S[1],L);
      GetItem := S
    end
  else
    GetItem := #26
end;  {TEMSText.GetItem}
{-------- Копия экрана в EMS-памяти  --------}
CONSTRUCTOR TEMSScreen.Init;
  {Создает объект - определяет текущий режим
  работы видеоадаптера и в зависимости от этого
  резервирует память нужного размера}
var
  Sz: LongInt;
begin
{С помощью функции $F прерывания $10 определяем
 текущий режим работы экрана}
  with Reg do
    begin
      ah := $F;
      Intr($10,Reg);
      Mode := al
    end;
{Выбираем нужный размер памяти
 1..7 - текстовые режимы или графика CGA,16 Кбайт=1с
 13,14 - имитация на EGA/VGA графики CGA,16 Кбайт=1с
 15 - моно EGA 640x350, 28 Кбайт = 2 стр.
 16 - цвет  "  "  "  ", 112 Кбайт = 7 стр.
 17 - моно VGA 640х480, 38.4 Кбайт = 3 стр.
 18 - цвет  "  "  "  ", 153.6 Кбайт = 10 стр.}
  case Mode of
    1..7,13..14 : Sz := LPage;
    15: Sz := 2*LPage;
    16: Sz := 7*LPage;
    17: Sz := 3*LPage;
    18: Sz := 10*LPage
  else
    Sz := 24*LPage   {Для SVGA}
  end;
  TEMSArea.Init(Sz)
end;  {TEMSScreen.Init}
{-------------------}
CONSTRUCTOR TEMSScreen.Load(var F: File);
  {Читает объект из файла}
var
  S: String;
begin
  TEMSArea.Load(F);
  if not EMSErrorFlag then
    if ReadFile(F,S,SizeOf(RegHeadTEMSScreen))
       and (S=RegHeadTEMSScreen) then
      ReadFile(F,Mode,1)
    else
      Done
end;  {TEMSScreen.Load}
{-------------------}
Procedure TEMSScreen.Store(var F: File);
  {Сохраняет объект в файле}
begin
  TEMSArea.Store(F);
  if not EMSErrorFlag then
    if WriteFile(F,RegHeadTEMSScreen,SizeOf(TEMSScreen))
      then WriteFile(F,Mode,1)
end;  {TEMSScreen.Store}
{-------------------}
Procedure TEMSScreen.PutScreen;
  {Записывает в EMS-память копию экрана}
var
  x,y,xx,yy,dy: Integer;
  Pag: Byte;
  EMS,Video: Pointer;
begin
  {Проверяем текущий видеорежим}
  with Reg do
    begin
      ah := $F;
      Intr($10,Reg);
      if al<>Mode then		{Режим соответствует Mode?}
        begin         		{Нет - сообщаем и выходим}
          EMSError($AD);
          Exit
        end
    end;
  {Копируем видеопамять в зависимости от режима}
  EMS := ptr(EMSS,0);       	{Начало EMS}
  case Mode of
    1..6,13..14:{Текстовые режимы всех адаптеров,
   		кроме MDA, графика CGA или ее имитация:
   		начало видеопамяти в $B800, длина до 16 Кбайт}
      begin
        Video := Ptr($B800,0);
        MapEMSPage(Handle,0,0);
        if not EMSErrorFlag then
          MoveFromScreen(Video^,EMS^,LPage)
      end;
    7:          {Текстовый режим MDA:
   		начало видеопамяти в $B000,  длина 4 Кбайт}
      begin
        Video := Ptr($B000,0);
        MapEMSPage(Handle,0,0);
        if not EMSErrorFlag then
          MoveFromScreen(Video,EMS,LPage div 4)
      end;
    else  	{Остальные дисплеи: предполагается, что
      		это EGA, VGA или SVGA в графическом режиме}
      begin
        x := 0;             {Левый верхний...}
        xx := GetMaxX;      {угол экрана}
        y := 0;             {Правый нижний угол}
        yy := 0;
        Pag := 0;     {Номер начальной стр.EMS}
        {Определяем количество dy полных строк
         экрана, которые еще умещаются в памяти
         одной страницы EMS}
        while (ImageSize(x,y,xx,yy)<LPage) and
              (yy<=GetMaxY) do inc(yy);
        dy := yy-1;
{Основной цикл сохранения копии блоками по 16 К}
        repeat
          {Картируем страницу окна}
          MapEMSPage(Handle,0,Pag);
          {Получаем копию части экрана}
          if y+dy<=GetMaxY then
            GetImage(x,y,xx,y+dy,EMS^)
          else
            GetImage(x,y,xx,GetMaxY,EMS^);
          inc(Pag);
          inc(y,dy)
        until y>=GetMaxY
      end
    end  {case Mode}
end;  {TEMSScreen.PutScreen}
{-------------------}
Procedure TEMSScreen.GetScreen;
  {Получает из EMS-памяти копию экрана}
var
  x,y,xx,yy,dy: Integer;
  Pag: Byte;
  EMS,Video: Pointer;
begin
  {Проверяем текущий видеорежим}
  with Reg do
    begin
      ah := $F;
      Intr($10,Reg);
      if al<>Mode then    {Режимсоответствует Mode?}
        begin             {Нет -сообщаем и выходим}
          EMSError($AD);
          Exit
        end
    end;
  {Переносим копию в видеопамять
   в зависимости от режима}
  EMS := ptr(EMSS,0);       {Начало EMS}
  case Mode of
    1..6,13..14:{Текстовые режимы всех адаптеров,
   		кроме MDA, графика CGA или ее имитация:
   		начало видеопамяти в $B800, длина до 16 Кбайт}
      begin
        Video := Ptr($B800,0);
        MapEMSPage(Handle,0,0);
        if not EMSErrorFlag then
          MoveToScreen(EMS^,Video^,LPage)
      end;
    7:    {Текстовый режим MDA: начало
           видеопамяти в $B000,  длина 4 Кбайт}
      begin
        Video := Ptr($B000,0);
        MapEMSPage(Handle,0,0);
        if not EMSErrorFlag then
          MoveToScreen(EMS,Video,LPage div 4)
      end;
    else   {Остальные дисплеи: предполагается,
 	   что это EGA, VGA или SVGA в графическом режиме}
      begin
        x := 0;             {Левый верхний...}
        xx := GetMaxX;      {угол экрана}
        y := 0;             {Правый нижний угол}
        yy := 0;
        Pag := 0;      {Номер начальной стр.EMS}
{Определяем количество dy полных строк экрана,
которые еще умещаются в памяти одной страницы EMS}
        while (ImageSize(x,y,xx,yy)<LPage) and
              (yy<=GetMaxY) do inc(yy);
        dy := yy-1;
 {Основной цикл восстановленияэкрана блоками по 16 К}
        repeat
          {Картируем окно}
          MapEMSPage(Handle,0,Pag);
          {Переносим копию части экрана}
          PutImage(x,y,EMS^,NormalPut);
          inc(Pag);
          inc(y,dy)
        until y>=GetMaxY
      end
    end  {case Mode}
end;  {TEMSScreen.GetScreen}
{------------  Интерфейс с EMM  ------------}
Procedure Intr67;
  {Реализует прерывание $67
  и устанавливает флаг EMSStatus}
begin
  Intr($67,Reg);
  EMSStatus := Reg.ah
end;
{------------------}
Function IsEMS: Boolean;
  {Возвращает TRUE, если в ПК имеется EMS-память}
const
  Name: array [1..9] of Char = 'EMMXXXX0'#0;
label
  Exit;
begin
  if EMSVer=0 then with Reg do {Былапроверка раньше?}
    begin        	{Нет - проверяем установку EMM}
      ah := $3D; 	{Создаем дескриптор файла}
      al := 0;   	{Для чтения}
      dx := Ofs(Name);  	{С именем "EMMXXXX0"}
      ds := Seg(Name);
      MSDOS(Reg);
      {Если файла нет - EMM не установлен}
      if (Flags and FCarry)<>0 then
        Goto Exit;
      {Проверяем статус файла}
      bx := ax;         	{Дескриптор файла}
      ah := $44;        	{Запрос IOCTL}
      al := 7;          	{Дать статус файла}
      MSDOS(Reg);
      if ((Flags and FCarry)<>0) or (al=0) then
        Goto Exit;
      ah := $46;      	{Получаем номер версии EMM}
      Intr67;
      if EMSStatus=0 then {Если ошибка - нет EMM}
        begin
          EMSVer := al;  {Сохраняем номер версии}
          ah := $41;     {Получаем сегмент окна}
          Intr67;
          EMSS := bx     {Сохраняем сегмент}
        end
    end;
Exit:
  IsEMS := EMSVer<>0
end;  {IsEMS}
{------------------}
Function GetEMMVersion: String;
  {Возвращает номер версии EMM в формате 'X.X'}
var
  s,ss: String;
begin
  if EMSVer=0 then
    if IsEMS then;
  Str(EMSVer shr 4,s);
  Str(EMSVer and $F,ss);
  GetEMMVersion := s+'.'+ss
end;
{------------------}
Function EMSSeg: Word;
  {Возвращает сегментную часть
   адреса "окна" EMS-памяти}
begin
  if EMSS=0 then
    if IsEMS then;
  EMSSeg := EMSS
end;  {EMSSeg}
{------------------}
Procedure GetEMSInfo(var AllPage, Pages: Word);
  {Возвращает полное количество (AllPages) и
  количество незанятых (Pages) страниц}
begin
  if IsEMS then with Reg do
    begin
      ah :=$42;
      Intr67;
      AllPage := dx;
      Pages := bx
    end
  else
    begin
      AllPage := 0;
      Pages := 0
    end
end;  {GetEMSInfo}
{------------------}
Procedure NewEMSHandle(var Handle: Word;Pages: Word);
  {Открывает новый дескриптор Handle и связывает
   с ним Pages страниц EMS}
begin
  if IsEMS then with Reg do
    begin
      ah := $43;
      bx := Pages;
      Intr67;
      Handle := dx
    end
end;  {NewEMSHandle}



Procedure DisposeEMSHandle(var Handle: Word);
  {Удаляет дескриптор Handle    и освобождаетсвязанную с ним память}
begin
  if IsEMS then with Reg do
    begin
      ah := $45;
      dx := Handle;
      Intr67
    end
end;  {DisposeEMSHandle}
{-------------------}
Procedure MapEMSPage(Handle,Physic,Logic: Word);
  {Картирует окно, связывая его Physic физическую
   страницу с Logic логической страницейдескриптора Handle}
const
  OldH: Word=$FFFF;  {Параметры...}
  OldL: Word=$FFFF;  {предыдущего...}
  OldP: Word=$FFFF;  {обращения к процедуре}
begin
asm
{Проверяем параметры обращения: если они не менялись,
 значит контекст страниц сохранился и можно не картировать}

  mov ax,Physic      	{AX := Physic}
  mov bx,Logic       	{BX := Logic}
  mov dx,Handle      	{DX := Handle}
  cmp ax,OldP        	{Physic=OldP ?}
  jne @do            	{Нет - изменилась физ.стр.}
  cmp bx,OldL        	{Logic=OldL ?}
  jne @do           	{Нет - изменилась логич.стр.}
  cmp dx,OldH       	{Handle=OldH ?}
  je @Exit          	{Да - параметры не менялись,
                    	не нужно картировать еще раз}
@do:   	{Параметры изменились - картируем:}
  mov OldP,ax     	{Сохраняем...}
  mov OldL,bx     	{новые...}
  mov OldH,dx     	{параметры}
  mov ah,$44      	{Код функции для картирования}
  int $67         	{Картируем}
  mov EMSStatus,ah   	{Новый статус EMS}
@Exit: end;
end;  {MapEMSPage}
{=============} end. {Unit F_EMS} {=============}
