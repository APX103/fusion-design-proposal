9d038848  addiu     $sp, $sp, -0x80
9d03884c  lui       $v0, 0x8008
9d038850  sw        $s0, 0x64($sp)
9d038854  addiu     $s0, $v0, -0x3bb8
9d038858  lwc1      $f5, 0xc($a0)
9d03885c  lwc1      $f4, 0x34($s0)
9d038860  lwc1      $f0, 0x28($s0)
9d038864  lwc1      $f3, 8($a0)
9d038868  sub.s     $f6, $f5, $f4
9d03886c  lwc1      $f1, 0x30($s0)
9d038870  lwc1      $f2, 0x24($s0)
9d038874  lwc1      $f8, 0x10($s0)
9d038878  mul.s     $f9, $f6, $f0
9d03887c  sub.s     $f7, $f3, $f1
9d038880  lwc1      $f10, 4($s0)
9d038884  lwc1      $f14, 0x1c($s0)
9d038888  lwc1      $f11, 0x10($a0)
9d03888c  mul.s     $f13, $f7, $f2
9d038890  lwc1      $f12, 0x38($s0)
9d038894  mul.s     $f15, $f9, $f8
9d038898  mul.s     $f16, $f9, $f10
9d03889c  mul.s     $f18, $f9, $f14
9d0388a0  sub.s     $f17, $f11, $f12
9d0388a4  lwc1      $f19, 0x2c($s0)
9d0388a8  lwc1      $f21, 0xc($s0)
9d0388ac  lwc1      $f23, -0x3bb8($v0)
9d0388b0  lwc1      $f27, 0x18($s0)
9d0388b4  mul.s     $f25, $f17, $f19
9d0388b8  madd.s    $f29, $f15, $f13, $f21
9d0388bc  madd.s    $f31, $f16, $f13, $f23
9d0388c0  madd.s    $f5, $f18, $f13, $f27
9d0388c4  lwc1      $f4, 0x14($s0)
9d0388c8  lwc1      $f0, 8($s0)
9d0388cc  lwc1      $f6, 0x20($s0)
9d0388d0  lwc1      $f8, 0x14($a0)
9d0388d4  madd.s    $f3, $f29, $f25, $f4
9d0388d8  madd.s    $f2, $f31, $f25, $f0
9d0388dc  madd.s    $f1, $f5, $f25, $f6
9d0388e0  lw        $t3, ($a0)
9d0388e4  lw        $t0, 4($a0)
9d0388e8  sw        $s5, 0x78($sp)
9d0388ec  sw        $s4, 0x74($sp)
9d0388f0  swc1      $f3, 0x2c($sp)
9d0388f4  swc1      $f2, 0x28($sp)
9d0388f8  sw        $s1, 0x68($sp)
9d0388fc  lw        $a1, 0x28($sp)
9d038900  lw        $a2, 0x2c($sp)
9d038904  sw        $ra, 0x7c($sp)
9d038908  sw        $s3, 0x70($sp)
9d03890c  sw        $s2, 0x6c($sp)
9d038910  swc1      $f1, 0x30($sp)
9d038914  lwc1      $f9, 0x18($a0)
9d038918  lwc1      $f10, 0x70($s0)
9d03891c  lwc1      $f11, 0x64($s0)
9d038920  lwc1      $f12, 0x6c($s0)
9d038924  sub.s     $f13, $f9, $f10
9d038928  lwc1      $f14, 0x60($s0)
9d03892c  sub.s     $f15, $f8, $f12
9d038930  lwc1      $f16, 0x4c($s0)
9d038934  mul.s     $f17, $f13, $f11
9d038938  lwc1      $f18, 0x58($s0)
9d03893c  lwc1      $f19, 0x40($s0)
9d038940  lwc1      $f7, 0x1c($a0)
9d038944  mul.s     $f21, $f15, $f14
9d038948  lwc1      $f23, 0x74($s0)
9d03894c  lwc1      $f25, 0x68($s0)
9d038950  mul.s     $f29, $f17, $f16
9d038954  mul.s     $f31, $f17, $f18
9d038958  mul.s     $f3, $f17, $f19
9d03895c  sub.s     $f5, $f7, $f23
9d038960  lwc1      $f27, 0x48($s0)
9d038964  lwc1      $f2, 0x54($s0)
9d038968  lwc1      $f1, 0x3c($s0)
9d03896c  mul.s     $f0, $f5, $f25
9d038970  madd.s    $f6, $f29, $f21, $f27
9d038974  madd.s    $f8, $f31, $f21, $f2
9d038978  madd.s    $f9, $f3, $f21, $f1
9d03897c  lwc1      $f4, 0x50($s0)
9d038980  lwc1      $f7, 0x5c($s0)
9d038984  lwc1      $f10, 0x44($s0)
9d038988  lw        $a3, 0x30($sp)
9d03898c  madd.s    $f11, $f6, $f0, $f4
9d038990  bc3tl     $cc1, 0x9d039614
9d038994  madd.s    $f13, $f9, $f0, $f10
9d038998  move      $s5, $a0
9d03899c  lw        $v1, 0xe8($s0)
9d0389a0  lui       $s4, 0x8008
9d0389a4  addiu     $s1, $s4, -0x26b0
9d0389a8  swc1      $f11, 0x2c($sp)
9d0389ac  swc1      $f12, 0x30($sp)
9d0389b0  swc1      $f13, 0x28($sp)
9d0389b4  lw        $a0, 0x28($sp)
9d0389b8  lw        $t1, 0x2c($sp)
9d0389bc  lw        $t2, 0x30($sp)
9d0389c0  sw        $t3, -0x26b0($s4)
9d0389c4  sw        $t0, -0x26ac($s4)
9d0389c8  sw        $a1, 8($s1)
9d0389cc  sw        $a2, 0xc($s1)
9d0389d0  sw        $a3, 0x10($s1)
9d0389d4  sw        $a0, 0x14($s1)
9d0389d8  sw        $t1, 0x18($s1)
9d0389dc  bnez      $v1, 0x9d038c64
9d0389e0  sw        $t2, 0x1c($s1)
9d0389e4  lw        $t4, 0xe4($s0)
9d0389e8  lwc1      $f14, 0x14($s1)
9d0389ec  lwc1      $f15, 0x18($s1)
9d0389f0  lwc1      $f16, 0x1c($s1)
9d0389f4  sltiu     $t7, $t4, 0x18
9d0389f8  lw        $t5, 8($s1)
9d0389fc  lw        $t6, 0xc($s1)
9d038a00  lw        $s3, 0x10($s1)
9d038a04  swc1      $f14, 0x58($sp)
9d038a08  swc1      $f15, 0x50($sp)
9d038a0c  beqz      $t7, 0x9d038ab0
9d038a10  swc1      $f16, 0x54($sp)
9d038a14  lui       $t9, 0x9d04
9d038a18  sll       $t8, $t4, 2
9d038a1c  addiu     $ra, $t9, -0x75d4
9d038a20  lwx       $v0, $t8($ra)
9d038a24  jr        $v0
9d038a28  nop       
9d038a2c  c.f.s     $f2, $f7
9d038a30  cop1.f0c  $f2, $f7
9d038a34  cop1.f28  $f4, $f7
9d038a38  c.sf.s    $f4, $f7
9d038a3c  cop1.f04  $f4, $f7
9d038a40  cop1.f00  $f4, $f7
9d038a44  cop1.f08  $f4, $f7
9d038a48  cop1.f20  $f4, $f7
9d038a4c  cop1.f28  $f4, $f7
9d038a50  c.sf.s    $f4, $f7
9d038a54  cop1.f04  $f4, $f7
9d038a58  cop1.f08  $f3, $f7
9d038a5c  cop1.f0c  $f3, $f7
9d038a60  cop1.f24  $f3, $f7
9d038a64  cop1.f20  $f3, $f7
9d038a68  cop1.f24  $f3, $f7
9d038a6c  c.lt.s    $f3, $f7
9d038a70  cop1.f00  $f3, $f7
9d038a74  cop1.f04  $f3, $f7
9d038a78  cop1.f00  $f3, $f7
9d038a7c  cop1.f10  $f3, $f7
9d038a80  cop1.f1c  $f3, $f7
9d038a84  cop1.f18  $f3, $f7
9d038a88  cop1.f10  $f4, $f7
9d038a8c  lw        $t1, 0x50($sp)
9d038a90  lwc1      $f14, 0x54($sp)
9d038a94  lui       $t5, 0x8000
9d038a98  xor       $ra, $t1, $t5
9d038a9c  xor       $v0, $t6, $t5
9d038aa0  swc1      $f14, 0x50($sp)
9d038aa4  sw        $s3, 0xc($s1)
9d038aa8  sw        $v0, 0x10($s1)
9d038aac  sw        $ra, 0x54($sp)
9d038ab0  lw        $t7, -0x7d70($gp)
9d038ab4  lw        $a1, -0x7d6c($gp)
9d038ab8  lwc1      $f15, 0x58($sp)
9d038abc  subu      $s0, $t3, $t7
9d038ac0  lwc1      $f16, 0x50($sp)
9d038ac4  lwc1      $f17, 0x54($sp)
9d038ac8  subu      $t0, $t0, $a1
9d038acc  sltu      $t3, $t3, $s0
9d038ad0  subu      $s2, $t0, $t3
9d038ad4  move      $a2, $zero
9d038ad8  move      $a3, $zero
9d038adc  move      $a0, $s0
9d038ae0  move      $a1, $s2
9d038ae4  swc1      $f15, 0x14($s1)
9d038ae8  swc1      $f16, 0x18($s1)
9d038aec  jal       0x9d0862a4
9d038af0  swc1      $f17, 0x1c($s1)
9d038af4  blez      $v0, 0x9d038c38
9d038af8  mtc1      $s0, $f18
9d038afc  mthc1     $s2, $f18
9d038b00  cop1.f21  $f5, $f1
9d038b04  lui       $t1, 0x9d09
9d038b08  ldc1      $f25, -0x6ef8($t1)
9d038b0c  lui       $s3, 0x8008
9d038b10  addiu     $a0, $s3, -0x3240
9d038b14  cop1.f02  $f15, $f19  ; cc=6
9d038b18  cop1.f20  $f23, $f1
9d038b1c  jal       0x9d0890dc
9d038b20  mfc1      $a1, $f29
9d038b24  lw        $v0, ($s5)
9d038b28  lw        $v1, 4($s5)
9d038b2c  addiu     $a0, $s3, -0x3240
9d038b30  sw        $v0, -0x7d70($gp)
9d038b34  jal       0x9d0890e4
9d038b38  sw        $v1, -0x7d6c($gp)
9d038b3c  addiu     $t4, $zero, 1  ; 1
9d038b40  beql      $v0, $t4, 0x9d038ca0
9d038b44  lw        $a0, 0x18($s1)
9d038b48  beqz      $v0, 0x9d038cd0
9d038b4c  addiu     $a3, $zero, 3  ; 3
9d038b50  bnel      $v0, $a3, 0x9d038b88
9d038b54  lui       $s1, 0x8008
9d038b58  lw        $t4, 0x14($s1)
9d038b5c  lw        $v1, 0x18($s1)
9d038b60  lw        $v0, 0x1c($s1)
9d038b64  lw        $a1, 8($s1)
9d038b68  lw        $a2, 0xc($s1)
9d038b6c  lw        $a3, 0x10($s1)
9d038b70  addiu     $a0, $s3, -0x3240
9d038b74  sw        $t4, 0x10($sp)
9d038b78  sw        $v1, 0x14($sp)
9d038b7c  jal       0x9d0391d0  ; AhrsUpdate_partial
9d038b80  sw        $v0, 0x18($sp)
9d038b84  lui       $s1, 0x8008
9d038b88  lw        $a2, -0x23c4($s1)
9d038b8c  beqz      $a2, 0x9d038ba0
9d038b90  addiu     $s2, $s1, -0x23c4
9d038b94  jalr      $a2
9d038b98  addiu     $a0, $s4, -0x26b0
9d038b9c  addiu     $s2, $s1, -0x23c4
9d038ba0  lw        $t6, 0xc($s2)
9d038ba4  beqz      $t6, 0x9d038bcc
9d038ba8  lw        $ra, -0x26b0($s4)
9d038bac  lw        $s4, -0x26ac($s4)
9d038bb0  lui       $t7, 0x8008
9d038bb4  addiu     $a0, $t7, -0x22d8
9d038bb8  addiu     $s3, $s3, -0x3240
9d038bbc  sw        $ra, -0x22d8($t7)
9d038bc0  sw        $s4, -0x22d4($t7)
9d038bc4  jalr      $t6
9d038bc8  sw        $s3, 8($a0)
9d038bcc  lw        $a0, -0x7d74($gp)
9d038bd0  addiu     $s0, $a0, 1
9d038bd4  sltiu     $t3, $s0, 0x50
9d038bd8  bnez      $t3, 0x9d038c14
9d038bdc  sw        $s0, -0x7d74($gp)
9d038be0  lw        $a1, ($s5)
9d038be4  lw        $t0, 4($s5)
9d038be8  lwc1      $f31, 0x20($s5)
9d038bec  lw        $s5, 0x10($s2)
9d038bf0  lui       $t8, 0x8008
9d038bf4  addiu     $a0, $t8, -0x22c8
9d038bf8  sw        $a1, -0x22c8($t8)
9d038bfc  sw        $t0, -0x22c4($t8)
9d038c00  beqz      $s5, 0x9d038c10
9d038c04  swc1      $f31, 8($a0)
9d038c08  jalr      $s5
9d038c0c  nop       
9d038c10  sw        $zero, -0x7d74($gp)
9d038c14  lw        $ra, 0x7c($sp)
9d038c18  lw        $s5, 0x78($sp)
9d038c1c  lw        $s4, 0x74($sp)
9d038c20  lw        $s3, 0x70($sp)
9d038c24  lw        $s2, 0x6c($sp)
9d038c28  lw        $s1, 0x68($sp)
9d038c2c  lw        $s0, 0x64($sp)
9d038c30  jr        $ra
9d038c34  addiu     $sp, $sp, 0x80
9d038c38  sll       $a3, $s2, 0x1f
9d038c3c  srl       $t2, $s0, 1
9d038c40  andi      $a2, $s0, 1
9d038c44  or        $t8, $a3, $t2
9d038c48  or        $t9, $a2, $t8
9d038c4c  mtc1      $t9, $f19
9d038c50  srl       $t5, $s2, 1
9d038c54  cop1.f00  $f6, $f27  ; cc=3
9d038c58  cop1.f21  $f7, $f1
9d038c5c  b         0x9d038b04
9d038c60  cop1.f00  $f11, $f11  ; cc=5
9d038c64  lui       $s2, 0x8008
9d038c68  jal       0x9d06b3dc
9d038c6c  addiu     $a0, $s2, -0x29d0
9d038c70  addiu     $a1, $s2, -0x29d0
9d038c74  jal       0x9d0879b0
9d038c78  addiu     $a0, $sp, 0x40
9d038c7c  lw        $a1, 0x40($sp)
9d038c80  lw        $t3, ($s5)
9d038c84  lw        $t0, 4($s5)
9d038c88  sw        $a1, 8($s1)
9d038c8c  lw        $a2, 0x44($sp)
9d038c90  sw        $a2, 0xc($s1)
9d038c94  lw        $a3, 0x48($sp)
9d038c98  b         0x9d0389e4
9d038c9c  sw        $a3, 0x10($s1)
9d038ca0  lw        $ra, 0x14($s1)
9d038ca4  lw        $t6, 0x1c($s1)
9d038ca8  lw        $a1, 8($s1)
9d038cac  lw        $a2, 0xc($s1)
9d038cb0  lw        $a3, 0x10($s1)
9d038cb4  sw        $a0, 0x14($sp)
9d038cb8  sw        $ra, 0x10($sp)
9d038cbc  sw        $t6, 0x18($sp)
9d038cc0  jal       0x9d041038  ; AhrsUpdate_alt
9d038cc4  addiu     $a0, $s3, -0x3240
9d038cc8  b         0x9d038b88
9d038ccc  lui       $s1, 0x8008
9d038cd0  jal       0x9d087910  ; Settings_GetPointer
9d038cd4  nop       
9d038cd8  lui       $t7, 0x8008
9d038cdc  addiu     $s0, $t7, -0x2468
9d038ce0  lw        $a1, 0xc($s0)
9d038ce4  lw        $t3, 8($s0)
9d038ce8  lw        $t0, 0x10($s0)
9d038cec  move      $a0, $v0
9d038cf0  sw        $a1, 0x2c($sp)
9d038cf4  sw        $t3, 0x28($sp)
9d038cf8  jal       0x9d086d70  ; Scheduler_CriticalSection
9d038cfc  sw        $t0, 0x30($sp)
9d038d00  lw        $t2, 0x14($s1)
9d038d04  lw        $t5, 0x18($s1)
9d038d08  lw        $t1, 0x1c($s1)
9d038d0c  lw        $s2, 0x28($sp)
9d038d10  lw        $t8, 0x2c($sp)
9d038d14  lw        $t9, 0x30($sp)
9d038d18  lw        $a1, 8($s1)
9d038d1c  lw        $a2, 0xc($s1)
9d038d20  lw        $a3, 0x10($s1)
9d038d24  addiu     $a0, $s3, -0x3240
9d038d28  sw        $s2, 0x1c($sp)
9d038d2c  sw        $t8, 0x20($sp)
9d038d30  sw        $t9, 0x24($sp)
9d038d34  sw        $t2, 0x10($sp)
9d038d38  sw        $t5, 0x14($sp)
9d038d3c  sw        $t1, 0x18($sp)
9d038d40  sw        $s2, 0x34($sp)
9d038d44  sw        $t8, 0x38($sp)