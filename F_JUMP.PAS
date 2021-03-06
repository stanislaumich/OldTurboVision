{=============}  UNIT F_Jump;  {==============}
{
 +----------------------------------------------------------+
 | �����  ᮤ�ন� ���ம�।������, ��������騥 ��������� |
 | ���� ��� �ணࠬ�� � ⥬, �⮡� ��᫥ ��ࠡ�⪨ �訡��|
 | ��ਮ�� �ᯮ������ ��।��� �ࠢ����� � ��� ���.      |
 +----------------------------------------------------------+
}
                   INTERFACE
type
  JumpRec = record
    SPsave,            {���࠭�� ॣ���� SP}
    BPsave: Word;      {���࠭�� ॣ���� DP}
    JmpPtr: Pointer    {FAR-���� �த�������}
  end;  {JumpRec}
{-------------------}
Procedure SetJump(var JumpDest: JumpRec);
  {��� ����� ���ᯥ稢��� ��࠭���� ᮤ�ন���� ॣ���஢
   SP,BP � IP � ����� JumpDest. ������������ ���ﭨ�,
   ���஥ ����� ॣ����� � ������ �맮�� �����. ��
   ���ᯥ稢��� ��᫥���騩 ������ ��楤�ன LongJump � ���,
   �����।�⢥��� ᫥������ �� �맮���.}
InLine(
  $5F/
    {pop    di           ;DI=Ofs(JumpDest)     }
  $07/
    {pop    es           ;ES=Seg(JumpDest)     }
  $26/$89/$25/
    {mov    es:[di],sp   ;����頥� SP � SPsave }
  $26/$89/$6D/$02/
    {mov    es:[di+2],bp ;����頥� BP � BPsave }
  $E8/$00/$00/
    {call   null       	;����頥� � �⥪ ⥪�騩	}
    {null:               	;���� �������� CALL  	}
  $58/
    {pop    ax           	;��=⥪�騩 ����	}	
  $05/$0C/$00/
    {add    ax,12        	;ᬥ饭�� ������� NEXT	}
  $26/$89/$45/$04/
    {mov    es:[di+4],ax 	;��࠭塞 FAR-����	}
  $26/$8C/$4D/$06);
    {mov    es:[di+6],cs ;������� NEXT � JmpPtr	}
    {NEXT: ; �� �������� ���� �ࠧ� �� ����ᮬ � �易��
	� ��砫�� ��।���� ������ ��࡮ ��᪠��}
{-------------------}
Procedure LongJump(var JumpDest: JumpRec);
  {��� ����� ����⠭�������� ᮤ�ন��� ॣ���஢ SP � BP
  �� ����� SPsave, BPsave ����� JumpDest � ������
   FAR-���室 �� ����� JmpPtr.}

inline(
  $5F/
   {pop    di              ;DI=Ofs(JumpDest) 	}
  $07/
   {pop    es              ;ES=Seg(JumpDest)	}
  $26/$8B/$25/
   {mov    sp,es:[di]      ;����⠭�������� SP	}
  $26/$8B/$6D/$02/
   {mov    sp,es:[di+2]    ;����⠭�������� BP	}
  $26/$FF/$6D/$04);
   {jmp    far es:[di+4]   ;FAR-���室       	}
               IMPLEMENTATION
{============} end. {F_Jump} {=============}
