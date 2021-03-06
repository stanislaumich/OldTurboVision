{===============} Unit F_EMS; {================}
{+---------------------------------------------+
 | ��� ����� ᮤ�ন� ��ꥪ�� � ����ணࠬ�� |
 |          ��� ࠡ��� � EMS-�������           |
 +---------------------------------------------+}
{$X+,N+,E+}
                  INTERFACE
{-----------------------------------------------}
type
{----------  ������ ��ꥪ� ����娨 -----------}
  PEMSArea =^TEMSArea;
  TEMSArea = Object
    Handle: Word;    		{���ਯ��}
    MaxPag: Word;    		{������⢮ ��࠭��}
    Size: LongInt;   		{����� �ᯮ��㥬�� �����}
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
{----------  �������� ���ᨢ � EMS  ----------}
  PEMSVector =^TEMSVector;
  TEMSVector = object(TEMSArea)
    ItemS : LongInt;     		{����� ������� ���ᨢ�}
    MinInd: LongInt;     		{��������� ������}
    MaxInd: LongInt;     		{���ᨬ���� ������}
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
{----------  ��㬥�� ���ᨢ � EMS  ----------}
  PEMSMatrix =^TEMSMatrix;
  TEMSMatrix = object(TEMSVector)
    MinInd1: LongInt;     	{��������� ������}
    MaxInd1: LongInt;     	{���ᨬ���� ������}
    MinInd2: LongInt;     	{��������� ������}
    MaxInd2: LongInt;     	{���ᨬ���� ������}
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
{----------  ��������� ���ᨢ � EMS  ---------}
  TIndexList = array [1..MaxInt div 2] of LongInt;
  TIndex = array [1..MaxInt div 6,1..3] of LongInt;
  PIndex =^TIndex;
  TIndexBond = array [1..MaxInt div 4,1..2] of LongInt;
  PEMSArray =^TEMSArray;
  TEMSArray = object(TEMSVector)
    NIndex: Word;     		{������⢮ ����७��}
    Index : PIndex;
    Constructor Init(ASize: LongInt; NInd: Word; var Ind);
    Constructor Load(var F: File);
    Destructor Done; Virtual;
    Procedure Store(var F: File); Virtual;
    Function GetVecIndex(var Ind): LongInt;
    Procedure SetItem(var Source,Ind);
    Procedure GetItem(var Dest,Ind);
  end;
{---- ������ 䠩�� ��᫥����⥫쭮�� ����㯠 ----}
  PEMSType =^TEMSType;
  TEMSType = object(TEMSArea)
    Pos: LongInt;   	{������ ������ �� ��砫� �����}
    Constructor Init(ASize: Longint);
    Constructor Load(var F: File);
    Procedure Store(var F: File); Virtual;
    Procedure SetItem(var Source; Sz: LongInt);
    Procedure GetItem(var Dest; Sz: LongInt);
  end;
{--------  ������ ⥪�⮢��� 䠩��  ---------}
  PEMSText =^TEMSText;
  TEMSText = object(TEMSType)
    Procedure SetItem(S: String);
    Function GetItem: String;
  end;
{--------- ����� ��࠭� � EMS-�����  ---------}
  PEMSScreen =^TEMSScreen;
  TEMSScreen = object(TEMSArea)
    Mode: Byte;   		{��� ०���}
    Constructor Init;
    Constructor Load(var F: File);
    Procedure Store(var F: File); Virtual;
    Procedure PutScreen;
    Procedure GetScreen;
  end;

var
  EMSStatus: Byte;  {����� ��᫥���� ����樨}

Function IsEMS: Boolean;
  {�����頥� TRUE, �᫨ � �� ������� EMS-������}

Function GetEMMVersion: String;
  {�����頥� ����� ���ᨨ EMM � �ଠ� 'X.X'}

Function EMSSeg: Word;
  {�����頥� ᥣ������ ���� ���� ���� EMS-�����}

Procedure GetEMSInfo(var AllPage, Pages: Word);
  {�����頥� ������ ������⢮ (AllPages)
   � ������⢮ ��������� (Pages) ��࠭��}

Procedure NewEMSHandle(var Handle: Word;Pages: Word);
  {���뢠�� ���� ���ਯ�� Handle
   � ��뢠�� � ��� Pages ��࠭�� EMS}

Procedure DisposeEMSHandle(var Handle: Word);
  {������ ���ਯ�� Handle � �᢮�������   �易���� � ��� ������}

Procedure MapEMSPage(Handle,Physic,Logic: Word);
  {������� ����, ��뢠� ��� Physic 䨧����� ��࠭��� �
	Logic �����᪮� ��࠭�楩 ���ਯ�� Handle}
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
  EMSVer : Word = 0;  {����� EMM; �ᯮ������
                   	��� 䫠� �஢�ન ������ EMS}
  EMSS   : Word = 0;  {������� ����}
  LPage=16*1024;      {����� ��࠭���}
{---------  ������ ��ꥪ� ����娨 ----------}
CONSTRUCTOR TEMSArea.Init(ASize: LongInt);
  {������� ��ꥪ� TEMSArea. ASize - ࠧ���
   �ॡ㥬�� EMS-����� � �����}
