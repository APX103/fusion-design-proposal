9d036ac8  lw        $v0, 8($a0)
9d036acc  addiu     $sp, $sp, -0x90
9d036ad0  sw        $ra, 0x8c($sp)
9d036ad4  sw        $a1, 0x94($sp)
9d036ad8  sw        $a2, 0x98($sp)
9d036adc  bnez      $v0, 0x9d037220
9d036ae0  sw        $a3, 0x9c($sp)
9d036ae4  lwc1      $f2, 0xa0($sp)
9d036ae8  lwc1      $f1, 0xa4($sp)
9d036aec  lwc1      $f11, 0xa8($sp)
9d036af0  lbu       $v1, 0x18($a0)
9d036af4  move      $a2, $a0
9d036af8  lw        $t0, 0x94($sp)
9d036afc  lw        $t1, 0x98($sp)
9d036b00  lw        $t2, 0x9c($sp)
9d036b04  lwc1      $f7, 0xac($sp)
9d036b08  lwc1      $f8, 0xb0($sp)
9d036b0c  lwc1      $f9, 0xb4($sp)
9d036b10  swc1      $f2, 0x48($a0)
9d036b14  swc1      $f1, 0x4c($a0)
9d036b18  beqz      $v1, 0x9d036b74
9d036b1c  swc1      $f11, 0x50($a0)
9d036b20  lwc1      $f0, 0x1c($a0)
9d036b24  ext       $a0, $t0, 0, 0x1f
9d036b28  mtc1      $a0, $f3
9d036b2c  c.le.s    $f3, $f0
9d036b30  bc1f      0x9d036b5c
9d036b34  ext       $a1, $t1, 0, 0x1f
9d036b38  mtc1      $a1, $f4
9d036b3c  c.le.s    $f8, $f0
9d036b40  bc1f      $fcc1, 0x9d036b60
9d036b44  move      $a0, $a2
9d036b48  ext       $a3, $t2, 0, 0x1f
9d036b4c  mtc1      $a3, $f5
9d036b50  c.le.s    $f10, $f0
9d036b54  bc1tl     $fcc2, 0x9d036b78
9d036b58  lbu       $t4, 0x54($a2)
9d036b5c  move      $a0, $a2
9d036b60  jal       0x9d08252c
9d036b64  sw        $v0, 0x80($sp)
9d036b68  addiu     $v0, $zero, 1  ; 1
9d036b6c  sb        $v0, 0x5c($a2)
9d036b70  lw        $v0, 0x80($sp)
9d036b74  lbu       $t4, 0x54($a2)
9d036b78  beqz      $t4, 0x9d036bac
9d036b7c  lui       $t3, 0x9d08
9d036b80  lwc1      $f6, 0x58($a2)
9d036b84  lwc1      $f10, 0x14($a2)
9d036b88  lwc1      $f12, 0xc($a2)
9d036b8c  sub.s     $f13, $f6, $f10
9d036b90  c.lt.s    $f24, $f26  ; cc=3
9d036b94  bc1t      $fcc3, 0x9d036bac
9d036b98  swc1      $f13, 0x58($a2)
9d036b9c  sb        $zero, 0x54($a2)
9d036ba0  sb        $zero, 0x5c($a2)
9d036ba4  move      $t4, $zero
9d036ba8  lui       $t3, 0x9d08
9d036bac  lwc1      $f14, 0x5b7c($t3)
9d036bb0  mtc1      $t0, $f15
9d036bb4  mtc1      $t1, $f17
9d036bb8  mtc1      $t2, $f19
9d036bbc  mul.s     $f16, $f15, $f14
9d036bc0  mul.s     $f18, $f17, $f14
9d036bc4  mul.s     $f21, $f19, $f14
9d036bc8  lw        $t5, 4($a2)
9d036bcc  sltiu     $t6, $t5, 2
9d036bd0  swc1      $f16, 0x74($sp)
9d036bd4  swc1      $f18, 0x78($sp)
9d036bd8  bnez      $t6, 0x9d036f34
9d036bdc  swc1      $f21, 0x7c($sp)
9d036be0  addiu     $t8, $zero, 2  ; 2
9d036be4  bne       $t5, $t8, 0x9d036e68
9d036be8  mtc1      $zero, $f27
9d036bec  lwc1      $f10, 0x38($a2)
9d036bf0  lwc1      $f6, 0x3c($a2)
9d036bf4  lwc1      $f13, 0x44($a2)
9d036bf8  mul.s     $f12, $f10, $f10
9d036bfc  mul.s     $f14, $f10, $f6
9d036c00  mul.s     $f15, $f6, $f13
9d036c04  lwc1      $f16, 0x40($a2)
9d036c08  lui       $ra, 0x9d08
9d036c0c  mul.s     $f17, $f13, $f13
9d036c10  lwc1      $f19, 0x5b54($ra)
9d036c14  lui       $v1, 0x8000
9d036c18  madd.s    $f18, $f14, $f16, $f13
9d036c1c  sub.s     $f21, $f19, $f12
9d036c20  msub.s    $f25, $f15, $f10, $f16
9d036c24  sub.s     $f23, $f21, $f17
9d036c28  mfc1      $t9, $f18
9d036c2c  xor       $a0, $t9, $v1
9d036c30  sw        $a0, 0x6c($sp)
9d036c34  swc1      $f25, 0x68($sp)
9d036c38  swc1      $f23, 0x70($sp)
9d036c3c  mtc1      $zero, $f27
9d036c40  addiu     $t0, $zero, 1  ; 1
9d036c44  c.eq.s    $f5, $f22  ; cc=6
9d036c48  bc1f      $fcc4, 0x9d036e90
9d036c4c  sb        $t0, 0x74($a2)
9d036c50  c.eq.s    $f3, $f22  ; cc=6
9d036c54  bc1fl     $fcc5, 0x9d036e94
9d036c58  mul.s     $f29, $f1, $f1
9d036c5c  c.eq.s    $f23, $f22  ; cc=6
9d036c60  bc1fl     $fcc6, 0x9d036e94
9d036c64  mul.s     $f29, $f1, $f1
9d036c68  swc1      $f27, 0x5c($sp)
9d036c6c  swc1      $f27, 0x60($sp)
9d036c70  swc1      $f27, 0x64($sp)
9d036c74  lui       $a1, 0x9d08
9d036c78  mtc1      $zero, $f14
9d036c7c  addiu     $t3, $zero, 1  ; 1
9d036c80  c.eq.s    $f15, $f28  ; cc=3
9d036c84  bc1f      $fcc4, 0x9d037034
9d036c88  sb        $t3, 0x8c($a2)
9d036c8c  c.eq.s    $f17, $f28  ; cc=3
9d036c90  bc1fl     $fcc5, 0x9d037038
9d036c94  mul.s     $f12, $f9, $f25
9d036c98  c.eq.s    $f19, $f28  ; cc=3
9d036c9c  bc1fl     $fcc6, 0x9d037038
9d036ca0  mul.s     $f12, $f9, $f25
9d036ca4  mov.s     $f9, $f14
9d036ca8  mov.s     $f21, $f14
9d036cac  mov.s     $f8, $f14
9d036cb0  swc1      $f14, 0x50($sp)
9d036cb4  swc1      $f14, 0x54($sp)
9d036cb8  swc1      $f14, 0x58($sp)
9d036cbc  lwc1      $f27, 0x5c($sp)
9d036cc0  lwc1      $f29, 0x60($sp)
9d036cc4  beqz      $t4, 0x9d0371fc
9d036cc8  lwc1      $f31, 0x64($sp)
9d036ccc  add.s     $f5, $f8, $f27
9d036cd0  add.s     $f11, $f21, $f29
9d036cd4  add.s     $f0, $f9, $f31
9d036cd8  lwc1      $f13, 0x58($a2)
9d036cdc  mul.s     $f10, $f5, $f13
9d036ce0  mul.s     $f4, $f11, $f13
9d036ce4  mul.s     $f1, $f0, $f13
9d036ce8  lwc1      $f14, 0x7c($sp)
9d036cec  lwc1      $f2, ($a2)
9d036cf0  lwc1      $f15, 0x74($sp)
9d036cf4  add.s     $f12, $f1, $f14
9d036cf8  lwc1      $f19, 0x78($sp)
9d036cfc  add.s     $f16, $f10, $f15
9d036d00  lwc1      $f18, 0x40($a2)
9d036d04  mul.s     $f17, $f12, $f2
9d036d08  add.s     $f9, $f4, $f19
9d036d0c  mul.s     $f21, $f16, $f2
9d036d10  lwc1      $f8, 0x38($a2)
9d036d14  lwc1      $f27, 0x44($a2)
9d036d18  mul.s     $f29, $f9, $f2
9d036d1c  lwc1      $f7, 0x3c($a2)
9d036d20  mul.s     $f31, $f17, $f18
9d036d24  lw        $t8, 0x3c($a2)
9d036d28  lwc1      $f4, 0x3c($a2)
9d036d2c  lui       $t4, 0x8000
9d036d30  mul.s     $f23, $f17, $f7
9d036d34  mul.s     $f25, $f29, $f18
9d036d38  mul.s     $f10, $f29, $f27
9d036d3c  madd.s    $f3, $f31, $f21, $f8
9d036d40  mul.s     $f1, $f29, $f4
9d036d44  xor       $t9, $t8, $t4
9d036d48  mtc1      $t9, $f0
9d036d4c  mul.s     $f6, $f17, $f27
9d036d50  msub.s    $f13, $f25, $f0, $f21
9d036d54  lwc1      $f16, 0x3c($a2)
9d036d58  sub.s     $f2, $f3, $f10
9d036d5c  msub.s    $f11, $f23, $f29, $f8
9d036d60  madd.s    $f12, $f1, $f17, $f8
9d036d64  mul.s     $f14, $f21, $f18
9d036d68  add.s     $f17, $f2, $f16
9d036d6c  sub.s     $f19, $f13, $f6
9d036d70  lwc1      $f5, 0x5b5c($a1)
9d036d74  lw        $a1, 0x90($a2)
9d036d78  mul.s     $f9, $f17, $f17
9d036d7c  madd.s    $f15, $f11, $f21, $f27
9d036d80  add.s     $f21, $f19, $f8
9d036d84  sub.s     $f8, $f12, $f14
9d036d88  addiu     $ra, $zero, 1  ; 1
9d036d8c  madd.s    $f29, $f9, $f21, $f21
9d036d90  add.s     $f18, $f15, $f18
9d036d94  add.s     $f27, $f8, $f27
9d036d98  madd.s    $f31, $f29, $f18, $f18
9d036d9c  madd.s    $f7, $f31, $f27, $f27
9d036da0  sqrt.s    $f23, $f7
9d036da4  div.s     $f6, $f5, $f23
9d036da8  mul.s     $f25, $f21, $f6
9d036dac  mul.s     $f10, $f17, $f6
9d036db0  mul.s     $f1, $f18, $f6
9d036db4  mul.s     $f11, $f27, $f6
9d036db8  swc1      $f25, 0x10($sp)
9d036dbc  swc1      $f10, 0x14($sp)
9d036dc0  swc1      $f1, 0x18($sp)
9d036dc4  swc1      $f11, 0x1c($sp)
9d036dc8  lw        $a0, 0x10($sp)
9d036dcc  lw        $t0, 0x14($sp)
9d036dd0  lw        $t2, 0x18($sp)
9d036dd4  lw        $t1, 0x1c($sp)
9d036dd8  sw        $a0, 0x38($a2)
9d036ddc  sw        $t0, 0x3c($a2)
9d036de0  sw        $t2, 0x40($a2)
9d036de4  bne       $a1, $ra, 0x9d037224
9d036de8  sw        $t1, 0x44($a2)
9d036dec  beql      $t5, $a1, 0x9d037368
9d036df0  lui       $t5, 0x9d08
9d036df4  beqz      $t5, 0x9d037338
9d036df8  addiu     $v1, $zero, 2  ; 2
9d036dfc  beq       $t5, $v1, 0x9d03733c
9d036e00  lui       $a3, 0x9d08
9d036e04  mtc1      $zero, $f15
9d036e08  mov.s     $f16, $f15
9d036e0c  mov.s     $f17, $f15
9d036e10  swc1      $f15, 0x10($sp)
9d036e14  swc1      $f15, 0x14($sp)
9d036e18  swc1      $f15, 0x18($sp)
9d036e1c  lwc1      $f19, 0xa4($a2)
9d036e20  lwc1      $f9, 0xa8($a2)
9d036e24  lwc1      $f21, 0xa0($a2)
9d036e28  lw        $t3, 0x9c($a2)
9d036e2c  add.s     $f18, $f16, $f19
9d036e30  add.s     $f8, $f15, $f9
9d036e34  add.s     $f29, $f21, $f17
9d036e38  lw        $t6, 0x34($a2)
9d036e3c  addiu     $t7, $t3, 1
9d036e40  swc1      $f18, 0xa4($a2)
9d036e44  sltu      $t4, $t7, $t6
9d036e48  swc1      $f29, 0xa0($a2)
9d036e4c  swc1      $f8, 0xa8($a2)
9d036e50  bnez      $t4, 0x9d037224
9d036e54  sw        $t7, 0x9c($a2)
9d036e58  lw        $ra, 0x8c($sp)
9d036e5c  move      $a0, $a2
9d036e60  j         0x9d07bfa4  ; AhrsInitialiseWindow_Step
9d036e64  addiu     $sp, $sp, 0x90
9d036e68  mtc1      $zero, $f23
9d036e6c  c.eq.s    $f5, $f22  ; cc=6
9d036e70  addiu     $t0, $zero, 1  ; 1
9d036e74  swc1      $f23, 0x70($sp)
9d036e78  swc1      $f23, 0x68($sp)
9d036e7c  mfc1      $a0, $f23
9d036e80  mov.s     $f25, $f23
9d036e84  swc1      $f23, 0x6c($sp)
9d036e88  bc1t      $fcc4, 0x9d036c50
9d036e8c  sb        $t0, 0x74($a2)
9d036e90  mul.s     $f29, $f1, $f1
9d036e94  lui       $a1, 0x9d08
9d036e98  lwc1      $f31, 0x5b5c($a1)
9d036e9c  mtc1      $zero, $f3
9d036ea0  madd.s    $f0, $f29, $f2, $f2
9d036ea4  madd.s    $f4, $f0, $f11, $f11
9d036ea8  sqrt.s    $f5, $f4
9d036eac  div.s     $f10, $f31, $f5
9d036eb0  mul.s     $f1, $f1, $f10
9d036eb4  mul.s     $f6, $f10, $f11
9d036eb8  mtc1      $a0, $f11
9d036ebc  mul.s     $f2, $f2, $f10
9d036ec0  mul.s     $f13, $f1, $f11
9d036ec4  mul.s     $f15, $f6, $f11
9d036ec8  mul.s     $f16, $f1, $f25
9d036ecc  mul.s     $f14, $f2, $f23
9d036ed0  swc1      $f2, 0x44($sp)
9d036ed4  swc1      $f1, 0x48($sp)
9d036ed8  swc1      $f6, 0x4c($sp)
9d036edc  madd.s    $f17, $f13, $f2, $f25
9d036ee0  msub.s    $f19, $f15, $f1, $f23
9d036ee4  msub.s    $f27, $f16, $f2, $f11
9d036ee8  madd.s    $f29, $f17, $f6, $f23
9d036eec  c.lt.s    $f7, $f26  ; cc=7
9d036ef0  bc1t      $fcc7, 0x9d036f9c
9d036ef4  msub.s    $f18, $f14, $f6, $f25
9d036ef8  c.eq.s    $f19, $f3
9d036efc  swc1      $f19, 0x20($sp)
9d036f00  swc1      $f18, 0x24($sp)
9d036f04  bc1f      0x9d036f78
9d036f08  swc1      $f27, 0x28($sp)
9d036f0c  c.eq.s    $f4, $f7
9d036f10  bc1fl     $fcc1, 0x9d036f7c
9d036f14  mul.s     $f31, $f18, $f18
9d036f18  c.eq.s    $f22, $f7
9d036f1c  bc1fl     $fcc2, 0x9d036f7c
9d036f20  mul.s     $f31, $f18, $f18
9d036f24  swc1      $f3, 0x10($sp)
9d036f28  swc1      $f3, 0x14($sp)
9d036f2c  b         0x9d036fa8
9d036f30  swc1      $f3, 0x18($sp)
9d036f34  lui       $t7, 0x9d08
9d036f38  lwc1      $f23, 0x38($a2)
9d036f3c  lwc1      $f25, 0x3c($a2)
9d036f40  lwc1      $f27, 0x40($a2)
9d036f44  lwc1      $f0, 0x5b54($t7)
9d036f48  mul.s     $f29, $f25, $f23
9d036f4c  mul.s     $f31, $f23, $f27
9d036f50  msub.s    $f4, $f0, $f23, $f23
9d036f54  lwc1      $f3, 0x44($a2)
9d036f58  madd.s    $f5, $f29, $f3, $f27
9d036f5c  msub.s    $f25, $f31, $f25, $f3
9d036f60  madd.s    $f23, $f4, $f3, $f3
9d036f64  mfc1      $a0, $f5
9d036f68  swc1      $f5, 0x6c($sp)
9d036f6c  swc1      $f25, 0x68($sp)
9d036f70  b         0x9d036c3c
9d036f74  swc1      $f23, 0x70($sp)
9d036f78  mul.s     $f31, $f18, $f18
9d036f7c  lwc1      $f3, 0x5b5c($a1)
9d036f80  madd.s    $f0, $f31, $f19, $f19
9d036f84  madd.s    $f4, $f0, $f27, $f27
9d036f88  sqrt.s    $f5, $f4
9d036f8c  div.s     $f10, $f3, $f5
9d036f90  mul.s     $f19, $f10, $f19
9d036f94  mul.s     $f18, $f10, $f18
9d036f98  mul.s     $f27, $f10, $f27
9d036f9c  swc1      $f19, 0x10($sp)
9d036fa0  swc1      $f18, 0x14($sp)
9d036fa4  swc1      $f27, 0x18($sp)
9d036fa8  lw        $t2, 0x10($sp)
9d036fac  lw        $t1, 0x14($sp)
9d036fb0  lw        $a3, 0x18($sp)
9d036fb4  lbu       $t3, 0x20($a2)
9d036fb8  sw        $t2, 0x60($a2)
9d036fbc  sw        $t1, 0x64($a2)
9d036fc0  beqz      $t3, 0x9d037304
9d036fc4  sw        $a3, 0x68($a2)
9d036fc8  beqz      $t4, 0x9d037270
9d036fcc  lw        $t6, 0x6c($a2)
9d036fd0  addiu     $v1, $t6, -9
9d036fd4  sb        $zero, 0x74($a2)
9d036fd8  sw        $v1, 0x6c($a2)
9d036fdc  lw        $t7, 0x70($a2)
9d036fe0  slt       $t9, $t7, $v1
9d036fe4  bnez      $t9, 0x9d037230
9d036fe8  lw        $t8, 0x30($a2)
9d036fec  sw        $t8, 0x70($a2)
9d036ff0  bltz      $v1, 0x9d037490
9d036ff4  lbu       $ra, 0x74($a2)
9d036ff8  slt       $a0, $t8, $v1
9d036ffc  movn      $v1, $t8, $a0
9d037000  beqz      $ra, 0x9d037248
9d037004  sw        $v1, 0x6c($a2)
9d037008  mtc1      $zero, $f14
9d03700c  addiu     $t3, $zero, 1  ; 1
9d037010  c.eq.s    $f15, $f28  ; cc=3
9d037014  sw        $zero, 0x5c($sp)
9d037018  sw        $zero, 0x60($sp)
9d03701c  sw        $zero, 0x64($sp)
9d037020  lwc1      $f25, 0x68($sp)
9d037024  lw        $a0, 0x6c($sp)
9d037028  lwc1      $f23, 0x70($sp)
9d03702c  bc1t      $fcc4, 0x9d036c8c
9d037030  sb        $t3, 0x8c($a2)
9d037034  mul.s     $f12, $f9, $f25
9d037038  mtc1      $a0, $f16
9d03703c  mul.s     $f15, $f8, $f23
9d037040  mul.s     $f17, $f7, $f16
9d037044  lwc1      $f18, 0x5b5c($a1)
9d037048  addiu     $t6, $zero, 1  ; 1
9d03704c  msub.s    $f7, $f12, $f7, $f23
9d037050  msub.s    $f9, $f15, $f9, $f16
9d037054  msub.s    $f8, $f17, $f8, $f25
9d037058  mul.s     $f21, $f7, $f7
9d03705c  swc1      $f7, 0x3c($sp)
9d037060  swc1      $f9, 0x38($sp)
9d037064  swc1      $f8, 0x40($sp)
9d037068  madd.s    $f27, $f21, $f9, $f9
9d03706c  madd.s    $f29, $f27, $f8, $f8
9d037070  sqrt.s    $f31, $f29
9d037074  div.s     $f3, $f18, $f31
9d037078  mul.s     $f23, $f9, $f3
9d03707c  mul.s     $f0, $f7, $f3
9d037080  mul.s     $f25, $f8, $f3
9d037084  swc1      $f23, 0x2c($sp)
9d037088  swc1      $f0, 0x30($sp)
9d03708c  beq       $t5, $t6, 0x9d037394
9d037090  swc1      $f25, 0x34($sp)
9d037094  beqz      $t5, 0x9d037448
9d037098  addiu     $v1, $zero, 2  ; 2
9d03709c  beql      $t5, $v1, 0x9d0373f4
9d0370a0  lwc1      $f6, 0x38($a2)
9d0370a4  mtc1      $zero, $f18
9d0370a8  sw        $zero, 0x80($sp)
9d0370ac  mfc1      $a3, $f18
9d0370b0  sw        $zero, 0x20($sp)
9d0370b4  swc1      $f18, 0x24($sp)
9d0370b8  swc1      $f18, 0x28($sp)
9d0370bc  mul.s     $f17, $f0, $f18
9d0370c0  mtc1      $a3, $f8
9d0370c4  lwc1      $f6, 0x80($sp)
9d0370c8  mul.s     $f7, $f0, $f8
9d0370cc  lwc1      $f9, 0x80($sp)
9d0370d0  mul.s     $f19, $f25, $f18
9d0370d4  mtc1      $zero, $f27
9d0370d8  madd.s    $f31, $f17, $f23, $f8
9d0370dc  mul.s     $f21, $f23, $f9
9d0370e0  msub.s    $f2, $f7, $f23, $f18
9d0370e4  msub.s    $f0, $f19, $f0, $f6
9d0370e8  madd.s    $f23, $f31, $f25, $f6
9d0370ec  c.lt.s    $f23, $f15  ; cc=5
9d0370f0  bc1t      $fcc7, 0x9d037140
9d0370f4  msub.s    $f13, $f21, $f25, $f8
9d0370f8  c.eq.s    $f0, $f27
9d0370fc  bc1fl     0x9d037120
9d037100  mul.s     $f25, $f13, $f13
9d037104  c.eq.s    $f26, $f22  ; cc=6
9d037108  bc1fl     $fcc1, 0x9d037120
9d03710c  mul.s     $f25, $f13, $f13
9d037110  c.eq.s    $f4, $f22  ; cc=6
9d037114  bc1tl     $fcc2, 0x9d0372a4
9d037118  swc1      $f27, 0x10($sp)
9d03711c  mul.s     $f25, $f13, $f13
9d037120  lwc1      $f5, 0x5b5c($a1)
9d037124  madd.s    $f10, $f25, $f0, $f0
9d037128  madd.s    $f1, $f10, $f2, $f2
9d03712c  sqrt.s    $f4, $f1
9d037130  div.s     $f11, $f5, $f4
9d037134  mul.s     $f0, $f11, $f0
9d037138  mul.s     $f13, $f11, $f13
9d03713c  mul.s     $f2, $f11, $f2
9d037140  swc1      $f0, 0x10($sp)
9d037144  swc1      $f13, 0x14($sp)
9d037148  swc1      $f2, 0x18($sp)
9d03714c  lw        $t3, 0x10($sp)
9d037150  lw        $t6, 0x14($sp)
9d037154  lw        $t7, 0x18($sp)
9d037158  lbu       $t8, 0x28($a2)
9d03715c  sw        $t3, 0x78($a2)
9d037160  sw        $t6, 0x7c($a2)
9d037164  beqz      $t8, 0x9d037318
9d037168  sw        $t7, 0x80($a2)
9d03716c  bnez      $t4, 0x9d0372b0
9d037170  lw        $t9, 0x84($a2)
9d037174  lwc1      $f14, 0x7c($a2)
9d037178  lwc1      $f12, 0x78($a2)
9d03717c  lwc1      $f15, 0x80($a2)
9d037180  mul.s     $f16, $f14, $f14
9d037184  lwc1      $f18, 0x2c($a2)
9d037188  madd.s    $f17, $f16, $f12, $f12
9d03718c  madd.s    $f19, $f17, $f15, $f15
9d037190  c.le.s    $f6, $f5  ; cc=4
9d037194  bc1t      $fcc3, 0x9d0372b4
9d037198  lw        $ra, 0x88($a2)
9d03719c  addiu     $v1, $t9, 1
9d0371a0  sw        $v1, 0x84($a2)
9d0371a4  slt       $t0, $ra, $v1
9d0371a8  beqz      $t0, 0x9d0372cc
9d0371ac  lw        $a0, 0x30($a2)
9d0371b0  sw        $zero, 0x88($a2)
9d0371b4  bltz      $v1, 0x9d0374a0
9d0371b8  sb        $zero, 0x8c($a2)
9d0371bc  slt       $a3, $a0, $v1
9d0371c0  movn      $v1, $a0, $a3
9d0371c4  sw        $v1, 0x84($a2)
9d0371c8  lw        $t3, 0x78($a2)
9d0371cc  lw        $t6, 0x7c($a2)
9d0371d0  lw        $t7, 0x80($a2)
9d0371d4  sw        $t3, 0x50($sp)
9d0371d8  sw        $t6, 0x54($sp)
9d0371dc  sw        $t7, 0x58($sp)
9d0371e0  lwc1      $f8, 0x50($sp)
9d0371e4  lwc1      $f21, 0x54($sp)
9d0371e8  lwc1      $f9, 0x58($sp)
9d0371ec  lwc1      $f27, 0x5c($sp)
9d0371f0  lwc1      $f29, 0x60($sp)
9d0371f4  bnez      $t4, 0x9d036ccc
9d0371f8  lwc1      $f31, 0x64($sp)
9d0371fc  lwc1      $f7, 0x10($a2)
9d037200  lwc1      $f23, 0xc($a2)
9d037204  mul.s     $f3, $f7, $f8
9d037208  mul.s     $f6, $f7, $f21
9d03720c  mul.s     $f25, $f7, $f9
9d037210  madd.s    $f10, $f3, $f23, $f27
9d037214  madd.s    $f4, $f6, $f23, $f29
9d037218  b         0x9d036ce8
9d03721c  madd.s    $f1, $f25, $f23, $f31
9d037220  addiu     $v0, $zero, 1  ; 1
9d037224  lw        $ra, 0x8c($sp)
9d037228  jr        $ra
9d03722c  addiu     $sp, $sp, 0x90
9d037230  sw        $zero, 0x70($a2)
9d037234  bltz      $v1, 0x9d0374a8
9d037238  sb        $zero, 0x74($a2)
9d03723c  slt       $t0, $t8, $v1
9d037240  movn      $v1, $t8, $t0
9d037244  sw        $v1, 0x6c($a2)
9d037248  lw        $t2, 0x60($a2)
9d03724c  lw        $t1, 0x64($a2)
9d037250  lw        $a3, 0x68($a2)
9d037254  lwc1      $f25, 0x68($sp)
9d037258  lw        $a0, 0x6c($sp)
9d03725c  lwc1      $f23, 0x70($sp)
9d037260  sw        $t2, 0x5c($sp)
9d037264  sw        $t1, 0x60($sp)
9d037268  b         0x9d036c78
9d03726c  sw        $a3, 0x64($sp)
9d037270  lwc1      $f23, 0x64($a2)
9d037274  lwc1      $f25, 0x60($a2)
9d037278  lwc1      $f6, 0x68($a2)
9d03727c  mul.s     $f1, $f23, $f23
9d037280  lwc1      $f2, 0x24($a2)
9d037284  madd.s    $f11, $f1, $f25, $f25
9d037288  madd.s    $f13, $f11, $f6, $f6
9d03728c  c.le.s    $f26, $f4
9d037290  bc1tl     $fcc3, 0x9d036fd4
9d037294  addiu     $v1, $t6, -9
9d037298  addiu     $v1, $t6, 1
9d03729c  b         0x9d036fdc
9d0372a0  sw        $v1, 0x6c($a2)
9d0372a4  swc1      $f27, 0x14($sp)
9d0372a8  b         0x9d03714c
9d0372ac  swc1      $f27, 0x18($sp)
9d0372b0  lw        $ra, 0x88($a2)
9d0372b4  addiu     $v1, $t9, -9
9d0372b8  sb        $zero, 0x8c($a2)
9d0372bc  slt       $t0, $ra, $v1
9d0372c0  sw        $v1, 0x84($a2)
9d0372c4  bnez      $t0, 0x9d0371b0
9d0372c8  lw        $a0, 0x30($a2)
9d0372cc  sw        $a0, 0x88($a2)
9d0372d0  bltz      $v1, 0x9d037498
9d0372d4  lbu       $t2, 0x8c($a2)
9d0372d8  slt       $t1, $a0, $v1
9d0372dc  movn      $v1, $a0, $t1
9d0372e0  beqz      $t2, 0x9d0371c8
9d0372e4  sw        $v1, 0x84($a2)
9d0372e8  mtc1      $zero, $f9
9d0372ec  swc1      $f9, 0x50($sp)
9d0372f0  swc1      $f9, 0x54($sp)
9d0372f4  swc1      $f9, 0x58($sp)
9d0372f8  mov.s     $f21, $f9
9d0372fc  b         0x9d036cbc
9d037300  mov.s     $f8, $f9
9d037304  sb        $zero, 0x74($a2)
9d037308  sw        $t2, 0x5c($sp)
9d03730c  sw        $t1, 0x60($sp)
9d037310  b         0x9d036c78
9d037314  sw        $a3, 0x64($sp)
9d037318  sw        $t3, 0x50($sp)
9d03731c  sw        $t6, 0x54($sp)
9d037320  sw        $t7, 0x58($sp)
9d037324  sb        $zero, 0x8c($a2)
9d037328  lwc1      $f8, 0x50($sp)
9d03732c  lwc1      $f21, 0x54($sp)
9d037330  b         0x9d036cbc
9d037334  lwc1      $f9, 0x58($sp)
9d037338  lui       $a3, 0x9d08
9d03733c  lwc1      $f2, 0x5b54($a3)
9d037340  mul.s     $f0, $f25, $f11
9d037344  mul.s     $f13, $f25, $f1
9d037348  msub.s    $f12, $f2, $f25, $f25
9d03734c  msub.s    $f16, $f0, $f10, $f1
9d037350  madd.s    $f15, $f13, $f10, $f11
9d037354  madd.s    $f17, $f12, $f10, $f10
9d037358  swc1      $f16, 0x14($sp)
9d03735c  swc1      $f15, 0x18($sp)
9d037360  b         0x9d036e1c
9d037364  swc1      $f17, 0x10($sp)
9d037368  lwc1      $f14, 0x5b54($t5)
9d03736c  mul.s     $f3, $f25, $f11
9d037370  mul.s     $f4, $f25, $f10
9d037374  msub.s    $f5, $f14, $f25, $f25
9d037378  madd.s    $f17, $f3, $f10, $f1
9d03737c  msub.s    $f15, $f4, $f1, $f11
9d037380  madd.s    $f16, $f5, $f1, $f1
9d037384  swc1      $f17, 0x10($sp)
9d037388  swc1      $f15, 0x18($sp)
9d03738c  b         0x9d036e1c
9d037390  swc1      $f16, 0x14($sp)
9d037394  lwc1      $f5, 0x38($a2)
9d037398  lwc1      $f4, 0x40($a2)
9d03739c  lwc1      $f6, 0x3c($a2)
9d0373a0  lwc1      $f11, 0x44($a2)
9d0373a4  mul.s     $f1, $f5, $f4
9d0373a8  mul.s     $f10, $f5, $f5
9d0373ac  mul.s     $f2, $f6, $f4
9d0373b0  lui       $t7, 0x9d08
9d0373b4  mul.s     $f13, $f6, $f6
9d0373b8  lwc1      $f14, 0x5b54($t7)
9d0373bc  lui       $t9, 0x8000
9d0373c0  madd.s    $f15, $f1, $f6, $f11
9d0373c4  sub.s     $f12, $f14, $f10
9d0373c8  msub.s    $f18, $f2, $f5, $f11
9d0373cc  sub.s     $f16, $f12, $f13
9d0373d0  mfc1      $t8, $f15
9d0373d4  xor       $ra, $t8, $t9
9d0373d8  sw        $ra, 0x80($sp)
9d0373dc  lwc1      $f17, 0x80($sp)
9d0373e0  mfc1      $a3, $f16
9d0373e4  swc1      $f16, 0x20($sp)
9d0373e8  swc1      $f18, 0x24($sp)
9d0373ec  b         0x9d0370bc
9d0373f0  swc1      $f17, 0x28($sp)
9d0373f4  lwc1      $f5, 0x44($a2)
9d0373f8  lwc1      $f10, 0x40($a2)
9d0373fc  mul.s     $f1, $f6, $f6
9d037400  mul.s     $f4, $f6, $f5
9d037404  mul.s     $f2, $f10, $f5
9d037408  lwc1      $f11, 0x3c($a2)
9d03740c  lui       $t2, 0x9d08
9d037410  mul.s     $f13, $f10, $f10
9d037414  lwc1      $f12, 0x5b54($t2)
9d037418  lui       $t1, 0x8000
9d03741c  madd.s    $f14, $f4, $f11, $f10
9d037420  sub.s     $f15, $f12, $f1
9d037424  msub.s    $f16, $f2, $f11, $f6
9d037428  sub.s     $f18, $f15, $f13
9d03742c  mfc1      $t0, $f14
9d037430  xor       $a3, $t0, $t1
9d037434  swc1      $f16, 0x80($sp)
9d037438  sw        $a3, 0x20($sp)
9d03743c  swc1      $f18, 0x24($sp)
9d037440  b         0x9d0370bc
9d037444  swc1      $f16, 0x28($sp)
9d037448  lui       $a0, 0x9d08
9d03744c  lwc1      $f18, 0x38($a2)
9d037450  lwc1      $f19, 0x3c($a2)
9d037454  lwc1      $f9, 0x44($a2)
9d037458  lwc1      $f21, 0x5b54($a0)
9d03745c  mul.s     $f8, $f19, $f18
9d037460  mul.s     $f7, $f18, $f9
9d037464  msub.s    $f27, $f21, $f18, $f18
9d037468  lwc1      $f29, 0x40($a2)
9d03746c  bc3t      $cc2, 0x9d033410
9d037470  madd.s    $f3, $f7, $f19, $f29
9d037474  madd.s    $f18, $f27, $f29, $f29
9d037478  swc1      $f31, 0x80($sp)
9d03747c  mfc1      $a3, $f3
9d037480  swc1      $f31, 0x28($sp)
9d037484  swc1      $f3, 0x20($sp)
9d037488  b         0x9d0370bc
9d03748c  swc1      $f18, 0x24($sp)
9d037490  b         0x9d037000
9d037494  move      $v1, $zero
9d037498  b         0x9d0372e0
9d03749c  move      $v1, $zero
9d0374a0  b         0x9d0371c8
9d0374a4  sw        $zero, 0x84($a2)
9d0374a8  b         0x9d037248
9d0374ac  sw        $zero, 0x6c($a2)
9d0374b0  mtc1      $zero, $f0
9d0374b4  sltiu     $v0, $a1, 3