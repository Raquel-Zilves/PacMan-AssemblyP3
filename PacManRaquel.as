;==============================================================================
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;==============================================================================
;----------Funcionalidades:
CR              EQU     0Ah
FIM_LINHA       EQU     '@'
FIM_TEXTO       EQU     '!'
IO_READ         EQU     FFFFh
IO_WRITE        EQU     FFFEh
IO_STATUS       EQU     FFFDh
INITIAL_SP      EQU     FDFFh
CURSOR		    	EQU     FFFCh
CURSOR_INIT	  	EQU	   	FFFFh
ASCII_NUM	    	EQU    	48d
GAME_OVER 	   	EQU     0d
RND_MASK	     	EQU	    8016h	;-----1000 0000 0001 0110b
LSB_MASK	     	EQU	    0001h	;-----Mascara para testar o bit menos significativo do RandomMe

;----------Direção:
QTD_DIRECOES    EQU     4d
ESQ             EQU     0d ;---------Par
CIMA            EQU     1d ;---------Impar
DIR             EQU     2d ;---------Par
BAIXO           EQU     3d ;---------Impar
SEM_MOVIMENTO   EQU     5d

;---------Simbologia:
PACMAN  	     	EQU     'C'
GHOST        		EQU     '^'
FOOD  		    	EQU    	'.'
NULLSPACE	    	EQU    	' '


;---------Valores:
;--PacMan
PACMAN_START  	EQU      2578d ;--------00001010|00010010 L10|C18
PACMAN_STARTM   EQU     438d ;----------L0+438

;--Ghost1
SHY_START     	EQU     1570d ;------00000110|00100010 L6|C34
SHY_STARTM    	EQU     286d ;------L0+286

;--Ghost2
STALKER_START	  EQU   	2311d ;------00001001|00000111 L9|C7
STALKER_STARTM	EQU    	385d ;------L0+286

MAX_SCORE 		  EQU     200d ;---!!!!!!!!!!!!!!NEED ATT!!!!!!!!!!!!! 200
DEATH 		    	EQU   	0d

LIFELINE        EQU     0d

ENDSCREEN_L     EQU     0d
ENDSCREEN_C     EQU     15d

QTD_COLUM	      EQU	  	42d ; 41 char + FIM
UND_LINHAS      EQU     256d


;---------Timer:
TIMER_UNITS     EQU     FFF6h
ACTIVATE_TIMER  EQU     FFF7h
ON              EQU     1d
OFF             EQU     0d
TIME_TO_WAIT    EQU     4d


;==============================================================================
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
;==============================================================================

                ORIG    8000h
L0			STR     'life: S2 S2 S2                 SCORE: 000', FIM_LINHA
L1			STR     '_________________________________________', FIM_LINHA
L2			STR     'NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN', FIM_LINHA
L3			STR     'N........N       N......................N', FIM_LINHA
L4			STR     'N..NNN...N  NN   N....NNN  NNNN  NNNNN..N', FIM_LINHA
L5			STR     'N  NNN  NN  NN  NNN.....N        NN.....N', FIM_LINHA
L6			STR     'N......... ............ ......       NNNN', FIM_LINHA
L7			STR     'N.........N.......N....N......N..NN.....N', FIM_LINHA
L8 			STR     'N..NNNN  NNNNN  NNNNN  NN...NNN..NNNNN..N', FIM_LINHA
L9 			STR     'N..N        NN....N....N      N......N..N', FIM_LINHA
L10 		STR     'N..N   NN   NN.... ....N  NN  N..NN.. ..N', FIM_LINHA
L11			STR     'N..N   NN   NNNNN...NNNN  NN  N..NN..N..N', FIM_LINHA
L12  		STR     'N......NN.................NN............N', FIM_LINHA
L13			STR     'NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN', FIM_TEXTO

Win1 	    	STR 	' _____________ ', FIM_LINHA
Win2  	   	STR 	'| FIM DE JOGO |', FIM_TEXTO

