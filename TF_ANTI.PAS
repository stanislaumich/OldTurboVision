{���⮢�� �ணࠬ�� ��� ����� F_Anti}
Uses F_Anti;
begin
  case CheckVirusResult of
    0: WriteLn('� 䠩�� ',ParamStr(0),' ����� �� �����㦥�.');
    1: WriteLn('��⠭������ ���� 䠩�� ',ParamStr(0),'.');
   -1: WriteLn('����� 㤠��� � ࠧ�襭�� ���짮��⥫�.');
   -2: WriteLn('����� 㤠��� ��⮬���᪨.');
   -3: WriteLn('����஫� �����஢�� ���箬 /NOANTI.');
   -4: WriteLn('����� �ᯮ����� � ��砫� '+
               '䠩�� - 㤠����� ����������.')
  end
end.
