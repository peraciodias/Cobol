       IDENTIFICATION DIVISION.
       PROGRAM-ID. CRIANOTA.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       SELECT ARQ-ENT0 ASSIGN TO 'F:\COBOL45\SOURCE\NOTAS.TXT'
              ORGANIZATION IS LINE SEQUENTIAL.

       SELECT ARQ-ENT1 ASSIGN TO 'F:\COBOL45\SOURCE\CADALUNOS.TXT'
              ORGANIZATION IS LINE SEQUENTIAL.

       SELECT ARQ-SAI ASSIGN TO 'F:\COBOL45\SOURCE\NOTAS.DAT'
              ORGANIZATION IS INDEXED
              ACCESS MODE IS DYNAMIC
              RECORD KEY IS CODIGO-OK
              FILE STATUS IS FS-STAT.

       DATA DIVISION.
       FILE SECTION.
       FD  ARQ-ENT0.
       01  REG-ENT0.
           02 PRIMEIRO-ENT0       PIC 9(2).
           02 SEGUNDO-ENT0        PIC 9(2).
           02 TERCEIRO-ENT0       PIC 9(2).
           02 QUARTO-ENT0         PIC 9(2).

       FD  ARQ-ENT1.
       01  REG-ENT1.
           02 CODIGO-ENT         PIC 9(08).
           02 NOME-ENT           PIC X(20). 
           02 S-NOME-ENT         PIC X(30).
           02 FONE-ENT           PIC X(12).
           02 CEP-ENT            PIC X(08).
           02 CIDADE-ENT         PIC X(08).
           02 UF-ENT             PIC X(02).
           02 BAIRRO-ENT         PIC X(32).
           02 RUA-ENT            PIC X(55).
           02 FILLER             PIC X(3).

        FD ARQ-SAI.
        01 REG-OK.
           02 CODIGO-OK             PIC 9(08).
           02 NOME-OK               PIC X(20).
           02 S-NOME-OK             PIC X(30).
           02 PRIMEIRO-OK           PIC 9(02).
           02 SEGUNDO-OK            PIC 9(02).
           02 TERCEIRO-OK           PIC 9(02).
           02 QUARTO-OK             PIC 9(02).
 
       WORKING-STORAGE SECTION.
       01  WS-REG-NOTAS.
           02 WS-PRIMEIRO           PIC 9(02).
           02 WS-SEGUNDO            PIC 9(02).
           02 WS-TERCEIRO           PIC 9(02).
           02 WS-QUARTO             PIC 9(02).

       01  WS-REG-ENT1.
           02 WS-CODIGO             PIC 9(08).
           02 WS-NOME               PIC X(20).
           02 WS-S-NOME             PIC X(30).
           02 WS-FONE               PIC X(12).
           02 WS-CEP                PIC X(08).
           02 WS-CIDADE             PIC X(08).
           02 WS-UF                 PIC X(02).
           02 WS-BAIRRO             PIC X(32).
           02 WS-RUA                PIC X(55).
           02 FILLER                PIC X(3).

       01  WS-REG-OK.
           02 WS-CODIGO-OK             PIC 9(08).
           02 WS-NOME-OK               PIC X(20).
           02 WS-S-NOME-OK             PIC X(30).
           02 WS-PRIMEIRO-OK           PIC 9(02).
           02 WS-SEGUNDO-OK            PIC 9(02).
           02 WS-TERCEIRO-OK           PIC 9(02).
           02 WS-QUARTO-OK             PIC 9(02).
         
       01  WS-EOF PIC A(1).
       77 FS-STAT PIC 9(02).
           88 FS-OK         VALUE ZEROS.
           88 FS-NAO-EXISTE VALUE 35.

      *
      *******************************************************
       PROCEDURE DIVISION.
       PERFORM ABRIR-ARQUIVOS.
      * inicia um loop ate que WS-EOF SEJA='Y' quando finaliza o loop
       PERFORM UNTIL WS-EOF = 'Y'
              READ ARQ-ENT0 INTO WS-REG-NOTAS
              AT END MOVE 'Y' TO WS-EOF
              END-READ
              READ ARQ-ENT1 INTO WS-REG-ENT1
              AT END MOVE 'Y' TO WS-EOF
              NOT AT END
              PERFORM MOSTRA
              MOVE WS-CODIGO      TO WS-CODIGO-OK
              MOVE WS-NOME        TO WS-NOME-OK
              MOVE WS-S-NOME      TO WS-S-NOME-OK
              MOVE WS-PRIMEIRO    TO WS-PRIMEIRO-OK
              MOVE WS-SEGUNDO     TO WS-SEGUNDO-OK
              MOVE WS-TERCEIRO    TO WS-TERCEIRO-OK
              MOVE WS-QUARTO      TO WS-QUARTO-OK
              WRITE REG-OK FROM WS-REG-OK
              END-READ
       END-PERFORM.
       CLOSE ARQ-ENT0.
       CLOSE ARQ-ENT1.
       CLOSE ARQ-SAI.
       STOP RUN.
      ******************************************************************
      *  DISPLAY  'CIDADE..:' WS-CIDADE
      *  DISPLAY  'CEP.....:' WS-CEP
      *  DISPLAY  'RUA.....:' WS-RUA
      *  DISPLAY  'BAIRRO..:' WS-BAIRRO

       MOSTRA.
       DISPLAY  'CODIGO..:' WS-CODIGO
       DISPLAY  'NOME....:' WS-NOME
       DISPLAY  'S-NOME..:' WS-S-NOME       
       DISPLAY  'PRIMEIRO:' WS-PRIMEIRO
       DISPLAY  'SEGUNDO.:' WS-SEGUNDO
       DISPLAY  'TERCEIRO:' WS-TERCEIRO
       DISPLAY  'QUARTO..:' WS-QUARTO.
       DISPLAY '-------------------------------------------------'.

       ABRIR-ARQUIVOS.
           OPEN OUTPUT ARQ-SAI
           IF FS-NAO-EXISTE THEN
               DISPLAY 'CRIANDO NOVO ARQUIVO ...'
               CLOSE ARQ-SAI
               OPEN I-O ARQ-SAI
           END-IF

           OPEN INPUT ARQ-ENT0
           IF FS-NAO-EXISTE THEN
               DISPLAY 'UM ARQUIVO DE ENTRADA Nao FOI ENCONTRADO....'
               CLOSE ARQ-ENT0
               STOP RUN
           END-IF

           OPEN INPUT ARQ-ENT1
           IF FS-NAO-EXISTE THEN
               DISPLAY 'UM ARQUIVO DE ENTRADA Nao FOI ENCONTRADO....'
               CLOSE ARQ-ENT1
               STOP RUN
           END-IF.