GhostBite   STR   ' --', FIM_TEXTO


;-----------------------TABELAS AUXILIARES------------------------------------

;-----------Text Print:
TextIndex	  	WORD   	0d ;-Memory location
ScreenLine 		WORD    0d
ScreenColum		WORD    0d


;-----------Perfil:
Direction       WORD 0d
WasInMem        WORD 0d
IsInMem  	    	WORD 0d
WasInCoord	   	WORD 0d
IsInCoord       WORD 0d
WasOn		       	STR  ' '
IsOn  		    	STR  ' '

;----------------------TABELAS DE INFORCAÇÕES---------------------------------

;------------PacMan:
PacManInMem	  	WORD	0d
PacManCoord	  	WORD	0d
PacManDirection WORD	0d

;------------GhostShy:
ShyInMem	   	WORD	0d
ShyCoord	   	WORD	0d
ShyDirection 	WORD	0d
ShyIsOn   		STR  	' '

;------------GhostStalker:
StalkerInMem	     	WORD	0d
StalkerCoord	     	WORD	0d
StalkerDirection    WORD	0d
StalkerIsOn  	    	STR  	' '

Random_Var			WORD	A5A5h  ; 1010 0101 1010 0101

;------------Lifes:
PacLifes	   	WORD    3d
LifeColum 		WORD    11d ;----------00000000|00001011 L0|C11

;------------Score:
ScoreValue	   	WORD	0d
ScoreColum      WORD    40d ;----------00000000|00101001 L0|C40

;------------Game:
GameStatus		WORD    1d

;==============================================================================
; ZONA II: definicao de tabela de interrupções
;==============================================================================
    			ORIG    FE00h
INT0      WORD    PacManLeft
INT1			WORD   	PacManDown
INT2			WORD   	PacManRight
INT3			WORD    PacManUp

				ORIG    FE0Fh
INT15     WORD    CicloGame

;==============================================================================
; ZONA IV: codigo
;        conjunto de instrucoes Assembly, ordenadas de forma a realizar
;        as funcoes pretendidas
;==============================================================================
                ORIG    0000h
                JMP     Main
;------------------------------------------------------------------------------
;						  	  CONFIGURA TIMER
;------------------------------------------------------------------------------
; 				{ Reseta o cronômetro para 0.4 segundos }
;------------------------------------------------------------------------------
ConfiguraTimer: PUSH R1

				MOV  R1, TIME_TO_WAIT ;-------pegar o tempo a esperar
				MOV M[ TIMER_UNITS ], R1 ;----passa o tempo

				MOV  R1, ON ;-----------------pega valor de ON
				MOV M[ ACTIVATE_TIMER ], R1 ;-ativa o timer
				;-----------------------------quando timer igual a 0d, chama INT15

				POP R1
				RET
;------------------------------------------------------------------------------
;						  	  GERADOR DE RANDOM
;------------------------------------------------------------------------------
; 						{ Gera um número aleatório }
;------------------------------------------------------------------------------
RandomV1:	PUSH	R1

			MOV	R1, LSB_MASK
			AND	R1, M[Random_Var] ; R1 = bit menos significativo de M[Random_Var]
			JMP.Z	Rnd_Rotate
			MOV	R1, RND_MASK
			XOR	M[Random_Var], R1

Rnd_Rotate:	ROR	M[Random_Var], 1

			POP	R1

			RET

;------------------------------------------------------------------------------
;						  	  GERADOR DE DIREÇÃO
;------------------------------------------------------------------------------
; 			{ Gera um número simbolizando a direção a se atribuir }
;------------------------------------------------------------------------------
GeradorDirecao: PUSH R1 ;-----------------------------------------Direção
		PUSH R2 ;-------------------------------------------------Aux

		CALL RandomV1
		MOV R1, M[Random_Var]
		MOV R2, QTD_DIRECOES
		DIV R1, R2

		MOV M[Direction], R2

		POP R2
		POP R1
		RET
