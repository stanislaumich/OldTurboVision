{===============} UNIT F_Disk; {===============}
{
+------------------------------------------------------------+
| Модуль содержит подпрограммы для гибкой работы с дисками.  |
| Во всех подпрограммах параметр DISK относится к логическим |
| дискам: 0=A, 1=B, 2=C, 3=D и т.д. Параметр SEC - относи-   |
| тельный  номер сектора:  0 = загрузочный сектор, далее по  |
| секторам до конца дорожки, по головкам, по цилиндрам.      |
+------------------------------------------------------------+
}
                  INTERFACE
type
  {Информация из BPB загрузочного сектора:}
  BPB_Type = record
    SectSiz : Word; {Количество байт в секторе}
    ClustSiz: Byte; {Количество секторов в кластере}
    ResSecs : Word; {Количество секторов перед FAT}
    FatCnt  : Byte; {Количество FAT}
    RootSiz : Word; {Количество элементов корневого каталога}
    TotSecs : Word; {Количество секторов на диске}
    Media   : Byte; {Дескриптор носителя}
    FatSize : Word  {Количество секторов в FAT}
  end;  {BPB_Type}
  {Дополнительная информация из загрузочного сектора:}
  Add_BPB_Type = record
    TrkSecs : Word;   	{Количество секторов на дорожке
                        для разделов меньше 32 Мбайт или 0}
    HeadCnt : Word;   	{Количество головок}
    HidnSecLo : Word;   {Количество спрятанных секторов для
                        разделов меньше 32 Мбайт}
    HidnSecHi: Word;    {Вместе в HidnSecLo дает количество
                        спрятанных секторов для
                        разделов больше 32 Мбайт}
    LargSectors: LongInt; {Общее количество секторов для
                          разделов больше 32 Мбайт}
  end;  {Add_BPB_Type}
  {Элемент дискового каталога:}
  Dir_Type = record case Byte of
  1:(
    Name  : array [1..8] of Char;	{Имя файла или каталога}
    Ext   : array [1..3] of Char;	{Расширение}
    FAttr : Byte;     		        {Атрибуты файла}
    Reserv:array [1..10] of Byte;       {Резервное поле}
    Time  : Word;     		        {Время создания}
    Date  : Word;     		        {Дата создания}
    FirstC: Word;     		        {Номер первого кластера}
    Size  : LongInt   		        {Размер файла в байтах});
  2:(NameExt: array [1..11] of Char)
  end;  {Dir_Type}
  {Описатель логического раздела}
  PartType = record
    Act: Boolean;     		{Флаг активности раздела}
    BegHead: Byte;    		{Головка начала раздела}
    BegSC  : Word;    		{Сектор/цилиндр начала}
    SysCode: Byte;    		{Системный код}
    EndHead: Byte;    		{Головка конца раздела}
    EndSC  : Word;    		{Сектор/цилиндр конца}
    RelSect: LongInt; 		{Относительный сектор начала}
    FoolSiz: LongInt  		{Объем в секторах}
  end;  {PartType}
  {Загрузочный сектор диска}
  PBoot = ^TBoot;
  TBoot = record
  case Byte of
  0:(
    a  : array [1..11] of Byte;
    BPB: BPB_Type;
    Add: Add_BPB_Type;
    c  : array [1..+$1BE-(SizeOf(BPB_Type)+
         SizeOf(Add_BPB_Type)+11)] of Byte;
    Par: array [1..4] of PartType);
  1: (b: array [1..512] of Byte)
  end;
  {Описатель диска по структуре IOCTL}
  IOCTL_Type = record
    BuildBPB: Boolean; 		{Cтроить BPB}
    TypeDrv : Byte;    		{Тип диска}
    Attrib  : Word;    		{Атрибуты диска}
    Cylindrs: Word;    		{Число цилиндров}
    Media   : Byte;    		{Тип носителя}
    BPB     : BPB_Type;
    Add     : Add_BPB_Type;
    Reserv  : array [1..10] of Byte;
  end;
  {Описатель диска}
  TDisk = record
    Number  : Byte; 	{Номер диска 0=А,...}
    TypeD   : Byte; 	{Тип диска}
    AttrD   : Word; 	{Атрибуты диска}
    Cyls    : Word; 	{Число цилиндров на диске}
    Media   : Byte; 	{Дескриптор носителя}
    SectSize: Word; 	{Количество байт в секторе}
    TrackSiz: Word; 	{Количество секторов на дорожке}
    TotSecs : LongInt; 	{Полная длина в секторах}
    Heads   : Byte; 	{Количество головок}
    Tracks  : Word; 	{Число цилиндров на носителе}
    ClusSize: Byte; 	{Количество секторов в кластере}
    MaxClus : Word; 	{Максимальный номер кластера}
    FATLock : Word; 	{Номер 1-го сектора FAT}
    FATCnt  : Byte; 	{Количество FAT}
    FATSize : Word; 	{Длина FAT в секторах}
    FAT16: Boolean; 	{Признак 16-битового элемента FAT}
    RootLock: Word; 	{Начало корневого каталога}
    RootSize: Word; 	{Количество элементов каталога}
    DataLock: Word; 	{Начальный сектор данных}
  end;
  {Список описателей диска}
  PListDisk = ^TListDisk;
  TListDisk = record
    DiskInfo: TDisk;
    NextDisk: PListDisk
  end;
