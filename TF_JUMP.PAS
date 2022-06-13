{+-------------------------------------------------------+
 | Программа иллюстрирует механизм выхода из процедуры   |
 |   завершения в нужную точку программы.В программе     |
 | осуществляется ввод произвольного целого числа, затем |
 |   вычисляется корень квадратный из него и находится   |
 | обратная ему величина.Для завершения работы программы |
 |             следует ввести единицу.                   |
 |+------------------------------------------------------+}
Uses F_Jump;
var
  OldExit: Pointer;  {Старое значение переменной ExitProc}
  Jump   : JumpRec;  {Сохранение точки выхода}
  r      : Real;     {Вспомогательная переменная}
label
  Loop;
Procedure MyExit; Far;
  {Эта процедура обрабатывает исключительную ситуацию}
begin
  LongJump(Jump)
end;  {MyExit}
begin
  OldExit := ExitProc;
  repeat
Loop:             		{Точка повторения ввода}
    if ErrorAddr <> NIL then
      begin
        Write('Повторите ввод числа: ');
        ErrorAddr := NIL;
        ExitCode := 0
      end
    else
      Write('Введите число: ');
    ExitProc := @MyExit;    	{Адрес процедуры выхода}
    SetJump(Jump);          	{Контролируем ввод данных}
    if ErrorAddr <> NIL then
      begin
        WriteLn('Ошибка при вводе вещественного числа');
        Goto Loop
      end
    else
      ReadLn(r);
    SetJump(Jump);             {Контролируем извлечение корня}
    if ErrorAddr <> NIL then
      begin
        WriteLn('Ошибка при извлечении корня');
        Goto Loop
      end
    else
      r := sqrt(r);
    SetJump(Jump);          	{Контролируем деление}
    if ErrorAddr <> NIL then
      begin
        WriteLn('Ошибка при делении чисел');
        Goto Loop
      end
    else
      r := 1/r;
    WriteLn(r:20:10)
  until r = 1;
  ExitProc := OldExit       {Нормальный выход}
end.