;------------------------------------------------------------------------------
;								IMPRIME INTEIRO
;------------------------------------------------------------------------------
;					{ Imprime valor de inteiro referenciado }
;------------------------------------------------------------------------------
ImprimeInteiro: PUSH R1 ;-----------------------------------------Coordenada
	PUSH R2 ;-----------------------------------------------------Coluna/Valor
	PUSH R3 ;-----------------------------------------------------Aux

;--------------------------Atribuição:
	MOV R1, M[ScreenLine]
	SHL R1, 8d
	MOV R2,  M[ScreenColum]
	OR R1, R2
	MOV R2, M[TextIndex]

;--------------------------Impressão:
ImprimeDigito: MOV R3, 10d
	DIV R2, R3 ;----------------------separa a unidade
	MOV M[CURSOR], R1
	ADD R3, ASCII_NUM
	MOV M[IO_WRITE], R3 ;-------------printa unidade
	DEC R1 ;--------------------------anda na posição pra proxima casa decimal
	CMP R2, 0d ;----------------------se o numero acabou
	JMP.NZ ImprimeDigito ;------------Loop

	POP R3
	POP R2
	POP R1
	RET



;------------------------------------------------------------------------------
; 							   	IMPRIME STRING
;------------------------------------------------------------------------------
;	{ Imprime strings em bloco na posição de memória e de tela referenciadas }
;------------------------------------------------------------------------------
ImprimeString:PUSH R1 ;---------------------------------------------Coordenada
	PUSH R2 ;-------------------------------------------------Coluna/Aux
	PUSH R3 ;-------------------------------------------------Memoria
	PUSH R4 ;-------------------------------------------------Char
;--------------------------Atribuição:
	MOV R1, M[ScreenLine]
	SHL R1, 8d
	MOV R2,  M[ScreenColum]
	OR R1, R2
	MOV R3, M[TextIndex]
;--------------------------Impressão:
ImprimeLinha: MOV R4, M[R3]

	CMP R4, FIM_LINHA ;------------R3 == '@' FIM_LINHA
	JMP.Z ProximaLinha
	CMP R4, FIM_TEXTO ;------------R3 == '!' FIM_TEXTO
	JMP.Z FimImprimeString

	MOV M[ CURSOR ], R1    ;-------cursor assume posição
	MOV M[ IO_WRITE ], R4    ;-----escreve no cursor
	INC R3   ;---------------------próximo caracter
	INC R1   ;---------------------anda na coluna
	JMP ImprimeLinha    ;----------volta para printlinha

ProximaLinha:  	SHR R1, 8d    ;----0000Linha
	INC R1    ;--------------------0000Linha +1
	SHL R1, 8d    ;----------------Linha0000
	OR R1, R2 ;--------------------Realinha texto com a coluna inicial

	INC R3 ;-----------------------próximo caracter
	JMP ImprimeLinha;--------------volta para imprimelinha

FimImprimeString: POP R4
	POP R3
	POP R2
	POP R1

		RET

;------------------------------------------------------------------------------
;								IMPRIME MOVIMENTO
;------------------------------------------------------------------------------
; { Imprime na tela a atualização de movimento da posição antiga e nova }
;------------------------------------------------------------------------------
ImprimeMovimento: PUSH R1 ;----------------------------------Coordenada
	PUSH R2 ;------------------------------------------------Char

;------------------------------Antiga Posição:
	MOV R1, M[WasInCoord]
	MOV M[CURSOR], R1
	MOV R1, M[WasOn]
	MOV M[IO_WRITE], R1

;------------------------------Nova Posição:
	MOV R1, M[IsInCoord]
	MOV M[CURSOR], R1
	MOV R1, M[IsOn]
	MOV M[IO_WRITE], R1

	POP R2
	POP R1
	RET

