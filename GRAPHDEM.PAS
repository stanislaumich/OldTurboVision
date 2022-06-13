Uses Win_CRT, WinProcs, WinTypes, Strings;
var
  k: Integer; 		{Параметр цикла}
  DC: hDC;
  R: TRect;
  OldFont,Font: hFont;
  LogFont: TLogFont;
const
  NX = 50; 			{Количество точек по горизонтали}
  dt = 2*pi/NX;		{Шаг табуляции}
  NY = 10;			{Амплитуда графика}
  MaxX = 300;
  MaxY = 100;
  dx = MaxX div NX;
  dd = 20;
begin
  ScreenSize.X := 80;   {Ширина виртуального экрана}
  ScreenSize.Y := 60;   {Длина экрана}
  AutoTracking := False;{Запрещаем прокрутку}
  InitWinCrt;
  {DC := GetDC(CrtWindow);}
  R.Left := 0;
  R.Top := 0;
  R.Right := MaxX+3*dd;
  R.Bottom := 2*MaxY+3*dd;
  FillRect(DC,R,GetStockObject(LtGray_Brush));
  MoveTo(DC,dd,dd);
  LineTo(DC,dd,2*(MaxY+dd));
  MoveTo(DC,dd,MaxY+dd);
  LineTo(DC,MaxX+2*dd,MaxY+dd);
  FillChar(LogFont,SizeOf(LogFont),0);
  with LogFont do
    begin
      lfHeight := 20;
      lfItalic := 1;
      lfUnderline := 1;
      lfWeight := fw_Bold;
      StrCopy(lfFaceName,'Arial Cyr')
    end;
  Font := CreateFontIndirect(LogFont);
  OldFont := SelectObject(DC,Font);
  SetBkMode(DC,Transparent);
  DrawText(DC,'График синуса',13,R,dt_Center);
  SelectObject(DC,OldFont);
  DeleteObject(Font);
  for k := 0 to NX do
    begin
      {Выводим точки графика:}
      LineTo(DC,k*dx+dd,Round(MaxY*(1-sin(dt*k)))+dd);
      {Формируем таблицу значений:}
      GotoXY(NX+5,k+1);
      Write(dt*k:4:2,sin(dt*k):8:2)
    end;
  ReleaseDC(CrtWindow,DC)
end.
