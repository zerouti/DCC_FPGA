


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MAE is
    Port (
           Reset 	: in STD_LOGIC;		-- Reset Asynchrone
           clk 	: in STD_LOGIC;		-- Horloge 100 MHz de la carte Nexys     
             -- entre MAE   
           FIN_1 : in STD_LOGIC; -- FIN_1 la sortie de BIT_DCC pour indiquer a la machine etat la fin de generation 1 ( sortie DCC_BIT1)
           FIN_0 : in STD_LOGIC; -- FIN_0 la sortie de BIT_DCC pour indiquer a la machine etat la fin de generation 0 ( sortie DCC_BIT0)     
           FIN_tempo: in STD_LOGIC; -- Lorsque ce délai (6us) est écoulé, un signal Fin_Tempo est mis à 1 pour séparer les trames 
           FIN_trame: in STD_LOGIC;  -- FIN_trame ce signal indique a la machine état la fin de trame 
           REG_DCC_MSB: in STD_LOGIC; -- entrée serie de registre DCC (bit de poid fort ) par  decalage a gauche  c'est la sortie de registre DCC
           Data_Ready : in std_logic; -- la sortie de registre DCC permet d'inqiuer qu'on a bien chargé la trame a envoyé dans le registre DCC 
           -- sortie MAE
           START_tempo : out STD_LOGIC; -- la sortie START_tempo pour dire  au tempo commence a compter  
           GO_1 : out STD_LOGIC ; -- la sortie GO_1 pour dire au module DCC_BIT1 pour générer un 1 
           GO_0 : out STD_LOGIC ;  -- la sortie GO_0 pour dire au module DCC_BIT0 pour générer un 0          
           COM_reg : out STD_LOGIC_vector(1 downto 0 ) -- COM_reg est un vecteur sur deux bits (4 cas ) pour dire au registre de faire : la memeoire , reset , chargement parallele , decalage  
   );	
end MAE;

architecture Behavioral of MAE is

type etat is(S0,S1,S2,S3,S4,S5); -- on a 6 état ( voir le graphe d'etat ) 
signal EP, EF: etat;
begin
-- Process du Registre d'etats
process(clk,Reset)
    begin
    -- Reset asynchrone
        if Reset='1' then EP <= S0;
         elsif rising_edge(clk) then EP <= EF;
    end if; 
end process;


process(EP,FIN_trame,FIN_tempo,FIN_0,FIN_1,REG_DCC_MSB,Data_Ready)
    begin
        case (EP) is
             when S0 => EF<=S0; if FIN_tempo='1'  and Data_Ready = '0' then EF<=S2 ; -- on passe a l'etat s2 si le tempo a terminé et la trame n'est pas chargé (trame idle chargé automatiquement )
                                elsif FIN_tempo='1'  and Data_Ready = '1' then EF<=S1 ;  end if; -- on passe a l'etat s2 si le tempo a terminé et la trame est chargé
             when S1 => EF<=S2; 
             when S2 => EF<=S2;  if FIN_trame='1' then EF<=S0; -- si fin trame a 1 on revient a l'etat 0 ( la fin de trame ) 
                                 elsif REG_DCC_MSB='0' then EF<=S3; -- si la trame serie egale 0 on va a l'etat S3 pour génerer 0  
                                 else EF<=S4; end if;   -- si la trame serie egale 1 on va a l'etat S4 pour génerer 1  
             when S3 => EF<=S5; -- etat s5 pour decaler la trame
             when S4 => EF<=S5; -- etat s5 pour decaler la trame
             when S5 => EF<=S5; if FIN_1='1'or FIN_0='1' then EF<=S2; end if ; -- revenir a l'etat s2 
        end case;
end process;



process(EP)
    begin
     
        case (EP) is
             when S0 => START_tempo<='1' ; COM_reg <= "01" ;  GO_1<='0';GO_0<='0'; --demmarer de tempo et chargement de trame idle 
             when S1 => COM_reg <= "11" ;START_tempo<='0' ; GO_1<='0';GO_0<='0'; --- charment de trame 
             when S2 => COM_reg <= "00" ;GO_1<='0';GO_0<='0';START_tempo<='0' ; -- memoire 
             when S3 => GO_0<='1';GO_1<='0'; COM_reg <= "10" ;START_tempo<='0' ; -- generation de 0 et decalge de trame 
             when S4 => GO_1<='1';GO_0<='0';  COM_reg <= "10" ;START_tempo<='0' ; --generation de 1 et decalge de trame 
             when S5 =>GO_1<='0';GO_0<='0';COM_reg <= "00" ;START_tempo<='0' ; -- mémoire 
        end case;
end process;

end Behavioral;