;------------------------------------------------------------------------------
; 								INICIALIZA
;------------------------------------------------------------------------------
;			{ Atribui as posições iniciais e imprime na tela}
;------------------------------------------------------------------------------
Inicializa: PUSH R1 ;-------------------------------------------Valores
	PUSH R2 ;---------------------------------------------------Auxiliar

	MOV R2, L0

;///////////////////////////{ PACMAN }\\\\\\\\\\\\\\\\\\\\\\\\\\
	MOV R1, SEM_MOVIMENTO
	MOV M[PacManDirection], R1

	MOV R1, PACMAN_STARTM
	ADD R1, R2 ;----------------L0 + posição no mapa
	MOV M[PacManInMem], R1 ;----Memória

	MOV R1, PACMAN_START
	MOV M[PacManCoord], R1 ;----Coordenada

	MOV M[CURSOR], R1
	MOV R1, PACMAN
	MOV M[IO_WRITE], R1 ;-------Tela

;/////////////////////////{ GHOST SHY }\\\\\\\\\\\\\\\\\\\\\\\\\\
    MOV R1, ESQ
	MOV M[ShyDirection], R1

	MOV R1, SHY_STARTM
	ADD R1, R2 ;----------------L0 + posição no mapa
	MOV M[ShyInMem], R1 ;-------Memória

	MOV R1, SHY_START
	MOV M[ShyCoord], R1 ;-------Coordenada

	MOV M[CURSOR], R1
	MOV R1, GHOST
	MOV M[IO_WRITE], R1 ;-------Tela

;/////////////////////////{ GHOST STALKER }\\\\\\\\\\\\\\\\\\\\\\\\\\
	MOV R1, DIR
	MOV M[StalkerDirection], R1

	MOV R1, STALKER_STARTM
	ADD R1, R2
	MOV M[StalkerInMem], R1

	MOV R1, STALKER_START
	MOV M[StalkerCoord], R1

	MOV M[CURSOR], R1
	MOV R1, GHOST
	MOV M[IO_WRITE], R1

	POP R2
	POP R1
	RET

;------------------------------------------------------------------------------
;							CALCULA POSIÇÃO
;------------------------------------------------------------------------------
;      {Calcula a posição indicada pela direção referida e salva valores}
;------------------------------------------------------------------------------
CalculaNew: PUSH R1 ;------------------------------------------Direção
			PUSH R2 ;------------------------------------------Coordenada
			PUSH R3 ;------------------------------------------Memoria
			PUSH R4 ;------------------------------------------Char

;---------------------------Atribuição:
	MOV R1, M[Direction]
	MOV R2, M[WasInCoord]
	MOV R3, M[WasInMem]
	MOV R4, M[WasOn]

;---------------------------Identificação:
	CMP R1, ESQ
	JMP.Z MoveEsquerda
	CMP R1, DIR
	JMP.Z MoveDireita
	CMP R1, CIMA
	JMP.Z MoveCima
	CMP R1, BAIXO
	JMP.Z MoveBaixo
	JMP CompletaTabela

;---------------------------Cálculos de Memória/Coordenada:
MoveEsquerda: DEC R3
	DEC R2
	JMP CompletaTabela

MoveDireita: INC R3
	INC R2
	JMP CompletaTabela

MoveCima:	SUB R3, QTD_COLUM
	SUB R2, UND_LINHAS
	JMP CompletaTabela

MoveBaixo:	ADD R3, QTD_COLUM
	ADD R2, UND_LINHAS
	JMP CompletaTabela

;---------------------------Completa tabela:
CompletaTabela: MOV R4, M[R3]
	MOV M[IsInCoord], R2
	MOV M[IsInMem], R3
	MOV M[IsOn], R4

FimCalculaNew:	POP R4
				POP R3
				POP R2
				POP R1
				RET

