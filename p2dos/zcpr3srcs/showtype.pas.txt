program showtype;

{ 4/10/88 - Al Heynneman, creation date

            70110,611 on CompuServe
            HEYNNEMAN on Genie
            CL0798 on the Source

            NOTE: Also download my Z3INS version 1.5 if you
                  are still running ZCPR30 and wish to use the
                  newer ZCPR33 utilities.
}

const version  = '1.0';

type   z3header = record
                    jump_type   : byte;
                    filler1     : byte;
                    filler2     : byte;
                    z3env       : array[1..5] of byte;
                    env_type    : byte;
                    filler3     : array[1..119] of byte; {make it 128 bytes}
                  end;

var    comfile  : file;
       header   : z3header;
       IOstatus : integer;

begin
  if (paramcount =0) or (paramstr(1) = '//') then
  begin
    clrscr;
    writeln('SHOW_TYPE Version ',version);
    writeln;
    writeln('Displays ZCPR compatibility information for a selected .COM file.');
    writeln;
    writeln('ZCPR30 type programs need to be installed with Z3INS or Z-RIP to');
    writeln('run under ZCPR30.');
    writeln;
    writeln('ZCPR33 type programs do not need installation to run under ZCPR33,');
    writeln('but require installation with Z3INS version 1.5 to run under ZCPR30.');
    writeln('The bell will ring when a ZCPR33 compatible file is found.  This is');
    writeln('useful when performing a search like "W SHOWTYPE *.COM" using the');
    writeln('W20 shell to find all ZCPR33 .COM programs.');
    writeln;
    writeln('syntax : showtype');
    writeln('         showtype //');
    writeln('         showtype <filename> [/options]');
    writeln('options:');
    writeln('         B = disable the bell when a ZCPR33 type file is found.');
    writeln('         D = debug mode, print bytes that we use in SHOW_TYPE.');
    exit;
  end;

  if (pos('COM',paramstr(1)) = 0) then
  begin
    writeln;
    writeln(paramstr(1),' is not a .COM file, try again.');
    exit;
  end;

  assign(comfile,paramstr(1));
  {$I-}
  reset(comfile);
  {$I+}
  IOstatus := IOresult;
  if not (IOstatus = 0) then
    begin
      close(comfile);
      writeln;
      if (IOstatus = 1) then
        writeln(paramstr(1),' file not found.')
        else
        writeln('SHOW_TYPE abort, IOerror # ',IOstatus);
      exit;
    end;

  blockread(comfile,header,1); {read 1 128 block}

  writeln;

  if (pos('D',paramstr(2)) <> 0) then
  begin
    writeln('jump byte value is ',header.jump_type);
    writeln('z3env byte[1] is ',header.z3env[1]);
    writeln('z3env byte[2] is ',header.z3env[2]);
    writeln('z3env byte[3] is ',header.z3env[3]);
    writeln('z3env byte[4] is ',header.z3env[4]);
    writeln('z3env byte[5] is ',header.z3env[5]);
    writeln('environment byte is ',header.env_type);
    writeln;
  end;

  if (header.z3env[1] = 90) and
     (header.z3env[2] = 51) and
     (header.z3env[3] = 69) and
     (header.z3env[4] = 78) and
     (header.z3env[5] = 86) then
  begin
    if (header.jump_type = 24) then
    begin
      writeln(paramstr(1),' is a ZCPR33 compatible program.');
      if not (pos('B',paramstr(2)) <> 0) then write(chr(7));
    end;
    if (header.jump_type = 195) then
    begin
      writeln(paramstr(1),' is a ZCPR30 compatible program.');
    end;
  end

  else

  begin
    writeln(paramstr(1),' is not a ZCPR program.');
    exit;
  end;

  close(comfile);
end.