----------------------------------------------------------------------------------
-- Company: UPMC
-- Engineer: Julien Denoulet
-- 
-- Create Date:   	Septembre 2016 
-- Module Name:    	TP_Impulse_Count - Behavioral 
-- Project Name: 		TP1 - FPGA1
-- Target Devices: 	Nexys4 / Artix7

-- XDC File:			Aucun					

-- Description: Testbench du Compteur d'Impulsions
--
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TB_MAE IS
END TB_MAE;
 
ARCHITECTURE behavior OF TB_MAE IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT MAE
    PORT(
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
    END COMPONENT;
    
   --Inputs
   signal Reset : std_logic := '1';
   signal clk : std_logic := '1';
   -- entre
   signal FIN_1,FIN_0,FIN_tempo,FIN_trame,Data_Ready :std_logic:='0'    ;
   signal REG_DCC_MSB : std_logic:='0'  ;
   -- sortie 
   signal START_tempo : std_logic  ;
   signal GO_1 : std_logic  ;
   signal GO_0 : std_logic  ;
   signal COM_reg : std_logic_vector(1 downto 0 ) ;

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MAE PORT MAP (
          Reset => Reset,
          clk => clk,
          
          FIN_1 => FIN_1,
          FIN_0 => FIN_0,
          FIN_tempo => FIN_tempo ,
          FIN_trame =>FIN_trame,
          REG_DCC_MSB=>REG_DCC_MSB,
          Data_Ready=>Data_Ready ,
          
          START_tempo=>START_tempo,
          GO_1=>GO_1,
          GO_0=>GO_0,
          COM_reg=>COM_reg
        );


	-- Evolution des Entrées
	Reset <=  '0' after 10 ns ;
	clk <=not (clk) after 5 ns ; 
	REG_DCC_MSB <= '1' after 1000 ns,'0' after 1050 ns,'0' after 1100 ns,'1' after 1150 ns,'1' after 1200 ns,'0' after 1250 ns;
	FIN_trame <= '1' after 1100 ns ;
	FIN_tempo <='1' after 1000 ns ;
	FIN_1<='1' after 1050 ns ,'0' after 1060 ns;
	FIN_0<='1' after 1100 ns ,'0' after 1110 ns ;
	Data_Ready <= '1' after  900 ns,'0' after  1100 ns  ; 
END;
