library ieee;
use ieee.std_logic_1164.all;

--unidade de controle do painel de segurança

entity unidade_controle is
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
		 trigg                : out std_logic; --sinal que avisa ao banco de dados sobre a entrada do id de usuário
		 db_hex_0             : out std_logic_vector(6 downto 0);
		 db_hex_1             : out std_logic_vector(6 downto 0);
		 db_hex_2             : out std_logic_vector(6 downto 0);
		 db_hex_3             : out std_logic_vector(6 downto 0);
		 db_hex_4             : out std_logic_vector(6 downto 0);
		 db_hex_5             : out std_logic_vector(6 downto 0)
  );
end entity;

--unidade de controle é uma Máquina de Estados que segue o modelo Moore
architecture mei of unidade_controle is
    --lista de estados possíveis
    type t_estado is (inicio, espera_ini, insere_usuario, temporizacao, carrega_tamanho, preparacao, espera, carrega_senha, verifica_fim, proximo,
                      proxP, esperaP, carrega_panico, confere_fim, proximoP, proxN, esperaN, carrega_normal, confere_fimN, proximoN,
							 preparacao_senha, espera_confirmacao, registra_entrada, comparacao, proxima_entrada_erro, proxima_entrada, confirmar, abre, registra_abertura, mantem_erro,
							 prox, espera_panico, registra_panico, comparacao_panico, proxima_entrada_panico, verifica_panico, verifica_erros, incrementa_erro, avisa_erro, ativa_alarme,
							 preparacao_alarme, espera_alarme, registra_alarme, comparacao_alarme, proxima_entrada_alarme, errou_alarme, confirmacao_alarme);

    signal Eatual, Eprox: t_estado;