var
  All,Pag: Word;
begin
  if not IsEMS then
    EMSError($A5)    		{��� EMS}
  else
    begin
      EMSErrorFlag := False;
      Size := ASize;
      MaxPag := (Size+LPage-1) shr 14;
      GetEMSInfo(All,Pag);
      if MaxPag>Pag then
        EMSError($88)  		{��� �ॡ㥬�� ��࠭��}
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
  {��⠥� Sz ���� �� 䠩�� F �
   ��६����� Dest � ����஫���� १����}
var
  K: Word;
begin
  BlockRead(F,Dest,Sz,K);
  if K<>Sz then
    begin
      EMSError($A7);
      ReadFile := False  {�訡�� �� �⥭��}
    end
  else
    ReadFile := True     		{��� �訡��}
end;  {ReadFile}
{-------------------}
CONSTRUCTOR TEMSArea.Load(var F: File);
  {������� ��ꥪ� TEMSArea, ���뢠� ��� ��䠩�� F. ����
   ������ ���� ����� �� �⥭�� � ������ ������ � 1 ���� �
   ����樮��஢�� �� ����, ��� ࠭�� �� ��࠭�� ��ꥪ�
   TEMSArea ��楤�ன Store.}

var
  SRead,Rest: LongInt;
  S: String;
  All,k: Word;
  Stop: Boolean;
  P: Pointer;
begin
  if not IsEMS then
    EMSError($A5)    		{��� EMS}
  else
    begin
      {��⠥� ��������� ��ꥪ� -
       ��ப� RegHeadTEMSArea}
      EMSErrorFlag := False;
      Stop := False;    		{���� ��ଠ�쭮�� �⥭��}
      if not ReadFile(F,S,SizeOf(RegHeadTEMSArea))
        or (S<>RegHeadTEMSArea) then
        EMSError($A6) 		{�訡�� �⥭�� ��� ��ᮢ������� ���������}
      else            		{��⠥� ���� MaxPag � Size}
        begin
          if not(ReadFile(F,MaxPag,2) and
            ReadFile(F,Size,4)) then
              Exit;  		{�뫠 �訡�� �� �⥭�� �����}
          {�஢��塞 ����㯭�� ������}
          GetEMSInfo(All,k);
          if k<MaxPag then
            EMSError($88)   	{��� �㦭�� �����}
          else
            begin
              {��⠥��� ᮧ���� ���ਯ��}
              NewEMSHandle(Handle,MaxPag);
              if EMSStatus<>0 then
                EMSError(EMSStatus)
              else
                begin      	        {��⠥� ᮤ�ন��� �����}
                  Rest := Size; 	{�����⠭�� ���⮪}
                  P := Ptr(EMSSeg,0);  	{���� ��砫�
                                        䨧��᪮� ��࠭��� ����}
                  All := 0;  	        {��稭��� � 0-�	�����᪮� ��࠭���}
                  Stop := False;
                  while (Rest<>0) and not Stop do
                    begin
                      MapEMSPage(Handle,0,All);
                      EMSError(EMSStatus);
                      if EMSStatus<>0 then
                        Exit;   	{�訡�� ����஢����}
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
  {�����뢠�� Sz ���� �� ��६����� Source
   � 䠩� F � ����஫���� १����}
var
  K: Word;
begin
  BlockWrite(F,Source,Sz,K);
  if K<>Sz then
    begin
      EMSError($A8);
      WriteFile := False  {�訡�� �� �����}
    end
  else
    WriteFile := True     {��� �訡��}
end;  {TEMSArea.WriteFile}
{-------------------}
Procedure TEMSArea.Store(var F: File);
  {�����뢠�� ��ꥪ� TEMSArea � 䠩� F. ���� ������ ����
   ����� �� ������ � ������ ������ � 1 ���� � ����樮��஢��
   �� �㦭�� ���� (���筮 - � ����� 䠩��).}
var
  SRead,Rest: LongInt;
  S: String;
  All,k: Word;
  Stop: Boolean;
  P: Pointer;
begin
  if not IsEMS then
    EMSError($A5)    	{��� EMS}
  else
    begin
      {�����뢠�� ��������� ��ꥪ� - ��ப� RegHeadTEMSArea}
      EMSErrorFlag := False;
      S := RegHeadTEMSArea;
      if WriteFile(F,S,SizeOf(RegHeadTEMSArea))
      then begin  	              {�����뢠�� ���� MaxPag � Size}
          if WriteFile(F,MaxPag,2) and
            WriteFile(F,Size,4) then
          begin    	              {�����뢠�� ᮤ�ন��� �����}
            Rest := Size;             {������ᠭ�� ���⮪}
            P := Ptr(EMSSeg,0);       {���� ��砫� 䨧��᪮� ��࠭��� ����}
            All := 0;                 {��稭��� � 0-� �����᪮� ��࠭���}
            Stop := False;            {�ਧ��� �訡��}
            while (Rest<>0) and not Stop do
              begin
                MapEMSPage(Handle,0,All);
                EMSError(EMSStatus);
                if EMSStatus<>0 then
                  Exit;               {�訡�� ����஢����}
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
  {����⮦��� ��ꥪ� TEMSArea � �᢮������� �易���� � ��� ������}
