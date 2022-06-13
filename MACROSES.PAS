{$A+,B-,D+,E+,F-,G-,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+}
{$M 16384,0,0}

(*
   514
   даны 2 файла   склад  и продажа из записей товар-число
   найти остаток на складе

     ADD==================EDITM LISTMS
*)
Uses Crt,Dos;
Const
 MaxCommand   =  22;
 Ext          =  '.SDB';
 maxmstr      =  20;
 maxm         =  20;
 MaxMacros    :byte  =  0;
Type
 Macros = array [1..maxm,1..maxmstr]   of string[80];
 NameMac= array [1..10]      of string[80];
 ARR    = array [1..MaxCommand] of string[80];
  rec     =  record
              tovar  :  string;
              kol    :  integer;
             end;

  filer   =  file of rec;
  Farr    =  array[1..24] of PathStr;

 Var
  fv,fd        :  filer;
  r1,r2        :  rec;
  s,ps         :  string;
  i,j          :  integer;
  kol1,kol2    :  integer;
  r            :  rec;
  s1           :  integer;
  d            :  string;
  ch           :  char;
  f            :  boolean;
  d1           :  integer;
  ff           :  filer;
  MF           :  Farr;
  MN           :  Byte;
  Mac          :  Macros;
  sss          :  namemac;
