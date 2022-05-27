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
        
        ;registros que NO se pueden usar D0,D1,D2,A0 
	
	; ESCRIBID EN CADA ETIQUETA LA FASE DE EJECUCION DE CADA INSTRUCCION
	
ETRA:
   ;mover aaa a la posicion menos significativa
    MOVE.W EIR,D3
    AND.W #$00F0,D3
    LSR.L #4,D3

    JSR DECOD_VALOR
    ;en D4 esta el valor de aaa en decimal
    JSR COJER_CONTENIDO
    ;en D5 esta el contenido de el eregistro Xa
    
    ;mirar donde guardar el contenido de Xa
    MOVE.W EIR,D3
    AND.W #$0F00,D3
    LSR.L #8,D3
    
    JSR DECOD_VALOR
    ;en D4 esta el valor de bbb en decimal
    JSR GUARDAR_CONTENIDO
    
    ;actualizar flags Z y N
    JSR ACT_FLAGS
    
    ;limpiar los registros usados
    CLR.W D3
    CLR.W D4
    CLR.W D5    
    
    JMP FETCH
EADD:
    ;mover aaa a la posicion menos significativa
    MOVE.W EIR,D3
    AND.W #$00F0,D3
    LSR.L #4,D3

    JSR DECOD_VALOR
    ;en D4 esta el valor de aaa en decimal
    JSR COJER_CONTENIDO
    ;en D5 esta el contenido de el eregistro Xa
    MOVE.W D5,D6
    
    ;mirar el operando b
    MOVE.W EIR,D3
    AND.W #$0F00,D3
    LSR.L #8,D3
    
    JSR DECOD_VALOR
    ;en D4 esta el valor de bbb en decimal
    JSR COJER_CONTENIDO
    ;en D5 esta el contenido de bbb
    
    ADD.W D6,D5
    ;resultado suma en D5
    MOVE.W SR,D7
    ;guardar flags de la operaci�n
    
    JSR GUARDAR_CONTENIDO
    ;D4 es bbb, guardar contenido ahi
    
    ;actualizar flags Z,N (con lo que hay en D5)
    JSR ACT_FLAGS
    ;actualizar flag C
    JSR ACT_FLAG_C
    
    ;limpiar registros
    CLR.W D3
    CLR.W D4
    CLR.W D5
    CLR.W D6
    
    JMP FETCH
ESUB:

    ;mover aaa a la posicion menos significativa
    MOVE.W EIR,D3
    AND.W #$00F0,D3
    LSR.L #4,D3

    JSR DECOD_VALOR
    ;en D4 esta el valor de aaa en decimal
    JSR COJER_CONTENIDO
    ;en D5 esta el contenido de el eregistro Xa
    MOVE.W D5,D6
    
    ;mirar el operando b
    MOVE.W EIR,D3
    AND.W #$0F00,D3
    LSR.L #8,D3
    
    JSR DECOD_VALOR
    ;en D4 esta el valor de bbb en decimal
    JSR COJER_CONTENIDO
    ;en D5 esta el contenido de bbb
    
    SUB.W D6,D5
    ;resultado suma en D6
    MOVE.W SR,D7
    ;guardar flags de la operaci�n
    
    JSR GUARDAR_CONTENIDO
    ;D4 es bbb, guardar contenido ahi
    
    ;actualizar flags Z,N (con lo que hay en D5)
    JSR ACT_FLAGS
    ;actualizar flag C
    JSR ACT_FLAG_C
    
    ;limpiar registros
    CLR.W D3
    CLR.W D4
    CLR.W D5
    CLR.W D6

    
    JMP FETCH
ENAN:
    JMP FETCH
ESTC:
    MOVE.W EIR,D3
    AND.W #$0F00,D3
    LSR.L #8,D3
    JSR DECOD_VALOR
    ;en D4 esta el valor de bbb en decimal
    
    ;cojer constante k
    MOVE.W EIR,D3
    AND.W #$00FF,D3
    EXT.W D3
    MOVE.W D3,D5
    ;guardarlo en el registro indicado (D4 <--- [D5])
    ;actualizar flags N y Z
    JSR ACT_FLAGS
    
    JSR GUARDAR_CONTENIDO
    
    CLR.W D3
    CLR.W D4
    CLR.W D5
    
    JMP FETCH

