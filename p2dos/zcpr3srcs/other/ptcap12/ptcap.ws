                      PTCAĞ (PBBÓ TCAĞ Modifier)

Versioî 1.2    05/16/8·                              

     Wheî É firsô installeä PBBÓ anä deceideä tï uså thå TCAĞ support¬ 
É waó usinç thå latesô versioî oæ TCAP¬  versioî 1.9®  É waó tolä theî 
thaô wheî É upgradeä thå TCAP¬  É woulä havå tï manuallù changå alì oæ 
thå  entrieó  iî  mù useò baså tï reflecô thå  useró  propeò  terminaì 
selection®  Aô  thå  time¬  thió  diä  noô seeí likå thaô  mucè  oæ  á 
sacrafice®  Afteò  all¬  ho÷  manù useró caî  therå  be¿  Well¬  afteò 
installinç fivå ne÷ TCAP'ó anä upgradinç PBBÓ tï handlå á useò baså oæ 
40° users¬  É deceideä thaô somethinç haä tï bå donå tï facilitatå thå 
upgradå process® Thuó camå PTCAP.

     PTCAĞ  waó designeä tï completelù instalì á ne÷ TCAĞ withouô  thå 
neeä tï manuallù changå thå useò base® Iô wilì reaä thå ne÷ TCAĞ tï bå 
installeä  anä thå currenô TCAĞ intï memorù anä theî procesó thå  useò 
base® Thå useró recorä ió reaä iî anä thå olä terminaì indeø numbeò ió 
useä  tï finä thå olä terminaì iä string®  Thå ne÷ TCAĞ filå  ió  theî 
scanneä  foò á match®  Wheî á matcè ió found¬  thå ne÷ indeø numbeò ió 
calculateä anä placeä intï thå useò record®  ALÌ recordó arå processeä 
tï eliminatå thå risë oæ corruptinç thå useò index®  Processinç ió noô 
lightninç fast¬  buô thå joâ getó done®  Completå processinç oæ á  40° 
recorä  useò  baså  takeó lesó thaî ´ minutes®  Foò safetù reasons¬  á 
completelù ne÷ USEÒ filå ió createä calleä USERS.NEW®  Oncå  satisfieä 
thaô thå integritù oæ thå filå haó beeî maintained¬ yoõ jusô renamå iô 
tï  USERS.PBÓ  anä renamå thå ne÷ TCAĞ filå tï whateveò yoõ uså  aó  á 
defaulô name¬ anä yoõ arå readù tï go.

