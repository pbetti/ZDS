PCBNEW-LibModule-V1  1/19/2013 3:38:06 PM
# encoding utf-8
Units deci-mils
$INDEX
molex-drive-connector
$EndINDEX
$MODULE molex-drive-connector
Po 0 0 0 15 50FB0428 00000000 ~~
Li molex-drive-connector
Cd Bornier d'alimentation 4 pins
Kw DEV
Sc 0
AR /47C1CB92
Op 0 0 0
T0 -500 2000 600 600 0 120 N V 21 N "P2"
T1 2500 2000 600 600 0 120 N V 21 N "POWER"
DS -3000 -1500 -4000 -500 150 21
DS -4000 -1000 -3500 -1500 150 21
DS 3000 -1500 4000 -500 150 21
DS 3500 -1500 4000 -1000 150 21
DS -4000 -1500 -4000 1500 120 21
DS 4000 1500 4000 -1500 120 21
DS 4000 1000 -4000 1000 120 21
DS -4000 -1500 4000 -1500 120 21
DS -4000 1500 4000 1500 120 21
$PAD
Sh "3" C 1500 1500 0 0 0
Dr 700 0 0
At STD N 00E0FFFF
Ne 1 "GND"
Po -1000 0
$EndPAD
$PAD
Sh "2" C 1500 1500 0 0 0
Dr 700 0 0
At STD N 00E0FFFF
Ne 1 "GND"
Po 1000 0
$EndPAD
$PAD
Sh "4" C 1500 1500 0 0 0
Dr 700 0 0
At STD N 00E0FFFF
Ne 2 "VCC"
Po -3000 0
$EndPAD
$PAD
Sh "1" R 1500 1500 0 0 0
Dr 700 0 0
At STD N 00E0FFFF
Ne 0 ""
Po 3000 0
$EndPAD
$SHAPE3D
Na "device/bornier_4.wrl"
Sc 1 1 1
Of 0 0 0
Ro 0 0 0
$EndSHAPE3D
$EndMODULE molex-drive-connector
$EndLIBRARY