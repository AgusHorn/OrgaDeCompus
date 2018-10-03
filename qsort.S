#include <mips/regdef.h>

#define SS 48
#define offset_ra 40
#define offset_fp 36
#define offset_gp 32

#define offset_a1 52
#define offset_a2 56

#define offset_s0 16
#define offset_s1 20

.text
.align 2

        .globl qsort2
qsort2: .ent qsort2
        .frame  $29, SS, $31
        .set noreorder
        .cpload $25
        .set noreorder

        #prologo
        subu sp, sp, SS
        .cprestore 32
        sw ra, offset_ra(sp)
        sw $fp, offset_fp(sp)
        #sw gp, offset_gp(sp)

        sw s0, offset_s0(sp)
        sw s1, offset_s1(sp)

        #guardamos parametros en el ABA
        sw a0, SS(sp)
        sw a1, offset_a1(sp)
        sw a2, offset_a2(sp)

        bge a0, a1, fin   # si izq >= der termine de ordenar.
        nop
        jal pivotear      #pivotear(izq,der,num) que estan en a0,a1 y a2 respectivamente

        #en v0 vuelve la direccion del pivote

        move t3, v0
        sw t3, 28(sp)		  #guardo el pivote en t3 en el LTA

        lw a0, SS(sp)       #a0 = izquierdo
        move a1, t3
        subu a1, a1, 1    #a1 = pivot - 1
        jal qsort         #qsort(izq,pivot-1,num)

        lw a0, 28(sp)              #a0 = pivot
        addi a0, a0, 1            #a0 += 1
        lw a1, offset_a1(sp)       #a1 = derecho
        jal qsort                  #qsort(pivot+1, der, num)

        jal fin           #creo que no es necesario


fin:
        #epilogo
        lw ra, offset_ra(sp)
        lw $fp, offset_fp(sp)
        #lw gp, offset_gp(sp)

        lw s0, offset_s0(sp)
        lw s1, offset_s1(sp)

        addi sp, sp, SS
        jr ra
        .end qsort2

pivotear: .ent pivotear
          .frame  $29, SS, $31
          .set noreorder
          nop
          .cpload $25
          .set noreorder

        #prologo

        subu sp, sp, SS
        .cprestore 32

        sw ra, offset_ra(sp)
        sw $fp, offset_fp(sp)
        #sw gp, offset_gp(sp)

        sw s0, offset_s0(sp)
        sw s1, offset_s1(sp)

        #guardamos parametros en el ABA
        sw a0, SS(sp)
        sw a1, offset_a1(sp)
        sw a2, offset_a2(sp)

        move t0, a0             #t0 = izq
        move t1, a1             #t1 = der
        move t2, a2             #t2 = num

        lbu t3, 0(t0)           #t3 = *izq (valor_pivote)
        move s0, t0             #s0 = izq (pivote)
        move t4, zero           #t4 = 0 (i)

loop:   add t5,t0 ,t4           #t5 = izq + i
        beq t5, t1, fin_piv     #if(izq+i == der)break
        lbu s1, 0(t5)           #s1 = *(izq + i)
        bge t5, s1, cambio      # *(izq + i) >= valor_pivote swapeo
        add t4,t4,1             # i++
        jal loop

cambio:

        move a0, t5             #a0 = izq + 1
        move a1, s1             #a1 = pivote
        jal swap                #swap(izq+i,pivote)

        add s0,s0,1             #pivote++

        move a0, t5             #a0 = izq + 1
        move a1, s1             #a1 = pivote
        jal swap                #swap(izq+i,pivote+1)

        jal loop


swap:   lw t6, 0(a0)
        lw t7, 0(a1)

        sw t7, 0(a0)
        sw t6, 0(a1)

        jr ra

fin_piv:
        #epilogo
        lw ra, offset_ra(sp)
        lw $fp, offset_fp(sp)
        #lw gp, offset_gp(sp)

        lw s0, offset_s0(sp)
        lw s1, offset_s1(sp)

        addi sp, sp, SS
        jr ra

        .end pivotear
