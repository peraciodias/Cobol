       IDENTIFICATION DIVISION.
       PROGRAM-ID. RANDOMIZA.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  RND-NUM PIC 99V999.
       77  RND-REAL PIC 9(02).
       01  HORARIO PIC 9(08).
       01  HORA REDEFINES HORARIO.
       02  HH  PIC 99.
       02  HM  PIC 99.
       02  HS  PIC 99.
       02  HX  PIC 99.
       01  NUMERO PIC 9(6).
       PROCEDURE DIVISION.
       INICIO.
      *NESTE EXEMPLO ESTOU GERANDO 10 NÚMEROS ALEATÓRIOS" 
            ACCEPT HORARIO FROM TIME
            COMPUTE NUMERO = (HH * HX) / HM + HS
            COMPUTE RND-NUM = FUNCTION RANDOM
            COMPUTE RND-REAL = RND-NUM *(NUMERO)        
            DISPLAY RND-REAL
       STOP RUN.
