//
//  '########'########::'######:::'##::: ##'########'########:'#######:::'#####:::
//  ..... ##: ##.... ##'##... ##:: ###:: ## ##.....:..... ##:'##.... ##:'##.. ##::
//  :::: ##:: ##:::: ## ##:::..::: ####: ## ##:::::::::: ##:: ##:::: ##'##:::: ##:
//  ::: ##::: ##:::: ##. ######::: ## ## ## ######::::: ##:::: #######: ##:::: ##:
//  :: ##:::: ##:::: ##:..... ##:: ##. #### ##...::::: ##::::'##.... ## ##:::: ##:
//  : ##::::: ##:::: ##'##::: ##:: ##:. ### ##::::::: ##::::: ##:::: ##. ##:: ##::
//   ######## ########:. ######::: ##::. ## ######## ########. #######::. #####:::
//  ........:........:::......::::..::::..:........:........::.......::::.....::::
//
//  Sysbios C interface library
//  P.Betti  <pbetti@lpconsul.eu>
//
//  Module: c_bios header
//
//  HISTORY:
//  -[Date]- -[Who]------------- -[What]---------------------------------------
//  28.09.18 Piergiorgio Betti   Creation date
//

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define	BUFSIZ		512
#define	_NFILE		8

// #define	uint8_t	unsigned char

extern	struct	_iobuf {
	char *		_ptr;
	int		_cnt;
	char *		_base;
	uint8_t		_flag;
	char		_file;
} _iob[_NFILE];


#define	_IOREAD		01
#define	_IOWRT		02
#define	_IORW		03
#define	_IONBF		04
#define	_IOMYBUF	010
#define	_IOEOF		020
#define	_IOERR		040
#define	_IOSTRG		0100
#define	_IOBINARY	0200

#define	FILE		struct _iobuf
#define	EOF		(-1)
#define	STDSETUP()

#define	stdin		(&_iob[0])
#define	stdout		(&_iob[1])
#define	stderr		(&_iob[2])
#define	getc(p)		fgetc(p)
#define	getchar()	getc(stdin)
#define	putc(x,p)	fputc(x,p)
#define	putchar(x)	putc(x,stdout)
#define	feof(p)		(((p)->_flag&_IOEOF)!=0)
#define	ferror(p)	(((p)->_flag&_IOERR)!=0)
#define	fileno(p)	((uint8_t)p->_file)

// FILE *		fopen();
// FILE *		freopen();
// FILE *		fdopen();
// long		ftell();
// char *		fgets();
// char *		_bufallo();

#define	MAXFILE		8	/* max number of files open */
#define	SECSIZE		128	/* no. of bytes per sector */


/*	 flag values in fcb.use */

#define	U_READ	1		/* file open for reading */
#define	U_WRITE	2		/* file open for writing */
#define	U_RDWR	3		/* open for read and write */
#define	U_CON	4		/* device is console */
#define	U_RDR	5		/* device is reader */
#define	U_PUN	6		/* device is punch */
#define	U_LST	7		/* list device */

/*	 special character values */

#define	CPMETX	032		/* ctrl-Z, CP/M end of file for text */
#define	CPMRBT	003		/* ctrl-C, reboot CPM */


#define	MPM	0x100		/* bit to test for MP/M */
#define	CCPM	0x400		/* bit to test for CCP/M */

#define	ISMPM()	(bdoshl(CPMVERS)&MPM)	/* macro to test for MPM */

/*	 what to do after you hit return */

#define	EXIT	(*(int (*)())0)	/* where to go to reboot CP/M */

/*	 signals */

// #define	SIGINT	1		/* control-C */

// #define	SIG_DFL	((void (*)(int))0)	/* default action is to exit */
// #define	SIG_IGN	((void (*)(int))1)	/* ignore them */

// extern void (*	signal(int, void (*)(int)))();
extern void _sigchk();

/*	 stat */

struct stat
{
	short	st_mode;	/* flags */
	long	st_atime;	/* access time */
	long	st_mtime;	/* modification time */
	long	st_size;	/* file size in bytes */
};

/*	 time */

typedef	long	time_t;		/* for representing times in seconds */
struct tm {
	int	tm_sec;
	int	tm_min;
	int	tm_hour;
	int	tm_mday;
	int	tm_mon;
	int	tm_year;
	int	tm_wday;
	int	tm_yday;
	int	tm_isdst;
};

struct tod
{
	int	day;
	int	hoursmin;
	char	sec;
};


extern int	time_zone;		/* minutes WESTWARD of Greenwich */
					/* this value defaults to 0 since with
					operating systems like MS-DOS there is
					no time zone information available */

extern time_t	time(time_t *);		/* seconds since 00:00:00 Jan 1 1970 */
extern char *	asctime(struct tm *);	/* converts struct tm to ascii time */
extern char *	ctime();		/* current local time in ascii form */
extern struct tm *	gmtime();	/* Universal time */
extern struct tm *	localtime();	/* local time */

/* Flag bits in st_mode */

#define	S_IFMT		0x600	/* type bits */
#define	S_IFDIR		0x400	/* is a directory */
#define	S_IFREG		0x200	/* is a regular file */
#define	S_IREAD		0400	/* file can be read */
#define	S_IWRITE	0200	/* file can be written */
#define	S_IEXEC		0100	/* file can be executed */
#define	S_HIDDEN	0x1000	/* file is hidden */
#define	S_SYSTEM	0x2000	/* file is marked system */
#define	S_ARCHIVE	0x4000	/* file has been written to */


extern int	stat(char *, struct stat *);

/*	 bdos calls etc. */

