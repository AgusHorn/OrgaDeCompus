#include <mips/regdef.h>

#CONSTANTES DE LA FUNCION QSORT2
#define SS 48
#define offset_ra 32
#define offset_fp 28
#define offset_gp 24

#define offset_a1 52
#define offset_a2 56


#CONSTANTES DE LA FUNCION PIVOTEAR
#define SS_pivotear 64
#define of_ra_pivotear 56
#define of_fp_pivotear 52
#define of_gp_pivotear 48

#define of_a1_pivotear 68
#define of_a2_pivotear 72


#CONSTANTES DE LA FUNCION SWAP
#define SS_swap 8
#define of_fp_swap 4
#define of_gp_swap 0
#define of_a1_swap 12

#CONSTANTES DE LA FUNCION ATOI
#define of_atoi 8
#define of_fp_atoi 4
#define of_gp_atoi 0


#CONSTANTES DE LA FUNCION STRCMP
#define SS_strcmp 24
#define of_gp_strcmp 16
#define of_fp_strcmp 20
#define of_a1_strcmp 28

#COMIENZA EL CODIGO

        .text
        .align 2

        .globl qsort2

#------------------------------------------------------------------------------------------------------------------------------
#                                       FUNCION QSORT2
#------------------------------------------------------------------------------------------------------------------------------

qsort2: .ent qsort2
        .frame $fp, SS, ra
        .set noreorder
        .cpload $25
        .set noreorder

        #prologo qsort2
        subu sp, sp, SS
        .cprestore offset_gp
        sw ra, offset_ra(sp)
        sw $fp, offset_fp(sp)
        sw gp, offset_gp(sp)

        move $fp, sp

        #guardamos parametros en el ABA
        sw a0, SS(sp)
        sw a1, offset_a1(sp)
        sw a2, offset_a2(sp)

        bge a0, a1, fin   # si izq >= der termine de ordenar.
        nop
        jal pivotear      #pivotear(izq,der,num) que estan en a0,a1 y a2 respectivamente

        #en v0 vuelve la direccion del pivote

        move t3, v0
        sw t3, 16(sp)		  #guardo el pivote en t3 en el LTA

        lw a0, SS(sp)       #a0 = izquierdo
        move a1, t3
        subu a1, a1, 4    #a1 = pivot - 1
        jal qsort2         #qsort(izq,pivot-1,num)

        lw a0, SS(sp)              #a0 = pivot
        addi a0, a0, 4            #a0 += 1
        lw a1, offset_a1(sp)       #a1 = derecho
        jal qsort2                  #qsort(pivot+1, der, num)

fin:
        #epilogo qsort2
        lw ra, offset_ra(sp)
        lw $fp, offset_fp(sp)
        lw gp, offset_gp(sp)

        addi sp, sp, SS
        jr ra
        .end qsort2

#------------------------------------------------------------------------------------------------------------------------------
#                                       FUNCION PIVOTEAR
#------------------------------------------------------------------------------------------------------------------------------

pivotear: .ent pivotear
          .frame $fp, SS_pivotear, ra
          .set noreorder
          .cpload $25
          .set noreorder

        #prologo pivotear

        subu sp, sp, SS_pivotear
        .cprestore of_gp_pivotear

        sw ra, of_ra_pivotear(sp)
        sw $fp, of_fp_pivotear(sp)
        sw gp, of_gp_pivotear(sp)

        move $fp, sp

        sw s0, 24(sp)
        sw s1, 28(sp)
        sw s2, 32(sp)
        sw s3, 36(sp)
        sw s4, 40(sp)
        sw s5, 44(sp)

        #guardamos parametros en el ABA
        sw a0, SS_pivotear(sp)
        sw a1, of_a1_pivotear(sp)
        sw a2, of_a2_pivotear(sp)

        move s2, a0             #s2 = izq
        move s3, a1             #s3 = der
        move s4, a2             #s4 = num

        lw s5, 0(s2)            #s5 = *izq (valor_pivote)
        move s0, s2             #s0 = izq (pivote)
        move t4, zero           #t4 = 0 (i)
        add t4,t4,4




loop:   add t5,s2 ,t4           #t5 = izq + i
        bgt t5, s3, fin_piv     #if(izq+i >= der)break
        nop

        bne s4, zero, pre_atoi #if (num != 0) -> pre_atoi
        nop

        #Parametros para strcmp(char* cadena1, char* cadena2)
        lw a0, 0(t5)           #a0 = izq + 1
        move a1, s5            #a1 = valor_pivote
        jal mystrcmp
        nop

        bgt zero, v0, cambio      # if(*(izq + i) <= valor_pivote ) -> swapeo

        add t4,t4,4             # i++
        b loop

pre_atoi: lw a0, 0(t5)           # a0 = *(izq +i)
          jal atoi
          nop
          move t1, v0            #guardo el valor de atoi en t1

          sw t1, 16(sp)         #guardo valor del primer atoi en el LTA

          move a0, s5            # a0 = valor_pivote
          jal atoi
          move t2, v0            #guardo el valor de atoi en t2

          lw t1, 16(sp)          #restauro valor del primer atoi del LTA
          nop
          add t4,t4,4
          bgt t1,t2,loop         #if (a>b) ->loop sino swapeo(cambio)

cambio: move a0, t5             #a0 = izq + 1
        move a1, s0             #a1 = pivote

        sw t5, 20(sp)           #guardo el valor de t5 porque nose si swap lo puede cambiar

        jal swap

        add s0,s0,4             #pivote++

        lw t5, 20(sp)           #restauro valor de t5

        move a0, t5             #a0 = izq + 1
        move a1, s0             #a1 = pivote

        jal swap
        nop

        b loop

