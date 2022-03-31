##################################################################
# ALUNO: Hyago Gabriel
# MATRÍCULA: 17/0105067
# TURMA: C
##################################################################

.data 
mat1:  .byte 
       0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
       0 1 1 0 0 0 1 0 0 0 0 0 0 0 0 0 
       0 1 1 0 0 0 0 1 0 0 0 0 0 0 0 0 
       0 0 0 0 0 1 1 1 0 0 0 0 0 0 0 0 
       0 0 0 0 0 0 0 0 0 0 0 1 1 1 0 0 
       0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
       0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
       0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
       0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
       0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
       0 0 0 1 1 0 0 0 0 0 1 1 1 0 0 0 
       0 0 1 1 0 0 0 0 0 0 0 1 0 0 0 0 
       0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 
       0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
       0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 
       0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
mat2:  .byte  0:255

cor: 0xFF00FF

.text
	li t0, 50		# qtde de iteracoes
	jal CONFIG
	jal RUN_GAME
END_GAME:
	li a7,10
	ecall
		
##################################################################
# write
# Entradas:
# 			a0 = linha;
#			a1 = coluna;
#			a2 = mat adress;
# Saida:
#			n/a
#			o dado correspondente a linha e coluna na matriz argumento é alterado
##################################################################
WRITE:	li t6, 16
	mul a0, a0, t6
	add a0, a0, a1
	add a2, a2, a0
	lbu t6, 0(a2)
	xori a0,t6, 1
	sb a0, 0(a2) 
	ret
################################################################### write

##################################################################
# readm
# Entradas:
# 			a0 = linha;
#			a1 = coluna;
#			a2 = mat adress;
# Saida:
#			a0 = o dado correspondente a linha e coluna na matriz argumento
##################################################################
READM:	li t6, 16
	mul a0, a0, t6
	add a0, a0, a1
	add a0, a2, a0
	lb a0, 0(a0)
	ret
################################################################### readm

##################################################################
# CONFIG
#	-> Inicializa os registradores utilizados no programa
# Entradas:
#			N/A
# Saida:
#			n/a
##################################################################
CONFIG:	li t1,0x00003000	# endereco inicial da heap
	li t2,0x00003400	# endereco final de teste
	la t3, cor		# cor
	la t4, mat1		# mat 1
	la s0, mat2		# mat 2
	li t5, 0		# contador para vizinho
	ret
##################################################################

##################################################################
# RUN
#	-> Processo dito "principal". Aqui é orquestrado o andamento do jogo
# Entradas:
#			N/A
# Saida:
#			n/a
##################################################################
RUN_GAME:	ble t0, zero, STOP_GAME
		li t1,0x00003000		# endereco inicial da heap
		mv a0, t4
		jal PLOTM
		mv a2, t4
		jal CELL_JUDGE
JUDGED:		li a0, 500
		li a7, 32
		ecall
		jal BITMAP_CLEANER
		
		addi s0, s0, -256

		mv a0, s0
		mv s0, t4
		mv t4, a0
		
		addi t0,t0,-1
		j RUN_GAME
STOP_GAME:	j END_GAME
################################################################### RUN

##################################################################
# LIMPA BITMAP
# Entradas:
#			N/A
# Saida:
#			N/A
#			O bitmap é zerado (pintado pela cor presente no registrador t5)
##################################################################	
BITMAP_CLEANER: 		li t1,0x00003000		# endereco inicial da heap
LOOP_BLACKOUT:			beq t1,t2,BLACK_OUT		# Se for o último endereço então sai do loop
				sw t3,0(t1)			# escreve a word na memória
				li t5, 0x000000
				sw t5,0(t1)
				addi t1,t1, 4			# soma 4 ao endereço
				j LOOP_BLACKOUT			# volta a verificar
BLACK_OUT:			li t1,0x00003000
				ret
##################################################################

##################################################################
# Inverte pixel
# 
#	IDEM AO WRITE, função realizada antes do processo de refatoração
#	-> Espólio para fins de estudo
#
##################################################################
#PIXEL_INVERTER:	xori t6,t6,1
#		sb t6, 0(s0)
#		j RETORNO_INVERT
################################################################### Inverte pixel

##################################################################
# NASCE pixel
# Entrada:
# 			N/A
# Saída:
#			n/a
# 			o pixel é marcado como VIVO na matriz 2 (utilizada como auxiliar no cálculo de CELL_JUDGE)
##################################################################
PIXEL_BIRTH:	li t6, 1
		sb t6, 0(s0)
		j RETORNO_INVERT
################################################################### Inverte pixel

##################################################################
# MATA pixel
# Entrada:
# 			N/A
# Saída:
#			n/a
# 			o pixel é marcado como MORTO na matriz 2 (utilizada como auxiliar no cálculo de CELL_JUDGE)
##################################################################
PIXEL_DEATH:	li t6, 0
		sb t6, 0(s0)
		j RETORNO_INVERT
################################################################### Inverte pixel

