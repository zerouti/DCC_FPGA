library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity top_dcc is
  Port (    clk : in std_logic; -- horloge de 100 Mhz 
            reset : in std_logic; -- reset asynchrone 
            Signal_DCC : out std_logic; -- trame envoyé au train 
            Data_Ready : in std_logic; -- une nouvelle trame  est pret a etre chargé   
            Read_Flag : out std_logic; -- pour indiquer que la trame est bien chargé sur notre registre 
            Interrupteur : in STD_LOGIC_VECTOR(7 downto 0) -- pour choisir la trame a envoyé 
              
  );
end top_dcc;

architecture Behavioral of top_dcc is
    signal Trame_DCC 	:  STD_LOGIC_VECTOR(50 downto 0) ;
begin

    centrale_dcc0 : entity work.Centrale_dcc -- centrale dcc avec tout les module qui gere l'envoie de trame bit par bit 
        port map(
            clk => clk,
            reset=> reset,
            Signal_DCC =>Signal_DCC,
            Data_Ready =>Data_Ready,
            Read_Flag =>Read_Flag,
            Trame_DCC=>Trame_DCC
        );
    


    dcc_trame : entity work.DCC_FRAME_GENERATOR  -- le fichier des trames pour une composition des interepteur donnée 
        port map(  
        
         Interrupteur	=>	Interrupteur , 
           Trame_DCC    =>Trame_DCC 
        );
    
  

end Behavioral;