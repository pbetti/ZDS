#!/bin/sh

EXENAME=alias

OPLOG=$EXENAME.log

echo "Doing $EXENAME.com ..."

> $OPLOG

zxcc ../../m80.com -=alias0 >> $OPLOG
zxcc ../../m80.com -=alias1 >> $OPLOG

# zxcc ../../zml.com -alias0,z3lib/,syslib/ >> $OPLOG
# zxcc ../../zml.com -alias1,z3lib/,syslib/ >> $OPLOG
zxcc ../../l80 -/p:100,alias0,z3lib/s,syslib/s,alias0/n,/u,/e
zxcc ../../l80 -/p:100,alias1,z3lib/s,syslib/s,alias1/n,/u,/e

rm -f alias.com
cat alias0.com alias1.com >> alias.com

rm -f alias0.com alias1.com alias0.rel alias1.rel

# -- DONE

