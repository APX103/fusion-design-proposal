9d07ca98  lui       $a1, 0x9d08
9d07ca9c  lui       $v1, 0x9d08
9d07caa0  lw        $v0, 0x30($a0)
9d07caa4  lwc1      $f0, 0x5b5c($a1)
9d07caa8  lwc1      $f1, 0x5b60($v1)
9d07caac  addiu     $a2, $zero, 1  ; 1
9d07cab0  swc1      $f0, 0x38($a0)
9d07cab4  sw        $zero, 0x3c($a0)
9d07cab8  sw        $zero, 0x40($a0)
9d07cabc  sw        $zero, 0x44($a0)
9d07cac0  sw        $zero, 0x48($a0)
9d07cac4  sw        $zero, 0x4c($a0)
9d07cac8  sw        $zero, 0x50($a0)
9d07cacc  sb        $a2, 0x54($a0)
9d07cad0  swc1      $f1, 0x58($a0)
9d07cad4  sb        $zero, 0x5c($a0)
9d07cad8  sw        $zero, 0x60($a0)
9d07cadc  sw        $zero, 0x64($a0)
9d07cae0  sw        $zero, 0x68($a0)
9d07cae4  sw        $zero, 0x6c($a0)
9d07cae8  sw        $v0, 0x70($a0)
9d07caec  sb        $zero, 0x74($a0)
9d07caf0  sw        $zero, 0x78($a0)
9d07caf4  sw        $zero, 0x7c($a0)
9d07caf8  sw        $zero, 0x80($a0)
9d07cafc  sw        $zero, 0x84($a0)
9d07cb00  sw        $v0, 0x88($a0)
9d07cb04  sb        $zero, 0x8c($a0)
9d07cb08  sw        $zero, 0x90($a0)
9d07cb0c  sw        $zero, 0x94($a0)
9d07cb10  sb        $zero, 0x98($a0)
9d07cb14  sw        $zero, 0x9c($a0)
9d07cb18  sw        $zero, 0xa0($a0)
9d07cb1c  sw        $zero, 0xa4($a0)
9d07cb20  jr        $ra
9d07cb24  sw        $zero, 0xa8($a0)
9d07cb28  addiu     $sp, $sp, -0x28
9d07cb2c  sw        $ra, 0x24($sp)
9d07cb30  sw        $s1, 0x20($sp)
9d07cb34  sw        $s0, 0x1c($sp)
9d07cb38  lbu       $s1, 0x16($a0)
9d07cb3c  sltiu     $v0, $s1, 4
9d07cb40  beqz      $v0, 0x9d07cbb0
9d07cb44  sb        $zero, 0x10($sp)
9d07cb48  move      $s0, $a0
9d07cb4c  move      $a3, $a0