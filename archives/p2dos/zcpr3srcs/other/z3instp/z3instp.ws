.mt 6
.pl 60
.po 8     
.pn
                             Z3INStp
AUTO-INSTALLEÒ FOÒ TURBO-PASCAÌ PROGRAMÓ RUNNINÇ OÎ ZCPR³ SYSTEMS

;      Thió filå anä alì fileó iî thå LIBRARÙ calleä ZTP-INS2.LBÒ 
;      arå copyrighô 198µ bù Steveî M® Cohen¬ anä thereforå remaiî       
;      hió property®  Yoõ maù freelù distributå it¬ buô yoõ maù noô       
;      selì iô oò bundlå iô aó parô oæ anù packagå foò salå       
;      withouô thå expresó writteî consenô oæ thå author.

Introduction

     Lasô June¬ iî thå firsô blusè oæ mù enthusiasí foò ZCPR3¬ É 
releaseä á packagå calleä ZTP-INS.LBR®  Thaô packagå containeä a
Turbo-Pascaì prograí thaô installeä Videï controì sequenceó 
directlù froí ZCPR³ TCAPÓ (Terminaì Capabilitù Segments© intï 
otheò programó compileä bù Turbo-Pascal®  ZTP-INÓ waó noô á baä 
program¬ buô it'ó documentatioî waó florid¬ anä iô containeä 
severaì featureó thaô werå practicallù useless®  Worsô oæ all¬ iô 
containeä thå 1° oò sï Ë run-timå packagå thaô alì Turbo-Pascaì 
programó uså makinç foò á mucè biggeò prograí thaî waó necessarù 
foò sucè á simplå task.

     Thió package¬ containeä iî ZTP-INS2.LBÒ containó aî 
assembly-languagå versioî oæ thå olä program¬ calleä Z3INSTP.COM¬ 
whicè deleteó thå featureó thaô werå noô usefuì iî thå earlieò 
versioî anä addó á fe÷ ne÷ ones:

  1¾ thå abilitù tï turî ofæ highlightinç -- Somå programó maù be
     writteî oî systemó witè reduceä intensity®  Wheî theså arå      
     porteä tï systemó thaô havå inverså videï insteaä oæ reduceä      
     intensitù thå resultinç screenó actuallù looë worså thaî      
     theù woulä withouô anù highlighting®  Á simplå commanä line
     switcè allowó highlightinç tï bå turneä off.

  2¾ thå abilitù tï REVERSÅ higè anä lo÷ videï -- aó above¬ in
     somå cases¬ simplù reversinç whaô waó highlighteä anä what
     waó normaì wilì improvå thingó considerably®  Thió toï can
     bå selecteä oî thå commanä line.
.cp 6
  3¾ thå optioî tï instalì thå arro÷ keyó directlù intï thå      
     prograí foò anù prograí writteî tï takå advantagå oæ thió      
     capablility®  Thió schemå wilì worë foò anù terminaì that
     haó arro÷ keyó whicè generatå singlå bytes®  Thió optioî is
     alsï selectablå aô thå commanä line.
.cp7Š.heZ3INStp - Auto-installs Turbo-Pascal programs on ZCPR3 systems
  4¾ Z3INSTP.COÍ ió á ZCPR³ utilitù anä accesseó thå environmenô      
     descriptoò automatically¬ insteaä oæ needinç iô tï bå      
     specifieä oî thå commanä line®  Likå mosô Z³ utilities
     iô comeó witè it'ó owî built-iî helğ screen®  Z3INStp also
     giveó fulì controì oæ useò areaó witè Z3'ó DUº specification
     buô noô thå DIRº form.

Installinç Z3INStp

     Sincå Z3INSTP.COÍ ió á ZCPR³ utilitù iô musô bå installeä aó 
alì ZCPR³ utilitieó are¬ foò thå user'ó system®  Thå commanä linå 
foò thió ió thå usual:
                    
           Z3INÓ SYS.ENÖ Z3INSTP.COM

Z3INStp no÷ bå readù tï uså oî thå user'ó system.


Invokinç Z3INStp

     Z3INStp ió easilù invokeä froí thå commanä line®  Foò thå 
defaulô modå (withouô options© simplù type:

          Z3INSTĞ filenamå 

wherå filenamå ió thå namå oæ á .COÍ filå optionallù prefixeä 
witè á DUº (disk-user© specification®  E® G.

          Z3INSTĞ FATCAT
          Z3INSTĞ FATCAT.COM
          Z3INSTĞ B7:FATCAT.COM

.cp 6
Notå thaô thå .COÍ extensioî ió optionaì oî thå commanä line®  Iæ 
á filå oæ .COÍ typå ió noô found¬ aî erroò messagå wilì result®  
Iæ yoõ typå foò example

          Z3INSTĞ FATCAT.OBJ
 
thå prograí wilì looë onlù foò FATCAT.COM¬ abortinç iæ iô ió noô 
found¬ eveî iæ FATCAT.OBÊ ió present®  Iî otheò words¬ Z3INStp 
onlù installó .COÍ files.

Furthermore¬ Z3INStp checkó tï seå iæ thå specifieä filå waó 
compileä undeò Turbo-Pascaì (versioî 2.° oò higher)¬ agaiî 
abortinç iæ iô waó not®  Thió preventó againsô damaginç fileó 
whicè wilì noô worë witè theså installations.Š
Aó aî addeä measurå oæ safety¬ Z3INStp firsô renameó thå filå to
bå installeä witè thå namå filename.OLD¬ theî createó á ne÷ filå 
froí scratcè upoî whicè thå ne÷ installeä valueó arå placed®  Iæ 
foò somå reasoî Z3INStp fails¬ simplù renamå filename.OLÄ bacë to
filename.COM®  Iæ filename.OLÄ alreadù exists¬ yoõ arå querieä 
beforå thå olä copù ió deleted®  Betteò safå thaî sorry.

Options

Optionó arå selecteä oî thå commanä linå aó parameteró afteò the
filenamå ió typed®  Options¬ iæ any¬ arå combineä intï á single
"word¢ aó thå seconä commanä linå parameter:

          Z3INSTĞ FATCAÔ A
          Z3INSTĞ FATCAT.COÍ AR
          Z3INSTĞ FATCAÔ HA

Therå arå onlù ³ options:

optioî 'H'‚ - turnó ofæ highlightinç iî thå prograí beinç 
installed¬ aó describeä above®  Thaô ió thå prograí wilì run
aó thougè iô werå runninç oî á terminaì withouô highlighting.

optioî 'R'‚ - reverseó whaô ió highlighteä anä whaô ió not¬ aó 
describeä above®  Iæ thió optioî ió choseî togetheò witè the
'H§ option¬ theî iô wilì bå ignored®  

optioî 'A'‚ - installó thå arro÷ keyó aó describeä above®  Notå 
thaô foò thió optioî tï worë thå prograí documentatioî musô 
specifù thaô arro÷ keyó caî bå installeä thió way.‚  Aó oæ now¬ 
thå onlù prograí thaô caî bå installeä iî thió waù ió FATCAÔ bù 
thå authoò oæ Z3INStp®  Hopefully¬ otheò programmeró maù decidå 
thaô thió ió á usefuì ideá anä implemenô iô iî theiò programs®  
Also¬ arro÷ keyó musô bå installeä iî thå user'ó TCAĞ -- anä foò 
thió tï happen¬ thå arro÷ keyó musô generatå onlù single-
characteò sequences®  Mosô arro÷ keyó worë thió way¬ buô á fe÷ dï 
not®  However¬ noô tï worry®  Eveî iæ thå prograí yoõ arå 
installinç doeó noô supporô thió convention¬ iô doeó nï harm®  
Programmeró wishinç tï writå programó usinç Z3INStp shoulä 
consulô thå sectioî "Arro÷ Keù Programming¢ below.

Theorù oæ Z3INStp

     Z3INStp workó becauså botè ZCPR³ anä Turbï Pascaì codå theiò 
terminaì datá iî readilù accessiblå places®  Similaò setupó coulä Šbå workeä uğ foò anù prograí oò programminç languagå thaô useä á 
similaò methoä oæ accessinç terminaì data®  

     Aó neatlù aó Z3INStp workó iô ió importanô tï notå whaô iô 
CANNOÔ do®  Iô cannoô makå Turbï programó uså thå TCAĞ thå samå 
effortlesó waù zcpr³ utilitieó do®  Thaô is¬ iô caî onlù instalì 
programó tï specifiã TCAPs®  Iô ió easù tï reinstalì theså 
programó foò differenô TCAPó buô yoõ musô reinstalì foò eacè TCAĞ 
used®  Yoõ cannoô simplù LDÒ á ne÷ TCAĞ anä expecô youò prograí 
tï worë right.

     Thå reasoî foò thió ió simple®  Turbï anä ZCPR³ uså 
completelù differenô methodó oæ formattinç theiò terminaì data®  
Turbï useó thå fixeä lengtè strinç method¬ wherå eacè terminaì 
functioî caî bå founä aô specific¬ exacô locationó iî memory®  
Theså locationó arå thå samå foò everù Turbï prograí (aô leasô 
thoså undeò versionó 2.° anä 3.0)¬ anä indeed¬ foò TURBO.COÍ 
itself®  Further¬ theù follo÷ thå Turbo-Pascaì Strinç format¬ 
whereiî thå firsô bytå oæ thå strinç variablå ió thå actuaì 
lengtè oæ thå string®  ZCPR³ TCAPó uså thå "null-termination¢ 
methoä sï thå beginninç addresó oæ thå TCAĞ ió readilù available¬ 
otheró arå not®  Iô woulä bå possible¬ buô hardlù worthwhile¬ tï 
writå Turbo-Pascaì programó redefininç thå terminaì procedureó 
sucè thaô theù accesseä thå ZCPR³ locations.

     Therefore¬ wå caî besô seå Z3INStp aó á halfwaù houså 
betweeî totaì ZCPR3-utilitù videï compatibility¬ anä non-
compatibility®  Iô ió simplù á translatioî program®  Itó maiî uså 
aó É seå it¬ ió tï enablå ZCPR³ useró tï instalì Turbo-programó 
oî theiò terminaló withouô thå space-wastinç anä clumsù methodó 
oæ TINSÔ anä GINST¬ whicè amounô tï á duplicatioî oæ efforô afteò 
yoõ havå installeä youò TCAP®  Iô alsï ió á nicå demonstratioî oæ 
thå advantageó oæ ZCPR³ oveò CP/M® 

Weaknesseó oæ Z3INStp anä Futurå Directions

     Z3INStp wilì noô worë oî terminaló witè "non-fixed-lengtè 
ASCIÉ ¢ cursoò addressinç sequences®  Theså arå terminaló whicè 
uså thå "%d¢ iî theiò cursoò addressing®  Foò examplå thå H1¹ 
Terminaì ANSÉ mode¬ whoså ZCPR³ cursoò addressinç sequencå ió 
1BH,'[%d;%dH',0®  É cannoô finä anù sucè terminaì definitionó 
useä bù TURBO¬ sï haä nï poinô oæ reference®  É aí reasonablù 
surå thaô Z3INStp wilì worë oî terminaló witè "fixed-lengtè ASCIÉ 
addressing¢ buô havå noô trieä one¬ sï woulä appreciatå anù buç 
reportó oî thió aô thå "homå base¢ listeä below® (Seå chapter 22
oæ ZCPR³ - thå Manual“ iæ yoõ dï noô understanä thió paragraph.)Š     
.cp7
     Z3INStp haó á couplå oæ inherenô weaknesseó duå tï partiaì 
incompatibilitieó oæ ZCPR³ TCAPÓ witè Turbo-Pascaì terminaì 
definitions®  Specifically,

  TCAPÓ dï noô havå sequenceó foò Inserô Linå anä Deletå Linå 
(thå Turbï procedureó InsLinå anä DelLine)®  Luckily¬ theså arå 
probablù lesó useä thaî thå otheò terminaì functions®  É finä 
thaô É seldoí uså theí iî mù owî programming» theiò mosô frequenô 
uså seemó tï bå iî thå Turbï Editoò itself» here¬ Borland'ó 
programmeró havå beeî smarô enougè tï includå workaroundó foò 
terminaló noô supportinç theså functions¬ á practicå thaô otheró 
mighô wanô tï emulate.

     Nonetheless¬ iô woulä bå nicå tï bå ablå tï accesó theså 
functions®  Lookinç aô thå TCAPÓ thaô currentlù exist¬ iô woulä 
seeí tï bå easù tï adä theså functionó aô thå enä oæ thå TCAĞ aó 
theù alì seeí tï havå amplå spacå iî thå 12¸ bytå standarä 
allocation®  É wondeò whaô dï thå authoró oæ ZCPR³ thinë abouô 
extendinç thå TCAPÓ tï includå theså functions¿  
.cp7

     Thå otheò weaknesó iî thå concepô behinä Z3INStp haó largelù 
beeî largelù eliminateä witè thå arrow-keù installatioî procedurå 
describeä above®  However¬ thió createó somå otheò minoò 
difficultieó foò programmers¬ whicè É wilì no÷ attempô tï cleaò 
up.

Programmer'ó Guidå tï Arro÷ Keù Installation

     Iî designinç thå arrow-keù interface¬ thå followinç schemå 
suggesteä itself®  Thå Turbo-Pascaì Terminaì Namå strinç occupies
2± byteó iî memorù startinç aô 0153h®  Thå firsô bytå containó 
thå actuaì lengtè oæ thió string¬ sï therå ió á maximuí oæ 2° 
byteó availablå foò thå terminaì name®  Quitå bù accident¬ thå 
Turbï TCAĞ strinç holdinç thå terminaì namå occupieó á maximuí oæ 
1¶ bytes®  Thereforå wå havå fouò byteó availablå oî thå Turbo
Interfacå pagå (016´ - 0167h© thaô wilì almosô certainlù noô 
conflicô witè anything®  Theså fouò byteó arå noô useä iî anù waù 
oncå thå shorteò TCAĞ strinç ió overlaiä oveò thå originaì Turbï 
string®  Therefore¬ alì thaô ió needeä iî youò prograí tï allo÷ 
thå arro÷ keù optioî 'A§ tï worë ió thå followinç code:

       VAR
          UpArro÷                º Chaò absolutå $0164;
          DownArro÷              º Chaò absolutå $0165;
          RightArro÷             º Chaò absolutå $0166;Š          LeftArro÷              º Chaò absolutå $0167;

However¬ thió createó anotheò probleí iæ thå prograí wilì alsï bå 
ruî oî non-Z³ systems®  Foò thoså installationó somethinç similaò 
tï TINSÔ oò GINSÔ musô bå used¬ anä iî thaô caså characteró froí 
thå 2° characteò Turbï terminaì namå wilì filì theså spaces¬ witè 
thå possiblù unfortunatå consequencå thaô á printablå ASCIÉ 
characteò wilì bå interpreteä bù thå prograí aó aî arro÷ key®  
Thió caî bå cureä bù placinç thå followinç statemenô aô thå 
beginninç oæ thå program:

  Foò Ø :½ Addr(UpArrow© tï Addr(LeftArrow© do
    Iæ Mem[Xİ iî [32..127İ then
      Mem[Xİ :½ 0;

Iæ thå prograí haó beeî installeä bù á GINSÔ method¬ theså 
locationó wilì contaiî characteró iî thå 32..12· rangå anä wilì 
thuó bå converteä tï zeroeó iî memory®  Iæ therå ió á neeä iî 
youò prograí foò thå Terminaì name¬ iô caî bå copieä ouô oæ thió 
areá beforå thå abovå statemenô ió executed.

Otheò Possiblå Problems

     Turbo-Pascaì programmeró oughô tï enä theiò programó witè 
thå CRTExiô statement®  Thaô way¬ anù speciaì videï effectó caî 
bå turneä off¬ iæ thå useò includeó iî hió terminaì definitioî á 
CRTExiô strinç thaô returnó thå videï attributeó tï normal®  
Unfortunately¬ manù dï not.

     Iæ thå useò encounteró thió annoyance¬ hå shoulä redefinå 
thå TCAĞ tï includå aî exiô strinç thaô returnó hió videï tï thå 
normaì statå aó describeä above®  Then¬ iæ thå programmeò haó 
writteî hió prograí aó describeä iî thå lasô paragraph¬ aô exiô 
froí thå program¬ thå videï wilì bå normal®  Iô shoulä bå noteä 
thaô thå TCAPÓ supplieä bù Echelon¬ Inc® dï noô includå thió 
informatioî iî thå reseô strinç anä iô musô bå addeä witè TCMAKE.
.paŠConclusion

     Sourcå codå ió includeä iî thió library®  Feeì freå tï 
modifù it®  Therå ió certainlù rooí foò improvement®  However¬ 
thå authoò woulä likå tï seå whaô yoõ havå done®  Pleaså leavå 
anù messages¬ modifications¬ buç reports¬ etc® foò må oî Richarä 
Jacobson'ó LilliPutå ZNodå iî Chicago®  Thå phonå numbeò foò thió 
excellenô boarä ió 312-649-1730¬ anä yoõ maù leavå messageó therå 
withouô beinç á member®  However¬ aó É saiä iî thå earlieò 
version¬ hió $4° membershiğ feå ió á bargain.


                              Steve Cohen
                              Nov. 30, 1985



Turbo-Pascal is a trademark of Borland International, Inc.
