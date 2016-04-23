







                              V T C A P  

                 Video Oriented TCAP Database Manager

                        Version 1.0 - 08/21/87








































Access Programming RAS - 14385 SW Walker Rd. B3 - Beaverton, OR  97006
Š





                  T A B L E   O F   C O N T E N T S


          Introduction ....................................  3
     
          Program Description .............................  4
     
               A - Add ....................................  5

               D - Delete .................................  5

               H - Help ...................................  6

               L - List ...................................  6

               M - Merge ..................................  6

               N - Next ...................................  7

               P - Previous ...............................  7

               S - Search .................................  7

               U - Update .................................  8

               Z - Z3 Load ................................  8

               X - Exit ...................................  8

          Appendix A - TCAP File Description ..............  9

          Appendix B - Program Listings ................... 12
















Š                             Introduction


     VTCAĞ ió á videï orienteä databaså manageò designeä  specificallù 
tï  manipulatå thå Terminaì CAPabilitieó (TCAP©  database®  Currently¬ 
thå onlù waù tï modifù oò adä terminaló tï aî existinç TCAĞ ió tï ediô 
thå sourcå codå anä reassemblå thå code®  Thió ió aî unfaiò limitatioî 
tï  thoså whoså abilitieó witè assembleò arå limiteä oò  non-existant® 
Eveî thoså oæ uó witè assembleò ability¬  musô resorô tï 'patching§ oò 
re-assembling to just experiment with different terminal codes.

     Aó  á sysoğ runninç ZCPR3/ZRDOÓ witè BYE51° anä PBBS¬  É waó verù 
interesteä iî thå growinç supporô oæ TCAP® Bù givinç thå ordinarù useò 
á  methoä witè whicè tï experimenô witè TCAĞ listingó anä adä  supporô 
foò  terminaló oæ hió choice¬  É hopå tï puô TCAĞ supporô oî morå  anä 
morå  systems®  Thå besô waù tï accomplisè thió ió tï supplù thå  useò 
witè  softwarå thaô wilì makå supportinç sucè ideaó easier®  VTCAĞ  ió 
jusô onå oæ á fe÷ softwarå packageó availablå foò thió purpose®  Otheò 
such programs now available, or currently under development are,



PTCAP - TCAP installation package for PBBS systems     AVAILABLE NOW

VTCAP - TCAP database manager                          AVAILABLE NOW

PCAP  - Printer capabilities package               UNDER DEVELOPMENT

PLIB  - Printer support library                    UNDER DEVELOPMENT

GCAP  - Graphics capabilities package              UNDER DEVELOPMENT

GLIB  - Graphics support library                   UNDER DEVELOPMENT


Future of VTCAP

     Support for both printer and graphics packages when released.

     Prinô  functioî  foò hardcopù printouô oæ individuaì terminaì  iî 
     databaså oò á lisô oæ alì terminals.

     Additioî oæ á tesô modulå thaô displayó thå effectó oæ thå choseî 
     display attributes

     Installatioî  functioî  thaô wilì actuallù instalì youò  selecteä 
     TCAP in your system environment.







Š                 V T C A P - T C A P   M A N A G E R

                         Program Description



     Thå  basiã functioî oæ thió prograí ió tï providå thå manù  useró 
oæ  thå Z³ systemó anä Terminaì CAPabilitù fileó (TCAP's© á methoä  tï 
easilù  modifù thå TCAĞ fileó oî theiò systems®  TCAĞ Manageò  (VTCAP© 
gives you the following: 

     1.   Adä  á terminaì tï thå database
     2.   Deletå á terminal
     3.   Searcè foò á requesteä terminal
     4.   Scaî forwarä oò backwarä througè thå listings
     5.   Updatå  thå currentlù displayeä terminal
     6.   Lisô alì oæ  thå terminaló iî thå database
     7.   Mergå twï TCAĞ fileó 
     8.   Switch between Z3TCAP files
     9.   Provideó yoõ witè completå  on-linå helğ foò alì functions

     Thå distributioî librarù filå containó alì oæ thå fileó necessarù 
tï  completelù  assemblå  anä linë VTCAP®  Thió ió  á  videï  orienteä 
routinå anä requireó certaiî informatioî about your system.

     Thió  prograí  ió  offereä  intï thå publiã  domaiî  anä  maù  bå 
redistributeä withouô permission® VTCAĞ ió thå solå propertù oæ Accesó 
Programminç  RAÓ  anä  cannoô  bå solä  seperatelù  oò  packageä  witè 
productó aó aî incentivå tï purchaså withouô prioò writteî  permissioî 
froí  thå author®  Anù suggestionó oò modificationó shoulä bå directeä 
tï  må  personallù  aô  thå systeí below®  Wå  wilì  NOÔ  supporô  anù 
modificationó  thaô  havå  noô beeî previouslù  cleareä  througè  thió 
system.











Access Programming RAS
14385 SW Walker Rd. B3
Beaverton, OR  97006

Terry Pinto - Owner/SYSOP

(503) 646-4937  VOICE
(503) 644-0900  (300/1200 baud - 24 hours/day)


Š
     ADD

     Thå  adä functioî wilì allo÷ thå useò tï adä additionaì  terminaì 
listingó tï thå database®  Wheî yoõ enteò thå ADÄ mode¬  thå datá wilì 
bå cleareä froí thå displaù givinç yoõ á 'blank§ recorä tï worë  with® 
Aô  thió timå yoõ maù enteò thå information®  

     Therå arå threå typeó oæ fieldó iî whicè yoõ maù enteò data®  Thå 
firsô  oæ whicè ió thå fixeä lengtè string®  Thå onlù fielä thaô  useó 
thió  entrù methoä ió thå terminaì name®  Yoõ arå limiteä tï entrù  oæ 
sixteeî characters®  Iæ yoõ makå á mistake¬  yoõ maù uså thå backspacå 
tï repositioî thå cursoò iî thå field®  Wheî entrù ió complete¬  presó 
<ENTER¾  tï  terminatå thå field®  Thió wilì automaticallù  eraså  anù 
characteró  tï  thå  righô  oæ thå  cursoò  effectivelù  clearinç  thå 
remainder of the field.

     Thå  seconä  typå oæ entrù ió thå singlå character®  Alì  oæ  thå 
arro÷ keyó anä screeî delayó arå representeä bù thió type®  Thió fielä 
ió automaticallù terminateä wheî yoõ enteò á characteò anä thå  cursoò 
wilì  bå advanceä tï thå nexô field®  Iæ yoõ makå á mistake¬  jusô uså 
the arrow key to reposition the cursor. 

     Thå thirä typå ió thå variablå lengtè string®  Alì oæ thå  screeî 
controì  stringó arå formatteä witè thió typå oæ input®  Durinç input¬ 
yoõ  maù uså thå backspacå tï correcô mistakes®  Pressinç thå  <ENTER¾ 
keù wilì terminatå inpuô oæ thå fielä anä advancå tï thå next® Tï skiğ 
á  field¬  jusô enteò á carriagå return®  REMEMBER¬   THÅ ENTRÙ  OÆ  Á 
CARRIAGE RETURN WILL ERASE THE REMAINDER OF THE FIELD.

     Wheî yoõ exiô froí thå ADÄ mode¬  yoõ wilì bå prompteä tï enteò á 
ne÷ versioî number®  Uså anù twï digiô numbeò iî thå followinç format® 
   
     Version Number:  2.7     [major.minor]
     
     Anytimå yoõ makå anù changeó tï thå database¬  increaså thå minoò 
revisioî numbeò bù one.


     DELETE

     Thå  deletå functioî ió á togglå anä wilì allo÷ yoõ tï  'mark§  á 
recorä  foò  deletion®  Wheî sï marked¬  thå datá iî thå  recorä  wilì 
appeaò  iî thå standouô modå anä thå worä 'DELETED§ wilì appeaò aô thå 
toğ oæ thå screen®  Oncå á recorä haó beeî markeä foò deletion¬ iô maù 
bå  reclaimeä bù usinç thå samå function®  Thå firsô timå thå  [Dİ  ió 
pressed¬  thå  recorä wilì bå markeä foò deletion¬  thå nexô time¬  iô 
wilì bå reinstated®  Thå markeä recordó arå noô deleteä untiì yoõ exiô 
thå database®  Aô thaô timå yoõ wilì bå prompteä foò á versioî number® 
Use the same proceedure as outlined above.




Š     HELP

     Thå helğ functioî wilì providå yoõ witè on-linå helğ oæ alì modeó 
oæ operatioî iî thå program® Bù pressinç [H]¬ yoõ caî geô thå firsô oæ 
thå  HELĞ  screens®  Thió  screeî wilì presenô yoõ witè  helğ  oî  thå 
commanä  linå  syntaø  oæ  thå program®  Yoõ maù invokå  mosô  oæ  thå 
operationó oæ thå prograí froí thå ZCPR³ commanä linå bù specifinç thå 
appropriatå  option®  Alì oæ thå informatioî yoõ wilì neeä oî  ho÷  tï 
accomplisè  thió  ió displayeä oî thió screen®  Aô thå bottoí  oæ  thå 
display¬ yoõ wilì seå á prompô tï selecô thå topiã yoõ wisè helğ with® 
Alì  oæ  thå topicó arå representeä bù á /o®  Tï requesô helğ  witè  á 
particulaò topic¬  jusô presó thå characteò afteò thå /® Foò instance¬ 
the help function is shown as follows:

     /H - Help

     Tï  selecô  helğ witè thå helğ functions¬  jusô presó H®  Iæ  yoõ 
presó á keù thaô ió noô supported¬  aî erroò messagå wilì bå displayeä 
oî thå screen® Wheî yoõ selecô á topic¬ thå informatioî requesteä wilì 
bå  displayeä  oî  thå  lasô fivå lineó oæ  thå  displaù  leavinç  thå 
originaì helğ screen®  Theså bottoí fivå lineó wilì acô likå á  windo÷ 
displayinç  thå requireä informatioî wheî needed®  Tï exiô bacë tï thå 
database, just press [X].


     LIST

     Thå lisô functioî wilì displaù alì oæ thå terminaló currentlù  iî 
thå database® Theù wilì bå displayeä iî thå ordeò iî whicè theù appeaò 
iî  thå file®  Eacè screeî wilì displaù uğ tï eightù terminaló iî fouò 
columnó  oæ  twenty®  Anù deleteä terminaló wilì bå displayeä  iî  thå 
standouô mode®  Iæ therå arå eightù terminaló oò lesó yoõ wilì seå thå 
entirå  databaså oî onå screeî witè thå [Strikå anù keyİ prompô aô thå 
bottom®  Iæ  therå arå morå thaî eightù terminals¬  thå  displaù  wilì 
pauså aô eightù anä displaù thå [moreİ prompt®  Herå yoõ maù presó anù 
keù tï seå uğ tï eightù morå listings.


     MERGE

     Thió ió á verù powerfuì function®  Iô wilì allo÷ yoõ tï creatå  á 
TCAĞ filå containinç alì oæ thå uniquå listingó iî twï files®  Thå twï 
fileó beinç thå defaulô TCAĞ filå (Z3TCAP.TCP© anä thå filå  specifieä 
oî  thå commanä linå oò loadeä witè thå 'Z§ optioî withiî  VTCAP®  Thå 
twï  fileó arå compareä anä alì oæ thå uniquå listingó arå writteî  tï 
aî outpuô file¬  Z3TCAPxx.TCP¬ wherå xø ió thå versioî numbeò thå useò 
supplieó aô thå beginninç oæ thå mergå process® Yoõ wilì wanô tï checë 
oveò  thå listingó verù carefullù aó onlù thå indeø namå ió  compared® 
Iæ  someonå changeó thå indeø namå iî onå file¬  yoõ wilì enä uğ  witè 
twï seperatå listingó foò thå samå terminal® Á gooä examplå oæ thió ió 
obtaineä  bù  merginç Z3TCAP2³ witè Z3TCAP20®  Thå mergå oæ theså  twï 
fileó  contaiî twï listingó eacè foò thå HEATÈ terminals¬  botè  Heatè 


Šanä  ANSÉ  modes®  Thå listinç foò thå Generaì Terminaì  10°  ió  alsï 
duplicated®  Carefuì  checkinç oæ thå outpuô filå ió á smalì pricå  tï 
paù  foò thå poweò oæ thå mergå function®  Yoõ maù alwayó gï iî  lateò 
with the delete mode and take care of any duplication.

     Thå  mergå procesó iî verù compleø iî naturå anä haó beeî greatlù 
simplifieä iî thå descriptioî above®  Seå thå descriptioî oæ thå  TCAĞ 
filå  anä  thå  technicaì descriptioî oæ thå prograí  moduleó  iî  thå 
appropriatå  appendicieó  foò  á  morå  completå  descriptioî  oæ  thå 
operation of this and other functions.


     NEXT

     Thió  functioî wilì repositioî thå databaså tï thå nexô recorä iî 
thå  database®  Nï indeø filå ió useä thereforå thå steppinç  ió  donå 
sequentially®  Thå recordó arå alphabetizeä anä thereforå shoulä bå iî 
'indexed' order.


     PREVIOUS

     Thió  ió thå oppositå oæ thå abovå functioî anä wilì positioî thå 
databaså tï thå recorä beforå thå onå currentlù displayed®  Again¬ thå 
stepping is done sequentially through an alphabetized listing.


     SEARCH
     
     Thå  searcè  functioî  ió  useä tï locatå anù  desireä  entrù  iî 
database®  Wheî enterinç thå searcè mode¬ yoõ wilì bå prompteä foò thå 
namå oæ thå terminaì tï searcè for® Thå prograí wilì determinå betweeî 
uppeò anä loweò caså, sï bå exacô wheî specifinç thå searcè criteria.

                APPLE /// is not the same as Apple ///

     Iæ  yoõ requesô á namå thaô ió noô iî thå database¬  yoõ wilì  bå 
giveî  aî  erroò messagå and¬  afteò á shorô delay¬  returneä  tï  thå 
'Enteò Filenameº § prompt® Iæ thå searcè ió sucessful¬ thå searcè modå 
wilì  bå  terminateä anä yoõ wilì bå returneä tï thå commanä  modå  oæ 
VTCAP®  Thå  namå entereä musô bå identicaì tï thå namå iî  thå  indeø 
sectioî  oæ  thå databaså (seå thå sectioî oî thå descriptioî  oæ  thå 
TCAĞ files)® Iæ yoõ arå unsurå oæ thå spellinç oò thå waù thå terminaì 
ió  described¬  uså thå lisô functioî tï displaù thå terminaló iî  thå 
database®  Oncå yoõ havå locateä á terminal¬  yoõ maù scaî througè thå 
databaså bù usinç thå [P]reviouó anä [N]exô commands.








Š
     UPDATE

     Thå  updatå  functioî  ió verù similaò iî operatioî  tï  thå  adä 
function®  Oncå yoõ havå selecteä thå terminaì yoõ wanô tï update¬ yoõ 
selecô  [Uİ  anä  thå cursoò ió placeä oî thå firsô characteò  oæ  thå 
firsô fielä iî thå record®  Thå <ENTER¾ keù wilì terminatå fielä inpuô 
anä advancå thå cursoò tï thå nexô field® Alì informatioî tï thå righô 
oæ thå cursor¬  iî thå currenô field¬  wilì bå losô wheî yoõ terminatå 
thå field®  Tï writå thå datá tï thå databaså uså '^W'® Iæ yoõ wisè tï 
aborô thå currenô update¬  presó '^Q'® Thå updatå modå wilì noô prompô 
foò thå entrù oæ á versioî number®  Iô ió assumeä thaô thió modå  wilì 
bå  useä morå foò experimentatioî anä correctinç oæ typinç erroró  anä 
thereforå  wilì noô requirå thå generatioî oæ á higheò versioî number® 
Iæ yoõ feeì thå neeä tï issuå á versioî numbeò foò aî updateä listing¬ 
you may rename the file externally.


     Z3 LOAD

     Thå  Z³  Loaä  functioî ió useä tï exiô  onå  databaså  anä  loaä 
another® Yoõ wilì bå prompteä foò thå namå oæ thå databaså yoõ wisè tï 
read®  DÏ  NOÔ TYPÅ THÅ FILÅ EXTENT®  Alì fileó shoulä bå oæ thå  forí 
Z3TCAPxx¬  wherå xø ió thå versioî numbeò oæ thå filå tï bå loaded® Iæ 
yoõ requesô á filå thaô doeó noô exist¬  yoõ seå aî erroò message¬ anä 
yoõ wilì bå returneä tï thå 'Enteò Filenameº  § prompô allowinç yoõ tï 
trù agian®  Iæ youò requesô ió sucessful¬  yoõ wilì bå returneä tï thå 
VTCAĞ  commanä level®  Tï canceì thå filenamå entry¬  enteò á carriagå 
return and the default Z3TCAP file will be loaded.

     Exit

     Thió commanä ió selæ explanitory®  Alì opeî fileó wilì bå closed¬ 
alì  disë  housekeepinç wilì bå completeä anä yoõ wilì bå returneä  tï 
the operating system level, exiting the program.



















Š 

                              Appendix A   

                        TCAP File Description


     Tï understanä thå operatioî oæ VTCAP¬  yoõ musô firsô  understanä 
the TCAP file and how it is constructed.

     Thå  TCAĞ  filå  consistó  oæ twï sections¬  thå  indeø  anä  thå 
database® 

     Thå  indeø sectioî containó thå nameó oæ alì oæ thå terminaló  iî 
thå database®  Alì sortinç anä searchinç ió donå relativå tï thå nameó 
iî  thå indeø section®  Eacè terminaì namå ió sixteeî byteó iî  lengtè 
anä  eighô nameó wilì occupù onå physicaì recorä iî thå file®  Iæ  thå 
terminaì nameó dï noô completelù filì thå record¬ thå remaindeò oæ thå 
recorä wilì bå filleä witè 0's®  Thå terminaì nameó arå entereä iî thå 
databaså  iî alphabeticaì ordeò thuó negatinç thå neeä  foò  elaboratå 
indeø  files®  Eacè  terminaì  namå ió paddeä witè blankó  tï  sixteeî 
characters®  Thå  followinç  wilì illustratå thå constructioî  oæ  thå 
indeø sectioî oæ TCAĞ files.

+---------------------------------------------+    +--------------+
00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F    0123456789ABCDEF

57 59 53 45 20 31 30 30 20 20 20 20 20 20 20 20    WYSE 100        
58 65 72 6F 78 20 38 32 30 2D 49 20 20 20 20 20    Xerox 820-I  
58 65 72 6F 78 20 38 32 30 2D 49 49 20 20 20 20    Xerox 820-II   
58 65 72 6F 78 20 38 2D 31 36 20 20 20 20 20 20    Xerox 8-16    
20 32 22 36 20 20 20 20 20 20 20 20 20 20 20 20     2.6           
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    ................
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    ................
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00    ................
+---------------------------------------------+    +--------------+

Noticå  thaô  eacè entrù takeó thå entirå sixteeî byteó  anä  thaô  nï 
terminatoò  ió useä tï indicatå thå enä oæ thå string®  Thå lasô entrù 
iî  thå  filå  ió  thå indeø entrù  foò  thå  versioî  number®  Iô  ió 
recognizeä bù thå facô thaô thå firsô characteò iî thå fielä ió blank® 
Thió  ió thå onlù recorä thaô beginó witè á blanë character®  Thå nexô 
threå  byteó  denotå thå versioî number®  Thå resô oæ  thaô  fielä  ió 
paddeä  witè  blanks®  Thå remaindeò oæ thå physicaì recorä ió  filleä 
witè  binarù  0's®  Thå  firsô  oæ theså zero'ó servå  aó  thå  strinç 
terminatoò foò thå indeø file®  Thuó thå entirå indeø filå ió  treateä 
aó onå lonç strinç terminateä bù á binarù 0.







Š

     Thå nexô sectioî ió thå database®  Eacè 12¸ bytå physicaì  recorä 
representó  onå terminaì entry®  Thå followinç fielä structurå defineó 
the database section.

     Terminal Name  16 bytes
     Up Arrow        1 byte
     Down Arrow      1 byte
     Left Arrow      1 byte
     Right Arrow     1 byte
     CLS Delay       1 byte
     DCA Delay       1 byte
     EOL Delay       1 byte
     Clear Screen    Variable Length --+
     Dir Cur Pstn    Variable Length   |
     Erase EOL       Variable Length   |
     Begiî Standouô  Variablå Lengtè   |--¾ Total =< 105 Bytes
     End Standout    Variable Length   |
     Terminal Init   Variable Length   |
     Term De-Init    Variable Length --+

     Thå  terminaì namå ió thå onlù fielä thaô ió NOÔ terminateä bù  á 
binarù  0®  Alì  otheò fieldó arå terminated®  Iæ á serieó  oæ  zero'ó 
exist¬ easè wilì represenô á fielä entry® Thå followinç examplå oæ thå 
Televideo 950 terminal should help to clarify.

00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F   0123456789ABCDEF

54 56 49 39 35 30 20 20 20 20 20 20 20 20 20 20   TVI950
0B 16 0C 08 32 00 00 1B 2A 00 1B 3D 25 2B 20 25   ....2...*..=%+ %
2B 20 00 1B 74 00 1B 29 00 1B 28 00 00 00 00 00   + ..t..)..(.....
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................ 
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................ 
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................

The following should help to translate the code.

54 56 49 39 35 30 20 20 20 20 20 20 20 20 20 20   TVI950
T  V  I  9  5  0  

0B 16 0C 08 32 00 00 1B 2A 00 1B 3D 25 2B 20 25   ....2...*..=%+ %
| Arrows  | |Delays| | CLS  | | Direct Cursor
^K ^V ^L ^H |2ms dl| | ESC* | | ESC=%+ %+ 
+---------+ +------+ +------+ +----------------

2B 20 00 1B 74 00 1B 29 00 1B 28 00 00 00 00 00   + ..t..)..(.....
Addr   | | EOL  | |Beg SO| |End SO| TI TD
       | | ESCt | |ESC)  | |ESC(  | |  +- No De-initialization 
-------+ +------+ +------+ +------+ +---- No Initialization


Š
Thå  lasô databaså entrù ió thå versioî number®  Onå entirå recorä  ió 
reserveä  foò  thió entry®  Iô appearó thå samå aó thå  indeø  sectioî 
entry®  Thå firsô sixteeî byteó arå reserveä foò thå 'name'¬  whicè iî 
thió caså wilì bå thå versioî numbeò preceedeä bù onå blanë anä paddeä 
tï filì thå sixteeî bytå namå field®  Thå resô oæ thå recorä ió filleä 
witè á binarù 0®  Iô ió importanô tï notå thaô thå firsô recorä iî thå 
datá  sectioî  alwayó beginó oî á recorä boundary®  Thió ió  importanô 
becauså  iô  ió  thå basió oæ thå calculationó useä  tï  positioî  thå 
record pointer within the database.











































