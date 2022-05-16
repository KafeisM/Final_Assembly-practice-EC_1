*-----------------------------------------------------------
* Title      : PRAFIN22
* Written by : Jordi Florit Ensenyat y Marc Ferrer Fernandez
* Date       : 30/05/2022
* Description: Emulador de la JARVIS
*-----------------------------------------------------------
    ORG $1000
EMEM:   DC.W $2800,$2A03,$50E0,$0B60,$5114,$0C70,$1430,$0E40,$7140,$3001,$32FF,$90D0
        DC.W $8020,$C000,$0002,$0003,$0001,$0003,$0002,$0004,$0000,$0000,$0000
EIR:    DC.W 0 ;eregistro de instruccion
EPC:    DC.W 0 ;econtador de programa
EB0:    DC.W 0 ;eregistro B0
EB1:    DC.W 0 ;eregistro B1
ER2:    DC.W 0 ;eregistro R2
ER3:    DC.W 0 ;eregistro R3
ER4:    DC.W 0 ;eregistro R4
ER5:    DC.W 0 ;eregistro R5
ET6:    DC.W 0 ;eregistro T6
ET7:    DC.W 0 ;eregistro T7
ESR:    DC.W 0 ;eregistro de estado (00000000 00000ZCN)

START:
       CLR.W EPC


FETCH:
    ;--- IFETCH: INICIO FETCH
        ;*** En esta seccion debeis introducir el codigo necesario para cargar
        ;*** en el EIR la siguiente instruccion a ejecutar, indicada por el EPC,
	    ;*** y dejar listo el EPC para que apunte a la siguiente instruccion
	    
	   MOVE.W #14,D0    ;bucle de 14 iteraciones
	   SUBQ.W #1,D0
	   
	   MOVE.W EPC,A0
	   MOVE.L A0,D2
	   MULU #2,D2
       MOVE.L D2,A0
   
	   MOVE.W EMEM(A0),EIR
	   
	   ADDQ.W #1,EPC   ;incrementar PC
        
    ;--- FFETCH: FIN FETCH
    
    
    ;--- IBRDECOD: INICIO SALTO A DECOD
        ;*** En esta seccion debeis preparar la pila para llamar a la subrutina
        ;*** DECOD, llamar a la subrutina, y vaciar la pila correctamente,
        ;*** almacenando el resultado de la decodificacion en D1
        
       SUB.W #2,SP ;reserva espacio resultado
       MOVE.W EIR,-(SP) ;paso parametro EIR
       
       JSR DECOD
       
       MOVE.W 2(SP),D1 ;parametro de salida
       ADD.L #2,SP
       
       
    	
    ;--- FBRDECOD: FIN SALTO A DECOD
    
    
    ;--- IBREXEC: INICIO SALTO A FASE DE EJECUCION
        ;*** Esta seccion se usa para saltar a la fase de ejecucion
        ;*** NO HACE FALTA MODIFICARLA
       MULU #6,D1
       MOVEA.L D1,A1
       JMP JMPLIST(A1)
JMPLIST:
    JMP ETRA
    JMP EADD
    JMP ESUB
    JMP ENAN
    JMP ESTC
    JMP EINC
    JMP ELOA
    JMP ELOAX
    JMP ESTO
    JMP ESTOX
    JMP EBRI
    JMP EBRZ
    JMP EBRN
    JMP ESTP
    ;--- FBREXEC: FIN SALTO A FASE DE EJECUCION
    
    
    ;--- IEXEC: INICIO EJECUCION
        ;*** En esta seccion debeis implementar la ejecucion de cada einstr.
	
	; ESCRIBID EN CADA ETIQUETA LA FASE DE EJECUCION DE CADA INSTRUCCION
ETRA:
    JSR TRA
EADD:
ESUB:
ENAN:
ESTC:
EINC:
ELOA:
ELOAX:
ESTO:
ESTOX:
EBRI:
EBRZ:
EBRN:
ESTP:
    ;--- FEXEC: FIN EJECUCION
    
       DBRA D0,FETCH   ;bucle temporal
       
       SIMHALT  ;TEMPORAL

    ;--- ISUBR: INICIO SUBRUTINAS
        ;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
        ;*** SALVO DECOD, que va en la siguiente seccion

TRA:

    RTS
        
    ;--- FSUBR: FIN SUBRUTINAS
    

    ;--- IDECOD: INICIO DECOD
        ;*** Tras la etiqueta DECOD, debeis implementar la subrutina de 
        ;*** decodificacion, que debera ser de libreria, siguiendo la interfaz
        ;*** especificada en el enunciado
DECOD:
;guardar registros en la pila

       MOVE.W D0,-(SP)
       MOVE.W D2,-(SP)
       
       MOVE.W 8(SP),D2
       
       BTST.L #15,D2
       BNE BIT15_1   
       
;Inicio rama 0x
       BTST.L #14,D2
       BNE R0BIT14_1
       
      
       BTST.L #13,D2
       BNE R02BIT13_1
       
      
       BTST.L #12,D2
       BNE R02BIT12_1 
       
      
       MOVE.W #0,10(SP)  ;instruccion num TRA
       JMP END_DEC
       
R02BIT13_1:
       BTST.L #12,D2
       BNE R022BIT12_1
      
       BTST.L #11,D2
       BNE R02BIT11_1
      
       MOVE.W #3,10(SP)  ;instruccion num NAN
       JMP END_DEC

 
R02BIT11_1:
       MOVE.W #4,10(SP)  ;instruccion num STC
       JMP END_DEC
       
R022BIT12_1:
       MOVE.W #5,10(SP)  ;instruccion num INC
       JMP END_DEC

R02BIT12_1: 
       BTST.L #11,D2
       BNE R022BIT11_1
      
       MOVE.W #1,10(SP)  ;instruccion num ADD
       JMP END_DEC
       
R022BIT11_1:
       MOVE.W #2,10(SP)  ;instruccion num SUB
       JMP END_DEC      

      
      
      ;si bit 14 = 1
R0BIT14_1:
       BTST.L #13,D2
       BNE R0BIT13_1
       
       BTST.L #12,D2
       BNE R0_1_BIT12_1
       
       MOVE.W #6,10(SP)  ;instrucciónn num LOA M
       JMP END_DEC
       
R0BIT13_1:
       BTST.L #12,D2
       BNE R0_2_BIT12_1
       MOVE.W #8,10(SP)   ;instruccion num STOM
       JMP END_DEC

R0_1_BIT12_1:
       MOVE.W #7,10(SP) ;instruccion num LOAX
       JMP END_DEC
       
R0_2_BIT12_1:
       MOVE.W #9,10(SP) ;instruccion num STOX
       JMP END_DEC
       
  


     
;Inicio rama 1x 
BIT15_1:
       BTST.L #14,D2
       BNE R1BIT14_1
       
       BTST.L #13,D2
       BNE R1BIT13_1
       
       BTST.L #12,D2
       BNE R1BIT12_1
       
       MOVE.W #10,10(SP) ;instrucción  num BRI M
       JMP END_DEC
       
    
R1BIT14_1:
       MOVE.W #13,10(SP) ;instrucción num STP
       JMP END_DEC
                                     
R1BIT13_1:
       MOVE.W #12,10(SP) ;instruccin num BRN M
       JMP END_DEC

R1BIT12_1:
      
      MOVE.W #11,10(SP) ;instruccion num BRZ M
      JMP END_DEC
      

END_DEC:

;devolver los valores a los registros desde la pila
      MOVE.W (SP)+,D2
      MOVE.W (SP)+,D0

      
      RTS
      
    ;--- FDECOD: FIN DECOD
    END    START












*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
