#CONSTANTES DE LA FUNCION PAINT
#define SS 56
#define offset_ra 48
#define offset_fp 44
#define offset_gp 40

#define offset_a1 60
#define offset_a2 64
#define offset_a3 68
#define offset_a4 72

#define LRA_GRID 32
#define LRA_ITER 28
#define LRA_P 20
#define LRA_R 24
#define LRA_ANT 16

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
      lw $t0, SS($fp)   #ant
      sw $t0,LRA_ANT($fp)

      lw $t0, offset_a2($fp) #palette
      sw $t0,LRA_P($fp)

      lw $t0, offset_a3($fp) #rules
      sw $t0,LRA_R($fp)

      lw $t0, offset_a4($fp) #iterations
      sw $t0,LRA_ITER($fp)

      lw $t0, offset_a1($fp) #grid
      sw $t0,LRA_GRID($fp)

      #codigo de la FUNCION
LOOP_WHILE:
      lw $t0, LRA_ITER($fp) #t0 = iterations
      beqz $t0, FIN

      lw $t6, offset_a2($fp) #t6 = pallete[0]
      #sw $t6, LRA_P($fp)  #reseteo en el stack P para volver a comenzar el for

      addi $t6,$t6,4 #p++

      sw $t6, LRA_P($fp) #guardo el valores de la pallete (p)

      lw $s4, offset_a3($fp) #reseteo R para el prox ciclo
      sw $s4, LRA_R($fp)

LOOP_FOR:
      lw $s0, LRA_R($fp) #s0 = rotation_t* rules
      lw $t2, 0($s0) #s1 = *rules
      slti $t3, $t2, 0 #Si *rules es < 0 entonces t3 = 1, sino t3 = 0
      bgtz $t3,DECREMENTAR_ITER

      lw $s1,LRA_GRID($fp) #s1 = square_grid_t* grid
      lw $t4, 8($s1) #t4 = (colour_t **) grid->grid

      lw $s2, LRA_ANT($fp) #s2 = ant*
      lw $t5, 0($s2) #t5 = ant->x
      lw $t6, 4($s2) #t6 = ant->y

      addi $t7, $zero, 4 #size de un int32
      mul $t5,$t5,$t7 #sizeof(x)*x
      mul $t6,$t6,$t7#sizeof(y)*y

      addu $t4,$t4,$t5 #grid->grid[ant->x]
      lw $t5,0($t4) #dereferenciamos y obtenemos el puntero

      addu $t5,$t5,$t6 # obtenemos el puntero que apunta a grid->grid[ant->x][ant->y]


      lw $s3,LRA_P($fp) #s3 = palette_t* p
      lw $t7, 0($s3) #t7 = *p
      sw $t7, 0($t5) #  grid->grid[ant->x][ant->y] = *p;

      move $a0, $s2 #a0 = ant_t* ant
      lw $a1,0($s0) #a1 = *r

      la $t7,change_orientation
      jalr $t7

      sw $v0, LRA_ANT($fp) #Guardamos lo que devolvio change_orientation
      lw $a0, LRA_ANT($fp) #cargamos en a0 lo que acabamos de guardar (ant)

      move $a1, $s1 #a1 = square_grid_t* grid


      la $t7,move_ant
      jalr $t7

      sw $v0, LRA_ANT($fp) #Guardamos lo que devolvio move_ant

      addi $s0, $s0, 4 #sumamos 1 a rotation_t* rules
      sw $s0, LRA_R($fp) #guardamos el puntero actualizado para la próxima iteración


      lw $t1, LRA_P($fp) #t1 = palette_t* p
      addi $t1,$t1,4 #actualizamos el puntero de p
      sw $t1,LRA_P($fp)

      lb $t2, 0($t1) #t2 = *p
      slti $t3, $t2, 0 #Si *p es < 0 entonces t3 = 1, sino t3 = 0


      bgtz $t3,RESET_PALLETE

      b LOOP_FOR

RESET_PALLETE:


      lw $t6, offset_a2($fp) #t6 = pallete[0]
      sw $t6, LRA_P($fp) # p = pallete

      b LOOP_FOR

DECREMENTAR_ITER:
      lw $t0,LRA_ITER($fp)
      addi $t0,$t0,-1 #t0 = iter--
      sw $t0,LRA_ITER($fp)

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
#                                       FUNCION MOVE_ANT
#------------------------------------------------------------------------------------------------------------------------------
#|----------|
#|PADDING   |
#|PADDING   |
#|grid      |   ABA DE PAINT
#|ant       |
#|----------|
#|fp        |
#|gp        |   SRA
#|----------|
      .globl move_ant
      .ent move_ant

