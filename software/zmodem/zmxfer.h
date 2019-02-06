/* ../zmxfer2.c */
extern int wcsend(int, char *[]);
extern int wcs(char *);
extern int wctxpn(char *);
extern char *itoa(short, char[]);
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
extern void saybibi(void);
extern char *ttime(long);
extern void tfclose(void);
extern void slabel(void);

/* ../zmxfer4.c */
extern int wcreceive(char *);
extern int wcrxpn(char *);
extern int wcrx(void);
extern int wcgetsec(char *, int);
extern int procheader(char *);
extern char *substr(char *, char *);
extern void canit(void);
extern void clrreports(void);

/* ../zmxfer5.c */
extern void zperr(char *, int);
extern void dreport(int, int );
extern void lreport(int, long);
extern void sreport(int, long);
extern void clrline(int);
extern int tryz(void);
extern int rzmfile(void);
extern int rzfile(void);
extern void statrep(long);
extern void crcrept(int);
extern int putsec(int, int );
extern int zmputs(char *);
extern void testexist(char *);
extern int closeit(void);
extern void ackbibi(void);
extern long atol(char *);
extern void rlabel(void);

/* ../zmxfer.c */
extern int ovmain(char);
extern int sendout(int);
extern int bringin(int);
extern void endstat(int, int );
extern int protocol(int);
extern int updcrc(unsigned, unsigned );
extern long updc32(int, long);
extern int asciisend(char *);
extern void checkpath(char *);
extern void xmchout(char);
extern void testrxc(short);
extern int getpathname ( char *, char ** );
extern int linetolist ( char ** );
extern void freepath ( int, char ** );
extern int process_flist ( int, char ** );

/* ../zzm2.c */
extern int zrbhdr(char *);
extern int zrb32hdr(char *);
extern int zrhhdr(char *);
extern void zputhex(int);
extern void zsendline(int);
extern int zgethex(void);
extern int zgeth1(void);
extern int zdlread(void);
extern int noxrd7(void);
extern void stohdr(long);
extern long rclhdr(char *);

/* ../zzm.c */
extern void zsbhdr(int , char *);
extern void zsbh32(char *, int );
extern void zshhdr(int , char *);
extern void zsdata(char *, int, int );
extern void zsda32(char *, int, int );
extern int zrdata(char *, int );
extern int zrdat32(char *, int );
extern int zgethdr(char *, int);
extern void prhex(char);