var
  Disk_Error : Boolean;    	{Флаг ошибки}
  Disk_Status: Word;       	{Код ошибки}
const
  Disks: PListDisk = NIL;  {Начало списка описателей диска}

Function ChangeDiskette(Disk: Byte): Boolean;
  {Возвращает TRUE, если изменялось положение
   запора на указанном приводе гибкого диска}

Procedure FreeListDisk(var List: PListDisk);
  {Удаляет список описателей дисков}

Procedure GetAbsSector(Disk,Head: Byte; CSec: Word; var Buf);
  {Читает абсолютный дисковый сектор с помощью прерывания $13}

Function GetCluster(Disk: Byte;Sector: Word): Word;
  {Возвращает номер кластера по заданному номеру сектора}

Function GetDefaultDrv: Byte;
  {Возвращает номер диска по умолчанию}

Procedure GetDirItem(FileName: String;var Item: Dir_Type);
  {Возвращает элемент справочника для указанного файла}

Procedure GetDirSector(Path: String;var Disk: Byte;
                       		   var Dirs,DirSize: Word);
  {Возвращает адрес сектора, в котором содержится
   начало нужного каталога, или 0, если каталог не найден.
   Вход:
     PATH - полное имя каталога ('', если каталог текущий).
   Выход:
     DISK - номер диска;
     DIRS - номер первого сектора каталога или 0;
     DIRSIZE - размер каталога (в элементах DIR_TYPE).}

Procedure GetDiskInfo(Disk: Byte;var DiskInfo: TDisk);
  {Возвращает информацию о диске DISK}

Function GetDiskNumber(c: Char): Byte;
  {Преобразует имя диска A...Z в номер 0...26.
   Если указано недействительное имя,возвращает 255}

Function GetFATItem(Disk: Byte; Item: Word): Word;
  {Возвращает содержимое указанного элемента FAT}

Procedure GetIOCTLInfo(Disk: Byte;var IO: IOCTL_Type);
  {Получить информацию об устройстве
   согласно общему вызову IOCTL}

Procedure GetListDisk(var List: PListDisk);
  {Формирует список описателей дисков}

Procedure GetMasterBoot(var Buf);
  {Возвращает в переменной Buf главный загрузочный сектор}

Function GetMaxDrv: Byte;
  {Возвращает количество логических дисков}

Function GetSector(Disk: Byte;Cluster: Word): Word;
  {Преобразует номер кластера в номер сектора}

Function PackCylSec(Cyl,Sec: Word): Word;
  {Упаковывает цилиндр и сектор в одно слово для прерывания $13}

Procedure ReadSector(Disk: Byte; Sec: LongInt; NSec: Word; var Buf);
  {Читает сектор (секторы) на указанном диске}

Procedure SetAbsSector(Disk,Head: Byte; CSec: Word; var Buf);
  {Записывает абсолютный дисковый сектор
   с помощью прерывания $13}

Procedure SetDefaultDrv(Disk: Byte);
  {Устанавливает диск по умолчанию}

Procedure SetFATItem(Disk: Byte;Cluster,Item: Word);
  {Устанавливает содержимое ITEM в элемент CLUSTER таблицы FAT}

Procedure SetMasterBoot(var Buf);
  {Записывает в главный загрузочный сектор содержимое Buf}

