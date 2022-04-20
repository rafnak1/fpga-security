library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fluxo_dados is
  port (
     clock                         : in  std_logic;
     zeraES                        : in  std_logic;
     contaES                       : in  std_logic;
     zeraE                         : in  std_logic;
     contaE                        : in  std_logic;
     zeraTMR                       : in  std_logic;
     contaTMR                      : in  std_logic;
     zeraMarca                     : in  std_logic;
     contaMarca                    : in  std_logic;
     escreve                       : in  std_logic;
	  escrevep                      : in  std_logic;
     limpaR                        : in  std_logic;
     registraR                     : in  std_logic;
	  limpaP                        : in  std_logic;
	  registraP                     : in  std_logic;
	  limpaU                        : in  std_logic;
	  registraU                     : in  std_logic;
	  limpaFP                       : in  std_logic;
	  registraFP                    : in  std_logic;
	  escolheBotoes                 : in  std_logic;
	  enterfd                       : in  std_logic;
     botoes                        : in  std_logic_vector (3 downto 0); --entrada do usuário
		 panico                        : in  std_logic_vector (3 downto 0); --entrada do banco de dados para a senha do panico
		 ultimo                        : in  std_logic_vector (3 downto 0); --entrada do banco de dados para a senha normal
     chavesIgualMemoria            : out std_logic;
		 sPanicoCorreta                : out std_logic;
		 fimES                         : out std_logic;
     fimE                          : out std_logic;
     fimTMR                        : out std_logic;
		 fimTM                         : out std_logic;
		 errouPanico                   : out std_logic;
     jogada_feita                  : out std_logic;
		 fimSenha                      : out std_logic;
		 fimSenhaPanico                : out std_logic;
		 enter                         : out std_logic;
     jogada                        : out std_logic_vector (3 downto 0)
  );
end entity;

architecture estrutural of fluxo_dados is

  signal s_endereco        : std_logic_vector (3 downto 0);
  signal s_dado            : std_logic_vector (3 downto 0);
  signal s_jogada          : std_logic_vector (3 downto 0);
  signal s_panico          : std_logic_vector (3 downto 0);
  signal s_loadpanico      : std_logic_vector (3 downto 0);
  signal s_final           : std_logic_vector (3 downto 0);
  signal s_finalPanico     : std_logic_vector (3 downto 0);
  signal s_botoes          : std_logic_vector (3 downto 0);
  signal not_zeraE         : std_logic;
  signal not_escreve       : std_logic;
  signal not_escrevep      : std_logic;
  signal not_registraR     : std_logic;
  signal not_registraP     : std_logic;
  signal not_registraU     : std_logic;
  signal not_registraFP    : std_logic;
  signal s_chaveacionada   : std_logic;

  component contador_163
    port (
        clock : in  std_logic;
        clr   : in  std_logic;
        ld    : in  std_logic;
        ent   : in  std_logic;
        enp   : in  std_logic;
        D     : in  std_logic_vector (3 downto 0);
        Q     : out std_logic_vector (3 downto 0);
        rco   : out std_logic
    );
  end component;

  component comparador_85
    port (
    i_A3   : in  std_logic;
    i_B3   : in  std_logic;
    i_A2   : in  std_logic;
    i_B2   : in  std_logic;
    i_A1   : in  std_logic;
    i_B1   : in  std_logic;
    i_A0   : in  std_logic;
    i_B0   : in  std_logic;
    i_AGTB : in  std_logic;
    i_ALTB : in  std_logic;
    i_AEQB : in  std_logic;
    o_AGTB : out std_logic;
    o_ALTB : out std_logic;
    o_AEQB : out std_logic
    );
  end component;

  component ram_16x4 is
    port (
       clk          : in  std_logic;
       endereco     : in  std_logic_vector(3 downto 0);
       dado_entrada : in  std_logic_vector(3 downto 0);
       we           : in  std_logic;
       ce           : in  std_logic;
       dado_saida   : out std_logic_vector(3 downto 0)
    );
  end component;

  component registrador_173 is
      port (
          clock : in  std_logic;
          clear : in  std_logic;
          en1   : in  std_logic;
          en2   : in  std_logic;
          D     : in  std_logic_vector (3 downto 0);
          Q     : out std_logic_vector (3 downto 0)
     );
  end component;

 component edge_detector is
      port (
          clock  : in  std_logic;
          reset  : in  std_logic;
          sinal  : in  std_logic;
          pulso  : out std_logic
      );
 end component;

 component contador_m is
     generic (
         constant M: integer := 100 -- modulo do contador
     );
     port (
         clock   : in  std_logic;
         zera_as : in  std_logic;
         zera_s  : in  std_logic;
         conta   : in  std_logic;
         Q       : out std_logic_vector(natural(ceil(log2(real(M))))-1 downto 0);
         fim     : out std_logic;
         meio    : out std_logic
     );
 end component;

