#CONSTANTES DE LA FUNCION PAINT
#define SS 56
#define offset_ra 44
#define offset_fp 40
#define offset_gp 36

#define offset_a1 56
#define offset_a2 60
#define offset_a3 64
#define offset_a4 68

#define LRA_GRID 32
#define LRA_ITER 28
#define LRA_P 20
#define LRA_R 24
#define LRA_ANT 16
#define ABA_ANT 8
#define ABA_R 4
#define ABA_GRID 0

#CONSTANTES DE LA FUNCION BEGINNING_ANT
#define SS_ba 8
#define of_fp_ba 4
#define of_gp_ba 0

#define of_a0_ba 8

#CONSTANTES DE LA FUNCION MOVE_ANT
#define SS_ma 8
#define of_fp_ma 4
#define of_gp_ma 0

#define of_a0_ma  8
#define of_a1_ma  12
#define of_a2_ma  16

#CONSTANTES DE LA FUNCION CHANGE_ORIENTATION
#define SS_co 8
#define of_fp_co 4
#define of_gp_co 0

#define of_a0_co 8
#define of_a1_co 12


#define ON 0
#define OS 1
#define OE 2
#define OW 3

#COMIENZA EL CODIGO

        .text
        .align 2

        .globl paint
        .ent	paint
#------------------------------------------------------------------------------------------------------------------------------
#                                       FUNCION PAINT
#------------------------------------------------------------------------------------------------------------------------------

#|iterations|
#|rules     |
#|palette   |
#|grid      |
#|ant       |
#|----------|
#|PADDING   |
#|ra        |
#|fp        |   SRA
#|gp        |
#|----------|
#|PADDING   |
#|grid      |
#|iter      |
#|r         |
#|p         |   LTA
#|ant       |
#|----------|
#|PADDING   |
#|          |
#|          |   ABA
#|          |
#|----------|

paint: #paint(void *ant1, void *grid1, void *palette1, void *rules1,  uint32_t iterations)
      #creo el stack
      subu $sp,$sp,SS
      sw $ra,offset_ra($sp)
      sw $fp,offset_fp($sp)
      sw $gp,offset_gp($sp)
      move $fp,$sp

      #Argument building Area
      sw $a0,SS($fp) #ant
      sw $a1,offset_a1($fp) #grid
      sw $a2,offset_a2($fp) #pallete
      sw $a3,offset_a3($fp) #rules


      #Saved Registers Area
      lw $t0, offset_a4($fp) #iterations
      sw $t0,LRA_ITER($fp)

      lw $t0, offset_a2($fp)
      sw $t0,LRA_P($fp)

      lw $t0, offset_a3($fp) #rules
      sw $t0,LRA_R($fp)

      lw $t0, SS($fp)   #ant
      sw $t0,LRA_ANT($fp)

      lw $t0, offset_a1($fp) #grid
      sw $t0,LRA_GRID($fp)

      b LOOP_WHILE
      nop


      #codigo de la FUNCION
LOOP_WHILE:
      lw $t0, LRA_ITER($fp) #t0 = iterations
      beqz $t0, FIN

      lw $t1, LRA_P($fp) #t1 = palette (t1=p) (fijarse como hscer para que entiendas que es un colour_t*)
      addi $t1,$t1,1 #p++

      sw $t1, LRA_P($fp) #guardo el valores de la pallete (p)

      lw $a0, LRA_ANT($fp) #t2 = ant*

      la $t3, beginning_ant #beginning_ant(ant*)
      jalr $t3

      sw $v0, LRA_ANT($fp) #guardo el valor del ant* que me devolvio

      b LOOP_FOR
LOOP_FOR:
      lw $t4, LRA_R #t4 = rules*
      addi $t6,$t4,1 #rules++
      beqz $t6,DECREMENTAR_ITER #si r+1 = 0 termina


      #FALTA HACER grid->grid[ant->x][ant->y] = *p;
      lw $t7,LRA_GRID($fp) #t7 = square_grid_t* grid
      lw $t8, 8($t7) #t8 = grid->grid (colour_t **)

      lw $t9, LRA_ANT($fp) #t9 = ant*
      lw $t1, 0($t9) #t1 = ant->x

      addu $t1,$t1,$t8 # t1 = grid->grid[ant->x]

      lw $t3, 4($t9) # t3 = ant->y
      addu $t1,$t3,$t1 # t1 = grid->grid[antx][ant->y]

      lw $t4,LRA_P($fp) #t4 = p (pallete)
      lw $t5, 0($t4) #t5 = *p
      sw $t5, 0($t1) #  grid->grid[ant->x][ant->y] = *p;

      lw $a0, LRA_ANT($fp)

      lw $t7,LRA_R($fp)
      lw $a1,0($t7) #t8 = *r

      la $t1, change_orientation
      jalr $t1

      sw $v0, LRA_ANT($fp)

      lw $a0, LRA_ANT($fp)

      lw $a1, LRA_GRID($fp)


      lw $t7,LRA_R($fp)
      lw $a2,0($t7) #t8 = *r

      la $t7,move_ant
      jalr $t7

      sw $v0, LRA_ANT($fp)

      lw $t7,LRA_ANT($fp)
      sw $t7,ABA_ANT($fp)

      lw $t7,LRA_R($fp)
      lw $t8,0($t7) #t8 = *r
      sw $t8,ABA_R($fp)

      lw $t7,LRA_GRID($fp)
      sw $t7,ABA_GRID($fp)

      la $t7,move_ant
      jalr $t7

      sw $v0, LRA_ANT($fp)

      lw $t7,LRA_P
      addi $t7,$t7,1

      lw $t8, 0($t7) #t8 = *p
      addi $t8,$t8,1
      beqz $t8,RESET_PALLETE
      b LOOP_FOR



