/*
 * #  MODULE DESCRIPTION:
 * #  Partition manager for Z80 Darkstar (Z80NE)
 * #
 * #  AUTHORS:
 * #  Piergiorgio Betti <pbetti@lpconsul.net>
 * #
 * #  LICENSE: See "License.txt" under top-level source directory
 * #
 * #  HISTORY:
 * #  -[Date]- -[Who]------------- -[What]---------------------------------------
 * #  25.08.14 Piergiorgio Betti   Creation date
 * #  27.09.18 Piergiorgio Betti   Fixed gets, some minor change
 * #--
 * #
 */

// #include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <c_bios.h>
#include <cpm.h>

#define	SIGNSIZE		8
#define	SIGNSTRING		"AUAUUAUA"
#define	MAX_PARTITIONS		16
#define	true			1
#define false			0

// static const unsigned int TMPBYTE = 0x004b;	// TMPBYTE in page 0

typedef struct {
	unsigned char active;			// active/inactive partition
	unsigned char letter;			// assigned letter (A - P)
	unsigned char ptype;			// 2: cp/m2, 3: cp/m3, N: NEDOS, O: Other
	unsigned int startcyl;			// starting cylinder
	unsigned int endcyl;			// last cylinder
	unsigned char reserved;			// reserved... and make struct size even
} PARTINFO;

typedef struct {
	unsigned char signature[SIGNSIZE];
	PARTINFO table[MAX_PARTITIONS];
} PARTTABLE;

static	PARTTABLE partition;
static	unsigned char modified;
static	HDGEO geometry;
static	unsigned char hdbuf[512];
static	char ubuf[256];
static	unsigned long ltrack;
static	unsigned int lsects;
static	unsigned char cview;
static	unsigned long mbyte;
static	unsigned long cylsize;
static	unsigned int ndisks = 1;
static	unsigned char selected_drive = 0;
static	unsigned char system_drive;

	// Some string constant (to save space)
static const char * msg_partnumber;
static const char * msg_invinput;

extern	void displayTable();
extern	void doExit();
extern	void exitPrompt();
extern	int checkAndInit();
extern	void buf2Tab();
extern	void tab2Buf();
extern 	void doHelp();
extern	void readTable();
extern	void writeTable();
extern	void uprompt(const char *, unsigned int *);
extern	void upromptc(const char *, char *, const char *);
extern	void editPartition();
extern	void clearPartition();
extern	void lockHDAccess();
extern	void unlockHDAccess();
extern	void doFormat();
extern	int changewarn();

// since C11 standard forbid gets...
extern char * gets(char *);

main()
{
	char cmd;
	unsigned char loop = true;

	mbyte = 1024L * 1024L;
	cview = 1;
	ltrack = 0;
	modified = false;
	msg_partnumber = "Partition number: ";
	msg_invinput = "Invalid input\n";

	unlockHDAccess();		// enable unpartitioned access to hd
	if (hasHDSlave())
		++ndisks;
	system_drive = curHDrive();

	/* hello user ! */
	cls();

	printf("\nZ80 Darkstar NEZ80 Partition Manager\n");
	printf("P. Betti, 2014. Rev 2.0 - 2019/04/02\n\n");

	// get HD data
	readTable();

	// check for valid table and init if wrong
	checkAndInit();

	displayTable();

	// application loop
	while (loop) {

		printf("\nEnter command (h = help): ");
		cmd = getch();
		cmd = toupper(cmd);
		putch('\n');

		switch (cmd) {
			case 'H':
				doHelp();
				break;

			case 'D':
				if (!changewarn()) {
					break;
				}
				if (ndisks > 1) {
					modified = false;
					selected_drive = (selected_drive) ? 0 : 1;
					logHDrive(selected_drive);
					cls();
					readTable();
					checkAndInit();					
					displayTable();
				}
				break;
				
			case 'V':
				cview = ! cview;
				break;
				
			case 'L':
				displayTable();
				break;

			case 'F':
				doFormat();
				break;

			case 'X':
			case 'R':
				if (!changewarn()) {
					break;
				}
				if (cmd == 'X') {
					loop = false;
					break;
				}
				readTable();
				modified = false;
				break;

			case 'S':
				if (! modified) {
					printf("Nothing to save.\n");
					break;
				}
				writeTable();
				modified = false;
				printf("Saved.\n");
				break;

			case 'E':
				editPartition();
				break;

			case 'C':
				clearPartition();
				break;
		}
	}


	lockHDAccess();
	logHDrive(system_drive);
	exitPrompt();
	return 0;
}

