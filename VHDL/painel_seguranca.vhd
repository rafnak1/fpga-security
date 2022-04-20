library ieee;
use ieee.std_logic_1164.all;

entity painel_seguranca is
 port (
      clock                     : in  std_logic;
      cancelar                  : in  std_logic;
      enter                     : in  std_logic;
      botoes                    : in  std_logic_vector(3 downto 0); --botoes de entrada do usuário
      entradabdNormal           : in  std_logic_vector(3 downto 0);
      entradabdPanico           : in  std_logic_vector(3 downto 0);
      saidacom                  : out std_logic_vector(3 downto 0);  --saida de comunicação com o banco de dados
      espere                    : out std_logic;
      abrir                     : out std_logic;
      errou                     : out std_logic;
      alarme                    : out std_logic;
      hex0                      : out std_logic_vector(6 downto 0);
      hex1                      : out std_logic_vector(6 downto 0);
      hex2                      : out std_logic_vector(6 downto 0);
      hex3                      : out std_logic_vector(6 downto 0);
      hex4                      : out std_logic_vector(6 downto 0);
      hex5                      : out std_logic_vector(6 downto 0);
      trigger                   : out std_logic; --sinal que avisa ao banco de dados que o id de usuário está disponível para ser lido
      alarmeMQTT                : out std_logic;
      fimES                     : out std_logic; --avisa que foram cometidos 4 erros
      abrirMQTT                 : out std_logic
 );
end entity;

architecture arch of painel_seguranca is

  signal s_enter                : std_logic;
  signal s_alarme               : std_logic;
  signal s_abrir                : std_logic;
  signal escreve                : std_logic;
  signal escrevep               : std_logic;
  signal zeraE                  : std_logic;
  signal zeraTMR                : std_logic;
  signal zeraMarca              : std_logic;
  signal zeraES                 : std_logic;
  signal contaE                 : std_logic;
  signal contaTMR               : std_logic;
  signal contaMarca             : std_logic;
  signal contaES                : std_logic;
  signal limpaR                 : std_logic;
  signal limpaFP                : std_logic;
  signal limpaU                 : std_logic;
  signal limpaP                 : std_logic;
  signal registraR              : std_logic;
  signal registraFP             : std_logic;
  signal registraU              : std_logic;
  signal registraP              : std_logic;
  signal escolheBotoes          : std_logic;
  signal chavesIgualMemoria     : std_logic;
  signal sPanicoCorreta         : std_logic;
  signal fimSenhaPanico         : std_logic;
  signal fimSenha               : std_logic;
  signal jogada_feita           : std_logic;
  signal fimTM                  : std_logic;
  signal fimTMR                 : std_logic;
  signal s_fimES                  : std_logic;
  signal errouPanico            : std_logic;

  component fluxo_dados is
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
       botoes                        : in  std_logic_vector (3 downto 0);
  		 panico                        : in  std_logic_vector (3 downto 0);
  		 ultimo                        : in  std_logic_vector (3 downto 0);
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
  end component;

  component unidade_controle is
    port (
         clock                : in  std_logic;
         jogada_feita         : in  std_logic;
         enter                : in  std_logic;
         cancelar             : in  std_logic;
         fimTM                : in  std_logic;
         fimTMR               : in  std_logic;
         fimES                : in  std_logic;
         fimSenhaPanico       : in  std_logic;
         fimSenha             : in  std_logic;
         chavesIgualMemoria   : in  std_logic;
         sPanicoCorreta       : in  std_logic;
         errouPanico          : in  std_logic;
         limpaR               : out std_logic;
         limpaFP              : out std_logic;
         limpaU               : out std_logic;
         limpaP               : out std_logic;
         zeraTMR              : out std_logic;
         zeraE                : out std_logic;
         zeraMarca            : out std_logic;
         zeraES               : out std_logic;
         registraR            : out std_logic;
         registraFP           : out std_logic;
         registraU            : out std_logic;
         registraP            : out std_logic;
         contaTMR             : out std_logic;
         contaE               : out std_logic;
         contaMarca           : out std_logic;
         contaES              : out std_logic;
         escreve              : out std_logic;
         escrevep             : out std_logic;
         escolheBotoes        : out std_logic;
         espere               : out std_logic;
         abrir                : out std_logic;
         errou                : out std_logic;
         alarme               : out std_logic;
			 trigg                : out std_logic;
			 db_hex_0             : out std_logic_vector(6 downto 0);
		   db_hex_1             : out std_logic_vector(6 downto 0);
		   db_hex_2             : out std_logic_vector(6 downto 0);
		   db_hex_3             : out std_logic_vector(6 downto 0);
		   db_hex_4             : out std_logic_vector(6 downto 0);
		   db_hex_5             : out std_logic_vector(6 downto 0)
    );
  end component;

