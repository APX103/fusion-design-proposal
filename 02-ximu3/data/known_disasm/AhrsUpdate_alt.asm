9d041038  lw        $v1, 8($a0)
9d04103c  addiu     $sp, $sp, -0x68
9d041040  addiu     $v0, $zero, 1  ; 1
9d041044  sw        $ra, 0x64($sp)
9d041048  sw        $s0, 0x60($sp)
9d04104c  sw        $a1, 0x6c($sp)
9d041050  sw        $a2, 0x70($sp)
9d041054  bne       $v1, $v0, 0x9d041378
9d041058  sw        $a3, 0x74($sp)
9d04105c  lwc1      $f6, 0x78($sp)
9d041060  lwc1      $f5, 0x7c($sp)
9d041064  lwc1      $f3, 0x80($sp)
9d041068  lbu       $a1, 0x18($a0)
9d04106c  move      $s0, $a0
9d041070  lw        $a2, 0x6c($sp)
9d041074  lw        $a3, 0x70($sp)
9d041078  lw        $t0, 0x74($sp)
9d04107c  swc1      $f6, 0x48($a0)
9d041080  swc1      $f5, 0x4c($a0)
9d041084  beqz      $a1, 0x9d0410d4
9d041088  swc1      $f3, 0x50($a0)
9d04108c  lwc1      $f0, 0x1c($a0)
9d041090  ext       $a0, $a2, 0, 0x1f
9d041094  mtc1      $a0, $f1
9d041098  c.le.s    $f1, $f0
9d04109c  bc1f      0x9d0410c4
9d0410a0  ext       $t1, $a3, 0, 0x1f
9d0410a4  mtc1      $t1, $f2
9d0410a8  c.le.s    $f4, $f0
9d0410ac  bc1f      $fcc1, 0x9d0410c4
9d0410b0  ext       $t2, $t0, 0, 0x1f
9d0410b4  mtc1      $t2, $f4
9d0410b8  c.le.s    $f8, $f0
9d0410bc  bc1tl     $fcc2, 0x9d0410d8
9d0410c0  lbu       $t4, 0x54($s0)
9d0410c4  jal       0x9d08252c
9d0410c8  move      $a0, $s0
9d0410cc  addiu     $t3, $zero, 1  ; 1
9d0410d0  sb        $t3, 0x5c($s0)
9d0410d4  lbu       $t4, 0x54($s0)
9d0410d8  beqz      $t4, 0x9d04110c
9d0410dc  lui       $t5, 0x9d08
9d0410e0  lwc1      $f7, 0x58($s0)
9d0410e4  lwc1      $f8, 0x14($s0)
9d0410e8  lwc1      $f9, 0xc($s0)
9d0410ec  sub.s     $f10, $f7, $f8
9d0410f0  c.lt.s    $f18, $f20  ; cc=2
9d0410f4  bc1t      $fcc3, 0x9d04110c
9d0410f8  swc1      $f10, 0x58($s0)
9d0410fc  sb        $zero, 0x54($s0)
9d041100  sb        $zero, 0x5c($s0)
9d041104  move      $t4, $zero
9d041108  lui       $t5, 0x9d08
9d04110c  lwc1      $f12, 0x5b7c($t5)
9d041110  mtc1      $a2, $f11
9d041114  mtc1      $a3, $f14
9d041118  mtc1      $t0, $f16
9d04111c  mul.s     $f13, $f11, $f12
9d041120  mul.s     $f15, $f14, $f12
9d041124  mul.s     $f17, $f16, $f12
9d041128  lw        $t6, 4($s0)
9d04112c  sltiu     $t7, $t6, 2
9d041130  swc1      $f13, 0x50($sp)
9d041134  swc1      $f15, 0x54($sp)
9d041138  bnez      $t7, 0x9d041564
9d04113c  swc1      $f17, 0x58($sp)
9d041140  addiu     $t9, $zero, 2  ; 2
9d041144  beql      $t6, $t9, 0x9d0415a8
9d041148  lwc1      $f8, 0x38($s0)
9d04114c  mtc1      $zero, $f18
9d041150  mfc1      $a2, $f18
9d041154  mov.s     $f19, $f18
9d041158  swc1      $f18, 0x44($sp)
9d04115c  swc1      $f18, 0x48($sp)
9d041160  swc1      $f18, 0x4c($sp)
9d041164  mtc1      $zero, $f21
9d041168  addiu     $a1, $zero, 1  ; 1
9d04116c  c.eq.s    $f13, $f10  ; cc=5
9d041170  bc1f      $fcc4, 0x9d04138c
9d041174  sb        $a1, 0x74($s0)
9d041178  c.eq.s    $f11, $f10  ; cc=5
9d04117c  bc1fl     $fcc5, 0x9d041390
9d041180  mul.s     $f23, $f5, $f5
9d041184  c.eq.s    $f7, $f10  ; cc=5
9d041188  bc1fl     $fcc6, 0x9d041390
9d04118c  mul.s     $f23, $f5, $f5
9d041190  mov.s     $f10, $f21
9d041194  mov.s     $f9, $f21
9d041198  mov.s     $f3, $f21
9d04119c  swc1      $f21, 0x38($sp)
9d0411a0  swc1      $f21, 0x3c($sp)
9d0411a4  swc1      $f21, 0x40($sp)
9d0411a8  lui       $a1, 0x9d08
9d0411ac  addiu     $a2, $zero, 1  ; 1
9d0411b0  sb        $a2, 0x8c($s0)
9d0411b4  sw        $zero, 0x2c($sp)
9d0411b8  sw        $zero, 0x30($sp)
9d0411bc  beqz      $t4, 0x9d0414fc
9d0411c0  sw        $zero, 0x34($sp)
9d0411c4  mtc1      $zero, $f19
9d0411c8  lwc1      $f18, 0x58($s0)
9d0411cc  add.s     $f21, $f3, $f19
9d0411d0  add.s     $f4, $f9, $f19
9d0411d4  add.s     $f23, $f10, $f19
9d0411d8  mul.s     $f14, $f21, $f18
9d0411dc  mul.s     $f7, $f4, $f18
9d0411e0  mul.s     $f16, $f23, $f18
9d0411e4  add.s     $f25, $f17, $f16
9d0411e8  lwc1      $f27, ($s0)
9d0411ec  add.s     $f29, $f13, $f14
9d0411f0  add.s     $f31, $f15, $f7
9d0411f4  mul.s     $f13, $f25, $f27
9d0411f8  lwc1      $f15, 0x40($s0)
9d0411fc  mul.s     $f17, $f29, $f27
9d041200  mul.s     $f0, $f31, $f27
9d041204  lwc1      $f8, 0x38($s0)
9d041208  lwc1      $f6, 0x44($s0)
9d04120c  lwc1      $f5, 0x3c($s0)
9d041210  mul.s     $f9, $f13, $f15
9d041214  lwc1      $f2, 0x3c($s0)
9d041218  mul.s     $f1, $f13, $f5
9d04121c  mul.s     $f3, $f0, $f15
9d041220  mul.s     $f12, $f0, $f6
9d041224  lw        $a0, 0x3c($s0)
9d041228  lui       $t0, 0x8000
9d04122c  madd.s    $f14, $f9, $f17, $f8
9d041230  mul.s     $f11, $f0, $f2
9d041234  xor       $t1, $a0, $t0
9d041238  mtc1      $t1, $f16
9d04123c  mul.s     $f10, $f13, $f6
9d041240  msub.s    $f19, $f3, $f16, $f17
9d041244  msub.s    $f7, $f1, $f0, $f8
9d041248  sub.s     $f4, $f14, $f12
9d04124c  lwc1      $f29, 0x3c($s0)
9d041250  mul.s     $f18, $f17, $f15
9d041254  madd.s    $f23, $f11, $f13, $f8
9d041258  add.s     $f31, $f4, $f29
9d04125c  sub.s     $f27, $f19, $f10
9d041260  madd.s    $f25, $f7, $f17, $f6
9d041264  lwc1      $f21, 0x5b5c($a1)
9d041268  mul.s     $f17, $f31, $f31
9d04126c  add.s     $f13, $f27, $f8
9d041270  sub.s     $f0, $f23, $f18
9d041274  add.s     $f15, $f25, $f15
9d041278  add.s     $f8, $f0, $f6
9d04127c  madd.s    $f6, $f17, $f13, $f13
9d041280  madd.s    $f9, $f6, $f15, $f15
9d041284  madd.s    $f5, $f9, $f8, $f8
9d041288  sqrt.s    $f1, $f5
9d04128c  div.s     $f12, $f21, $f1
9d041290  mul.s     $f10, $f13, $f12
9d041294  mul.s     $f3, $f31, $f12
9d041298  mul.s     $f14, $f15, $f12
9d04129c  mul.s     $f2, $f8, $f12
9d0412a0  swc1      $f10, 0x10($sp)
9d0412a4  swc1      $f3, 0x14($sp)
9d0412a8  swc1      $f14, 0x18($sp)
9d0412ac  swc1      $f2, 0x1c($sp)
9d0412b0  lw        $a3, 0x10($sp)
9d0412b4  lw        $t2, 0x14($sp)
9d0412b8  lw        $t3, 0x18($sp)
9d0412bc  lw        $t5, 0x1c($sp)
9d0412c0  sw        $a3, 0x38($s0)
9d0412c4  sw        $t2, 0x3c($s0)
9d0412c8  sw        $t3, 0x40($s0)
9d0412cc  beqz      $t4, 0x9d0412e4
9d0412d0  sw        $t5, 0x44($s0)
9d0412d4  lw        $t4, 8($s0)
9d0412d8  addiu     $t6, $zero, 1  ; 1
9d0412dc  beq       $t4, $t6, 0x9d0416dc
9d0412e0  move      $a1, $zero
9d0412e4  lw        $t7, 0x90($s0)
9d0412e8  addiu     $t8, $zero, 1  ; 1
9d0412ec  bne       $t7, $t8, 0x9d041368
9d0412f0  lw        $ra, 0x64($sp)
9d0412f4  lw        $t9, 4($s0)
9d0412f8  beq       $t9, $t7, 0x9d0416a0
9d0412fc  lui       $ra, 0x9d08
9d041300  beqz      $t9, 0x9d041660
9d041304  addiu     $v1, $zero, 2  ; 2
9d041308  beq       $t9, $v1, 0x9d041664
9d04130c  lui       $v0, 0x9d08
9d041310  mtc1      $zero, $f0
9d041314  mov.s     $f6, $f0
9d041318  mov.s     $f9, $f0
9d04131c  swc1      $f0, 0x10($sp)
9d041320  swc1      $f0, 0x14($sp)
9d041324  swc1      $f0, 0x18($sp)
9d041328  lwc1      $f5, 0xa4($s0)
9d04132c  lwc1      $f12, 0xa8($s0)
9d041330  lwc1      $f10, 0xa0($s0)
9d041334  lw        $a1, 0x9c($s0)
9d041338  add.s     $f1, $f6, $f5
9d04133c  add.s     $f14, $f0, $f12
9d041340  add.s     $f3, $f10, $f9
9d041344  lw        $a2, 0x34($s0)
9d041348  addiu     $t0, $a1, 1
9d04134c  swc1      $f1, 0xa4($s0)
9d041350  sltu      $a0, $t0, $a2
9d041354  swc1      $f3, 0xa0($s0)
9d041358  swc1      $f14, 0xa8($s0)
9d04135c  beqz      $a0, 0x9d041550
9d041360  sw        $t0, 0x9c($s0)
9d041364  lw        $ra, 0x64($sp)
9d041368  move      $v0, $zero
9d04136c  lw        $s0, 0x60($sp)
9d041370  jr        $ra
9d041374  addiu     $sp, $sp, 0x68
9d041378  lw        $ra, 0x64($sp)
9d04137c  addiu     $v0, $zero, 1  ; 1
9d041380  lw        $s0, 0x60($sp)
9d041384  jr        $ra
9d041388  addiu     $sp, $sp, 0x68
9d04138c  mul.s     $f23, $f5, $f5
9d041390  lui       $a1, 0x9d08
9d041394  lwc1      $f25, 0x5b5c($a1)
9d041398  mtc1      $zero, $f27
9d04139c  madd.s    $f29, $f23, $f6, $f6
9d0413a0  madd.s    $f31, $f29, $f3, $f3
9d0413a4  sqrt.s    $f0, $f31
9d0413a8  div.s     $f8, $f25, $f0
9d0413ac  mul.s     $f5, $f8, $f5
9d0413b0  mul.s     $f2, $f8, $f3
9d0413b4  mtc1      $a2, $f3
9d0413b8  mul.s     $f6, $f6, $f8
9d0413bc  mul.s     $f1, $f5, $f3
9d0413c0  mul.s     $f12, $f2, $f3
9d0413c4  mul.s     $f11, $f5, $f19
9d0413c8  mul.s     $f10, $f6, $f18
9d0413cc  swc1      $f6, 0x20($sp)
9d0413d0  swc1      $f5, 0x24($sp)
9d0413d4  swc1      $f2, 0x28($sp)
9d0413d8  madd.s    $f14, $f1, $f6, $f19
9d0413dc  msub.s    $f16, $f12, $f5, $f18
9d0413e0  msub.s    $f7, $f10, $f2, $f19
9d0413e4  madd.s    $f18, $f14, $f2, $f18
9d0413e8  c.lt.s    $f23, $f5  ; cc=4
9d0413ec  bc1t      $fcc7, 0x9d041448
9d0413f0  msub.s    $f19, $f11, $f6, $f3
9d0413f4  c.eq.s    $f16, $f27
9d0413f8  bc1fl     0x9d041428
9d0413fc  mul.s     $f21, $f7, $f7
9d041400  c.eq.s    $f14, $f22  ; cc=6
9d041404  bc1fl     $fcc1, 0x9d041428
9d041408  mul.s     $f21, $f7, $f7
9d04140c  c.eq.s    $f6, $f23  ; cc=6
9d041410  bc1fl     $fcc2, 0x9d041428
9d041414  mul.s     $f21, $f7, $f7
9d041418  swc1      $f27, 0x10($sp)
9d04141c  swc1      $f27, 0x14($sp)
9d041420  b         0x9d041454
9d041424  swc1      $f27, 0x18($sp)
9d041428  lwc1      $f23, 0x5b5c($a1)
9d04142c  madd.s    $f25, $f21, $f16, $f16
9d041430  madd.s    $f27, $f25, $f19, $f19
9d041434  sqrt.s    $f29, $f27
9d041438  div.s     $f31, $f23, $f29
9d04143c  mul.s     $f16, $f31, $f16
9d041440  mul.s     $f7, $f31, $f7
9d041444  mul.s     $f19, $f31, $f19
9d041448  swc1      $f16, 0x10($sp)
9d04144c  swc1      $f7, 0x14($sp)
9d041450  swc1      $f19, 0x18($sp)
9d041454  lw        $t0, 0x10($sp)
9d041458  lw        $a0, 0x14($sp)
9d04145c  lw        $t1, 0x18($sp)
9d041460  lbu       $a3, 0x20($s0)
9d041464  sw        $t0, 0x60($s0)
9d041468  sw        $a0, 0x64($s0)
9d04146c  beqz      $a3, 0x9d0415f8
9d041470  sw        $t1, 0x68($s0)
9d041474  beqz      $t4, 0x9d04151c
9d041478  lw        $t2, 0x6c($s0)
9d04147c  addiu     $t8, $t2, -9
9d041480  sb        $zero, 0x74($s0)
9d041484  sw        $t8, 0x6c($s0)
9d041488  lw        $t3, 0x70($s0)
9d04148c  slt       $t5, $t3, $t8
9d041490  beqz      $t5, 0x9d041618
9d041494  lw        $t4, 0x30($s0)
9d041498  sw        $zero, 0x70($s0)
9d04149c  bltz      $t8, 0x9d0416f4
9d0414a0  sb        $zero, 0x74($s0)
9d0414a4  slt       $t9, $t4, $t8
9d0414a8  movn      $t8, $t4, $t9
9d0414ac  sw        $t8, 0x6c($s0)
9d0414b0  lw        $ra, 0x60($s0)
9d0414b4  lw        $v1, 0x64($s0)
9d0414b8  lw        $v0, 0x68($s0)
9d0414bc  lbu       $t4, 0x54($s0)
9d0414c0  sw        $ra, 0x38($sp)
9d0414c4  sw        $v1, 0x3c($sp)
9d0414c8  sw        $v0, 0x40($sp)
9d0414cc  addiu     $a2, $zero, 1  ; 1
9d0414d0  lwc1      $f3, 0x38($sp)
9d0414d4  lwc1      $f9, 0x3c($sp)
9d0414d8  lwc1      $f10, 0x40($sp)
9d0414dc  lwc1      $f13, 0x50($sp)
9d0414e0  lwc1      $f15, 0x54($sp)
9d0414e4  lwc1      $f17, 0x58($sp)
9d0414e8  sb        $a2, 0x8c($s0)
9d0414ec  sw        $zero, 0x2c($sp)
9d0414f0  sw        $zero, 0x30($sp)
9d0414f4  bnez      $t4, 0x9d0411c4
9d0414f8  sw        $zero, 0x34($sp)
9d0414fc  lwc1      $f12, 0x10($s0)
9d041500  mtc1      $zero, $f2
9d041504  lwc1      $f1, 0xc($s0)
9d041508  mul.s     $f11, $f12, $f2
9d04150c  madd.s    $f14, $f11, $f1, $f3
9d041510  madd.s    $f7, $f11, $f1, $f9
9d041514  b         0x9d0411e4
9d041518  madd.s    $f16, $f11, $f1, $f10
9d04151c  lwc1      $f13, 0x64($s0)
9d041520  lwc1      $f15, 0x60($s0)
9d041524  lwc1      $f17, 0x68($s0)
9d041528  mul.s     $f0, $f13, $f13
9d04152c  lwc1      $f8, 0x24($s0)
9d041530  madd.s    $f5, $f0, $f15, $f15
9d041534  madd.s    $f6, $f5, $f17, $f17
9d041538  c.le.s    $f12, $f16  ; cc=2
9d04153c  bc1tl     $fcc3, 0x9d041480
9d041540  addiu     $t8, $t2, -9
9d041544  addiu     $t8, $t2, 1
9d041548  b         0x9d041488
9d04154c  sw        $t8, 0x6c($s0)
9d041550  move      $a0, $s0
9d041554  lw        $ra, 0x64($sp)
9d041558  lw        $s0, 0x60($sp)
9d04155c  j         0x9d07bfa4  ; AhrsInitialiseWindow_Step
9d041560  addiu     $sp, $sp, 0x68
9d041564  lui       $t8, 0x9d08
9d041568  lwc1      $f18, 0x38($s0)
9d04156c  lwc1      $f19, 0x3c($s0)
9d041570  lwc1      $f21, 0x40($s0)
9d041574  lwc1      $f27, 0x5b54($t8)
9d041578  mul.s     $f23, $f19, $f18
9d04157c  mul.s     $f25, $f18, $f21
9d041580  msub.s    $f29, $f27, $f18, $f18
9d041584  lwc1      $f31, 0x44($s0)
9d041588  madd.s    $f0, $f23, $f31, $f21
9d04158c  msub.s    $f19, $f25, $f19, $f31
9d041590  madd.s    $f18, $f29, $f31, $f31
9d041594  mfc1      $a2, $f0
9d041598  swc1      $f0, 0x48($sp)
9d04159c  swc1      $f19, 0x44($sp)
9d0415a0  b         0x9d041164
9d0415a4  swc1      $f18, 0x4c($sp)
9d0415a8  lwc1      $f2, 0x3c($s0)
9d0415ac  lwc1      $f1, 0x44($s0)
9d0415b0  mul.s     $f10, $f8, $f8
9d0415b4  mul.s     $f9, $f8, $f2
9d0415b8  mul.s     $f7, $f2, $f1
9d0415bc  lwc1      $f12, 0x40($s0)
9d0415c0  lui       $v1, 0x9d08
9d0415c4  mul.s     $f4, $f1, $f1
9d0415c8  lwc1      $f14, 0x5b54($v1)
9d0415cc  lui       $v0, 0x8000
9d0415d0  madd.s    $f11, $f9, $f12, $f1
9d0415d4  sub.s     $f16, $f14, $f10
9d0415d8  msub.s    $f19, $f7, $f8, $f12
9d0415dc  sub.s     $f18, $f16, $f4
9d0415e0  mfc1      $ra, $f11
9d0415e4  xor       $a2, $ra, $v0
9d0415e8  sw        $a2, 0x48($sp)
9d0415ec  swc1      $f19, 0x44($sp)
9d0415f0  b         0x9d041164
9d0415f4  swc1      $f18, 0x4c($sp)
9d0415f8  sw        $t0, 0x38($sp)
9d0415fc  sw        $a0, 0x3c($sp)
9d041600  sw        $t1, 0x40($sp)
9d041604  sb        $zero, 0x74($s0)
9d041608  lwc1      $f3, 0x38($sp)
9d04160c  lwc1      $f9, 0x3c($sp)
9d041610  b         0x9d0411ac
9d041614  lwc1      $f10, 0x40($sp)
9d041618  sw        $t4, 0x70($s0)
9d04161c  bltz      $t8, 0x9d0416ec
9d041620  lbu       $t6, 0x74($s0)
9d041624  slt       $t7, $t4, $t8
9d041628  movn      $t8, $t4, $t7
9d04162c  beqz      $t6, 0x9d0414b0
9d041630  sw        $t8, 0x6c($s0)
9d041634  mtc1      $zero, $f10
9d041638  lbu       $t4, 0x54($s0)
9d04163c  swc1      $f10, 0x38($sp)
9d041640  swc1      $f10, 0x3c($sp)
9d041644  swc1      $f10, 0x40($sp)
9d041648  lwc1      $f13, 0x50($sp)
9d04164c  lwc1      $f15, 0x54($sp)
9d041650  lwc1      $f17, 0x58($sp)
9d041654  mov.s     $f9, $f10
9d041658  b         0x9d0411ac
9d04165c  mov.s     $f3, $f10
9d041660  lui       $v0, 0x9d08
9d041664  lwc1      $f25, 0x38($s0)
9d041668  lwc1      $f27, 0x40($s0)
9d04166c  lwc1      $f29, 0x44($s0)
9d041670  lwc1      $f17, 0x5b54($v0)
9d041674  mul.s     $f31, $f25, $f27
9d041678  mul.s     $f13, $f25, $f29
9d04167c  msub.s    $f15, $f17, $f25, $f25
9d041680  lwc1      $f8, 0x3c($s0)
9d041684  madd.s    $f0, $f31, $f8, $f29
9d041688  msub.s    $f6, $f13, $f8, $f27
9d04168c  madd.s    $f9, $f15, $f8, $f8
9d041690  swc1      $f0, 0x18($sp)
9d041694  swc1      $f6, 0x14($sp)
9d041698  b         0x9d041328
9d04169c  swc1      $f9, 0x10($sp)
9d0416a0  lwc1      $f11, 0x38($s0)
9d0416a4  lwc1      $f7, 0x3c($s0)
9d0416a8  lwc1      $f16, 0x44($s0)
9d0416ac  lwc1      $f21, 0x5b54($ra)
9d0416b0  mul.s     $f19, $f7, $f11
9d0416b4  mul.s     $f18, $f11, $f16
9d0416b8  msub.s    $f4, $f21, $f11, $f11
9d0416bc  lwc1      $f23, 0x40($s0)
9d0416c0  msub.s    $f0, $f19, $f23, $f16
9d0416c4  madd.s    $f9, $f18, $f7, $f23
9d0416c8  madd.s    $f6, $f4, $f23, $f23
9d0416cc  swc1      $f0, 0x18($sp)
9d0416d0  swc1      $f9, 0x10($sp)
9d0416d4  b         0x9d041328
9d0416d8  swc1      $f6, 0x14($sp)
9d0416dc  jal       0x9d0708a4
9d0416e0  move      $a0, $s0
9d0416e4  b         0x9d0412e8
9d0416e8  lw        $t7, 0x90($s0)
9d0416ec  b         0x9d04162c
9d0416f0  move      $t8, $zero
9d0416f4  b         0x9d0414b0
9d0416f8  sw        $zero, 0x6c($s0)
9d0416fc  addiu     $sp, $sp, -0x18
9d041700  sw        $ra, ($sp)
9d041704  sw        $s0, 4($sp)