RESET_PALLETE:

      lw $t7,LRA_P
      addi $t7,$t7,1

      lw $t8, 0($t7) #t8 = *p
      lw $t2, offset_a2($fp) #t2 = pallete*
      lw $t1, 0($t2)
      lw $t2, 0($t8) # *p = pallete[0]

      B LOOP_FOR



DECREMENTAR_ITER:
      lw $t5,LRA_ITER($fp)
      addi $t5,$t5,-1
      sw $t5,LRA_ITER
      b LOOP_WHILE

FIN:
      lw $v0,LRA_GRID($fp)

      #desarmo el stack
      move $sp,$fp
      lw $fp,offset_fp($sp)
      lw $gp,offset_gp($sp)
      lw $ra, offset_ra($sp)
      addu $sp,$sp,SS
      jr $ra

      .end paint




#------------------------------------------------------------------------------------------------------------------------------
#                                       FUNCION BEGINNING_ANT
#------------------------------------------------------------------------------------------------------------------------------

#|----------|
#|PADDING   |
#|PADDING   |
#|PADDING   |   ABA DE PAINT
#|ant       |
#|----------|
#|fp        |
#|gp        |   SRA
#|----------|

#Parametros a0 puntero a ant_t.
      .globl beginning_ant
beginning_ant:    .ent beginning_ant

          		#prologo beginning_ant
      		subu $sp, $sp, SS_ba
      		.cprestore of_gp_ba

      		sw $fp, of_fp_ba($sp)
            	sw $gp, of_gp_ba($sp)

     			move $fp, $sp

     			sw $a0,of_a0_ba($fp)


     			la $t0, 0($a0)      #Addr of Ant->x
     			la $t1, 4($a0)	#Addr of Ant->y
     			la $t2, 8($a0)	#Addr of Ant->o

     			lw $t3, 0($t0)		#Ant->x
     			lw $t4, 0($t1)		#Ant->y
     			lw $t5, 0($t2)		#Ant->o

     			addi $t3, $zero, 1	#Ant->x = 1
     			addi $t4, $zero, 1	#Ant->y = 1
     			add  $t5, $zero, $zero	#Ant->o = 0 (0 es la constante ON)

     			sw $t3, 0($a0)
     			sw $t4, 4($a0)
     			sw $t5, 8($a0)

      		#epilogo beginning_ant
      		lw $fp, of_fp_ba($sp)
      		lw $gp, of_gp_ba($sp)

      		addi $sp, $sp, SS_ba
      		jr $ra

      		.end beginning_ant

#------------------------------------------------------------------------------------------------------------------------------
#                                       FUNCION MOVE_ANT
#------------------------------------------------------------------------------------------------------------------------------
#|----------|
#|PADDING   |
#|r*        |
#|grid      |   ABA DE PAINT
#|ant       |
#|----------|
#|fp        |
#|gp        |   SRA
#|----------|
      .globl move_ant
      .ent move_ant

move_ant: #ant_t* move_ant(ant_t *ant, square_grid_t *grid, rotation_t rule)

            #Creo el stack
            subu $sp,$sp,SS_ma
            #sw $ra,offset_ra(sp)
            sw $fp,of_fp_ma($sp)
            sw $gp,of_gp_ma($sp)
            move $fp,$sp

            sw $a0,of_a0_ma($fp) #addr ant
            sw $a1,of_a1_ma($fp) #addr grid
            sw $a2,of_a2_ma($fp) #r

            #Codigo de la FUNCION
            lw $t1,of_a0_ma($fp) #t1= ant*
            lw $t2,12($t1) #t2 = ant->o

            beqz $t2,CASE_ON

            subu $t3,$t2,1

            beqz $t3,CASE_OS

            subu $t3,$t2,1

            beqz $t3,CASE_OE

            subu $t3,$t2,1

            beqz $t3,CASE_OW

FIN_MA:
           #desarmo el stack
            move $sp,$fp
            lw $fp,of_fp_ma($sp)
            lw $gp,of_gp_ma($sp)
            #lw ra, offset_ra(sp)
            addu $sp,$sp,SS_ma
            jr $ra


CASE_ON:
      lw $t5,0($t1) #t5 = ant->x

      lw $t6,of_a1_ma($fp) #t6 = grid*
      lw $t7,4($t6) #t7 = grid->height
      addi $t7,$t7,-1

      sub $t7, $t5,$t7
      beqz $t7,ANTX_ON
      addi $t5,$t5,1 #ant->x++
      sw $t5,0($t1) #ant->x = ant->x++
      j FIN_SWITCH

