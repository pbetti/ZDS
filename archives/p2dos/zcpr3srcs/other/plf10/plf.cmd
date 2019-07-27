PLF $zif ex $d1$u1:$:1.lbr;llf $d1$u1:$:1; p2 $d1$u1:$:1;else;if nu $:1;or eq $:1 //;t a0:m plf;else;echo ^M^Jt%>here is no ^[)%<$:1.lbr%>^[( on %<^[)$d1$u1:^[(.^M^J;zif
P2 $zzif;reg s0 6; p3 $1 $'FILE(S) TO VIEW/EXTRACT/PRINT: ';zif
P3 $zzif;if eq $2 /r;reg s0 4;else;if ge $2 /t;lt $1 $:3.$.3;reg s0 5;zif;rs p$$r0 $1 $2 $d3$u3:$:3.$.3 $d4$u4:$:4.$.4 $d5$u5:$:5.$.5;zif
P4 $zzif;if ~co x.$.3;lex $1 $d3$u3:$:3.$.3;rena $d3$u3:$:3.$.3 $d3$u3:$:4.$.4;else;echo ^M^Jc%>ompressed files cannot be renamed.;sak /p3;fi;llf $1; p2 $1;zif
P5 $zzif;if ~nu $:4;lt $1 $:4.$.4;if ~nu $:5;lt $1 $:5.$.5;zif;llf $1; p2 $1;zif
P6 $zzif;;echo;lex $1 $3 u;if ~nu $:4;go $1 $4 u;if ~nu $:5;go $1 $5 u;zif; P7 $1 $2 $:3.$.3 $:4.$.4 $:5.$.5;zif
P7 $zzif;if eq $:2 /e;llf $1; p2 $1;else; p8 $1 $-2;zif
P8 $zzif;if ~co x.$.2;print $2;if ~nu $:3; $0 $1 $-2;fi;llf $1; p2 $1;else; p9 $*;zif
P9 $zzif;print $:2.* i;era $:2.* i;if ~nu $:3; P8 $1 $-2;else;llf $1; p2 $1;zif
