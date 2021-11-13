library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sept_segment is
Port ( 
    clk : in STD_LOGIC; -- horloge de 100Mhz 
    reset : in STD_LOGIC;  -- reset asynchrone 
    affichage_sept_segments : in STD_LOGIC_VECTOR (63 downto 0); --  les 8 diodes alumée pour chacun de 7 segment 8*8 =64 , octet de poid faible pour le 7 segment a droite et octet de poid fort pour le 7 segment a gauche
    anodes_sept_segments : out STD_LOGIC_VECTOR (7 downto 0); -- les anodes de 7 segement 
	cathodes_sept_segment : out STD_LOGIC_VECTOR(7 downto 0) -- les cathodes de 7 segments 
    ); 
           
end sept_segment;

architecture Behavioral of sept_segment is
signal compteur : std_logic_vector(19 downto 0); -- compteur de 20 bits 
signal cpt : std_logic_vector(2 downto 0); -- cpt prend la valeur des 3 bit poid fort de compteur pour controler les anodes et cathodes de 7 segment

begin

process(clk,reset)
	begin
	
		if reset = '1' then compteur <= (others => '0');
		elsif rising_edge(clk) then
			compteur <= compteur + '1';
		end if;

end process;

cpt<=compteur(19 downto 17); 
--Grace à ce compteur on vas pouvoir laisser un seul des 7 segement allumé pour afficher une valleur dessus puis passer au suivat
--La fréquence est suffisament éléver pour que la persistance rétinienne ne constate pas que seulement un des afficheur est allumé
--Elle est aussi suffisament faible pour que les led ais le temps de s'allumé.

process(cpt,affichage_sept_segments)
begin
 
 
    case cpt is
        when "000" =>        -- pour afficher le 7 segment a droite 
        anodes_sept_segments <= "11111110"; --0000 0008
        cathodes_sept_segment <= affichage_sept_segments(7 downto 0);
        
        when "001" =>       -- pour afficher le 7 segment qui suit   
        anodes_sept_segments <= "11111101"; --0000 0080
        cathodes_sept_segment <= affichage_sept_segments(15 downto 8);
        
        when "010" =>        
        anodes_sept_segments <= "11111011"; --0000 0800
        cathodes_sept_segment <= affichage_sept_segments(23 downto 16);
    
        when "011" =>        
        anodes_sept_segments <= "11110111"; --0000 8000
        cathodes_sept_segment <= affichage_sept_segments(31 downto 24);
        
        when "100" =>        
        anodes_sept_segments <= "11101111"; --0008 0000 
        cathodes_sept_segment <= affichage_sept_segments(39 downto 32);
        
        when "101" =>        
        anodes_sept_segments <= "11011111";  --0080 0000 
        cathodes_sept_segment <= affichage_sept_segments(47 downto 40);
        
        when "110" =>        
        anodes_sept_segments <= "10111111"; --0800 0000 
        cathodes_sept_segment <= affichage_sept_segments(55 downto 48);
    
        when "111" =>        
        anodes_sept_segments <= "01111111"; --8000 0000 -- pour afficher le 7 segment a gauche 
        cathodes_sept_segment <= affichage_sept_segments(63 downto 56);
        
        when others => NULL;
	
    end case;
end process;

end architecture;