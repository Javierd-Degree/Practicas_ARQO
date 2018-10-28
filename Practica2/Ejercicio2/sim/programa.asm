# Prog de prueba para Pr�ctica 2. Ej 1

.data 0
num0: .word 1 # posic 0
num1: .word 2 # posic 4
num2: .word 4 # posic 8 
num3: .word 8 # posic 12 
num4: .word 16 # posic 16 
num5: .word 32 # posic 20
num6: .word 0 # posic 24
num7: .word 0 # posic 28
num8: .word 0 # posic 32
num9: .word 0 # posic 36
num10: .word 0 # posic 40
num11: .word 0 # posic 44
.text 0
main:
  # carga num0 a num5 en los registros 9 a 14
  L1: lw $t1, 0($zero) # lw $r9, 0($r0)
  lw $t2, 4($zero) # lw $r10, 4($r0)
  lw $t3, 8($zero) # lw $r11, 8($r0)
  lw $t4, 12($zero) # lw $r12, 12($r0)
  lw $t5, 16($zero) # lw $r13, 16($r0)
  lw $t6, 20($zero) # lw $r14, 20($r0)
  nop
  nop
  add $t3, $t1, $t2 # en r11 un 3 = 1 + 2
  sub $t3, $t3, $t3 # en r11 un 0
  nop
  nop

  add $t3, $t1, $t2 # en r11 un 3 = 1 + 2
  add $t1, $t3, $t2 # en r9 un 5 = 2 + 3
  beq $t3, $t1, L1 #No salta
  nop
  nop
  sub $t6, $t6, $t6 #$r14 a 0
  
  add $t3, $t1, $t2 # en r11 un 7 = 5 + 2
  add $t1, $t1, $t2 # en r9 un 7 = 5 + 2
  beq $t3, $t1, L2 #Salta

  #Relleno, no deberia ejecutarse
  add $t3, $t1, $t1 # en r11 un 10 = 5 + 5
  sub $t3, $t3, $t3 # en r11 un 0
  
  #Probamos LW y add no efectivos
  L2: lw $t5, 4($zero) # $r13 = 2
  add $t1, $t5, $t5 #r9 = 4
  beq $t5, $t1, L3 # No salta

  nop
  nop
  #En este caso sí debería ejecutarse, pues no ha saltado
  add $t3, $t1, $t2 # en r11 un 6 = 4 + 2
  sub $t3, $t3, $t3 # en r11 un 0

  #Probamos LW y add efectivos
  lw $t5, 16($zero) # $r13 = 16
  add $t1, $t5, $zero #r9 = 16
  beq $t5, $t1, L3 #Salta

  #Relleno, no deberia ejecutarse
  add $t3, $t1, $t2 # en r11 un 7 = 5 + 2
  sub $t3, $t3, $t3 # en r11 un 0
  
  #Probamos add y LW no efectivos
  L3: add $t1, $t1, $t1 # r9 = 32
  lw $t5, 12($zero) # $r13 = 8
  beq $t5, $t1, L4 #No salta

  #Probamos add y LW efectivos
  add $t1, $t1, $zero # r9 = 32
  lw $t5, 20($zero) # $r13 = 32
  beq $t5, $t1, L4 #Salta

  #Relleno, no deberia ejecutarse
  add $t3, $t1, $t2 # en r11 un 7 = 5 + 2
  sub $t3, $t3, $t3 # en r11 un 0
  
  #Probamos LW y LW
  L4: lw $t6, 20($zero) # $r14 = 32
  lw $t5, 20($zero) # $r13 = 32
  beq $t5, $t6, L1 #Salta
  
  
  
  
  