EINC:;revisar
    ;cojer constante k
    MOVE.W EIR,D3
    AND.W #$00FF,D3
    EXT.W D3
    MOVE.W D3,D6
    
    MOVE.W EIR,D3
    AND.W #$0F00,D3
    LSR.L #8,D3
    JSR DECOD_VALOR
    ;en D4 esta el valor de bbb en decimal
    
    JSR COJER_CONTENIDO
    ;en D5 contenido de bbb
    
    ADD.W D5,D6
    
    ;actualizar flags N,Z y C
    MOVE.W SR,D7
    JSR ACT_FLAGS
    JSR ACT_FLAG_C
    
    JSR GUARDAR_CONTENIDO
    ;guarda la suma en el eregistro correspondiente
    
    CLR.W D3
    CLR.W D4
    CLR.W D5
    CLR.W D6
 
    JMP FETCH
     
ELOA:
        ;cojer la M mediante una mascara y guardarla en D3
    MOVE.W EIR,D3
    AND.W #$0FF0,D3
    LSR.L #4,D3
    MULU #2,D3
    MOVE.W D3,A2
    
    MOVE.W EMEM(A2),ET6 ;mover el contenido de 1000 + M 
    
    ;limpiar los registros usados
    CLR.W D3
    CLR.W A2
    JMP FETCH
ELOAX:
    ;cojer la M mediante una mascara y guardarla en D3
    MOVE.W EIR,D3
    AND.W #$0FF0,D3
    LSR.L #4,D3
       
    ;mirar con el bit i que registro B tomar
    MOVE.W EIR,D4
    BTST #3, D4
    BEQ I_0 ;salta si es 0
    MOVE.W EB1,D5
    ADD.W D5,D3
    MULU #2,D3
    MOVE.W D3,A2
    JMP B_COMPROBADO
    
I_0:
    MOVE.W EB0,D5
    ADD.W D5,D3
    MULU #2,D3
    MOVE.W D3,A2

B_COMPROBADO:
    
    ;mirar con el bit j que registro T tomar
    
    BTST #2,D4
    BEQ J_0 ;salta si j es 0
    MOVE.W EMEM(A2),ET7
    JMP J_COMPROBADO
J_0:
    MOVE.W EMEM(A2),ET6
J_COMPROBADO:

    ;limpiar los registros usados
    CLR.W D3
    CLR.W D4
    CLR.W D5
    CLR.W A2  
       
    JMP FETCH    
   
ESTO:
    MOVE.W ET6,D4 ;cojemos el contenido de T6 y lo guardamos en D4
    
    MOVE.W EIR,D3 ;cojer la M mediante una mascara y guardarla en D3
    AND.W #$0FF0,D3
    LSR.L #4,D3
    MULU #2,D3
    MOVE.W D3,A2
    
    MOVE D4,EMEM(A2)

    ;limpiar los registros usados
    CLR.W D3
    CLR.W D4
    CLR.W A2

    JMP FETCH

ESTOX:
    MOVE.W EIR,D4
    BTST #2,D4
    BEQ J_0_
    MOVE ET7,D6 
    JMP J_COMPROBADO_  
J_0_:
    MOVE ET6,D6

J_COMPROBADO_:    
    MOVE.W EIR,D3 ;cojer la M mediante una mascara y guardarla en D3
    AND.W #$0FF0,D3
    LSR.L #4,D3
    
    ;mirar con el bit i que registro B tomar

    BTST #3, D4
    BEQ I_0_ ;salta si es 0
    MOVE.W EB1,D5
    ADD.W D5,D3
    MULU #2,D3
    MOVE.W D3,A2
    JMP B_COMPROBADO_    
I_0_:
    MOVE.W EB0,D5
    ADD.W D5,D3
    MULU #2,D3
    MOVE.W D3,A2 

B_COMPROBADO_: 
    MOVE.W D6,EMEM(A2)
    
    JMP FETCH
EBRI:
    ;cojer valor M y meterlo en PC
    MOVE.W EMEM,D3
    AND.W #$0FF0,D3
    LSR.L #4,D3
    MOVE.W D3,EPC
    
    CLR.W D3

    JMP FETCH
EBRZ:
    
    MOVE.W ESR,D3
    BTST #2,D3
    BEQ Z_0
    ;si es 0 salta, sino, si Z es 1, se hace PC <---M
    
    ;cojer valor M y meterlo en PC
    MOVE.W EMEM,D3
    AND.W #$0FF0,D3
    LSR.L #4,D3
    MOVE.W D3,EPC
    