;------------------------------------------------------------------------------
;								COME PONTO
;------------------------------------------------------------------------------
;			 {Substitui na memoria o ponto na localização por vazio}
;------------------------------------------------------------------------------
ComePonto: PUSH R1 ;----------------------------------------Localização
	PUSH R2 ;-----------------------------------------------Simbolo

	MOV R1, M[IsInMem]
	MOV R2, NULLSPACE

	MOV M[R1], R2
	MOV M[IsOn], R2

	POP R2
	POP R1
	RET

;------------------------------------------------------------------------------
;								PONTUAÇÃO
;------------------------------------------------------------------------------
;			 {Incrementa a pontuação, atualiza e imprime na tela}
;------------------------------------------------------------------------------
Pontuacao: PUSH R1 ;-----------------------------------------Coordenada
	PUSH R2 ;------------------------------------------------Pontos
	PUSH R3 ;------------------------------------------------Aux

;------------------------Come Ponto:
	CALL ComePonto

;------------------------Calculo:
	MOV R2, M[ScoreValue]
	INC R2
	MOV M[ScoreValue], R2

;------------------------Impressão:
	MOV R3, LIFELINE
    MOV M[ScreenLine], R3
    MOV M[TextIndex], R2
	MOV R1, M[ScoreColum]
	MOV M[ScreenColum], R1

    CALL ImprimeInteiro

;------------------------Verificação de Max:
	MOV R3, MAX_SCORE
	CMP R3, R2
	JMP.NZ FimPontuacao

;------------------------Caso Ganhe:
		CALL FimDeJogo

FimPontuacao:	POP R3
	POP R2
	POP R1
	RET

;------------------------------------------------------------------------------
;								FIM DE JOGO
;------------------------------------------------------------------------------
;					{Imprime Fim de Jogo e Finaliza}
;------------------------------------------------------------------------------
FimDeJogo: PUSH R1

;------------[End Screen]:
		MOV R1, Win1
		MOV M[TextIndex], R1
		MOV R1, ENDSCREEN_L
		MOV M[ScreenLine], R1
		MOV R1, ENDSCREEN_C
		MOV M[ScreenColum], R1
		CALL ImprimeString

		MOV R1, GAME_OVER
		MOV M[GameStatus], R1

		POP R1
		RET

;------------------------------------------------------------------------------
;								   MORDIDA
;------------------------------------------------------------------------------
;				   {Reduz uma vida e reposiciona elementos}
;------------------------------------------------------------------------------
Mordida:	PUSH R1 ;------------------------------------- Lifes
		PUSH R2 ;----------------------------------------- Hearts

;---------------------------Reduz Graficamente:
		MOV R1, GhostBite ;----------[' --']
		MOV M[TextIndex], R1
		MOV R1, LIFELINE
		MOV M[ScreenLine], R1
		MOV R1, M[LifeColum]
		MOV M[ScreenColum], R1
		SUB R1, 3d ;---------------------Anda 3 pra trás na coordenada de Life
		MOV M[LifeColum], R1 ;-----------Atualiza proxima redução de vida na tela
		CALL ImprimeString

;---------------------------Reduz Vida:
		MOV R2, M[PacLifes]
		SUB R2, 1d
		MOV M[PacLifes], R2

;---------------------------Reposiciona elementos:
		CALL Reseta

;---------------------------Caso Acabe:
		CMP R2, 0d ;---------------------Se a vida zerou
		CALL.Z FimDeJogo

	POP R2
	POP R1
	RET

;-------------------------------------------------------------------------------
;									RESETA
;-------------------------------------------------------------------------------
;					{Limpa posições e reinicia elementos}
;-------------------------------------------------------------------------------
Reseta: PUSH R1

;----------------------Limpa Posições:
;/////////////////////////{ PACMAN }\\\\\\\\\\\\\\\\\\\\\\\\\\
		MOV R1, M[PacManCoord]
		MOV M[CURSOR], R1
		MOV R1, NULLSPACE
		MOV M[IO_WRITE], R1

;/////////////////////////{ GHOST SHY }\\\\\\\\\\\\\\\\\\\\\\\\\\
		MOV R1, M[ShyCoord]
		MOV M[CURSOR], R1
		MOV R1, M[ShyIsOn]
		MOV M[IO_WRITE], R1

