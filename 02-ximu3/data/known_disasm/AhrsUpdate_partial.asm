9d0391d0  lw        $t0, 8($a0)
9d0391d4  addiu     $sp, $sp, -0xa0
9d0391d8  addiu     $v1, $zero, 3  ; 3
9d0391dc  sw        $ra, 0x9c($sp)
9d0391e0  sw        $a1, 0xa4($sp)
9d0391e4  sw        $a2, 0xa8($sp)
9d0391e8  sw        $a3, 0xac($sp)
9d0391ec  bne       $t0, $v1, 0x9d0394c4
9d0391f0  addiu     $v0, $zero, 1  ; 1
9d0391f4  lw        $a1, 0x90($a0)
9d0391f8  addiu     $a2, $zero, 2  ; 2
9d0391fc  beql      $a1, $a2, 0x9d0397d8
9d039200  lw        $t2, 0xa0($a0)
9d039204  lw        $a3, 4($a0)
9d039208  beql      $a3, $v0, 0x9d039978
9d03920c  lui       $v0, 0x9d08
9d039210  beql      $a3, $zero, 0x9d03995c
9d039214  lui       $a3, 0x9d08
9d039218  beq       $a3, $a2, 0x9d03995c
9d03921c  lui       $a3, 0x9d08
9d039220  mtc1      $zero, $f9
9d039224  mov.s     $f8, $f9
9d039228  mov.s     $f7, $f9
9d03922c  swc1      $f9, 0x80($sp)
9d039230  swc1      $f9, 0x84($sp)
9d039234  swc1      $f9, 0x88($sp)
9d039238  lwc1      $f2, 0xb0($sp)
9d03923c  lwc1      $f1, 0xb4($sp)
9d039240  lwc1      $f11, 0xb8($sp)
9d039244  lbu       $t5, 0x18($a0)
9d039248  move      $a2, $a0
9d03924c  lw        $t0, 0xa4($sp)
9d039250  lw        $t1, 0xa8($sp)
9d039254  lw        $t2, 0xac($sp)
9d039258  swc1      $f2, 0x48($a0)
9d03925c  swc1      $f1, 0x4c($a0)
9d039260  beqz      $t5, 0x9d0392a0
9d039264  swc1      $f11, 0x50($a0)
9d039268  lwc1      $f0, 0x1c($a0)
9d03926c  ext       $a0, $t0, 0, 0x1f
9d039270  mtc1      $a0, $f3
9d039274  c.le.s    $f3, $f0
9d039278  bc1f      0x9d039290
9d03927c  ext       $t6, $t1, 0, 0x1f
9d039280  mtc1      $t6, $f4
9d039284  c.le.s    $f8, $f0
9d039288  bc1t      $fcc1, 0x9d039800
9d03928c  ext       $t7, $t2, 0, 0x1f
9d039290  jal       0x9d08252c
9d039294  move      $a0, $a2
9d039298  addiu     $t8, $zero, 1  ; 1
9d03929c  sb        $t8, 0x5c($a2)
9d0392a0  lbu       $t9, 0x54($a2)
9d0392a4  beqz      $t9, 0x9d0392d8
9d0392a8  lui       $ra, 0x9d08
9d0392ac  lwc1      $f6, 0x58($a2)
9d0392b0  lwc1      $f10, 0x14($a2)
9d0392b4  lwc1      $f12, 0xc($a2)
9d0392b8  sub.s     $f13, $f6, $f10
9d0392bc  c.lt.s    $f24, $f26  ; cc=3
9d0392c0  bc1t      $fcc3, 0x9d0392d8
9d0392c4  swc1      $f13, 0x58($a2)
9d0392c8  sb        $zero, 0x54($a2)
9d0392cc  sb        $zero, 0x5c($a2)
9d0392d0  move      $t9, $zero
9d0392d4  lui       $ra, 0x9d08
9d0392d8  lwc1      $f14, 0x5b7c($ra)
9d0392dc  mtc1      $t0, $f15
9d0392e0  mtc1      $t1, $f17
9d0392e4  mtc1      $t2, $f19
9d0392e8  mul.s     $f16, $f15, $f14
9d0392ec  mul.s     $f18, $f17, $f14
9d0392f0  mul.s     $f21, $f19, $f14
9d0392f4  lw        $v1, 4($a2)
9d0392f8  sltiu     $a1, $v1, 2
9d0392fc  swc1      $f16, 0x74($sp)
9d039300  swc1      $f18, 0x78($sp)
9d039304  bnez      $a1, 0x9d03984c
9d039308  swc1      $f21, 0x7c($sp)
9d03930c  addiu     $t3, $zero, 2  ; 2
9d039310  beql      $v1, $t3, 0x9d039890
9d039314  lwc1      $f10, 0x38($a2)
9d039318  mtc1      $zero, $f23
9d03931c  mfc1      $a0, $f23
9d039320  mov.s     $f25, $f23
9d039324  swc1      $f23, 0x68($sp)
9d039328  swc1      $f23, 0x6c($sp)
9d03932c  swc1      $f23, 0x70($sp)
9d039330  mtc1      $zero, $f27
9d039334  addiu     $t1, $zero, 1  ; 1
9d039338  c.eq.s    $f5, $f22  ; cc=6
9d03933c  bc1f      $fcc4, 0x9d0394d0
9d039340  sb        $t1, 0x74($a2)
9d039344  c.eq.s    $f3, $f22  ; cc=6
9d039348  bc1fl     $fcc5, 0x9d0394d4
9d03934c  mul.s     $f29, $f1, $f1
9d039350  c.eq.s    $f23, $f22  ; cc=6
9d039354  bc1fl     $fcc6, 0x9d0394d4
9d039358  mul.s     $f29, $f1, $f1
9d03935c  swc1      $f27, 0x5c($sp)
9d039360  swc1      $f27, 0x60($sp)
9d039364  swc1      $f27, 0x64($sp)
9d039368  mtc1      $zero, $f14
9d03936c  addiu     $t8, $zero, 1  ; 1
9d039370  c.eq.s    $f15, $f28  ; cc=3
9d039374  bc1f      $fcc4, 0x9d03961c
9d039378  sb        $t8, 0x8c($a2)
9d03937c  c.eq.s    $f17, $f28  ; cc=3
9d039380  bc1fl     $fcc5, 0x9d039620
9d039384  mul.s     $f12, $f9, $f25
9d039388  c.eq.s    $f19, $f28  ; cc=3
9d03938c  bc1fl     $fcc6, 0x9d039620
9d039390  mul.s     $f12, $f9, $f25
9d039394  mov.s     $f19, $f14
9d039398  mov.s     $f21, $f14
9d03939c  lwc1      $f9, 0x5c($sp)
9d0393a0  lwc1      $f27, 0x60($sp)
9d0393a4  beqz      $t9, 0x9d0397b4
9d0393a8  lwc1      $f8, 0x64($sp)
9d0393ac  add.s     $f5, $f21, $f9
9d0393b0  add.s     $f11, $f19, $f27
9d0393b4  add.s     $f13, $f14, $f8
9d0393b8  lwc1      $f0, 0x58($a2)
9d0393bc  mul.s     $f25, $f5, $f0
9d0393c0  mul.s     $f10, $f11, $f0
9d0393c4  mul.s     $f2, $f13, $f0
9d0393c8  lwc1      $f3, 0x7c($sp)
9d0393cc  lwc1      $f14, ($a2)
9d0393d0  lwc1      $f1, 0x74($sp)
9d0393d4  add.s     $f4, $f2, $f3
9d0393d8  lwc1      $f17, 0x78($sp)
9d0393dc  add.s     $f12, $f25, $f1
9d0393e0  lwc1      $f15, 0x40($a2)
9d0393e4  mul.s     $f16, $f4, $f14
9d0393e8  add.s     $f18, $f10, $f17
9d0393ec  mul.s     $f19, $f12, $f14
9d0393f0  lwc1      $f21, 0x38($a2)
9d0393f4  lwc1      $f27, 0x44($a2)
9d0393f8  mul.s     $f8, $f18, $f14
9d0393fc  lwc1      $f7, 0x3c($a2)
9d039400  mul.s     $f9, $f16, $f15
9d039404  lwc1      $f10, 0x3c($a2)
9d039408  lw        $t7, 0x3c($a2)
9d03940c  lui       $t9, 0x8000
9d039410  mul.s     $f29, $f16, $f7
9d039414  mul.s     $f6, $f8, $f15
9d039418  mul.s     $f23, $f8, $f27
9d03941c  madd.s    $f25, $f9, $f19, $f21
9d039420  mul.s     $f11, $f8, $f10
9d039424  xor       $t8, $t7, $t9
9d039428  mtc1      $t8, $f2
9d03942c  mul.s     $f31, $f16, $f27
9d039430  msub.s    $f13, $f6, $f2, $f19
9d039434  lwc1      $f3, 0x3c($a2)
9d039438  sub.s     $f4, $f25, $f23
9d03943c  msub.s    $f14, $f29, $f8, $f21
9d039440  madd.s    $f0, $f11, $f16, $f21
9d039444  mul.s     $f12, $f19, $f15
9d039448  add.s     $f16, $f4, $f3
9d03944c  sub.s     $f17, $f13, $f31
9d039450  lwc1      $f5, 0x5b5c($a3)
9d039454  move      $v0, $zero
9d039458  mul.s     $f18, $f16, $f16
9d03945c  madd.s    $f1, $f14, $f19, $f27
9d039460  add.s     $f19, $f17, $f21
9d039464  sub.s     $f21, $f0, $f12
9d039468  madd.s    $f8, $f18, $f19, $f19
9d03946c  add.s     $f15, $f1, $f15
9d039470  add.s     $f27, $f21, $f27
9d039474  bc3tl     $cc3, 0x9d057df8
9d039478  madd.s    $f7, $f9, $f27, $f27
9d03947c  sqrt.s    $f29, $f7
9d039480  div.s     $f31, $f5, $f29
9d039484  mul.s     $f6, $f19, $f31
9d039488  mul.s     $f23, $f16, $f31
9d03948c  mul.s     $f25, $f15, $f31
9d039490  mul.s     $f10, $f27, $f31
9d039494  swc1      $f6, 0x10($sp)
9d039498  swc1      $f23, 0x14($sp)
9d03949c  swc1      $f25, 0x18($sp)
9d0394a0  swc1      $f10, 0x1c($sp)
9d0394a4  lw        $a3, 0x10($sp)
9d0394a8  lw        $t2, 0x14($sp)
9d0394ac  lw        $v1, 0x18($sp)
9d0394b0  lw        $ra, 0x1c($sp)
9d0394b4  sw        $a3, 0x38($a2)
9d0394b8  sw        $t2, 0x3c($a2)
9d0394bc  sw        $v1, 0x40($a2)
9d0394c0  sw        $ra, 0x44($a2)
9d0394c4  lw        $ra, 0x9c($sp)
9d0394c8  jr        $ra
9d0394cc  addiu     $sp, $sp, 0xa0
9d0394d0  mul.s     $f29, $f1, $f1
9d0394d4  lwc1      $f31, 0x5b5c($a3)
9d0394d8  mtc1      $zero, $f3
9d0394dc  madd.s    $f0, $f29, $f2, $f2
9d0394e0  madd.s    $f4, $f0, $f11, $f11
9d0394e4  sqrt.s    $f5, $f4
9d0394e8  div.s     $f10, $f31, $f5
9d0394ec  mul.s     $f1, $f10, $f1
9d0394f0  mul.s     $f6, $f10, $f11
9d0394f4  mtc1      $a0, $f11
9d0394f8  mul.s     $f2, $f2, $f10
9d0394fc  mul.s     $f13, $f1, $f11
9d039500  mul.s     $f15, $f6, $f11
9d039504  mul.s     $f16, $f1, $f25
9d039508  mul.s     $f14, $f2, $f23
9d03950c  madd.s    $f17, $f13, $f2, $f25
9d039510  msub.s    $f19, $f15, $f1, $f23
9d039514  msub.s    $f27, $f16, $f2, $f11
9d039518  madd.s    $f29, $f17, $f6, $f23
9d03951c  c.lt.s    $f7, $f26  ; cc=7
9d039520  bc1t      $fcc7, 0x9d03957c
9d039524  msub.s    $f18, $f14, $f6, $f25
9d039528  c.eq.s    $f19, $f3
9d03952c  bc1fl     0x9d03955c
9d039530  mul.s     $f31, $f18, $f18
9d039534  c.eq.s    $f4, $f7
9d039538  bc1fl     $fcc1, 0x9d03955c
9d03953c  mul.s     $f31, $f18, $f18
9d039540  c.eq.s    $f22, $f7
9d039544  bc1fl     $fcc2, 0x9d03955c
9d039548  mul.s     $f31, $f18, $f18
9d03954c  swc1      $f3, 0x10($sp)
9d039550  swc1      $f3, 0x14($sp)
9d039554  b         0x9d039588
9d039558  swc1      $f3, 0x18($sp)
9d03955c  lwc1      $f3, 0x5b5c($a3)
9d039560  madd.s    $f0, $f31, $f19, $f19
9d039564  madd.s    $f4, $f0, $f27, $f27
9d039568  sqrt.s    $f5, $f4
9d03956c  div.s     $f10, $f3, $f5
9d039570  mul.s     $f19, $f10, $f19
9d039574  mul.s     $f18, $f10, $f18
9d039578  mul.s     $f27, $f10, $f27
9d03957c  swc1      $f19, 0x10($sp)
9d039580  swc1      $f18, 0x14($sp)
9d039584  swc1      $f27, 0x18($sp)
9d039588  lw        $t6, 0x10($sp)
9d03958c  lw        $t7, 0x14($sp)
9d039590  lw        $t8, 0x18($sp)
9d039594  lbu       $t2, 0x20($a2)
9d039598  sw        $t6, 0x60($a2)
9d03959c  sw        $t7, 0x64($a2)
9d0395a0  beqz      $t2, 0x9d039948
9d0395a4  sw        $t8, 0x68($a2)
9d0395a8  beqz      $t9, 0x9d039818
9d0395ac  lw        $ra, 0x6c($a2)
9d0395b0  addiu     $v0, $ra, -9
9d0395b4  sb        $zero, 0x74($a2)
9d0395b8  sw        $v0, 0x6c($a2)
9d0395bc  lw        $a1, 0x70($a2)
9d0395c0  slt       $t4, $a1, $v0
9d0395c4  beqz      $t4, 0x9d03999c
9d0395c8  lw        $t3, 0x30($a2)
9d0395cc  sw        $zero, 0x70($a2)
9d0395d0  bltz      $v0, 0x9d039ac0
9d0395d4  sb        $zero, 0x74($a2)
9d0395d8  slt       $a0, $t3, $v0
9d0395dc  movn      $v0, $t3, $a0
9d0395e0  sw        $v0, 0x6c($a2)
9d0395e4  mtc1      $zero, $f14
9d0395e8  lw        $t1, 0x60($a2)
9d0395ec  lw        $t6, 0x64($a2)
9d0395f0  lw        $t7, 0x68($a2)
9d0395f4  c.eq.s    $f15, $f28  ; cc=3
9d0395f8  addiu     $t8, $zero, 1  ; 1
9d0395fc  lwc1      $f25, 0x68($sp)
9d039600  lw        $a0, 0x6c($sp)
9d039604  lwc1      $f23, 0x70($sp)
9d039608  sw        $t1, 0x5c($sp)
9d03960c  sw        $t6, 0x60($sp)
9d039610  sw        $t7, 0x64($sp)
9d039614  bc1t      $fcc4, 0x9d03937c
9d039618  sb        $t8, 0x8c($a2)
9d03961c  mul.s     $f12, $f9, $f25
9d039620  mtc1      $a0, $f16
9d039624  mul.s     $f15, $f8, $f23
9d039628  mul.s     $f17, $f7, $f16
9d03962c  lwc1      $f18, 0x5b5c($a3)
9d039630  addiu     $t2, $zero, 1  ; 1
9d039634  msub.s    $f7, $f12, $f7, $f23
9d039638  msub.s    $f9, $f15, $f9, $f16
9d03963c  msub.s    $f8, $f17, $f8, $f25
9d039640  mul.s     $f21, $f7, $f7
9d039644  madd.s    $f27, $f21, $f9, $f9
9d039648  madd.s    $f29, $f27, $f8, $f8
9d03964c  sqrt.s    $f31, $f29
9d039650  div.s     $f3, $f18, $f31
9d039654  mul.s     $f23, $f9, $f3
9d039658  mul.s     $f0, $f7, $f3
9d03965c  beq       $v1, $t2, 0x9d0399d4
9d039660  mul.s     $f25, $f8, $f3
9d039664  beqz      $v1, 0x9d039a6c
9d039668  addiu     $t5, $zero, 2  ; 2
9d03966c  beql      $v1, $t5, 0x9d039a24
9d039670  lwc1      $f6, 0x38($a2)
9d039674  mtc1      $zero, $f16
9d039678  sw        $zero, 0x90($sp)
9d03967c  mfc1      $t1, $f16
9d039680  mul.s     $f17, $f0, $f16
9d039684  mtc1      $t1, $f9
9d039688  lwc1      $f31, 0x90($sp)
9d03968c  mul.s     $f7, $f0, $f9
9d039690  lwc1      $f19, 0x90($sp)
9d039694  mul.s     $f18, $f25, $f16
9d039698  mtc1      $zero, $f27
9d03969c  madd.s    $f29, $f17, $f23, $f9
9d0396a0  mul.s     $f21, $f23, $f19
9d0396a4  msub.s    $f1, $f7, $f23, $f16
9d0396a8  msub.s    $f0, $f18, $f0, $f31
9d0396ac  madd.s    $f23, $f29, $f25, $f31
9d0396b0  c.lt.s    $f23, $f15  ; cc=5
9d0396b4  bc1t      $fcc7, 0x9d0396f8
9d0396b8  msub.s    $f3, $f21, $f25, $f9
9d0396bc  c.eq.s    $f0, $f27
9d0396c0  bc1fl     0x9d0396d8
9d0396c4  mul.s     $f25, $f3, $f3
9d0396c8  c.eq.s    $f6, $f22  ; cc=6
9d0396cc  bc1t      $fcc1, 0x9d039aa8
9d0396d0  c.eq.s    $f2, $f22  ; cc=6
9d0396d4  mul.s     $f25, $f3, $f3
9d0396d8  lwc1      $f5, 0x5b5c($a3)
9d0396dc  madd.s    $f10, $f25, $f0, $f0
9d0396e0  madd.s    $f2, $f10, $f1, $f1
9d0396e4  sqrt.s    $f11, $f2
9d0396e8  div.s     $f13, $f5, $f11
9d0396ec  mul.s     $f0, $f13, $f0
9d0396f0  mul.s     $f3, $f13, $f3
9d0396f4  mul.s     $f1, $f13, $f1
9d0396f8  swc1      $f0, 0x10($sp)
9d0396fc  swc1      $f3, 0x14($sp)
9d039700  swc1      $f1, 0x18($sp)
9d039704  lw        $t6, 0x10($sp)
9d039708  lw        $t7, 0x14($sp)
9d03970c  lw        $t8, 0x18($sp)
9d039710  lbu       $t2, 0x28($a2)
9d039714  sw        $t6, 0x78($a2)
9d039718  sw        $t7, 0x7c($a2)
9d03971c  beqz      $t2, 0x9d039928
9d039720  sw        $t8, 0x80($a2)
9d039724  bnez      $t9, 0x9d0398e0
9d039728  lw        $v1, 0x84($a2)
9d03972c  lwc1      $f4, 0x7c($a2)
9d039730  lwc1      $f14, 0x78($a2)
9d039734  lwc1      $f12, 0x80($a2)
9d039738  mul.s     $f15, $f4, $f4
9d03973c  lwc1      $f16, 0x2c($a2)
9d039740  madd.s    $f17, $f15, $f14, $f14
9d039744  madd.s    $f18, $f17, $f12, $f12
9d039748  c.le.s    $f4, $f1  ; cc=4
9d03974c  bc1t      $fcc3, 0x9d0398e4
9d039750  lw        $ra, 0x88($a2)
9d039754  addiu     $t0, $v1, 1
9d039758  sw        $t0, 0x84($a2)
9d03975c  slt       $t3, $ra, $t0
9d039760  beqz      $t3, 0x9d0398fc
9d039764  lw        $a1, 0x30($a2)
9d039768  sw        $zero, 0x88($a2)
9d03976c  bltz      $t0, 0x9d039ad8
9d039770  sb        $zero, 0x8c($a2)
9d039774  slt       $a0, $a1, $t0
9d039778  movn      $t0, $a1, $a0
9d03977c  sw        $t0, 0x84($a2)
9d039780  lw        $t1, 0x78($a2)
9d039784  lw        $t6, 0x7c($a2)
9d039788  lw        $v0, 0x80($a2)
9d03978c  sw        $t1, 0x50($sp)
9d039790  sw        $t6, 0x54($sp)
9d039794  sw        $v0, 0x58($sp)
9d039798  lwc1      $f21, 0x50($sp)
9d03979c  lwc1      $f19, 0x54($sp)
9d0397a0  lwc1      $f14, 0x58($sp)
9d0397a4  lwc1      $f9, 0x5c($sp)
9d0397a8  lwc1      $f27, 0x60($sp)
9d0397ac  bnez      $t9, 0x9d0393ac
9d0397b0  lwc1      $f8, 0x64($sp)
9d0397b4  lwc1      $f7, 0x10($a2)
9d0397b8  lwc1      $f29, 0xc($a2)
9d0397bc  mul.s     $f31, $f7, $f21
9d0397c0  mul.s     $f6, $f7, $f19
9d0397c4  mul.s     $f23, $f7, $f14
9d0397c8  madd.s    $f25, $f31, $f29, $f9
9d0397cc  madd.s    $f10, $f6, $f29, $f27
9d0397d0  b         0x9d0393c8
9d0397d4  madd.s    $f2, $f23, $f29, $f8
9d0397d8  lw        $t3, 0xa4($a0)
9d0397dc  lw        $t4, 0xa8($a0)
9d0397e0  sw        $t2, 0x80($sp)
9d0397e4  sw        $t3, 0x84($sp)
9d0397e8  sw        $t4, 0x88($sp)
9d0397ec  lwc1      $f7, 0x80($sp)
9d0397f0  lwc1      $f8, 0x84($sp)
9d0397f4  lwc1      $f9, 0x88($sp)
9d0397f8  b         0x9d039238
9d0397fc  lui       $a3, 0x9d08
9d039800  mtc1      $t7, $f5
9d039804  c.le.s    $f10, $f0
9d039808  bc1f      $fcc2, 0x9d039290
9d03980c  nop       
9d039810  b         0x9d0392a4
9d039814  lbu       $t9, 0x54($a2)
9d039818  lwc1      $f23, 0x64($a2)
9d03981c  lwc1      $f25, 0x60($a2)
9d039820  lwc1      $f6, 0x68($a2)
9d039824  mul.s     $f1, $f23, $f23
9d039828  lwc1      $f2, 0x24($a2)
9d03982c  madd.s    $f11, $f1, $f25, $f25
9d039830  madd.s    $f13, $f11, $f6, $f6
9d039834  c.le.s    $f26, $f4
9d039838  bc1tl     $fcc3, 0x9d0395b4
9d03983c  addiu     $v0, $ra, -9
9d039840  addiu     $v0, $ra, 1
9d039844  b         0x9d0395bc
9d039848  sw        $v0, 0x6c($a2)
9d03984c  lui       $v0, 0x9d08
9d039850  lwc1      $f23, 0x38($a2)
9d039854  lwc1      $f25, 0x3c($a2)
9d039858  lwc1      $f27, 0x40($a2)
9d03985c  lwc1      $f0, 0x5b54($v0)
9d039860  mul.s     $f29, $f25, $f23
9d039864  mul.s     $f31, $f23, $f27
9d039868  msub.s    $f4, $f0, $f23, $f23
9d03986c  lwc1      $f3, 0x44($a2)
9d039870  madd.s    $f5, $f29, $f3, $f27
9d039874  msub.s    $f25, $f31, $f25, $f3
9d039878  madd.s    $f23, $f4, $f3, $f3
9d03987c  mfc1      $a0, $f5
9d039880  swc1      $f5, 0x6c($sp)
9d039884  swc1      $f25, 0x68($sp)
9d039888  b         0x9d039330
9d03988c  swc1      $f23, 0x70($sp)
9d039890  lwc1      $f6, 0x3c($a2)
9d039894  lwc1      $f13, 0x44($a2)
9d039898  mul.s     $f12, $f10, $f10
9d03989c  mul.s     $f14, $f10, $f6
9d0398a0  mul.s     $f15, $f6, $f13
9d0398a4  lwc1      $f16, 0x40($a2)
9d0398a8  lui       $t5, 0x9d08
9d0398ac  mul.s     $f17, $f13, $f13
9d0398b0  lwc1      $f19, 0x5b54($t5)
9d0398b4  lui       $t0, 0x8000
9d0398b8  madd.s    $f18, $f14, $f16, $f13
9d0398bc  sub.s     $f21, $f19, $f12
9d0398c0  msub.s    $f25, $f15, $f10, $f16
9d0398c4  sub.s     $f23, $f21, $f17
9d0398c8  mfc1      $t4, $f18
9d0398cc  xor       $a0, $t4, $t0
9d0398d0  sw        $a0, 0x6c($sp)
9d0398d4  swc1      $f25, 0x68($sp)
9d0398d8  b         0x9d039330
9d0398dc  swc1      $f23, 0x70($sp)
9d0398e0  lw        $ra, 0x88($a2)
9d0398e4  addiu     $t0, $v1, -9
9d0398e8  sb        $zero, 0x8c($a2)
9d0398ec  slt       $t3, $ra, $t0
9d0398f0  sw        $t0, 0x84($a2)
9d0398f4  bnez      $t3, 0x9d039768
9d0398f8  lw        $a1, 0x30($a2)
9d0398fc  sw        $a1, 0x88($a2)
9d039900  bltz      $t0, 0x9d039ac8
9d039904  lbu       $t4, 0x8c($a2)
9d039908  slt       $t5, $a1, $t0
9d03990c  movn      $t0, $a1, $t5
9d039910  beqz      $t4, 0x9d039780
9d039914  sw        $t0, 0x84($a2)
9d039918  mtc1      $zero, $f14
9d03991c  mov.s     $f19, $f14
9d039920  b         0x9d03939c
9d039924  mov.s     $f21, $f14
9d039928  sw        $t6, 0x50($sp)
9d03992c  sw        $t7, 0x54($sp)
9d039930  sw        $t8, 0x58($sp)
9d039934  sb        $zero, 0x8c($a2)
9d039938  lwc1      $f21, 0x50($sp)
9d03993c  lwc1      $f19, 0x54($sp)
9d039940  b         0x9d03939c
9d039944  lwc1      $f14, 0x58($sp)
9d039948  sb        $zero, 0x74($a2)
9d03994c  sw        $t6, 0x5c($sp)
9d039950  sw        $t7, 0x60($sp)
9d039954  b         0x9d039368
9d039958  sw        $t8, 0x64($sp)
9d03995c  lwc1      $f7, 0x5b5c($a3)
9d039960  mtc1      $zero, $f9
9d039964  swc1      $f7, 0x80($sp)
9d039968  swc1      $f9, 0x84($sp)
9d03996c  swc1      $f9, 0x88($sp)
9d039970  b         0x9d039238
9d039974  mov.s     $f8, $f9
9d039978  lui       $t1, 0x9d08
9d03997c  lwc1      $f7, 0x5b74($v0)
9d039980  lwc1      $f8, 0x5b78($t1)
9d039984  lui       $a3, 0x9d08
9d039988  mov.s     $f9, $f7
9d03998c  swc1      $f7, 0x80($sp)
9d039990  swc1      $f8, 0x84($sp)
9d039994  b         0x9d039238
9d039998  swc1      $f7, 0x88($sp)
9d03999c  sw        $t3, 0x70($a2)
9d0399a0  bltz      $v0, 0x9d039ad0
9d0399a4  lbu       $t5, 0x74($a2)
9d0399a8  slt       $t0, $t3, $v0
9d0399ac  movn      $v0, $t3, $t0
9d0399b0  beqz      $t5, 0x9d0395e4
9d0399b4  sw        $v0, 0x6c($a2)
9d0399b8  sw        $zero, 0x5c($sp)
9d0399bc  sw        $zero, 0x60($sp)
9d0399c0  sw        $zero, 0x64($sp)
9d0399c4  lwc1      $f25, 0x68($sp)
9d0399c8  lw        $a0, 0x6c($sp)
9d0399cc  b         0x9d039368
9d0399d0  lwc1      $f23, 0x70($sp)
9d0399d4  lwc1      $f5, 0x38($a2)
9d0399d8  lwc1      $f4, 0x40($a2)
9d0399dc  lwc1      $f6, 0x3c($a2)
9d0399e0  mul.s     $f10, $f5, $f5
9d0399e4  mul.s     $f1, $f5, $f4
9d0399e8  lwc1      $f2, 0x44($a2)
9d0399ec  lui       $v1, 0x9d08
9d0399f0  mul.s     $f11, $f6, $f6
9d0399f4  lwc1      $f14, 0x5b54($v1)
9d0399f8  mul.s     $f13, $f6, $f4
9d0399fc  lui       $a1, 0x8000
9d039a00  madd.s    $f15, $f1, $f6, $f2
9d039a04  sub.s     $f12, $f14, $f10
9d039a08  sub.s     $f16, $f12, $f11
9d039a0c  mfc1      $ra, $f15
9d039a10  xor       $t3, $ra, $a1
9d039a14  mfc1      $t1, $f16
9d039a18  sw        $t3, 0x90($sp)
9d039a1c  b         0x9d039680
9d039a20  msub.s    $f16, $f13, $f5, $f2
9d039a24  lwc1      $f5, 0x44($a2)
9d039a28  lwc1      $f3, 0x40($a2)
9d039a2c  lwc1      $f2, 0x3c($a2)
9d039a30  mul.s     $f1, $f6, $f5
9d039a34  mul.s     $f13, $f3, $f5
9d039a38  mul.s     $f10, $f6, $f6
9d039a3c  lui       $t0, 0x9d08
9d039a40  mul.s     $f11, $f3, $f3
9d039a44  lwc1      $f4, 0x5b54($t0)
9d039a48  lui       $v0, 0x8000
9d039a4c  madd.s    $f12, $f1, $f2, $f3
9d039a50  msub.s    $f15, $f13, $f2, $f6
9d039a54  sub.s     $f14, $f4, $f10
9d039a58  sub.s     $f16, $f14, $f11
9d039a5c  mfc1      $a0, $f12
9d039a60  swc1      $f15, 0x90($sp)
9d039a64  b         0x9d039680
9d039a68  xor       $t1, $a0, $v0
9d039a6c  lwc1      $f17, 0x38($a2)
9d039a70  lwc1      $f18, 0x3c($a2)
9d039a74  lwc1      $f19, 0x44($a2)
9d039a78  lui       $t4, 0x9d08
9d039a7c  mul.s     $f9, $f18, $f17
9d039a80  mul.s     $f7, $f17, $f19
9d039a84  lwc1      $f27, 0x40($a2)
9d039a88  lwc1      $f8, 0x5b54($t4)
9d039a8c  bc3t      $cc4, 0x9d01d030
9d039a90  msub.s    $f29, $f9, $f27, $f19
9d039a94  madd.s    $f31, $f7, $f18, $f27
9d039a98  madd.s    $f16, $f21, $f27, $f27
9d039a9c  swc1      $f29, 0x90($sp)
9d039aa0  b         0x9d039680
9d039aa4  mfc1      $t1, $f31
9d039aa8  bc1fl     $fcc2, 0x9d0396d8
9d039aac  mul.s     $f25, $f3, $f3
9d039ab0  swc1      $f27, 0x10($sp)
9d039ab4  swc1      $f27, 0x14($sp)
9d039ab8  b         0x9d039704
9d039abc  swc1      $f27, 0x18($sp)
9d039ac0  b         0x9d0395e4
9d039ac4  sw        $zero, 0x6c($a2)
9d039ac8  b         0x9d039910
9d039acc  move      $t0, $zero
9d039ad0  b         0x9d0399b0
9d039ad4  move      $v0, $zero
9d039ad8  b         0x9d039780
9d039adc  sw        $zero, 0x84($a2)
9d039ae0  lw        $v0, ($a2)
9d039ae4  lw        $t1, 4($a2)
9d039ae8  addiu     $v1, $zero, 0xa  ; 10
9d039aec  beqz      $a1, 0x9d03a074