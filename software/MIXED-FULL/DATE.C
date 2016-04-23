#define TITLE "Date      Version 0.0      04-18-84"
#define NOTICE "Copyright (c) 1984 Kenmore Computer Technologies"
/*
    Program Name: Date
    Purpose: To print the current time and date

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
    char darry[23];       /* Array to hold the formated time and date */
    
    printf("%s\n",TITLE); /* Title of program */
    printf("%s\n\n",NOTICE); /* to protect us */
    
    getdate(darry);       /* Get the formatted date and time into the array */
    
    printf("The current date and time is: %s",darry);
}
    