#define	CPMRCON	1		/* read console */
#define	CPMWCON	2		/* write console */
#define	CPMRRDR	3		/* read reader */
#define	CPMWPUN	4		/* write punch */
#define	CPMWLST	5		/* write list */
#define	CPMDCIO	6		/* direct console I/O */
#define	CPMGIOB	7		/* get I/O byte */
#define	CPMSIOB	8		/* set I/O byte */
#define	CPMRCOB	10		/* read console buffered */
#define	CPMICON	11		/* interrogate console ready */
#define	CPMVERS	12		/* return version number */

/*	BDOS calls */

#define	CPMRDS	13		/* reset disk system */
#define	CPMLGIN	14		/* log in and select disk */
#define	CPMOPN	15		/* open file */
#define	CPMCLS	16		/* close file */
#define	CPMFFST	17		/* find first */
#define	CPMFNXT	18		/* find next */
#define	CPMDEL	19		/* delete file */
#define	CPMREAD	20		/* read next record */
#define	CPMWRIT	21		/* write next record */
#define	CPMMAKE	22		/* create file */
#define	CPMREN	23		/* rename file */
#define	CPMILOG	24		/* get bit map of logged in disks */
#define	CPMIDRV	25		/* interrogate drive number */
#define	CPMSDMA	26		/* set DMA address for i/o */
#define	CPMSUID	32		/* set/get user id */
#define	CPMRRAN	33		/* read random record */
#define	CPMWRAN	34		/* write random record */
#define	CPMCFS	35		/* compute file size */
#define	CPMDSEG	51		/* set DMA segment */


#define	_IOREAD		01
#define	_IOWRT		02
#define	_IORW		03
#define	_IONBF		04
#define	_IOMYBUF	010
#define	_IOEOF		020
#define	_IOERR		040
#define	_IOSTRG		0100
#define	_IOBINARY	0200

#define	FILE		struct _iobuf
#define	EOF		(-1)

#define	stdin		(&_iob[0])
#define	stdout		(&_iob[1])
#define	stderr		(&_iob[2])
#define	getchar()	getc(stdin)
#define	putchar(x)	putc(x,stdout)

extern struct	fcb {
	uint8_t	dr;		/* drive code */
	char	name[8];	/* file name */
	char	ft[3];		/* file type */
	uint8_t	ex;		/* file extent */
	char	fil[2];		/* not used */
	char	rc;		/* number of records in present extent */
	char	dm[16];		/* CP/M disk map */
	char	nr;		/* next record to read or write */
	uint8_t	ranrec[3];	/* random record number (24 bit no. ) */
	long	rwp;		/* read/write pointer in bytes */
	uint8_t	use;		/* use flag */
	uint8_t	uid;		/* user id belonging to this file */
}	_fcb[MAXFILE];

extern uint8_t		bdos(uint8_t, uint16_t);
extern uint16_t		bdoshl(uint8_t, uint16_t);
extern struct fcb *	getfcb(void);
extern uint8_t		getuid(void);
extern void		setuid(int);
extern uint8_t		setfcb(struct fcb *, char *);
extern void 		putfcb(struct fcb *);
extern void 		fc_parse(struct fcb *, char *);
extern char 		getch(void);
extern int 		kbhit(void);
extern void 		putch(char c);
extern void 		ungetch(char c);
extern char 		getche(void);
extern char * 		fcbname(short);
extern	int 		dup(uint8_t);
extern int		open(char *, int);
extern int		close(uint8_t);
extern int		creat(char *);
extern long		lseek(uint8_t, long, uint8_t);
extern int		read(uint8_t, char *, uint16_t);
extern int		unlink(char *);
extern int		write(uint8_t, char *, uint16_t);
extern int		isatty(uint8_t);
extern int		chmod(char *, int);
extern int		rename(char *, char *);
extern void		abort();
extern void		_cpm_clean();
extern void		_putrno(uint8_t *, int32_t);
extern int		frmbcd(uint8_t);
extern time_t		convtime(struct tod *);


#define	feof(p)		(((p)->_flag&_IOEOF)!=0)
#define	ferror(p)	(((p)->_flag&_IOERR)!=0)
#define	fileno(p)	((uint8_t)p->_file)
#define	clrerr(p)	p->_flag &= ~_IOERR
#define	clreof(p)	p->_flag &= ~_IOEOF

#define	L_tmpnam	34		/* max length of temporary names */

extern int	fclose(FILE *);
extern int	fflush(FILE *);
extern int	fgetc(FILE *);
extern int	ungetc(int, FILE *);
extern int	fputc(int, FILE *);
extern int	getw(FILE *);
extern int	putw(int, FILE *);
extern char *	gets(char *);
extern int	puts(char *);
extern int	fputs(char *, FILE *);
extern int	fread(void *, unsigned, unsigned, FILE *);
extern int	fwrite(void *, unsigned, unsigned, FILE *);
extern int	fseek(FILE *, long, int);
extern int	rewind(FILE *);
extern int	setbuf(FILE *, char *);
extern int	printf(char *, ...);
extern int	fprintf(FILE *, char *, ...);
extern int	sprintf(char *, char *, ...);
extern int	scanf(char *, ...);
extern int	fscanf(FILE *, char *, ...);
extern int	sscanf(char *, char *, ...);
extern int	remove(char *);
extern FILE *	fopen(char *, char *);
extern FILE *	freopen(char *, char *, FILE *);
extern FILE *	fdopen(int, char *);
extern long	ftell(FILE *);
extern char *	fgets(char *, int, FILE *);
extern char *	_bufallo(void);
extern void     exit(int);


// EOF
