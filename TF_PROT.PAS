{+-------------------------------------------+
 | �� �ணࠬ�� �஢���� �����쭮��� ᢮�� |
 | ����� �� ��� ����஫� ���祢�� ��᪥��.  |
 +-------------------------------------------+}
Uses F_Prot;
Procedure Alarm; Far;
  {����砥� �ࠢ�����, �᫨ ����� �������쭠}
begin
  WriteLn('�������쭠� �����')
end;
{------------------}
Procedure Norma; Far;
  {����砥� �ࠢ����� � ��砥 �����쭮� �����}
begin
  WriteLn('�����쭠� �����')
end;
{------------------}
Function ParStr: String;
  {�����頥� ��ࠬ��� �맮�� � ���� ��ப� ��������� �㪢}
var
  S: String;
  k: Byte;
begin
  S := ParamStr(1);
  for k := 1 to Length(S) do
    S[k] := UpCase(S[k]);
  ParStr := S
end;
{-----------------}
var
  p1,p2: Pointer;
  d: Integer;
  dsk: Byte;
begin  {������� �ணࠬ��}
  p1 := @Norma;
  p2 := @Alarm;
  if ParStr='/SET' then
    WriteLn('��⠭���� �� ��: ',SetOnHD)
  else
    if ParStr='/REMOVE' then
      WriteLn('�������� � ��: ',RemoveFromHd)
    else
      begin
	ProtCheck(p1,p2,d);
	WriteLn('������� �஢�ન: ',d)
      end
end.




