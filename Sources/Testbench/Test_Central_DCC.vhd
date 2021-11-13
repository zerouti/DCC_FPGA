library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Test_top_DCC is
end Test_top_DCC;

architecture Behavioral of Test_top_DCC is
    signal clk : std_logic:='1';
    signal reset : std_logic:='1';
    signal Signal_DCC : std_logic;
    signal  Data_Ready :  std_logic;
    signal  Read_Flag :  std_logic;
    signal Interrupteur : STD_LOGIC_VECTOR(7 downto 0)	;
    
begin

    test_centrale_dcc: entity work.top_dcc 
        port map(reset=>reset,
        clk=>clk,
        Signal_DCC=>Signal_DCC,
        Data_Ready=>Data_Ready,
        Read_Flag=>Read_Flag,
        Interrupteur=>Interrupteur
        );
	
	
	Reset <=  '0' after 10 ns ;
	clk <=not (clk) after 5 ns ; 
	
	Data_Ready<='0','1' after 5 ms,'0' after 7 ms,'1' after 15 ms,'0' after 23 ms; -- data_ready ( le bouton poussoir ) pour laquelle la trame est prete a envoyer
    Interrupteur <= "10000000","01000000" after 10 ms ; -- choisir deux trame deferente 
end Behavioral;