;/////////////////////////{ GHOST SHY }\\\\\\\\\\\\\\\\\\\\\\\\\\
		MOV R1, M[StalkerCoord]
		MOV M[CURSOR], R1
		MOV R1, M[StalkerIsOn]
		MOV M[IO_WRITE], R1

;----------------------Retorna a Posição Inicial:
		CALL Inicializa

	POP R1
	RET

;------------------------------------------------------------------------------
;								DIRECIONA PAC
;------------------------------------------------------------------------------
;{Conjunto de funções que atribui o correspondente numerico a direção pela interrupção}
;------------------------------------------------------------------------------
PacManUp: 	PUSH R1    ;--------------------direção
			MOV R1, CIMA    ;---------------pega o numero correspondente a UP
			MOV M[PacManDirection], R1 ;----atualiza a direção
			POP R1
			RTI

PacManDown: PUSH R1    ;--------------------direção
			MOV R1, BAIXO   ;---------------pega o numero correspondente a DOWN
			MOV M[PacManDirection], R1 ;----atualiza a direção
			POP R1
			RTI

PacManLeft: PUSH R1    ;--------------------direção
			MOV R1, ESQ   ;-----------------pega o numero correspondente a LEFT
			MOV M[PacManDirection], R1 ;----atualiza a direção
			POP R1
			RTI

PacManRight: 	PUSH R1    ;----------------direção
			MOV R1, DIR   ;-----------------pega o numero correspondente a RIGHT
			MOV M[PacManDirection], R1 ;----atualiza a direção
			POP R1
			RTI

;------------------------------------------------------------------------------
;								CICLO GAME
;------------------------------------------------------------------------------
;     {Realiza as movimentaçoes necessárias em cada ciclo do cronômetro}
;------------------------------------------------------------------------------
CicloGame: PUSH R1 ;----------------------------------------------Direção/AUX
	PUSH R2 ;-----------------------------------------------------Memoria
	PUSH R3 ;-----------------------------------------------------Coord
	PUSH R4 ;-----------------------------------------------------Char

	MOV R1, M[GameStatus]
	CMP R1, GAME_OVER
	JMP.Z FimCicloGame

;//////////////////////////////[PACMAN]\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;---------------------Atribuição:
	MOV R1, M[PacManDirection]
	CMP R1, SEM_MOVIMENTO
	JMP.Z MovimentaShy
	MOV M[Direction], R1

	MOV R2, M[PacManInMem]
	MOV R3, M[PacManCoord]
	MOV R4, NULLSPACE

	MOV M[WasInMem], R2
	MOV M[WasInCoord], R3
	MOV M[WasOn], R4

;---------------------Calcula:
	CALL CalculaNew

;---------------------Reatribuição:
	MOV R2, M[IsInMem]
	MOV R3, M[IsInCoord]
	MOV R4, M[IsOn]

;---------------------Verifica Encontro:
	MOV R1, M[ShyInMem]
	CMP R2, R1
	JMP.Z Encontro

;---------------------Verifica Ponto:
	CMP R4, FOOD
	CALL.Z Pontuacao
	MOV R4, M[IsOn]

;---------------------Verifica Se Pode Mover:
	CMP R4, NULLSPACE
	JMP.Z AtribuicaoPac

	MOV R1, SEM_MOVIMENTO
	MOV M[PacManDirection], R1
	JMP MovimentaShy

;---------------------Atribui Valores para PacMan:
AtribuicaoPac:	MOV M[PacManInMem], R2
				MOV M[PacManCoord], R3

;---------------------Movimenta PacMan:
	MOV R1, PACMAN
	MOV M[IsOn], R1
	CALL ImprimeMovimento

