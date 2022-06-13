uses crt;
begin
if readkey=#0 then Writeln('#0#',Byte(readkey))
              else Writeln(Byte(readkey))
end.