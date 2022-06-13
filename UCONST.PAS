Unit UConst;
{iiiiiiiiiiiiiiiiiiiiiiiiiiiiiii}INTERFACE{iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii}
Uses Graph;
Const
{Draw Constants}
 Common   =  0;
 Selected =  1;
 Pressed  =  2;
{---------------------------------------------------------------------------}

{ System Color Constants}
scBack            : Integer = LightGray;
scFore            : Integer = Blue;
scBorderLeft      : Integer = White;
scBorderRight     : Integer = DarkGray;
HeaderBackColor   : Integer = Blue;
HeaderForeColor   : Integer = White;
{ListColorsConstant}
lcBack            : Integer = White;
lcFore            : Integer = Blue;
lcSelectedFore    : Integer = LightGreen;
lcSelectedBack    : Integer = Blue;
{----------------------------------------------------------------------------}
{Keyboard Constants}
UpKey    = 72; AltAKey = 30; AltOKey = 24 ; Alt4Key = 123;
DownKey  = 80; AltBKey = 48; AltPKey = 25 ; Alt5Key = 124;
EnterKey = 13; AltCKey = 46; AltQKey = 16 ; Alt6Key = 125;
EscKey   = 27; AltDKey = 32; AltRKey = 19 ; Alt7Key = 126;
LeftKey  = 75; AltEKey = 18; AltSKey = 31 ; Alt8Key = 127;
RightKey = 77; AltFKey = 33; AltTKey = 20 ; Alt9Key = 128;
F10Key   = 68; AltGKey = 34; AltUKey = 22 ; Alt0Key = 129;
TabKey   = 9 ; AltHKey = 35; AltVKey = 47 ;
EndKey   = 79; AltIKey = 23; AltWKey = 17 ;
InsKey   = 82; AltJKey = 36; AltXKey = 45 ;
AltMinusKey = 130;           AltYKey = 21 ;
DelKey   = 83; AltKKey = 37; AltZKey = 44 ;
HomeKey  = 71; AltLKey = 38; Alt1Key = 120;
BackKey  = 8 ; AltMKey = 50; Alt2Key = 121;
               AltNKey = 49; Alt3Key = 122;
AltEquallKey = 131;
{----------------------------------------------------------------------------}
{Commands}
cmEmpty      = 0;
cmExit       = 1;
cmAbortModal = 2;
cmHorMenu    = 101;
cmNoCommand  = $FFFF;
{----------------------------------------------------------------------------}
{CPU Delay}
Pause        : Word   = 20;
{----------------------------------------------------------------------------}
{Saving Image}
SAVE    =  TRUE;
NOTSAVE =  FALSE;
{----------------------------------------------------------------------------}
{EDITOR STRINGER}
InsMode    : Boolean = True;
Kursor     : Char    = #1;{Symbol for kursor}
Kurs1      = #1;
Kurs2      = #2;
{----------------------------------------------------------------------------}
{Graphicks constant}
 M : WORD = 100;
 Xmin : Real = -1.0;
 Ymin : Real = -1.0;
 Xmax : Real =  1.0;
 Ymax : Real =  1.0;
 Pmin : Real = -1.0;
 Qmin : Real = -1.0;
 Pmax : Real =  1.0;
 Qmax : Real =  1.0;
 K    : Word =  15 ;
{----------------------------------------------------------------------------}
{Colors}
Type
 RGBRec=record
         R,G,B:integer;
         ColorNum:Integer;
        end;