Procedure UnPackCylSec(CSec: Word;var Cyl,Sec: Word);
  {Декодирует цилиндр и сектор для прерывания $13}

Procedure WriteSector(Disk: Byte; Sec: LongInt; NSec: Word; var Buf);
  {Записывает сектор (секторы) на указанный диск}

                 IMPLEMENTATION

Uses DOS;
var
  Reg: registers;
Procedure Output;
  {Формирует значения Disk_Status и Disk_Error}
begin
  with Reg do
    begin
      Disk_Error := Flags and FCarry = 1;
      Disk_Status:= ax
    end
end;  {Output}
{----------------------}
Function ChangeDiskette(Disk: Byte): Boolean;
  {Возвращает TRUE, если изменялось положение
   запора на указанном приводе гибкого диска}
begin
  with Reg do
    begin
      AH := $16;
      DL := Disk;
      Intr($13, Reg);
      Output;
      ChangeDiskette := Disk_Error and (AH=6)
    end
end;  {ChangeDiskett}
{------------------------}
Procedure FreeListDisk(var List: PListDisk);
  {Удаляет список дисковых описателей}
var
  P: PListDisk;
begin
  while List <> NIL do
    begin
      P := List^.NextDisk;
      Dispose(List);
      List := P
    end
end;  {FreeListDisk}
{------------------------}
Procedure GetAbsSector(Disk,Head: Byte; CSec: Word; var Buf);
  {Читает абсолютный дисковый сектор с помощью прерывания $13}
begin
  with Reg do
    begin
      ah := 2;       		{Операция чтения}
      dl := Disk;    		{Номер привода}
      dh := Head;    		{Номер головки}
      cx := CSec;    		{Цилиндр/сектор}
      al := 1;       		{Читать один сектор}
      es := seg(Buf);
      bx := ofs(Buf);
      Intr($13,Reg);
      Output
    end
end;  {GetAbsSector}
{----------------------}
Function GetCluster(Disk: Byte; Sector: Word): Word;
  {Возвращает номер кластера по заданному номеру сектора}
var
  DI: TDisk;
begin
  GetDiskInfo(Disk,DI);
  if not Disk_Error then with DI do
    if (Sector-DataLock >= 0) and (TotSecs-Sector >= 0) then
      GetCluster :=   		{Нормальное обращение}
        (Sector-DataLock) div ClusSize+2
    else
      GetCluster := 0 		{Неверный номер сектора}
  else
    GetCluster := 0   		{Неверный номер диска}
end;  {GetCluster}
{----------------------}
Function GetDefaultDrv: Byte;
  {Возвращает номер диска по умолчанию}
begin
  with Reg do
    begin
      AH := $19;
      MSDOS(Reg);
      GetDefaultDrv := AL
    end
end;  {GetDefaultDrv}
{------------------------}
Procedure GetDirItem(FileName: String; var Item: Dir_Type);
  {Возвращает элемент справочника для указанного файла}
var
  Dir:array [1..16] of Dir_Type; 	{Буфер на 1 сектор каталога}
  Path : DirStr;  		{Маршрут поиска}
  NameF: NameStr; 		{Имя файла}
  Ext  : ExtStr;  		{Расширение файла}
  Disk : Byte;    		{Номер диска}
  Dirs : Word;    		{Номер сектора}
  DirSize: Word;  		{Размер каталога}
  Find: Boolean;  		{Флаг поиска}
  j   : Integer;  		{Номер элемента каталога}
{-------}
Procedure FindItem;
  {Ищет нужный элемент в секторах каталога}
var
  k,i: Integer;
  m: array [1..11] of Char; 	{Массив имени}
  Clus: Word;               	{Номер кластера}
  DI: TDisk;