begin
  if not IsEMS then
    EMSError($A5)    {��� EMS}
  else
    begin
      DisposeEMSHandle(Handle);
      EMSError(EMSStatus)
    end
end;  {TEMSArea.Done}
{-------------------}
Procedure TEMSArea.WriteEMS(var Source; Dest,Sz: LongInt);
  {�����뢠�� Sz ���� �� ��६����� Source � EMS,
   ��稭�� � ����樨 Dest ���� �� �� ��砫�}
var
  Rest,Pos,k: LongInt;
  Pag: Word;
  PD,PS: Pointer;
  PW: record S,O: Word end absolute PS;
  Stop: Boolean;
begin
{$IFNDEF NOTCHECK}
  if (Sz<0) or (Dest+Sz>Size) then
    EMSError($AA)    		{������ �� �࠭�楩 �����}
  else
{$endIF}
    begin
      Pag := Dest div LPage; 	        {�����᪠� ��࠭��}
      Pos := Dest mod LPage; 	        {���饭�� � ���}
      PS := @Source;      	        {�����⥫� � ���筨��}
      PD := ptr(EMSS,Pos);   	        {�����⥫� � EMS}
      Stop := False;   		        {���� �訡�� ����஢����}
      Rest := Sz;            	        {���⮪ �����}
      repeat    			{���� �� ��࠭�栬 EMS}
        MapEMSPage(Handle,0,Pag);	{�����㥬 ����}
        EMSError(EMSStatus);
        Stop := EMSStatus<>0;    	{�ਧ��� �訡��}
        if not Stop then
          begin
         {��।��塞 ࠧ��� Sz ��।���� �����:}
            if Rest>LPage-Pos then
              Sz := LPage-Pos
            else
              Sz := Rest;
            Move(PS^,PD^,Sz);    	{��७�ᨬ ����}
            Dec(Rest,Sz);     	        {�����蠥� ���⮪}
            Inc(Pag);        	        {�������� �����᪠� ���.}
            PD := ptr(EMSS,0);   	{�����⥫� -� �� ��砫�}
            Pos := 0;
            Inc(PW.O,Sz);  	        {���饭�� � ���筨��}
            {��ଠ���㥬 㪠��⥫� PS ���筨��:}
            PW.S := PW.S+(PW.O shr 4);
            PW.O := PW.O mod 16
          end
      until Stop or (Rest=0)
    end
end;  {TEMSArea.WriteEMS}
{-------------------}
Procedure TEMSArea.ReadEMS(Source: LongInt; var Dest; 					Sz: LongInt);
  {��⠥� Sz ���� �� EMS-�����, ��稭�� � ����
   Source �� �� ��砫�, � ��६����� Dest}
var
  Rest,Pos,k: LongInt;
  Pag: Word;
  PD,PS: Pointer;
  PW: record S,O: Word end absolute PD;
  Stop: Boolean;
begin
{$IFNDEF NOTCHECK}
  if (Sz<0) or (Source+Sz>Size) then
    EMSError($A9)    		{�⥭�� �� �࠭�楩 �����}
  else
{$endIF}
    begin
      Pag := Source div LPage; 	{�����᪠� ��࠭��}
      Pos := Source mod LPage; 	{���饭�� � ���}
      PD := @Dest;       	{�����⥫� � �ਥ�����}
      PS := ptr(EMSS,Pos);	{�����⥫� � ���筨��}
      Stop := False;   		{���� �訡�� ����஢����}
      Rest := Sz;              	{���⮪ �⥭��}
      repeat    			{���� �� ��࠭�栬 EMS}
        MapEMSPage(Handle,0,Pag);	{�����㥬 ����}
        EMSError(EMSStatus);
        Stop := EMSStatus<>0;    	{�ਧ��� �訡��}
        if not Stop then
          begin
         {��।��塞 ࠧ��� Sz ��।���� �����:}
            if Rest>LPage-Pos then
              Sz := LPage-Pos
            else
              Sz := Rest;
            Move(PS^,PD^,Sz);   {��७�ᨬ ����}
            Dec(Rest,Sz);     	{�����蠥� ���⮪}
            Inc(Pag);        	{�������� �����᪠� ���.}
            PS := ptr(EMSS,0);
            Pos := 0;
            Inc(PW.O,Sz);  	{���饭�� � �ਥ�����}
            {��ଠ���㥬 㪠��⥫� PD �ਥ�����:}
            PW.S := PW.S+(PW.O shr 4);
            PW.O := PW.O mod 16
          end
      until Stop or (Rest=0)
    end