Z_0:
    CLR.W D3
    
    JMP FETCH
EBRN:

    MOVE.W ESR,D3
    BTST #0,D3
    BEQ N_0
    ;si es 0 salta, sino, si N es 1, se hace PC <---M
    
    ;cojer valor M y meterlo en PC
    MOVE.W EMEM,D3
    AND.W #$0FF0,D3
    LSR.L #4,D3
    MOVE.W D3,EPC
    
N_0:
    CLR.W D3
    
    JMP FETCH
ESTP:
    SIMHALT   
    ;--- FEXEC: FIN EJECUCION

    ;--- ISUBR: INICIO SUBRUTINAS
        ;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
        ;*** SALVO DECOD, que va en la siguiente seccion
DECOD_VALOR:
    MOVE.W #0,D4
    
    BTST #0,D3
    BEQ CERO1
    ADD.W #1,D4
    
CERO1:
    BTST #1,D3
    BEQ CERO2
    ADD.W #2,D4
    
CERO2:   
    BTST #2,D3
    BEQ CERO3
    ADD.W #4,D4
    
CERO3:
    RTS
    
COJER_CONTENIDO:
    ;coje el contenido de la posicion de memoria y lo almacena en D5
    
    CMP #0,D4 ;B0
    BNE AUX0
    MOVE EB0,D5
    
AUX0:
    CMP #1,D4 ;B1
    BNE AUX1
    MOVE EB1,D5
    
AUX1:    
    CMP #2,D4 ;R2
    BNE AUX2
    MOVE ER2,D5
    
AUX2:    
    CMP #3,D4 ;R3
    BNE AUX3
    MOVE ER3,D5

AUX3:    
    CMP #4,D4 ;R4
    BNE AUX4
    MOVE ER4,D5

AUX4:    
    CMP #5,D4 ;R5
    BNE AUX5
    MOVE ER5,D5

AUX5:    
    CMP #6,D4 ;T6
    BNE AUX6
    MOVE ET6,D5
    
AUX6:   
    CMP #7,D4 ;T7
    BNE AUX7
    MOVE ET7,D5
    
AUX7:
    RTS
    
GUARDAR_CONTENIDO:
    ;guarda el contenido de D5 en la posicion indicada por D4
    
    CMP #0,D4 ;B0
    BNE AUX0_
    MOVE D5,EB0
    
AUX0_:
    CMP #1,D4 ;B1
    BNE AUX1_
    MOVE D5,EB1
    
AUX1_:    
    CMP #2,D4 ;R2
    BNE AUX2_
    MOVE D5,ER2
    
AUX2_:    
    CMP #3,D4 ;R3
    BNE AUX3_
    MOVE D5,ER3

AUX3_:    
    CMP #4,D4 ;R4
    BNE AUX4_
    MOVE D5,ER4

AUX4_:    
    CMP #5,D4 ;R5
    BNE AUX5_
    MOVE D5,ER5

AUX5_:    
    CMP #6,D4 ;T6
    BNE AUX6_
    MOVE D5,ET6
    
AUX6_:   
    CMP #7,D4 ;T7
    BNE AUX7_
    MOVE D5,ET7
    
AUX7_:

    RTS

;Actualizaci�n de flags Z y N (Dato en D5)
ACT_FLAGS:
    MOVE.W D6,-(SP)
    
    MOVE.W ESR,D6
    
    CMP #0,D5
    BNE _CERO
    BSET #2,D6
    BRA UNO_PUESTO
_CERO:
    BCLR #2,D6
UNO_PUESTO:
    
    BTST D5,#15
    BNE ES_0
    BSET #0,D6
    BRA UNO_PUESTO1
ES_0:
    BCLR #0,D6
UNO_PUESTO1:

    MOVE.W (SP)+,D6
    RTS
    
;actualizar flag C  
ACT_FLAG_C:
    MOVE.W D6,-(SP)
    MOVE.W ESR,D6

    BTST D7,#0
    BNE ES_CERO
    BSET #1,D6
    MOVE.W D6,ESR
     
ES_CERO:
    MOVE.W (SP)+,D6    
    
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
       
       MOVE.W #6,10(SP)  ;instrucci�nn num LOA M
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
       
       MOVE.W #10,10(SP) ;instrucci�n  num BRI M
       JMP END_DEC
       
    
R1BIT14_1:
       MOVE.W #13,10(SP) ;instrucci�n num STP
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
