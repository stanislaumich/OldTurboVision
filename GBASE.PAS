Unit GBase;
{--------------------------------}INTERFACE{---------------------------------}
Uses Graph;
{----------------------------------------------------------------------------}
Const   Gray50 : FillPatternType = ($AA, $55, $AA,
    $55, $AA, $55, $AA, $55);
TYPE
   PBase = ^TBase;
   TBase = object
            X1,Y1,X2,Y2 : Integer;
            SaveFlag    : Boolean;
            UnderImage  : Pointer;
            Interior    : PBase;
            OImageSize  : Word;
            Color       : Word;

            Constructor Init(Save:Boolean;iX1,iY1,iX2,iY2:Integer;Point:PBase);
            Destructor  Done;          Virtual;
            Procedure   Draw;          Virtual;
            Procedure   Hide;          Virtual;
            Private Procedure   SaveImage;
            Private Procedure   RestoreImage;
           end;
{----------------------------------------------------------------------------}





{----------------------------}IMPLEMENTATION{--------------------------------}
Constructor TBase.Init;
 begin
  X1:=iX1;
  X2:=iX2;
  Y1:=iY1;
  Y2:=iY2;
  Color:=Random(255);
  Interior:=Point;
  SaveFlag:=Save;
  If SaveFlag then SaveImage;
  Draw;
 end;
{----------------------------------------------------------------------------}
Destructor TBase.Done;
 Var
  P:PBase;
 begin
  P:=Interior;
  While P<>NIL do
   begin
    P:=Interior^.Interior;
    Interior^.Done
   end;
  Interior:=NIL;
    If SaveFlag then
   begin
    RestoreImage;
    FreeMem(UnderImage,OimageSize);
   end;
 end;
{----------------------------------------------------------------------------}
Procedure TBase.Draw;
 begin
  SaveImage;
  {Drawing}
   SetFillPattern(Gray50,Color);
  Bar(X1,Y1,X2,Y2)
 end;
{----------------------------------------------------------------------------}
Procedure TBase.Hide;
 begin
  RestoreImage;
 end;
{----------------------------------------------------------------------------}
Procedure TBase.SaveImage;
 begin
  OImageSize:=ImageSize(X1,Y1,X2,Y2);
 { OImageSize:=(x2-x1+1)*(y2-Y1+1)+6;}
  GetMem(UnderImage,OimageSize);
  GetImage(X1,Y1,X2,Y2,UnderImage^)
 end;
{----------------------------------------------------------------------------}
Procedure TBase.RestoreImage;
 begin
  PutImage(X1,Y1,UnderImage^,NormalPut)
 end;
{----------------------------------------------------------------------------}
END.{________________________________________________________________________}