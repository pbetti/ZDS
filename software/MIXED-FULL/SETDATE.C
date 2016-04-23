#define TITLE "Setdate        Version 0.0         04-20-84"
#define NOTICE "Copyright (c) 1984 Kenmore Computer Technologies"
/*
    Program Name: 
    Purpose: 

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

main()
{
    char tarry[6];      /* define array for raw date and time */
    char line[80];      /* place to read line into */
    
    printf("%s\n%s\n\n",TITLE,NOTICE);
    
    puts("Enter Month (1-12): ");
    scanf("%u",&tarry[0]);

    puts("Enter Day of the Month (1-31): ");
    scanf("%u",&tarry[1]);
    
    puts("Enter Day of the Week (1-7, where Sunday=1): ");
    scanf("%u",&tarry[2]);
    
    puts("Enter Hour (1-12): ");
    scanf("%u",&tarry[3]);

    puts("Enter AM or PM: ");
    scanf("%s",line);
    if (toupper(line[0]) == 'A') {  /* if it is AM */
        if (tarry[3] == 12)       /* midnight */
            tarry[3] = 00;
    }
    else                            /* if it's PM */
        if (tarry[3] < 12)          /* if after 12 PM add 12 to time */
            tarry[3] += 12;
       
    puts("Enter Minute (0-59): ");
    scanf("%u",&tarry[4]);
    
    puts("Enter Seconds (0-59): ");
    scanf("%u",&tarry[5]);
    
    puts("\nPress any key when it is the exact time as stated: ");
    getchar();
    
    setraw(tarry);     /* call routine to set raw time */
    
    getdate(line);     /* get current time */
    
    printf("\n\nThe current time and date is: %s",line);
}
