{+--------------------------------------------+
 | �ਬ�� �ᯮ�짮����� �।�� ����� F_Text |
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
{�뢮��� ⠡���� ᥣ���⮢
 ��� ����㯭�� ��࠭��}
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
  WriteLn('�������� ���� �������࠭��:');
  WriteLn('��࠭��  �������');
  for k := 0 to 7 do
    WriteLn(k,m[k]:16);


{����訢��� ����� ��࠭���}
  Write('������ ����� ��࠭���: ');
  ReadLn(Page);


{��⮢���� � ࠡ��: ���塞 ��ࠬ����
 �����०���, ��७����砥� �⠭����� �뢮�
 � ��⨢����㥬 ��࠭���}
  InitText;
  PageWriteOn;
  SetActivePage(Page);
  Page := GetActivePage;  {�஢��塞��⨢��� ��࠭���}


{��⠭�������� �⠭����� 梥� � ��頥� ��࠭}
  Colors(LightGray,Black);
  ClrScr;


{������塞 ��࠭ 䮭��묨 ᮮ�饭�ﬨ}
  for k := 1 to 24 do
    for j := 1 to 8 do
      Write('��ப� ',k:2,' ');
  {�������� ��᫥���� ��ப�}
  for j := 1 to 7 do
    Write('��ப� 25 ');


{���������� ���ﭨ� ��࠭�}
  Size := PageSaveSize;
  GetMem(P,Size);
  SavePage(Page,P^);


{������� ���� � 業�� ��࠭�}
  Colors(Yellow,Blue);      {������ 梥�}
  CursorOff;                {���ࠥ� �����}
  SetWindow(20,10,60,14,DoubleBorder,'',True,True,True);


{�뢮��� � ��� ᮮ�饭��}
  WriteLn('��࠭�� N ':25,Page);
  WriteLn('    ���頩� ���� �����蠬� �����');
  Write('ESC - ��室':25);


{���������� ��ਡ��� ����}
  OldAtt := Pages[Page].Attrib;


{���� ��६�饭�� ���� �����蠬� ����� �
 Home,End,PgUp,PgDn. �த�������� �� �� ���,
 ���� �� �㤥� ����� ������ Esc}
  repeat
    while not KeyPressed do
      begin  {���塞 ��ਡ��� ���� � ��������
              ������ �� ������}
        for k := 1 to 10 do
          if not KeyPressed then
            Delay(50);
        SetWindAttribute(Page,
           PackAttribute(Random(255),Random(8)))
      end;
    {����⠭�������� ���� ��ਡ���}
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


{�����蠥� ࠡ��� �ணࠬ��}
  PageWriteOff;         		{����⠭�������� �ࠩ���}
  CursorOn;             		{����砥� �����}
  SetActivePage(0);     		{���室��� �᭮���� ��࠭���}
  Window(1,1,80,25);        	{����� ��࠭}
  Colors(LightGray,Black);  	{�⠭����� 梥�}
  ClrScr;                   	{��頥� ��࠭}
  FreeMem(P,Size)
END. 