ANTX_ON:
      sw $zero,0($t1) #ant->x = 0
      j FIN_SWITCH

CASE_OS:
      lw $t5,0($t1) #t5 = ant->x

      beqz $t5,ANTX_OS
      addi $t5,$t5,-1 #ant->x--
      sw $t5,0($t1) #ant->x = ant->x--
      j FIN_SWITCH

ANTX_OS:

      lw $t6,of_a1_ma($fp) #t6 = grid*
      lw $t7,4($t6) #t7 = grid->height
      addi $t7,$t7,-1

      sw $t7,0($t1) #ant->x = grid->height-1
      j FIN_SWITCH

CASE_OE:
      lw $t5,4($t1) #t5 = ant->y

      lw $t6,of_a1_ma($fp) #t6 = grid*
      lw $t7,0($t6) #t7 = grid->width
      addi $t7,$t7,-1

      sub $t7, $t5,$t7
      beqz $t7,ANTX_OE
      addi $t5,$t5,1 #ant->y++
      sw $t5,4($t1) #ant->y = ant->y++
      j FIN_SWITCH

ANTX_OE:

      sw $zero,4($t1) #ant->y = 0
      j FIN_SWITCH

CASE_OW:
      lw $t5,4($t1) #t5 = ant->y

      beqz $t5,ANTX_OE
      addi $t5,$t5,-1 #ant->y--
      sw $t5,4($t1) #ant->y = ant->y--
      j FIN_SWITCH

ANTX_OW:
      lw $t6,of_a1_ma($fp) #t6 = grid*
      lw $t7,0($t6) #t7 = grid->width
      addi $t7,$t7,-1

      sw $t7,4($t1) #ant->y = grid->width-1
      j FIN_SWITCH

FIN_SWITCH:
      move $v0,$t1
      j FIN_MA


      .end move_ant
#------------------------------------------------------------------------------------------------------------------------------
#                                       FUNCION CHANGE_ORIENTATION
#------------------------------------------------------------------------------------------------------------------------------
#|----------|
#|PADDING   |
#|PADDING   |
#|r         |   ABA DE PAINT
#|ant       |
#|----------|
#|fp        |
#|gp        |   SRA
#|----------|
      .globl change_orientationf
      .ent change_orientation
change_orientation: #ant_t* change_orientation(ant_t *ant, rotation_t rule)

            #Creo el stack
            subu $sp,$sp,SS_co

            sw $fp,of_fp_co($sp)
            sw $gp,of_gp_co($sp)
            move $fp,$sp

            sw $a0,of_a0_co($fp)
            sw $a1,of_a1_co($fp)

            lw $t1,of_a0_co($fp)     #t1= ant*
            lw $t2,8($t1)             #t2 = ant->o

            lw $t3, of_a1_co($fp)    #t3 = rule

            beqz $t2,CASE_ON_CO

            subu $t3,$t2,1

            beqz $t3,CASE_OS_CO

            subu $t3,$t2,1

            beqz $t3,CASE_OE_CO

            subu $t3,$t2,1

            beqz $t3,CASE_OW_CO

FIN_CO:
           #desarmo el stack
            move $sp,$fp
            lw $fp,of_fp_co($sp)
            lw $gp,of_gp_co($sp)
            #lw ra, offset_ra(sp)
            addu $sp,$sp,SS_co
            jr $ra


CASE_ON_CO:

      beqz $t3, ON_RL_CO        # if rule == RL -> ON_RL_CO
                              # rule == RR
      addi $t2, $t2, OE         # ant->o = OE
      j FIN_SWITCH_CO

ON_RL_CO:
                              # rule == RL
      addi $t2, $t2, OW         # ant->o = OW
      j FIN_SWITCH_CO

CASE_OS_CO:
      beqz $t3, OS_RL_CO        # if rule == RL -> OS_RL_CO
                              # rule == RR
      addi $t2, $t2, OW         # ant->o = OW
      j FIN_SWITCH_CO

OS_RL_CO:
                              # rule == RL
      addi $t2, $t2, OE         # ant->o = OE
      j FIN_SWITCH_CO

CASE_OE_CO:
      beqz $t3, OE_RL_CO        # if rule == RL -> OE_RL_CO
                              # rule == RR
      addi $t2, $t2, OS         # ant->o = OS
      j FIN_SWITCH_CO

OE_RL_CO:
                              # rule == RL
      addi $t2, $t2, ON         # ant->o = ON
      j FIN_SWITCH_CO

CASE_OW_CO:
      beqz $t3, OW_RL_CO       # if rule == RL -> OW_RL_CO
                              # rule == RR
      addi $t2, $t2, ON         # ant->o = ON
      j FIN_SWITCH_CO

OW_RL_CO:
                              # rule == RL
      addi $t2, $t2, OS         # ant->o = OS
      j FIN_SWITCH_CO

FIN_SWITCH_CO:
      sw $t2, 8($t1)            # Guardo el nuevo valor de ant->o
      move $v0, $t1             # Muevo la dirección de la ant a v0

      j FIN_CO
      .end change_orientation
