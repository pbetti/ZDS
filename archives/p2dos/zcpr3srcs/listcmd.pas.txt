program list_cmd;

(*----------------------------------------------------------------------------
Ver 1.0 - Program to display internal ARUNZ commands from ARUNZ.CMD file on
          current disk/user, or the alternate designated disk drive.

          3/30/88 - Al Heynneman

          70110,611 on Compuserve
          HEYNNEMAN on Genie
          CL0798 on the Source
----------------------------------------------------------------------------*)

const drive             = 'M:';
      version           = '1.0';

var   end_of_first_word : integer;
      cmdcount          : integer;
      cmdfile           : text;
      cmdline           : string[200];
      command_is        : string[20];
      exist             : boolean;
      horz_pos          : integer;
      vert_pos          : integer;

begin
  if (paramcount > 0) then
  begin
    clrscr;
    writeln('LIST_CMD Version ',version);
    writeln;
    writeln('LIST_CMD will display the internal ARUNZ commands that are found');
    writeln('in ARUNZ.CMD in the currently logged in disk drive and user area,');
    writeln('or alternatively on drive ',drive,' (current user area).');
    writeln;
    writeln('If commands are more than 18 characters long, they are truncated,');
    writeln('shown in alternate video mode, and end in + to indicate truncation.');
    writeln;
    writeln('To change the default, alternate location of the ARUNZ.CMD file,');
    writeln('you must first edit, and then recompile this program.');
    exit;
  end;

  assign(cmdfile,'alias.cmd');
  (*$I-*)
  reset(cmdfile);
  (*$I+*)
  exist := (IOresult = 0);

  if not exist then
  begin
    assign(cmdfile,drive + 'alias.cmd');
    (*$I-*)
    reset(cmdfile);
    (*$I+*)
    exist := (IOresult = 0);
  end;

  if not exist then
  begin
    writeln;
    writeln(chr(7),'ALIAS.CMD file not found on current drive,');
    writeln('or on alternate drive ',drive,' (current user area).');
    exit;
  end;

  clrscr;
  writeln('ARUNZ.CMD commands are:');
  cmdcount := 0;
  horz_pos := 1;
  vert_pos := 3;

  while not EOF(cmdfile) do
  begin
    repeat
      readln(cmdfile,cmdline);
      end_of_first_word := pos(chr(9),cmdline);
      if (end_of_first_word = 0) then end_of_first_word := pos(' ',cmdline);
    until (end_of_first_word > 1) and (not (ord(cmdline[1]) in [9,32]));

    command_is := copy(cmdline,1,end_of_first_word - 1);
    if (length(command_is) > 18) then
    begin
      command_is := copy(cmdline,1,18);
      command_is[18] := '+';
    end;

    cmdcount := cmdcount + 1;
    gotoxy(horz_pos,vert_pos);
    if (command_is[18] = '+') then lowvideo;
    write(command_is);
    fillchar(command_is,20,32);
    normvideo;
    horz_pos := horz_pos + 20;
    if (cmdcount = 4) then
    begin
      cmdcount := 0;
      horz_pos := 1;
      vert_pos := vert_pos + 1;
      writeln;
      if (vert_pos = 23) then
      begin
        gotoxy(1,24);
        write('Hit RETURN to continue display...');
        repeat until keypressed;
        horz_pos := 1;
        vert_pos := 1;
        clrscr;
      end;
    end;
  end;

  close(cmdfile);
end.