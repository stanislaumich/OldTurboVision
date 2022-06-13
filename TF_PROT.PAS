{+-------------------------------------------+
 | Эта программа проверяет легальность своей |
 | копии за счет контроля ключевой дискеты.  |
 +-------------------------------------------+}
Uses F_Prot;
Procedure Alarm; Far;
  {Получает управление, если копия нелегальна}
begin
  WriteLn('Нелегальная копия')
end;
{------------------}
Procedure Norma; Far;
  {Получает управление в случае легальной копии}
begin
  WriteLn('Легальная копия')
end;
{------------------}
Function ParStr: String;
  {Возвращает параметр вызова в виде строки заглавных букв}
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
begin  {Главная программа}
  p1 := @Norma;
  p2 := @Alarm;
  if ParStr='/SET' then
    WriteLn('Установка на ЖД: ',SetOnHD)
  else
    if ParStr='/REMOVE' then
      WriteLn('Удаление с ЖД: ',RemoveFromHd)
    else
      begin
	ProtCheck(p1,p2,d);
	WriteLn('Результат проверки: ',d)
      end
end.




