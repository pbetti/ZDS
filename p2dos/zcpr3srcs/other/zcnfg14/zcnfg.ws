









                            Ú Ã Î Æ G
             Ã Ï Î Æ É Ç Õ Ò Á Ô É Ï Î  Å Ä É Ô Ï R
                               FOR
                 ZCPÒ anä CP/Í EXECUTABLÅ FILES
                               by
                          A® E® HAWLEY























                        COPYRIGHÔ NOTICE
     ZCNFÇ anä itó documentatioî arå copyrighteä (C© 198¸ by
             A® E® Hawley® Alì rightó arå reserved.






                          A® E® Hawley
                       603² Charitoî Ave.
                     Loó Angeles¬ CA® 90056
 (213© 649-357µ (voice©     Laderá Z-node:(213© 670-946µ (modem)
.paŠ                   ZCNFÇ CONFIGURATIOÎ UTILITY

INTRODUCTION

ZCNFÇ   ió á universaì configuratioî utilitù foò  programó   likå 
ZMAC¬  MCOPY¬ BYE¬ ZFILER¬ anä manù others® Thå behavioò oæ  sucè 
programó ió designeä tï bå modifieä bù useró withouô  reassembly® 
Thió  ió  donå bù changinç datá aô knowî addresseó iî  thå  firsô 
pagå  oæ prograí code® ZCNFÇ performó thió editinç functioî iî  á 
particularlù convenienô way® Datá optionó  arå displayeä  iî  onå 
oò  morå  menus®  Thå currenô selectioî   foò   eacè  optioî   ió  
displayeä  aó parô oæ thå menõ  information® HELĞ screenó caî  bå 
invokeä foò assistancå iî selectinç options.

Thå  mosô commoî configuratioî optionó arå logicaì choiceó  baseä 
oî thå valuå oæ á bytå (zerï oò noî-zero)® Sucè choiceó appeaò iî 
thå  ZCNFÇ menõ aó 'YES§ oò 'NO§ (oò anù otheò seô oæ  termó  yoõ 
like)¬ anä maù bå toggleä wheî thaô menõ iteí ió selected®  ZCNFÇ 
readilù handleó thå followinç kindó oæ data:

       Logicaì togglå oæ anù biô iî á byte
       Changå thå valuå oæ á bytå witè display/entrù iî Decimal
       Changå thå valuå oæ á worä witè display/entrù iî Decimal
       Changå thå valuå oæ á bytå witè display/entrù iî HEX
       Changå thå valuå oæ á worä witè display/entrù iî HEX
       Replacå á strinç oæ ASCIÉ characters
       Replacå oò modifù á DÕ specificatioî
       Replacå oò modifù á Z3-stylå Filå Specificatioî

Aî acceptablå rangå foò numeriã valueó caî bå specifieä foò  eacè 
bytå oò worä value» valueó outsidå thaô rangå wilì noô bå entereä 
iî thå targeô program® Thå rangå ió displayeä foò eacè item® Thió 
ió  usefuì  foò entrù of¬ foò example¬ á buffeò sizå oò  á  ZCPR³ 
systeí filå number® Thå lasô twï arå usefuì foò editinç á defaulô 
filespec.

ZCNFÇ ió universaì becauså iô useó aî overlaù filå tï providå thå 
menõ layout(s)¬ Helğ screen(s)¬ anä datá specifyinç thå  locatioî 
anä  naturå  oæ  eacè  option® Aî  appropriatå  overlaù  musô  bå  
presenô  foò thå targeô program» ZCNFÇ loadó iô automaticallù  oò 
aó  á resulô oæ á commanä linå specification® Thå  generatioî  oæ 
overlayó ió discusseä belo÷ foò thoså whï wisè tï makå sucè fileó 
foò theiò owî use.

ZCNFÇ  ió á CP/Í compatiblå Ú-systeí utility® Iæ  ZCPR3/33/3´  ió 
present¬  theî ZCPÒ facilitieó arå useä tï takå advantagå oæ  thå 
TCAĞ anä nameä directories.

.paŠINVOCATION

Jusô  typå ZCNFG'ó namå tï geô á  helğ  screeî thaô explainó  ho÷ 
tï invokå ZCNFG® Anù forí oæ thå followinç invocatioî wilì work.

       ZCNFÇ   or   ZCNFG [/[/]İ       <== ? may replace the /

Tï  configurå  á  targeô filå wheî thå overlaù  filå  ió  oî  thå 
currentlù loggeä directory¬ use:

          ZCNFÇ <targeô filename>

Thió  examplå  implieó thaô thå namå oæ thå overlaù filå  ió  thå 
samå  aó thaô oæ thå targeô filå anä maù bå founä iî thå  currenô 
directory®  Thå  overlaù  maù alsï  bå  explicitlù  declared®  Aî 
expliciô  declaratioî takeó  precedencå  oveò  aî implieä one® Iæ 
thå DÕ portioî ió missing¬ theî thå defaulô directorù ió used® Iæ 
thå filetypå ió missing¬ theî á filetypå oæ .CFÇ ió assumed.

     Implied  filespecº    Explicit filespec: 

          ZCNFG  FÓ             ZCNFG  FS _ FS

     where:    FS = [DU: | DIR:][<filename>][.<filetype>]
       anä     underlinå (_© meanó space,tab¬ oò comma

Thå   firsô filespeã (FS© defineó thå targeô prograí thaô ió   tï 
bå configured® Thå seconä filespeã defineó thå associateä overlaù 
file® Aó implied¬ alì partó oæ botè specificationó arå  optional» 
iæ   everythinç  ió omitteä thå helğ screeî wilì  bå   displayed®  
Thå   defaulô  overlaù filetypå extensioî ió .CFG®  Yoõ  can¬  oæ 
course¬  uså  ZCNFÇ  tï changå itó owî  defaults»  CFÇ  coulä  bå 
changeä tï CNF¬ foò example.

Iæ thå configuratioî overlaù filå cannoô bå founä witè thå  specó 
supplied¬  theî thå searcè ió repeateä iî thå Alternatå DU®  Thaô 
directorù  ió  onå  oæ thå  configurablå  defaultó  withiî  ZCNFÇ 
itself®  Iæ  thå  overlaù filå ió stilì  noô  found¬  theî  ZCNFÇ 
attemptó  tï  obtaiî  thå namå oæ thå  overlaù  froí  thå  targeô 
programó  datá areá anä repeató thå searcè iî thå currenô anä  iî 
thå alternatå directories.

Thå  targeô prograí ió searcheä aô relativå locatioî  0DÈ  (righô 
afteò  thå Z3´ header© foò á legaì filå name® Uğ tï ¸  byteó  arå 
examined® Á possiblå filenamå wilì bå assumeä iæ iô ió terminateä 
witè  enougè  spaceó tï makå ¸ byteó oò iæ iô  ió  terminateä  bù 
null¬  $¬ oò Higè-biô-seô foò thå lasô character® Iæ  thå  strinç 
lookó likå á legaì filå name¬ iô ió takeî aó thå namå portioî  oæ 
thå  overlaù filespec.

Thå  objecô oæ thå abovå strategù ió tï permiô normaì  invocatioî 
witè aî implieä overlaù filespec® Iæ thå targeô prograí  containó 
thå  namå oæ itó overlaù filå aó described¬ thå overlaù  ió  verù 
likelù tï bå founä eveî iæ thå targeô prograí haó beeî renamed.
Š.pa
THE CONFIGURATION FILE

Thå configuratioî filå ió aî overlaù loadeä aô ruî timå bù ZCNFG® 
Thå  overlaù conventionallù haó thå samå namå aó thå filå  tï  bå 
configured¬ anä á filetypå oæ .CFG® Iô ió createä bù assemblù  oæ 
á  standarä Z8° sourcå filå tï producå á binarù image® Thå  aliaó 
MAKECFG.COÍ automateó thå procesó foò ZMAÃ anä ZMACLNK.Iô ió  noô 
necessarù  tï seô aî Origiî (ORG© iî thå sourcå filå becauså  thå 
imagå ió automaticallù relocateä durinç loadinç aô ruî time®  Thå 
relocatioî dependó oî thå initiaì MENÕ DATÁ beinç presenô aó  thå 
firsô codå producinç iteí iî thå sourcå file¬ aó describeä below® 

Thå Configuratioî Overlaù sourcå filå containó thå followinç maiî 
sections:

         DEFINITIONS
         MENÕ DATÁ STRUCTURE
         CASÅ TABLE(s)
         SCREEÎ IMAGE(s)
         DATÁ FOÒ ALTERNATÅ SCREEÎ IMAGÅ FIELDS
         HELĞ SCREEÎ DATA

Thå  sectionó arå discusseä below® Seå fileó likå *.SRÃ  iî  thió 
librarù foò implementatioî examples.

DEFINITIONS

Thió  sectioî defineó symboló anä macroó useä iî thå  balancå  oæ 
thå sourcå file® Functions¬ offsets¬ screeî locations¬ data¬  anä 
locaì datá addresseó arå symbolicallù defineä bù EQÕ  statements® 
Twï  macroó arå provideä iî thå examplå filå  MODELCFG.SRÃ  whicè 
greatlù simplifù thå constructioî oæ thå caså tables.

MENÕ DATÁ STRUCTURE

Thå firsô threå codå generatinç lineó iî thå filå MUSÔ be:

          RSÔ  0
          D×   MENUÁ     ;oò whateveò labeì yoõ uså foò menua:
menuaº    D×   LASTM,NEXTM,SCREENA,CASEA,HELPA

LASTÍ anä NEXTÍ arå pointeró iî á doublù linkeä circulaò queuå oæ 
recordó  likå thaô aô menua:® Therå ió onå recorä foò  eacè  menõ 
screeî displayeä bù ZCNFG® Iæ therå ió onlù onå menõ screeî  (thå 
caså  foò  manù targeô prograí implementations©  theî  LASTÍ  anä 
NEXTÍ wilì botè bå replaceä witè MENUA® Foò î menõ screens¬ addeä 
menõ recordó woulä bå required® Foò example,

menuaº    D×   menun,menui,SCREENa,CASEa,HELPa
          ....
menuiº    D×   menua,menun,SCREENi,CASEi,HELPi
          ....
menunº    D×   menui,menua,SCREENn,CASEn,HELPn

.cp 5ŠTherå  ió  nï requiremenô imposeä foò locatioî  oæ  menõ  recordó 
afteò thå firsô onå (menua)® ZCNFÇ findó thå MENUA recorä aô  thå 
specifieä offseô iî thå configuratioî overlaù (offseô ió 3)®  Anù 
otheró arå locateä througè thå linkó LASTÍ anä NEXTM.

Thå RSÔ ° instructioî ió presenô tï prevenô thió filå froí  beinç 
inadvertentlù executed® Á REÔ instructioî coulä alsï bå useä herå 
iî manù cases.

Thå  D×  statemenô containinç thå symboliã addresó oæ  thå  firsô 
menõ  recorä ió useä foò ruî-timå relocatioî oæ pointeró  iî  thå 
menõ recordó anä CASÅ tables.

CASÅ TABLE(s)

Therå  ió onå CASÅ tablå foò eacè menõ screen® Thå caså tablå  ió 
labeleä anä thå labeì ió aî entrù iî thå associateä menõ  record® 
Eacè caså tablå containó á serieó oæ recordsº onå recorä foò eacè 
configurablå  iteí  iî thå menõ display¬ anä onå  initiaì  ²-bytå 
entrù  whicè  specifieó  thå numbeò oæ recordó  presenô  anä  thå 
numbeò oæ byteó iî eacè record® Sincå variablå lengtè recordó arå 
noô  implementeä iî ZCNFG¬ thå recorä lengtè bytå ió alwayó  0AH® 
Herå ió thå structurå oæ eacè CASÅ record:

letterº   dó   ±    ;ASCIÉ codå foò thå menõ selector®
functionº dó   ²    ;1¶ biô functioî number
offsetº   dó   ²    ;1¶ biô offseô oæ confiç datá iî targeô pgm.
bdataº    dó   ±    ;¸ biô datá requireä bù function.
scrnlocº  dó   ²    ;1¶ biô addresó foò datá iî thå screeî image.
pdataº    dó   ²    ;1¶ biô addresó oæ datá requireä bù function.

Menõ itemó arå selecteä bù consolå inpuô oæ á visiblå  character¬ 
letter:® Typicaì entrieó foò letterº arå "dâ 'A'"¬ "dâ '1'"¬ etc.

'function:§  defineó onå oæ á seô oæ standarä modificationó  thaô 
caî bå madå tï datá iî thå targeô prograí configuratioî areá  anä 
tï  thå ZCNFÇ screeî display® Foò example¬ functioî °  toggleó  á 
biô iî á specifieä byte» thå associateä fielä iî thå menõ displaù 
maù  togglå betweeî 'YES§ anä 'NO'® Thå latteò arå stringó  whoså 
addresó  ió giveî aô 'pdata:'¬ sï yoõ havå controì oæ  whaô  ió 
displayed®  Iæ yoõ wished¬ thå displaù iî thió caså mighô bå  '1§ 
anä '0§ oò 'True§ anä 'False'.

namå:     function: useä for:

switcè       °      togglå biô <bdata¾ iî thå bytå aô <offset>
texô         ±      edit <bdata¾ characteró witè UÃ conversion
duspeã       ²      ediô á bytå paiò aó á DÕ specification
hexrad       ³      ediô á configuratioî bytå/worä iî HEX.
decrad       4      ediô á configuratioî byte/worä iî DECIMAL
textlã       µ      ediô <bdata¾ characters¬ botè UÃ anä LC
filesp       6      ediô á Z³ filespeã oò filespeã fragment
togl3        7      rotatå á biô iî thå ³ low bitó aô <offset>
togltf       8      togglå bytå aô <offset¾ betweeî ° anä 0ffH
Š.cp 6
'offset:§ specifieó thå relativå addresó oæ thå datá iteí iî  thå 
targeô  prograí  thaô  ió  tï  bå  configurablå  witè  thió  menõ 
selection® 'offset§ ió á worä (1¶ bit© quantity¬ eveî thougè  itó 
valuå maù bå limiteä tï thå rangå °-7fH.

bdata:„ ió á bytå whoså valuå implieó thå sizå oæ thå datá iî  thå 
configuratioî blocë anä ho÷ iô ió tï bå interpreted® Functionó  ± 
anä  5¬ foò example¬ requirå bdatá tï specifù thå lengtè  oæ  thå 
texô  fielä iî thå configuratioî block® ZCNFÇ wilì aborô  witè  á 
diagnostiã  erroò messagå iæ thå valuå oæ bdatá founä iî thå  CFÇ 
filå ió inappropriatå foò thå functioî specified.

namå:     function: 'bdata§ entrù required

switcè       °      biô positioî tï toggle¬ lsâ ½ 0¬ msâ ½ 7
texô         ±      numbeò oæ characteró tï replace
duspeã       ²      ° foò (A..Ğ)½(0..15)¬ ± foò (A..P)=(1..16)
hexraä       ³      ± foò byte¬ ² foò worä confiç data
decraä       ´      ± foò byte¬ ² foò worä confiç data
texôlc       5      numbeò oæ characteró tï edit
filesğ       ¶      0½ FN.FT¬ 1=Drive¬ 2=DU¬ 3=Fulì filespec
togl3        7      · ¨ ½ 00000111B)
togltf       8      ±  (onå bytå getó toggleä 00/ff)

'scrnloc:'„ ió thå addresó iî thå screeî imagå aô whicè thå  ASCIÉ 
representatioî oæ thå configuratioî datá foò thió menõ iteí ió tï 
bå displayed® Thió ió normallù á labeì iî thå screeî imagå sourcå 
describeä below.

'pdata:'„  ió thå addresó oæ datá useä bù á function® Somå oæ  thå 
functionó dï noô requirå thió data® Iî thoså instances¬ thå valuå 
entereä  iî  thió  fielä ió ignored¬ anä ió  normallù  0000®  Thå 
followinç tablå showó whaô eacè functioî requireó oæ thå  'pdata§ 
field.

namå:     function: 'pdata:§ entrù required
switcè       °      addresó oæ ² nulì terminateä strings
texô         ±      0
duspeã       ²      0
hexrad       ³      0 oò addresó oæ min/maø datá words
decrad       4      ° oò addresó oæ min/maø datá words
texôlc       5      0
filesğ       ¶      0
togl3        7      addresó oæ ³ nulì terminateä strings
togltf       8      addresó oæ ² nulì terminateä strings

Thå min/maø datá wordó arå á paiò oæ 1¶ biô valueó whicè  contaiî 
thå minimuí anä maximuí valueó alloweä foò thå currenô iteí beinç 
configured® Foò example¬ Z³ systeí filå numberó arå froí ± tï  4® 
Thå  datá provideä iî thå configuratioî filå foò thió caså  woulä 
be:

sfilmmº   DW   1,´       ;minimuí valuå first¡ Do NOÔ use DB!

.cp 5ŠSCRNLOÃ  anä PDATÁ arå addresseó withiî thå  configuratioî  file® 
Becauså  theù arå relocateä wheî thå overlaù ió loadeä bù  ZCNFG¬ 
theù  maù NOÔ designatå absolutå addresseó outsidå  thå  overlay® 
(Foò  PDATA¬ ° doeó noô specifù aî address® Iô meanó  thaô  therå 
arå nï limitó foò thió numeriã datá item.)
.CP 12
SCREEÎ IMAGE(s)

Thå  screeî imagå ió á seô oæ DÂ statementó thaô  specifù  enougè 
spaces¬  data¬  anä CR,LÆ characteró tï 'paint§ 1¸ lineó  oæ  thå 
screen® Thå otheò ¶ lineó oæ á 2´-linå screeî arå takeî uğ bù thå 
prompô  messagå  anä  useò responså lineó aô thå  bottoí  oæ  thå 
screen.

Thå firsô statemenô oæ thå screeî imagå ió labeled® Thaô labeì ió 
parô oæ thå MENÕ record¬ identifieä aó SCREENa¬ SCREENi¬ etc®  iî 
thå descriptioî oæ thå menõ recorä structurå above® Screeî imageó 
arå illustrateä iî thå samplå *.SRÃ files.

Thå 'data§ jusô mentioneä compriseó titles¬ borders¬ anä thå texô 
oæ menõ itemó thaô doeó noô change® Fieldó iî whicè  configurablå 
datá  ió tï bå displayeä arå filleä witè spaces® Sucè fieldó  arå 
usuallù  madå intï independenô labeleä DÂ statements®  Thå  labeì 
foò  sucè  á statemenô ió aî entrù iî thå caså  tablå  recorä  aó 
'scrnloc'.

Thå entirå screeî imagå ió terminateä bù á binarù zerï ¨ dâ °  oò 
itó  equivalent)®  Seå thå discussioî belo÷  undeò  'HELĞ  SCREEÎ 
DATA'.

TIPº  Don'ô forgeô tï puô thå menõ iteí selectioî  characteró  iî 
thå screeî imagå neaò thå datá tï bå referenced¡ Thió ió ho÷  thå 
useò kno÷s whicè keù tï presó foò á particulaò item..

DATÁ FOÒ SCREEÎ IMAGÅ FIELDS

Functionó 1¬ 2¬ 5¬ anä ¶ ignorå anù entrieó iî thå pdataº  field® 
Theù geô theiò datá froí thå keyboarä only.

Twï  kindó  oæ  datá structureó arå  referenceä  bù  pointeró  aô 
pdataº foò functionó 0¬ 3¬ 4¬ 7¬ anä 8®

Thå  firsô  typå ió composeä oæ DÂ statementó  thaô  definå  nulì 
terminateä  ASCIÉ  strings® Theså stringó appeaò iî thå  menõ  tï 
sho÷  thå  currenô statå oæ thå configuratioî iteí  addresseä  bù 
thió  caså tablå record® 'yndata§ iî thå *.SRÃ examplå  fileó  ió 
typical®  Notå  thaô  thå ordeò iî whicè  thå  stringó  occuò  ió 
importantº thå onå correspondinç tï 'true§ comeó first® Thió typå 
oæ datá ió requireä bù functionó 0¬ 7¬ anä 8.

Thå seconä typå ió á D× datá statemenô containinç twï words®  Thå 
firsô worä ió á minimuí valuå anä thå seconä ió á maximuí foò thå 
numeriã  datá  addresseä  bù thió case® Thió typå  ió  useä  witè 
functionó ³ anä ´ (HEØ anä DECimaì data)® Iæ thå POINTEÒ valuå iî 
pdataº  ió 0000è theî nï rangå checkinç wilì occur® Wheî  Min/Maø 
valueó  arå given¬ theù arå displayeä iî thå propeò radiø iî  thå Šprompô  line® Iæ thå useò attemptó tï enteò á valuå  outsidå  thå 
indicateä range¬ hió entrù ió ignored.

.cp 10ŠHELĞ SCREEÎ DATA

Helğ screenó arå accesseä viá thå '?§ oò '/§ aô thå menõ  prompt® 
Á  helğ  screeî  shoulä bå provideä foò eacè  menu¬  eveî  iæ  iô 
containó  nï morå thaî á 'helğ noô available§ message®  Thå  helğ 
screeî maù bå omitteä iæ á 0000è entrù ió madå iî thå MENÕ recorä 
(HELPa¬  HELPi¬ HELPn)® Thaô causeó ZCNFÇ tï ignorå helğ  requesô 
(¯ oò ?© froí thå menõ serveä bù thaô record.

Helğ  screenó are¬ likå screeî images¬ á blocë oæ  DÂ  statementó 
whicè definå thå texô tï bå displayed® Helğ screenó maù bå longeò 
thaî  2´ lines® ZCNFÇ countó lineó anä executeó á  displaù  pauså 
foò  eacè  screeî-fulì  oæ  text®  Yoõ  controì  thå  contenô  oæ 
successivå displayó bù addinç oò removinç linå feeä characteró iî 
thå DÂ statements.

Thå  entirå  blocë oæ ASCIÉ texô thaô compriseó á  HELĞ  display¬ 
whicè maù bå displayeä iî multiplå screens¬ ió terminateä witè  á 
binarù zerï (NOÔ á '$')® Thió conventioî permitó thå uså oæ thå ¤ 
characteò iî youò screeî displays® Sincå somå earlù configuratioî 
fileó  uså  thå  ¤ aó á terminator¬ ZCNFÇ maù  bå  configureä  tï 
recognizå thaô characteò aó thå terminator¬ ratheò thaî thå null® 
Sucè non-standarä configuratioî shoulä bå temporarù only.

Thå helğ screeî foò eacè menõ ió labeled® Thaô labeì ió aî  entrù 
(HELPa¬ etc.© iî thå associateä MENÕ record.

.paŠ