Const
 GreenPalette:array[0..MaxColors] of RGBRec=
 ( (R:0;G:3; B:0;ColorNum:0 ),
   (R:0;G:7; B:0;ColorNum:1 ),
   (R:0;G:11; B:0;ColorNum:2 ),
   (R:0;G:15;B:0;ColorNum:3 ),
   (R:0;G:21;B:0;ColorNum:4 ),
   (R:0;G:23;B:0;ColorNum:5 ),
   (R:0;G:27;B:0;ColorNum:20),
   (R:0;G:31;B:0;ColorNum:7 ),
   (R:0;G:35;B:0;ColorNum:56),
   (R:0;G:39;B:0;ColorNum:57),
   (R:0;G:43;B:0;ColorNum:58),
   (R:0;G:47;B:0;ColorNum:59),
   (R:0;G:51;B:0;ColorNum:60),
   (R:0;G:55;B:0;ColorNum:61),
   (R:0;G:59;B:0;ColorNum:62),
   (R:0;G:63;B:0;ColorNum:63)
 );
 RedPalette:array[0..MaxColors] of RGBRec=
 ( (R:3;G:0; B:0;ColorNum:0 ),
   (R:7;G:0; B:0;ColorNum:1 ),
   (R:11;G:0; B:0;ColorNum:2 ),
   (R:15;G:0;B:0;ColorNum:3 ),
   (R:19;G:0;B:0;ColorNum:4 ),
   (R:23;G:0;B:0;ColorNum:5 ),
   (R:27;G:0;B:0;ColorNum:20),
   (R:31;G:0;B:0;ColorNum:7 ),
   (R:35;G:0;B:0;ColorNum:56),
   (R:39;G:0;B:0;ColorNum:57),
   (R:43;G:0;B:0;ColorNum:58),
   (R:47;G:0;B:0;ColorNum:59),
   (R:51;G:0;B:0;ColorNum:60),
   (R:55;G:0;B:0;ColorNum:61),
   (R:59;G:0;B:0;ColorNum:62),
   (R:63;G:0;B:0;ColorNum:63)
 );
BluePalette:array[0..MaxColors] of RGBRec=
 ( (R:0;G:0;B:3; ColorNum:0 ),
   (R:0;G:0;B:7; ColorNum:1 ),
   (R:0;G:0;B:11; ColorNum:2 ),
   (R:0;G:0;B:15;ColorNum:3 ),
   (R:0;G:0;B:19;ColorNum:4 ),
   (R:0;G:0;B:23;ColorNum:5 ),
   (R:0;G:0;B:27;ColorNum:20),
   (R:0;G:0;B:31;ColorNum:7 ),
   (R:0;G:0;B:35;ColorNum:56),
   (R:0;G:0;B:39;ColorNum:57),
   (R:0;G:0;B:43;ColorNum:58),
   (R:0;G:0;B:47;ColorNum:59),
   (R:0;G:0;B:51;ColorNum:60),
   (R:0;G:0;B:55;ColorNum:61),
   (R:0;G:0;B:59;ColorNum:62),
   (R:0;G:0;B:63;ColorNum:63)
 );
CommonPalette:array[0..MaxColors] of RGBRec=
 ( (R:0; G:0; B:0; ColorNum:0 ),
   (R:0; G:0; B:40;ColorNum:1 ),
   (R:0; G:40;B:0; ColorNum:2 ),
   (R:0; G:40;B:40;ColorNum:3 ),
   (R:40;G:7; B:7; ColorNum:4 ),
   (R:40;G:0; B:40;ColorNum:5 ),
   (R:40;G:30;B:0; ColorNum:20),
   (R:49;G:49;B:49;ColorNum:7 ),
   (R:26;G:26;B:26;ColorNum:56),
   (R:0; G:0; B:63;ColorNum:57),
   (R:9; G:63;B:9; ColorNum:58),
   (R:0; G:63;B:63;ColorNum:59),
   (R:63;G:10;B:10;ColorNum:60),
   (R:44;G:0; B:63;ColorNum:61),
   (R:63;G:63;B:18;ColorNum:62),
   (R:63;G:63;B:63;ColorNum:63)
 );

VAR
 Pal                      : PaletteType;
 ListPattern              : FillPatternType;
{----------------------------------------------------------------------------}
Type
 Strin = String[30];
{----------------------------------------------------------------------------}
VAR
 Result        : Word;
 DoneModalF    : Boolean;
 First         : Boolean;
{----------------------------------------------------------------------------}
{qqqqqqqqqqqqqqqqqqqqqqqqqqqqq}IMPLEMENTATION{qqqqqqqqqqqqqqqqqqqqqqqqqqqqq}
END.