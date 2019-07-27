.he   ZXLATE - 8080 TO Z80 SOURCE CODE TRANSLATOR                            #


                ZXLATE - AN 8080 TO Z80 SOURCE CODE TRANSLATOR
                     Copyright (c) 1986 by G. Benson Grey
                        All Rights Reserved, Worldwide

    ZXLATÅ  ió  aî 808° tï Z8° Sourcå Codå Translatoò iî thå  traditioî  oæ 
    Richarä  Conn'ó  ZXLATE² anä Franë Zerilli'ó XLATE10´ anä ió  á  direcô 
    descendanô  froí  thå twï programs®  Thió versioî haó beeî  labeleä  aó 
    Versioî  1¬  Revisioî ± sincå iô waó completelù re-writteî iî Z8° code® 
    Iî addition¬ iô ió designeä tï operatå oî systemó whicè utilizå Richarä 
    Conn'ó exceptionaì commanä processoò replacement¬  ZCPR3® ZXLATÅ relieó 
    oî ZCPR3'ó SYSLIB3¬  VLIÂ anä Z3LIÂ relocatablå libraries®  Iô musô  bå 
    assembleä   usinç   M8°  (oò  equivalent©  anä  linkeä  witè  L8°   (oò 
    equivalent).

    ZXLATÅ  ió largelù á completå re-writå oæ Franë  Zerilli'ó  XLATE®  Thå 
    defaulô locationó werå removeä froí thå fronô oæ thå prograí aó eacè oæ 
    thå  optionó haó á manuaì overridå froí thå commanä line®  ZXLATÅ haó á 
    varietù  oæ  optionó  whicè  arå useä tï  controì  thå  translatioî  oæ 
    programs.

    Thå  optionó definå sucè thingó aó whetheò multiplå commandó  separateä 
    bù  Digitaì Research'ó ¡  separatoò shoulä bå outpuô oî separatå  lineó 
    (default©  oò  lefô intact»  iæ opcodeó shoulä bå followeä bù  á  spacå 
    (20H© oò á taâ (09È default)»  whaô columî tï aligî commentó iî (4±  ió 
    thå  default)»  anä  whetheò  tï  translatå  speciaì  TDÌ  opcodeó  (nï 
    translatå  default)»  translatå DÂ anä EQÕ (nï translatå default)»  anä 
    whetheò  tï  translatå  thå "standarä Z80.LIB¢ macroó  tï  Z8°  opcodeó 
    (default).

    The standard command line syntax for invoking ZXLATE is:

            ZXLATE [du:]filename.typ [du:filename.typ] / [options]

    Itemó  encloså iî squarå bracketó arå optional®  Thå spacå betweeî  thå 
    filename.tyğ  anä separatoò anä betweeî thå separatoò anä  thå  optionó 
    arå  required®  Thå duº  refeò tï thå standarä ZCPÒ systeí oæ disë  anä 
    useò  specificationó followeä bù á colon®  Thå onlù iteí whicè musô  bå 
    specifieä ió thå sourcå filename®  Thå filetype¬ iæ omitted¬ ió assumeä 
    tï  bå .ASM®  Iæ thå destinatioî filename.tyğ ió noô specified®  ZXLATÅ 
    wilì creatå aî outpuô filå oæ du:filename.Z80¬ wherå du:filenamå ió thå 
    samå aó thå sourcå file® Iæ thå destinatioî filå ió specified¬ anù parô 
    of the filename specification may be given. A typical example is:

                ZXLATE B1:SOURCE.ASM A0:DESTIN.MAC / E U M C=33

    wherå  B1:SOURCE.ASÍ  ió thå inpuô file»  A0:DESTIN.MAÃ ió  thå  outpuô 
    file»  TDÌ extendeä mneumonicó wilì bå translated»  labels¬ opcodeó anä 
    operandó  wilì bå translateä tï uppeò case»  .Z8° anä  ASEÇ  statementó 
    wilì  bå  outpuô  tï  thå beginninç  oæ  A0:DESTIN.MAÃ  file»  multiplå 
    commandó oî onå linå wilì bå translateä tï commandó oî separatå  lines» 
    and comments will be aligned in column 33.
.cp 4Š
    Thå  sourcå  anä destinatioî fileó maù bå oî anù  legaì  Disk/User®  Nï 
    checkó  arå donå bù ZXLATÅ aó tï thå validitù oæ theså  specifications® 
    However¬  iæ improperlù specified¬ á Disk/Useò Erroò wilì bå issueä anä 
    the program will be terminated.

    Invokinç  ZXLATÅ  witè  nï  parameteró oò aó ZXLATÅ /¯  wilì  causå  aî 
    internaì helğ filå tï bå displayeä oî thå console® Thå followinç singlå 
    characteró  maù bå useä tï changå thå defaulô valueó aô ruî  time®  Thå 
    square brackets are not part of the specification.

         [A]       Outpuô  .Z8° anä ASEÇ assembleò pseudo-opó  tï 
                   thå destinatioî filå foò M80.

         [C=nn]    Aligî  commentó  iî columî nn®  (C=4±  ió  thå 
                   default.©  Noteº  therå musô bå nï interveninç 
                   spaceó betweeî thå Ã anä thå ½ oò betweeî  thå 
                   ½ anä thå columî number® ZXLATÅ doeó noô checë 
                   thå  columî  numbeò  aó beinç valiä  anä  wilì 
                   attempô   tï  aligî  tï  whateveò  columî   ió 
                   specifieä iæ iô ió possible.

         [D]       Translatå   DÂ   anä   EQÕ   statements®   (Nï 
                   translatioî ió thå default.)

         [E]       Translatå  TDÌ  pseudo-opó intï  standarä  Z8° 
                   mnemonics.

         [L]       Translatå  labels¬  opcodeó  anä  operandó  tï 
                   loweò  case®   (Nï  caså  translatioî  ió  thå 
                   default.)

         [M]       Puô   instructionó   separateä  bù   DRI'ó   ¡ 
                   separatoò  intï  singlå lines®  Removå  thå  ¡ 
                   separatoò (default).

         [S]       Separate opcode from operand by a space (20H).

         [T]       Separatå  opcodå froí operanä bù á  taâ  (09H© 
                   (default).

         [Z]       Translatå   Z80.LIÂ   macrï  pseudo-opó   intï 
                   standarä Z8° mnemonicó (default).

    Anù  oæ thå abovå optionó maù bå specifieä oî thå  commanä  line®  Theù 
    musô  bå  preceedeä bù thå ¯ separatoò tï bå recognizeä bù  ZXLATE®  Nï 
    otheò syntaø checkó arå donå oî thå sourcå file® ZXLATÅ wilì ignorå anù 
    instructions (opcodes) which are not defined it its internal tables.

    ZXLATÅ wilì recognizå thå M8° .COMMENÔ pseudo-op® Anù text appearinç iî 
    thió  typå  oæ statement¬  wilì bå copieä verbatií tï  thå  destinatioî 
    file.
.cp 4Š
    Thå "standarä Z80.LIB¢ filå haó haó severaì ne÷ additionó sincå iô  waó 
    firsô  released®  Thå majoritù oæ thå additionó arå onlù tï renamå somå 
    oæ  thå Jumğ (JP© anä Jumğ Relativå (JR© instructions®  Thå  ne÷  codeó 
    havå   beeî  addeä  tï  ZXLATE'ó  tableó  witè  thå  correspondinç  Z8° 
    instructioî  beinç  generated®   Theså  firsô  appeareä  iî  J®  Sage'ó 
    experimentaì ZCPR31´ anä RCP14µ whicè havå noô beeî releaseä tï  publiã 
    domain.

    Iô  ió mù desirå tï contributå tï thå realí oæ publiã domaiî  software® 
    Thió  ió jusô onå oæ á serieó oæ programó whicè wilì bå  developeä  foò 
    use by serious microcomputer users.

    Thió  prograí ió registereä witè thå UÓ Governmenô anä ió copyrighô (c© 
    1986 by G. Benson Grey and Virtual Micro Systems International.

    Anù  commentó anä oò suggestionó regardinç thå prograí maù bå addresseä 
    to:

              G. Benson Grey, Sysop         [503] 641-6101 Voice
              Portland  ZNODE #24           [503] 644-4621 Data 1200
              12275 NW Cornell Rd, Ste 5
              Portland, OR 97229-5611   


    Thå  ZNODÅ  systeí datá phonå ió availablå froí  22.0°  - 06.0°  daily® 
    Voicå  phonå  calló wilì bå accepteä froí 06.0° - 220°  daily®  Collecô 
    calló wilì noô bå accepteä undeò anù circumstances.

