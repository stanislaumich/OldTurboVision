{+-------------------------------------------------------+
 | �ணࠬ�� ���������� ��堭��� ��室� �� ��楤���   |
 |   �����襭�� � �㦭�� ��� �ணࠬ��.� �ணࠬ��     |
 | �����⢫���� ���� �ந����쭮�� 楫��� �᫠, ��⥬ |
 |   �������� ��७� ������� �� ���� � ��室����   |
 | ���⭠� ��� ����稭�.��� �����襭�� ࠡ��� �ணࠬ�� |
 |             ᫥��� ����� �������.                   |
 |+------------------------------------------------------+}
Uses F_Jump;
var
  OldExit: Pointer;  {��஥ ���祭�� ��६����� ExitProc}
  Jump   : JumpRec;  {���࠭���� �窨 ��室�}
  r      : Real;     {�ᯮ����⥫쭠� ��६�����}
label
  Loop;
Procedure MyExit; Far;
  {�� ��楤�� ��ࠡ��뢠�� �᪫��⥫��� �����}
begin
  LongJump(Jump)
end;  {MyExit}
begin
  OldExit := ExitProc;
  repeat
Loop:             		{��窠 ����७�� �����}
    if ErrorAddr <> NIL then
      begin
        Write('������ ���� �᫠: ');
        ErrorAddr := NIL;
        ExitCode := 0
      end
    else
      Write('������ �᫮: ');
    ExitProc := @MyExit;    	{���� ��楤��� ��室�}
    SetJump(Jump);          	{����஫��㥬 ���� ������}
    if ErrorAddr <> NIL then
      begin
        WriteLn('�訡�� �� ����� ����⢥����� �᫠');
        Goto Loop
      end
    else
      ReadLn(r);
    SetJump(Jump);             {����஫��㥬 �����祭�� ����}
    if ErrorAddr <> NIL then
      begin
        WriteLn('�訡�� �� �����祭�� ����');
        Goto Loop
      end
    else
      r := sqrt(r);
    SetJump(Jump);          	{����஫��㥬 �������}
    if ErrorAddr <> NIL then
      begin
        WriteLn('�訡�� �� ������� �ᥫ');
        Goto Loop
      end
    else
      r := 1/r;
    WriteLn(r:20:10)
  until r = 1;
  ExitProc := OldExit       {��ଠ��� ��室}
end.
