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
#define of_ra_pivotear 32
#define of_fp_pivotear 28
#define of_gp_pivotear 24


#CONSTANTES DE LA FUNCION SWAP
#define SS_swap 8
#define of_fp_swap 4
#define of_gp_swap 0
#define of_a1_swap 12



#COMIENZA EL CODIGO

        .text
        .align 2

        .globl qsort2

qsort2: .ent qsort2
        .set noreorder
        .cpload $25
        .set noreorder

        #prologo qsort2
        subu sp, sp, SS           #dejamos espacio en el stack para:
        .cprestore offset_gp
        sw ra, offset_ra(sp)      #guardar ra
        sw $fp, offset_fp(sp)     #guardar fp
        #sw gp, offset_gp(sp)     #guardar gp

        #guardamos parametros en el ABA
        sw a0, SS(sp)             #espacio para guardar a0 = char** izq
        sw a1, offset_a1(sp)      #espacio para guardar a1 = char** der
        sw a2, offset_a2(sp)      #espacio para guardar a2 = int num

        bge a0, a1, fin           # si izq >= der termine de ordenar.
        nop
        jal pivotear              #pivotear(izq,der,num) que estan en a0,a1 y a2 respectivamente

        #en v0 vuelve la direccion del pivote

        move t3, v0               #guardo el pivote en t3
        sw t3, 16(sp)		          #guardo en el stack (LTA) el pivote

        lw a0, SS(sp)             #cargo izq en a0
        move a1, t3               #meuvo pivote a a1
        subu a1, a1, 4            #a1 = pivot - 1
        jal qsort2                #qsort(izq,pivot-1,num)

        lw a0, SS(sp)             #cargo a0 = pivot
        addi a0, a0, 4            #a0 = pivot + 1
        lw a1, offset_a1(sp)      #cargo a1 = derecho
        jal qsort2                #qsort(pivot+1, der, num)

fin:
        #epilogo qsort2
        lw ra, offset_ra(sp)      #cargo ra
        lw $fp, offset_fp(sp)     #cargo fp
        lw gp, offset_gp(sp)      #cargo gp

        addi sp, sp, SS           #restore stackpointer
        jr ra                     #return
        .end qsort2




pivotear: .set noreorder
          nop
          .cpload $25
          .set noreorder

        #prologo pivotear

        subu sp, sp, SS_pivotear      #dejamos espacio en el stack para:
        .cprestore of_gp_pivotear

        sw ra, of_ra_pivotear(sp)     #guardar ra
        sw $fp, of_fp_pivotear(sp)    #guardar fp
        #sw gp, of_gp_pivotear(sp)    #guardar gp

        sw s0, 36(sp)
        sw s1, 40(sp)
        sw s2, 44(sp)
        sw s3, 48(sp)
        sw s4, 52(sp)
        sw s5, 56(sp)

        #guardamos parametros en el ABA
        sw a0, SS(sp)           #espacio para guardar a0 = char** izq
        sw a1, offset_a1(sp)    #espacio para guardar a1 = char** der
        sw a2, offset_a2(sp)    #espacio para guardar a2 = int num

        move s2, a0             #s2 = izq
        move s3, a1             #s3 = der
        move s4, a2             #s4 = num

        lw t3, 0(s2)            #aca es char*
        lw s5, 0(t3)            #s5 = **izq (valor_pivote) aca es char TODO: Comparacion entre cadenas de mas de un caracter
        move s0, s2             #s0 = izq (pivote)
        move t4, zero           #t4 = 0 (contador para el for)
        add t4,t4,4             #t4 = 1

loop:   add t5,s2 ,t4           #t5 = izq + i
        bgt t5, s3, fin_piv     #if(izq+i >= der)break
        lw t2, 0(t5)            #t2 = *(izq + i)
        lw s1, 0(t2)            #s1 = **(izq + i)

        #lw s1, 0(t5)           #s1 = *(izq + i)

        bgt s5, s1, cambio      #if (**(izq + i) <= valor_pivote) -> swapeo
        add t4,t4,4             #i++
        b loop

cambio: #move a0, t5            #a0 = izq + 1
        #move a1, s0            #a1 = pivote

        #jal swap

        #swap
        lw t6, 0(t5)            #cargo izq+i en t6
        lw t7, 0(s0)            #cargo pivote en t7

        sw t7, 0(t5)            #guardo pivote en izq+i
        sw t6, 0(s0)            #guardo izq + i en pivote

        add s0,s0,4             #pivote++

        #move a0, t5            #a0 = izq + 1
        #move a1, s0            #a1 = pivote

        #jal swap

        #swap
        lw t6, 0(t5)            #cargo izq+i en t6
        lw t7, 0(s0)            #cargo pivote + 1 en t7

        sw t7, 0(t5)            #guardo izq + i en pivote +1
        sw t6, 0(s0)            #guardo pivote + 1 en izq + i

        b loop                  #vuelvo al loop

fin_piv:
        #epilogo pivotear
        lw ra, of_ra_pivotear(sp)
        lw $fp, of_fp_pivotear(sp)
        lw gp, of_gp_pivotear(sp)

        move v0, s0

        lw s0, 36(sp)
        lw s1, 40(sp)
        lw s2, 44(sp)
        lw s3, 48(sp)
        lw s4, 52(sp)
        lw s5, 56(sp)


        addi sp, sp, SS_pivotear
        jr ra


#swap:   .ent swap
        #.set noreorder
        #nop
        #.cpload $25
        #.set noreorder

        #prologo swap

        #subu sp, sp, SS_swap
        #.cprestore of_gp_swap

        #sw $fp, of_fp_swap(sp)
        #sw gp, of_gp_swap(sp)


        #guardamos parametros en el ABA
        #sw a0, SS_swap(sp)
        #sw a1, of_a1_swap(sp)


        #lw t6, 0(a0)
        #lw t7, 0(a1)

        #sw t7, 0(a0)
        #sw t6, 0(a1)

        #epilogo swap
        #lw $fp, of_fp_swap(sp)
        #lw gp, of_gp_swap(sp)

        #addi sp, sp, SS
        #jr ra

        #.end swap
