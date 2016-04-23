#define TITLE "Cfgdate         Version 0.0       6-28-84"
#define NOTICE "Copyright (c) 1984 Kenmore Computer Technologies"
/*
    Program Name: cfgdate
    Purpose: To configure the executable code for 'date' and 'setdate'
    to differant port base addresses without recompiling or relinking
    the code.

    Written by:
        Alan D. Percy
        Kenmore Computer Technologies
        PO Box 635
        Kenmore, NY   14217
    
    This program or program section can not 
    be resold, given away or copied (other than
    normal use and backup copies) without
    written permission of the above copyright
    holder.
*/

#include <0/bdscio.h>

#define SSTRING "Cbase: 0x"
#define TFNAME "CFGDATE.TMP"

main(argc,argv)
int argc;
char *argv[];
/*
    For each filename in the argument list,
    perform search and configure.
*/
{
    char base[10];       /* space for hex base */

    printf("%s\n%s\n\n",TITLE,NOTICE);

    puts("Enter TWO digit HEX port address for object files: ");
    scanf("%s",base);

    if(strlen(base) != 2) {      /* if user didn't type two characters */
        puts("Cfgdate: A TWO digit address is required\n");
        exit(-1);                /* stop */
    }

    argc--;             /* skip program name */
    argv++;

    while (argc--) 
        cfgdate(*argv++,base);/* pass pointer to filename and port address */

}

cfgdate(fname,base)
char *fname,*base;
/*
    Open the file 'fname' and search it for the string
    SSTRING, replacing the next two characters in the file
    from the characters in 'base'.
*/
{
    char infile[BUFSIZ];              /* input file */
    char outfile[BUFSIZ];             /* output file */
    char ch,hold[11];                 /* space to keep search string in */
    int i;                            /* offset into hold string */
    int instat;                       /* input file status */
    int slen;                         /* string length variable */

    strcpy(hold,SSTRING);             /* stick search string in array */
    slen=strlen(hold);                /* number of chars in search string */
    i=0;                              /* index into search string */

    printf("Processing file: %s\n",fname);

    if(fopen(fname,infile) == -1) {
        printf("Cfgdate: infile open error: %s\n",errmsg(errno()));
        return(0);
    }

    if(fcreat(TFNAME,outfile) == -1) {
        printf("Cfgdate: outfile open error: %s\n",errmsg(errno()));
        return(0);
    }

    do {
        ch = instat = getc(infile);       /* get next character */

        if(i < slen) {                    /* if still searching */
            if(hold[i]==ch)               /* if next character matches */
                i++;                      /* move to next */
            else
                i=0;                      /* otherwise start over */
        }
        else                              /* match found */
            if(i-slen == 0) {             /* first character of replacement */
                ch = base[i - slen];
                i++;
            }
            else {                        /* second character of repl. */
                ch = base[i - slen];
                i = 0;                    /* repl all done, so start over */
            }

        if(putc(ch,outfile) == -1) {      /* output character */
            printf("Cfgdate: outfile write error: %s\n",errmsg(errno()));
            fclose(infile);
            fclose(outfile);
            return(0);
        }
    }
    while(instat != -1);

    if(errno() != 1) {
         printf("Cfgdate: infile read error: %s\n",errmsg(errno()));
         fclose(infile);
         fclose(outfile);
         return(0);
    }

    fclose(infile);        /* close files */
    fclose(outfile);

    /* delete original and rename temporary */
    unlink(fname);
    rename(TFNAME,fname);
}

