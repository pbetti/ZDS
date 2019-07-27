-- VHDL test bench created from symbol mmu_gal.sym -- Jun 25 12:16:52 2015

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

   signal       A0 : std_logic;
   signal       A1 : std_logic;
   signal       A2 : std_logic;
   signal       A3 : std_logic;
   signal       A4 : std_logic;
   signal       A5 : std_logic;
   signal       A6 : std_logic;
   signal       A7 : std_logic;
   signal     IORQ : std_logic;
   signal       WR : std_logic;
   signal       RD : std_logic;
   signal       M1 : std_logic;
   signal    MMUWR : std_logic;
   signal    MMURD : std_logic;
   signal      RST : std_logic;
   signal   MEMENA : std_logic;

   component MMU_GAL
      Port (      A0 : In    std_logic;
                  A1 : In    std_logic;
                  A2 : In    std_logic;
                  A3 : In    std_logic;
                  A4 : In    std_logic;
                  A5 : In    std_logic;
                  A6 : In    std_logic;
                  A7 : In    std_logic;
                IORQ : In    std_logic;
                  WR : In    std_logic;
                  RD : In    std_logic;
                  M1 : In    std_logic;
               MMUWR : Out   std_logic;
               MMURD : Out   std_logic;
                 RST : In    std_logic;
              MEMENA : In    std_logic );
   end component;

begin
   UUT : MMU_GAL
      Port Map ( A0=>A0, A1=>A1, A2=>A2, A3=>A3, A4=>A4, A5=>A5, A6=>A6,
                 A7=>A7, IORQ=>IORQ, M1=>M1, MEMENA=>MEMENA,
                 MMURD=>MMURD, MMUWR=>MMUWR, RD=>RD, RST=>RST, WR=>WR );

-- *** Test Bench - User Defined Section ***
   TB : process
   begin
      wait; -- will wait forever
   end process;
-- *** End Test Bench - User Defined Section ***

end behavior;