move_ant: #ant_t* move_ant(ant_t *ant, square_grid_t *grid)

            #Creo el stack
            subu $sp,$sp,SS_ma
            #sw $ra,offset_ra(sp)
            sw $fp,of_fp_ma($sp)
            sw $gp,of_gp_ma($sp)
            move $fp,$sp

            sw $a0,of_a0_ma($fp) #addr ant
            sw $a1,of_a1_ma($fp) #addr grid


            #Codigo de la FUNCION
            lw $t1,of_a0_ma($fp) #t1= ant*
            lw $t2,8($t1) #t2 = ant->o

            beqz $t2,CASE_ON_MA

            subu $t3,$t2,1

            beqz $t3,CASE_OS_MA

            subu $t3,$t3,1

            beqz $t3,CASE_OE_MA

            subu $t3,$t3,1

            beqz $t3,CASE_OW_MA

FIN_MA:
           #desarmo el stack
            move $sp,$fp
            lw $fp,of_fp_ma($sp)
            lw $gp,of_gp_ma($sp)
            #lw ra, offset_ra(sp)
            addu $sp,$sp,SS_ma
            jr $ra


CASE_ON_MA:
      lw $t5,0($t1) #t5 = ant->x

      lw $t6,of_a1_ma($fp) #t6 = grid*
      lw $t7,4($t6) #t7 = grid->height
      addi $t7,$t7,-1

      subu $t7, $t5,$t7
      beqz $t7,ANTX_ON
      addi $t5,$t5,1 #ant->x++
      sw $t5,0($t1) #ant->x = ant->x++
      j FIN_SWITCH

ANTX_ON:
      sw $zero,0($t1) #ant->x = 0
      j FIN_SWITCH

CASE_OS_MA:
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

CASE_OE_MA:
      lw $t5,4($t1) #t5 = ant->y

      lw $t6,of_a1_ma($fp) #t6 = grid*
      lw $t7,0($t6) #t7 = grid->width
      addi $t7,$t7,-1

      subu $t7, $t5,$t7
      beqz $t7,ANTX_OE
      addi $t5,$t5,1 #ant->y++
      sw $t5,4($t1) #ant->y = ant->y++
      j FIN_SWITCH

ANTX_OE:

      sw $zero,4($t1) #ant->y = 0
      j FIN_SWITCH

CASE_OW_MA:
      lw $t5,4($t1) #t5 = ant->y

      beqz $t5,ANTX_OW
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
      .globl change_orientation
      .ent change_orientation
change_orientation: #ant_t* change_orientation(ant_t *ant, rotation_t rule)

            #Creo el stack
            subu $sp,$sp,SS_co

            #|fp        |
            sw $fp,of_fp_co($sp)
            sw $gp,of_gp_co($sp)
            move $fp,$sp


            sw $a0,of_a0_co($fp)
            sw $a1,of_a1_co($fp)

            lw $t1,of_a0_co($fp)     #t1= ant*
            lw $t2,8($t1)             #t2 = ant->o

            lw $t3, of_a1_co($fp)    #t3 = rule

            beqz $t2,CASE_ON_CO

            subu $t4,$t2,1

            beqz $t4,CASE_OS_CO

            subu $t4,$t4,1

            beqz $t4,CASE_OE_CO

            subu $t4,$t4,1

            beqz $t4,CASE_OW_CO

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

      addi $t0,$zero,OE          # rule == RR
      sw $t0, 8($t1)         # ant->o = OE
      j FIN_SWITCH_CO

ON_RL_CO:
                              # rule == RL
                              # ant->o = OW
      addi $t0,$zero,OW
      sw $t0, 8($t1)
      j FIN_SWITCH_CO

CASE_OS_CO:
      beqz $t3, OS_RL_CO        # if rule == RL -> OS_RL_CO

      addi $t0,$zero,OW
      sw $t0, 8($t1)                         # rule == RR
                              # ant->o = OW
      j FIN_SWITCH_CO

OS_RL_CO:
                              # rule == RL
                              # ant->o = OE
      addi $t0,$zero,OE
      sw $t0, 8($t1)
      j FIN_SWITCH_CO

CASE_OE_CO:
      beqz $t3, OE_RL_CO        # if rule == RL -> OE_RL_CO
                              # rule == RR
                              # ant->o = OS
      addi $t0,$zero,OS
      sw $t0,8($t1)
      j FIN_SWITCH_CO

OE_RL_CO:
                              # rule == RL
                              # ant->o = ON
      addi $t0,$zero,ON
      sw $t0, 8($t1)
      j FIN_SWITCH_CO

CASE_OW_CO:
      beqz $t3, OW_RL_CO       # if rule == RL -> OW_RL_CO
                              # rule == RR
                              # ant->o = ON
      addi $t0,$zero,ON
      sw $t0, 8($t1)
      j FIN_SWITCH_CO

OW_RL_CO:
                              # rule == RL
                              # ant->o = OS
      addi $t0,$zero,OS
      sw $t0, 8($t1)
      j FIN_SWITCH_CO

FIN_SWITCH_CO:
      #sw $t2, 8($t1)            # Guardo el nuevo valor de ant->o
      move $v0, $t1             # Muevo la dirección de la ant a v0

      j FIN_CO
      .end change_orientation
