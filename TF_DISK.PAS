 {���ᠭ�� �ணࠬ�� �. �.1.1.1 ����� 2}
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
  GetListDisk(Disks);   		{��ନ�㥬 ᯨ᮪ ��᪮�}
  repeat
    Write('������ ��� 䠩�� '+
          '(��� ������ Enter ��� ��室�): ');
    ReadLn(Name);
    if Name <> '' then
      begin
        Name := Fexpand(Name); 	        {������ ��� 䠩��}
	Disk := GetDiskNumber(Name[1]);
        GetDiskInfo(Disk,DI);
        GetDirItem(Name,Item); 	        {������� ��⠫���}
        if not Disk_Error then with Item do
          begin
            Sec := GetSector(Disk,FirstC); 	{����� 1-�� ᥪ�� 䠩��}
            j := 0;                     {������⢮ ���⠭��� ᥪ�஢}
            if not Disk_Error then
              repeat                    {���� ���� 䠩��}
                ReadSector(Disk,Sec,1,Text);
                if Size < 512 then
		 N := Size
                else N := 512;
                for k := 1 to N do
                  Write(Text[k]);
                dec(Size,N);            {Size - ���ᯥ�⠭�� ���⮪ 䠩��}
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
              WriteLn('�訡�� �⥭�� 䠩��')
          end
        else
          WriteLn('�訡�� ���᪠ 䠩��')
      end
  until Name = '';
  FreeListDisk(Disks)                   {����塞 �易��� ᯨ᮪}
end.
