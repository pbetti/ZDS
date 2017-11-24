
/* ../getline.c */
extern void getline(char[], int);

/* ../ovloader.c */
extern int ovloader(char *, int );

/* ../zmconf2.c */
extern int setparity(void);
extern int setdatabits(void);
extern int setstopbits(void);
extern int sethost(void);
extern int phonedit(void);
extern int cshownos(void);
extern int cloadnos(void);
extern int ldedit(void);
extern int edit(void);
extern int savephone(void);
extern int saveconfig(void);
extern int setbaud(void);
extern int goodbaud(int);

/* ../zmconfig.c */
extern int ovmain(void);
extern int settransfer(void);
extern int setsys(void);
extern int setmodem(void);
extern int gnewint(char *, int *);
extern int gnewstr(char *, char *, int);
extern int setline(void);

/* ../zminit.c */
extern int ovmain(void);
extern int title(void);
extern int initializemodem(void);
extern int getconfig(void);
extern int xfgets(char *, int, FILE *);
extern int resetace(void);

/* ../zmp2.c */
extern int fstat(char *, struct stat *);
extern unsigned filelength(struct fcb *);
extern int roundup(int, int );
extern int getfirst(char *);
extern int getnext(void);
extern int memcpy(char *, char *, int);
extern int memset(char *, int , int);
extern int command(int *, int *);
extern int ctr(char *);
extern int opabort(void);
extern int readock(int, int );
extern int readline(int);
extern int putlabel(char[]);
extern int killlabel(void);
extern int mgetchar(int);
extern int dummylong(void);
extern int box(void);
extern int clrbox(void);
extern int mread(char *, int, int );
extern int mcharinp(void);
extern int mcharout(int);
extern int minprdy(void);

/* ../zmp.c */
extern int main(void);
extern char *grabmem(unsigned *);
extern int getpathname(char *);
extern int linetolist(void);
extern int freepath(int);
extern int reset(unsigned, int);
extern int addu(char *, int, int );
extern int deldrive(char *);
extern int dio(void);
extern int chrin(void);
extern int getch(void);
extern int flush(void);
extern int purgeline(void);
extern int openerror(int, char *, int );
extern int wrerror(char *);
extern char *alloc(int);
extern int allocerror(char *);
extern int perror(char *);
extern int kbwait(unsigned);
extern int readstr(char *, int);
extern int isin(char *, char *);
extern int report(int, char *);
extern int mstrout(char *, int);

/* ../zmterm2.c */
extern int keydisp(void);
extern int keep(char *, int);
extern int startcapture(void);
extern int docmd(void);
extern int capturetog(char *);
extern int comlabel(void);
extern int scplabel(void);
extern int diskstuff(void);
extern int possdirectory(char *);
extern int help(void);
extern int viewfile(void);
extern int printfile(void);

/* ../zmterm3.c */
extern int directory(void);
extern int sorted_dir(unsigned char *, unsigned);
extern int unsort_dir(void);
extern int printsep(int);
extern int domore(void);
extern int dirsort(char *, char *);
extern int memcmp(char *, char *, int);
extern int cntbits(int);
extern int resetace(void);
extern int updateace(void);
extern int hangup(void);
extern int tlabel(void);
extern int waitakey(void);

/* ../zmterm.c */
extern int ovmain(void);
extern int prtchr(int);
extern int tobuffer(int);
extern int prompt(int);
extern int toprinter(int);
extern int toggleprt(void);
extern int getprtbuf(void);
extern int doexit(void);
extern int prtservice(void);
extern int pready(void);
extern int adjustprthead(void);
extern int setace(int);
extern int dial(void);
extern int shownos(void);
extern int loadnos(void);

/* ../zmxfer2.c */
extern int wcsend(int, char *[]);
extern int wcs(char *);
extern int wctxpn(char *);
extern char *itoa(int, char[]);
extern char *ltoa(long, char[]);
extern int getnak(void);
extern int wctx(long);
extern int wcputsec(char *, int, int);
extern int filbuf(char *, int);
extern int newload(char *, int);

/* ../zmxfer3.c */
extern int getzrxinit(void);
extern int sendzsinit(void);
extern int zsendfile(char *, int);
extern int zsndfdata(void);
extern int getinsync(int);
extern int saybibi(void);
extern char *ttime(long);
extern int tfclose(void);
extern int uneof(FILE *);
extern int slabel(void);

/* ../zmxfer4.c */
extern int wcreceive(char *);
extern int wcrxpn(char *);
extern int wcrx(void);
extern int wcgetsec(char *, int);
extern int procheader(char *);
extern char *substr(char *, char *);
extern int canit(void);
extern int clrreports(void);

/* ../zmxfer5.c */
extern int zperr(char *, int);
extern int dreport(int, int );
extern int lreport(int, long);
extern int sreport(int, long);
extern int clrline(int);
extern int tryz(void);
extern int rzmfile(void);
extern int rzfile(void);
extern int statrep(long);
extern int crcrept(int);
extern int putsec(int, int );
extern int zmputs(char *);
extern int testexist(char *);
extern int closeit(void);
extern int ackbibi(void);
extern long atol(char *);
extern int rlabel(void);

/* ../zmxfer.c */
extern int ovmain(int);
extern int sendout(int);
extern int bringin(int);
extern int endstat(int, int );
extern int protocol(int);
extern int updcrc(unsigned, unsigned );
extern long updc32(int, long);
extern int asciisend(char *);
extern int checkpath(char *);
extern int xmchout(int);
extern int testrxc(int);

/* ../zzm2.c */
extern int zrbhdr(char *);
extern int zrb32hdr(char *);
extern int zrhhdr(char *);
extern int zputhex(int);
extern int zsendline(int);
extern int zgethex(void);
extern int zgeth1(void);
extern int zdlread(void);
extern int noxrd7(void);
extern int stohdr(long);
extern long rclhdr(char *);

/* ../zzm.c */
extern int zsbhdr(int , char *);
extern int zsbh32(char *, int );
extern int zshhdr(int , char *);
extern int zsdata(char *, int, int );
extern int zsda32(char *, int, int );
extern int zrdata(char *, int );
extern int zrdat32(char *, int );
extern int zgethdr(char *, int);
extern int prhex(int);