Const
 (*common commands*)
 cCREATE  = 1 ;        (* filename *)
 cDELETE  = 2 ;        (* filename *)
 cWORK    = 3 ;        (* filename_sklad filename_prodazga*)
 cEXIT    = 4 ;        (* not *)
 cADD     = 5 ;        (* filename *)
 cSORT    = 6 ;        (* filename  priznak(1/2)*)
 cPRINT   = 7 ;        (* filename *)
 cFIND    = 8 ;        (* filename tovar *)
 cADDP    = 9 ;        (* filename position *)
 cDELP    = 10;        (* filename position *)
 cHELP    = 11;        (* command*)
 cCLS     = 12;        (* not *)
 cHELPC   = 13;
 cSORTTO  = 14;
 cDIR     = 15;
 cCHDIR   = 16;
 cGetDir  = 17;
 cDef     = 18;
 cDelay   = 19;
 cListm   = 20;
 cLOADM   = 21;
 cSAVEM   = 22;
 cWrong   = 0 ;

 CURS    = '>';

 HelpArray:Arr=(
  'CREATE  [filename] ,Создать файл',
  'DELETE  [filename] ,Удалить файл с диска',
  'WORK    [filename_sklad, filename_prodazga], Работать',
  'EXIT    ,Выход из программы',
  'ADD     [filename], Добавить запись в конец файла',
  'SORT    [filename  {PRODUCT/NUMBER}] , Сортировать по признаку',
  'LIST    [filename], Вывести на экран все записи',
  'FIND    [filename, product] , Поиск в файле по товару',
  'ADDP    [filename, position] , Добавить запись в заданную позицию файла',
  'DELP    [filename, position] , Удалить запись в заданной позиции файла',
  'HELP    [command],  Помощь по произвольной команде системы',
  'CLS     , Очистить экран',
  'HELPC   , Общая помощь',
  'SORTTO  [filename1 filename2 {PRODUCT/NUMBER}] , Сортировка в файл ',
  'DIR     , Вывести на экран файлы текущего каталога ',
  'CHDIR   [new_directory] , Сменить текущий каталог',
  'GETDIR  , Вывести на экран текущий каталог ',
  'DEF     [name_macros] определить макрос, конец макроса  END',
  'DELAY    пауза ',
  'LISTM   [macros]    список команд макроса',
  'LOADM   [macros]    load macros from file',
  'SAVEM   [macros]    save macros as file '
  );

 Function UpStr(s:string):string;
  var
     k : Integer;
  begin
   for k := 1 to Length(s) do
    if s[k] in ['a'..'z'] then
     s[k] := chr(ord('A')+ord(s[k])-ord('a'))
    else if s[k] in ['а'..'п'] then
     s[k] := chr(ord('А')+ord(s[k])-ord('а'))
    else if s[k] in ['р'..'я'] then
     s[k] := chr(ord('Р')+ord(s[k])-ord('р'));
   UpStr := s
  end;

 Function GetCommand(s:string):Byte;
  begin
   if Pos(' ',s)<>0 then Delete(s,Pos(' ',s),255);
   if UpStr(s)= 'CREATE'then begin GetCommand := cCreate; Exit end;
   if UpStr(s)= 'DELETE'then begin GetCommand := cDelete; Exit end;
   if UpStr(s)= 'WORK'  then begin GetCommand := cWork;   Exit end;
   if UpStr(s)= 'EXIT'  then begin GetCommand := cExit;   Exit end;
   if UpStr(s)= 'ADD'   then begin GetCommand := cAdd;    Exit end;
   if UpStr(s)= 'SORT'  then begin GetCommand := cSort;   Exit end;
   if UpStr(s)= 'LIST'  then begin GetCommand := cPrint;  Exit end;
   if UpStr(s)= 'FIND'  then begin GetCommand := cFind;   Exit end;
   if UpStr(s)= 'ADDP'  then begin GetCommand := cAddP;   Exit end;
   if UpStr(s)= 'DELP'  then begin GetCommand := cDelP;   Exit end;
   if UpStr(s)= 'HELP'  then begin GetCommand := cHelp;   Exit end;
   if UpStr(s)= 'CLS'   then begin GetCommand := cCls;    Exit end;
   if UpStr(s)= 'HELPC' then begin GetCommand := cHelpC;  Exit end;
   if UpStr(s)= 'SORTTO'then begin GetCommand := cSortTo; Exit end;
   if UpStr(s)= 'DIR'   then begin GetCommand := cDir;    Exit end;
   if UpStr(s)= 'CHDIR' then begin GetCommand := cCHDir;  Exit end;
   if UpStr(s)= 'GETDIR'then begin GetCommand := cGetDir; Exit end;
   if UpStr(s)= 'DEF'   then begin GetCommand := cDef;    Exit end;
   if UpStr(s)= 'DELAY' then begin GetCommand := cDelay;  Exit end;
   if UpStr(s)= 'LISTM' then begin GetCommand := cLISTM;  Exit end;
   if UpStr(s)= 'LOADM' then begin GetCommand := cLOADM;  Exit end;
   if UpStr(s)= 'SAVEM' then begin GetCommand := cSAVEM;  Exit end;
   GetCommand := cWrong
  end;

 Function Trim(s:string):string;
    var
    b : byte absolute s;
    i : byte;
   begin
    if s='' then begin Trim:='';Exit end;
    While s[1] = ' ' do delete(s,1,1);
    While s[b] = ' ' do delete(s,b,1);
    For i:=2 to b do
     While (s[i-1] = ' ')AND(s[i] = ' ') do Delete(s,i,1);
    Trim:=s
   end;

 Function GetFName(st:string):string;
  begin
   if Pos('.',st)<>0 then GetFName:=UpStr(st)
                     else GetFName:=UpStr(st)+Ext
  end;

 Function GetParameters(st:string;var s1:string;var s2:string):byte;
   var
    n   :  byte;
  begin
   St:=trim(st);
   if pos(' ',st)=0 then
    begin
     GetParameters:=0;
     Exit
    end;
   Delete(St,1,Pos(' ',st));
   St:=trim(st);
   n:=0;
   if pos(' ',st)<>0 then begin
                           s1:=copy(st,1,Pos(' ',st));
                           inc(n);
                           Delete(st,1,Pos(' ',st))
                          end
                     else begin
                           s1:=st;
                           s2:='';
                           ps:='';
                           GetParameters:=1;
                           exit
                          end;
   if pos(' ',st)<>0 then begin
                           s2:=copy(st,1,Pos(' ',st));
                           inc(n);
                           Delete(st,1,Pos(' ',st))
                          end
                     else begin
                           s2:=st;
                           ps:='';
                           GetParameters:=2;
                           exit
                          end;
   if pos(' ',st)<>0 then begin
                           GetParameters:=4;
                           Exit
                          end
                     else begin
                           ps:=st;
                           GetParameters:=2;
                           exit
                          end
  end;

 Function Check(s:string):boolean;
  var
    f   :    file;
    d   :    boolean;
  begin
   {$i-}
   Assign(f,s);
   Reset(f);
   {$i+}
   d:=IOResult=0;
   if d then Close(f);
   Check:=d
  end;
 procedure delay;
  begin
   Writeln;
   WriteLn('Нажмите любую клавишу...');
   while keypressed do ch:=readkey;
   repeat until keypressed         ;
   while keypressed do ch:=readkey;
   WriteLn
  end;

 Procedure ShowMessage;
  begin
   WriteLn('Нельзя открыть файл...')
  end;

 Procedure CreateFile(st:string);
  var
   s,s2:string;
    begin
     WriteLn;
     Case GetParameters(st,s,s2) of
      0: begin WriteLn('Должен быть один параметр');WriteLn;Exit end;
      2: begin WriteLn('Должен быть один параметр');WriteLn;Exit end;
     end;
     Assign(fv,GetFName(s));
     ReWrite(fv);
     r.tovar:='';
     WriteLn('конец ввода - 9999 ');
     Repeat
      WriteLn;
      Write('Product : ');
      Read(r.tovar);
      GotoXY(25,WhereY-1);
      if r.tovar<>'9999' then
       begin
        Write('Number  : ');
        ReadLn(r.kol);
        Write(fv,r)
       end;
     Until r.tovar='9999';
     Close(fv);
    WriteLn
   end;

 Procedure WorkFile(st:string);
   Var
    g   :  integer;
    s1,s2: string;
   begin
      WriteLn;
       Case GetParameters(st,s1,s2) of
        0,1: begin WriteLn('Должно быть два параметра ');WriteLn;Exit end;
      end;
      Writeln('Работаю с файлами  ',GetFName(s1),'  ',GetFName(s2));
      WriteLn;
      s1:=GetFName(s1);
      if NOT(Check(s1))  then ShowMessage
      else begin
      Assign(fv,s1);
      Reset(fv);
      s2:=GetFName(s2);
      if NOT(Check(s2))  then ShowMessage
      else begin
      Assign(fd,s2);
      Reset(fd);
      Seek(fv,0);
      g:=0;
     while not(eof(fv)) do
      begin
       Seek(fd,0);
       inc(g);
       Read(fv,R1);
       While NOT(EOF(fd)) do
        begin
         Read(FD,R2);
         if r1.tovar=r2.tovar
          then r1.kol:=r1.kol-r2.kol;
         Seek(fv,G-1);
         Write(fv,R1);
        end;
      end;
      Seek(fv,0);
      While NOT(EOF(FV)) do
      begin
       Read(fv,R);
       With r do
        if kol<0 then WriteLn('Product : ',tovar:14,'  Number  : ',kol,'  Caution')
                 else WriteLn('Product : ',tovar:14,'  Number  : ',kol)
      end
     end;
    Close(fd);
    Close(fv)
   end;
   WriteLn
  end;

 Procedure Help(c:byte);
  begin
   If c<>cWrong then WriteLn(HelpArray[c])
                else WriteLn('Нет такой команды!')
  end;

 Procedure GetHelp(st:string);
  var
   s1,s2:string;
 begin
  WriteLn;
  Case GetParameters(st,s1,s2) of
   0: WriteLn('Must be parameter');
   1: Help(GetCommand(s1));
   2: begin
       Help(GetCommand(s1));
       Help(GetCommand(s2))
      end;
  end;
  WriteLn
 end;

 Procedure GetHelpC;
  var
   i  :  byte;
 begin
  WriteLn;
  for i:=1 to MaxCommand do
   WriteLn(HelpArray[i]);
  WriteLn
 end;

 Procedure PrintAll(st:string);
  var
   s1,s2:string;
   begin
      WriteLn;
      Case GetParameters(st,s1,s2) of
       0: WriteLn('Must be parameter');
       2: WriteLn('Too many parameters...');
      else begin
      WriteLn('List file ',GetFName(s1));
      WriteLn;
      s1:=GetFName(s1);
      f:=Check(s1);
      if not(Check(s1))  then ShowMessage
      else begin
      Assign(fv,s1);
      ReSet(fv);
      kol1:=filesize(fv);
      for i:=1 to kol1 do
       begin
        read(fv,r);
        WriteLn('Product : ',r.tovar:14,'          Number  : ',r.kol)
       end;
      Close(fv);
     end
    end
   end;
   WriteLn
  end;

 Procedure FindFile(st:string);
   var
    s1,s2 : string;
    begin
      WriteLn;
      Case GetParameters(st,s1,s2) of
       0,1:Begin WriteLn('Must be 2 parameters');WriteLn;Exit end;
      else begin
      WriteLn('Searching for Record with Product=',s2,'  in file  ',GetFName(s1));
      WriteLn;
      S1:=GetFName(s1);
      f:=Check(s1);
     if not(Check(s1))  then ShowMessage
      else begin
      Assign(fv,s1);
      ReSet(fv);
      kol1:=filesize(fv);
      d:=s2;
      kol2:=0;
      Repeat
       read(fv,r);
       inc(kol2);
      Until (r.tovar = d) or (kol2 = kol1);
      if r.tovar<>d  then WriteLn('Product not found...') else
      WriteLn('Product : ',r.tovar, #10#13'Number  : ',r.kol);
      Close(fv)
    end
   end
  end;
  WriteLn
 end;

 Procedure DeleteFile(st:string);
  var
   s1,s2 : string;
   f     : filer;
  begin
      WriteLn;
      Case GetParameters(st,s1,s2) of
       0,2:begin WriteLn('Must be parameter');WriteLn;Exit end
      Else
       begin
        {$I-}
        s1:=GetFName(s1);
        Assign(f,s1);
        Erase(f);
        {$I+}
        If IOResult<>0 then WriteLn('Cannot delete file  ',s1)
                       else WriteLn('O`k file  ',GetFName(s1),'  was deleted!');
        WriteLn
       end
      end
  end;

 Procedure AddFile(st:string);
 var
  s1,s2 : string;
  f     : filer;
  begin
      WriteLn;
      Case GetParameters(st,s1,s2) of
       0,2:begin WriteLn('Must be parameter');WriteLn;Exit end
      Else
       begin
      WriteLn;
      WriteLn('Adding record to the end of file ',GetFName(s1));
      WriteLn;
      s1:=GetFName(s1);
      if not(Check(s1))  then ShowMessage
      else begin
      Assign(f,s1);
      Reset(f);
      Seek(f,filesize(f));
      r.tovar:='';
      WriteLn('End of work -9999 ');
     Repeat
      Write('Product : ');
      ReadLn(r.tovar);
      if r.tovar<>'9999' then
       begin
        Write('Number  : ');
        ReadLn(r.kol);
        Write(f,r)
       end;
     Until r.tovar='9999';
      Close(f);
    end
   end
  end;
  WriteLn
 end;

{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
 Function SearchMin(var f:filer;g:boolean):integer;(*true first   false   last*)
  var
   r1,r2 : rec;
   sd    : integer;
  begin
   Seek(f,0);
   if not(eof(f)) then read(f,R1);
   while not(eof(f)) do
    begin
     Read(f,r2);
     if (g and (r2.tovar<r1.tovar)) then r1:=r2;
     if ((not(g)) and (r2.kol<r1.kol)) then r1:=r2;
    end;
   Seek(f,0);
   sd:=-1;
   if not(eof(f)) then
    Repeat
     Read(f,r2);
     inc(sd);
    Until (g and (r2.tovar=r1.tovar)) or ((not(g)) and (r2.kol=r1.kol));
   SearchMin:=sd
  end;

 Procedure DelItem(var f:filer;d:integer);
   var
   s  :  integer;
   r  :  rec;
  begin
   s:=filesize(f);
   dec(s);
   Seek(f,s);
   Read(f,r);
   Seek(f,d);
   Write(f,r);
   Seek(f,S);
   Truncate(f)
  end;

  Procedure SortFile(st:string);
   var
    fr,cod   :   integer;
    d1,d2    :   integer;
    g        :   boolean;
    s1,s2    :   string;
    fv,ff    :   filer;
     begin
      WriteLn;
      Case GetParameters(st,s1,s2) of
       0,1:begin WriteLn('Must be 2 parameters');WriteLn;Exit end
      Else
       begin
      WriteLn;
      S1:=GetFName(s1);
      if not(Check(s1))  then ShowMessage
      else begin
      Assign(fv,s1);
      ReSet(fv);
      Assign(ff,'########.###');
      ReWrite(ff);
      s2:=UpStr(s2);
      if (s2<>'PRODUCT') and (s2<>'NUMBER') then
       begin
        WriteLn('Second parameter must be "PRODUCT" or "NUMBER"');
        WriteLn;
        Exit
       end;
      If s2='PRODUCT' then g:=true
                      else g:=false;
      Write('Sorting records in file  ',GetFName(s1));
      if g then WriteLn('  on PRODUCT')
           Else WriteLn('  on NUMBER');
      fr:=filesize(FV);
      for i:=1 to fr do
       begin
        d1:=SearchMin(fv,g);
        Seek(fv,d1);
        Read(fv,r1);
        Write(ff,r1);
        DelItem(fv,d1);
       end;
      Close(fv);
      Close(ff);
      Erase(fv);
      Rename(ff,s1);
      WriteLn('Ready...');
     end
    end
   end;
   WriteLn
  end;
{============================================================================}

 Procedure AddInPosition(st:string);
   var
    s1,s2  : string;
    fv,ff  : filer;
    cod    : integer;
   begin
      WriteLn;
      Case GetParameters(st,s1,s2) of
       0,1:begin WriteLn('Must be 2 parameters');WriteLn;Exit end
      Else
       begin
      WriteLn;
      s1:=GetFName(s1);
      if not(Check(s1))  then ShowMessage
      else
      begin
       Assign(fv,s1);
       ReSet(fv);
       Assign(ff,'########.###');
       ReWrite(ff);
       Val(s2,d1,cod);
       if (d1=0)or(cod<>0) then begin
                          WriteLn('Second parameter must be nomber <>0');
                          WriteLn;
                          Exit
                         end;
       WriteLn('Adding record in position  ',s2,'  file  ',GetFName(s1));
       Write('Product : ');ReadLn(r1.tovar);
       Write('Number  : ');ReadLn(r1.kol);
       kol1:=filesize(fv);
       i:=1;
       While i<>d1 do
        begin
         Read(fv,r);
         Write(ff,r);
         inc(i);
        end;
       Write(ff,r1);
       While i<=kol1 do
        begin
         Read(fv,r);
         Write(ff,r);
         inc(i)
       end;
       Close(fv);
       Close(ff);
       Erase(fv);
       Rename(ff,s1);
       WriteLn('Ready...');
      end
     end
   end
  end;

 Procedure DelInPosition(st:string);
  var
    s1,s2  : string;
    fv,ff  : filer;
    cod    : integer;
    a      : longint;
   begin
      WriteLn;
      Case GetParameters(st,s1,s2) of
       0,1:begin WriteLn('Must be 2 parameters');WriteLn;Exit end
      Else
       begin
      WriteLn;
     s1:=GetFName(s1);
     if not(Check(s1))  then ShowMessage
      else begin
     Assign(fv,s1);
     Reset(fv);
     a:=FileSize(fv);
     if d1>a then begin
                   Writeln('Only ',a,' records in file ',s1);
                   Close(fv);
                   WriteLn;
                   Exit
                  end;
     Seek(fv,filesize(fv)-1);
     read(fv,r1);
     Val(s2,d1,cod);

     if (d1=0)or(cod<>0) then begin
                               WriteLn('Second parameter must be nomber <>0');
                               WriteLn;
                               Exit
                              end;
     WriteLn('Deleting record in position  ',s2,'  file  ',GetFName(s1));
     Seek(fv,d1-1);
     Write(fv,r1);
     Seek(fv,filesize(fv)-1);
     Truncate(fv);
     Close(fv);
    end
   end
  end;
  WriteLn
 end;

 Procedure SortTo(st:string);
  var
    s1,s2  : string;
    fv,ff  : filer;
    cod,i  : integer;

 begin
     WriteLn;
     cod:=GetParameters(st,s1,s2);
     if (ps='')or(cod in [1,0]) then
     begin
      WriteLn('Must be 3 parameters');
      WriteLn;
      Exit
     end
     else
      begin
      WriteLn;
      S1:=GetFName(s1);
      if not(Check(s1)) then ShowMessage
       else
        begin
       Assign(fv,s1);
       Reset(fv);
       S2:=GetFName(s2);
       Assign(ff,s2);
       Rewrite(ff);
       While not(eof(fv)) do
        begin
         Read(fv,r);
         Write(ff,r)
        end;
       Close(fv);
       Close(ff);
       i:=1;
       While st[i]<>' ' do inc(i);
       Delete(st,i,1);
       While st[i]<>' ' do Delete(st,i,1);
       SortFile(st)
   end
  end
 end;

 Procedure GetFiles(st:string);
  var
   ND   :  SearchRec;
   i    :  byte;
   d    :  integer;
   s,ss :  string;
  begin
   {$I-}
   i:=1;
   MN:=0;
   s:='*'+Ext;
   FindFirst(s,Archive,ND);
   d:=DosError;
   If d=0 then begin MF[i]:=ND.Name;inc(MN) end
          else begin WriteLn;WriteLn('No files in current directory...');WriteLn;Exit end;
   While d=0 do
    begin
     FindNext(ND);
     d:=DosError;
     if d=0 then begin
                  inc(mn);
                  inc(i);
                  MF[i]:=ND.Name
                 end
    end;
   WriteLn;
   GetDir(0,ss);
   WriteLn('Current directory:  ',ss);
   WriteLn;
   For i:=1 to MN do WriteLn(MF[i]);
   WriteLn
  end;

 Procedure ChangeDirectory(st:string);
  var
   cod  :  byte;
   s1,s2:  string;
  begin
   WriteLn;
    cod:=GetParameters(st,s1,s2);
    if(cod in [2,0]) then
     begin
      WriteLn('Must be parameter');
      WriteLn;
      Exit
     end
     else
      begin
      WriteLn;
      {$I-}
      ChDir(s1);
      {$I+}
      if DosError<>0 then WriteLn('Error in changing directory');
     WriteLn
   end
  end;

 Procedure GetDirectory;
  var
   cod    :   byte;
   s1     :   string;

  begin
   WriteLn;
   {$I-}
   GetDir(0,s1);
   {$I+}
   WriteLn('Current disk and directory : ',s1);
   WriteLn
  end;

 Procedure Define(st:string);
  var
   cod  :  byte;
   s1,s2:  string;
   t    :  boolean;
   j,i  :  byte;
  begin
   WriteLn;
    if maxmacros=maxm then begin
     writeln('Нет места для макроса');
     exit
    end;
    cod:=GetParameters(st,s1,s2);
    if(cod in [2,0]) then
     begin
      WriteLn('Must be 1 parameter');
      WriteLn;
      Exit
     end
     else
      begin
   st:=UpStr(s1);
       i:=1;
       t:=true;
       while i<=maxmacros do
        begin
         if sss[i]=st then t:=false{search that macros exist};
         inc(i)
        end;
       if not t then
        begin
         WriteLn('Макрос уже существует...');
         WriteLn;
         Exit
        end
       else
        begin
         i:=maxmacros+1;
         inc(maxmacros);
         sss[i]:=st;
         j:=1;
         repeat
          writeln;
          write('Ready >');
          readln(mac[i,j]);
          mac[i,j]:=trim(mac[i,j]);
          if mac[i,j]<>'' then inc(j);
         until (upstr(mac[i,j-1])='END') or (j=maxmstr+1);

      end
  end
 end;

 function searchmac(st:string):byte;
  var
   i:byte;
  begin
   if pos(' ',st)<>0 then delete(st,pos(' ',st),255);
   searchmac:=0;
   for i:=1 to maxmacros do
    if st=sss[i] then
     begin
      searchmac:=i;
      exit
     end
  end;

  procedure loadm(st:string);
   var
    ss   :  string;
    fv   :  text;
    i,j  :  byte;
    cod  :  integer;
   begin
   WriteLn;
   write('insert macros filename : ');readln(ss);
   assign(fv,ss);{$I-}reset(fv);{$I+}
   if ioresult<>0 then
    begin
     writeLn('Error opening file ',ss);
     writeLn;
     exit
    end;
    readln(fv,ss);
    val(ss,maxmacros,cod);
    if cod=0 then writeln('ok') else writeln('bad file');
   for i:=1 to maxm do
    for j:=1 to maxmstr do
     readln(fv,mac[i,j]);
   close(fv);
   end;

  procedure savem(st:string);
   var
   cod  :  byte;
   fv   :  text;
   ss   :  string;
   s1,s2:  string;
   t    :  boolean;
   j,i  :  byte;
  begin
   WriteLn;
   write('insert macros filename : ');readln(ss);
   assign(fv,ss);{$I-}rewrite(fv);{$I+}
   if ioresult<>0 then
    begin
     writeLn('Error creating file ',ss);
     writeLn;
     exit
    end;
    str(maxmacros,ss);
    writeln(fv,ss);
   for i:=1 to maxm do
    for j:=1 to maxmstr do
     writeln(fv,upstr(mac[i,j]));
   close(fv);
  end;

 procedure listm(st:string);
  var
   cod  :  byte;
   s1,s2:  string;
   t    :  boolean;
   j,i  :  byte;
  begin
   WriteLn;
    if maxmacros=0 then begin
     Writeln;
     writeln('Нет определённых макросов');
     writeln;
     exit
    end;
    cod:=GetParameters(st,s1,s2);
    if(cod in [2,0]) then
     begin
      WriteLn('Must be 1 parameter');
      WriteLn;
      Exit
     end
     else
      begin
       i:=searchmac(s1);
       if i=0 then begin
        Writeln;
        writeln('Нет макроса  ',s1);
        writeln;
        exit
       end;
       j:=1;
      while (upstr(mac[i,j])<>'END') and (j<=maxmstr) do
       begin
        writeln(mac[i,j]);
        inc(j);
       end;
     writeln('end');
     writeln
   end
 end;

 Procedure Handle;
  var
   st    : string;
   S1,S2 : string;
   bd    : byte;
   st2   : string;
   fdl,j : byte;

  begin
   Write(curs);
   ReadLn(st);
   st:=Trim(st);
   st:=upstr(st);
   st2:=st;
   fdl:=searchmac(st2);
   if fdl=0 then
   Case GetCommand(st) of
    cCREATE  : CreateFile(st);
    cDELETE  : DeleteFile(st);
    cDIR     : GetFiles(st);
    cWORK    : WorkFile(st);
    cEXIT    : Halt;
    cADD     : AddFile(st);
    cSORT    : SortFile(st);
    cPRINT   : PrintAll(st);
    cFIND    : FindFile(st);
    cADDP    : AddInPosition(st);
    cDELP    : DelInPosition(st);
    cHELP    : GetHelp(st);
    cHELPC   : GetHelpC;
    cCLS     : ClrScr;
    cSortTo  : SortTo(st);
    cCHDIR   : ChangeDirectory(st);
    cGetDir  : GetDirectory;
    cDef     : Define(st);
    cDelay   : delay;
    cLISTM   : listm(st);
    cLOADM   : LOADM(st);
    cSAVEM   : SAVEM(st);
    cWrong   : if st<>'' then begin
                               WriteLn;
                               WriteLn('Uncorrect command : ',st);
                               WriteLn
                              end;
   end
  else
   begin
    j:=1;
    while (upstr(mac[fdl,j])<>'END') and (j<=maxmstr) do
    begin
    Case GetCommand(mac[fdl,j]) of
    cCREATE  : CreateFile(mac[fdl,j]);
    cDELETE  : DeleteFile(mac[fdl,j]);
    cDIR     : GetFiles(mac[fdl,j]);
    cWORK    : WorkFile(mac[fdl,j]);
    cEXIT    : Halt;
    cADD     : AddFile(mac[fdl,j]);
    cSORT    : SortFile(mac[fdl,j]);
    cPRINT   : PrintAll(mac[fdl,j]);
    cFIND    : FindFile(mac[fdl,j]);
    cADDP    : AddInPosition(mac[fdl,j]);
    cDELP    : DelInPosition(mac[fdl,j]);
    cHELP    : GetHelp(mac[fdl,j]);
    cHELPC   : GetHelpC;
    cCLS     : ClrScr;
    cSortTo  : SortTo(mac[fdl,j]);
    cCHDIR   : ChangeDirectory(mac[fdl,j]);
    cGetDir  : GetDirectory;
    cDELAY   : delay;
    cLOADM   : LOADM(st);
    cSAVEM   : SAVEM(st);
    cWrong   : if mac[fdl,j]<>'' then begin
                               WriteLn;
                               WriteLn('Uncorrect command : ',mac[fdl,j]);
                               WriteLn
                              end;
   end;
   inc(j)
   end
  end
 end;

 Procedure Intro;
  begin
   WriteLn(      ' This programm was written for work with records of type:');
   WriteLn(#13#10' Product : string  '                                      );
   WriteLn(      ' Number  : integer '                                      );
   WriteLn(#13#10' Enter HELPC for help about all commands of programm'     );
   WriteLn(      ' Now you can work with program...'                        );
   WriteLn
  end;


BEGIN
  HighVideo;
  ClrScr;
  Intro;
  While True do Handle
END.