int changewarn()
{
	char answ;

	if (modified) {
		printf("Changes pending for save! Continue will discard them.\n");
		printf("Are you shure to proceed ? \n");
		answ = getch();
		answ = toupper(answ);
		return (answ != 'Y') ? false : true;
	}
	return true;
}


void clearPartition()
{
	int pnum;
	char prm = 'N';

	// get part number
	printf(msg_partnumber);
	gets(ubuf);
	pnum = atoi(ubuf);

	if (pnum < 1 || pnum > MAX_PARTITIONS ) {
		printf(msg_invinput);
		return;
	}
	--pnum;

	upromptc("Are you shure ?", &prm, "YN");

	if (prm == 'Y') {
		memset((void *) partition.table[pnum], 0, sizeof(PARTINFO) );
		partition.table[pnum].active = 'N';
		partition.table[pnum].letter = ' ';
		partition.table[pnum].ptype = 'X';
	}
}

void doFormat()
{
	int pnum, sec, trk;
	char prm = 'N';

	// get part number
	printf(msg_partnumber);
	gets(ubuf);
	pnum = atoi(ubuf);

	if (pnum < 1 || pnum > MAX_PARTITIONS ) {
		printf(msg_invinput);
		return;
	}
	--pnum;

	printf("This will delete entire volume %c. ", partition.table[pnum].letter);
	upromptc("Confirm ?", &prm, "YN");
	modified = false;
	if (prm != 'Y')
		return;

	upromptc("Are you shure ?", &prm, "YN");
	modified = false;
	if (prm != 'Y')
		return;

	// prepare buffer
	memset((void *) hdbuf, 0xe5, 512 );

	// ok...
	printf("Formatting...\n");

	for (trk = partition.table[pnum].startcyl; trk < partition.table[pnum].endcyl; trk++) {
		sec = 0;
		for (sec = 0; sec < 256; sec++) {
			printf("Trk: %d, sec: %d     \r",
			       trk - partition.table[pnum].startcyl,
			       sec);
			if ( hdWrite(hdbuf, trk, sec) ) {
				printf("\nFormat error!\n");
				return;
			}
			// user do something
			if (kbhit()) {
				getch();
				upromptc("Abort formatting ?", &prm, "YN");
				if (prm == 'Y')
					return;
			}
		}
	}
	printf("\nDone.\n");
}

