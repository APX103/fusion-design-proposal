9d048164  addiu     $sp, $sp, -0x170
9d048168  sw        $s2, 0x128($sp)
9d04816c  lui       $s2, 0x8008
9d048170  sw        $s0, 0x120($sp)
9d048174  addiu     $s0, $s2, -0x28d8
9d048178  lw        $v0, 0x18($s0)
9d04817c  sw        $s1, 0x124($sp)
9d048180  sw        $ra, 0x134($sp)
9d048184  sw        $s4, 0x130($sp)
9d048188  sw        $s3, 0x12c($sp)
9d04818c  sdc1      $f30, 0x160($sp)
9d048190  sdc1      $f28, 0x158($sp)
9d048194  sdc1      $f26, 0x150($sp)
9d048198  sdc1      $f24, 0x148($sp)
9d04819c  sdc1      $f22, 0x140($sp)
9d0481a0  sdc1      $f20, 0x138($sp)
9d0481a4  beqz      $v0, 0x9d048494
9d0481a8  move      $s1, $a0
9d0481ac  sltiu     $v1, $v0, 2
9d0481b0  bnez      $v1, 0x9d0481c8
9d0481b4  lw        $a0, -0x7db8($gp)
9d0481b8  addiu     $a1, $a0, 1
9d0481bc  sltu      $a2, $a1, $v0
9d0481c0  bnez      $a2, 0x9d0482e8
9d0481c4  sw        $a1, -0x7db8($gp)
9d0481c8  lw        $a3, 4($s0)
9d0481cc  addiu     $t0, $zero, 1  ; 1
9d0481d0  beq       $a3, $t0, 0x9d04858c
9d0481d4  sw        $zero, -0x7db8($gp)
9d0481d8  beqz      $a3, 0x9d048528
9d0481dc  addiu     $t4, $zero, 2  ; 2
9d0481e0  bnel      $a3, $t4, 0x9d0482ec
9d0481e4  lw        $v0, 0x1c($s0)
9d0481e8  lw        $a1, 8($s1)
9d0481ec  addiu     $a0, $sp, 0xd0
9d0481f0  jal       0x9d086e88  ; AhrsGetQuaternion
9d0481f4  lui       $s4, 0x9d09
9d0481f8  lwc1      $f20, 0xd0($sp)
9d0481fc  lwc1      $f22, 0xd4($sp)
9d048200  lwc1      $f24, 0xdc($sp)
9d048204  mul.s     $f30, $f20, $f20
9d048208  mul.s     $f23, $f20, $f22
9d04820c  lwc1      $f25, 0xd8($sp)
9d048210  lwc1      $f27, -0x7d1c($s4)
9d048214  lui       $s3, 0x9d09
9d048218  swc1      $f25, 0x110($sp)
9d04821c  madd.s    $f29, $f30, $f24, $f24
9d048220  madd.s    $f12, $f23, $f25, $f24
9d048224  jal       0x9d05d940  ; atan2f
9d048228  sub.s     $f14, $f29, $f27
9d04822c  mul.s     $f31, $f22, $f24
9d048230  lwc1      $f26, -0x7d18($s3)
9d048234  lwc1      $f3, 0x110($sp)
9d048238  lui       $t5, 0x9d09
9d04823c  mul.s     $f28, $f0, $f26
9d048240  lwc1      $f1, -0x7d14($t5)
9d048244  msub.s    $f0, $f31, $f20, $f3
9d048248  add.s     $f12, $f0, $f0
9d04824c  c.le.s    $f12, $f1
9d048250  bc1t      0x9d0486fc
9d048254  lui       $t6, 0x9d09
9d048258  lwc1      $f2, -0x7d28($t6)
9d04825c  c.le.s    $f4, $f24  ; cc=3
9d048260  bc1f      $fcc1, 0x9d0486e8
9d048264  lui       $t7, 0x9d09
9d048268  lwc1      $f26, -0x7d20($t7)
9d04826c  mul.s     $f4, $f20, $f24
9d048270  madd.s    $f5, $f30, $f22, $f22
9d048274  lwc1      $f8, -0x7d1c($s4)
9d048278  addiu     $s4, $sp, 0x10
9d04827c  madd.s    $f12, $f4, $f22, $f3
9d048280  jal       0x9d05d940  ; atan2f
9d048284  sub.s     $f14, $f5, $f8
9d048288  lwc1      $f7, -0x7d18($s3)
9d04828c  lw        $a1, 4($s1)
9d048290  lw        $a0, ($s1)
9d048294  mul.s     $f20, $f0, $f7
9d048298  swc1      $f28, 0xf4($sp)
9d04829c  swc1      $f26, 0xf8($sp)
9d0482a0  jal       0x9d072394
9d0482a4  swc1      $f20, 0xfc($sp)
9d0482a8  lw        $t9, -0x28d8($s2)
9d0482ac  sw        $v0, 0xa0($sp)
9d0482b0  sw        $v1, 0xa4($sp)
9d0482b4  swc1      $f28, 0xa8($sp)
9d0482b8  swc1      $f26, 0xac($sp)
9d0482bc  swc1      $f20, 0xb0($sp)
9d0482c0  addiu     $a2, $sp, 0xa0
9d0482c4  bnez      $t9, 0x9d0486c8
9d0482c8  addiu     $a1, $zero, 0x3e  ; 62
9d0482cc  jal       0x9d02d030
9d0482d0  move      $a0, $s4
9d0482d4  lw        $a3, -0x7da8($gp)
9d0482d8  lw        $a0, -0x7fcc($gp)
9d0482dc  move      $a2, $v0
9d0482e0  jal       0x9d03e580
9d0482e4  move      $a1, $s4
9d0482e8  lw        $v0, 0x1c($s0)
9d0482ec  beql      $v0, $zero, 0x9d04840c
9d0482f0  sw        $zero, -0x7dbc($gp)
9d0482f4  lw        $ra, 8($s0)
9d0482f8  beqz      $ra, 0x9d048470
9d0482fc  addiu     $v1, $zero, 1  ; 1
9d048300  beql      $ra, $v1, 0x9d048450
9d048304  lw        $a1, 8($s1)
9d048308  sltiu     $a0, $v0, 2
9d04830c  bnel      $a0, $zero, 0x9d04839c
9d048310  lw        $s0, 8($s0)
9d048314  lw        $a1, -0x7dbc($gp)
9d048318  lwc1      $f6, 0x104($sp)
9d04831c  lwc1      $f9, 0x108($sp)
9d048320  lwc1      $f10, 0x10c($sp)
9d048324  beqz      $a1, 0x9d0484a8
9d048328  addiu     $a2, $a1, 1
9d04832c  lui       $a3, 0x8008
9d048330  addiu     $t0, $a3, -0x2248
9d048334  lwc1      $f11, -0x2248($a3)
9d048338  lwc1      $f12, 4($t0)
9d04833c  lwc1      $f13, 8($t0)
9d048340  add.s     $f14, $f6, $f11
9d048344  add.s     $f15, $f9, $f12
9d048348  add.s     $f16, $f10, $f13
9d04834c  sltu      $t1, $a2, $v0
9d048350  swc1      $f14, -0x2248($a3)
9d048354  swc1      $f15, 4($t0)
9d048358  swc1      $f16, 8($t0)
9d04835c  bnez      $t1, 0x9d04840c
9d048360  sw        $a2, -0x7dbc($gp)
9d048364  mtc1      $a2, $f17
9d048368  move      $t2, $zero
9d04836c  lui       $t3, 0x9d09
9d048370  cop1.f00  $f2, $f21  ; cc=2
9d048374  lwc1      $f19, -0x7d28($t3)
9d048378  cop1.f20  $f3, $f1
9d04837c  div.s     $f21, $f19, $f18
9d048380  mul.s     $f22, $f14, $f21
9d048384  mul.s     $f24, $f15, $f21
9d048388  mul.s     $f30, $f16, $f21
9d04838c  swc1      $f22, 0x104($sp)
9d048390  swc1      $f24, 0x108($sp)
9d048394  swc1      $f30, 0x10c($sp)
9d048398  lw        $s0, 8($s0)
9d04839c  beqz      $s0, 0x9d0484d8
9d0483a0  sw        $zero, -0x7dbc($gp)
9d0483a4  addiu     $t4, $zero, 1  ; 1
9d0483a8  bnel      $s0, $t4, 0x9d048410
9d0483ac  lw        $a1, 8($s1)
9d0483b0  lw        $a1, 4($s1)
9d0483b4  lw        $a0, ($s1)
9d0483b8  lwc1      $f24, 0x104($sp)
9d0483bc  lwc1      $f22, 0x108($sp)
9d0483c0  jal       0x9d072394
9d0483c4  lwc1      $f30, 0x10c($sp)
9d0483c8  lw        $s3, -0x28d8($s2)
9d0483cc  sw        $v0, 0xa0($sp)
9d0483d0  sw        $v1, 0xa4($sp)
9d0483d4  swc1      $f24, 0xa8($sp)
9d0483d8  swc1      $f22, 0xac($sp)
9d0483dc  swc1      $f30, 0xb0($sp)
9d0483e0  addiu     $s4, $sp, 0x10
9d0483e4  addiu     $a2, $sp, 0xa0
9d0483e8  bnez      $s3, 0x9d048698
9d0483ec  addiu     $a1, $zero, 0x3e  ; 62
9d0483f0  jal       0x9d02ed30
9d0483f4  move      $a0, $s4
9d0483f8  move      $a2, $v0
9d0483fc  lw        $a3, -0x7da8($gp)
9d048400  lw        $a0, -0x7fd0($gp)
9d048404  jal       0x9d03e580
9d048408  move      $a1, $s4
9d04840c  lw        $a1, 8($s1)
9d048410  jal       0x9d06ecf8
9d048414  move      $a0, $s1
9d048418  lw        $ra, 0x134($sp)
9d04841c  lw        $s4, 0x130($sp)
9d048420  lw        $s3, 0x12c($sp)
9d048424  lw        $s2, 0x128($sp)
9d048428  lw        $s1, 0x124($sp)
9d04842c  lw        $s0, 0x120($sp)
9d048430  ldc1      $f30, 0x160($sp)
9d048434  ldc1      $f28, 0x158($sp)
9d048438  ldc1      $f26, 0x150($sp)
9d04843c  ldc1      $f24, 0x148($sp)
9d048440  ldc1      $f22, 0x140($sp)
9d048444  ldc1      $f20, 0x138($sp)
9d048448  jr        $ra
9d04844c  addiu     $sp, $sp, 0x170
9d048450  jal       0x9d07396c
9d048454  addiu     $a0, $sp, 0x104
9d048458  lw        $v0, 0x1c($s0)
9d04845c  sltiu     $a0, $v0, 2
9d048460  beqz      $a0, 0x9d048318
9d048464  lw        $a1, -0x7dbc($gp)
9d048468  b         0x9d04839c
9d04846c  lw        $s0, 8($s0)
9d048470  lw        $a1, 8($s1)
9d048474  jal       0x9d082584
9d048478  addiu     $a0, $sp, 0x104
9d04847c  lw        $v0, 0x1c($s0)
9d048480  sltiu     $a0, $v0, 2
9d048484  beqz      $a0, 0x9d048318
9d048488  lw        $a1, -0x7dbc($gp)
9d04848c  b         0x9d04839c
9d048490  lw        $s0, 8($s0)
9d048494  lw        $v0, 0x1c($s0)
9d048498  bnez      $v0, 0x9d0482f4
9d04849c  sw        $zero, -0x7db8($gp)
9d0484a0  b         0x9d04840c
9d0484a4  sw        $zero, -0x7dbc($gp)
9d0484a8  mtc1      $zero, $f23
9d0484ac  lui       $t5, 0x8008
9d0484b0  add.s     $f25, $f6, $f23
9d0484b4  add.s     $f27, $f9, $f23
9d0484b8  add.s     $f29, $f10, $f23
9d0484bc  addiu     $t6, $t5, -0x2248
9d0484c0  addiu     $t7, $zero, 1  ; 1
9d0484c4  swc1      $f25, -0x2248($t5)
9d0484c8  swc1      $f27, 4($t6)
9d0484cc  swc1      $f29, 8($t6)
9d0484d0  b         0x9d04840c
9d0484d4  sw        $t7, -0x7dbc($gp)
9d0484d8  lw        $a1, 4($s1)
9d0484dc  lw        $a0, ($s1)
9d0484e0  lwc1      $f28, 0x104($sp)
9d0484e4  lwc1      $f26, 0x108($sp)
9d0484e8  jal       0x9d072394
9d0484ec  lwc1      $f20, 0x10c($sp)
9d0484f0  lw        $s2, -0x28d8($s2)
9d0484f4  sw        $v0, 0xa0($sp)
9d0484f8  sw        $v1, 0xa4($sp)
9d0484fc  swc1      $f28, 0xa8($sp)
9d048500  swc1      $f26, 0xac($sp)
9d048504  swc1      $f20, 0xb0($sp)
9d048508  addiu     $s4, $sp, 0x10
9d04850c  addiu     $a2, $sp, 0xa0
9d048510  bnez      $s2, 0x9d0486a8
9d048514  addiu     $a1, $zero, 0x3e  ; 62
9d048518  jal       0x9d02deb0
9d04851c  move      $a0, $s4
9d048520  b         0x9d0483fc
9d048524  move      $a2, $v0
9d048528  lw        $a1, 8($s1)
9d04852c  addiu     $a0, $sp, 0xd0
9d048530  jal       0x9d086e88  ; AhrsGetQuaternion
9d048534  addiu     $s4, $sp, 0x10
9d048538  lw        $a1, 4($s1)
9d04853c  jal       0x9d072394
9d048540  lw        $a0, ($s1)
9d048544  lwc1      $f17, 0xd0($sp)
9d048548  lwc1      $f18, 0xd4($sp)
9d04854c  lwc1      $f19, 0xd8($sp)
9d048550  lwc1      $f21, 0xdc($sp)
9d048554  lw        $t3, -0x28d8($s2)
9d048558  sw        $v0, 0xa0($sp)
9d04855c  sw        $v1, 0xa4($sp)
9d048560  swc1      $f17, 0xa8($sp)
9d048564  swc1      $f18, 0xac($sp)
9d048568  swc1      $f19, 0xb0($sp)
9d04856c  swc1      $f21, 0xb4($sp)
9d048570  addiu     $a2, $sp, 0xa0
9d048574  bnez      $t3, 0x9d0486b8
9d048578  addiu     $a1, $zero, 0x4b  ; 75
9d04857c  jal       0x9d0281f8
9d048580  move      $a0, $s4
9d048584  b         0x9d0482d8
9d048588  lw        $a3, -0x7da8($gp)
9d04858c  lw        $a1, 8($s1)
9d048590  addiu     $a0, $sp, 0xf4
9d048594  jal       0x9d086e88  ; AhrsGetQuaternion
9d048598  addiu     $s4, $sp, 0x10
9d04859c  lwc1      $f3, 0xf4($sp)
9d0485a0  lwc1      $f0, 0xfc($sp)
9d0485a4  lwc1      $f1, 0xf8($sp)
9d0485a8  add.s     $f2, $f3, $f3
9d0485ac  lui       $t1, 0x9d09
9d0485b0  lwc1      $f5, -0x7d28($t1)
9d0485b4  add.s     $f22, $f1, $f1
9d0485b8  add.s     $f20, $f0, $f0
9d0485bc  lwc1      $f4, 0x100($sp)
9d0485c0  msub.s    $f8, $f5, $f3, $f2
9d0485c4  mul.s     $f28, $f0, $f22
9d0485c8  mul.s     $f26, $f4, $f22
9d0485cc  mul.s     $f24, $f4, $f20
9d0485d0  mul.s     $f7, $f4, $f2
9d0485d4  mul.s     $f6, $f0, $f2
9d0485d8  mul.s     $f9, $f1, $f2
9d0485dc  add.s     $f10, $f4, $f4
9d0485e0  bc3fl     $cc5, 0x9d04bc64
9d0485e4  bc3f      $cc5, 0x9d049a68
9d0485e8  lw        $a1, 4($s1)
9d0485ec  bc3f      $cc1, 0x9d05d270
9d0485f0  sub.s     $f11, $f28, $f7
9d0485f4  add.s     $f13, $f26, $f6
9d0485f8  sub.s     $f30, $f24, $f9
9d0485fc  add.s     $f28, $f28, $f7
9d048600  sub.s     $f26, $f26, $f6
9d048604  add.s     $f24, $f24, $f9
9d048608  lw        $a0, ($s1)
9d04860c  swc1      $f22, 0xd0($sp)
9d048610  swc1      $f11, 0xd4($sp)
9d048614  swc1      $f11, 0x118($sp)
9d048618  swc1      $f13, 0xd8($sp)
9d04861c  swc1      $f13, 0x114($sp)
9d048620  swc1      $f28, 0xdc($sp)
9d048624  swc1      $f20, 0xe0($sp)
9d048628  swc1      $f30, 0xe4($sp)
9d04862c  swc1      $f26, 0xe8($sp)
9d048630  swc1      $f24, 0xec($sp)
9d048634  swc1      $f12, 0xf0($sp)
9d048638  jal       0x9d072394
9d04863c  swc1      $f12, 0x110($sp)
9d048640  lwc1      $f14, 0x118($sp)
9d048644  lwc1      $f15, 0x114($sp)
9d048648  lwc1      $f16, 0x110($sp)
9d04864c  lw        $t2, -0x28d8($s2)
9d048650  sw        $v0, 0xa0($sp)
9d048654  sw        $v1, 0xa4($sp)
9d048658  swc1      $f22, 0xa8($sp)
9d04865c  swc1      $f14, 0xac($sp)
9d048660  swc1      $f15, 0xb0($sp)
9d048664  swc1      $f28, 0xb4($sp)
9d048668  swc1      $f20, 0xb8($sp)
9d04866c  swc1      $f30, 0xbc($sp)
9d048670  swc1      $f26, 0xc0($sp)
9d048674  swc1      $f24, 0xc4($sp)
9d048678  swc1      $f16, 0xc8($sp)
9d04867c  addiu     $a2, $sp, 0xa0
9d048680  bnez      $t2, 0x9d0486d8
9d048684  addiu     $a1, $zero, 0x8c  ; 140
9d048688  jal       0x9d010694
9d04868c  move      $a0, $s4
9d048690  b         0x9d0482d8
9d048694  lw        $a3, -0x7da8($gp)
9d048698  jal       0x9d019324
9d04869c  move      $a0, $s4
9d0486a0  b         0x9d0483fc
9d0486a4  move      $a2, $v0
9d0486a8  jal       0x9d017804
9d0486ac  move      $a0, $s4
9d0486b0  b         0x9d0483fc
9d0486b4  move      $a2, $v0
9d0486b8  jal       0x9d00e460
9d0486bc  move      $a0, $s4
9d0486c0  b         0x9d0482d8
9d0486c4  lw        $a3, -0x7da8($gp)
9d0486c8  jal       0x9d015ce4
9d0486cc  move      $a0, $s4
9d0486d0  b         0x9d0482d8
9d0486d4  lw        $a3, -0x7da8($gp)
9d0486d8  jal       0x9d001300
9d0486dc  move      $a0, $s4
9d0486e0  b         0x9d0482d8
9d0486e4  lw        $a3, -0x7da8($gp)
9d0486e8  jal       0x9d068af0  ; atanf_approx
9d0486ec  nop       
9d0486f0  mul.s     $f26, $f0, $f26
9d0486f4  b         0x9d04826c
9d0486f8  lwc1      $f3, 0x110($sp)
9d0486fc  lui       $t8, 0x9d09
9d048700  b         0x9d04826c
9d048704  lwc1      $f26, -0x7d24($t8)
9d048708  addiu     $sp, $sp, -0xe8