;/////////////////////////////[GHOSTSHY]\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;---------------------Atribuição:
MovimentaShy: MOV R1, M[ShyDirection]
	MOV R2, M[ShyInMem]
	MOV R3, M[ShyCoord]
	MOV R4, M[ShyIsOn]

	MOV M[Direction], R1
	MOV M[WasInMem], R2
	MOV M[WasInCoord], R3
	MOV M[WasOn], R4

;---------------------Calcula:
CalculoShy: CALL CalculaNew

;---------------------Reatribuição:
	MOV R2, M[IsInMem]
	MOV R3, M[IsInCoord]
	MOV R4, M[IsOn]

;---------------------Verifica Encontro:
	MOV R1, M[PacManInMem]
	CMP R2, R1
	JMP.Z Encontro

;---------------------Verifica Se Pode Mover:
	CMP R4, FOOD
	JMP.Z AtribuicaoShy

	CMP R4, NULLSPACE
	JMP.Z AtribuicaoShy

;---------------------Gerador de Direcao
	CALL GeradorDirecao
	JMP CalculoShy

;---------------------Atribui Valores para Shy:

AtribuicaoShy:  MOV R1, M[Direction]
				MOV M[ShyDirection], R1
				MOV M[ShyInMem], R2
				MOV M[ShyCoord], R3
				MOV M[ShyIsOn], R4


;---------------------Movimenta Shy:
	MOV R1, GHOST
	MOV M[IsOn], R1
	CALL ImprimeMovimento

;/////////////////////////////[GHOSTSTALKER]\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;---------------------Atribuição:
MovimentaStalker: MOV R1, M[StalkerDirection]
	MOV R2, M[StalkerInMem]
	MOV R3, M[StalkerCoord]
	MOV R4, M[StalkerIsOn]

	MOV M[Direction], R1
	MOV M[WasInMem], R2
	MOV M[WasInCoord], R3
	MOV M[WasOn], R4

;---------------------Calcula:
CalculoStalker: CALL CalculaNew

;---------------------Reatribuição:
	MOV R2, M[IsInMem]
	MOV R3, M[IsInCoord]
	MOV R4, M[IsOn]

;---------------------Verifica Encontro:
	MOV R1, M[PacManInMem]
	CMP R2, R1
	JMP.Z Encontro

;---------------------Verifica Se Pode Mover:
	CMP R4, FOOD
	JMP.Z AtribuicaoStalker

	CMP R4, NULLSPACE
	JMP.Z AtribuicaoStalker

;---------------------Gerador de Direcao
	CALL GeradorDirecao
	JMP CalculoStalker

;---------------------Atribui Valores para Stalker:

AtribuicaoStalker:  MOV R1, M[Direction]
				MOV M[StalkerDirection], R1
				MOV M[StalkerInMem], R2
				MOV M[StalkerCoord], R3
				MOV M[StalkerIsOn], R4


;---------------------Movimenta Stalker:
	MOV R1, GHOST
	MOV M[IsOn], R1
	CALL ImprimeMovimento


	JMP FimCicloGame
;--------------------Caso Tenha Mordido: !!JMP pra ca
Encontro: CALL Mordida

FimCicloGame: CALL ConfiguraTimer

		POP R4
		POP R3
		POP R2
		POP R1
		RTI
;==============================================================================
; Função Main
;==============================================================================
Main:			ENI

				MOV		R1, INITIAL_SP
				MOV		SP, R1		 		; We need to initialize the stack
				MOV		R1, CURSOR_INIT		; We need to initialize the cursor
				MOV		M[ CURSOR ], R1		; with value CURSOR_INIT

				;-----Imprime Mapa:
				MOV     R1, 0d
				MOV 	M[ScreenLine], R1
				MOV     M[ScreenColum], R1
				MOV     R1, L0
				MOV  	M[TextIndex], R1
				CALL ImprimeString

				;-----Pontos de Start:
				CALL Inicializa

				;-----Timer:
				CALL ConfiguraTimer


Cycle: 			BR		Cycle	
Halt:       BR		Halt