void editPartition()
{
	int pnum, i;
	unsigned int scyl, mbsiz;
	unsigned long psiz, ajcyl;
	unsigned int oscyl, oecyl;
	char prm;

	// get part number
	printf(msg_partnumber);
	gets(ubuf);
	pnum = atoi(ubuf);

	if (pnum < 1 || pnum > MAX_PARTITIONS ) {
		printf(msg_invinput);
		return;
	}
	--pnum;

	// get start cyl

	scyl = partition.table[pnum].startcyl;
	oscyl = scyl;
	if (scyl == 0) {
		for (i = 0; i < MAX_PARTITIONS; i++) {
			if (partition.table[i].endcyl > scyl)
				scyl = partition.table[i].endcyl;
		}
		++scyl;
		modified = 1;
	}


	uprompt("Starting cylinder", &scyl);
	if (scyl > ltrack - 3) {
		printf(msg_invinput);
		return;
	}
	partition.table[pnum].startcyl = scyl;

	// get end cyl
	if (scyl > partition.table[pnum].endcyl) {
		mbsiz = 0;
	}
	else {
		psiz = (unsigned long)partition.table[pnum].endcyl - (unsigned long)partition.table[pnum].startcyl;
		printf("Num cyls: %ld\n",psiz);

		psiz = (((unsigned long)partition.table[pnum].endcyl - (unsigned long)partition.table[pnum].startcyl) * cylsize);
		printf("Size: %ld\n",psiz);


		psiz = (((unsigned long)partition.table[pnum].endcyl - (unsigned long)partition.table[pnum].startcyl)
		* cylsize) / mbyte;
		printf("Mb: %ld\n",psiz);

		mbsiz = (unsigned int)psiz;
	}
	oecyl = partition.table[pnum].endcyl;

	uprompt("Partition size in Mbytes", &mbsiz);
	psiz = (unsigned long)mbsiz * mbyte;
	mbsiz = (unsigned int)(psiz / cylsize);

	ajcyl = mbsiz;
	while ( (ajcyl * cylsize) < psiz ) {
		++ajcyl;
	}

	mbsiz = (unsigned int)ajcyl + scyl;

	if (mbsiz > ltrack - 2) {
		printf("Cylinder %d too high!\n", mbsiz);
		return;
	}
	partition.table[pnum].endcyl = mbsiz;

	// check overlaps
	for (i = 0; i < MAX_PARTITIONS; i++) {
		if (i == pnum)
			continue;
		if ( (partition.table[pnum].endcyl >= partition.table[i].startcyl && partition.table[pnum].endcyl <= partition.table[i].endcyl) ||
			(partition.table[pnum].startcyl >= partition.table[i].startcyl && partition.table[pnum].startcyl <= partition.table[i].endcyl)
		) {
			printf("Overlapping partions %d!\n", i+1);
			partition.table[pnum].startcyl = oscyl;
			partition.table[pnum].endcyl = oecyl;
			modified = false;
			return;
		}
	}

	// active
	prm = partition.table[pnum].active;

	upromptc("Activate partition", &prm, "YN");
	partition.table[pnum].active = prm;
	
	// volume type
	prm = partition.table[pnum].ptype;
	
	upromptc("2=CP/M2 and like\n\
	3=CP/M3\n\
	N=NEDOS\n\
	U=UZI/Fuzix\n\
	T=TurboDOS\n\
	O=Others\n\
	Select partition type", &prm, "23NUTO");
	partition.table[pnum].ptype = prm;

	// drive letter
	prm = partition.table[pnum].letter;

	// CP/M partions ID are tied to drive
	if (partition.table[pnum].ptype == '2' || 
	    partition.table[pnum].ptype == '3' || 
	    partition.table[pnum].ptype == 'T')
	{
		if (selected_drive == 0) {
			printf("Valid ID for CP/M volume on drive %d are \"CDEFGH\".\n", selected_drive + 1);
			upromptc("Drive id [C-H]", &prm, "CDEFGH");
		}
		else {
			printf("Valid ID for CP/M volume on drive %d are \"IJKLMN\".\n", selected_drive + 1);
			upromptc("Drive id [I-N]", &prm, "IJKLMN");
		}
	}
	else
		upromptc("Drive id [A-P,0-9]", &prm, "ABCDEFGHIJKLMNOP0123456789");
	
	partition.table[pnum].letter = prm;	

	for (i = 0; i < MAX_PARTITIONS; i++) {
		if (i == pnum)
			continue;
		if (partition.table[pnum].ptype == partition.table[i].ptype && partition.table[pnum].letter == partition.table[i].letter) {
			printf("Duplicated volume ID/Type %c/%c !\n", partition.table[pnum].letter, partition.table[pnum].ptype);
			partition.table[pnum].active = 'N';
			partition.table[pnum].letter = ' ';
			partition.table[pnum].ptype = 'X';
			partition.table[pnum].startcyl = 0;
			partition.table[pnum].endcyl = 0;
			
			return;
		}
	}

	displayTable();
}

void doExit()
{
	lockHDAccess();
	exitPrompt();

	__asm
		jp	0
	__endasm;
}

void exitPrompt()
{
	/* prompt to terminate */
	printf("Terminating...\n");
}

void readTable()
{
	unsigned long tsectors;

	getHDgeo(&geometry);

	printf("System has %d hard drive(s).\n", ndisks);
	printf("Disk is %d cylinders, %d heads, %d sectors.\n",
		geometry.cylinders,
		geometry.heads,
		geometry.sectors
	);

	tsectors = (unsigned long)geometry.cylinders * (unsigned long)geometry.heads * (unsigned long)geometry.sectors;
	printf("Disk size is %ld sectors.\n", tsectors);

	// do remap
	lsects = 256;
	geometry.cylinders = tsectors / lsects;

	cylsize = (unsigned long)lsects * 512L;
	printf("Cylinder size is %ld bytes.\n", cylsize);

	ltrack = (unsigned long)geometry.cylinders - 1;
	printf("CP/M LBA addressing: %ld tracks, %d sectors (1 track reserved)\n", ltrack, lsects);

	// partition table is stored on first track of disk, sector 1

	if ( hdRead(hdbuf, 0, 1) ) {
		printf("Error reading table!\n");
		doExit();
	}
	buf2Tab();

}

