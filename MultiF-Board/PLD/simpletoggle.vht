-- VHDL test bench created from symbol simpletoggle.sym -- Jun 14 19:53:54 2014

LIBRARY vanmacro;
USE vanmacro.components.ALL;
LIBRARY ieee;
LIBRARY generics;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE generics.components.ALL;

entity testbench is
end testbench;

Architecture behavior of testbench is

   signal        T : std_logic;
   signal        R : std_logic;
   signal       Q0 : std_logic;
   signal       Q1 : std_logic;

   component SIMPLETOGGLE
      Port (       T : In    std_logic;
                   R : In    std_logic;
                  Q0 : Out   std_logic;
                  Q1 : Out   std_logic );
   end component;

begin
   UUT : SIMPLETOGGLE
      Port Map ( Q0=>Q0, Q1=>Q1, R=>R, T=>T );

-- *** Test Bench - User Defined Section ***
   TB : process
   begin
      wait; -- will wait forever
   end process;
-- *** End Test Bench - User Defined Section ***

end behavior;

