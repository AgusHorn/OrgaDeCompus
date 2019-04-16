#include <mips/regdef.h>

#CONSTANTES DE LA FUNCION PAINT
#define SS 
#define offset_ra 
#define offset_fp 
#define offset_gp 

#define offset_a1 
#define offset_a2
#define offset_a3
#define offset_a4
#define offset_a5 

#CONSTANTES DE LA FUNCION BEGINNING_ANT
#define SS_ba 
#define of_ra_ba 
#define of_fp_ba
#define of_gp_ba 

#define of_a1_ba

#CONSTANTES DE LA FUNCION MOVE_ANT
#define SS_ma
#define of_ra_ma
#define of_fp_ma
#define of_gp_ma

#define of_a1_ma 
#define of_a2_ma
#define of_a3_ma

#CONSTANTES DE LA FUNCION CHANGE_ORIENTATION
#define SS_co
#define of_fp_co
#define of_ra_co
#define of_gp_co

#define of_a1_co
#define of_a2_co 


#COMIENZA EL CODIGO

        .text
        .align 2

        .globl qsort2
#------------------------------------------------------------------------------------------------------------------------------
#                                       FUNCION PAINT
#------------------------------------------------------------------------------------------------------------------------------

paint: 






#------------------------------------------------------------------------------------------------------------------------------
#                                       FUNCION BEGINNING_ANT
#------------------------------------------------------------------------------------------------------------------------------

#Parametros a0 puntero a ant_t.

beginning_ant:  .ent beginning_ant
				.frame fp, SS_ba, ra
          		.set noreorder
          		.cpload 25
          		.set noreorder

          		#prologo beginning_ant
      			subu sp, sp, SS_strcmp
      			.cprestore of_gp_strcmp

      			sw fp, of_fp_ba(sp)
      			sw gp, of_gp_ba(sp)

      			move fp, sp

      			#guardo el parámetro en el ABA
      			sw a0, of_a1_ba(sp)

      			la t0, 0(a0)    #Addr of Ant->x
      			la t1, 4(a0)	#Addr of Ant->y
      			la t2, 8(a0)	#Addr of Ant->o

      			lw t3, t0		#Ant->x
      			lw t4, t1		#Ant->y
      			lw t5, t2		#Ant->o

      			addi t3, zero, 1	#Ant->x = 1
      			addi t4, zero, 1	#Ant->y = 1
      			add  t5, zero, zero	#Ant->o = 0 (0 es la constante ON)

      			sw t3, 0(a0)
      			sw t4, 4(a0)
      			sw t5, 8(a0)

      			#epilogo beginning_ant
      			lw fp, of_fp_ba(sp)
      			lw gp, of_gp_ba(sp)

      			addi sp, sp, SS_ba
      			jr ra

      			.end beginning_ant






#------------------------------------------------------------------------------------------------------------------------------
#                                       FUNCION MOVE_ANT
#------------------------------------------------------------------------------------------------------------------------------



#------------------------------------------------------------------------------------------------------------------------------
#                                       FUNCION CHANGE_ORIENTATION
#------------------------------------------------------------------------------------------------------------------------------