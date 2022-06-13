 {Описание программы см. п.1.1.1 книги 2}
Uses DOS,F_Disk;
var
  Name: string;
  Text: array [1..512] of Char;
  k,j : Word;
  N   : Word;
  DI  : TDisk;
  Item: Dir_Type;
  Disk: Byte;
  Sec : Word;
begin
  GetListDisk(Disks);   		{Формируем список дисков}
  repeat
    Write('Введите имя файла '+
          '(или нажмите Enter для выхода): ');
    ReadLn(Name);
    if Name <> '' then
      begin
        Name := Fexpand(Name); 	        {Полное имя файла}
	Disk := GetDiskNumber(Name[1]);
        GetDiskInfo(Disk,DI);
        GetDirItem(Name,Item); 	        {Элемент каталога}
        if not Disk_Error then with Item do
          begin
            Sec := GetSector(Disk,FirstC); 	{Номер 1-го сектора файла}
            j := 0;                     {Количество прочитанных секторов}
            if not Disk_Error then
              repeat                    {Цикл печати файла}
                ReadSector(Disk,Sec,1,Text);
                if Size < 512 then
		 N := Size
                else N := 512;
                for k := 1 to N do
                  Write(Text[k]);
                dec(Size,N);            {Size - нераспечатанный остаток файла}
                inc(j);
                if j < DI.ClusSize then
                  inc(Sec)
                else
		  begin
                    j := 0;
                    FirstC := GetFATItem(Disk,FirstC);
                    Sec := GetSector(Disk,FirstC)
                  end
              until Size = 0
            else
              WriteLn('Ошибка чтения файла')
          end
        else
          WriteLn('Ошибка поиска файла')
      end
  until Name = '';
  FreeListDisk(Disks)                   {Удаляем связанный список}
end.
