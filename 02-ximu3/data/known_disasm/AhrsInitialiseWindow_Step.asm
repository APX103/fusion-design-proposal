9d07bfa4  lw        $v1, 8($a0)
9d07bfa8  addiu     $v0, $zero, 3  ; 3
9d07bfac  beq       $v1, $v0, 0x9d07c024
9d07bfb0  addiu     $a2, $zero, 1  ; 1
9d07bfb4  lw        $a1, 0x90($a0)
9d07bfb8  bne       $a1, $a2, 0x9d07c01c
9d07bfbc  nop       
9d07bfc0  lw        $a3, 0x9c($a0)
9d07bfc4  beqz      $a3, 0x9d07c02c
9d07bfc8  mtc1      $a3, $f0
9d07bfcc  move      $v0, $zero
9d07bfd0  lui       $t0, 0x9d08
9d07bfd4  mthc1     $v0, $f0
9d07bfd8  lwc1      $f2, 0x5b5c($t0)
9d07bfdc  cop1.f20  $f0, $f0
9d07bfe0  lwc1      $f3, 0xa4($a0)
9d07bfe4  div.s     $f4, $f2, $f1
9d07bfe8  lwc1      $f5, 0xa8($a0)
9d07bfec  lwc1      $f6, 0xa0($a0)
9d07bff0  addiu     $t1, $zero, 2  ; 2
9d07bff4  sw        $t1, 0x90($a0)
9d07bff8  sb        $a1, 0x98($a0)
9d07bffc  move      $v0, $zero
9d07c000  mul.s     $f7, $f4, $f3
9d07c004  mul.s     $f8, $f4, $f5
9d07c008  mul.s     $f9, $f6, $f4
9d07c00c  swc1      $f7, 0xa4($a0)
9d07c010  swc1      $f8, 0xa8($a0)
9d07c014  jr        $ra
9d07c018  swc1      $f9, 0xa0($a0)
9d07c01c  jr        $ra
9d07c020  addiu     $v0, $zero, 2  ; 2
9d07c024  jr        $ra
9d07c028  addiu     $v0, $zero, 1  ; 1
9d07c02c  sw        $v0, 0x90($a0)
9d07c030  jr        $ra
9d07c034  sw        $v0, 0x94($a0)
9d07c038  addiu     $sp, $sp, -0x48
9d07c03c  sw        $s1, 0x40($sp)
9d07c040  move      $s1, $a1