fin_piv: move v0, s0

        #epilogo pivotear
        lw ra, of_ra_pivotear(sp)
        nop
        lw $fp, of_fp_pivotear(sp)
        lw gp, of_gp_pivotear(sp)


        lw s0, 24(sp)
        lw s1, 28(sp)
        lw s2, 32(sp)
        lw s3, 36(sp)
        lw s4, 40(sp)
        lw s5, 44(sp)


        addi sp, sp, SS_pivotear
        jr ra
        .end pivotear

#------------------------------------------------------------------------------------------------------------------------------
#                                       FUNCION ATOI
#------------------------------------------------------------------------------------------------------------------------------
atoi:   .ent atoi
        .frame $fp, of_atoi, ra
        .set noreorder
        .cpload $25
        .set reorder

        #prologo atoi
        subu sp, sp, of_atoi        #dejamos espacio en el stack para:
        .cprestore of_gp_atoi
        sw $fp, of_fp_atoi(sp)      #guardar fp
        sw gp, of_gp_atoi(sp)      #guardar gp

        move $fp, sp

        li v0, 0
        move t0, a0                 #muevo (char* letra) a t0

        #Obtenemos el signo
        li t3, 1
			  lb t1, 0(t0)				 #obtengo el primer caracter
			  bne t1, 45, loop_atoi	 #if (!"-") -> paso al loop, si no es un - salto directo al loop
			  li t3, -1				 #t3 = -1
			  addu t0, t0, 1			 #salteo el signo


loop_atoi:
        lbu t1, 0(t0)            # t1 = *letra
		    beq zero, t1, fin_atoi   #if (letra == 0) -> fin_atoi
		    blt t1, 48, fin_atoi	#corroboro que  0 <= t1 sino -> fin_atoi
		    bgt t1, 57, fin_atoi	#corroboro que 9 >= t1 sino -> fin_atoi
		    mul v0, v0, 10			# v0 *= 10.
        sub t2, t1, 48			# t2 = t1 - ’0’
		    add v0, v0, t2			# v0 += t2
        add t0, t0, 1			# t0 += 1
        b loop_atoi				# repito el loop
        nop

fin_atoi:
        mul v0, v0, t3		 # set the sign properly.
		    lw $fp, of_fp_atoi(sp)
        lw gp, of_gp_atoi(sp)
        addi sp, sp, of_atoi
        jr ra
       	.end atoi


#------------------------------------------------------------------------------------------------------------------------------
#                                       FUNCION STRCMP
#------------------------------------------------------------------------------------------------------------------------------

#Parametros a0 posicion inicial de cadena 1, a1 posicion inicial de cadena 2

mystrcmp:
      .ent mystrcmp
      .frame $fp, SS_strcmp, ra
      .set noreorder
      .cpload $25
      .set noreorder

      #prologo strcmp
      subu sp, sp, SS_strcmp
      .cprestore of_gp_strcmp

      sw $fp, of_fp_strcmp(sp)
      sw gp, of_gp_strcmp(sp)

      sw s0, 0(sp)
      sw s1, 4(sp)
      sw s2, 8(sp)
      sw s3, 12(sp)

      move $fp, sp

      #guardamos parametros en el ABA
      sw a0, SS_strcmp(sp)
      sw a1, of_a1_strcmp(sp)


      move s0, a0       # puntero a cadena 1 en i
      move s1, a1       # puntero a cadena 2 en i

      move t0, zero     # return value c>0 si cadena1>cadena2, c<0 si cadena2>=cadena1



loop_cmp:

      lbu s2, 0(s0)   #cadena1[i]
      lbu s3, 0(s1)   #cadena2[i]

      beq zero, s2, mayor_cadena2 #son iguales pero la cadena 2 es mas larga que la cadena 1
      nop
      beq zero, s3, mayor_cadena1 #son iguales pero la cadena 1 es mas larga que la cadena 2
      nop

      sub t0, s2, s3

      bnez t0, fin_cmp
      nop

      add s0, s0, 1 #avanzamos la cadena1
      add s1, s1, 1 #avanzamos la cadena2

      b loop_cmp

fin_cmp:
      move v0, t0 #devuelvo positivo o negativo segun sea correspondiente

      #epilogo
      lw $fp, of_fp_strcmp(sp)
      lw gp, of_gp_strcmp(sp)

      lw s0, 0(sp)
      lw s1, 4(sp)
      lw s2, 8(sp)
      lw s3, 12(sp)

      addi sp, sp, SS_strcmp
      jr ra

mayor_cadena1:
      li t0, 1 #lo seteo positivo
      b fin_cmp

mayor_cadena2:
      li t0, -1 #lo seteo negativo
      b fin_cmp

      .end mystrcmp


#------------------------------------------------------------------------------------------------------------------------------
#                                       FUNCION SWAP
#------------------------------------------------------------------------------------------------------------------------------

swap: .ent swap
      .frame $fp, SS_swap, ra
      .set noreorder
      .cpload $25
      .set noreorder

      #prologo swap

      subu sp, sp, SS_swap
      .cprestore of_gp_swap

      sw $fp, of_fp_swap(sp)
      sw gp, of_gp_swap(sp)

      move $fp, sp


      #guardamos parametros en el ABA
      sw a0, SS_swap(sp)
      sw a1, of_a1_swap(sp)


      lw t6, 0(a0)
      lw t7, 0(a1)

      sw t7, 0(a0)
      sw t6, 0(a1)

      #epilogo swap
      lw $fp, of_fp_swap(sp)
      lw gp, of_gp_swap(sp)

      addi sp, sp, SS_swap
      jr ra

      .end swap
