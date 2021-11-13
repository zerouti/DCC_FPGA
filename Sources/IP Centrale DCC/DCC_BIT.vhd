library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DCC_BIT is
    generic( N: natural :=100); -- N pour modifier le delai depend de protocole DCC 
    Port (  clk : in std_logic; -- horloge de 100 MHz
            clk1MHz : in std_logic; -- horloge de 1 MHz
            reset : in std_logic;  -- remise à zeros 
            GO : in std_logic; -- La commande Go active la génération du bit.
            Fin : out std_logic; -- Fin indique que la transmission du bit est terminée
            DCC_out : out std_logic); -- en sortie de module on a DCC_Bit_0 ou DCC_Bit_1 ca depent les délais requis par le protocole DCC. 
            
end DCC_BIT;

architecture Behavioral of DCC_BIT is
signal cpt : integer range 0 to (N+N)-1; -- un compteur pour compter jusqu'a 2*N-1.
signal enable : std_logic; -- enable pour indiquer au compteur le moment ou on compte.  
signal raz : std_logic; -- pour mettre le compteur a zeros 
signal Signal_DCC_memoire : std_logic; -- ce signal sert a mémoriser le signal Signal_DCC
signal Signal_DCC : std_logic; -- Signal_DCC represent la sortie DCC_out
begin
	process(clk1MHz,reset)
	begin
		-- Reset Asynchrone
        if reset = '1' then Cpt <= 0;
        elsif rising_edge(clk1MHz) then
            if raz = '1' then Cpt<=0;  -- Reset synchrone
            elsif enable='1' then Cpt <= Cpt + 1;	-- Incrémentation CPT
            end if;
		end if;
	end process;
	
	DCC_out <= Signal_DCC; -- afféctation de notre signal a la sortie DCC_out
	Signal_DCC <= '1' when cpt >= N else '0'; -- signal_dcc a 1 si on arrive a la valeur N

	Fin<='1' when (Signal_DCC ='0' and Signal_DCC_memoire='1') else '0'; -- mettre fin a '1' si on a un front descendant de signal_dcc
	
    process(clk,reset)
        begin
        if reset='1' then enable<='0'; raz<='0'; Signal_DCC_memoire<='0'; -- Reset Asynchrone
        elsif rising_edge(clk) then 
            if GO = '1' then enable <= '1';raz<='0'; -- si go a 1 on change l'état de enable=1 
            elsif (enable ='1' and Cpt=(N+N)-1) then enable <= '0'; raz<='1'; -- on compte si enable a 1
            end if;
            Signal_DCC_memoire<=Signal_DCC; -- memoire 

        end if;
    end process;

end Behavioral;
