library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity registre_dcc is
  Port (    clk : in std_logic; -- horloge de 100 Mhz 
            reset : in std_logic; -- reset asynchrone 
            Com_Reg : in std_logic_vector(1 downto 0); -- commande de registre pour modifier le mode de fonctionnement de registre 
            Fin_Trame : out std_logic; -- fin trame pour indiquer que la trame est finie 
            Reg_DCC_MSB : out std_logic; -- la sortie en serie de registre 
            Read_Flag : out std_logic; -- signal  pour dire que la trame est^prete a envoyer 
            Trame_DCC 	: in STD_LOGIC_VECTOR(50 downto 0)  -- la trame a chargé dans le registre dcc 
  );
end registre_dcc;

architecture Behavioral of registre_dcc is
    signal Reg_DCC : std_logic_vector(50 downto 0);

begin

   process(clk,reset) 
        begin
        if reset='1' then Reg_DCC<=(others => '0');
        elsif rising_edge(clk) then
            
            case(Com_Reg) is
                when "01" => Reg_DCC<="111111111111011111111000000000011111111100000000000";Read_Flag<='0'; -- RAZ
                when "10" => Reg_DCC <= Reg_DCC(49 downto 0)&'0' ;Read_Flag<='0'; -- Decalage
                when "11" => Reg_DCC <= Trame_DCC;Read_Flag<='1'; -- chargement //
                when others => Reg_DCC <= Reg_DCC;Read_Flag<='0'; -- mémorisation
            end case;            
            
            
        end if;
    end process;
    Fin_Trame <= '1' when Reg_DCC(50 downto 35) = "0000000000000000" else '0'; -- fin trame egale a un si les 16 dernier bits sont nulles 
    Reg_DCC_MSB <= Reg_DCC(50);
end Behavioral;