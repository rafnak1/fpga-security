--------------------------------------------------------------------------
-- Arquivo   : edge_detector.vhd
-- Projeto   : Experiencia 04 - Desenvolvimento de Projeto de
--                              Circuitos Digitais com FPGA
--------------------------------------------------------------------------
-- Descricao : detector de borda
--             gera um pulso na saida de 1 periodo de clock
--             a partir da detecao da borda de subida sa entrada
--
--             sinal de reset ativo em alto
--
--             > adaptado a partir de codigo VHDL disponivel em
--               https://surf-vhdl.com/how-to-design-a-good-edge-detector/
--------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     29/01/2020  1.0     Edson Midorikawa  criacao
--     27/01/2021  1.1     Edson Midorikawa  revisao
--------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity edge_detector is
    port (
        clock  : in  std_logic;
        reset  : in  std_logic;
        sinal  : in  std_logic;
        pulso  : out std_logic
    );
end entity edge_detector;

architecture rtl of edge_detector is

    signal reg0   : std_logic;
    signal reg1   : std_logic;

begin

    detector : process(clock,reset)
    begin
        if(reset='1') then
            reg0 <= '0';
            reg1 <= '0';
        elsif(rising_edge(clock)) then
            reg0 <= sinal;
            reg1 <= reg0;
        end if;
    end process;
    
    pulso <= not reg1 and reg0;

end architecture rtl;