begin

  FD: fluxo_dados
  port map (
    clock                => clock,
    zeraES               => zeraES,
    contaES              => contaES,
    zeraE                => zeraE,
    contaE               => contaE,
    zeraTMR              => zeraTMR,
    contaTMR             => contaTMR,
    zeraMarca            => zeraMarca,
    contaMarca           => contaMarca,
    escreve              => escreve,
    escrevep             => escrevep,
    limpaR               => limpaR,
    registraR            => registraR,
    limpaP               => limpaP,
    registraP            => registraP,
    limpaU               => limpaU,
    registraU            => registraU,
    limpaFP              => limpaFP,
    registraFP           => registraFP,
    escolheBotoes        => escolheBotoes,
	 enterfd              => enter,
    botoes               => botoes,
    panico               => entradabdPanico,
    ultimo               => entradabdNormal,
    chavesIgualMemoria   => chavesIgualMemoria,
    sPanicoCorreta       => sPanicoCorreta,
    fimES                => s_fimES,
    fimE                 => open,
    fimTMR               => fimTMR,
    fimTM                => fimTM,
    errouPanico          => errouPanico,
    jogada_feita         => jogada_feita,
    fimSenha             => fimSenha,
    fimSenhaPanico       => fimSenhaPanico,
	 enter                => s_enter,
    jogada               => saidacom
  );


  UC: unidade_controle
  port map (
    clock                => clock,
    jogada_feita         => jogada_feita,
    enter                => s_enter,
    cancelar             => cancelar,
    fimTM                => fimTM,
    fimTMR               => fimTMR,
    fimES                => s_fimES,
    fimSenhaPanico       => fimSenhaPanico,
    fimSenha             => fimSenha,
    chavesIgualMemoria   => chavesIgualMemoria,
    sPanicoCorreta       => sPanicoCorreta,
    errouPanico          => errouPanico,
    limpaR               => limpaR,
    limpaFP              => limpaFP,
    limpaU               => limpaU,
    limpaP               => limpaP,
    zeraTMR              => zeraTMR,
    zeraE                => zeraE,
    zeraMarca            => zeraMarca,
    zeraES               => zeraES,
    registraR            => registraR,
    registraFP           => registraFP,
    registraU            => registraU,
    registraP            => registraP,
    contaTMR             => contaTMR,
    contaE               => contaE,
    contaMarca           => contaMarca,
    contaES              => contaES,
    escreve              => escreve,
    escrevep             => escrevep,
    escolheBotoes        => escolheBotoes,
    espere               => espere,
    abrir                => s_abrir,
    errou                => errou,
    alarme               => s_alarme,
	 trigg                => trigger,
	 db_hex_0             => hex0,
	 db_hex_1             => hex1,
	 db_hex_2             => hex2,
	 db_hex_3             => hex3,
	 db_hex_4             => hex4,
	 db_hex_5             => hex5
  );

  alarmeMQTT <= s_alarme;
  alarme <= s_alarme;
  abrirMQTT <= s_abrir;
  abrir <= s_abrir;
  fimES <= s_fimES;

end architecture;