end;  {TEMSArea.ReadEMS}
{-------------------}
Procedure TEMSArea.EMSError(NError: Byte);
  {����砥� �ࠢ����� �� �訡��� EMM ����� �믮������ 
   ��⮤�� ��ꥪ�. �� 㬮�砭�� �뢮��� ᮮ�饭�� � ����஬ NError.}
const
  Msg: array [$80..$AD] of String =(
'����७��� �訡�� EMM',
'���� EMS-�����',
'EMM ����� ��ࠡ�⪮� �।��饣� �����',
'������ ���ਯ�� ����',
'����襭� ����।������� � ������ ���ᨨ EMM �㭪��',
'��� ����㯭�� ���ਯ�஢ ����',
'�訡�� �� ��࠭���� ��� ����⠭������� ����',
'����� ��।������ �ॢ�蠥� ����� EMS-������',
'����� ��।������ �ॢ�蠥� �᫮ ����㯭�� ��࠭��',
'����⪠ ᮧ���� ���ਯ�� � �㫥�� ������⢮� ��࠭��',
'���ਯ�� �� �ᯮ������ ⠪�� �᫮� ��࠭��',
'����⪠ ����஢��� ����� 4 ��࠭��',
'��९������� ������ ��࠭���� �������饣� ���⥪��',
'����⪠ ����୮�� ��࠭���� �������饣� ���⥪��',
'����⪠ ����⠭������� ����࠭������ ���⥪��',
'�� ��।���� ��ࠬ��� ����㭪樨',
'��������� ⨯ ��ਡ�⮢',
'��� �����⭮� �����প� ��࠭塞�� ��࠭��',
'���筨� � �ਥ���� ���ଠ樨 '+
		'�����६���� ��室���� � EMS-�����',
'������ �ਥ����� ���ଠ樨 ᫨誮� ���',
'�⠭���⭠� ������ ���筮 ��४�뢠�� ���७��� ������',
'���誮� ����讥 ᬥ饭�� � ��६�頥��� �����',
'������ ��६�頥���� ����� ����� 1 �����',
'���筨� � �ਥ���� �易�� � ����� '+
  		'���ਯ�஬ � ���筮 ��४�뢠����',
'�������⨬� ⨯ ����� ���筨�� ��� �ਥ�����',
'������������ �訡��',
'��� �����⭮� �����প� ����ୠ⨢��� ��⠭���� ��࠭��',
'���௠�� �� �����⨬� ��⠭���� ����ୠ⨢��� ॣ���஢',
'�� �����ন������ ��⠭���� ����ୠ⨢��� ॣ���஢',
'���ࠢ��쭠� ��⠭���� ����ୠ⨢��� ॣ���஢',
'�����祭�� ������ ��אַ�� ����㯠 '+
  		'� ����� (����) �� �����ন������',
'�������� ���� �� �����ন������',
'���ਯ�� �� ����������',
'��������� ��� ���ਯ�� 㦥 �������',
'���筨� ��室�� �� �࠭��� 1 �����',
'����ন��� 㪠������ ������ ������ ࠧ��襭�',
'��� ����㯠 � 㪠������ �㭪樨',
'��� EMS-����� ��� �� ��⠭����� �ࠩ��� EMM.SYS',
'������ �ଠ� 䠩��',
'�訡�� �� �⥭�� ��ꥪ� �� 䠩��',
'�訡�� �� ����� ��ꥪ� � 䠩�',
'����⪠ �⥭�� �� �࠭�楩 ����㯭�� EMS-�����',
'����⪠ ����� �� �࠭�楩 ����㯭�� EMS-�����',
'������ �࠭��� �����ᮢ',
'������ ������� ����� �� ᮮ⢥����� ����� ��६�����',
'������� ०�� ࠡ��� ��ᯫ�� (��ꥪ� TEMSScreen)'
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
    WriteLn('�訡�� ����� ',NError)
end;  {TEMSArea.EMSError}
{----------  �������� ���ᨢ � EMS  ----------}
CONSTRUCTOR TEMSVector.Init(ASize,Min,Max: LongInt);
  {������� ��ꥪ� TEMSVector:
  ASize - ࠧ��� ������⮢ ���ᨢ� � �����;
  Min,Max - �࠭��� ������.}
var
  Sz: LongInt;
begin
  if Min>Max then
    begin
      EMSError($AB);     		{���ࠢ���� �࠭���}
      Exit
    end;
  Sz := ASize*(Max-Min+1); 	{��।��塞 ࠧ���}
  TEMSArea.Init(Sz);       	{������� TEMSArea}
  if not EMSErrorFlag then
    begin
      ItemS  := ASize;
      MinInd := Min;
      MaxInd := Max
    end
end;  {TEMSVector.Init}
{-------------------}
CONSTRUCTOR TEMSVector.Load(var F: File);
  {������� ��ꥪ� TEMSVector - �⠥� �� 䠩�������� ��ꥪ� 


   TEMSArea, ��⥬ ��������� ����� ItemS, MinInd, MaxInd.}
var
  S: String;
begin
  TEMSArea.Load(F);  {����㦠�� �� 䠩�������� ��ꥪ�}
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
  {���࠭�� ����� � 䠩�� - ᭠砫� ��࠭�⡠���� 
   ��ꥪ�, ��⮬ ��������� � ����ItemS, MinInd, MaxInd.}

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
{����頥� � EMS ������� � �����ᮬ Index �� ��६����� Source}
begin
{$IFNDEF NOTCHECK}
  if (Index>MaxInd) or (Index<MinInd) then
    EMSError($AB)   {���ࠢ���� ������}
  else
{$endIF}
    WriteEMS(Source,(Index-MinInd)*ItemS,ItemS)
end;  {TEMSVector.SetItem}
{-------------------}
Procedure TEMSVector.GetItem(var Dest; Index: LongInt);
 {��⠥� �� EMS ������� ���ᨢ� � �����ᮬ Index}
begin
{$IFNDEF NOTCHECK}
  if (Index>MaxInd) or (Index<MinInd) then
    EMSError($AB)   {���ࠢ���� ������}
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
    EMSError($AC)   {�訡�� � ����� �������}
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
    EMSError($AC)   {�訡�� � ����� �������}
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
    EMSError($AC)   {�訡�� � ����� �������}
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
    EMSError($AC)   {�訡�� � ����� �������}
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
    EMSError($AC)   {�訡�� � ����� �������}
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
    EMSError($AC)   {�訡�� � ����� �������}
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
    EMSError($AC)   {�訡�� � ����� �������}
  else
{$endIF}
    begin
      GetItem(X,Index);
      ByteItem := X
    end
end;  {TEMSVector.ByteItem}
{----------  ��㬥�� ���ᨢ � EMS  ----------}
CONSTRUCTOR TEMSMatrix.Init(ASize,Min1,Max1, 					Min2,Max2: LongInt);
  {������� ��ꥪ� TEMSMatrix:
  ASize - ࠧ��� ������⮢ ���ᨢ� � �����;
  Min,Max - �࠭��� ������.}
var
  Sz: LongInt;
begin
  if (Min1>Max1) or (Min2>Max2) then
    begin
      EMSError($AB);     {���ࠢ���� �࠭���}
      Exit
    end;
  {�८�ࠧ㥨 � ������୮�� ���ᨢ� �� 0}
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
  {������� ��ꥪ� TEMSMatrix - �⠥� �� 䠩��
   ��ꥪ� TEMSVector, ��⥬ ��������� �
   ���� MinInd1, MaxInd1, MinInd2, MaxInd2}
var
  S: String;
begin
  TEMSVector.Load(F);  {����㦠�� �� 䠩����ꥪ�-த�⥫�}
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
  {���࠭�� ����� � 䠩�� - ᭠砫� ��࠭��த�⥫�᪨� 
   ��ꥪ� TEMSVector, ��⮬��������� � ����  
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
  {�८�ࠧ�� ������� ��㬥୮�� ���ᨢ� 
				�������� ������୮�� �� 0}


begin
  EMSErrorFlag := False;
{$IFNDEF NOTCHECK}
  if (Ind1>MaxInd1) or (Ind1<MinInd1) or
     (Ind2>MaxInd2) or (Ind2<MinInd2) then
    EMSError($AB)   {���ࠢ���� ������}
  else
{$endIF}
    GetVecIndex := (Ind1-MinInd1)* 			(MaxInd2-MinInd2)+Ind2-MinInd2
end;  {TEMSMatrix.GetVecIndex}
{-------------------}
Procedure TEMSMatrix.SetItem(var Source; Ind1,Ind2: LongInt);
  {����頥� � EMS ������� � �����ᠬ�
  Ind1, Ind2 �� ��६����� Source}
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
  {��⠥� �� EMS ������� ���ᨢ�� �����ᠬ� Ind1,Ind2}
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
{---------  ��������� ���ᨢ � EMS  ----------}
CONSTRUCTOR TEMSArray.Init(ASize: LongInt; 				NInd: Word; var Ind);
  {������� ��ꥪ� TEMSArray: ᭠砫� ᮧ���⡠���� ��ꥪ� 
   TEMSVector � �����ᮬ �� 0,��⥬ �������� ���� NInde,    १�ࢨ��� 
�����줫� ���� Index  � �������� ���   �࠭�栬� �����ᮢ}

var
  Indx: TIndexBond absolute Ind;
  Sz: LongInt;
  k,j: Word;
begin
  {��।��塞 ��饥������⢮ Sz ������⮢ ���ᨢ�:}
  Sz := 0;
  EMSErrorFlag := False;
  for k := 1 to NInd do
    if Indx[k,1]>Indx[k,2] then
      EMSError($AB)
    else
      Sz := Sz+Indx[k,2]-Indx[k,1]+1;
  if not EMSErrorFlag then
    begin
      {������� ������ ��ꥪ� TEMSVector}
      TEMSVector.Init(ASize,0,Sz-1);
      if not EMSErrorFlag then
        begin
          GetMem(Index,NInd*12);
          {����塞 �����⥫� ������� ����७��
           � �ନ�㥬 ᯨ᮪ �࠭�� Index^}
          Index^[NInd,3] := 1;  {����訩 ������}
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
  {����⮦��� ��ꥪ� TEMSArray - 㭨�⮦��⡠���� ��ꥪ�
   TEMSVector � �᢮������⯠���� Index^}

begin
  TEMSVector.Done;
  FreeMem(Index,NIndex*12)
end;  {TEMSArray.Done}
{-------------------}
CONSTRUCTOR TEMSArray.Load(var F: File);
  {����㦠�� ��ꥪ� TEMSArray �� 䠩�� F -᭠砫� ����㦠��   ������ 
��ꥪ� TEMSVector,��⥬ �⠥� ��������� 
   RegHeadTEMSArray, ����NIndex � ᯨ᮪ �࠭�� �����ᮢ}

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
  {���࠭�� ��ꥪ� TEMSArray � 䠩�� - ��࠭��
 ������ ��ꥪ� TEMSVector, ��⥬ ����
 ���������, ���� NIndex � ᯨ᮪ �࠭�� �����ᮢ}
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
  {�� ⥪�騬 ���祭�� ᯨ᪠ �����ᮢ Ind
  ������ ������ ��� ��ꥪ� TEMSVector}
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
  {����頥� ���祭�� Source� ������� �������୮�� ���ᨢ�}
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
  {�����頥� � ��६����� Dest������� �������୮�� ���ᨢ�}
var
  N: LongInt;
begin
  N := GetVecIndex(Ind);
{$IFNDEF NOTCHECK}
  if not EMSErrorFlag then
{$endIF}
    TEMSVector.GetItem(Dest,N)
end;  {TEMSArray.GetItem}
{----  ������ 䠩�� ��᫥����⥫쭮�� ����㯠  ----}
CONSTRUCTOR TEMSType.Init(ASize: LongInt);
  {������� ��ꥪ� TEMSType: ᭠砫� ᮧ���� ������ ��ꥪ� 
   TEMSArea, ��⥬ ������ ���� Pos}

begin
  TEMSArea.Init(ASize);
  Pos := 0
end;  {TEMSType.Init}
{-------------------}
CONSTRUCTOR TEMSType.Load(var F: File);
  {���뢠�� ��ꥪ� TEMSType �� 䠩�� F}
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
  {�����뢠�� ��ꥪ� � 䠩�}
begin
  TEMSArea.Store(F);
  if not EMSErrorFlag and
    WriteFile(F,RegHeadTEMSType,SizeOf(RegHeadTEMSType))
    then
      WriteFile(F,Pos,4)
end;  {TEMSType.Store}
{------------------}
Procedure TEMSType.SetItem(var Source; Sz: LongInt);
  {�����뢠�� � TEMSType ��।��� �������}
begin
  WriteEMS(Source,Pos,Sz);
  if not EMSErrorFlag then
    inc(Pos,Sz)
end;  {TEMSType.}
{-------------------}
Procedure TEMSType.GetItem(var Dest; Sz: LongInt);
  {��⠥� �� TEMSType ��।��� �������}
begin
  ReadEMS(Pos,Dest,Sz);
  if not EMSErrorFlag then
    inc(Pos,Sz)
end;  {TEMSType.}

{-------  ������ ⥪�⮢��� 䠩��  --------}
Procedure TEMSText.SetItem(S: String);
  {����頥� � EMS-������ (��稭�� � ����樨
  Pos �� �� ��砫�) ��ப� S}
begin
  TEMSType.SetItem(S,Length(S)+1)
end;  {TEMSText.SetItem}
{-------------------}
Function TEMSText.GetItem: String;
  {��⠥� �� EMS-����� ��।��� ��ப�}
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
{-------- ����� ��࠭� � EMS-�����  --------}
CONSTRUCTOR TEMSScreen.Init;
  {������� ��ꥪ� - ��।���� ⥪�騩 ०��
  ࠡ��� ����������� � � ����ᨬ��� �� �⮣�
  १�ࢨ��� ������ �㦭��� ࠧ���}
var
  Sz: LongInt;
begin
{� ������� �㭪樨 $F ���뢠��� $10 ��।��塞
 ⥪�騩 ०�� ࠡ��� ��࠭�}
  with Reg do
    begin
      ah := $F;
      Intr($10,Reg);
      Mode := al
    end;
{�롨ࠥ� �㦭� ࠧ��� �����
 1..7 - ⥪�⮢� ०��� ��� ��䨪� CGA,16 �����=1�
 13,14 - ������ �� EGA/VGA ��䨪� CGA,16 �����=1�
 15 - ���� EGA 640x350, 28 ����� = 2 ���.
 16 - 梥�  "  "  "  ", 112 ����� = 7 ���.
 17 - ���� VGA 640�480, 38.4 ����� = 3 ���.
 18 - 梥�  "  "  "  ", 153.6 ����� = 10 ���.}
  case Mode of
    1..7,13..14 : Sz := LPage;
    15: Sz := 2*LPage;
    16: Sz := 7*LPage;
    17: Sz := 3*LPage;
    18: Sz := 10*LPage
  else
    Sz := 24*LPage   {��� SVGA}
  end;
  TEMSArea.Init(Sz)
end;  {TEMSScreen.Init}
{-------------------}
CONSTRUCTOR TEMSScreen.Load(var F: File);
  {��⠥� ��ꥪ� �� 䠩��}
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
  {���࠭�� ��ꥪ� � 䠩��}
begin
  TEMSArea.Store(F);
  if not EMSErrorFlag then
    if WriteFile(F,RegHeadTEMSScreen,SizeOf(TEMSScreen))
      then WriteFile(F,Mode,1)
end;  {TEMSScreen.Store}
{-------------------}
Procedure TEMSScreen.PutScreen;
  {�����뢠�� � EMS-������ ����� ��࠭�}
var
  x,y,xx,yy,dy: Integer;
  Pag: Byte;
  EMS,Video: Pointer;
begin
  {�஢��塞 ⥪�騩 �����०��}
  with Reg do
    begin
      ah := $F;
      Intr($10,Reg);
      if al<>Mode then		{����� ᮮ⢥����� Mode?}
        begin         		{��� - ᮮ�頥� � ��室��}
          EMSError($AD);
          Exit
        end
    end;
  {�����㥬 ����������� � ����ᨬ��� �� ०���}
  EMS := ptr(EMSS,0);       	{��砫� EMS}
  case Mode of
    1..6,13..14:{����⮢� ०��� ��� �����஢,
   		�஬� MDA, ��䨪� CGA ��� �� ������:
   		��砫� ���������� � $B800, ����� �� 16 �����}
      begin
        Video := Ptr($B800,0);
        MapEMSPage(Handle,0,0);
        if not EMSErrorFlag then
          MoveFromScreen(Video^,EMS^,LPage)
      end;
    7:          {����⮢� ०�� MDA:
   		��砫� ���������� � $B000,  ����� 4 �����}
      begin
        Video := Ptr($B000,0);
        MapEMSPage(Handle,0,0);
        if not EMSErrorFlag then
          MoveFromScreen(Video,EMS,LPage div 4)
      end;
    else  	{��⠫�� ��ᯫ��: �।����������, ��
      		�� EGA, VGA ��� SVGA � ����᪮� ०���}
      begin
        x := 0;             {���� ���孨�...}
        xx := GetMaxX;      {㣮� ��࠭�}
        y := 0;             {�ࠢ� ������ 㣮�}
        yy := 0;
        Pag := 0;     {����� ��砫쭮� ���.EMS}
        {��।��塞 ������⢮ dy ������ ��ப
         ��࠭�, ����� �� 㬥����� � �����
         ����� ��࠭��� EMS}
        while (ImageSize(x,y,xx,yy)<LPage) and
              (yy<=GetMaxY) do inc(yy);
        dy := yy-1;
{�᭮���� 横� ��࠭���� ����� ������� �� 16 �}
        repeat
          {�����㥬 ��࠭��� ����}
          MapEMSPage(Handle,0,Pag);
          {����砥� ����� ��� ��࠭�}
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
  {����砥� �� EMS-����� ����� ��࠭�}
var
  x,y,xx,yy,dy: Integer;
  Pag: Byte;
  EMS,Video: Pointer;
begin
  {�஢��塞 ⥪�騩 �����०��}
  with Reg do
    begin
      ah := $F;
      Intr($10,Reg);
      if al<>Mode then    {�����ᮮ⢥����� Mode?}
        begin             {��� -ᮮ�頥� � ��室��}
          EMSError($AD);
          Exit
        end
    end;
  {��७�ᨬ ����� � �����������
   � ����ᨬ��� �� ०���}
  EMS := ptr(EMSS,0);       {��砫� EMS}
  case Mode of
    1..6,13..14:{����⮢� ०��� ��� �����஢,
   		�஬� MDA, ��䨪� CGA ��� �� ������:
   		��砫� ���������� � $B800, ����� �� 16 �����}
      begin
        Video := Ptr($B800,0);
        MapEMSPage(Handle,0,0);
        if not EMSErrorFlag then
          MoveToScreen(EMS^,Video^,LPage)
      end;
    7:    {����⮢� ०�� MDA: ��砫�
           ���������� � $B000,  ����� 4 �����}
      begin
        Video := Ptr($B000,0);
        MapEMSPage(Handle,0,0);
        if not EMSErrorFlag then
          MoveToScreen(EMS,Video,LPage div 4)
      end;
    else   {��⠫�� ��ᯫ��: �।����������,
 	   �� �� EGA, VGA ��� SVGA � ����᪮� ०���}
      begin
        x := 0;             {���� ���孨�...}
        xx := GetMaxX;      {㣮� ��࠭�}
        y := 0;             {�ࠢ� ������ 㣮�}
        yy := 0;
        Pag := 0;      {����� ��砫쭮� ���.EMS}
{��।��塞 ������⢮ dy ������ ��ப ��࠭�,
����� �� 㬥����� � ����� ����� ��࠭��� EMS}
        while (ImageSize(x,y,xx,yy)<LPage) and
              (yy<=GetMaxY) do inc(yy);
        dy := yy-1;
 {�᭮���� 横� ����⠭���������࠭� ������� �� 16 �}
        repeat
          {�����㥬 ����}
          MapEMSPage(Handle,0,Pag);
          {��७�ᨬ ����� ��� ��࠭�}
          PutImage(x,y,EMS^,NormalPut);
          inc(Pag);
          inc(y,dy)
        until y>=GetMaxY
      end
    end  {case Mode}
end;  {TEMSScreen.GetScreen}
{------------  ����䥩� � EMM  ------------}
Procedure Intr67;
  {�������� ���뢠��� $67
  � ��⠭�������� 䫠� EMSStatus}
begin
  Intr($67,Reg);
  EMSStatus := Reg.ah
end;
{------------------}
Function IsEMS: Boolean;
  {�����頥� TRUE, �᫨ � �� ������� EMS-������}
const
  Name: array [1..9] of Char = 'EMMXXXX0'#0;
label
  Exit;
begin
  if EMSVer=0 then with Reg do {�뫠�஢�ઠ ࠭��?}
    begin        	{��� - �஢��塞 ��⠭���� EMM}
      ah := $3D; 	{������� ���ਯ�� 䠩��}
      al := 0;   	{��� �⥭��}
      dx := Ofs(Name);  	{� ������ "EMMXXXX0"}
      ds := Seg(Name);
      MSDOS(Reg);
      {�᫨ 䠩�� ��� - EMM �� ��⠭�����}
      if (Flags and FCarry)<>0 then
        Goto Exit;
      {�஢��塞 ����� 䠩��}
      bx := ax;         	{���ਯ�� 䠩��}
      ah := $44;        	{����� IOCTL}
      al := 7;          	{���� ����� 䠩��}
      MSDOS(Reg);
      if ((Flags and FCarry)<>0) or (al=0) then
        Goto Exit;
      ah := $46;      	{����砥� ����� ���ᨨ EMM}
      Intr67;
      if EMSStatus=0 then {�᫨ �訡�� - ��� EMM}
        begin
          EMSVer := al;  {���࠭塞 ����� ���ᨨ}
          ah := $41;     {����砥� ᥣ���� ����}
          Intr67;
          EMSS := bx     {���࠭塞 ᥣ����}
        end
    end;
Exit:
  IsEMS := EMSVer<>0
end;  {IsEMS}
{------------------}
Function GetEMMVersion: String;
  {�����頥� ����� ���ᨨ EMM � �ଠ� 'X.X'}
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
  {�����頥� ᥣ������ ����
   ���� "����" EMS-�����}
begin
  if EMSS=0 then
    if IsEMS then;
  EMSSeg := EMSS
end;  {EMSSeg}
{------------------}
Procedure GetEMSInfo(var AllPage, Pages: Word);
  {�����頥� ������ ������⢮ (AllPages) �
  ������⢮ ��������� (Pages) ��࠭��}
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
  {���뢠�� ���� ���ਯ�� Handle � ��뢠��
   � ��� Pages ��࠭�� EMS}
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
  {������ ���ਯ�� Handle    � �᢮��������易���� � ��� ������}
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
  {������� ����, ��뢠� ��� Physic 䨧�����
   ��࠭��� � Logic �����᪮� ��࠭�楩���ਯ�� Handle}
const
  OldH: Word=$FFFF;  {��ࠬ����...}
  OldL: Word=$FFFF;  {�।��饣�...}
  OldP: Word=$FFFF;  {���饭�� � ��楤��}
begin
asm
{�஢��塞 ��ࠬ���� ���饭��: �᫨ ��� �� ���﫨��,
 ����� ���⥪�� ��࠭�� ��࠭���� � ����� �� ����஢���}

  mov ax,Physic      	{AX := Physic}
  mov bx,Logic       	{BX := Logic}
  mov dx,Handle      	{DX := Handle}
  cmp ax,OldP        	{Physic=OldP ?}
  jne @do            	{��� - ���������� 䨧.���.}
  cmp bx,OldL        	{Logic=OldL ?}
  jne @do           	{��� - ���������� �����.���.}
  cmp dx,OldH       	{Handle=OldH ?}
  je @Exit          	{�� - ��ࠬ���� �� ���﫨��,
                    	�� �㦭� ����஢��� �� ࠧ}
@do:   	{��ࠬ���� ���������� - �����㥬:}
  mov OldP,ax     	{���࠭塞...}
  mov OldL,bx     	{����...}
  mov OldH,dx     	{��ࠬ����}
  mov ah,$44      	{��� �㭪樨 ��� ����஢����}
  int $67         	{�����㥬}
  mov EMSStatus,ah   	{���� ����� EMS}
@Exit: end;
end;  {MapEMSPage}
{=============} end. {Unit F_EMS} {=============}
