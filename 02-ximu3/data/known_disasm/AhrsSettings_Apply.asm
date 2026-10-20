9d0545dc  addiu     $sp, $sp, -0x68
9d0545e0  sw        $s0, 0x50($sp)
9d0545e4  lui       $s0, 0x8008
9d0545e8  sw        $s4, 0x60($sp)
9d0545ec  sw        $s2, 0x58($sp)
9d0545f0  sw        $s1, 0x54($sp)
9d0545f4  sw        $ra, 0x64($sp)
9d0545f8  move      $s1, $a0
9d0545fc  sw        $s3, 0x5c($sp)
9d054600  jal       0x9d087910  ; Settings_GetPointer
9d054604  addiu     $s0, $s0, -0x3bb8
9d054608  move      $s2, $v0
9d05460c  lw        $v1, 0xe4($s0)
9d054610  lw        $v0, 0xe4($s1)
9d054614  bne       $v1, $v0, 0x9d05462c
9d054618  lui       $s4, 0x8008
9d05461c  lw        $a0, 0x108($s0)
9d054620  lw        $a1, 0x108($s1)
9d054624  beql      $a0, $a1, 0x9d05464c
9d054628  lwc1      $f2, 0xec($s1)
9d05462c  jal       0x9d07ca98  ; AhrsReset
9d054630  addiu     $a0, $s4, -0x3240
9d054634  lwc1      $f1, 0x110($s0)
9d054638  mtc1      $zero, $f0
9d05463c  c.eq.s    $f1, $f0
9d054640  bc1t      0x9d054948
9d054644  nop       
9d054648  lwc1      $f2, 0xec($s1)
9d05464c  lwc1      $f3, 0xec($s0)
9d054650  c.eq.s    $f4, $f6
9d054654  bc1tl     $fcc1, 0x9d05491c
9d054658  lwc1      $f4, 0xf0($s0)
9d05465c  lw        $a1, 0xec($s1)
9d054660  lw        $a2, 0xf0($s1)
9d054664  lw        $a3, 0xf4($s1)
9d054668  lui       $s3, 0x8008
9d05466c  jal       0x9d087f30
9d054670  addiu     $a0, $s3, -0x29d0
9d054674  lwc1      $f8, 0xfc($s0)
9d054678  lwc1      $f9, 0xfc($s1)
9d05467c  c.eq.s    $f17, $f18  ; cc=2
9d054680  bc1tl     $fcc4, 0x9d0548f0
9d054684  lwc1      $f10, 0x100($s0)
9d054688  lw        $a1, 0xfc($s1)
9d05468c  lw        $a2, 0x100($s1)
9d054690  lw        $a3, 0x104($s1)
9d054694  lui       $t0, 0x8008
9d054698  jal       0x9d087f4c
9d05469c  addiu     $a0, $t0, -0x4004
9d0546a0  move      $a0, $s1
9d0546a4  move      $v0, $s0
9d0546a8  addiu     $t3, $s1, 0x120
9d0546ac  lw        $t1, ($a0)
9d0546b0  lw        $a3, 8($a0)
9d0546b4  lw        $a2, 0xc($a0)
9d0546b8  lw        $t2, 4($a0)
9d0546bc  sw        $a3, 8($v0)
9d0546c0  sw        $a2, 0xc($v0)
9d0546c4  sw        $t1, ($v0)
9d0546c8  sw        $t2, 4($v0)
9d0546cc  lw        $t4, 0x10($a0)
9d0546d0  lw        $t5, 0x14($a0)
9d0546d4  lw        $t6, 0x18($a0)
9d0546d8  lw        $t7, 0x1c($a0)
9d0546dc  sw        $t4, 0x10($v0)
9d0546e0  sw        $t5, 0x14($v0)
9d0546e4  sw        $t6, 0x18($v0)
9d0546e8  sw        $t7, 0x1c($v0)
9d0546ec  lw        $t8, 0x20($a0)
9d0546f0  lw        $t9, 0x24($a0)
9d0546f4  lw        $ra, 0x28($a0)
9d0546f8  lw        $s1, 0x2c($a0)
9d0546fc  sw        $t8, 0x20($v0)
9d054700  sw        $t9, 0x24($v0)
9d054704  sw        $ra, 0x28($v0)
9d054708  sw        $s1, 0x2c($v0)
9d05470c  lw        $v1, 0x30($a0)
9d054710  lw        $a1, 0x34($a0)
9d054714  lw        $t0, 0x38($a0)
9d054718  lw        $t1, 0x3c($a0)
9d05471c  sw        $v1, 0x30($v0)
9d054720  sw        $a1, 0x34($v0)
9d054724  sw        $t0, 0x38($v0)
9d054728  sw        $t1, 0x3c($v0)
9d05472c  lw        $t2, 0x40($a0)
9d054730  lw        $a2, 0x44($a0)
9d054734  lw        $a3, 0x4c($a0)
9d054738  lw        $t4, 0x48($a0)
9d05473c  sw        $a2, 0x44($v0)
9d054740  sw        $a3, 0x4c($v0)
9d054744  sw        $t2, 0x40($v0)
9d054748  sw        $t4, 0x48($v0)
9d05474c  lw        $t5, 0x50($a0)
9d054750  lw        $t6, 0x54($a0)
9d054754  lw        $t7, 0x58($a0)
9d054758  lw        $t8, 0x5c($a0)
9d05475c  sw        $t5, 0x50($v0)
9d054760  sw        $t6, 0x54($v0)
9d054764  sw        $t7, 0x58($v0)
9d054768  sw        $t8, 0x5c($v0)
9d05476c  lw        $t9, 0x60($a0)
9d054770  lw        $ra, 0x64($a0)
9d054774  lw        $s1, 0x68($a0)
9d054778  lw        $v1, 0x6c($a0)
9d05477c  sw        $t9, 0x60($v0)
9d054780  sw        $ra, 0x64($v0)
9d054784  sw        $s1, 0x68($v0)
9d054788  sw        $v1, 0x6c($v0)
9d05478c  lw        $a1, 0x70($a0)
9d054790  lw        $t1, 0x74($a0)
9d054794  lw        $t0, 0x78($a0)
9d054798  lw        $t2, 0x7c($a0)
9d05479c  sw        $a1, 0x70($v0)
9d0547a0  sw        $t1, 0x74($v0)
9d0547a4  sw        $t0, 0x78($v0)
9d0547a8  sw        $t2, 0x7c($v0)
9d0547ac  lw        $t4, 0x80($a0)
9d0547b0  lw        $t5, 0x84($a0)
9d0547b4  lw        $a3, 0x88($a0)
9d0547b8  lw        $a2, 0x8c($a0)
9d0547bc  addiu     $a0, $a0, 0x90
9d0547c0  sw        $t4, 0x80($v0)
9d0547c4  sw        $t5, 0x84($v0)
9d0547c8  sw        $a3, 0x88($v0)
9d0547cc  sw        $a2, 0x8c($v0)
9d0547d0  bne       $a0, $t3, 0x9d0546ac
9d0547d4  addiu     $v0, $v0, 0x90
9d0547d8  lui       $s1, 0x9d09
9d0547dc  lwc1      $f14, -0x78c8($s1)
9d0547e0  lw        $t3, 0x108($s0)
9d0547e4  lw        $t8, 0x10c($s0)
9d0547e8  addiu     $t6, $zero, 1  ; 1
9d0547ec  swc1      $f14, 0x10($sp)
9d0547f0  beq       $t8, $t6, 0x9d054808
9d0547f4  sw        $t3, 0x14($sp)
9d0547f8  xori      $t7, $t8, 2
9d0547fc  addiu     $v0, $zero, 3  ; 3
9d054800  movn      $v0, $zero, $t7
9d054804  move      $t8, $v0
9d054808  lwc1      $f15, 0x110($s0)
9d05480c  lbu       $t9, 0x114($s0)
9d054810  sw        $t8, 0x18($sp)
9d054814  swc1      $f15, 0x1c($sp)
9d054818  beqz      $t9, 0x9d054828
9d05481c  mtc1      $zero, $f16
9d054820  lui       $ra, 0x9d09
9d054824  lwc1      $f16, -0x78d0($ra)
9d054828  lbu       $v1, 0x115($s0)
9d05482c  swc1      $f16, 0x20($sp)
9d054830  beqz      $v1, 0x9d054840
9d054834  mtc1      $zero, $f17
9d054838  lui       $a1, 0x9d09
9d05483c  lwc1      $f17, -0x78cc($a1)
9d054840  lbu       $t1, 0x116($s0)
9d054844  swc1      $f17, 0x24($sp)
9d054848  beqz      $t1, 0x9d054858
9d05484c  mtc1      $zero, $f18
9d054850  lui       $t0, 0x9d09
9d054854  lwc1      $f18, -0x78cc($t0)
9d054858  lui       $t2, 0x9d08
9d05485c  lwc1      $f21, 0x118($s0)
9d054860  lwc1      $f23, 0x11c($s0)
9d054864  lwc1      $f19, 0x6ecc($t2)
9d054868  addiu     $a1, $sp, 0x10
9d05486c  addiu     $a0, $s4, -0x3240
9d054870  swc1      $f18, 0x28($sp)
9d054874  swc1      $f19, 0x2c($sp)
9d054878  swc1      $f21, 0x30($sp)
9d05487c  swc1      $f23, 0x34($sp)
9d054880  jal       0x9d05c740  ; AhrsEngine_Configure
9d054884  lui       $s4, 0x9d09
9d054888  lw        $s0, 0xe8($s0)
9d05488c  addiu     $t4, $s4, -0x7920
9d054890  lwc1      $f25, -0x78c8($s1)
9d054894  lwc1      $f27, 4($t4)
9d054898  lwc1      $f29, 8($t4)
9d05489c  lwc1      $f31, 0x10($t4)
9d0548a0  xori      $t5, $s0, 1
9d0548a4  sltiu     $a3, $t5, 1
9d0548a8  addiu     $a1, $sp, 0x38
9d0548ac  addiu     $a0, $s3, -0x29d0
9d0548b0  swc1      $f25, 0x38($sp)
9d0548b4  swc1      $f27, 0x3c($sp)
9d0548b8  swc1      $f29, 0x40($sp)
9d0548bc  sb        $a3, 0x44($sp)
9d0548c0  jal       0x9d073ed4
9d0548c4  swc1      $f31, 0x48($sp)
9d0548c8  jal       0x9d086d70  ; Scheduler_CriticalSection
9d0548cc  move      $a0, $s2
9d0548d0  lw        $ra, 0x64($sp)
9d0548d4  lw        $s4, 0x60($sp)
9d0548d8  lw        $s3, 0x5c($sp)
9d0548dc  lw        $s2, 0x58($sp)
9d0548e0  lw        $s1, 0x54($sp)
9d0548e4  lw        $s0, 0x50($sp)
9d0548e8  jr        $ra
9d0548ec  addiu     $sp, $sp, 0x68
9d0548f0  lwc1      $f11, 0x100($s1)
9d0548f4  c.eq.s    $f21, $f22  ; cc=2
9d0548f8  bc1fl     $fcc5, 0x9d05468c
9d0548fc  lw        $a1, 0xfc($s1)
9d054900  lwc1      $f12, 0x104($s0)
9d054904  lwc1      $f13, 0x104($s1)
9d054908  c.eq.s    $f25, $f26  ; cc=3
9d05490c  bc1fl     $fcc6, 0x9d05468c
9d054910  lw        $a1, 0xfc($s1)
9d054914  b         0x9d0546a4
9d054918  move      $a0, $s1
9d05491c  lwc1      $f5, 0xf0($s1)
9d054920  c.eq.s    $f8, $f10  ; cc=1
9d054924  bc1fl     $fcc2, 0x9d054660
9d054928  lw        $a1, 0xec($s1)
9d05492c  lwc1      $f6, 0xf4($s1)
9d054930  lwc1      $f7, 0xf4($s0)
9d054934  c.eq.s    $f12, $f14  ; cc=1
9d054938  bc1fl     $fcc3, 0x9d054660
9d05493c  lw        $a1, 0xec($s1)
9d054940  b         0x9d054674
9d054944  lui       $s3, 0x8008
9d054948  jal       0x9d088cb0  ; AhrsClearRampFlags
9d05494c  addiu     $a0, $s4, -0x3240
9d054950  b         0x9d05464c
9d054954  lwc1      $f2, 0xec($s1)
9d054958  addiu     $sp, $sp, -0x108