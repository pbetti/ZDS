            MTBASIC Version 2.6
 
 
    MTBASIC now supports user defined multi-line functions. In
addition, the CODE statement has been added to allow the insertion
of in-line machine code.
 
 
               CODE statement
 
    The CODE statement may be used to insert machine language statements
in-line with your Basic program. This should ONLY be done by
experienced machine language programmers. The format of the
CODE statement is:
 
10 CODE <list of hex machine codes>
 
  For example,
 
10 CODE $21,0,0
 
    This statement puts a "LD HL,0" instruction in memory.
 
    The code is generated at the indicated line number. You can
'flow into' the machine code, or reference it by a GOTO the
line number.
 
    It is also possible to write a subroutine with CODE statements,
and to then access it with a GOSUB. However, you MUST return from
the subroutine with a Basic RETURN, as follows:
10 CODE $21,0,0
20 CODE $3E,0
30 RETURN
 
    You may use any Z-80 register in your code; MTBASIC does not 
expect you to preserve the registers. You may NOT use the alternate
register set.
 
    CODE statements may be put inside of function definitions.
 
    The arguments given to a CODE statement MUST be numbers.
Expressions like $41-$22 are not allowed. MTBASIC simply copies the
argument to memory.
 
 
 
               Functions
 
    You may now define your own functions in MTBASIC. A function
definition may be any number of lines long. All functions must be
defined as follows:
 
10  DEF  <function name>
20  <function definition>
30  FNEND
 
    DEF indicates the start of a definition. FNEND indicates the
end of a definition.
 
    The <function name> may be a 7 character name which follows the
same rules as for variables. The name must be declared in a
INTEGER, REAL, or STRING statement, so MTBASIC knows what mode 
the function is.  The function name may have arguments in
parenthesis. These arguments must also be declared.
 
    The arguments are true variables. When the function is
called, the parameters passed to the function will be
copied to these variables. They should have unique names.
 
    Note that when a function is declared in an INTEGER, REAL,
or STRING statement, its arguments should not be given. For example,
 
10 INTEGER FUNCT
20 REAL A,B,C
30 DEF FUNCT(A,B,C)
40 FNEND
 
    Functions must be defined BEFORE they are used. It's a good
idea to put all function definitions near the beginning of
your program, after the variable definitions. If a function
is referenced before it is declared, a FUNCTION ERROR will
result.
 
    A maximum of 64 functions may be defined in one program.
 
    Function definitions may not be nested. A FUNCTION ERROR
will result if a DEF statement is found inside of a function
definition.
 
    Function names must be unique. If they're not, a FUNCTION
ERROR will result.
 
    Arrays may not be used as arguments to functions. Only
simple strings, reals or integers are legal.
 
    The result of a function may be assigned to the function's
name. To do this, in the function definition use an assignment
statement to place the desired value in the function's name.
(I.e., the function's name is referenced like a variable).
In the assignment statement, do NOT specify the function's
arguments on the left hand side of the '=' sign. For example,
the following function returns the value 1:
10 INTEGER FN1
20 DEF FN1
30 FN1=1
40 FNEND
50 PRINT FN1  : ' the value 1 will be printed
 
    The following function returns the sum of its arguments:
 
10 INTEGER FN1,A,B,C
20 DEF FN1(A,B,C)
30 FN1= A+B+C
40 FNEND
50 PRINT FN1(1+2+3)
 
    Note that in lines 10 and 30 the function is referred to without
it's arguments.
 
    Here's another example. This function returns the left N characters
of a string:
10 STRING LEFT$(127),A$(127)
20 INTEGER N
30 DEF LEFT$(A$,N)
40 LEFT$=MID$(A$,1,N)
50 FNEND
60 PRINT LEFT$("ABCDEF",3) : ' prints ABC
 
 
    One function may reference another. For example, the following
is legal:
10 INTEGER FNA,FNB
20 DEF FNB: FNB=1: FNEND
30 DEF FNA: FNA=FNB: FNEND
 
    If the functions use strings, and functions call each other,
the error "STRING SPACE EXCEEDED" will result if too many functions
have partial string results stored in internal temporary storage.
If this message appears, you've called too many functions that
need intermediate string storage. Simplify your code somewhat.
 
    Don't attempt to perform console inputs and outputs inside
of a function if you're multitasking. Your program may "hang
up", since MTBASIC blocks console access during some multitasking 
operations.
 
    Functions are not recursive. A function may not call itself,
either directly or indirectly.
 
 
		CALL statement
 
    The arguments on the CALL statement line may be arrays,
constants, variables, etc. However, since MTBASIC references
array elements indirectly, data may be passed FROM an array
TO a machine language program, but not the other way. If you wish 
to pass an argument BACK to the Basic program from your machine
language routine, do it thru an intermediate variable, as follows:
 
10 CALL $9000,K
20 A(3)=K
 
 
		DATA statements
 
    ALL data statements must be in your program before the FIRST
read statement. When the first READ statement is encountered,
MTBASIC figures out where all of the DATA statements are.
/h~#Õ