       IDENTIFICATION DIVISION.
       PROGRAM-ID. clientes.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FILE1 ASSIGN TO '/home/peracio/mycobol/clientes.dat'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS RANDOM
               FILE STATUS IS FS-STAT
               RECORD KEY IS FS-KEY.
       DATA DIVISION.
       FILE SECTION.
       FD FILE1.
       01 FILE1-REC.
           05 FS-KEY.
               10 FS-FONE PIC 9(09) BLANK WHEN ZEROS.
           05 FS-NOME     PIC X(40).
           05 FS-ENDERECO PIC X(40).
           05 FILLER      PIC X(20).
       WORKING-STORAGE SECTION.
       01 WS-MODULO.
           05 FILLER PIC X(11) VALUE "CLIENTES -".
           05 WS-OP PIC X(20) VALUE SPACES.

       77 WS-OPCAO PIC X.
           88 E-INCLUIR   VALUE IS "1".
           88 E-CONSULTAR VALUE IS "2".
           88 E-ALTERAR   VALUE IS "3".
           88 E-EXCLUIR   VALUE IS "4".
           88 E-ENCERRAR  VALUE IS "X" "x".
       77 FS-STAT PIC 9(02).
           88 FS-OK         VALUE ZEROS.
           88 FS-CANCELA    VALUE 99.
           88 FS-NAO-EXISTE VALUE 35.
       77 WS-ERRO PIC X.
           88 E-SIM VALUES ARE "S" "s".

       77 WS-NUML PIC 999.
       77 WS-NUMC PIC 999.
       77 COR-FUNDO PIC 9 VALUE 1.
       77 COR-FRENTE PIC 9 VALUE 6.

       77 WS-STATUS PIC X(30).
       77 WS-MSGERRO PIC X(80).

       COPY screenio.

       SCREEN SECTION.
       01 SS-CLS.
           05 SS-FILLER.
               10 BLANK SCREEN.
               10 LINE 01 COLUMN 01 ERASE EOL
                  BACKGROUND-COLOR COR-FUNDO.
               10 LINE WS-NUML COLUMN 01 ERASE EOL
                  BACKGROUND-COLOR COR-FUNDO.
           05 SS-CABECALHO.
               10 LINE 01 COLUMN 02 PIC X(31) FROM WS-MODULO
                  HIGHLIGHT FOREGROUND-COLOR COR-FRENTE
                  BACKGROUND-COLOR COR-FUNDO.
           05 SS-STATUS.
               10 LINE WS-NUML COLUMN 2 ERASE EOL PIC X(30)
                  FROM WS-STATUS HIGHLIGHT
                  FOREGROUND-COLOR COR-FRENTE
                  BACKGROUND-COLOR COR-FUNDO.
       01 SS-MENU FOREGROUND-COLOR 6.
           05 LINE 07 COLUMN 15 VALUE "1 - INCLUIR".
           05 LINE 08 COLUMN 15 VALUE "2 - CONSULTAR".
           05 LINE 09 COLUMN 15 VALUE "3 - ALTERAR".
           05 LINE 10 COLUMN 15 VALUE "4 - EXCLUIR".
           05 LINE 11 COLUMN 15 VALUE "X - ENCERRAR".
           05 LINE 13 COLUMN 15 VALUE "OPÇÃO: ".
           05 LINE 13 COL PLUS 1 USING WS-OPCAO AUTO.

       01 SS-TELA-REGISTRO.
           05 SS-CHAVE FOREGROUND-COLOR 2.
               10 LINE 10 COLUMN 10 VALUE "TELEFONE:".
               10 COLUMN PLUS 2 PIC 9(09) USING FS-FONE
                  BLANK WHEN ZEROS.
           05 SS-DADOS.
               10 LINE 11 COLUMN 10 VALUE "    NOME:".
               10 COLUMN PLUS 2 PIC X(40) USING FS-NOME.
               10 LINE 12 COLUMN 10 VALUE "ENDEREÇO:".
               10 COLUMN PLUS 2 PIC X(40) USING FS-ENDERECO.

       01 SS-ERRO.
           05 FILLER FOREGROUND-COLOR 4 BACKGROUND-COLOR 1 HIGHLIGHT.
               10 LINE WS-NUML COLUMN 2 PIC X(80) FROM WS-MSGERRO BELL.
               10 COLUMN PLUS 2 TO WS-ERRO.
       PROCEDURE DIVISION.
       INICIO.
           SET ENVIRONMENT 'COB_SCREEN_EXCEPTIONS' TO 'Y'.
           SET ENVIRONMENT 'COB_SCREEN_ESC' TO 'Y'.
           SET ENVIRONMENT 'ESCDELAY' TO '25'.
           ACCEPT WS-NUML FROM LINES
           ACCEPT WS-NUMC FROM COLUMNS
           PERFORM ABRIR-ARQUIVOS
           PERFORM UNTIL E-ENCERRAR
               MOVE "MENU" TO WS-OP
               MOVE "ESCOLHA A OPÇÃO" TO WS-STATUS
               MOVE SPACES TO WS-OPCAO
               DISPLAY SS-CLS
               ACCEPT SS-MENU
               EVALUATE TRUE
                   WHEN E-INCLUIR
                       PERFORM INCLUI THRU INCLUI-FIM
                   WHEN E-CONSULTAR
                       PERFORM CONSULTA THRU CONSULTA-FIM
                   WHEN E-ALTERAR
                       PERFORM ALTERA THRU ALTERA-FIM
                   WHEN E-EXCLUIR
                       PERFORM EXCLUI THRU EXCLUI-FIM
               END-EVALUATE
           END-PERFORM.
       FINALIZA.
           CLOSE FILE1.
           STOP RUN.

      * -----------------------------------
       INCLUI.
           MOVE "INCLUSÃO" TO WS-OP.
           MOVE "ESC PARA ENCERRAR" TO WS-STATUS.
           DISPLAY SS-CLS.
           MOVE SPACES TO FILE1-REC.
       INCLUI-LOOP.
           ACCEPT SS-TELA-REGISTRO.
           IF COB-CRT-STATUS = COB-SCR-ESC
               GO INCLUI-FIM
           END-IF
           IF FS-NOME EQUAL SPACES OR FS-ENDERECO EQUAL SPACES
               MOVE "FAVOR INFORMAR NOME E ENDEREÇO" TO WS-MSGERRO
               PERFORM MOSTRA-ERRO
               GO INCLUI-LOOP
           END-IF
           WRITE FILE1-REC
           INVALID KEY
               MOVE "CLIENTE JÁ EXISTE" TO WS-MSGERRO
               PERFORM MOSTRA-ERRO
               MOVE ZEROS TO FS-KEY
           END-WRITE.
           GO INCLUI.
       INCLUI-FIM.

      * -----------------------------------
       CONSULTA.
           MOVE "CONSULTA" TO WS-OP.
           MOVE "ESC PARA ENCERRAR" TO WS-STATUS.
           DISPLAY SS-CLS.
       CONSULTA-LOOP.
           MOVE SPACES TO FILE1-REC.
           DISPLAY SS-TELA-REGISTRO.
           PERFORM LE-CLIENTE THRU LE-CLIENTE-FIM.
           IF FS-CANCELA
               GO CONSULTA-FIM
           END-IF
           IF FS-OK
               DISPLAY SS-DADOS
               MOVE "PRESSIONE ENTER" TO WS-MSGERRO
               PERFORM MOSTRA-ERRO
           END-IF.
           GO CONSULTA-LOOP.
       CONSULTA-FIM.

      * -----------------------------------
       ALTERA.
           MOVE "ALTERAÇÃO" TO WS-OP.
           MOVE "ESC PARA ENCERRAR" TO WS-STATUS.
           DISPLAY SS-CLS.
       ALTERA-LOOP.
           MOVE SPACES TO FILE1-REC.
           DISPLAY SS-TELA-REGISTRO.
           PERFORM LE-CLIENTE THRU LE-CLIENTE-FIM.
           IF FS-CANCELA
               GO TO ALTERA-FIM
           END-IF
           IF FS-OK
               ACCEPT SS-DADOS
               IF COB-CRT-STATUS = COB-SCR-ESC
                   GO ALTERA-LOOP
               END-IF
           ELSE
               GO ALTERA-LOOP
            END-IF
            REWRITE FILE1-REC
                INVALID KEY
                    MOVE "ERRO AO GRAVAR" TO WS-MSGERRO
                    PERFORM MOSTRA-ERRO
                NOT INVALID KEY
                    CONTINUE
            END-REWRITE.
            GO ALTERA-LOOP.
       ALTERA-FIM.

      * -----------------------------------
       EXCLUI.
           MOVE "EXCLUSÃO" TO WS-OP.
           MOVE "ESC PARA ENCERRAR" TO WS-STATUS.
           DISPLAY SS-CLS.
           MOVE SPACES TO FILE1-REC.
           DISPLAY SS-TELA-REGISTRO.
           PERFORM LE-CLIENTE THRU LE-CLIENTE-FIM.
           IF FS-CANCELA
               GO EXCLUI-FIM
           END-IF
           IF NOT FS-OK
               GO EXCLUI
           END-IF
           DISPLAY SS-DADOS.
           MOVE "N" TO WS-ERRO.
           MOVE "CONFIRMA A EXCLUSÃO DO CLIENTE (S/N)?" TO WS-MSGERRO.
           ACCEPT SS-ERRO.
           IF NOT E-SIM
               GO EXCLUI-FIM
           END-IF
           DELETE FILE1
               INVALID KEY
                   MOVE "ERRO AO EXCLUIR" TO WS-MSGERRO
                   PERFORM MOSTRA-ERRO
           END-DELETE.
       EXCLUI-FIM.

      * -----------------------------------
      * LE CLIENTE E MOSTRA MENSAGEM SE CHAVE NÃO EXISTE
       LE-CLIENTE.
           ACCEPT SS-CHAVE.
           IF NOT COB-CRT-STATUS = COB-SCR-ESC
               READ FILE1
                   INVALID KEY
                       MOVE "CLIENTE NÃO ENCONTRADO" TO WS-MSGERRO
                       PERFORM MOSTRA-ERRO
               END-READ
           ELSE
               MOVE 99 to FS-STAT
           END-IF.
       LE-CLIENTE-FIM.

      * -----------------------------------
      * ABRE ARQUIVOS PARA ENTRADA E SAÍDA
       ABRIR-ARQUIVOS.
           OPEN I-O FILE1
           IF FS-NAO-EXISTE THEN
               OPEN OUTPUT FILE1
               CLOSE FILE1
               OPEN I-O FILE1
           END-IF.
       ABRIR-ARQUIVOS-FIM.
      * -----------------------------------
      * MOSTRA MENSAGEM, ESPERA ENTER, ATUALIZA BARRA STATUS
       MOSTRA-ERRO.
           DISPLAY SS-ERRO
           ACCEPT SS-ERRO
          DISPLAY SS-STATUS.