begin

  process(clock, cancelar)
  begin
    --'cancelar' assíncrono
    if cancelar='1' then
      Eatual <= inicio;
    elsif clock'event and clock='1' then
      Eatual <= Eprox;
    end if;
  end process;


  --Lógica de próximo estado
  Eprox <=
      espera_ini                   when Eatual=inicio else
      espera_ini                   when Eatual=espera_ini and jogada_feita='0' else
      insere_usuario               when Eatual=espera_ini and jogada_feita='1' else
      insere_usuario               when Eatual=insere_usuario and enter='0' else
      temporizacao                 when Eatual=insere_usuario and enter='1' else
      temporizacao                 when Eatual=temporizacao and fimTM='0' else
      carrega_tamanho              when Eatual=temporizacao and fimTM='1' else
      preparacao                   when Eatual=carrega_tamanho else
      espera                       when Eatual=preparacao else
      espera                       when Eatual=espera and fimTM='0' else
      carrega_senha                when Eatual=espera and fimTM='1' else
      verifica_fim                 when Eatual=carrega_senha else
      proximo                      when Eatual=verifica_fim and fimSenhaPanico='0' and fimSenha='0' else
      espera                       when Eatual=proximo else
      proxP                        when Eatual=verifica_fim and fimSenhaPanico='0' and fimSenha='1' else
		esperaP                      when Eatual=proxP else
      esperaP                      when Eatual=esperaP and fimTM='0' else
      carrega_panico               when Eatual=esperaP and fimTM='1' else
      confere_fim                  when Eatual=carrega_panico else
      proximoP                     when Eatual=confere_fim and fimSenhaPanico='0' else
      preparacao_senha             when Eatual=confere_fim and fimSenhaPanico='1' else
      esperaP                      when Eatual=proximoP else
      preparacao_senha             when Eatual=verifica_fim and fimSenhaPanico='1' and fimSenha='1' else
      proxN                        when Eatual=verifica_fim and fimSenhaPanico='1' and fimSenha='0' else
      esperaN                      when Eatual=proxN else
		esperaN                      when Eatual=esperaN and fimTM='0' else
      carrega_normal               when Eatual=esperaN and fimTM='1' else
      confere_fimN                 when Eatual=carrega_normal else
      preparacao_senha             when Eatual=confere_fimN and fimSenha='1' else
      proximoN                     when Eatual=confere_fimN and fimSenha='0' else
      esperaN                      when Eatual=proximoN else
      espera_confirmacao           when Eatual=preparacao_senha else
      espera_confirmacao           when Eatual=espera_confirmacao and fimTMR='0' and enter='0' and jogada_feita='0' else
      verifica_erros               when Eatual=espera_confirmacao and enter='1' else
      ativa_alarme                 when Eatual=espera_confirmacao and fimTMR='1' else
      registra_entrada             when Eatual=espera_confirmacao and jogada_feita='1' else
      comparacao                   when Eatual=registra_entrada else
      proxima_entrada              when Eatual=comparacao and chavesIgualMemoria='1' and fimSenha='0' and (sPanicoCorreta='1' or errouPanico='1') else
      espera_confirmacao           when Eatual=proxima_entrada else
      proxima_entrada_erro         when Eatual=comparacao and chavesIgualMemoria='1' and fimSenha='0' and sPanicoCorreta='0' and errouPanico='0' else
      espera_confirmacao           when Eatual=proxima_entrada_erro else
      verifica_erros               when Eatual=comparacao and chavesIgualMemoria='0' and (sPanicoCorreta='0' or errouPanico='1') else
      confirmar                    when Eatual=comparacao and chavesIgualMemoria='1' and fimSenha='1' else
      confirmar                    when Eatual=confirmar and fimTMR='0' and enter='0' and jogada_feita='0' else
      abre                         when Eatual=confirmar and enter='1' else
      registra_abertura            when Eatual=abre else
      registra_abertura            when Eatual=registra_abertura and fimTM='0' else
      inicio                       when Eatual=registra_abertura and fimTM='1' else
      ativa_alarme                 when Eatual=confirmar and fimTMR='1' else
      mantem_erro                  when Eatual=confirmar and jogada_feita='1' else
      registra_entrada             when Eatual=mantem_erro else
      prox                         when Eatual=comparacao and chavesIgualMemoria='0' and sPanicoCorreta='1' and errouPanico='0' and fimSenhaPanico='0' else
		ativa_alarme                 when Eatual=comparacao and chavesIgualMemoria='0' and sPanicoCorreta='1' and errouPanico='0' and fimSenhaPanico='1' else
		espera_panico                when Eatual=prox else
      espera_panico                when Eatual=espera_panico and fimTMR='0' and enter='0' and jogada_feita='0' else
      verifica_panico              when Eatual=espera_panico and enter='1' else
      verifica_erros               when Eatual=verifica_panico and fimSenhaPanico='0' else
      ativa_alarme                 when Eatual=verifica_panico and fimSenhaPanico='1' else
      ativa_alarme                 when Eatual=espera_panico and fimTMR='1' else
      registra_panico              when Eatual=espera_panico and jogada_feita='1' else
      comparacao_panico            when Eatual=registra_panico else
      verifica_erros               when Eatual=comparacao_panico and sPanicoCorreta='0' else
      ativa_alarme                 when Eatual=comparacao_panico and sPanicoCorreta='1' and fimSenhaPanico='1' else
      proxima_entrada_panico       when Eatual=comparacao_panico and sPanicoCorreta='1' and fimSenhaPanico='0' else
      espera_panico                when Eatual=proxima_entrada_panico else
      ativa_alarme                 when Eatual=verifica_erros and fimES='1' else
      incrementa_erro              when Eatual=verifica_erros and fimES='0' else
      avisa_erro                   when Eatual=incrementa_erro else
      avisa_erro                   when Eatual=avisa_erro and enter='0' and fimTMR='0' else
      preparacao_senha             when Eatual=avisa_erro and enter='1' else
      ativa_alarme                 when Eatual=avisa_erro and fimTMR='1' else
      preparacao_alarme            when Eatual=ativa_alarme else
      espera_alarme                when Eatual=preparacao_alarme else
      espera_alarme                when Eatual=espera_alarme and jogada_feita='0' and enter='0' else
      preparacao_alarme            when Eatual=espera_alarme and enter='1' else
      registra_alarme              when Eatual=espera_alarme and jogada_feita='1' else
      comparacao_alarme            when Eatual=registra_alarme else
      proxima_entrada_alarme       when Eatual=comparacao_alarme and chavesIgualMemoria='1' and fimSenha='0' else
      espera_alarme                when Eatual=proxima_entrada_alarme else
      errou_alarme                 when Eatual=comparacao_alarme and chavesIgualMemoria='0' else
      errou_alarme                 when Eatual=errou_alarme and enter='0' else
      preparacao_alarme            when Eatual=errou_alarme and enter='1' else
      confirmacao_alarme           when Eatual=comparacao_alarme and chavesIgualMemoria='1' and fimSenha='1' else
      confirmacao_alarme           when Eatual=confirmacao_alarme and enter='0' and jogada_feita='0' else
      abre                         when Eatual=confirmacao_alarme and enter='1' else
      errou_alarme                 when Eatual=confirmacao_alarme and jogada_feita='1' else
      inicio;



  --Máquina de Moore: saídas dependem somente do estado atual
  with Eatual select
       limpaR <= '1' when inicio | espera | esperaN | preparacao_senha | preparacao_alarme,
                 '0' when others;

  with Eatual select
       limpaFP <= '1' when inicio,
                  '0' when others;

  with Eatual select
       limpaU <= '1' when inicio,
                 '0' when others;

  with Eatual select
       limpaP <= '1' when inicio | espera | esperaP | preparacao_senha,
                 '0' when others;

  with Eatual select
       zeraTMR <= '1' when insere_usuario | preparacao | verifica_fim | proximoP | proximoN | preparacao_senha | abre | preparacao_alarme,
                  '0' when others;

  with Eatual select
       zeraE <= '1' when preparacao | preparacao_senha | preparacao_alarme,
                '0' when others;

  with Eatual select
       zeraMarca <= '1' when preparacao_senha,
                    '0' when others;

  with Eatual select
       zeraES <= '1' when inicio,
                 '0' when others;

  with Eatual select
       registraR <= '1' when insere_usuario | carrega_senha | carrega_normal | registra_entrada | registra_panico | registra_alarme,
                    '0' when others;

  with Eatual select
       registraFP <= '1' when carrega_tamanho,
                     '0' when others;

  with Eatual select
       registraU <= '1' when carrega_tamanho,
                    '0' when others;

  with Eatual select
       registraP <= '1' when carrega_senha | carrega_panico,
                    '0' when others;

  with Eatual select
       contaTMR <= '1' when temporizacao | espera | esperaP | esperaN | espera_confirmacao | confirmar | registra_abertura | espera_panico | avisa_erro,
                   '0' when others;

  with Eatual select
       contaE <= '1' when proximo | proxN | proxP | proximoP | proximoN | proxima_entrada | proxima_entrada_erro | prox | mantem_erro | proxima_entrada_panico | proxima_entrada_alarme,
                 '0' when others;

  with Eatual select
       contaMarca <= '1' when proxima_entrada_erro,
                     '0' when others;

  with Eatual select
       contaES <= '1' when incrementa_erro,
                  '0' when others;

  with Eatual select
       escreve <= '1' when verifica_fim | confere_fimN,
                  '0' when others;

  with Eatual select
       escrevep <= '1' when verifica_fim | confere_fim,
                   '0' when others;

  with Eatual select
       escolheBotoes <= '1' when espera | carrega_senha | verifica_fim | esperaN | carrega_normal | confere_fimN,
                        '0' when others;

  with Eatual select
       espere <= '1' when temporizacao | espera | esperaP | esperaN,
                 '0' when others;

  with Eatual select
       abrir <= '1' when abre | registra_abertura,
                '0' when others;

  with Eatual select
       errou <= '1' when incrementa_erro | avisa_erro | errou_alarme,
                '0' when others;

  with Eatual select
       alarme <= '1' when ativa_alarme | preparacao_alarme | espera_alarme | registra_alarme | comparacao_alarme | proxima_entrada_alarme | errou_alarme | confirmacao_alarme,
                 '0' when others;

  with Eatual select
       trigg  <= '1' when temporizacao,
		           '0' when others;

  --saídas que escrevem uma certa mensagem na FPGA. Em ordem de implementação:
  --'espere' when temporizacao | espera | esperaP | esperaN,
  --'aberto' when abre | registra_abertura,
  --'errou' when incrementa_erro | avisa_erro | errou_alarme,
  --'alarme' when ativa_alarme | preparacao_alarme | espera_alarme | registra_alarme | comparacao_alarme | proxima_entrada_alarme | confirmacao_alarme,
  with Eatual select
       db_hex_5  <= "0000110" when temporizacao | espera | esperaP | esperaN,
                    "0001000" when abre | registra_abertura,
						  "0000110" when incrementa_erro | avisa_erro | errou_alarme,
						  "0001000" when ativa_alarme | preparacao_alarme | espera_alarme | registra_alarme | comparacao_alarme | proxima_entrada_alarme | confirmacao_alarme,
		              "1111111" when others;

	with Eatual select
       db_hex_4  <= "0010010" when temporizacao | espera | esperaP | esperaN,
                    "0000000" when abre | registra_abertura,
						  "0101111" when incrementa_erro | avisa_erro | errou_alarme,
						  "1000111" when ativa_alarme | preparacao_alarme | espera_alarme | registra_alarme | comparacao_alarme | proxima_entrada_alarme | confirmacao_alarme,
		              "1111111" when others;

	with Eatual select
       db_hex_3  <= "0001100" when temporizacao | espera | esperaP | esperaN,
                    "0000110" when abre | registra_abertura,
						  "0101111" when incrementa_erro | avisa_erro | errou_alarme,
						  "0001000" when ativa_alarme | preparacao_alarme | espera_alarme | registra_alarme | comparacao_alarme | proxima_entrada_alarme | confirmacao_alarme,
		              "1111111" when others;

	with Eatual select
       db_hex_2  <= "0000110" when temporizacao | espera | esperaP | esperaN,
                    "0101111" when abre | registra_abertura,
						  "1000000" when incrementa_erro | avisa_erro | errou_alarme,
						  "0101111" when ativa_alarme | preparacao_alarme | espera_alarme | registra_alarme | comparacao_alarme | proxima_entrada_alarme | confirmacao_alarme,
		              "1111111" when others;

	with Eatual select
       db_hex_1  <= "0101111" when temporizacao | espera | esperaP | esperaN,
                    "0000111" when abre | registra_abertura,
						  "1000001" when incrementa_erro | avisa_erro | errou_alarme,
						  "0101011" when ativa_alarme | preparacao_alarme | espera_alarme | registra_alarme | comparacao_alarme | proxima_entrada_alarme | confirmacao_alarme,
		              "1111111" when others;

	with Eatual select
       db_hex_0  <= "0000110" when temporizacao | espera | esperaP | esperaN,
                    "1000000" when abre | registra_abertura,
						  "0000110" when ativa_alarme | preparacao_alarme | espera_alarme | registra_alarme | comparacao_alarme | proxima_entrada_alarme | confirmacao_alarme,
		              "1111111" when others;

end architecture;