void displayTable()
{
	int i = 0;
	int nentry;
	const char * msr;

	printf("Current disk partition table: ");
	if (cview)
		printf("[short] ");
	if (ndisks > 1)
		printf("[%s disk] ", (selected_drive) ? "1 SLAVE" : "0 MASTER");
	if (modified)
		printf("(unsaved)\n");
	else
		printf("\n");

	printf("No A L Type Start End   Size\n");
	printf("-- - - ---- ----- ----- --------\n");

	// half list if cview view is acative
	if (cview)
		nentry = 8;
	else
		nentry = MAX_PARTITIONS;

	for (i = 0; i < nentry; i++) {

		unsigned long psiz = (((unsigned long)partition.table[i].endcyl - (unsigned long)partition.table[i].startcyl)
					* cylsize) / 1024L;
		msr = "Kb";

		if (psiz > 10240) {
			psiz /= 1024;
			msr = "Mb";
		}


		printf("%02d %c %c %c    %05d %05d %ld%s\n",
			i+1,
			partition.table[i].active,
			partition.table[i].letter,
			partition.table[i].ptype,
			partition.table[i].startcyl,
			partition.table[i].endcyl,
			psiz,
			msr
      		);
	}

	return;
}

int checkAndInit()
{
	int i = 0;

	if (strncmp(partition.signature, SIGNSTRING, SIGNSIZE) == 0)
		return 0;	// ok

	// need initialization
	strncpy(partition.signature, SIGNSTRING, SIGNSIZE);
	memset((void *) partition.table, 0, sizeof(PARTINFO) * MAX_PARTITIONS );
	for (i = 0; i < MAX_PARTITIONS; i++) {
		partition.table[i].active = 'N';
		partition.table[i].letter = ' ';
		partition.table[i].ptype = 'X';
	}

	// update on disk
	modified = 1;		// update upon user action

	return 1;
}

// void unlockHDAccess()
// {
// 	unsigned char * tmpbyte = (unsigned char *)TMPBYTE;

// 	*tmpbyte |= 1 << 7;
// }

// void lockHDAccess()
// {
// 	unsigned char * tmpbyte = (unsigned char *)TMPBYTE;

// 	*tmpbyte &= ~(1 << 7);
// }

void tab2Buf()
{
	// clear sector buffer too
	memset((void *) hdbuf, 0, 512 );
	memcpy( (void *)hdbuf, (void *)partition, sizeof(PARTTABLE) );
}

void buf2Tab()
{
	memcpy( (void *)partition, (void *)hdbuf, sizeof(PARTTABLE) );
}


void writeTable()
{
	tab2Buf();
	if ( hdWrite(hdbuf, 0, 1) ) {
		printf("Error writing table!\n");
		doExit();
	}

}


void uprompt(const char * msg, unsigned int * n)
{
	printf("%s (%d) : ", msg, *n);
	gets(ubuf);

	if (strlen(ubuf) == 0)
		return;

	modified = 1;
	*n = atoi(ubuf);
	return;
}

void upromptc(const char * msg, char * c, const char * validate)
{
	char usrch;
	unsigned char inloop = true;
	int i, vlen;

	vlen = strlen(validate);

	do {
		printf("%s (%c) : ", msg, *c);
		usrch = getch();
		putch(usrch);

		if (usrch == 0x0d) {
			putch('\n');
			return;
		}
		usrch = toupper(usrch);

		for (i = 0; i < vlen; i++)
			if (usrch == validate[i])
				inloop = false;

		putch('\n');

	} while (inloop);

	modified = 1;
	*c = usrch;
	return;
}

void doHelp()
{
	printf("Command list:\n");
	printf("\
	d - change (swap) hard drive\n\
	v - toggle cview/full view\n\
	l - show table\n\
	f - format partition\n\
	e - edit partition\n\
	c - clear partition\n\
	s - save changes\n\
	r - re-read table\n\
	x - exit\n\
	");
}

char * gets (register char *s)
{
	register char c;
	unsigned int count = 0;

	while (1)
	{
		c = getch ();
		switch(c)
		{
			case '\b': /* backspace */
				if (count)
				{
					putch ('\b');
					putch (' ');
					putch ('\b');
					--s;
					--count;
				}
				break;

			case '\n':
			case '\r': /* CR or LF */
// 				putch ('\r');
				putch ('\n');
				*s = 0;
				return s;

			default:
				*s++ = c;
				++count;
				putch (c);
				break;
		}
	}
}


// --- EOF


