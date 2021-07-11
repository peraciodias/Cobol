       IDENTIFICATION DIVISION.
       PROGRAM-ID.    LEMENSA.
       AUTHOR.        PERINHA.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

       SELECT ARQ-ENT0
              ASSIGN TO DISK
              ORGANIZATION IS INDEXED
              ACCESS MODE  IS DYNAMIC
              RECORD KEY IS CODIGO
              FILE STATUS IS FS-STAT.
       DATA DIVISION.
       FILE SECTION.
       FD ARQ-ENT0
           LABEL RECORD IS STANDARD
           DATA  RECORD IS REG-ENT
           VALUE OF FILE-ID "MENSAL.DAT".

       01 REG-ENT0.
           02 CODIGO         PIC 9(08).
           02 NOME           PIC A(20). 
           02 S-NOME         PIC A(30).
           02 ANO-REF        PIC 9(04). 
           02 VAL-PARCELA    PIC ZZZ.Z9.
           02 MENSA-1.
              03 MES-REF-1   PIC  A(9).
              03 SITU-1      PIC A(02).  
           02 MENSA-2.
              03 MES-REF-2   PIC  A(9).
              03 SITU-2      PIC A(02).
           02 MENSA-3.
              03 MES-REF-3   PIC  A(9).
              03 SITU-3      PIC A(02).
           02 MENSA-4.
              03 MES-REF-4   PIC  A(9).
              03 SITU-4      PIC A(02).

       WORKING-STORAGE SECTION.
       01 WS-REG-ENT0.
           02 WS-CODIGO         PIC 9(08).
           02 WS-NOME           PIC A(20). 
           02 WS-S-NOME         PIC A(30).
           02 WS-ANO-REF        PIC 9(04).
           02 WS-VAL-PARCELA    PIC ZZZ.Z9.
           02 MENSA-1-ENT.
              03 WS-MES-REF1      PIC A(9).
              03 WS-SITU-1       PIC A(02).  
           02 MENSA-2-ENT.
              03 WS-MES-REF2      PIC A(9).
              03 WS-SITU-2       PIC A(02).
           02 MENSA-3-ENT.
              03 WS-MES-REF3      PIC A(9).
              03 WS-SITU-3       PIC A(02).
           02 MENSA-4-ENT.
              03 WS-MES-REF4      PIC A(9).
              03 WS-SITU-4       PIC A(02).

       01  WS-EOF PIC A(1).
       77 FS-STAT PIC 9(02).
           88 FS-OK         VALUE ZEROS.
           88 FS-NAO-EXISTE VALUE 35.
       PROCEDURE DIVISION.
       PERFORM ABRIR-ARQUIVOS.
      * inicia um loop ate que WS-EOF SEJA='Y' quando finaliza o loop
      * PERFORM UNTIL WS-EOF = 'Y'
       MOVE 20190152 TO CODIGO.
       READ ARQ-ENT0 RECORD INTO WS-REG-ENT0
            KEY IS CODIGO
              INVALID KEY  DISPLAY "CHAVE INVALIDA !"
      *        AT END MOVE 'Y' TO WS-EOF
              NOT INVALID KEY
              DISPLAY 'CODIGO..:' WS-CODIGO
              DISPLAY 'NOME....:' WS-NOME
              DISPLAY 'S-SNOME.:' WS-S-NOME
              DISPLAY 'ANO REF.:' WS-ANO-REF
              DISPLAY 'VALOR...:' WS-VAL-PARCELA
              DISPLAY WS-MES-REF1
              DISPLAY 'SITUACAO:' WS-SITU-1
              DISPLAY WS-MES-REF2
              DISPLAY 'SITUACAO:' WS-SITU-2
              DISPLAY WS-MES-REF3
              DISPLAY 'SUTUACAO:' WS-SITU-3
              DISPLAY WS-MES-REF4
              DISPLAY 'SITUACAO:' WS-SITU-4
              DISPLAY '-----------------------------------------'
              END-READ
      *END-PERFORM.
       CLOSE ARQ-ENT0.
       STOP RUN.
       EXIT PROGRAM.
       ABRIR-ARQUIVOS.
           OPEN INPUT ARQ-ENT0
           IF FS-NAO-EXISTE THEN
               DISPLAY 'UM ARQUIVO DE ENTRADA Nao FOI ENCONTRADO....'
               CLOSE ARQ-ENT0
               STOP RUN
           END-IF.         


