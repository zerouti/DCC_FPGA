library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Centrale_dcc is
  Port (    clk : in std_logic; -- horloge de 100 Mhz 
            reset : in std_logic; -- reset asynchrone 
            Signal_DCC : out std_logic;-- trame envoyé au train 
            Data_Ready : in std_logic;-- une nouvelle trame  est pret a etre chargé  
            Read_Flag : out std_logic;-- pour indiquer que la trame est bien chargé sur notre registre 
            Trame_DCC 	: in STD_LOGIC_VECTOR(50 downto 0)   -- pour choisir la trame a envoyé 
  );
end Centrale_dcc;

architecture Behavioral of Centrale_dcc is
    signal GO_0,GO_1,Start_Tempo : std_logic;
    signal Com_Reg : std_logic_vector(1 downto 0);
    signal Fin_Trame,Fin_Tempo,Reg_DCC_MSB : std_logic;
    signal clk1MHz : std_logic;
    signal Fin_1,Signal_DCC_1,Fin_0,Signal_DCC_0 : std_logic;
    
begin

Signal_DCC<= Signal_DCC_0 or Signal_DCC_1;


    CLK_DIV : entity work.CLK_DIV 
        port map(Reset=>reset,Clk_In=>clk,Clk_Out=>clk1MHz);
    
    TEMPO : entity work.COMPTEUR_TEMPO 
        port map(Reset=>reset,Clk=>clk,Clk1M=>clk1MHz,Start_Tempo=>Start_Tempo,Fin_Tempo=>Fin_Tempo);
    
    DCC_BIT_0 : entity work.DCC_BIT 
        generic map(100)
        port map(Reset=>reset,Clk=>clk,clk1MHz=>clk1MHz,GO=>GO_0,Fin=>Fin_0,DCC_out=>Signal_DCC_0);
    
    DCC_BIT_1 : entity work.DCC_BIT 
        generic map(58)
        port map(Reset=>reset,Clk=>clk,clk1MHz=>clk1MHz,GO=>GO_1,Fin=>Fin_1,DCC_out=>Signal_DCC_1);

    REG_DCC : entity work.registre_dcc
        port map(   clk=>clk,
                    reset=>reset,
                    Com_Reg=>Com_Reg,
                    Fin_Trame=>Fin_Trame,
                    Reg_DCC_MSB=>Reg_DCC_MSB,
                    Read_Flag => Read_Flag,
                    Trame_DCC=>Trame_DCC);
    
    MAE : entity work.MAE
        port map(   clk=>clk,
                    reset=>reset,
                    FIN_0=>FIN_0,
                    FIN_1=>FIN_1,
                    Com_Reg=>Com_Reg,
                    Fin_Trame=>Fin_Trame,
                    Reg_DCC_MSB=>Reg_DCC_MSB,
                    FIN_tempo=>FIN_tempo,
                    START_tempo=>START_tempo,
                    GO_1=>GO_1,
                    GO_0=>GO_0,
                    Data_Ready =>Data_Ready );

end Behavioral;