###################################################################
# Julga a capacidade de um pixel sobreviver
# Entrada:
# 			a0 = linha
# 			a1 = coluna
#			a2 = mat adress
# Saída:
#			n/a
# 			a matriz 2 é trocada pela nova matriz resultante dos julgamentos
###################################################################
CELL_JUDGE: 	li a0,0
		li a1,0
LOOP_JUDGE:	li t6, 15
		bgt a0, t6, FORA			# Se for o último endereço então sai do loop
		j NEIGHBORHOOD				#retorna em a4
RETURN_NEIGHBORHOOD_COUNTER:
		li t6, 2
		blt a4, t6, PIXEL_DEATH
		li t6, 3
		beq a4, t6, PIXEL_BIRTH
		bgt a4, t6, PIXEL_DEATH
		#ESCREVER O PROPRIO PIXEL
		mv a5, a0
		jal READM
		sb a0, 0(s0)				# escreve a word na memória
		mv a0, a5
RETORNO_INVERT:
		addi s0,s0,1
		addi a1, a1, 1
		li t6, 15
		bgt a1, t6, LINE_JUMPER
		j LOOP_JUDGE
LINE_JUMPER:	mv a1, zero
		addi a0,a0, 1
		j LOOP_JUDGE
FORA:		j JUDGED
################################################################### Printa matriz no bitmap

###################################################################
# Printa matriz no bitmap
# Entrada:
# 			a0 = mat adress
# Saída:
#			n/a
# 			é "pintado" no bitmap a matriz  
###################################################################
PRINT_TARGET_PIXEL:		sw t3,0(t1)			# escreve a word na memória
				j RETORNO_ANY_PRINTER
PLOTM: 				beq t1,t2,OUT			# Se for o último endereço então sai do loop
				lb t5, 0(a0)
				bne t5, zero, PRINT_TARGET_PIXEL
				li t5, 0xFF00FF
				sw t5,0(t1)
RETORNO_ANY_PRINTER:		addi t1,t1, 4			# soma 4 ao endereço
				addi a0, a0, 1
				j PLOTM				# volta a verificar
OUT:				ret
################################################################### Printa matriz no bitmap

##################################################################
# Conta vizinhos
# Entrada:
# 			a0 = linha
# 			a1 = coluna
#			a2 = mat adress
# Saída:
#			a4 = qtde de vizinhos que o pixel na posição indicada possui
##################################################################
BACKUP:		mv a0, a5			# linha
		mv a1, a6			# coluna
		ret
		
NEIGHBORHOOD: 	li a4, 0			#contador
		mv a5, a0			# linha
		mv a6, a1			# coluna
		
SUP_ESQ:	addi a0, a0, -1
		addi a1, a1, -1
		blt a0, zero, ESQ
		blt a1, zero, SUP
		jal READM
		beq a0, zero, SUP
		addi a4, a4, 1

SUP:		jal BACKUP
		addi a0, a0, -1
		addi a1, a1, 0
		jal READM
		beq a0, zero, SUP_DIR
		addi a4, a4, 1
		
SUP_DIR:	jal BACKUP
		addi a0, a0, -1
		addi a1, a1, 1
		li t6, 15
		bgt a1, t6, ESQ
		jal READM
		beq a0, zero, ESQ
		addi a4, a4, 1
		
ESQ:		jal BACKUP
		addi a0, a0, 0
		addi a1, a1, -1
		blt a1, zero, DIR
		jal READM
		beq a0, zero, DIR
		addi a4, a4, 1
	
DIR:		jal BACKUP
		addi a0, a0, 0
		addi a1, a1, 1
		li t6, 15
		bgt a1, t6, INF_ESQ
		jal READM
		beq a0, zero, INF_ESQ
		addi a4, a4, 1
		
INF_ESQ:	jal BACKUP
		addi a0, a0, 1
		addi a1, a1, -1
		li t6, 15
		bgt a0, t6, QUIT_COUNTER
		blt a1, zero, INF
		jal READM
		beq a0, zero, INF
		addi a4, a4, 1

INF:		jal BACKUP
		addi a0, a0, 1
		addi a1, a1, 0
		jal READM
		beq a0, zero, INF_DIR
		addi a4, a4, 1

INF_DIR:	jal BACKUP
		addi a0, a0, 1
		addi a1, a1, 1
		li t6, 15
		bgt a1, t6, QUIT_COUNTER
		jal READM
		beq a0, zero, QUIT_COUNTER
		addi a4, a4, 1
		
QUIT_COUNTER:	jal BACKUP
		j RETURN_NEIGHBORHOOD_COUNTER
		
#	indicação guia para realização dos saltos
#NO_UPPER_NEIGHBOR:
		#ESQ
		#DIR
		#INF_ESQ
		#INF
		#INF_DIR
#NO_LEFT_NEIBOR:
		#SUP
		#SUP_DIR
		#DIR
		#INF
		#INF_DIR
#NO_BOTTOM:	
		#SUP_ESQ
		#SUP
		#SUP_DIR
		#ESQ
		#DIR
#NO_RIGHT_NEIBOR
		#SUP
		#SUP_ESQ
		#ESQ
		#INF
		#INF_ESQ
################################################################### Conta vizinhos
	

