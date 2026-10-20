9d05c740  lw        $v1, 8($a0)
9d05c744  addiu     $sp, $sp, -0x48
9d05c748  addiu     $v0, $zero, 3  ; 3
9d05c74c  sw        $s1, 0x14($sp)
9d05c750  sw        $s0, 0x10($sp)
9d05c754  sw        $ra, 0x24($sp)
9d05c758  sw        $s4, 0x20($sp)
9d05c75c  sw        $s3, 0x1c($sp)
9d05c760  sw        $s2, 0x18($sp)
9d05c764  sdc1      $f24, 0x38($sp)
9d05c768  sdc1      $f22, 0x30($sp)
9d05c76c  sdc1      $f20, 0x28($sp)
9d05c770  move      $s0, $a0
9d05c774  beq       $v1, $v0, 0x9d05c790
9d05c778  move      $s1, $a1
9d05c77c  lw        $a1, 0x90($a0)
9d05c780  addiu     $a2, $zero, 1  ; 1
9d05c784  bne       $a1, $a2, 0x9d05c790
9d05c788  addiu     $a3, $zero, 4  ; 4
9d05c78c  sw        $a3, 0x90($a0)
9d05c790  lui       $a0, 0x9d08
9d05c794  lwc1      $f20, 0xc($s1)
9d05c798  lwc1      $f0, 0x5b60($a0)
9d05c79c  lui       $t1, 0x9d08
9d05c7a0  lui       $t2, 0x9d08
9d05c7a4  sub.s     $f3, $f0, $f20
9d05c7a8  lwc1      $f22, ($s1)
9d05c7ac  lwc1      $f1, 0x5b5c($t1)
9d05c7b0  lwc1      $f2, 0x5b64($t2)
9d05c7b4  lw        $t0, 4($s1)
9d05c7b8  div.s     $f4, $f1, $f22
9d05c7bc  div.s     $f5, $f3, $f2
9d05c7c0  lw        $s2, 8($s1)
9d05c7c4  addiu     $t3, $zero, 3  ; 3
9d05c7c8  sw        $t0, 4($s0)
9d05c7cc  sw        $s2, 8($s0)
9d05c7d0  swc1      $f20, 0xc($s0)
9d05c7d4  swc1      $f20, 0x10($s0)
9d05c7d8  swc1      $f4, ($s0)
9d05c7dc  mul.s     $f6, $f5, $f4
9d05c7e0  bne       $s2, $t3, 0x9d05c7fc
9d05c7e4  swc1      $f6, 0x14($s0)
9d05c7e8  lui       $t4, 0x9d08
9d05c7ec  lwc1      $f7, 0x20($s1)
9d05c7f0  lwc1      $f8, 0x5b68($t4)
9d05c7f4  mul.s     $f9, $f7, $f8
9d05c7f8  swc1      $f9, 0x10($s0)
9d05c7fc  lwc1      $f10, 0x10($s1)
9d05c800  mtc1      $zero, $f11
9d05c804  c.lt.s    $f11, $f10
9d05c808  bc1t      0x9d05c814
9d05c80c  addiu     $t5, $zero, 1  ; 1
9d05c810  move      $t5, $zero
9d05c814  lui       $t6, 0x9d08
9d05c818  lwc1      $f12, 0x5b6c($t6)
9d05c81c  lwc1      $f13, 0x14($s1)
9d05c820  mtc1      $zero, $f24
9d05c824  mul.s     $f14, $f10, $f12
9d05c828  c.lt.s    $f16, $f27  ; cc=3
9d05c82c  lui       $s4, 0x9d08
9d05c830  sb        $t5, 0x18($s0)
9d05c834  lwc1      $f15, 0x5b58($s4)
9d05c838  bc1f      $fcc1, 0x9d05c880
9d05c83c  swc1      $f14, 0x1c($s0)
9d05c840  c.lt.s    $f16, $f9  ; cc=5
9d05c844  bc1f      $fcc2, 0x9d05c880
9d05c848  addiu     $t7, $zero, 1  ; 1
9d05c84c  mul.s     $f12, $f13, $f15
9d05c850  sb        $t7, 0x20($s0)
9d05c854  jal       0x9d0613f8  ; cosf
9d05c858  lui       $s3, 0x9d08
9d05c85c  lwc1      $f21, 0x5b54($s3)
9d05c860  lwc1      $f23, 0x18($s1)
9d05c864  mul.s     $f25, $f0, $f21
9d05c868  c.lt.s    $f17, $f15  ; cc=5
9d05c86c  mul.s     $f27, $f25, $f25
9d05c870  bc1f      $fcc6, 0x9d05c8bc
9d05c874  swc1      $f27, 0x24($s0)
9d05c878  b         0x9d05c8c0
9d05c87c  sltiu     $t8, $s2, 1
9d05c880  mul.s     $f12, $f13, $f15
9d05c884  sb        $zero, 0x20($s0)
9d05c888  jal       0x9d0613f8  ; cosf
9d05c88c  lui       $s3, 0x9d08
9d05c890  lwc1      $f16, 0x5b54($s3)
9d05c894  lwc1      $f23, 0x18($s1)
9d05c898  mtc1      $zero, $f17
9d05c89c  mul.s     $f18, $f0, $f16
9d05c8a0  c.lt.s    $f2, $f15  ; cc=5
9d05c8a4  mul.s     $f19, $f18, $f18
9d05c8a8  bc1f      $fcc3, 0x9d05c8bc
9d05c8ac  swc1      $f19, 0x24($s0)
9d05c8b0  c.lt.s    $f3, $f9  ; cc=5
9d05c8b4  bc1t      $fcc4, 0x9d05c8c0
9d05c8b8  sltiu     $t8, $s2, 1
9d05c8bc  move      $t8, $zero
9d05c8c0  lwc1      $f29, 0x5b58($s4)
9d05c8c4  sb        $t8, 0x28($s0)
9d05c8c8  jal       0x9d0613f8  ; cosf
9d05c8cc  mul.s     $f12, $f23, $f29
9d05c8d0  lwc1      $f31, 0x5b54($s3)
9d05c8d4  lwc1      $f20, 0x24($s1)
9d05c8d8  lwc1      $f3, 0x1c($s1)
9d05c8dc  mul.s     $f0, $f0, $f31
9d05c8e0  mul.s     $f1, $f22, $f20
9d05c8e4  mul.s     $f22, $f22, $f3
9d05c8e8  lui       $t9, 0x9d08
9d05c8ec  lwc1      $f4, 0x5b70($t9)
9d05c8f0  mul.s     $f5, $f0, $f0
9d05c8f4  c.le.s    $f9, $f2
9d05c8f8  trunc.w.s $f2, $f22
9d05c8fc  swc1      $f2, 0x30($s0)
9d05c900  swc1      $f2, 0x70($s0)
9d05c904  swc1      $f2, 0x88($s0)
9d05c908  bc1t      $fcc5, 0x9d05c948
9d05c90c  swc1      $f5, 0x2c($s0)
9d05c910  trunc.w.s $f6, $f1
9d05c914  lw        $ra, 0x24($sp)
9d05c918  mfc1      $v0, $f6
9d05c91c  lw        $s4, 0x20($sp)
9d05c920  sw        $v0, 0x34($s0)
9d05c924  lw        $s3, 0x1c($sp)
9d05c928  lw        $s2, 0x18($sp)
9d05c92c  lw        $s1, 0x14($sp)
9d05c930  lw        $s0, 0x10($sp)
9d05c934  ldc1      $f24, 0x38($sp)
9d05c938  ldc1      $f22, 0x30($sp)
9d05c93c  ldc1      $f20, 0x28($sp)
9d05c940  jr        $ra
9d05c944  addiu     $sp, $sp, 0x48
9d05c948  sub.s     $f7, $f1, $f4
9d05c94c  lui       $v1, 0x8000
9d05c950  lw        $s4, 0x20($sp)
9d05c954  lw        $s3, 0x1c($sp)
9d05c958  trunc.w.s $f8, $f7
9d05c95c  mfc1      $ra, $f8