9d04a270  addiu     $sp, $sp, -0x138
9d04a274  addiu     $a1, $zero, 4  ; 4
9d04a278  sw        $s0, 0x130($sp)
9d04a27c  sw        $ra, 0x134($sp)
9d04a280  jal       0x9d0865e0
9d04a284  move      $s0, $a0
9d04a288  bnez      $v0, 0x9d04a2a4
9d04a28c  nop       
9d04a290  addiu     $a1, $zero, 5  ; 5
9d04a294  jal       0x9d0865e0
9d04a298  move      $a0, $s0
9d04a29c  beql      $v0, $zero, 0x9d04a5c4
9d04a2a0  addiu     $a1, $zero, 6  ; 6
9d04a2a4  jal       0x9d0892e0
9d04a2a8  move      $a0, $s0
9d04a2ac  addiu     $v1, $v0, 0x70
9d04a2b0  addiu     $a1, $sp, 0x10
9d04a2b4  addiu     $v0, $v0, 0x90
9d04a2b8  lw        $t0, ($v1)
9d04a2bc  lw        $a3, 4($v1)
9d04a2c0  lw        $a2, 8($v1)
9d04a2c4  lw        $a0, 0xc($v1)
9d04a2c8  addiu     $v1, $v1, 0x10
9d04a2cc  sw        $t0, ($a1)
9d04a2d0  sw        $a3, 4($a1)
9d04a2d4  sw        $a2, 8($a1)
9d04a2d8  sw        $a0, 0xc($a1)
9d04a2dc  bne       $v1, $v0, 0x9d04a2b8
9d04a2e0  addiu     $a1, $a1, 0x10
9d04a2e4  lw        $t1, ($v1)
9d04a2e8  move      $a0, $s0
9d04a2ec  jal       0x9d0892e0
9d04a2f0  sw        $t1, ($a1)
9d04a2f4  lw        $t2, 0x94($v0)
9d04a2f8  lw        $t3, 0x98($v0)
9d04a2fc  lw        $t4, 0x9c($v0)
9d04a300  move      $a0, $s0
9d04a304  sw        $t2, 0x34($sp)
9d04a308  sw        $t3, 0x38($sp)
9d04a30c  jal       0x9d0892e0
9d04a310  sw        $t4, 0x3c($sp)
9d04a314  lw        $t5, 0xa0($v0)
9d04a318  lw        $t6, 0xa4($v0)
9d04a31c  lw        $t7, 0xa8($v0)
9d04a320  move      $a0, $s0
9d04a324  sw        $t5, 0x40($sp)
9d04a328  sw        $t6, 0x44($sp)
9d04a32c  jal       0x9d0892e0
9d04a330  sw        $t7, 0x48($sp)
9d04a334  addiu     $a3, $v0, 0xac
9d04a338  addiu     $a2, $sp, 0x4c
9d04a33c  addiu     $t8, $v0, 0xcc
9d04a340  lw        $t9, ($a3)
9d04a344  lw        $ra, 4($a3)
9d04a348  lw        $v0, 8($a3)
9d04a34c  lw        $t0, 0xc($a3)
9d04a350  addiu     $a3, $a3, 0x10
9d04a354  sw        $t9, ($a2)
9d04a358  sw        $ra, 4($a2)
9d04a35c  sw        $v0, 8($a2)
9d04a360  sw        $t0, 0xc($a2)
9d04a364  bne       $a3, $t8, 0x9d04a340
9d04a368  addiu     $a2, $a2, 0x10
9d04a36c  lw        $v1, ($a3)
9d04a370  move      $a0, $s0
9d04a374  jal       0x9d0892e0
9d04a378  sw        $v1, ($a2)
9d04a37c  lw        $a1, 0xd0($v0)
9d04a380  lw        $t1, 0xd4($v0)
9d04a384  lw        $t2, 0xd8($v0)
9d04a388  move      $a0, $s0
9d04a38c  sw        $a1, 0x70($sp)
9d04a390  sw        $t1, 0x74($sp)
9d04a394  jal       0x9d0892e0
9d04a398  sw        $t2, 0x78($sp)
9d04a39c  lw        $t3, 0xdc($v0)
9d04a3a0  lw        $t4, 0xe0($v0)
9d04a3a4  lw        $t5, 0xe4($v0)
9d04a3a8  move      $a0, $s0
9d04a3ac  sw        $t3, 0x7c($sp)
9d04a3b0  sw        $t4, 0x80($sp)
9d04a3b4  jal       0x9d0892e0
9d04a3b8  sw        $t5, 0x84($sp)
9d04a3bc  addiu     $t0, $v0, 0xe8
9d04a3c0  addiu     $a3, $sp, 0x88
9d04a3c4  addiu     $t6, $v0, 0x108
9d04a3c8  lw        $t7, ($t0)
9d04a3cc  lw        $t8, 4($t0)
9d04a3d0  lw        $t9, 8($t0)
9d04a3d4  lw        $a0, 0xc($t0)
9d04a3d8  addiu     $t0, $t0, 0x10
9d04a3dc  sw        $t7, ($a3)
9d04a3e0  sw        $t8, 4($a3)
9d04a3e4  sw        $t9, 8($a3)
9d04a3e8  sw        $a0, 0xc($a3)
9d04a3ec  bne       $t0, $t6, 0x9d04a3c8
9d04a3f0  addiu     $a3, $a3, 0x10
9d04a3f4  lw        $ra, ($t0)
9d04a3f8  sw        $ra, ($a3)
9d04a3fc  jal       0x9d0892e0
9d04a400  move      $a0, $s0
9d04a404  lw        $a2, 0x10c($v0)
9d04a408  lw        $v1, 0x110($v0)
9d04a40c  lw        $v0, 0x114($v0)
9d04a410  move      $a0, $s0
9d04a414  sw        $a2, 0xac($sp)
9d04a418  sw        $v1, 0xb0($sp)
9d04a41c  jal       0x9d0892e0
9d04a420  sw        $v0, 0xb4($sp)
9d04a424  addiu     $t6, $v0, 0x118
9d04a428  addiu     $a1, $sp, 0xb8
9d04a42c  addiu     $t1, $v0, 0x138
9d04a430  lw        $t2, ($t6)
9d04a434  lw        $t3, 4($t6)
9d04a438  lw        $t4, 8($t6)
9d04a43c  lw        $t5, 0xc($t6)
9d04a440  addiu     $t6, $t6, 0x10
9d04a444  sw        $t2, ($a1)
9d04a448  sw        $t3, 4($a1)
9d04a44c  sw        $t4, 8($a1)
9d04a450  sw        $t5, 0xc($a1)
9d04a454  bne       $t6, $t1, 0x9d04a430
9d04a458  addiu     $a1, $a1, 0x10
9d04a45c  lw        $t7, ($t6)
9d04a460  move      $a0, $s0
9d04a464  jal       0x9d0892e0
9d04a468  sw        $t7, ($a1)
9d04a46c  lw        $t9, 0x140($v0)
9d04a470  lw        $t8, 0x13c($v0)
9d04a474  lw        $t0, 0x144($v0)
9d04a478  move      $a0, $s0
9d04a47c  sw        $t9, 0xe0($sp)
9d04a480  sw        $t8, 0xdc($sp)
9d04a484  jal       0x9d0892e0
9d04a488  sw        $t0, 0xe4($sp)
9d04a48c  lw        $a3, 0x148($v0)
9d04a490  lw        $a2, 0x14c($v0)
9d04a494  lw        $v1, 0x150($v0)
9d04a498  move      $a0, $s0
9d04a49c  sw        $a3, 0xe8($sp)
9d04a4a0  sw        $a2, 0xec($sp)
9d04a4a4  jal       0x9d0892e0
9d04a4a8  sw        $v1, 0xf0($sp)
9d04a4ac  lw        $v0, 0x318($v0)
9d04a4b0  move      $a0, $s0
9d04a4b4  jal       0x9d0892e0
9d04a4b8  sw        $v0, 0xf4($sp)
9d04a4bc  lbu       $t1, 0x31c($v0)
9d04a4c0  move      $a0, $s0
9d04a4c4  jal       0x9d0892e0
9d04a4c8  sw        $t1, 0xf8($sp)
9d04a4cc  lw        $t2, 0x320($v0)
9d04a4d0  lw        $t3, 0x324($v0)
9d04a4d4  lw        $t4, 0x328($v0)
9d04a4d8  move      $a0, $s0
9d04a4dc  sw        $t2, 0xfc($sp)
9d04a4e0  sw        $t3, 0x100($sp)
9d04a4e4  jal       0x9d0892e0
9d04a4e8  sw        $t4, 0x104($sp)
9d04a4ec  lbu       $t5, 0x32c($v0)
9d04a4f0  move      $a0, $s0
9d04a4f4  jal       0x9d0892e0
9d04a4f8  sb        $t5, 0x108($sp)
9d04a4fc  lw        $t6, 0x330($v0)
9d04a500  lw        $a1, 0x334($v0)
9d04a504  lw        $t7, 0x338($v0)
9d04a508  move      $a0, $s0
9d04a50c  sw        $t6, 0x10c($sp)
9d04a510  sw        $a1, 0x110($sp)
9d04a514  jal       0x9d0892e0
9d04a518  sw        $t7, 0x114($sp)
9d04a51c  lw        $t8, 0x33c($v0)
9d04a520  move      $a0, $s0
9d04a524  jal       0x9d0892e0
9d04a528  sw        $t8, 0x118($sp)
9d04a52c  lbu       $a0, 0x348($v0)
9d04a530  beqz      $a0, 0x9d04a5b4
9d04a534  addiu     $t9, $zero, 2  ; 2
9d04a538  move      $a0, $s0
9d04a53c  jal       0x9d0892e0
9d04a540  sw        $t9, 0x11c($sp)
9d04a544  lwc1      $f0, 0x340($v0)
9d04a548  move      $a0, $s0
9d04a54c  jal       0x9d0892e0
9d04a550  swc1      $f0, 0x120($sp)
9d04a554  lbu       $t0, 0x345($v0)
9d04a558  move      $a0, $s0
9d04a55c  jal       0x9d0892e0
9d04a560  sb        $t0, 0x124($sp)
9d04a564  lbu       $a3, 0x346($v0)
9d04a568  move      $a0, $s0
9d04a56c  jal       0x9d0892e0
9d04a570  sb        $a3, 0x125($sp)
9d04a574  lbu       $a2, 0x347($v0)
9d04a578  move      $a0, $s0
9d04a57c  jal       0x9d0892e0
9d04a580  sb        $a2, 0x126($sp)
9d04a584  lwc1      $f1, 0x34c($v0)
9d04a588  move      $a0, $s0
9d04a58c  jal       0x9d0892e0
9d04a590  swc1      $f1, 0x128($sp)
9d04a594  lwc1      $f2, 0x350($v0)
9d04a598  addiu     $a0, $sp, 0x10
9d04a59c  jal       0x9d0545dc  ; AhrsSettings_Apply
9d04a5a0  swc1      $f2, 0x12c($sp)
9d04a5a4  lw        $ra, 0x134($sp)
9d04a5a8  lw        $s0, 0x130($sp)
9d04a5ac  jr        $ra
9d04a5b0  addiu     $sp, $sp, 0x138
9d04a5b4  jal       0x9d0892e0
9d04a5b8  move      $a0, $s0
9d04a5bc  b         0x9d04a538
9d04a5c0  lbu       $t9, 0x344($v0)
9d04a5c4  jal       0x9d0865e0
9d04a5c8  move      $a0, $s0
9d04a5cc  bnez      $v0, 0x9d04a2a4
9d04a5d0  nop       
9d04a5d4  addiu     $a1, $zero, 7  ; 7
9d04a5d8  jal       0x9d0865e0
9d04a5dc  move      $a0, $s0
9d04a5e0  bnez      $v0, 0x9d04a2a4
9d04a5e4  nop       
9d04a5e8  addiu     $a1, $zero, 8  ; 8
9d04a5ec  jal       0x9d0865e0
9d04a5f0  move      $a0, $s0
9d04a5f4  bnez      $v0, 0x9d04a2a4
9d04a5f8  nop       
9d04a5fc  addiu     $a1, $zero, 9  ; 9
9d04a600  jal       0x9d0865e0
9d04a604  move      $a0, $s0
9d04a608  bnez      $v0, 0x9d04a2a4
9d04a60c  nop       
9d04a610  addiu     $a1, $zero, 0xa  ; 10
9d04a614  jal       0x9d0865e0
9d04a618  move      $a0, $s0
9d04a61c  bnez      $v0, 0x9d04a2a4
9d04a620  nop       
9d04a624  addiu     $a1, $zero, 0xb  ; 11
9d04a628  jal       0x9d0865e0
9d04a62c  move      $a0, $s0
9d04a630  bnez      $v0, 0x9d04a2a4
9d04a634  nop       
9d04a638  addiu     $a1, $zero, 0xc  ; 12
9d04a63c  jal       0x9d0865e0
9d04a640  move      $a0, $s0
9d04a644  bnez      $v0, 0x9d04a2a4
9d04a648  nop       
9d04a64c  addiu     $a1, $zero, 0xd  ; 13
9d04a650  jal       0x9d0865e0
9d04a654  move      $a0, $s0
9d04a658  bnez      $v0, 0x9d04a2a4
9d04a65c  nop       
9d04a660  addiu     $a1, $zero, 0xe  ; 14
9d04a664  jal       0x9d0865e0
9d04a668  move      $a0, $s0
9d04a66c  bnez      $v0, 0x9d04a2a4
9d04a670  nop       
9d04a674  addiu     $a1, $zero, 0x3b  ; 59
9d04a678  jal       0x9d0865e0
9d04a67c  move      $a0, $s0
9d04a680  bnez      $v0, 0x9d04a2a4
9d04a684  nop       
9d04a688  addiu     $a1, $zero, 0x3c  ; 60
9d04a68c  jal       0x9d0865e0
9d04a690  move      $a0, $s0
9d04a694  bnez      $v0, 0x9d04a2a4
9d04a698  nop       
9d04a69c  addiu     $a1, $zero, 0x3d  ; 61
9d04a6a0  jal       0x9d0865e0
9d04a6a4  move      $a0, $s0
9d04a6a8  bnez      $v0, 0x9d04a2a4
9d04a6ac  nop       
9d04a6b0  addiu     $a1, $zero, 0x3e  ; 62
9d04a6b4  jal       0x9d0865e0
9d04a6b8  move      $a0, $s0
9d04a6bc  bnez      $v0, 0x9d04a2a4
9d04a6c0  nop       
9d04a6c4  addiu     $a1, $zero, 0x3f  ; 63
9d04a6c8  jal       0x9d0865e0
9d04a6cc  move      $a0, $s0
9d04a6d0  bnez      $v0, 0x9d04a2a4
9d04a6d4  nop       
9d04a6d8  addiu     $a1, $zero, 0x40  ; 64
9d04a6dc  jal       0x9d0865e0
9d04a6e0  move      $a0, $s0
9d04a6e4  bnez      $v0, 0x9d04a2a4
9d04a6e8  nop       
9d04a6ec  addiu     $a1, $zero, 0x41  ; 65
9d04a6f0  jal       0x9d0865e0
9d04a6f4  move      $a0, $s0
9d04a6f8  bnez      $v0, 0x9d04a2a4
9d04a6fc  nop       
9d04a700  addiu     $a1, $zero, 0x42  ; 66
9d04a704  jal       0x9d0865e0
9d04a708  move      $a0, $s0
9d04a70c  bnez      $v0, 0x9d04a2a4
9d04a710  nop       
9d04a714  addiu     $a1, $zero, 0x43  ; 67
9d04a718  jal       0x9d0865e0
9d04a71c  move      $a0, $s0
9d04a720  bnez      $v0, 0x9d04a2a4
9d04a724  nop       
9d04a728  addiu     $a1, $zero, 0x44  ; 68
9d04a72c  jal       0x9d0865e0
9d04a730  move      $a0, $s0
9d04a734  bnez      $v0, 0x9d04a2a4
9d04a738  nop       
9d04a73c  addiu     $a1, $zero, 0x45  ; 69
9d04a740  jal       0x9d0865e0
9d04a744  move      $a0, $s0
9d04a748  bnez      $v0, 0x9d04a2a4
9d04a74c  nop       
9d04a750  addiu     $a1, $zero, 0x46  ; 70
9d04a754  jal       0x9d0865e0
9d04a758  move      $a0, $s0
9d04a75c  bnez      $v0, 0x9d04a2a4
9d04a760  nop       
9d04a764  addiu     $a1, $zero, 0x47  ; 71
9d04a768  jal       0x9d0865e0
9d04a76c  move      $a0, $s0
9d04a770  bnez      $v0, 0x9d04a2a4
9d04a774  nop       
9d04a778  addiu     $a1, $zero, 0x48  ; 72
9d04a77c  jal       0x9d0865e0
9d04a780  move      $a0, $s0
9d04a784  bnez      $v0, 0x9d04a2a4
9d04a788  lw        $ra, 0x134($sp)
9d04a78c  b         0x9d04a5ac
9d04a790  lw        $s0, 0x130($sp)
9d04a794  lui       $a3, 0x9d07
9d04a798  lui       $v1, 0x9d07
9d04a79c  sll       $v0, $a2, 2
9d04a7a0  addiu     $t1, $a3, -0x5ff4
9d04a7a4  addiu     $t2, $v1, -0x616c
9d04a7a8  sltiu     $t0, $a2, 0x5e
9d04a7ac  lwx       $t6, $v0($t1)