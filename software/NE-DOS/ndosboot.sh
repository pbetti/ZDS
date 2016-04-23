PRECOMP="ndosboot"
COMS="nedos formndos nedcopy"

mkdir -p ndosboot
for f in $PRECOMP
do
	zmac $f.asm || exit 1
done

for f in $COMS
do
	zmac $f.asm || exit 1
	mv -f $f.bin ndosboot/$f.com
done

cat ndosboot.bin >> ndosboot/nedos.com

../../img_prep.sh ndosboot