begin
  --gera sinais de lógica negativa (ativos em baixo)
  not_zeraE   <= not zeraE;
  not_registraR <= not registraR;
  not_registraP <= not registraP;
  not_registraU <= not registraU;
  not_registraFP <= not registraFP;
  not_escreve  <= not escreve;
  not_escrevep <= not escrevep;

  --sinal que verifica se houve ativação de algum dos botões
  s_chaveacionada <= botoes(3) or botoes(2) or botoes(1) or botoes(0);

  --multiplexação das entradas das entradas do usuário e do banco de dados para a senha normal
  s_botoes <= botoes  when escolheBotoes = '0' else
              ultimo;

  --contador que guarda o endereço a ser acessado em ambas as memórias
  contadorendereco: contador_163
    port map (clock, not_zeraE, '1', '1', contaE, "0000", s_endereco, fimE);

  --Timer reponsável por marcar que se passou 1 minuto (para clock de 1 kHz)
  Timer: contador_m
    generic map(60000)
    port map (clock, zeraTMR, '0', contaTMR, open, fimTMR, open); --zera de modo assincrono

  --Timer para resolver problemas de temporização na conexão com o banco de dados (utiliza as mesmas entradas que o outro timer)
  TimerTemp: contador_m
    generic map(1100)
    port map (clock, zeraTMR, '0', contaTMR, open, fimTM, open); --zera de modo assincrono

  --contador de erros de senha (ambas)
  Erros_de_senha: contador_m
    generic map(5)
    port map (clock, zeraES, '0', contaES, open, fimES, open); --zera de modo assincrono

  --Vai para 1 caso haja erro na senha do panico
  Flag_de_erro_panico: contador_m
    generic map(2)
    port map (clock, zeraMarca, '0', contaMarca, open, errouPanico, open); --zera de modo assincrono

  --comparador que verifica acerto para a senha normal
  comparadorjogadas: comparador_85
    port map (s_dado(3), s_jogada(3), s_dado(2), s_jogada(2), s_dado(1), s_jogada(1), s_dado(0), s_jogada(0), '0', '0', '1', open, open, chavesIgualMemoria);

  --comparador que verifica acerto para a senha do panico
  comparadorsenhapanico: comparador_85
    port map (s_panico(3), s_jogada(3), s_panico(2), s_jogada(2), s_panico(1), s_jogada(1), s_panico(0), s_jogada(0), '0', '0', '1', open, open, sPanicoCorreta);

  --comparador que verifica se a senha normal chegou ao fim
  comparadorfimsenha: comparador_85
    port map (s_final(3), s_endereco(3), s_final(2), s_endereco(2), s_final(1), s_endereco(1), s_final(0), s_endereco(0), '0', '0', '1', open, open, fimSenha);

  --comparador que verifica se a senha do panico chegou ao fim
  comparadorfimpanico: comparador_85
    port map (s_finalPanico(3), s_endereco(3), s_finalPanico(2), s_endereco(2), s_finalPanico(1), s_endereco(1), s_finalPanico(0), s_endereco(0), '0', '0', '1', open, open, fimSenhaPanico);

  --memoria que guarda a senha normal
  memoria: ram_16x4  -- usar para Quartus
  --memoria: entity work.ram_16x4(ram_modelsim) -- usar para ModelSim
    port map (clock, s_endereco, s_jogada, not_escreve, '0', s_dado);

  --memoria que guarda a senha do panico
  memoriapanico: ram_16x4  -- usar para Quartus
  --memoria: entity work.ram_16x4(ram_modelsim) -- usar para ModelSim
    port map (clock, s_endereco, s_loadpanico, not_escrevep, '0', s_panico);

  --guarda a jogada/entrada do usuário (entrada da memoria e utilizado nas comparações)
  registradorbotoes: registrador_173
    port map(clock, limpaR, not_registraR, '0', s_botoes, s_jogada);

  --registra um dado da senha so panico passado pelo banco de dados (entrada da memoriapanico)
  registradorpanico: registrador_173
    port map(clock, limpaP, not_registraP, '0', panico, s_loadpanico);

  --Registrador do tamanho-1 da senha normal
  registradorultimo: registrador_173
    port map(clock, limpaU, not_registraU, '0', ultimo, s_final);

  --Registrador do tamanho-1 da senha do panico
  registradorfimpanico: registrador_173
    port map(clock, limpaFP, not_registraFP, '0', panico, s_finalPanico);

  --gerador de pulso caso seja inserido um dado =/= "0000" na entrada de usuário
  JGD: edge_detector
    port map(clock, '0', s_chaveacionada, jogada_feita);

  --gera um pulso caso o usuário aperte 'enter'
  enterJGD: edge_detector
    port map(clock, '0', enterfd, enter);

  -- transmite o dado inserido pelo usuário para o banco de dados
  jogada     <= s_jogada;

end estrutural;
