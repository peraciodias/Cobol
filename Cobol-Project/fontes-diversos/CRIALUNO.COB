       IDENTIFICATION DIVISION.
       PROGRAM-ID. CRIALUNO.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       SELECT ARQ-ENT ASSIGN TO 'F:\COBOL45\SOURCE\CADALUNO.TXT'
              ORGANIZATION IS LINE SEQUENTIAL.
       SELECT ARQ-SAI ASSIGN TO 'F:\COBOL45\SOURCE\ALUNOS.DAT'
              ORGANIZATION IS INDEXED
              ACCESS IS DYNAMIC
              RECORD KEY IS CODIGO
              FILE STATUS IS FS-STAT.
       DATA DIVISION.
       FILE SECTION.
       FD  ARQ-ENT.
       01  REG-ENT.
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
           02 CODIGO         PIC 9(08).
           02 NOME           PIC X(20). 
           02 S-NOME         PIC X(30).
           02 FONE           PIC X(12).
           02 CEP            PIC X(08).
           02 CIDADE         PIC X(08).
           02 UF             PIC X(02).
           02 BAIRRO         PIC X(32).
           02 RUA            PIC X(55).

       WORKING-STORAGE SECTION.
       01  WS-REG-ENT.
           02 WS-CODIGO    PIC 9(08).
           02 WS-NOME      PIC X(20). 
           02 WS-S-NOME    PIC X(30).
           02 WS-FONE      PIC X(12).
           02 WS-CEP       PIC X(08).
           02 WS-CIDADE    PIC X(08).
           02 WS-UF        PIC X(02).
           02 WS-BAIRRO    PIC X(32).
           02 WS-RUA       PIC X(55).

       01  WS-EOF PIC A(1).
       01  WS-STP PIC X(2).
       01  WS-CONTA-REG PIC 9(09) VALUE ZEROES.
       77 FS-STAT PIC 9(02).
           88 FS-OK         VALUE ZEROS.
           88 FS-NAO-EXISTE VALUE 35.
       PROCEDURE DIVISION.
      * inicia um loop ate que ENCONTRE FIM DO ARQUIVO='Y'
       PERFORM ABRE-ARQUIVOS.
       PERFORM UNTIL WS-EOF = 'Y'
           READ ARQ-ENT INTO WS-REG-ENT
               AT END MOVE 'Y' TO WS-EOF
           END-READ
           MOVE WS-REG-ENT TO REG-SAI
           PERFORM MOSTRA      
           WRITE REG-SAI
           PERFORM MOSTRA
       END-PERFORM.
       CLOSE ARQ-ENT.
       CLOSE ARQ-SAI.
       STOP RUN.
      *
      *============================================================
      *
       MOSTRA.
       DISPLAY '-----------------------------------------------------'
       DISPLAY  'CODIGO:' WS-CODIGO
       DISPLAY  'NOME..:' WS-NOME
       DISPLAY  'S.NOME:' WS-S-NOME
       DISPLAY  'FONE..:' WS-FONE
       DISPLAY  'CIDADE:' WS-CIDADE
       DISPLAY  'UF....:' WS-UF
       DISPLAY  'CEP...:' WS-CEP
       DISPLAY  'RUA...:' WS-RUA
       DISPLAY  'BAIRRO:' WS-BAIRRO
       .
       ABRE-ARQUIVOS.
           OPEN OUTPUT ARQ-SAI
           IF FS-NAO-EXISTE THEN
               DISPLAY 'CRIANDO NOVO ARQUIVO ...'
               CLOSE ARQ-SAI
               OPEN I-O ARQ-SAI
           END-IF
           OPEN INPUT ARQ-ENT
           IF FS-NAO-EXISTE THEN
               DISPLAY 'UM ARQUIVO DE ENTRADA Nao FOI ENCONTRADO....'
               CLOSE ARQ-ENT
               STOP RUN
           END-IF.          
