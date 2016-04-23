.foXL-M180 Banked Zsystem vers 1.93 Users Guide  27jan88     Page #















                   Bankeä Zsystem Version 1.34

                             for the

            Intelligent Computer Designs Corporation

               XL-M180 S-100 Single Board Computer









                Documentation and latest revisions
                               by
                         Wells Brimhall
                          Phoenix, Az.
                  Z-Paradise (ZNODE #52) Sysop
                     (602)996-8739 24hrs/day
                        300/1200/2400 bps

.paŠ.CW 24
USER'Ó GUIDÅ TABLÅ OÆ CONTENTS

.CW 10

      OVERVIEW..........................................PAGE 3

      FEATURES..........................................PAGE 4

      LIMITATIONS.......................................PAGE 5

      FUTURE ENHANCEMENTS...............................PAGE 6

      MINIMUM HARDWARE REQUIREMENTS.....................PAGE 6

      SUPPORTED FLOPPY DISK FORMATS.....................PAGE 7

      RAM DISK..........................................PAGE 8

      IOBYTE............................................PAGE 9

      GETTING STARTED...................................PAGE 9

      ZCPR3.............................................PAGE 13

      CUSTOMIZATION.....................................PAGE 16

      NEW UTILITIES.....................................PAGE 16

      MEMORY BANK OVERVIEW..............................PAGE 17

      T-FUNCTION CALLS..................................PAGE 19

      I/O PORT ADDRESSES................................PAGE 20

      S-100 INTERRUPTS..................................PAGE 20
     
      DISK ASSIGNMENTS..................................PAGE 21

      IMP MODEM PROGRAM.................................PAGE 22

      MOVE-IT OVERLAY...................................PAGE 22

      DISCLAIMER........................................PAGE 22

.PAŠ.TC  OVERVIEW..........................................PAGE #
                            OVERVIEW

Thió guidå onlù coveró thå basiã systeí specifiã aspectó oæ 
Zsysteí oî thå XL-M180® Useró shoulä alsï reaä thå following
documentatioî foò á fulì description of thå system®

                 "ZCPR3 The Manual" by Richard Conn,

           "ZRDOS Programmer's Guide" by Dennis Wright

                           and the new

        "Z-System Users Guide" by R. Jacobson & B. Morgen

     (All arå availablå froí Echeloî Inc® aô (415)948-3820.)


É havå beeî á Zsysteí useò foò somå timå anä purchaseä aî XÌ-M18° 
oveò á yeaò agï foò uså oî mù ZNODÅ bulletiî boarä system® Iô ió 
aî impressivå piecå oæ hardwarå anä É haä hopeä iô woulä greatlù 
extenä thå lifå oæ ¸ biô Ó-10° systems®  It'ó unfortunatå thaô 
ICD'ó businesó managemenô abilitù waó noô uğ tï thå samå leveì aó 
theiò hardwarå desigî ability® Thå writinç waó oî thå walì froí 
thå waù theù werå handlinç theiò customeró anä iô waó noô á greaô 
supriså wheî theù finallù closeä uğ shop® 

Aó mosô oæ yoõ alreadù know¬ ICÄ designeä thå XÌ-M18° foò uså 
witè Turbodoó® Iô ió á verù impressivå operatinç systeí buô it's
higè pricå makeó iô difficulô tï justifù foò singlå useò noî 
commerciaì applications.

É decideä tï writå thå Zsysteí BIOÓ myselæ afteò waitinç severaì 
monthó foò ICÄ tï dï iô witè nï results® (Theù shippeä må oveò 1° 
versionó oæ theiò Zsysteí BIOÓ anä noô eveî ± oæ theí woulä booô 
up!© Somå oæ thå desigî goaló oæ thió implementatioî werå tï 
includå severaì featureó oæ TurboDOS¬ keeğ thå cosô lo÷ anä 
stilì bå compatiblå witè alì thå existinç Zsysteí utilities® Iô 
turneä intï biggeò projecô thaî anticipateä anä haó takeî oveò á 
yeaò tï geô thió Bankeä versioî functional¬ buô É feeì iô ió no÷ 
onå oæ thå mosô powerfuì ¸ biô singlå useò operatinç systemó 
available® 

I'ä likå tï givå speciaì thankó tï Franë Gaude§ anä Davå McCorä 
aô Echelon® Theiò quicë responså iî sendinç ouô diskó ¦ 
documentatioî haó beeî mosô helpful.

Pleaså forwarä anù questions¬ buç reportó oò suggestionó tï mù 
Bulletiî Boarä Numbeò (602)996-8739® I'í quitå dedicateä tï 
supportinç thå XL-M18° anä Zsysteí sï givå må á call¡ (É wilì 
alsï keeğ thå latesô versionó oî-linå foò downloading.)
.paŠ.TC  FEATURES..........................................PAGE #
                            FEATURES

« Thå systeí ió writteî iî abouô á dozeî relocatablå moduleó thaô 
arå assembleä witè Echeloî ZAÓ 3.° assembleò anä linkeä witè 
LINK.COÍ froí Digitaì Research® ZRDOÓ 1.9 musô bå iî .REÌ formaô 
anä linkó righô iî witè thå resô oæ thå modules® Thå ZSETUĞ 
utilitù ió no÷ useä tï fullù configurå thå systeí withouô 
reassembly.

« Thå systeí ió booteä froí á filå nameä OSLOAD.COÍ insteaä oæ 
froí reserveä systeí tracks® Thió allowó thå systeí tï bå largeò 
thaî thå 1sô ² tracks¬ eliminateó thå neeä foò SYSGEÎ programó 
anä freeó uğ thå reserveä trackó foò files.

« Thå CCĞ ió storeä iî RAÍ sï thå booô disë ió noô necessarù 
afteò thå systeí ió colä booted® Thió alsï speedó uğ thå warí 
bootó considerably.

« Thå operatinç systeí ió no÷ spliô intï ² bankó whicè giveó á 
58ë tpá iî banë ±.

« Thå fulì ZCPR³ implementatioî ió supported® Iô includesº Inpuô 
Outpuô Package¬ Residenô Commanä Packagå (witè ne÷ BANË command)¬ 
Flo÷ Commanä Package¬ anä Nameä Directories.

« Supportó uğ tï fouò floppù driveó iî anù combinatioî oæ 5.25¢ 
4¸ tpi¬ 5.25¢ 9¶ tpé oò 8"® Thå driveó caî bå singlå oò doublå 
sideä anä singlå, doublå oò higè density® 

+ Supports a 394k ram disk. 

« Supportó ² harä disë driveó usinç thå OMTÉ SCSÉ controller® Thå 
driveó caî bå spliô spliô intï partitionó oæ uğ tï 8meç whicè 
allowó thå totaì capacitù oæ eacè drivå tï bå 128meg.

« Therå arå severaì ne÷ utilitieó includinç ZSETUP.COÍ whicè 
allowó yoõ tï configurå thå system¬ FMTF.COÍ whicè initializeó ¦ 
verifieó oveò 14 oæ thå mosô populaò floppù disë formató anä 
PARTH.COÍ whicè ió useä tï partitioî á harä disk® Alì oæ theså 
functionó arå no÷ considerablù easieò tï perforí anä nï longeò 
requirå reassemblinç thå system.

« Á tablå driveî schemå ió useä tï support floppù diskó witè manù 
differenô formats® Tï uså á ne÷ formaô alì yoõ havå tï dï ió 
creatå á smalì Disë Specificatioî Tablå anä linë iô intï thå 
system® Thå systeí automaticallù checkó eacè drive'ó disë format¬ 
locateó thå appropriatå DSÔ anä createó thå necessarù CP/Í 
compatiblå DPÈ ¦ DPÂ tables® Additionaì parameteró havå no÷ beeî 
addeä tï eacè DSÔ tï supporô practicallù anù diskettå formaô 
includinç Kayprï ´ anä AMPRO/Microminô SÂ-180.
.paŠ« Supportó switchinç betweeî lo÷ ¦ higè densitù oî duaì modå 
5.25¢ 9¶ tpé IBÍ AÔ compatiblå floppù driveó likå thå Teaã 
FD55GFö-17.

« Á multitaskinç dispatcheò ió implementeä anä alì thå physicaì 
driveró supporô á multitaskinç environment® Thió allowó speciallù 
codeä externaì processeó tï ruî iî thå backgrounä withouô 
interferinç witè thå DOÓ anä shoulä makå iô easieò tï upgradå tï 
á futurå multé-taskinç Zsystem.

« Thå systeí ió compatiblå witè oldeò S-10° maiî frameó anä I/Ï 
cards® (Thå HD6418° internaì I/Ï registeò baså haó beeî relocateä 
uğ tï 80è sï yoõ won'ô havå tï reconfigurå youò olä boardó anä 
software.© It'ó runninç righô no÷ oî á 1° yeaò olä IMSAÉ systeí 
witè it'ó originaì S-10° seriaì ¦ paralleì I/Ï boards¡ (Somå oæ 
thå IMSAÉ fronô paneì functionó neeä somå additionaì hardwarå tï 
implement¬ buô Reset¬ Stop¬ Singlå Steğ anä thå addresó displaù 
LED'ó worë fine.)

« Selecteä Turbodoó systeí calló arå supporteä tï givå Turbodoó 
compatiblå banë switchinç anä SIÏ channeì modeí control.

« Á paralleì printeò driveò ió no÷ includeä alonç witè fulì CP/Í 
physical/logicaì devicå reassignmenô througè thå IOBYTÅ aô 0003h® 

« Á logical/physicaì disë assignmenô tablå ió implemented® Thió 
allowó anù physicaì drivå tï bå reassigneä aó Aº sï iô caî takå 
advantagå oæ drivå A'ó speciaì accesó featureó likå thå ROOTº 
directory® Disë assignmentó arå changeä througè thå consolå witè 
thå ASSIGN.COÍ oò ZSETUP.COÍ utilitù programs® 

« Overlayó foò thå IMP.COÍ veró 2.4´ ¦ MOVE-IT.COÍ veró 3.° 
modem/communicatioî programó arå includeä sï yoõ caî uså siï 
channeì ± foò á modeí oò á seriaì linë betweeî anotheò system.

.TC  LIMITATIONS.......................................PAGE #
                           LIMITATIONS

­ Thå BIOÓ doeó noô presentlù detecô diskettå formaô changes® Yoõ 
musô perforí á warí booô afteò changinç tï á diskettå witè á 
differenô formats.

­ Therå ió nï harä disë formaô utilitù buô thå ICÄ FORMATH.COÍ 
prograí wilì ruî undeò thió versioî oæ thå system.

.paŠ.TC  FUTURE ENHANCEMENTS...............................PAGE #
                       FUTURÅ ENHANCEMENTS

« Automatiã assignmenô oæ thå booô drivå to Aº sï thå systeí caî 
booô from anù drive.

« Á disë writå verifù optioî thaô caî bå selectivelù enableä oò 
disableä oî anù combinatioî oæ thå 1¶ logicaì drives.

+ Read 48 tpi disks in a 96 tpi drive.

« Aî optioî tï makå Reaä Onlù Systeí Fileó publiã tï alì useò 
areaó oî á drive.

« Tablå driveî harä disë formaô utilitù foò thå OMTÉ SCSÉ 
controller.

« Á floppù DSÔ installeò utilitù thaô wilì allo÷ yoõ tï adä oò 
removå floppù disë formató withouô reassembly.

« Harä disë tï tapå backuğ utilitieó foò thå OMTÉ SCSÉ 
controller.

+« Anù suggestionó foò additionaì futurå improvementó wilì bå 
appreciated.

.TC  MINIMUM HARDWARE REQUIREMENTS.....................PAGE #
                  MINIMUM HARDWARE REQUIREMENTS

Console Terminal

Thå consolå shoulä bå á CRÔ terminaì witè 19.2ë bauä capability® 
Thå firsô timå yoõ booô uğ thå systeí thå TCSELECÔ utilitù wilì 
displaù á menõ oæ terminaló anä allo÷ yoõ tï selecô thå onå thaô 
yoõ arå using® Froí theî oî youò selecteä terminaì capabilitù 
filå wilì bå loadeä intï thå Systeí Enviormenô eacè timå yoõ colä 
boot.

Main Frame

The main frame must have a 6mhz or faster motherboard.

Floppy Disk Drives

Thå standarä distributioî disë ió configureä foò thå followinç 
floppy disk drives:

     A:= 5.25" 48 tpi flpy drv 0    C:= 5.25" 96 tpi flpy drv 2
     B:= 5.25" 48 tpi flpy drv 1    D:=           8" flpy drv 3

Iæ yoõ wanô tï booô uğ oî thå standarä booô disë yoõ wilì havå tï 
attacè á 5.25¢ 48tpé DS/DÄ drivå strappeä aó floppù 0® Anù otheò 
typå oæ drivå wilì requirå á speciaì ordeò systeí distributioî 
disë anä possiblù thå ne÷ versioî booô rom® (Oncå thå systeí ió 
uğ thå abovå assignmentó caî bå changeä tï meeô youò needs.© 
Here'ó á tablå oæ alì thå supporteä formats:
Š.TC  SUPPORTED FLOPPY DISK FORMATS.....................PAGE #
                  SUPPORTEÄ FLOPPÙ DISË FORMATS

fmt             size-      sec  sec/ Old New              disk
 # Name     tpi sides dens size trk  ROM ROM Read Wrt Fmt cap.
 = ======== === ===== ==== ==== ===  === === ==== === === ====
 1 Tdos48-2 48  5"-2  dbl  1024  5   yes yes yes  yes yes 400k
 2 Tdos48-1 48  5"-1  dbl  1024  5   yes yes yes  yes yes 200k
 3 Kpro2    48  5"-1  dbl   512 10    no yes yes  yes yes 193k
 4 Kpro´    4¸  5"-²  dbì   51² 1°    nï  nï yeó  yeó yeó 394k
 µ Amp48-²  4¸  5"-²  dbì   51² 1°    nï  nï yeó  yeó yeó 396k
 ¶ Amp96-²  9¶  5"-²  dbì  102´  µ    nï  nï yeó  yeó yeó 797k
 · Kpro9¶   9¶  5"-²  dâì   51² 1°    nï  nï yeó  yeó yeó 796k
 8 Tdos96-2 96  5"-2  dbl  1024  5    no yes yes  yes yes 800k
 9 Tdos96-1 96  5"-1  dbl  1024  5    no yes yes  yes yes 400k
10 IBM8-1   48  8"-1  sgl   128 26   yes yes yes  yes yes 250k
11 ICM8-²   4¸  8"-²  dbì   51² 1¶    nï  nï yeó  yeó yeó   1m
12 Tdos8-2  48  8"-2  dbl  1024  8   yes yes yes  yes yes 1.2m
13 Tdos8-1  48  8"-1  dbl  1024  8   yes yes yes  yes yes 600k
1´ TdosHÄ   9¶  5"-²  hé   102´  ¸    nï  nï yeó  yeó yes 1.²m
15 ICMHD    9¶  5"-²  hé    51² 1¶    nï  nï yeó  yeó yes 1.2m
 
(Thå BIOÓ supportó alì oæ thå abovå formats¬ thå olä roí onlù 
restrictó thå formató thaô yoõ caî booô from® Tdos4¸-² ió thå 
standarä systeí booô disë format® Iô ió alsï availablå iî anù oæ 
thå otheò bootablå formató oî speciaì order.)

1© Tdos4¸-² ió thå standarä formaô foò distribution® Iô caî bå 
reaä witè botè booô roí versionó anä provideó thå maximuí storagå 
peò 4¸ tpé floppy® Iô ió recommendeä thaô yoõ havå aô leasô onå 
4¸ tpé ds/dä drivå installeä oî thå systeí tï supporô thió 
format.

2© Tdos4¸-± ió supporteä foò thoså thaô onlù havå á singlå sideä 
4¸ tpé drivå oò wanô tï uså singlå sideä diskettes® Iô ió noô 
recommendeä foò normaì use.

³) Kpro² ió provideä foò portabilitù betweeî otheò ¸ biô systemó 
anä ió thå onlù noî Turbodoó 5.25¢ formaô thaô yoõ caî booô from® 
Botè Kayprï formató havå reserveä systeí trackó sï yoõ caî noô 
uså thå entirå disë foò filå storagå likå yoõ caî witè thå Tdoó 
formats.

4© Kpro´ ió useä bù severaì Kayprï machineó includinç thå ² anä 
10® Iô ió á doublå sideä formaô anä giveó twicå thå capacitù oæ 
thå Kpro² above® 

5© AMP4¸-² ió useä bù AMPRÏ anä Microminô iî thå SÂ-180® Iô ió 
onå oæ thå morå commoî formató foò ¸ biô machines® Iô doeó noô 
havå quitå thå samå capacitù aó thå Tdoó formató becauså of
it'ó reserveä tracks.

6© AMP9¶-² ió alsï useä bù AMPRÏ anä Microminô iî thå SÂ-180®  Iô 
giveó twicå thå capacitù oæ thå AMP4¸-² above.

.paŠ7© Kpro9¶ ió useä iî Kayproó witè thå PRÏ-¸ ROM® Iô ió similaò tï 
thå Kpro´ formaô witè twicå thå tracks.

8© Tdos9¶-² ió thå preferreä formaô foò locaì uså duå tï itó 800ë 
storagå capacitù alonç witè thå conveniencå anä pricå oæ 5.25¢ 
diskettes.

9© Tdos9¶-± ió supporteä foò thoså thaô wanô tï uså singlå sideä 
diskettes® Iô ió noô recommendeä foò normaì use.

10© IBM¸-± ió thå industrù standarä IBÍ 8¢ singlå sided¬ singlå 
densitù format® Thió shoulä providå thå maximuí portabilitù 
betweeî systems.

11© ICM¸-² ió useä bù Inteò-Continentaì Microsystems® Iô ió 
includeä foò portabilitù betweeî systemó anä ió noô recommendeä 
foò generaì uså duå tï it'ó smalleò sectoò sizå anä reserveä 
systeí tracks.

12© Tdos¸-² ió thå Highesô capacitù formaô supported® Iô alsï 
giveó thå besô performancå duå tï thå 500ë transfeò ratå oæ 8¢ 
drives® Therå ió á tradeofæ thougè wheî yoõ consideò thå cosô oæ 
theså disketteó veró thå Tdos9¶-² format.

13© Tdos¸-± giveó giveó similaò performancå tï thå Tdos¸-² buô 
onlù haó halæ thå storagå capacity® Iô ió noô recommendeä unlesó 
yoõ havå á singlå sideä drivå oò neeä tï uså singlå sideä disks.

14© TdosHÄ ió identicaì tï thå Tdos¸-² formaô buô iô ió foò uså 
witè 5¢ higè densitù IBÍ AÔ compatiblå floppù driveó likå thå 
Teaã FD55GFö-17.

15© ICMHÄ iä identicaì tï thå ICM¸-² formaô buô iô ió foò uså 
witè 5¢ higè densitù IBÍ AÔ compatiblå floppù driveó likå thå 
Teaã FD55GFö-17.

.TC  RAM DISK..........................................PAGE #
                            RAM DISK

Thå systeí supportó á raí disë as physicaì drivå 5® Iô ió 
initiallù configureä tï bå logicaì drivå E:¬ buô caî bå 
reassigneä witè thå ASSIGN.COÍ utilitù tï bå anù logicaì drive® 
Everù timå thå systeí ió powereä uğ thå raí disk'ó directorù wilì 
contaiî randoí data® Yoõ musô ruî thå followinç utilitù prograí 
tï formaô thå raí disë directorù beforå iô caî bå used:

     ERADIR Eº         ;format ram disk directory

Remembeò thaô everythinç oî thå raí disë wilì bå losô wheneveò 
thå systeí ió powereä down® Makå surå yoõ copù anythinç yoõ wanô 
tï savå ontï á floppù beforå turninç ofæ thå power!¡ Thå raí disë 
wilì greatlù speeä uğ disë intensivå operationó likå assemblies¬ 
linkó anä compiles® (Thå raí disë linkó thió veró oæ thå systeí 
300¥ fasteò thaî mù Kayprï 10!)

.paŠ.TC  IOBYTE............................................PAGE #
                             IOBYTE

Thå standarä Intel/CPÍ IOBYTÅ ió no÷ implementeä aô 0003h® Iô caî 
bå vieweä anä changeä witè thå ZSETUĞ utility.

.TC  GETTING STARTED...................................PAGE #
                         GETTING STARTED


Naturallù yoõ wilì havå tï instalì youò boarä intï á S-10° 
maiî frame® Iô ió stronglù recommendeä thaô yoõ firsô checë alì 
poweò supplù voltageó oî thå busó tï verifù thaô theù arå withiî 
+/- 10¥ oæ thå valueó belo÷ anä remembeò tï neveò instalì oò 
removå thå boarä witè thå poweò on¡ Here'ó á lisô oæ stepó foò 
thå installation:

1© Iæ yoõ havå onå oæ thå oldeò 2mhú motherboardó iî youò systeí 
yoõ wilì havå tï replacå iô witè á fasteò one® Whaô appeareä tï 
bå á DMÁ channeì probleí oî mù XL-M18° turneä ouô tï bå mù olä 
2mhú buss® Visyî (Compupro© makeó á ne÷ 10mhú motheò boarä thaô 
fiô intï mù Imsaé cabineô witè minimaì modifications.

2© Checë foò +¸ voltó oî S-10° lineó ± anä 5± ,+1¶ voltó oî linå 
² anä -1¶ voltó oî linå 52® Lineó 20¬ 50¬ 53¬ 7° anä 10° arå 
grounds.

3© Iæ yoõ havå aî oldeò S-10° systeí likå thå IMSAÉ witè á fronô 
paneì theî yoõ wilì neeä tï makå thå followinç modificationó 
beforå installinç thå board:

     a© Cuô thå tracå goinç tï S-10° piî 2° oî thå fronô paneì 
     edgå connectoò tï disconnecô thå olä UNPROTECÔ memorù 
     signal® Thå XL-M18° groundó thió piî sï iô woulä placå á 1ë 
     resistoò acrosó thå poweò supplù aô alì timeó anä coulä 
     possiblù mesó uğ somå oæ thå fronô paneì functions.

     b© Cuô thå tracå goinç tï S-10° piî 6¸ oæ thå XL-M18° edgå 
     connector® Thió ió thå MWRITÅ signaì whicè shoulä bå 
     generateä bù thå fronô paneì wheî iô ió iî á system.

     c© Thå 1´ piî datá busó flaô cablå ió noô connected® Makå 
     surå thå pinó arå insulateä witè tapå sï they won't shorô 
     ouô on anything. 

4) Insert the board into any slot of your S-100 mainframe. 

5© Connecô á 1´ piî flaô cablå froí J¹ (oî thå faò right© oæ thå 
XL-M18° tï á RS23² seriaì paddlå card® 

6© Pluç youò Consolå terminaì intï thå 2µ piî DÂ connectoò oî thå 
RS23² paddlå card® Thå RS23² signaló arå oî thå followinç pinó 
wheî thå jumperó oî j² anä j³ arå iî thå Â position:
.paŠ
+--- Supported on ch0 (j9) 
| +- Supported on ch1 (j8) 
ü |
ü | HD64180     RS232    
ü | signals     DB25 pin 
= = =======    ========= 
x x   GND  <->  1  GND   << Pins 1 & 7 are tied together.
x x  /txd  -->  2  txd   << To reverse pin 2 with 3 move the
x x  /rxd  <--  3  rxd      jumpers on J2 from B to A.
ø ø  /ctó  <--  µ  ctó   <¼ Musô bå at « leveì tï enablå tx.
x x  /cts  <--  6  dsr   << Pins 5 & 6 are tied together
x x   GND  <->  7  COM   << Pins 1 & 7 are tied together
x    /rts  -->  8  dcd   << Should be an input instead of output.
           <-- 19  rts   << No connection on XL-M180
x    /dcd  --¾ 2°  dtò   <¼ Tï reverså pinó µ ¦ ¶ witè 2° movå 
                             jumpers on J3 from B to A.

Aó yoõ caî see¬ therå arå somå seriouó problemó witè thå modeí 
controì signals® É aí workinç oî á cuô ¦ jumğ lisô foò thå RS23² 
paddlå carä tï straighteî ouô thå signaló alonç witè á schematic® 
Foò no÷ therå appearó nï bå nï probleí usinç iô witè á terminal.

7© Seô youò consolå tï 19.2ë baud¬ ¸ datá bits¬ ± stoğ bit¬ nï 
parity¬ anä Fulì duplex® Iæ youò consolå doesn'ô supporô theså 
valueó theî yoõ wilì havå tï ordeò á speciaì systeí booô disë 
thaô ió configureä tï youò specifications.

8© Thå systeí shoulä bå turneä oî beforå connectinç thå driveó tï 
verifù thaô thå consolå ió functional® Turî oî thå AÃ poweò anä 
presó thå reseô button® Iæ thå Consolå Returî keù ió presseä 
severaì timeó withiî thå nexô µ secondó thå systeí monitoò wilì 
sigî on® Iæ iô doesn'ô gï bacë anä checë youò bauä rates¬ 
voltages¬ anä seriaì porô connections® 

9© Connecô youò floppù drive(s© tï thå systeí witè thå 
appropriatå ribboî cables® Therå arå usuallù numerouó strapinç 
combinationó foò eacè drive® Makå surå thaô yoõ havå thå drivå 
yoõ arå goinç tï booô ofæ strappeä aó DRIVÅ 0® Iô ió probablù 
easieò tï determinå thå besô heaä loaä anä leä optionó bù triaì 
anä erroò oncå thå systeí ió running¬ buô yoõ shoulä makå surå 
theù arå seô tï á valiä combinatioî beforå booting® É havå thå 
followinç strapó installeä oî mù TEAÃ fd55bv:

                         DS0, U2, RE, RY

Thió seemó tï worë ouô prettù good® Thå motoò anä heaä loaä arå 
botè controlleä bù thå motoò signaì froí thå XL-M180® Á diskettå 
musô bå iî place¬ thå dooò musô bå closed¬  thå motoò linå musô 
bå asserteä anä thå drivå musô bå selecteä (thå latteò ² arå donå 
bù thå BIOS© beforå thå heaä wilì loaä anä thå LEÄ wilì turî on® 
Thå heaä wilì staù loadeä untiì thå motoò timeò procesó iî thå 
BIOÓ turnó thå motoò off® Iô ió seô tï gï ofæ afteò appx® 1µ 
secondó oæ nï activity® Avoiä usinç á heaä loaä strağ combinatioî 
thaô loadó anä unloadó thå heaä oî eacè access® Thå LEÄ wilì emiô Šá slighô glo÷ wheî idlå whicè indicateó thaô thå FDÃ chiğ ió 
pollinç thå drives.

Thå standarä systeí booô disë expectó 5.25¢ 4¸ tpé driveó tï bå 
strappeä aó drivå ° anä 1¬ á 5.25¢ 9¶ tpé drivå tï bå strappeä aó 
² anä á 8¢ drivå aó 3.‚ Iæ yoõ neeä á differenô configuratioî theî 
yoõ wilì havå tï ordeò á speciaì booô disk® (Thå initiaì 
configuratioî caî bå changeä fairlù easilù oncå thå systeí ió 
up.© Yoõ caî physicallù connecô fouò 5.25¢ driveó anä fouò 8¢ 
driveó tï thå systeí buô thå FDÃ chiğ haó á limitatioî oæ 
addressinç onlù ´ drives.

10© Turî thå systeí oî anä inserô thå booô disë intï drivå 0® Makå 
surå noîe oæ thå otheò driveó arå closeä witè disketteó iî them® 
No÷ closå thå booô drivå anä presó thå reseô button® Thå motoò 
wilì turî on¬ thå heaä wilì loaä anä thå LEÄ wilì light® Yoõ 
shoulä alsï bå ablå tï heaò thå drivå seekinç tï thå righô 
tracks® Iæ everythinç ió oë thå systeí wilì signoî withiî á fe÷ 
secondó theî iô wilì finisè initializinç thå Zsysteí packageó anä 
givå thå A0:Root>‚ prompt® Iæ yoõ havå anù problemó gï bacë anä 
doublå checë youò drivå straps® Therå ió alsï á BOOÔ commanä iî 
thå monitor® Iô maù bå helpfuì tï determinå wherå thå probleí is.

11© Oncå yoõ geô thå systeí booteä uğ immediatelù makå á backuğ 
copù oæ youò systeí booô disk¡ Herå arå á fe÷ suggestionó iæ yoõ 
only have 1 drive:

     Formaô thå raí disë directorù witè thå followinç commanä 
     line. (Thió musô bå donå eacè timå thå systeí ió powereä 
     up.)

          ERADIR E:<cr>     ;format ram disk directory

     Uså thió commanä linå tï copù thå booô disë tï thå RAÍ disk® 
     Therå wilì probablù bå á fe÷ fileó thaô won'ô fiô sincå thå 
     Tdos48-² formaô disketteó arå abouô 20ë largeò thaî thå RAM 
     disk® (Thå remaininç fileó caî bå copieä onå aô á timå afteò 
     thå masó transfer.)

          AC E:=A:*.*<cr>     ;copy all files to E: with verify

     No÷ inserô á blanë disë intï youò drivå anä initializå iô 
     witè thå FMTF.COÍ utility® Makå doublå surå thaô yoõ don'ô 
     initializå thå distributioî booô disk!‚ Thió examplå assumeó 
     thaô yoõ arå usinç á 5.25¢ 48tpé drivå aó Aº anä thaô yoõ 
     arå usinç thå TD48² format® Looë aô FMTF.DOÃ foò informatioî 
     oî usinç FMTÆ witè otheò driveó anä formats® 

         E:FMTÆ Aº TD482<cr>     ;format ne÷ diskette in drivå Aº

     Type a ^C to reboot. Then copy the files from the RAM disk
     back to your new diskette with this command line:

          E:AC A:=E:*.*<cr>   ;copy all files to E: with verify
Š
12© Twï driveó arå stronglù recommended¡ É havå onå 5.25¢ 4¸ tpé 
floppy¬ onå 5.25¢ 9¶ tpé floppy¬ onå 8¢ floppù anä á 85meg harä 
disë oî mù system® Thió waù É caî read¬ writå anä formaô alì oæ 
thå diskettå formats® (É considereä attachinç twï 9¶ tpé driveó 
anä usinç theí foò 4¸ tpé disketteó aó well¬ buô therå ió á 
seriouó compatibilitù probleí wheî yoõ trù tï reaä á disë iî á 4¸ 
tpé drivå thaô waó formatteä anä writteî oî á 9¶ tpé drive.© Tï 
makå á copù oæ á diskettå É havå tï copù iô tï anotheò drivå theî 
copù iô back¬ buô thió seemó likå á smalì inconveniencå compareä 
tï thå pricå oæ ³ morå floppù drives® 

13© É jusô pickeä uğ á Teaã FD55GFv-1· 5.25¢ 9¶ tpé drivå whicè É 
aí verù impresseä with® Iô ió aî exacô replacemenô foò mù olä 
800ë FD55Æ 96 tpé drivå buô iô wilì alsï supporô thå IBÍ AÔ 1.² 
meç higè densitù 500ë transfeò ratå diskettes® Iô haó aî 
extremelù quieô stepper¬ lookó identicaì tï mù FD55Bö-1¶ 4¸ tpé 
drivå froí thå front¬ anä haó thå samå strappinç layout® Thå 
systeí caî automaticallù detecô thå densitù oæ thå diskettå anä 
adjusô thå drivå accordingly® (Iî thå higè densitù modå yoõ caî 
alsï configurå iô tï appeaò tï bå aî 8¢ drivå tï thå system.©  Aô 
undeò $12µ iô lookó likå thå dayó oæ thå 8¢ floppieó arå over.

14© Tï uså mù olä IMSAÉ SIÏ boardó witè thå XL-M18° É haä tï cuô 
thå traceó goinç tï thå olä 2mhú ph² clocë linå oî theiò S-10° 
edgå connectoró whicè ió no÷ 6mhú (piî 24© anä jumğ theí oveò tï 
thå ne÷ IEEÅ 2mhú clocë linå (piî 49)® Thió modificatioî maù bå 
necessarù oî otheò olä boardó aó well.

15© Á seriaì printeò caî bå connecteä tï siï ch1® Connecô á RS23² 
paddlå boarä betweeî J¸ anä youò printer® Looë aô iteí ¶ abovå 
foò thå pinouô oî thå paddlå card® Thå ctó linå musô bå aô á 
positivå leveì foò thå uarô tï outpuô characters® Iô caî bå useä 
foò thå printeò busù hanä shakå signal® Takinç iô negativå wilì 
stoğ outpuô tï thå printer® Thå standarä configuratioî oæ thå 
systeí wilì senä alì LSTº devicå outpuô tï siï ch1® 

.paŠ
.TC  ZCPR3.............................................PAGE #
                              ZCPR3

Thió implementatioî supportó thå followinç ZCPR³ packageó anä 
commands® Pleaså refeò tï thå ZCPR³ manuaì bù Richarä Conî foò 
fulì informatioî oî eacè commandó use® Yoõ caî uså thå SHOW.COÍ 
utilitù prograí tï vie÷ thå commandó thaô arå supporteä anä seå 
where each package resides in memory.

Command Processor Commands

Theså commandó arå containeä iî thå 2ë ZCPR³ Consolå Commanä 
Processoò (CCP)® Theù arå loadeä intï raí eacè timå thå systeí 
doeó á colä oò warí booô anä arå availablå foò uså wheneveò thå 
thå Drive/User:¾ prompô ió present.

     SAVE n file    ;Saves n pages starting at 100h to file
     GET adr file   ;Load a file into the tpa @ hex address
     JUMĞ adò       ;jumğ tï heø addresó ¦ executå code in tpa
     
Resident Command Package

Theså commandó arå containeä iî thå M180.RCĞ file® Iô ió loadeä 
intï memorù abovå thå BIOÓ oî colä bootó bù thå LDR.COÍ utilitù 
program® Oncå loadeä thå followinç commandó wilì bå available® 
(Sincå theså routineó staù iî memory¬ theù providå verù quicë 
response.)

     H              ;Display list of commands.
     CP dest=source ;Copy source file to dest file.
     ECHO string    ;Echo string back to console.
     ERA file       ;Erase file(s).
     NOTE string    ;Treat string as a comment.
     P adr          ;Peek at memory & display in hex & ascii.
     POKE adr val   ;Poke hex or ascii values into memory.
     PROT file atrb ;Set/reset files R/O or SYS attributes.
     REN new=old    ;Rename old file to new.
     WHL pwd        ;Set/Reset Wheel byte (pwd='SYSTEM').
     WHLQ           ;Display Wheel status.
     
     Thå abovå arå alì standarä commandó aó describeä iî thå 
     ZCPR³ manual® Thå followinç ne÷ commanä waó addeä tï displaù 
     thå XL-M18° Memorù Managemenô Uniô registeró anä optionallù 
     changå thå memorù bank.

     BANK      Display the current MMU register values.

     BANK n    Seô thå tpá BANË numbeò tï î (° oò 1© anä displaù 
               thå MMÕ registers® 
.paŠ
Flow Command Package

Theså commandó arå containeä iî thå M180.FCP file® Iô ió loadeä 
intï memorù above the BIOS witè LDR.COÍ jusô likå M180.RCĞ abovå.
Oncå loadeä thå followinç additionaì commandó wilì bå available:

     IF op     Seô thå flo÷ statå tï thå valuå oæ op.
     ELSE      Toggle the flow state.
     FI        Terminate the IF level.
     XIF       Exit all pending IFs back to level 0.

     The following options can be used with the IF command:

     ER        = True if error flag is set.
     EX afn    = True if file exists.       
     IN        = True if T,Y,<cr> or <sp> are input at console.
     NU afn    = True if afn is null.

Wheî thå flo÷ statå ió truå consolå commandó arå processeä aó 
usual® Iæ thå flo÷ statå ió seô tï false¬ consolå commandó wilì 
bå reaä buô noô executed® Onå oæ thå besô useó oæ thió featurå ió 
selectivå executioî oæ programó withiî ZEX batcè commanä files.

Input Output Package

Thå IOĞ featurå oæ Zsysteí allowó yoõ tï writå custoí driveró foò 
youò IÏ deviceó aó á separatå IOĞ segment® Theù caî theî bå 
easilù addeä tï thå systeí witè thå LDR.COÍ utility® (Yoõ maù 
wanô tï havå severaì differenô IOĞ segmentó sincå theù caî bå 
changeä sï easily.© Oncå thå IOĞ segmenô ió loaded¬ thå 
DEVICE.COÍ utilitù ió useä tï displaù anä changå thå devicå IÏ 
assignments® Yoõ caî alsï uså thå RECORD.COÍ utilitù tï savå CONº 
oò LSTº outpuô tï á disë file® Á samplå XÌ-M18° IOĞ ió includeä 
alonç witè sourcå code® Yoõ caî modifù iô tï meeô youò needs.

Thå IOĞ memorù areá ió initializeä tï thå specificationó iî thå 
"ZCPR³ anä IOPs¢ tutoriaì bù Richarä Conn® Thå jumğ vectoò 
locateä aô BIOS+° ió alsï modifieä durinç colä booô tï addresó aî 
internaì IOĞ vectoò tablå withiî thå BIOÓ foò thå BIOÓ devicå 
drivers® Thió allowó aî IOĞ segmenô tï locatå thå BIOÓ devicå 
routineó througè thå olä colä booô vector.
.paŠ
STARTUP.COM Alias

Wheî thå systeí ió colä booteä ZCPR³ loadó thå filå STARTUP.COÍ 
anä executeó it® STARTUP.COÍ ió aî ALIAÓ prograí thaô executeó 
the followinç commanä lines:

     LDR M180A.RCP,M180.NDR,M180.FCP,XLM11.IOP
     IÆ ~EXISÔ SYSTEM.Z3T;TCSELECÔ SYSTEM;FI
     LDÒ SYSTEM.Z3T;TPASIZE

Thió finisheó thå initializatioî bù allowinç yoõ tï selecô youò 
terminaì anä loadinç thå ´ ZCPR³ packageó intï theiò placeó iî 
memorù abovå thå BIOS® Yoõ caî uså onå oæ thå ALIAÓ utilitieó tï 
modifù STARTUP.COÍ sï iô wilì alsï executå otheò initializatioî 
programó necessarù foò youò system.

Zsystem Utilities

Thå fulì systeí includeó appø 8° Zsysteí utilitù programs® Mosô 
oæ thå utilitieó wilì displaù builô iî helğ infï iæ yoõ enteò thå 
followinç commanä line:

     Utility //     ;Utility= Utility program name

Mosô oæ thå utilitieó musô bå installeä beforå theù caî bå used® 
Alì oæ thå utilitieó includeä witè thå systeí werå alreadù 
installeä foò yoõ bù runninç thå followinç commanä line.

     Z3INS M180 ZSYSTEM.INS

Z3INS.COÍ anä M180.ENÖ shoulä bå oî thå disë alonç witè thå 
programó beinç installed® Wheî yoõ adä ne÷ utilitieó tï thió 
systeí yoõ wilì havå tï instalì theí likå thisº 

     Z3INS M180 Utility.COM

É recommenä downloadinç thå followinç Publiã Domaiî programó froí 
youò locaì ZNODÅ anä renaminç theí foò uså aó youò DIÒ anä TYPÅ 
commands.

     DIR.COM  = SD115.COM
     TYPE.COM = TYPEL36.COM
.paŠ
.TC  CUSTOMIZATION.....................................PAGE #
                          CUSTOMIZATION

Thå ZSETUP.COÍ utilitù no÷ performó fulì systeí customization® 
(Iô ió nï longeò necessarù tï ediô anä reassemblå thå systeí tï 
configurå it.© ZSETUĞ giveó yoõ thå optioî oæ configurinç thå 
OSLOAD.COÍ filå oò configurinç thå systeí presentlù iî memory® 
ZSETUĞ useó thå OSLOAD.SYÍ filå tï determinå thå patcè addresseó 
withiî thå systeí sï makå surå iô ió iî thå currenô directorù 
beforå ZSETUĞ ió run® ZSETUĞ musô bå iî banë ° tï worë properly® 
Iô wilì aborô iæ yoõ trù tï ruî iô froí banë 1.

ZSETUĞ ió menõ driveî anä ió prettù selæ explanatory® Thå onlù 
waù yoõ caî geô intï troublå ió bù noô backinç uğ youò 
distributioî disk® Wheî ZS130.ZEØ ió ruî iî thå disë modå iô wilì 
overwritå anù existinç OSLOAD.COÍ filå thaô ió oî thå disk® Iæ 
anù mistakeó arå madå iî configurinç thå systeí yoõ won'ô bå ablå 
tï geô iô tï booô agaiî sï makå surå youò originaì OSLOAD.COÍ ió 
backeä up!!!

Summarù oæ ZSETUĞ configuratioî parameters:

     1© SIÏ porô parameters
     2© IOBYTE
     3© Physicaì disë drivå parameters
     4© Logicaì/physicaì drivå assignments
     5© Floppù motoò turî ofæ time
     6© Waiô states
     7© Signoî messagå version

Iæ yoõ havå thå ZBIOÓ disë yoõ caî modifù thå sourcå files¬ 
reassemblå theí witè ZAÓ 3.0 anä theî uså thió commanä linå tï 
generatå youò ne÷ systeí witè ZEX.COÍ anä LINK.COÍ froí Digitaì 
Researcè Inc.

     ZEØ ZOS193     » Generatå OSLOAD.COÍ bù linkinç alì the
                    ; BIOS modules.

.TC  NEW UTILITIES.....................................PAGE #
                          NE× UTILITIES

Thå followinç utilitieó arå no÷ parô oæ thå systeí package.

     FMTF.COM  Thió ió á tablå driveî Multé-formaô floppù disë 
               initializå/verifù program® Seå FMTF.DOÃ foò fulì 
               instructions oî it'ó use.

     PARTH.COM Thió ió á tablå driveî Harä disë partitioî 
               utility® Seå PARTH.DOÃ foò fulì instructionó oî 
               it'ó use.

     ZEX.COM   Thió ió ZEØ veró 3.1â whicè haó beeî slightlù 
               modifieä tï ruî iî eitheò bank° oò bank1® Iô doeó 
               á BIOÓ versioî checë anä wilì onlù worë witè 
               Zsysteí veró 1.3´ anä up® Earlier versionó oæ ZEØ 
               wilì noô worë witè thió bankeä Zsystem!Š.TC  MEMORY BANK OVERVIEW..............................PAGE #
                      MEMORÙ BANË OVERVIEW

Thió BIOÓ no÷ utilizeó ² memorù bankó foò thå Disë Operatinç 
System® Thå primarù advantagå oæ doinç thió ió tï providå thå 
maximuí possiblå TPÁ sizå foò applicatioî programs® Wheî thå 
systeí colä bootó BANË ± ió selecteä foò thå TPA® Iô ió appø 58ë 
iî size® Severaì utilitieó wilì onlù operatå froí banë 0® Yoõ caî 
easilù changå betweeî bankó witè thå followinç RCĞ commanä whicè 
ió alwayó residenô iî memorù anä caî bå executeä wheneveò thå ZOÓ 
commanä linå prompô ió present.

     BANË 0    ;selecô banë ° foò thå TPA
     BANË 1    ;selecô banë ± foò thå TPA

Tï makå thå bankeä BIOÓ schemå worë witè thå largesô possiblå TPA
iô waó necessarù tï placå ZCPR³ aô á noî standarä addresó anä thå 
sizå oæ thå BDOÓ iî banë ió onlù ³ bytes® Thå onlù prograís thaô É 
havå founä thaô thió affectó arå thå Z3LOÃ utilitù anä ZEX® Thå 
systeí includeó á modifieä ZEX¬ buô insteaä oæ usinç Z3LOÃ yoõ 
should refeò tï thió addresó map:

                           Higè Memory
        «----------- Unbankeä Commoî Memorù -----------+
        ü                                              |
        ü  addresó rangå  sizå   disc.                 |
        ü  ------------­ -----­ ---------------­       |
        ü   ffd° ­ fffæ    4¸    Z³ exô stacë          |
        ü   ff0° ­ ffcæ   20¸    Z³ commanä buffeò     |
        ü   fe8° ­ fefæ   12¸    Z³ tcağ               |
        ü   fe0° ­ fe7æ   12¸    Z³ Environmenô desc   |
        ü   fdfæ            ±    Z³ Wheeì bytå         |
        ü   fdf´ ­ fdfå    1±    Z³ Externaì patè      |
        |   fdd0 ­ fdf³    3¶    Z³ Externaì FCÂ       |
        ü   fd8° ­ fdcæ    8°    Z³ messagå buffeò     |
        ü   fd0° ­ fd7æ   12¸    Z³ shelì stacë        |
        ü   fc0° ­ fcfæ   25¶    Z3 Nameä directorù    |
        ü   fa0° ­ fbfæ   51²    Z³ FCP                |
        ü   f20° ­ f9fæ  204¸    Z³ RCP                |
        ü   ec0° ­ f1fæ  153¶    Z³ IOĞ                |
        |   e80° ­ ec0°  102´    banë manageò          |
        |   e7fä ­ e7fæ     ³    Upper BDOS vectoò     |
        |   e00° ­ e7fæ  204¸    ZCPR³                 |
        ü                                              |
        +----------------------------------------------+

  «-­ Banë ° oæ Bankeä Mem. --«  «­- Banë 1 oæ Bankeä Mem. --+
  ü                           ü  ü                           |
  |  ae0° ­ dffæ  BIOÓ        |  ü                           |  
  ü  a00° ş adff  BDOÓ        ü  ü                           |    
  |  800° ş 9fff  DSÁ         |  ü                           |
  |  010° ş 7ffæ  Banë ° TPA  |  ü  0100 ­ dffæ  Banë 1 TPA  |
  |  000° ­ 00fæ  Pagå °      ü  ü  000° ­ 00fæ  Pagå 0      |
  ü                           ü  ü                           |
  «­--­­­­­­­­­­­­­­­­­­­­­­­­«  +---------------------------+
                           LO× MEMORYŠ
¨ DSÁ ½ Dynamiã Storagå Areá foò disë tables¬ sectoò bufferó ¦  
        etc® © 
¨ Pagå ° ½ CP/Í pagå ° vectoró ¦ bufferó )

Therå ió nï fixeä limiô oî thå sizå oæ thå BDOÓ oò BIOÓ sï lonç aó 
theiò  combineä sizå fitó intï banë ° anä leaveó reasonablå  rooí 
foò thå DSÁ anä TPA® 

Thå commoî memorù areá ió iî physicaì banë 0® Thió phantomó ouô 
e00° tï fffæ iî bankó ± througè n® ZCPR³ is saveä iî banë ± 
aô e00°  anä DMA'eä bacë tï banë ° durinç warí boots® Thió allowó 
applicatioî programó tï overlaù ZCPR³ jusô likå thå CP/Í 
specificationó tï providå á 58ë tpá whicè appearó tï bå jusô 
abouô aó largå aó possiblå foò á fulì Zsysteí implementation.

Bankó ² thrõ · arå reserveä foò Raí Disë use® Theù arå accesseä 
througè DMÁ aó physicaì memorù sï thå abovå commoî memorù area
assignment does noô uså anù oæ thå space.

.paŠ.TC  T-FUNCTION CALLS..................................PAGE #
                        T-FUNCTIOÎ CALLS

Thå followinç TurboDOS compatiblå Ô-functioî calló arå supporteä 
bù thå system® Theù providå á convenienô anä portablå waù tï 
accesó thå interrupô driveî SIÏ routineó anä thå tpá banë selecô 
routines® Tï perforí á Ô-functioî yoõ musô loaä thå functioî 
numbeò intï thå Ã register¬ loaä anù necessarù parameteró anä 
calì 50h® (Yoõ shoulä assumå thaô alì registeró wilì bå destroyeä 
durinç thå call.© 

     NAME:          COMST
     CALÌ WITH:     c½ 34
                    d½ SIÏ channeì numbeò (° oò 1)
                    a½ ° iæ inpuô characteò ió noô available
     COMMENTS:      Returî thå inpuô statuó oæ thå specifieä SIÏ 
                    channel.

     NAME:          COMIN
     CALÌ WITH:     c½ 35
                    d½ SIÏ channeì numbeò (° oò 1)
     RETURNS:       a½ inpuô character
     COMMENTS:      Inpuô á characteò from thå specifieä SIÏ 
                    channel®

     NAME:          COMOUT
     CALÌ WITH:     c½ 36
                    d½ SIÏ channeì numbeò (° oò 1)
                    e½ outpuô character
     COMMENTS:      Outpuô á characteò tï thå specifieä SIÏ 
                    channel®  
     
     NAME:          SETBAUD
     CALÌ WITH:     c½ 37
                    d½ SIÏ channeì numbeò (° oò 1)
                    e½ bauä ratå codå 
                        4½  150¬  5½   300¬  ¶½   60°
                        7½ 1200¬ 1°=  2400¬ 1²½  4800
                       1´½ 9600¬ 1µ½ 19200¬  °= 38400
     COMMENTSº      Setó bauä ratå oæ specifieä SIÏ channeì.

     NAME:          GETBAUD
     CALÌ WITH:     c½ 38
                    d½ SIO channeì numbeò (° oò 1)
     RETURNS:       a½ bauä ratå codå   (bitó 0-3)
                        4½  150¬  5½   300¬  ¶½   60°
                        7½ 1200¬ 1°=  2400¬ 1²½  4800
                       1´½ 9600¬ 1µ½ 19200¬  °= 38400
     COMMENTSº      Returnó currenô bauä ratå oæ specifieä SIÏ 
                    channel.
.paŠ   
     NAME:          SETMDM
     CALÌ WITH:     c½ 39
                    d½ SIÏ channeì numbeò (° oò 1)
                    e½ modeí controì byte
                       biô · seô tï asserô RTS
     COMMENTS:      Seô thå statå oæ thå modeí controì signaló 
                    foò thå specifieä SIÏ channel.

     NAME:          GETMDM
     CALÌ WITH:     c½ 40
                    d½ SIÏ channeì numbeò (° oò 1)
     RETURNS:       a½ modeí statuó byte
                       biô · seô foò CTÓ asserted
                       biô µ seô foò DCÄ true
     COMMENTS:      Returnó thå currenô statå oæ thå modeí 
                    controì signaló foò thå specifieä SIÏ 
                    channel.

     NAME:          MEMBNK
     CALÌ WITH:     c=43
                    e½ -± tï interrogatå thå tpá bank
                    e½ ° oò ± tï seô thå tpá bank
     RETURNS:       a½ banë selecteä foò thå tpa.
     COMMENTS:      Geô oò seô thå TPÁ memorù bank® (Thå banë 
                    doeó noô actuallù changå untiì thå nexô warí 
                    boot® Otherwiså á prograí woulä hanç uğ thå 
                    systeí bù switchinç itselæ ouô oæ memory.)

.TC  I/O PORT ADDRESSES................................PAGE #
                       I/O PORT ADDRESSES

Looë aô thå includeä HD64180.LIÂ anä M180.LIÂ fileó iæ yoõ neeä 
tï kno÷ thå addresó oæ anù I/Ï portó oî thå board® Remembeò thaô 
thå HD6418° I/Ï registeò baså addresó ió relocateä tï 80è iî thå 
loadeò module® Thió allowó existinç softwarå anä S-10° I/Ï boardó 
tï worë without being re-addressed.

.TC  S-100 INTERRUPTS..................................PAGE #
                        S-100 INTERRUPTS

Á modå ² interrupô vectoò tablå ió based aô BIOÓ « 100è foò thå 
¸ interrupô lineó oî thå S-10° buss® Applicatioî programó caî uså 
thå WBOOÔ jmğ vectoò aô 1è tï locatå anä initializå thå necessarù 
interrupô vector® (É haven'ô haä timå tï verifù thaô thå XÌ-M18° 
Ó-10° interrupô hardwarå ió functionaì sï gooä luck.)

.paŠ.TC  DISK ASSIGNMENTS..................................PAGE #
                        DISË ASSIGNMENTS

Thå ASSIGN.COÍ utilitù prograí ió useä tï changå thå 
logical/physicaì disë assignmentó froí thå console® Thå maiî 
reasoî iî doinç thió ió sï anù drivå caî bå reassigneä aó Aº tï 
takå advantagå oæ drivå A'ó speciaì accesó featureó likå thå 
rootº directorù anä autï logiî oî warí boots® Thió featurå ió 
alsï usefuì foò reassigninç á harä disë oò raí disë aó thå Aº 
drivå tï takå advantagå oæ itó higheò speeä performancå foò youò 
mosô useä drive® ASSIGN.COÍ wilì onlù executå froí banë 0® Iæ yoõ 
attempô tï ruî iô froí banë ± aî erroò messagå wilì bå displayeä 
anä iô wilì abort® Herå arå somå exampleó oæ ASSIGN.COÍ commanä 
lines:

     BANË 0              ;Selecô banë ° foò thå tpa
     ASSIGN /¯           ;Displaù builô iî helğ info
     ASSIGÎ              ;Displaù currenô drivå assignments
     ASSIGÎ A:µ          ;Assigî phù drivå µ (raí disk© tï A:
     ASSIGÎ A:6,B:±      ;Assigî phù drivå ¶ (harä disk© tï A:
                         »anä phù drivå ± (floppù 0© tï B:

Wheî thå systeí ió initiallù configured¬ eacè drivå ió assigneä á 
uniquå physicaì drivå number® Thå systeí wilì supporô uğ tï 2³ 
physicaì driveó anä comeó witè thå followinç 1µ physicaì driveó 
(±-15© configured® Theù caî bå assigneä tï anù oæ thå 1¶ logicaì 
driveó (Aº-P:)® Accessinç thå samå drivå bù morå thaî onå Drivå 
letteò caî causå losó oæ datá duå tï thå CP/Í typå disë 
allocatioî schemå thaô Zsysteí uses® Tï insurå thaô thió doeó noô 
happen¬ ASSIGN.COÍ  wilì cleaò anù duplicatå physicaì assignmentó 
tï ° wheî á ne÷ assignmenô ió made® Yoõ cannoô assigî thå 
physicaì drivå numbeò presentlù assigneä tï Aº tï anù otheò 
logicaì drive® Thió woulä cleaò thå assignmenô foò Aº tï ° whicè 
wilì hanç thå systeí wheî iô warí boots® Iæ yoõ attempô tï dï sï 
ASSIGN.COÍ wilì displaù aî erroò messagå anä abort® Tï geô arounä 
thió yoõ jusô assigî Aº tï á differenô phù drivå first¬ theî thå 
olä physicaì drivå caî bå reassigneä tï anù logicaì drive® Thå 
initiaì logical/physicaì assignmenô is:

     A: ½  1 (5.25" 48 tpi floppy drive with ds0 strapped)
     B: =  2 (5.25" 48 tpi floppy drive with ds1 strapped)
     C: =  3 (5.25" 96 tpi floppy drive with ds2 strapped)
     D: =  4 (8" floppy drive with ds3 strapped)
     E: =  5 (Ram disk)
     F: ½  ¶ (harä disë ° partitioî 0)
     Çº ½  · (harä disë ° partitioî 1)
     Hº ½  ¸ (harä disë ° partitioî 2)
     Iº ½  ¹ (harä disë ° partitioî 3)
     Jº ½ 1° (harä disë ° partitioî 4)
     Kº ½ 1± (harä disë ° partitioî 5)
     Lº ½ 1² (harä disë ° partitioî 6)
     Mº ½ 1³ (harä disë ° partitioî 7)
     Nº ½ 1´ (harä disë ° partitioî 8)
     Oº ½ 1µ (harä disë ° partitioî 9)
     Pº ½  ° (unassigned drive)
Š
.TC  IMP MODEM PROGRAM.................................PAGE #
                        IMP MODEM PROGRAM

Thå IMP24´ modeí prograí bù Irö Hofæ ió no÷ includeä witè thå 
system® Iô ió calleä IMPXLM1.COÍ anä haó alreadù beeî configureä 
tï uså siï channeì ± oî thå XL-M180® Yoõ caî useä thió IMĞ 
prograí tï downloaä thå IMP244.LBÒ librarù filå whicè ió 
availablå oî mosô Z-nodeó arounä thå country® Iô containó á 
detaileä .DOÃ filå anä utilitieó tï changå phonå numbers® Thå IMĞ 
prograí musô bå useä witè aî RS23² "AT¢ commanä seô modeí 
connecteä tï siï ch± (J8© througè á cablå witè pinó ± thrõ ¸ anä 
2° wireä piî foò pin® Yoõ musô seô thå strapó oî thå RS23² paddlå 
carä witè J³ tï Á anä J´ tï B® Piî 1± oæ thå 148¸ iã shoulä bå 
removeä froí it'ó sockeô oî thå paddlå board¬ otherwiså iô wilì 
drivå thå Carrieò Detecô outpuô linå oæ youò modeí anä possiblù 
blo÷ onå oæ thå ² chipó thaô woulä bå drivinç eacè other.‚ É havå 
verifieä thaô thió configuratioî oæ thå IMĞ prograí wilì worë 
witè á UÓ Roboticó Courieò modem® (Iæ yoõ don'ô havå á modeí yeô 
É stronglù recommenä thå Courier® Mosô RBBÓ systemó uså thå 
Courieò anä it'ó priceä lesó thaî mosô comparablå units.© Iæ yoõ 
havå á differenô branä oæ modeí yoõ maù havå tï makå somå 
changes® (Yoõ musô uså ZAS.COÍ tï reassemblå thå overlaù source® 
M8° ¦ L8° won'ô generatå á .HEØ filå thaô wilì properlù overlaù 
thå maiî IMĞ program.)

.TC  MOVE-IT OVERLAY...................................PAGE #
                         MOVE-IT OVERLAY

Aî overlaù filå nameä XLMOVIT1.HEØ ió includeä tï configurå thå 
MOVE-IT.COÍ veró 3.° computer/computeò filå transfeò prograí bù 
Woolæ Softwarå Systemó foò thå XL-M180® Á Zeø commanä filå ió 
alsï includeä tï perforí thå installation® Thå seriaì channeì oæ 
thå otheò computeò musô bå connecteä tï siï ch± oæ thå XL-M180® 
Looë aô iteí ¶ undeò Gettinç Starteä á fe÷ pageó bacë foò thå 
pinouô oî thå channeì ± RS23² paddlå card® Thå MOVE-IÔ prograí 
musô bå purchaseä froí Woolæ Software¬ buô iô ió indispensablå 
foò transferrinç fileó betweeî systemó witè incompatiblå disë 
formats.

.TC  DISCLAIMER........................................PAGE #
                           DISCLAIMER

Aó usuaì wå havå tï warî yoõ thaô yoõ musô accepô alì thå riskó 
witè thió software® Iô haó onlù haä á fe÷ dayó oæ testing¬ buô wå 
felô yoõ woulä ratheò geô á versioî no÷ thaô possiblù haó á fe÷ 
bugó oveò á versioî nexô montè thaô haó beeî fullù tested® Thå 
efforô thaô haó gonå intï thió wilì probablù neveò bå fullù 
compensateä financially¬ buô iô wilì bå morå thaî wortè whilå iæ á 
fe÷ morå peoplå arå ablå tï seå thå poweò thaô ió stilì availablå 
iî ¸ biô machines® É hopå thió versioî caî geô everyonå goinç 
tilì thå nexô releaså whicè wilì reallù sho÷ yoõ whaô thå HD6418° 
caî do!

.PAŠ.CW 24
USER'Ó GUIDÅ INDEX

.CW 10



Command Processor Commands, 1³   Memorù Bank Overview, 17            

Customization, 16                Minimum Hardware Requirements, 6    

                                 MOVE-IT Overlay, 22                 

Disclaimer, 22                                                       

Disk Assignments, 21             New Utilities, 16                   

                                                                     
Features, 4                      Overview, 3                         

Flow Command Package, 14                                             

Futurå Enhancements, 6           RAM DISK, 8                         

                                 Resident Command Package, 13        
Gettinç Started, 9                                                   

                                 S-100 INTERRUPTS, 20                

I/O Port Addresses, 20           STARTUP.COM Alias, 15               

IMP Modeí Program, 22            Supported Floppù Disë Formats, 7    

Input Output Package, 14                                             

IObyte, 9                        T-Function Calls, 19                

                                                                     
Limitations, 5                   ZCPR3, 13                           

                                 Zsystem Utilities, 15                                               




Trademarks:         Ú-SYSTEM¬ ZCPR3¬ ZRDOS¬ Echeloî Inc» 
                    TurboDOS¬ Softwarå 2000» HD64180¬ Hitachi» 
                    CP/M¬ Digitaì Researcè Inc» M80¬ MicroSoft» 
                    MOVE-IT¬ Woolæ Softwarå Systems.
