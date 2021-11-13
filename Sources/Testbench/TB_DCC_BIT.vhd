library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_textio.all;


entity tb_dcc_bit is
end tb_dcc_bit;

architecture Behavioral of tb_dcc_bit is
    signal clk : std_logic:='1';
    signal reset : std_logic:='1';
    signal clk1MHz : std_logic:='1';
    signal GO_1,GO_0 : std_logic:='0';
    signal Fin_1,Signal_DCC_1,Fin_0,Signal_DCC_0,Signal_DCC : std_logic;
    signal test_Fin_1,test_Fin_0,test_Signal_DCC : std_logic:='0';
    
    procedure check(signal Fin_1, Fin_0, Signal_DCC, test_Fin_1, test_Fin_0,test_Signal_DCC : in std_logic) is
    begin
        assert Fin_0=test_Fin_0 and Fin_1=test_Fin_1 and Signal_DCC=test_Signal_DCC
            report "Error at time = " & time'image(now) & " Expected Fin_0,Fin_1,Signal_DCC = " & std_logic'image(test_Fin_0) &", " & std_logic'image(test_Fin_1) &", "  & std_logic'image(test_Signal_DCC)&", "
                    & "Found Fin_0,Fin_1,Signal_DCC = " & std_logic'image(Fin_0) &", " & std_logic'image(Fin_1) &", "  & std_logic'image(Signal_DCC)&", "
            severity error;
    end procedure check;
    

begin
        
    DCC_BIT_0 : entity work.DCC_BIT 
        generic map(100)
        port map(Reset=>reset,Clk=>clk,clk1MHz=>clk1MHz,GO=>GO_0,Fin=>Fin_0,DCC_out=>Signal_DCC_0);
    
    DCC_BIT_1 : entity work.DCC_BIT 
        generic map(58)
        port map(Reset=>reset,Clk=>clk,clk1MHz=>clk1MHz,GO=>GO_1,Fin=>Fin_1,DCC_out=>Signal_DCC_1);

    Signal_DCC<= Signal_DCC_1 or Signal_DCC_0;
    

    reset <= '0' after 10 ns;
    clk<=not(clk) after 5 ns;
    clk1MHz<=not(clk1MHz) after 500 ns;
    GO_0<='1' after 2 us, '0' after 2.010 us;
    GO_1<='1' after 203 us, '0' after 203.01 us;
    test_Fin_1<='1' after 319 us,'0' after 319.01 us;
    test_Fin_0<='1' after 202 us,'0' after 202.01 us;
    test_Signal_DCC <='1' after 102 us,'0' after 202 us,'1' after 261 us,'0' after 319 us;
    --test_Signal_DCC <='1' after 102 us,'0' after 202 us,'1' after 211 us,'0' after 319 us;
    
    process is begin
        wait for 5 ns;
        --for i in T'range loop
            --wait for (T(i));
        while true loop
            wait for 10 ns;
            check(Fin_1, Fin_0, Signal_DCC, test_Fin_1, test_Fin_0,test_Signal_DCC);
        end loop;
    wait;
    end process;
    
 end Behavioral;