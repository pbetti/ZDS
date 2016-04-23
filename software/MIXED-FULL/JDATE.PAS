Program Jdate(output);

{
    JRT Pascal version of Date program.
    Written by: Alan D. Percy
    Date Written: 7/12/84

    Prints date and time from getdate routine.
}
Type
    str80 = string[80];

Var
    darry : str80;       {get ASCII string in here}

function getdate : str80;
{
    Gets an ASCII representation of the
    time and date as follows:
       Mon Jan 23 10:51:32 AM

    calls: rawdate and number
}
Type
    rawtype = array[1..6] of integer;
Var
    rdate : rawtype;     {place to get raw date into}
    tmp : str80;         {place to build string into}
    pmflag : boolean;      {AM/PM flag}

function number(num : integer; flag : boolean) : str80;
{
    This function returns a string with
    the character representation of the
    number passed as the parameter 'num'.
    The parameter 'flag' determines whether
    leading zeros should be given or not
    (false= no, true= yes).

    Limitations:
    Only a two digit number can be converted.
}
Var stmp : str80;
    tmp : integer;

Begin  {of number routine}
    tmp := ord('0')+num div 10;    {figure first character number}
    stmp := chr(tmp);             {put in string}
    if (stmp = '0') and not flag then  {if flag not set and leading zero}
        stmp := ' ';                   {make blank}
    tmp := ord('0')+num-10*(num div 10);   {figure second character number}
    stmp := concat(stmp,chr(tmp));        {tack on to string}
    number := stmp
End;    {of number routine}

procedure rawdate(var raw : rawtype);
{
    Fills a 6 element array of integers
    with the decimal time from the
    MM58167 clock chip addressed at the
    port 'cbase' constant.  The form
    of the array is as follows:

    Element      Contents (in decimal)
    --------     ---------------------
       1         Month number (1-12)
       2         Day of the month (1-31)
       3         Day of the week (1-7)
       4         Hours (0-23)
       5         Minutes (0-59)
       6         Seconds (0-59)
}
const
    cbase = 0e0h;
var
    i, tmp : integer;
    bcddate : rawtype;
    flag : boolean;  {true when read twice the same}
begin   {of rawdate routine}

    {get array filled with BCD value quickly ( < 1 second) }

    repeat  {until read twice the same}
        for i := 1 to 6 do  {read the array in BCD the first time}
            bcddate[i] := ord(portin(cbase+8-i));  {get BCD value from chip}
        flag := true; {assume we get it correct again}
        for i := 1 to 6 do {try again}
            if bcddate[i] <> ord(portin(cbase+8-i)) then
                flag := false {if not the same clear flag and try again}
    until flag;

    {convert from BCD to decimal at our leasure}

    for i := 1 to 6 do Begin
        tmp := bcddate[i] div 16;
        raw[i] := tmp * 10 + (bcddate[i] - tmp * 16)
    end
end;   {of rawdate routine}

Begin {of getdate routine}
    rawdate(rdate);       {read date and time from port}

    case rdate[3] of
        1 : tmp := 'Sun ';
        2 : tmp := 'Mon ';
        3 : tmp := 'Tue ';
        4 : tmp := 'Wed ';
        5 : tmp := 'Thu ';
        6 : tmp := 'Fri ';
        7 : tmp := 'Sat ';
        else : tmp := '*** ';
    end;

    case rdate[1] of
        1 : tmp := tmp + 'Jan ';
        2 : tmp := tmp + 'Feb ';
        3 : tmp := tmp + 'Mar ';
        4 : tmp := tmp + 'Apr ';
        5 : tmp := tmp + 'May ';
        6 : tmp := tmp + 'Jun ';
        7 : tmp := tmp + 'Jul ';
        8 : tmp := tmp + 'Aug ';
        9 : tmp := tmp + 'Sep ';
        10 : tmp := tmp + 'Oct ';
        11 : tmp := tmp + 'Nov ';
        12 : tmp := tmp + 'Dec ';
        else : tmp := tmp + '*** ';
    end;

    tmp := tmp + number(rdate[2],false) + ' ';  {add on day of the month}

    if rdate[4] >= 12 then begin  {if after 12 pm convert from military time}
        pmflag := true;
        if rdate[4] > 12 then
            rdate[4] := rdate[4] - 12
    end
    else begin
        pmflag := false;
        if rdate[4] = 0 then    {if 12 am}
            rdate[4] := 12
    end;

    tmp := tmp + number(rdate[4],false) + ':';   {put hour in}
    tmp := tmp + number(rdate[5],true) + ':';    {put minutes in}
    tmp := tmp + number(rdate[6],true);          {put seconds in}

    if pmflag then
        tmp := tmp + ' PM'
    else
        tmp := tmp + ' AM';

    getdate := tmp

end;   {of getdate routine}


Begin   {of date program}
    darry := getdate;       {get ASCII for of date and time}
    writeln('Jdate: (JRT Pascal version of Date)  Version 1.0  7-30-84');
    writeln('Current date and time is: ',darry)
end.
