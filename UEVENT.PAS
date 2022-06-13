Unit UEvent;
{--------------------------------}INTERFACE{---------------------------------}
Uses UMouse,UConst;
Const
 InternalEvent  =  0;
 MouseEvent     =  1;
 KeyboardEvent  =  2;

Var
 Extended:boolean;
 ScanCode:Byte;
 CharCode:Char;

Procedure ClearEvent(var Event:Word);
Function EventClear(Event:Word):Boolean;

{-----------------------------}IMPLEMENTATION{-------------------------------}

Procedure ClearEvent;
 begin
  Event:=cmNoCommand
 end;

Function EventClear;
 begin
  EventClear:=Event=cmNoCommand
 end;

END.