SYNTAX:

          PTCAĞ newfilå [oldfileİ [¯ oò ?]

          Newfilå  ió thå ne÷ TCAĞ filå yoõ wisè tï install®  Yoõ neeä 
          noô specifù thå extent¬ TCĞ ió thå defaulô extent.

          Oldfile¬  wheî specified¬  ió thå namå oæ thå currentlù useä 
          TCAĞ file® Iæ noô specified¬ á defaulô namå oæ Z3TCAP.TCĞ ió 
          used.
          
          Thå  '/§ anä '?§ arå optionaì anä botè invokå  thå  internaì 
          helğ features.

     Placå  thió prograí oî thå samå DÕ aó youò PBBÓ systeí files¬  oò 
iæ  usinç  ZCPR3.x¬  anywherå oî youò searcè path®  Thå  prograí  wilì 
automaticallù  loç intï thå DÕ yoõ havå specifieä aó thå systeí  drivå 
anä useò area® THESÅ VALUEÓ ARÅ DEFINEÄ INTERNALLÙ IÎ THIÓ PROGRAÍ ANÄ 
MUSÔ BÅ SEÔ FOÒ YOUÒ SYSTEM®  Yoõ wilì havå tï ediô thå sourcå codå tï 
suiô youò systeí needó anä reassemblå usinç M8° oò SLR180+®  Afteò thå 
assembly¬ yoõ wilì havå tï LINË witè SYSLIB36.REL.




ŠThe following commands should be used:

Assembly -     M80 =PTCAP12        using M80 or
               SLR180P PTCAP12/6   if using SLR180+

Link     -     L80 PTCAP12/P:100,SYSLIB36/S,Z3LIB13/S,PTCAP12/N/U/E
     
NOTE:          Yoõ  wilì  havå  tï  makå surå  thaô  SYSLIB36.REÌ  anä 
               Z3LIB13.REL are both in your working DU.


     Wheî  thå modificatioî ió completed¬  thå TCAĞ fileó wilì  remaiî 
unaltered®  Youò  originaì useò baså ió noô changeä anä thå  ne÷  filå 
necessarù ió createä iî thå samå disk/useò area®  Thå ne÷ useò baså ió 
calleä  USERS.NEW®   Renamå  youò  olä  USERS.PBÓ  tï  somethinç  likå 
USERS.OLÄ  theî renamå USERS.NE× tï USERS.PBS®  Thió wilì completå thå 
installatioî oæ thå ne÷ useò base®  Renamå youò currenô Z3TCAP.TCĞ  tï 
Z3TCAPxx.TCP¬  wherå  xø  ió thå versioî numbeò oæ thå previouó  file¬ 
theî renamå thå currenô versioî tï Z3TCAP.TCP®  Thió wilì completå thå 
installatioî oæ thå ne÷ TCAĞ file® Wheî yoõ havå completeä testinç thå 
ne÷  useò  baså anä TCAP¬  yoõ maù eraså thå USERS.OLÄ  filå  anä  thå 
Z3TCAPxx.TCĞ file.

     Thå  ne÷ useò fileó wilì contaiî ne÷ indeø numberó reflectinç thå 
samå terminaì selectionó useä iî thå previouó file® 

IMPORTANTº     Anù terminaló listeä iî thå olä filå thaô dï noô appeaò 
iî thå ne÷ listinç wilì bå updateä aó thougè thå useò diä noô  requesô 
á terminal®  Iî versionó 2.³ oò later¬ recorä ° specifieó thå terminaì 
iä strinç aó (Nonå requested).

     Iî  thió case¬  eitheò supporô foò thaô particulaò termainaì  haó 
beeî dropped¬  oò someonå haó changeä thå iä stringó iî thå files® Thå 
onlù  changeó  thaô  shoulä bå madå tï thå TCAĞ fileó  shoulä  bå  thå 
additioî  oæ  ne÷ terminals®  Nonå shoulä eveò bå droppeä anä  nï  onå 
shoulä  eveò  changå thå waù thå terminaló  arå  identified®  Althougè 
researcè  haó  proveî thaô somå terminaló havå actuallù  beeî  droppeä 
froí  thå listings®  Iî upgradinç froí versioî 2.° tï 2.³ alone¬  fouò 
terminaló havå beeî droppeä froí thå list® Wheî thió happens¬ thå useò 
wilì  jusô havå tï re-selecô his/heò terminaì oî theiò nexô  call®  Aô 
completion¬ thå prograí wilì selecô thå totaì numbeò oæ terminaló thaô 
havå  beeî  droppeä  froí  thå  list®   Thå  useró  affecteä  wilì  bå 
automaticallù  routeä  bacë througè thå terminaì selectioî procesó  oî 
their next call.

Iæ yoõ havå anù difficultieó oò suggestions¬  pleaså direcô theí tï må 
aô onå oæ thå numberó listeä belowº 

Accesó Programminç RAÓ   Cedaò Milló Z-Nodå 2´    Dallaó Connection
(503© 644-090°           (503© 644-4621           (214© 964-4356 
SYSOPº Terrù Pintï       SYSOPº Beî Greù          SYSOPº Rusó Pencin
(503© 646-493· Voice
6:00pí tï 10:00pí ONLY

Thanë yoõ foò youò supporô anä Happù Modeming.Š