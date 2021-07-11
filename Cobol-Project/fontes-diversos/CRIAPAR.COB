       IDENTIFICATION DIVISION.
       PROGRAM-ID. crialuno-seq.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       SELECT ARQ-ENT0
              ASSIGN TO 'F:\SOURCE\MENSA.TXT'
              ORGANIZATION IS LINE SEQUENTIAL
              FILE STATUS IS FS-STAT.
              
       SELECT ARQ-ENT1
              ASSIGN TO 'F:\SOURCE\CADALUNO.TXT'
              ORGANIZATION IS LINE SEQUENTIAL.

       SELECT ARQ-SAI
              ASSIGN TO 'F:\SOURCE\MENSAL.DAT'
              ORGANIZATION IS INDEXED
              ACCESS MODE  IS DYNAMIC
              RECORD KEY IS CODIGO.
       DATA DIVISION.
       FILE SECTION.
       FD ARQ-ENT0.
       01 REG-ENT0.
           02 ANO-REF-ENT      PIC  9(4).
           02 PARCELA-ENT      PIC  ZZZ.Z9.
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

       FD  ARQ-SAI.
       01  REG-SAI.
           02 CODIGO           PIC 9(08).
           02 NOME             PIC A(20). 
           02 S-NOME           PIC A(30).
           02 ANO-REF-SAI      PIC 9(04). 
           02 PARCELA-SAI      PIC ZZZ.Z9.
           02 MENSA-1-SAI.
              03 MES-REF-1     PIC A(9).
              03 SITU-1        PIC A(02).  
           02 MENSA-2-SAI.
              03 MES-REF-2     PIC A(9).
              03 SITU-2        PIC A(02).
           02 MENSA-3-SAI.
              03 MES-REF-3     PIC A(9).
              03 SITU-3        PIC A(02).
           02 MENSA-4-SAI.
              03 MES-REF-4     PIC A(9).
              03 SITU-4        PIC A(02).

       WORKING-STORAGE SECTION.
       01 WS-REG-SEQ.
           02 ANO-SEQ          PIC  9(4).
           02 PARCELA-SEQ      PIC  ZZZ.Z9.
           02 MENSA-SEQ-1.
              03 MES-SEQ-1     PIC  A(9).
              03 SEQ-SITU-1    PIC A(02).  
           02 MENSA-SEQ-2.
              03 MES-SEQ-2     PIC  A(9).
              03 SEQ-SITU-2    PIC A(02).
           02 MENSA-SEQ-3.
              03 MES-SEQ-3     PIC  A(9).
              03 SEQ-SITU-3    PIC A(02).
           02 MENSA-SEQ-4.
              03 MES-REF-4     PIC  A(9).
              03 SEQ-SITU-4    PIC A(02).

       01  WS-REG.
           02 WS-CODIGO         PIC 9(08).
           02 WS-NOME           PIC A(20). 
           02 WS-S-NOME         PIC A(30).
           02 WS-ANO-REF        PIC 9(04). 
           02 WS-PARCELA        PIC ZZZ.Z9.
           02 WS-MENSA-1.
              03 WS-MES-REF1    PIC A(9).
              03 WS-SITU-1      PIC A(02).  
           02 WS-MENSA-2.
              03 WS-MES-REF2    PIC A(9).
              03 WS-SITU-2      PIC A(02).
           02 WS-MENSA-3.
              03 WS-MES-REF3    PIC A(9).
              03 WS-SITU-3      PIC A(02).
           02 WS-MENSA-4.
              03 WS-MES-REF4    PIC A(9).
              03 WS-SITU-4      PIC A(02).

       01  WS-EOF PIC A(1).
       01  WS-CONTA-REG PIC 9(09).
       77 FS-STAT PIC 9(02).
           88 FS-OK         VALUE ZEROS.
           88 FS-NAO-EXISTE VALUE 35.
           
       PROCEDURE DIVISION.
       PERFORM ABRIR-ARQUIVOS.
      * inicia um loop ate que WS-EOF SEJA='Y' quando finaliza o loop
       PERFORM UNTIL WS-EOF = 'Y'
              READ ARQ-ENT0 INTO WS-REG-SEQ 
              AT END MOVE 'Y' TO WS-EOF
              END-READ
              READ ARQ-ENT1
              AT END MOVE 'Y' TO WS-EOF
              NOT AT END
              MOVE ANO-SEQ          TO WS-ANO-REF
              MOVE PARCELA-SEQ      TO WS-PARCELA
              MOVE CODIGO-ENT       TO WS-CODIGO
              MOVE NOME-ENT         TO WS-NOME
              MOVE S-NOME-ENT       TO WS-S-NOME
              MOVE MENSA-SEQ-1      TO WS-MENSA-1
              MOVE MENSA-SEQ-2      TO WS-MENSA-2
              MOVE MENSA-SEQ-3      TO WS-MENSA-3
              MOVE MENSA-SEQ-4      TO WS-MENSA-4
              WRITE REG-SAI FROM WS-REG
              END-READ
       END-PERFORM.
       CLOSE ARQ-ENT0.
       CLOSE ARQ-ENT1.
       CLOSE ARQ-SAI.
       STOP RUN.
       EXIT PROGRAM.

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
               CLOSE ARQ-SAI
               STOP RUN
           END-IF

           OPEN INPUT ARQ-ENT1
           IF FS-NAO-EXISTE THEN
               DISPLAY 'UM ARQUIVO DE ENTRADA Nao FOI ENCONTRADO....'
               CLOSE ARQ-ENT1
               CLOSE ARQ-ENT0
               CLOSE ARQ-SAI
               STOP RUN
           END-IF.         
