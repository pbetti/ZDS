#define NOTICE "Copyright (c) 1984 Kenmore Computer Technologies"
#define BSTRING "Cbase: 0xe0"    /* Base address of clock chip */

/*
    Module Name: datesubs
    Purpose: Define a set of subroutines to manipulate 
             the MM58167A real time clock chip.

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

getdate(array)
char array[];
/* 
   Gets an ASCII representation of the 
   time and date as follows:
      Mon Jan 23 10:51:32 AM
*/
{
    char tarry[6];        /* Array to hold raw date and time */
    char tmp[20];         /* Temporary work array */
    int pmflag;       /* indicated AM/PM time */

    rawdate(tarry);       /* Get raw date and time into tarry */
    
    array[0]=0;           /* null out string */

    switch (tarry[2]) {     /* fill in the day of the week */
        case 1: strcat(array,"Sun ");
                break;
        case 2: strcat(array,"Mon ");
                break;
        case 3: strcat(array,"Tue ");
                break;
        case 4: strcat(array,"Wed ");
                break;
        case 5: strcat(array,"Thu ");
                break;
        case 6: strcat(array,"Fri ");
                break;
        case 7: strcat(array,"Sat ");
                break;
        default: strcat(array,"*** ");
    }
    
    switch (tarry[0]) {      /* fill in month name */
        case 1: strcat(array,"Jan ");
                break;
        case 2: strcat(array,"Feb ");
                break;
        case 3: strcat(array,"Mar ");
                break;
        case 4: strcat(array,"Apr ");
                break;
        case 5: strcat(array,"May ");
                break;
        case 6: strcat(array,"Jun ");
                break;
        case 7: strcat(array,"Jul ");
                break;
        case 8: strcat(array,"Aug ");
                break;
        case 9: strcat(array,"Sep ");
                break;
        case 10: strcat(array,"Oct ");
                break;
        case 11: strcat(array,"Nov ");
                break;
        case 12: strcat(array,"Dec ");
                break;
        default: strcat(array,"*** ");
    }
    
    sprintf(tmp,"%2u ",tarry[1]);    /* put day of the month in */
    strcat(array,tmp);
    
    if (tarry[3] >= 12)  {          /* set or reset am/pm indicator */
        pmflag = -1;
        if (tarry[3] > 12)
            tarry[3] -= 12;         /* adjust to us normal people */
    }
    else {
        pmflag = 0;                 /* else its AM */
        if (tarry[3] == 0)          /* see if it's 12 AM */
            tarry[3] = 12;
    }
    
    sprintf(tmp,"%2u:",tarry[3]);    /* put hour in */
    strcat(array,tmp);
    
    sprintf(tmp,"%02u:",tarry[4]);    /* put minutes in */
    strcat(array,tmp);
    
    sprintf(tmp,"%02u ",tarry[5]);    /* put seconds in */
    strcat(array,tmp);
    
    strcat(array,(pmflag ? "PM" : "AM"));  /* AM/PM field in */
}


rawdate(array)
char array[];
/*
   Fills a 6 element array with the BCD 
   time from the MM58167 clock chip in
   the following form:

      Element    Contents (in Decimal)
      -------    ---------------------------
         0       Month Number (1-12)
         1       Day of the Month (1-31)
         2       Day of the Week (1-7)
         3       Hours (0-23)
         4       Minutes (0-59)
         5       Seconds (0-59)
*/
{
    int i,j,flg,cbase;

    sscanf(BSTRING,"%*s 0x%x",&cbase);  /* get base address from string */

    /* get time in BCD first */
    do {    /* Until the time is read twice and both are identical */
        for (i=0, j=7; i<=5; i++, j--) 
            array[i] = inp(cbase+j);
        
        flg = 0;   /* clear flag */
        for (i=0, j=7; i<=5; i++, j--) 
            if (array[i] != inp(cbase+j))
                flg = 1;  /* because they are not equal try again */
    }
    while (flg);   /* Check status bit */

    /* convert from BCD to Decimal */
    for (i=0; i<=5; i++)
        array[i] = ((array[i] >> 4) & 0x0f)*10 + (array[i] & 0x0f);
}

    
setraw(array)
char array[];
/*
    Set date and time from 'array' in the following form:
    (Distroys 'array')

      Element    Contents (in Decimal)
      -------    ---------------------------
         0       Month Number (1-12)
         1       Day of the Month (1-31)
         2       Day of the Week (1-7)
         3       Hours (0-23)
         4       Minutes (0-59)
         5       Seconds (0-59)

*/
{
    int i,j,cbase;

    sscanf(BSTRING,"%*s 0x%x",&cbase);
    
    for (i=0; i<=5; i++)         /* convert to BCD first */
        array[i] = (array[i]/10 << 4) | (array[i]-array[i]/10*10);

    outp(cbase+0x12,0xff);      /* reset all the counters */
    
    for (i=0, j=7; i<=5; i++, j--)  /* set date and time */
        outp(cbase+j,array[i]);
}