begin
  GetDiskInfo(Disk,DI);        	{Получаем длину кластера}
  ReadSector(Disk,Dirs,1,Dir); 	{Читаем первый сектор}
  k := 0; 		        {Количество просмотренных элементов}
  j := 1;  		        {Текущий элемент каталога}
{Готовим имя и расширение для поиска}
  FillChar(m,11,' ');
  Move(NameF[1],m[1],Length(NameF));
  if ext<>'' then
    Move(Ext[2],m[9],Length(ext)-1);
  Find := False;
{Цикл поиска}
  repeat
    if Dir[j].Name[1]=#0 then
      exit;     		{Обнаружен конец списка}
    if (Dir[j].FAttr and $18) = 0 then
      begin 		{Проверяем очередное имя в каталоге}
        Find := True;
        i := 1;
        While Find and (i<=11) do
          begin
            Find := m[i]=Dir[j].NameExt[i];
            inc(i)
          end;
      end;
    if not Find then inc(j);
    if j = 17 then
      begin
        inc(k,16);
        if k >= DirSize then
          exit;  		{Дошли до конца каталога}
        j := 1;  		{Продолжаем с 1-го элемента 				 следующего сектора}
        if (k div 16) mod DI.ClusSize=0 then
            if succ(Dirs)<DI.DataLock then
              inc(Dirs) 		{Корневой каталог}
            else
              begin     		{Конец кластера}
                {Новый кластер}
                Clus := GetFATItem(Disk,GetCluster(Disk,Dirs));
                {Новый сектор}
                Dirs := GetSector(Disk,Clus)
              end
        else     	{Очередной сектор - в кластере}
          inc(Dirs);
        ReadSector(Disk,Dirs,1,Dir)
      end
  until Find
end;  {FindItem}
{-------}
begin  {GetDirItem}
  {Готовим имя файла}
  FileName := FExpand(FileName);
  FSplit(FileName, Path, NameF, Ext);
  {Искать каталог}
  GetDirSector(Path,Disk,Dirs,DirSize);
  Find := Dirs<>0;  		{Dirs=0 - ошибка в маршруте}
  if Find then
    FindItem;       		{Ищем нужный элемент}
  if Find then
    begin
      {Переносим элемент каталога в Item}
      Move(Dir[j],Item,SizeOf(Dir_Type));
      {Сбросить ошибку}
      Disk_Error := False
    end
  else
    begin           		{Файл не найден}
      Disk_Error := True;
      Disk_Status := $FFFF
    end
end;  {GetDirItem}
{------------------------}
Procedure GetDirSector(Path: String; var Disk: Byte;
                     		var Dirs,DirSize: Word);
  {Возвращает адрес сектора, в котором содержится начало
   нужного каталога, или 0, если каталог не найден.
   Вход:
     PATH - полное имя каталога ('', если каталог - текущий).
   Выход:
     DISK - номер диска;
     DIRS - номер первого сектора каталога или 0;
     DIRSIZE - размер каталога (в элементах DIR_TYPE).}
var
  i,j,k: Integer;  		{Вспомогательные переменные}
  Find : Boolean;  		{Признак поиска}
  m    : array [1..11] of Char;	{Массив имени каталога}
  s    : String;   		{Вспомогательная переменная}
  DI   : TDisk;    		{Информация о диске}
  Dir  :array [1..16] of Dir_Type;   {Сектор каталога}
  Clus : Word;     		{Текущий кластер каталога}
label
  err;
begin
{Начальный этап: готовим путь к каталогу и диск}
  if Path = '' then             {Если каталог текущий,}
    GetDir(0,Path);             {дополняем маршрутом поиска}
  if Path[2] <> ':' then  	{Если нет диска,}
    Disk := GetDefaultDrv 	{берем текущий}
  else
    begin            		{Иначе проверяем имя диска}
      Disk := GetDiskNumber(Path[1]);
      if Disk=255 then
        begin        		{Недействительное имя диска}
Err:          {Точка выхода при неудачном поиске}
          Dirs := 0;             	{Нет сектора}
          Disk_Error := True;    	{Флаг ошибки}
          Disk_Status := $FFFF;  	{Статус $FFFF}
          exit
        end;
      Delete(Path,1,2){Удаляем имя диска из пути}
    end;
{Готовим цикл поиска}
  if Path[1]='\' then        		{Удаляем символы \}
    Delete(Path,1,1);        		{в начале}
  if Path[Length(Path)] = '\' then
    Delete(Path,Length(Path),1);  	{и конце маршрута}
  GetDiskInfo(Disk,DI);
  with DI do
    begin
      Dirs := RootLock;     		{Сектор с каталогом}
      DirSize := RootSize   		{Длина каталога}
    end;
  ReadSector(Disk,Dirs,1,Dir);   	{Читаем корневой каталог}
  Clus := GetCluster(Disk,Dirs); 	{Кластер начала каталога}
{Цикл поиска по каталогам}
  Find := Path='';     		        {Path='' - конец маршрута}
  while not Find do
    begin
      {Получаем в S первое имя до символа \}
      s := Path;
      if pos('\',Path) <> 0 then
        s[0] := chr(pos('\',Path)-1);
      {Удаляем выделенное имя из маршрута}
      Delete(Path,1,Length(s));
      if Path[1]='\' then
        Delete(Path,1,1); 	{Удаляем разделитель \}
      {Говим массив имени}
      FillChar(m,11,' ');
      move(s[1],m,ord(s[0]));
{Просмотр очередного каталога}
      k := 0;  {Количество просмотренных элементов каталога}
      j := 1;          		{Текущий элемент в Dir}
      repeat           		{Цикл поиска в каталоге}
        if Dir[j].Name[1]=#0 then {Если имя}
          Goto Err;    {начинается c 0 - это конец каталога}
        if Dir[j].FAttr=Directory then
          begin
            Find := True;
            i := 1;
            while Find and (i<=11) do
              begin    		{Проверяем имя}
                Find := m[i]=Dir[j].NameExt[i];
                inc(i)
              end
          end;
        if not Find then inc(j);
        if j = 17 then
          begin      	{Исчерпан сектор каталога}
            j := 1;  	{Продолжаем с 1-го элемента
                      	 следующего сектора}
            inc(k,16); 	{k - сколько элементов просмотрели}
            if k >= DirSize then
              goto err; 	{Дошли до конца каталога}
            if (k div 16) mod DI.ClusSize=0 then
              begin 	{Исчерпан кластер - ищем следующий}
                {Получаем новый кластер}
                Clus := GetFATItem(Disk,Clus);
		{Можно не проверять на конец цепочки,
			т.к. каталог еще не исчерпан}
                {Получаем нoвый сектор}
                Dirs := GetSector(Disk,Clus)
              end
            else         			{Очередной сектор -}
              inc(Dirs);  		        {в текущем кластере}
            ReadSector(Disk,Dirs,1,Dir);
          end
      until Find;
{Наден каталог для очередного имени в маршруте}
      Clus := Dir[j].FirstC;    		{Кластер начала}
      Dirs := GetSector(Disk,Clus);     	{Сектор}
      ReadSector(Disk,Dirs,1,Dir);
      Find := Path = '' 			{Продолжаем поиск,
                                                 если не исчерпан путь}
    end {while not Find}
end;  {GetDirSector}
{------------------------}
Procedure ReadWriteSector(Disk: Byte;
             Sec: LongInt; NSec: Word; var Buf; Op: Byte); forward;

Procedure GetDiskInfo(Disk: Byte; var DiskInfo: TDisk);
  {Возвращает информацию о диске DISK}
var
  Boot: TBoot;
  IO  : IOCTL_Type;
  p: PListDisk;
label
  Get;
begin
  Disk_Error := False;
  if (Disk<2) or (Disks=NIL) then
    goto Get; {Не искать в списке, если дискета или нет списка}
  {Ищем в списке описателей}
  p := Disks;
  while (p^.DiskInfo.Number<>Disk) and (p^.NextDisk<>NIL) do
    p := p^.NextDisk;  	      {Если не тот номер диска}
  if p^.DiskInfo.Number=Disk then
    begin        	      {Найден нужный элемент - выход}
      DiskInfo := p^.DiskInfo;
      exit
    end;
{Формируем описатель диска с помощью вызова IOCTL}
Get:
  IO.BuildBPB := True;   		{Требуем построить BPB}
  GetIOCTLInfo(Disk,IO); 		{Получаем информацию}
  if Disk_Error then
    exit;
  with DiskInfo, IO do   		{Формируем описатель}
    begin
      Number   := Disk;
      TypeD    := TypeDrv;
      AttrD    := Attrib;
      Cyls     := Cylindrs;
      Media    := BPB.Media;
      SectSize := BPB.SectSiz;
      TrackSiz := Add.TrkSecs;
      TotSecs  := BPB.TotSecs;
      if TotSecs=0 then
        begin                       {Диск большой емкости}
          ReadWriteSector(Number,0,1,Boot,2);  {Читаем загрузочный сектор}
          TotSecs := Boot.Add.LargSectors;
        end;
      Heads    := Add.HeadCnt;
      Tracks   := (TotSecs+pred(TrackSiz)) div (TrackSiz*Heads);
      ClusSize := BPB.ClustSiz;
      FATLock  := BPB.ResSecs;
      FATCnt   := BPB.FatCnt;
      FATSize  := BPB.FatSize;
      RootLock := FATLock+FATCnt*FATSize;
      RootSize := BPB.RootSiz;
      DataLock := RootLock+(RootSize*SizeOf(Dir_Type)) div SectSize;
      MaxClus  := (TotSecs-DataLock) div ClusSize+2;
      FAT16    := (MaxClus > 4086) and (TotSecs > 20790)
    end
end;  {GetDiskInfo}
{-----------------------}
Function GetDiskNumber(c: Char): Byte;
  {Преобразует имя диска A...Z в номер 0...26.
   Если указано недействительное имя, возвращает 255}
var
  DrvNumber: Byte;
begin
  if UpCase(c) in ['A'..'Z'] then
    DrvNumber := ord(UpCase(c))-ord('A')
  else
    DrvNumber := 255;
  if DrvNumber > GetMaxDrv then
    DrvNumber := 255;
  GetDiskNumber := DrvNumber;
end;  {GetDiskNumber}
{-----------------------}
Function GetFATItem(Disk: Byte;Item: Word): Word;
  {Возвращает содержимое указанного элемента FAT}
var
  DI   : TDisk;
  k,j,n: Integer;
  Fat  : record
    case Byte of
    0: (w: array [0..255] of Word);
    1: (b: array [0..512*3-1] of Byte);
  end;
begin
  GetDiskInfo(Disk,DI);
  if not Disk_Error then with DI do
    begin
      if (Item > MaxClus) or (Item < 2) then
        Item := $FFFF   	        {Задан ошибочный номер кластера}
      else
        begin
          if FAT16 then
            begin
              k := Item div 256;  	{Нужный сектор FAT}
              j := Item mod 256;  	{Смещение в секторе}
              n := 1                    {Количество читаемых секторов}
            end
          else
            begin
              k := Item div 1024;       {Нужная тройка секторов FAT}
              j := (3*Item) shr 1-k*1536; {Cмещение в секторе}
              n := 3                      {Количество читаемых секторов}
            end;
          {Читаем 1 или 3 сектора FAT}
          ReadSector(Disk,FATLock+k*n,n,Fat);
          if not Disk_Error then
            begin
              if FAT16 then
                Item := Fat.w[j]
              else
                begin
                  n := Item;      {Cтарое значение Item для проверки четности}
                  Item := Fat.b[j]+Fat.b[j+1] shl 8;
                  if odd(n) then
                    Item := Item shr 4
                  else
                    Item := Item and $FFF;
                  if Item > $FF6 then
                    Item := $F000+Item
                end;
              GetFatItem := Item
            end
        end
    end
end;  {GetFATItem}
{-----------------------}
Procedure GetIOCTLInfo(Disk: Byte;var IO: IOCTL_Type);
  {Получает информацию об устройстве
   согласно общему вызову IOCTL}
begin
  with Reg do
    begin
      ah := $44;    		{Функция 44}
      al := $0D;    		{Общий вызов IOCTL}
      cl := $60;    		{Дать параметры устройства}
      ch := $8;     		{Устройство - диск}
      bl := Disk+1; 		{Диск 1=А,..}
      bh := 0;
      ds := seg(IO);
      dx := ofs(IO);
      MSDOS(Reg);
      Output
    end
end;  {GetIOCTLInfo}
{-----------------------}
Procedure GetListDisk(var List: PListDisk);
  {Формирует список дисковых описателей}
var
  Disk: Byte;
  DI  : TDisk;
  P,PP: PListDisk;
begin
  Disk := 2;  			{Начать с диска С:}
  List := NIL;
  repeat
    GetDiskInfo(Disk,DI);
    if not Disk_Error then
      begin
        New(P);
        if List=NIL then
          List := P
        else
          PP^.NextDisk := P;
        with P^ do
          begin
            DiskInfo := DI;
            NextDisk := NIL;
            inc(Disk);
            PP := P
          end
      end
  until Disk_Error;
  Disk_Error := False
end;  {GetListDisk}
{---------------------}
Procedure GetMasterBoot(var Buf);
  {Возвращает в переменной Buf главный загрузочный сектор}
begin
  GetAbsSector($80,0,1,Buf)
end;  {GetMasterBoot}
{---------------------}
Function GetMaxDrv: Byte;
  {Возвращает количество логических дисков}
const
  Max: Byte = 0;
begin
  if Max=0 then with Reg do
    begin
      ah := $19;
      MSDOS(Reg);
      ah := $0E;
      dl := al;
      MSDOS(Reg);
      Max := al
    end;
  GetMaxDrv := Max
end;  {GetMaxDrv}
{----------------------}
Function GetSector(Disk: Byte; Cluster: Word): Word;
  {Преобразует номер кластера в номер сектора}
var
  DI: TDisk;
begin
  GetDiskInfo(Disk,DI);
  if not Disk_Error then with DI do
    begin
      Disk_Error := (Cluster > MaxClus) or(Cluster < 2);
      if not Disk_Error then
        GetSector := (Cluster-2)*ClusSize +DataLock
    end;
  if Disk_Error then
    GetSector := $FFFF
end;  {GetSector}
{-------------------------}
Function PackCylSec(Cyl,Sec: Word): Word;
  {Упаковывает цилиндр и сектор в одно слово для прерывания $13}

begin
  PackCylSec := Sec+(Cyl and $300) shr 2+(Cyl shl 8)
end;  {CodeCylSec}
{-------------------------}
Procedure ReadWriteSector(Disk: Byte;
             Sec: LongInt; NSec: Word; var Buf; Op: Byte);
  {Читает или записывает сектор (секторы):
    Op = 0 - читать; 1 - записать (малый диск)
       = 2 - читать; 3 - записать (большой диск)}
type
  TBuf0 = record
    StartSec: LongInt;
    Secs: Word;
    AdrBuf: Pointer
  end;
var
  Buf0: TBuf0;
  S: Word;
  O: Word;
begin
    if Op>1 then with Buf0 do
      begin
        {Готовим ссылочную структуру для большого диска}
        AdrBuf := Ptr(Seg(Buf),Ofs(Buf));
        StartSec := Sec;
        Secs := NSec;
        S := Seg(Buf0);
        O := Ofs(Buf0);
          asm
            mov CX,$FFFF
            mov AL,Op
            shr AX,1
            mov AL,Disk
            push DS
            push BP
            mov BX,O
            mov DS,S
            jc @1
            int 25H
            jmp @2
        @1: int 26H
        @2: pop DX
            pop BP
            pop DS
            mov BX,1
            jc @3
            mov BX,0
            xor AX,AX
        @3: mov Disk_Error,BL
            mov Disk_Status,AX
          end
      end
    else             {Обращение к диску малой емкости}
  asm
    mov    DX, Word Ptr Sec       {DX := Sec}
    mov    CX,NSec      {CX := NSec}
    push   DS           {Сохраняем DS - он будет испорчен}
    push   BP           {Сохраняем BP}
    lds    BX,Buf       {DS:BX - адрес буфера}
    mov    AL,Op        {AL := Op}
    shr    AX,1         {Переносим младший бит Op в CF}
    mov    AL,Disk      {AL := Disk}
    jc     @Write       {Перейти, если младший бит Op<>0}
    int    25H          {Читаем данные}
    jmp    @Go          {Обойти запись}
 @WRITE:
    int    26H  	{Записываем данные}
 @GO:
    pop    DX         		{Извлекаем флаги из стека}
    pop    BP         		{Восстанавливаем BP}
    pop    DS         		{Восстанавливаем DS}
    mov    BX,1       		{BX := True}
    jc     @Exit      		{Перейти, если была ошибка}
    mov    BX,0       		{BX := False}
    xor    AX,AX      		{Обнуляем код ошибки}
 @EXIT:
    mov    Disk_Error,BL  	{Флаг ошибки взять из BX}
    mov    Disk_Status,AX 	{Код ошибки вять из AX}
  end
end;  {ReadWriteSector}
{------------------------}
Procedure ReadSector(Disk: Byte; Sec: LongInt; NSec: Word; var Buf);
  {Читает сектор (секторы) на указанном диске}
var
  DI: TDisk;
begin
  GetDiskInfo(Disk,DI);
  if DI.TotSecs > $FFFF then              {Диск большой емкости?}
    ReadWriteSector(Disk,Sec,Nsec,Buf,2)  {-Да: операция 2}
  else
    ReadWriteSector(Disk,Sec,Nsec,Buf,0)  {-Нет: операция 0}
end;  {ReadSector}
{------------------------}
Procedure SetAbsSector(Disk,Head: Byte; CSec: Word; var Buf);
  {Записывает абсолютный дисковый сектор с помощью прерывания $13}
begin
  with Reg do
    begin
      ah := 3;       		{Операция записи}
      dl := Disk;    		{Номер привода}
      dh := Head;    		{Номер головки}
      cx := CSec;    		{Цилиндр/сектор}
      al := 1;       		{Читаем один сектор}
      es := seg(Buf);
      bx := ofs(Buf);
      Intr($13,Reg);
      Output
    end
end;  {SetAbsSector}
{-----------------------}
Procedure SetDefaultDrv(Disk: Byte);
  {Устанавливает диск по умолчанию}
begin
  if Disk <= GetMaxDrv then with Reg do
    begin
      AH := $E;
      DL := Disk;
      MSDOS(Reg)
    end
end;
{-----------------------}
Procedure SetFATItem(Disk: Byte;Cluster,Item: Word);
  {Устанавливает содержимое ITEM в элемент CLUSTER таблицы FAT}
var
  DI : TDisk;
  k,j,n: Integer;
  Fat: record
    case Byte of
    0: (w: array [0..255] of Word);
    1: (b: array [0..512*3-1] of Byte);
  end;
begin
  GetDiskInfo(Disk,DI);
  if not Disk_Error then with DI do
    begin
      if (Cluster <= MaxClus) and(Cluster >= 2) then
        begin
          if FAT16 then

            begin
              k := Cluster div 256;  	{Нужный сектор FAT}
              j := Cluster mod 256;  	{Смещение в секторе}
              n := 1
            end
          else
            begin
              k := Cluster div 1024;  	{Нужная тройка секторов FAT}
              j := (3*Cluster) shr 1-k*1536;
              n := 3
            end;
          ReadSector(Disk,FATLock+k*n,n,Fat);
          if not Disk_Error then
            begin
              if FAT16 then
                Fat.w[j] := Item
              else
                begin
                  if odd(Cluster) then
                    Item := Item shl 4 +Fat.b[j] and $F
                  else
                    Item := Item+(Fat.b[j+1] and$F0) shl 12;
                  Fat.b[j] := Lo(Item);
                  Fat.b[j+1] := Hi(Item)
                end;
              if not FAT16 then
                begin     	{Проверяем "хвост" FAT}
                  k := k*n;    	{k - смещение сектора}
                  while k+n > FatSize do dec(n)
                end;
              inc(FATLock,k);  {FATLock - номер сектора в FAT}
        {Записываем изменение в FatCnt копий FAT}
              for k := 0 to pred(FatCnt) do
                WriteSector(Disk,FATLock+k*FatSize,n,Fat)
            end
        end
    end
end;  {SetFATItem}
{----------------------}
Procedure SetMasterBoot(var Buf);
  {Записывает в главный загрузочный сектор содержимое Buf}
begin
  with Reg do
    begin
      ah := 3;         		{Операция записи}
      al := 1;         		{Кол-во секторов}
      dl := $80;       		{1-й жесткий диск}
      dh := 0;         		{Головка 0}
      cx := 1;         		{1-й сектор 0-й дорожки}
      es := seg(Buf);
      bx := ofs(Buf);
      Intr($13, Reg);
      Disk_Error := (Flags and FCarry <> 0);
      if Disk_Error then
        Disk_Status := ah
      else
        Disk_Status := 0
    end
end;  {SetMasterBoot}
{------------------------}
Procedure UnpackCylSec(CSec: Word; var Cyl,Sec: Word);
 {Декодирует цилиндр и сектор для прерывания $13}
begin
  Cyl := (CSec and 192) shl 2+CSec shr 8;
  Sec := CSec and 63
end;  {RecodeCylSec}
{----------------------}
Procedure WriteSector(Disk: Byte; Sec: LongInt; NSec: Word; var Buf);
  {Записывает сектор (секторы) на указанный диск}
var
  DI: TDisk;
begin
  GetDiskInfo(Disk,DI);
  if DI.TotSecs > $FFFF then
    ReadWriteSector(Disk,Sec,Nsec,Buf,3)
  else
    ReadWriteSector(Disk,Sec,Nsec,Buf,1);
end;  {ReadSector}
{===========}  end. {Unit F_Disk}  {===========}
