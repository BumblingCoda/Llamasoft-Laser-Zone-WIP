
GameLoop_1:

    !Jump:
      
        lda TRAINMODEFLAG 
        bne !continue+                          // L_BRS_838E_8389_OK
 
        jsr JSR_8641                            // L_JSR_8641_838B_OK

    !continue:

    PlayerStillAlive:
        lda SPRITEPOINTER0                      // Get Sprite 0 data address 
        sta ZP_COUNTER 
        cmp #Spr1_X_Laser_Upright           // Is it Sprite 1 X-Axis Laser Upright
        beq !Jump+                            // L_BRS_83A6_839E_OK
 
        lda JOYSTICK_1                      // Get Joy 1 status
        and #$10                            // fire button pressed?
        bne !Not_RUF+                        // L_BRS_83B4_83A4_OK

    !Jump:
        lda #Spr1_X_Laser_Upright               // Sprite 1 $3000 $C0 Horizontal Laser Upright
        sta ZP_COUNTER 
        lda JOYSTICK_1 
        and #%00011001                          // $19 Joy 1 R U & F
        cmp #%00011001                          // Is Joy 1 Right, Up & Fire?
        bne !Not_RUF+ 
        inc ZP_COUNTER 

    !Not_RUF: 
        lda SPRITEPOINTER1 
        sta ZP_TEMP_VAR_1 
        cmp #Spr3_Y_Laser_Upright           // Sprite 3 $32080 $C2 Vertical Laser
        beq !Jump+

        lda JOYSTICK_2                      // Get Joy 2 status
        and #%00010000                      // Joy 2's fire button pressed?
        bne !NoFirePressed+                 //BRS_83D1                                            // L_BRS_83D1_83C1_OK

    !Jump:                                                        // L_BRS_83C3_83BB_OK
        lda #Spr3_Y_Laser_Upright                          // Get Vertical Laser Angled Sprite
        sta ZP_TEMP_VAR_1                                                 // Store here
        lda JOYSTICK_2 
        and #%00010110                                // #$16 Joy 2 D L & F
        cmp #%00010110
        bne !NoFirePressed+

        inc ZP_TEMP_VAR_1                         // Get Sprite Pointer from location and inc x1 
    !NoFirePressed:                                 //BRS_83D1: 
        lda ZP_TEMP_VAR_1 
        sta SPRITEPOINTER1 
        lda ZP_COUNTER 
        sta SPRITEPOINTER0 
        lda SPRITEPOINTER0 
        cmp #Spr2_X_Laser_Angled                 // Is Sprite 0 Vertical Laser Angled?
        beq MoveLaser2Up 

MoveLaser1Left:
        lda JOYSTICK_1                                 // Get Joystick Position 
        and #JOY_LEFT                                // Joystick Left?
        beq MoveLaser1Right                                  // L_BRS_83F7_83E6_OK
        dec SPRITE0_X                                  //  Move Laser to the Left
        lda SPRITE0_X                                  //  Store in Register
        cmp #$18                                       // Has the bottom laser reached the Far left?
        bne MoveLaser1Right
        lda #$D0                                       // If yes, rap around bottom laser to far right
        sta SPRITE0_X                                  // Store new pos. in register
                                             
MoveLaser1Right:                                          // BRS_83F7
        lda JOYSTICK_1 
        and #JOY_RIGHT                                      // Joy 1 Right
        beq MoveLaser2Up                                   // L_BRS_840C_83FB_OK
        inc SPRITE0_X                                  //  Sprite 0 X Pos
        lda SPRITE0_X                                  //  Sprite 0 X Pos
        cmp #$D1                                       // Have we reached far right of track?
        bne MoveLaser2Up
        lda #$19                                       // Wrap around Laser
        sta SPRITE0_X                                  //  Sprite 0 X Pos
                                                       // L_BRS_840C_83E0_OK
MoveLaser2Up:                                         // BRS_840C
        lda SPRITEPOINTER1 
        cmp #Spr4_Y_Laser_Angled                 // Horizontal Laser
        beq CheckJoy_1_Fire                           // L_BRS_843D_8411_OK
        lda JOYSTICK_2 
        and #JOY_UP                                        // Joy 2 Up
        beq MoveLaser2Down                               // L_BRS_8428_8417_OK
        dec SPRITE1_Y                                   //  Move Sprite 1 up
        lda SPRITE1_Y                                   //  Sprite 1 Y Pos
        cmp #$2F                                        // Have we reached top of track?
        bne MoveLaser2Down
        lda #$D0                                        // Yes,so wrap around
        sta SPRITE1_Y                                   //  Sprite 1 Y Pos
                                                        // L_BRS_8428_8417_OK
                                                        // L_BRS_8428_8421_OK
MoveLaser2Down:                                                   
        lda JOYSTICK_2 
        and #JOY_DOWN                                                // Joy 2 Down
        beq CheckJoy_1_Fire                                            // L_BRS_843D_842C_OK
        inc SPRITE1_Y                                           //  Sprite 1 Y Pos
        lda SPRITE1_Y                                           //  Sprite 1 Y Pos
        cmp #$D1                                                // Have we reached bottom of the track?
        bne CheckJoy_1_Fire
        lda #$30                                                // Yes, so wrap around
        sta SPRITE1_Y                                           //  Sprite 1 Y Pos

        rts                                                   // L_BRS_843D_8411_OK


FireButtonCheck:                                                                // L_BRS_843D_842C_OK
                                                                // L_BRS_843D_8436_OK
CheckJoy_1_Fire:
        jsr UTILS.CheckForBackgroundCollision                          // L_JSR_8C03_843D_OK check coll.
        lda JOYSTICK_1 
        and #%00010000  // #$10                                    // Joy 1 Fire Button Pressed?
        bne NoFireJoy1                                            // L_BRS_8457_8444_OK
        lda #$07                                                // Colour laser dish brown
        sta SPRITEMULTICOLOUR1                                  //  MC Mode Sprites 0-2 turn off Sprites 3-7                                                // L_JMP_844B_8461_OK
                                                                // L_JMP_844B_847D_OK
CheckJoy_2_Fire:                                                // JMP_844B
        lda JOYSTICK_2 
        and #%00010000  // $10
        bne NoFireJoy2
        lda #$02                                                // 
        sta SPRITEMULTICOLOUR0                                  //  Sprite Multi-Color Register 0
        rts 


NoFireJoy1:                                                     // L_BRS_8457_8444_OK
        inc SPRITEMULTICOLOUR1                                  //  Sprite Multi-Color Register 1
        lda SPRITEMULTICOLOUR1                                  //  Sprite Multi-Color Register 1
        cmp #$F8
        beq BRS_8472                                            // L_BRS_8472_845F_OK
        jmp CheckJoy_2_Fire                                            // L_JMP_844B_8461_OK

NoFireJoy2:                                             // L_BRS_8464_844F_OK
        inc SPRITEMULTICOLOUR0                          //  Sprite Multi-Color Register 0
        lda SPRITEMULTICOLOUR0                          // Sprite Multi-Color Register 0
        cmp #$F3
        bne ExitFireButtonCheck                        // BRS_8471
        jsr BulletCount                                // L_JMP_84AF_846E_OK

ExitFireButtonCheck:                                    // L_BRS_8471_846C_OK
        rts

BRS_8472:                                                // L_BRS_8472_845F_OK
        ldx #$04
Sprite1Xloop: 
        lda SPRITE1_X,X                                 // Get Sprites 2-6 X Pos
        beq BRS_8480                                    // L_BRS_8480_8477_OK
        dex 
        dex 
        bne Sprite1Xloop                               // L_BRS_8474_847B_OK
        jmp CheckJoy_2_Fire                            // L_JMP_844B_847D_OK

// ============================
// Vertical Bullets

BRS_8480:                                       // L_BRS_8480_8477_OK
        txa 
        clc 
        ror
        tay 
        lda #Spr5_Vertical_Bullet              // Sprite 5 $3100 $C4 Vertical (Y-Axis) Bullet                       
        sta SPRITEPOINTER1,Y 
        lda SPRITEPOINTER0                      // Get Laser1 sprite data pointer 
        cmp #Spr1_X_Laser_Upright          // Is X-Axis Laser pointed vertical?
        beq X_AxisLaserUpright                // L_BRS_8495_848E_OK

        lda #Spr6_Vertical_Bullet_Angled        // Get Sprite 6 $3140 $C5 definition 
        sta SPRITEPOINTER1,Y 

X_AxisLaserUpright:                            // L_BRS_8495_848E_OK
        lda #216                                // 
        sta SPRITE1_Y,X                         //  Sprite 1 Y Pos
        lda SPRITE0_X                           //  Get Laser 1 X Pos
        clc 
        adc #$08
        ldy SPRITEPOINTER0 
        cpy #Spr2_X_Laser_Angled                  // Is Sprite 0 pointing to sprite2?
        bne BRS_84A9                            // L_BRS_84A9_84A5_OK

        adc #$08
BRS_84A9:                                        // L_BRS_84A9_84A5_OK
        sta SPRITE1_X,X                         //  Sprite 1 X Pos
        jmp SOUND.BulletSFX                            // L_JMP_860A_84AC_OK

//==================================================
                                               // L_JMP_84AF_846E_OK
BulletCount:
        ldx #$04
BRS_84B1:                                        // L_BRS_84B1_84B8_OK
        lda SPRITE3_X,X                         // Get Sprites 3-6 X position
        beq BRS_84BB                            // L_BRS_84BB_84B4_OK
        dex                                     // Skip Y location 
        dex 
        bne BRS_84B1
        rts 
// ==============================
// Horizontal Bullets
BRS_84BB:                                        // L_BRS_84BB_84B4_OK
        txa 
        clc 
        ror 
        tay
        lda #Spr7_Horizontal_Bullet             // Sprite 7 $3180 $C6 Horizontal Bullet
        sta SPRITEPOINTER3,Y                    // Point Sprite 5 to Horizontal Bullet 
        lda SPRITEPOINTER1                      // Get Y-Axis Laser Sprite pointer 
        cmp #Spr3_Y_Laser_Upright               // Sprite 3 $32080 $C2 Vertical Laser                
        beq IsYAxisLaser                        // BRS_84D0 
        lda #Spr8_Horizontal_Bullet_Angled      // Sprite 8 $31C0 $C7 Downward Angled Bullet
        sta SPRITEPOINTER3,Y                    // Point Sprite 3 to Sprite 8 Definition 

IsYAxisLaser:                                   // L_BRS_84D0_84C9_OK
        lda #$D8                // 216
        sta SPRITE3_X,X                         // Set Sprite 3+ X to 216
        lda SPRITE1_Y                           // Get Y-Axis Laser Y Pos
        clc 
        adc #$06
        ldy SPRITEPOINTER1 
        cpy #Spr4_Y_Laser_Angled           // Sprite 4 $30C0 $C3 Y-Axis Laser Angled
        bne BRS_84E4                            // L_BRS_84E4_84E0_OK
        adc #$08

BRS_84E4:                                        // L_BRS_84E4_84E0_OK
        sta SPRITE3_Y,X                         //  Sprite 3 Y Pos
        jmp SOUND.BulletSFX                          // L_JMP_860A_84E7_OK

//*********************************************************************************

//===============================================================================

// ==========================                     // L_JSR_84EA_834C_OK
GameLoop_2:
                     // L_BRS_84EF_84EC_OK
        lda #18                                 // 
        sta GAMELOOPTIMER2 
        jsr SOUND.CheckPlayerBulletFired              // L_JSR_85DD_84F3_OK
        jsr SOUND.SoundFX_1                     // Sound FX       // L_JSR_8958_84F6_OK
        jsr UTILS.SmartBomb                     // L_JSR_8B7D_84F9_OK
        jsr SOUND.SoundFX_2                     // Toggle background and SFX L_JSR_8BDB_84FC_OK
        ldx #$04
    !Loop:                                        // L_BRS_8501_8513_OK
        lda SPRITE1_X,X                          //  Get X position for Sprites 2 - 5
        beq !Jump+
        jsr UTILS.BulletCollision                // L_JSR_8516_8506_OK

    !Jump:                                        // L_BRS_8509_8504_OK
        lda SPRITE3_X,X                         // Get Sprite 3+ X Pos
        beq !Jump+
        jsr UTILS.BulletCheck                            // L_JSR_8563_850E_OK

    !Jump:                                        // L_BRS_8511_850C_OK
        dex 
        dex 
        bne !Loop-                              // $8501
        rts 
//=============================================================================

// ============================                   // L_JSR_8641_838B_OK
JSR_8641:

        dec $1817 
        beq GameLoop_4
        rts 

    GameLoop_4:                                         // L_BRS_8647_8644_OK
        lda ATTACKWAVESPEED 
        sta $1817 
        dec $1917                               // Counts down during attack waves 
        beq BRS_8654
    BRS_8651:                                        // L_BRS_8651_865D_OK
        jmp DecreaseEnemyCount                            // L_JMP_86A0_8651_OK

BRS_8654:                                        // L_BRS_8654_864F_OK
        ldx #$00
        lda $16                                 // counts down during attack wave
        sta $1917 
        lda NumEnemiesForRound 
        bne BRS_8651                           // L_BRS_8651_865D_OK

    EnemyCharPosLooper:                             // L_BRS_865F_8665_OK
        lda ENEMY_X_POS_TABLE,X                             // Vertical Enemy Char X-Y locations 
        beq NoMoreVerticalEnemies              // Branch no attack wave
        inx 
        bne EnemyCharPosLooper 
        jmp DecreaseEnemyCount                            // L_JMP_86A0_8667_OK

    NoMoreVerticalEnemies:                                        // L_BRS_866A_8662_OK
        lda #$00
        sta ENEMY_SFX_TABLE,X 
        lda #$01                                // Start at column 1
        sta ENEMY_X_POS_TABLE,X                            // Vertical Enemy Char X-Y location array 
        lda VICRASTER                          //  Raster Position
        tay 
        lda $A000,Y                          //  Restart Vectors
        and #$0F
        adc #$03
        sta ENEMY_Y_POS_TABLE,X                             // Enemy Char X location array  

    VerticalEnemyLooper:                            // L_BRS_8682_8688_OK
        lda ENEMY_X_POS_TABLE,X                             // Fetch Enemy Char X location 
        beq BRS_868D
        inx 
        bne VerticalEnemyLooper
        jmp DecreaseEnemyCount                            // L_JMP_86A0_868A_OK

    BRS_868D:                                        // L_BRS_868D_8685_OK
        lda #$80                // 128
        sta ENEMY_SFX_TABLE,X 
        lda #$00
        sta ENEMY_Y_POS_TABLE,X                            // Enemy Char Y location array 
        iny 
        lda $A000,Y                          //  Restart Vectors
        and #$17
        sta ENEMY_X_POS_TABLE,X 

    DecreaseEnemyCount:                                 //JMP_86A0:
        lda NumEnemiesForRound 
        beq CheckEnemyCount
        lda #$00
        sta BACKGROUNDCOLOUR0                    //  Background Color 0
        dec NumEnemiesForRound 
        bne CheckEnemyCount                     //BRS_86B0
        jmp ZoneCleared                          // L_JMP_8E78_86AD_OK
//======================================

    CheckEnemyCount:                               // L_BRS_86B0_86AB_OK
        ldx #$00

    GetEnemyPlotLoc:                                // L_BRS_86B2_86C4_OK
        lda ENEMY_X_POS_TABLE,X                             // Fetch enemy char X location
        beq GotLastEnemy                       // L_BRS_86C1_86B5_OK
        sta SCREENCOLUMNTOPLOT 
        lda ENEMY_Y_POS_TABLE,X                             // Fetch enemy char Y location 
        sta SCREENROWTOPLOT 
        jsr UTILS.PlotSpaceChar                        // L_JSR_8760_86BE_OK

    GotLastEnemy:                                        // L_BRS_86C1_86B5_OK
        inx 
        cpx #16                                // Max no of enemies?
        bne GetEnemyPlotLoc                            // L_BRS_86B2_86C4_OK

        inc $25                                  // game tic timer for enemies
        ldx #$00
    !Loop:                                        // L_BRS_86CA_86DC_OK
        lda ENEMY_X_POS_TABLE,X                   // Fetch enemy char X location
        beq Exit
        lda ENEMY_SFX_TABLE,X 
        and #%00010000                          // $10
        bne Exit
        jsr ENEMY.PlotEnemies                          // L_JSR_86DF_86D6_OK

    Exit:                                        // L_BRS_86D9_86D4_OK
        inx 
        cpx #16                                // Max no of enemies? // $10
        bne !Loop- 
        rts
//===================================================         
//
//==================================================
/*
JSR_86DF:        // Plot Enemies
        lda ENEMY_SFX_TABLE,X 
        and #%01000000                          // $40
        beq BRS_86E9
        jmp JMP_877F                           */ // L_JMP_877F_86E6_OK
  

/*BRS_86E9:                                         // L_BRS_86E9_86E4_OK
        lda ENEMY_SFX_TABLE,X 
        and #%10000000                          // $80
        beq BRS_86F3
        jmp JMP_872E                            // L_JMP_872E_86F0_OK

BRS_86F3: //Plot Skull                          // L_BRS_86F3_86EE_OK
        inc ENEMY_X_POS_TABLE,X 
        lda ENEMY_X_POS_TABLE,X 
        cmp #$1A        // 26
        bne PlotSkull                           // JMP_8705
        lda ENEMY_SFX_TABLE,X 
        ora #$40        // 6
        sta ENEMY_SFX_TABLE,X 

    PlotSkull:                                       // JMP_8705
        lda #$09
        sta COLOURTOPLOT 
        lda ENEMY_X_POS_TABLE,X             // Get enemy char Y location to plot 
        sta SCREENCOLUMNTOPLOT  
        lda ENEMY_Y_POS_TABLE,X             // Get enemy char X location to plot 
        sta SCREENROWTOPLOT 
        lda #CHAR_SKULL_1                            // $48 Skull 1 Char
        sta CHARTOPLOT 
        lda ENEMY_SFX_TABLE,X 
        and #$01
        beq PlotEnemy
        lda #CHAR_SKULL_2                            // $4C Alternate Skull Char
        sta CHARTOPLOT */
    
  /*  PlotEnemy:
        jsr UTILS.PrintCharTileSet                            // L_JSR_861E_8722_OK
        lda ENEMY_SFX_TABLE,X 
        eor #$01
        sta ENEMY_SFX_TABLE,X 
        rts */
//=============================================

/*JMP_872E:
        lda #$0F

        sta COLOURTOPLOT 
        inc ENEMY_Y_POS_TABLE,X 
        lda ENEMY_Y_POS_TABLE,X 
        cmp #$15
        bne PlotSpider                            // L_BRS_8744_873A_OK
        lda ENEMY_SFX_TABLE,X 
        ora #$40
        sta ENEMY_SFX_TABLE,X 

PlotSpider:                                      // JMP_8744
        lda ENEMY_X_POS_TABLE,X 
        sta SCREENCOLUMNTOPLOT  
        lda ENEMY_Y_POS_TABLE,X 
        sta SCREENROWTOPLOT 
        lda #CHAR_SPIDER_1                      // $50 Spider Char
        sta CHARTOPLOT 
        lda ENEMY_SFX_TABLE,X 
        and #$01
        bne PlotEnemy                            // L_BRS_8722_8757_OK
        lda #CHAR_SPIDER_2                                // $54 Alternate Spider char
        sta CHARTOPLOT 
        jmp PlotEnemy                            // L_JMP_8722_875D_OK
*/

/*JMP_877F:
        lda ENEMY_SFX_TABLE,X 
        and #$80
        beq BRS_87B0                            // L_BRS_87B0_8784_OK
        jmp JMP_8789                            // L_JMP_8789_8786_OK

JMP_8789:
        lda $25 
        and #$01
        beq BRS_87A9                            // L_BRS_87A9_878D_OK
        lda SPRITE0_X                          //  Sprite 0 X Pos
        sec 
        sbc #16                                 // $10
        clc 
        ror 
        clc 
        ror 
        clc 
        ror 
        cmp ENEMY_X_POS_TABLE,X 
        bpl BRS_87A6                            // L_BRS_87A6_879E_OK
        dec ENEMY_X_POS_TABLE,X 
        dec ENEMY_X_POS_TABLE,X 

BRS_87A6:                                        // L_BRS_87A6_879E_OK
        inc ENEMY_X_POS_TABLE,X 
BRS_87A9:                                        // L_BRS_87A9_878D_OK
        lda #$0F
        sta COLOURTOPLOT 
        jmp PlotSpider                            // L_JMP_8744_87AD_OK*/
//=========================

/*BRS_87B0:                                        // L_BRS_87B0_8784_OK
        lda $25 
        and #$01
        beq BRS_87D0                            // L_BRS_87D0_87B4_OK
        lda SPRITE1_Y                          //  Sprite 1 Y Pos
        sec 
        sbc #$2E
        clc 
        ror 
        clc 
        ror 
        clc 
        ror 
        cmp ENEMY_Y_POS_TABLE,X 
        bpl BRS_87CD                            // L_BRS_87CD_87C5_OK
        dec ENEMY_Y_POS_TABLE,X 
        dec ENEMY_Y_POS_TABLE,X 

BRS_87CD:                                        // L_BRS_87CD_87C5_OK
        inc ENEMY_Y_POS_TABLE,X 

BRS_87D0:                                        // L_BRS_87D0_87B4_OK
        jmp PlotSkull
*/
                                                // L_JSR_87D3_854E_OK
//********************************************************************************

JSR_886F:                                // Called every game cycle from main game loop
        dec SFXloop_timer 
        beq BRS_8874                            // L_BRS_8874_8871_OK
        rts 

BRS_8874:                                        // L_BRS_8874_8871_OK
        lda $1D 
        sta SFXloop_timer 

        ldx #$00
BRS_887A:                                         // L_BRS_887A_888B_OK
        lda ENEMY_SFX_TABLE,X                   // Get SFX byte from lookup table 
        and #%00010000
        beq BRS_8888                            // L_BRS_8888_887F_OK
        stx ZP_TEMP_VAR_1 
        jsr JSR_888E                            // L_JSR_888E_8883_OK

        ldx ZP_TEMP_VAR_1 
BRS_8888:                                        // L_BRS_8888_887F_OK
        inx 
        cpx #%00010000                          // $10
        bne BRS_887A                             // L_BRS_887A_888B_OK
        rts 

JSR_888E:
        lda ENEMY_SFX_TABLE,X 
        and #$0F
        sta ZP_COUNTER 
        tay 
        lda TABLES.ColourCycle_Table,Y                 //$8938
        sta BACKGROUNDCOLOUR1                  //  Background Color 1, Multi-Color Register 0
        lda #$0F
        sec 
        sbc ZP_COUNTER 
        sta ZP_COUNTER 
        lda #CHAR_SPACE                        // 32 Space Char
        sta CHARTOPLOT 
        jsr JSR_88D7                            // L_JSR_88D7_88A7_OK
        inc ZP_COUNTER 
        dec ENEMY_SFX_TABLE,X 
        lda ENEMY_SFX_TABLE,X 
        cmp #$0F
        bne BRS_88D3                            // L_BRS_88D3_88B4_OK
        lda #$00
        sta ENEMY_X_POS_TABLE,X 

BRS_88BB:                                        // L_BRS_88BB_88C0_OK
        jsr UTILS.JSR_8E09                            // L_JSR_8E09_88BB_OK
        dec $3C 
        bne BRS_88BB
        lda $3B 
        sta $3C 
        lda #RED
        sta BACKGROUNDCOLOUR1                   //  Background Color 1, Multi-Color Register 0
        dec $20 
        bne !Exit+
        jmp JMP_8949                            // L_JMP_8949_88CF_OK

    !Exit:                                           // L_BRS_88D2_88CD_OK
        rts 

BRS_88D3:                                        // L_BRS_88D3_88B4_OK
        lda #CHAR_ENEMY_FRAGMENT                                // Enemy Explosion Char
        sta CHARTOPLOT 
// Plot Enemies on screen
JSR_88D7:
        stx ZP_TEMP_VAR_2 
        lda ENEMY_X_POS_TABLE,X                     // Get Enemy X position 
        sec 
        sbc ZP_COUNTER 
        sta SCREENCOLUMNTOPLOT 
        lda ENEMY_Y_POS_TABLE,X                     // Get Enemy Y position
        sec 
        sbc ZP_COUNTER 
        sta SCREENROWTOPLOT 
        jsr JSR_890A                            // L_JSR_890A_88E9_OK

        lda ENEMY_Y_POS_TABLE,X 
        clc 
        adc ZP_COUNTER 
        sta SCREENROWTOPLOT 
        jsr JSR_890A                            // L_JSR_890A_88F4_OK
        lda ENEMY_X_POS_TABLE,X 
        clc 
        adc ZP_COUNTER 
        sta SCREENCOLUMNTOPLOT 
        jsr JSR_890A                            // L_JSR_890A_88FF_OK
        lda ENEMY_Y_POS_TABLE,X 
        sec 
        sbc ZP_COUNTER 
        sta SCREENROWTOPLOT 

JSR_890A:
        lda SCREENCOLUMNTOPLOT 
        and #%10000000                          // $80
        beq BRS_8911                            // L_BRS_8911_890E_OK

ExitEnemyExplode:                               // JMP_8910
        rts 

BRS_8911:                                        // L_BRS_8911_890E_OK
        lda SCREENCOLUMNTOPLOT 
        cmp #27                                 // Have we reached Far Right column of game area
        bpl ExitEnemyExplode                    // L_BRS_8910_8915_OK

        lda SCREENROWTOPLOT 
        and #%10000000                          // $80
        bne ExitEnemyExplode                    // L_BRS_8910_891B_OK

        lda SCREENROWTOPLOT 
        cmp #24                                 // Have we reached Row 24 bottom of screen?
        bpl ExitEnemyExplode                    // L_BRS_8910_8921_OK

        jsr UTILS.GetScreenRowAddress                 // L_JSR_8046_8923_OK
        cmp #$20                                // Is it 'SPACE'?
        beq plotBaddie                            // L_BRS_8933_8928_OK
        cmp #CHAR_ENEMY_FRAGMENT                // Enemy Explosion Char
        beq plotBaddie                          // BRS_8933
 
        ldx ZP_TEMP_VAR_2 
        jmp ExitEnemyExplode                            // L_JMP_8910_8930_OK

plotBaddie:
        jsr UTILS.CharPlot                            // L_JSR_804C_8933_OK
        ldx ZP_TEMP_VAR_2 

BRS_8938:                                        // L_BRS_8938_8953_OK
        rts 

JMP_8949:                                        // L_JMP_8949_88CF_OK
        dec $17
        lda $1F 
        sta $20 
        lda $17 
        cmp #$0A
        bne BRS_8938                            // L_BRS_8938_8953_OK
        inc $17 

BRS_8957:
        rts 

//=============================================================================
//
//=============================================================================

JMP_8B04:
        lda SCOREBOARDVECTORLO                  // Scoreboard vector lo byte 
        sta ZP_COUNTER 
        jsr PLAYER.UpdatePlayerScore                   // L_JSR_941E_8B08_OK
        lda SCOREBOARDVECTORHI                    // Scoreboard vector Hi byte  
        sta ZP_TEMP_VAR_1 
        ldx #41                                 // $29
    BRS_8B11:                                         // L_BRS_8B11_8B1C_OK
        dec ZP_COUNTER 
        lda ZP_COUNTER 
        cmp #$FF
        bne BRS_8B1B                            // L_BRS_8B1B_8B17_OK
        dec ZP_TEMP_VAR_1 
    BRS_8B1B:                                        // L_BRS_8B1B_8B17_OK
        dex 
        bne BRS_8B11

        ldy #$08
    !Loop:                                        // L_BRS_8B20_8B28_OK
        lda (ZP_COUNTER),Y 
        cmp #$20                                // 'Space' Char
        bne BRS_8B41                            // L_BRS_8B41_8B24_OK
        dey 
        dey 
        bne !Loop-                            // L_BRS_8B20_8B28_OK

BRS_8B2A:                                        // L_BRS_8B2A_8B47_OK
        lda NUMPLAYERS 
        beq GameOver                            // L_BRS_8B35_8B2C_OK
        cmp #$02
        beq GameOver                            // L_BRS_8B35_8B30_OK
        jmp JMP_8B74                            // L_JMP_8B74_8B32_OK

GameOver:
       jmp MAINGAMELOOP.GameOver

BRS_8B41:                                        // L_BRS_8B41_8B24_OK
        lda #$20
        sta (ZP_COUNTER),Y 
        cpy #$02
        beq BRS_8B2A                            // L_BRS_8B2A_8B47_OK
        jmp JMP_8B74                            // L_JMP_8B74_8B49_OK



JMP_8B74:
        jsr SCREEN.VICScreenBlank                      // L_JSR_8B4C_8B74_OK
        jsr INIT.GetLevelParams                            // L_JSR_901A_8B77_OK
        jmp MAINGAMELOOP.JMP_8301                            // L_JMP_8301_8B7A_OK

// If CMDR key pressed clear screen of enemies                                                 

SmartBomb:
        jsr UTILS.SmartBomb


// This routine runs every game loop                                 // L_JSR_8C8A_8352_OK
JSR_8C8A:
        lda SPRITE_6_X_POSITION  
        beq !Exit+                                       // L_BRS_8C89_8C8C_OK
        dec $2E 
        bne !Exit+                                       // L_BRS_8C89_8C90_OK
        lda $2D 
        sta $2E 
 
        lda SPRITE_6_X_POSITION  
        cmp #$FF                                        // Spriye 6 X pos >255?
        bne !Jump+
        jmp L_JMP_8D78_8C9C_OK
    !Exit:
        rts    

    !Jump:                                                     // L_BRS_8C9F_8C9A_OK
        jsr L_JSR_8D89_8C9F_OK
        dec $29 
        bne L_BRS_8CE7_8CA4_OK
        lda $28 
        and #$80                        // %10000000
        beq L_BRS_8CB0_8CAA_OK
        inc $26 
        inc $26 
L_BRS_8CB0_8CAA_OK:
// ------------------------------
        dec SPRITE_6_X_POSITION  
        inc SPRITEPOINTER6 
        lda SPRITEPOINTER6 
        cmp #Spr13_ZAP                                // Sprite 13 $3300 $CC ZAP
        bne L_BRS_8CC1_8CBA_OK
        lda #Spr10_IDS_Frame_1                                // Sprite 10 $3240 $C9 IDS Frame 1
        sta SPRITEPOINTER6 
// ------------------------------
L_BRS_8CC1_8CBA_OK:
// ------------------------------
        lda SPRITE_6_X_POSITION  
        cmp #31
        bne L_BRS_8CD4_8CC5_OK
        lda #48
        sta $2C 
        lda $28 
        ora #$80                // %10000000
        sta $28 
        jmp L_JMP_8CE4_8CD1_OK
// ------------------------------
L_BRS_8CD4_8CC5_OK:
// ------------------------------
        lda SPRITE_6_X_POSITION  
        cmp #240
        bne L_BRS_8CE4_8CD8_OK
        lda #48
        sta $2C 
        lda $28 
        and #%01111111
        sta $28 
// ------------------------------
L_JMP_8CE4_8CD1_OK:
L_BRS_8CE4_8CD8_OK:
// ------------------------------
        jsr SOUND.L8D6A
// ------------------------------
L_BRS_8CE7_8CA4_OK:
// ------------------------------
        dec $2B 
        bne L_BRS_8D1D_8CE9_OK
        lda $2A 
        and #$80                // %10000000
        beq L_BRS_8CF5_8CEF_OK
        inc SPRITE_6_Y_POSITION 
        inc SPRITE_6_Y_POSITION 
// ------------------------------
L_BRS_8CF5_8CEF_OK:
// ------------------------------
        dec SPRITE_6_Y_POSITION 
        lda SPRITE_6_Y_POSITION 
        cmp #$3F
        bne L_BRS_8D0A_8CFB_OK
        lda #$30
        sta $2C 
        lda $2A 
        ora #$80
        sta $2A 
        jmp JMP_8D1A
// ------------------------------
L_BRS_8D0A_8CFB_OK:
// ------------------------------
        lda SPRITE_6_Y_POSITION 
        cmp #Spr1_X_Laser_Upright
        bne L_BRS_8D1A_8D0E_OK
        lda #$30
        sta $2C 
        lda $2A 
        and #$7F
        sta $2A 
// ------------------------------
L_JMP_8D1A_8D07_OK:
L_BRS_8D1A_8D0E_OK:
// ------------------------------
JMP_8D1A:
        jsr SOUND.L8D71
// ------------------------------
L_BRS_8D1D_8CE9_OK:
// ------------------------------
        lda SPRITE_6_X_POSITION 
        sta SPRITE6_X                          //  Sprite 6 X Pos
        lda SPRITE_6_Y_POSITION 
        sta SPRITE6_Y                          //  Sprite 6 Y Pos
        dec $2C 
        bne L_BRS_8D2E_8D29_OK
        jsr SOUND.DeathSatSFX                    //L_JSR_8C51_8D2B_OK
// ------------------------------
L_BRS_8D2E_8D29_OK:
// ------------------------------
        lda SPRSPRCOLLISION 
        and #%01000000                           // $40 Check for Sprite 6 collision
        beq !Exit+                              // L_BRS_8D69_8D32_OK

        lda SPRITE_6_COLOUR 
        and #$07
        ora #$01
        sta SPRITECOLOUR6                          //  Sprite 6 Color
        dec SPRITE_6_COLOUR 
        bne !Exit+                        // L_BRS_8D69_8D3F_OK

        lda #$FF
        sta SPRITE_6_X_POSITION 
        lda #Spr13_ZAP                                // Sprite 13 $3300 $CC ZAP
        sta SPRITEPOINTER6 
        lda #$80
        sta SPRITE_6_COLOUR 
        lda #$00
        sta VOICE2CTRREG                          //  Voice 2: Control Register
        ldy #$04
        ldx #$01
        jsr PLAYER.UpdateScore                            // L_JSR_8976_8D57_OK
        lda #$08
        sta $21 
        lda #$20
        sta $4001 
        sta VOICE2FQHIGH                          //  Voice 2: Frequency Control - High-Byte
        jsr SOUND.InitV2Wave                            // L_JSR_85B6_8D66_OK
                                                        // L_BRS_8D69_8D32_OK
                                                       // L_BRS_8D69_8D3F_OK
    !Exit:
        rts 

// ------------------------------
L_JSR_8D6A_8C83_OK:
L_JSR_8D6A_8CE4_OK:
// ------------------------------
        lda $28 
        and #%01111111                                  // $7F
        sta $29 
        rts 
// ------------------------------
L_JSR_8D71_8C86_OK:
L_JSR_8D71_8D1A_OK:
// ------------------------------
        lda $2A 
        and #%01111111                                  // $7F
        sta $2B 
// ------------------------------
//L_BRS_8D77_8D7F_OK:
// ------------------------------
        rts 

// ------------------------------
L_JMP_8D78_8C9C_OK:
// ------------------------------
        lda SPRITE_6_COLOUR 
        sta SPRITECOLOUR6                          //  Sprite 6 Color
        dec SPRITE_6_COLOUR 
        bne !Exit+
        lda #$00
        sta SPRITE6_X                          //  Sprite 6 X Pos
        sta SPRITE_6_X_POSITION 
 !Exit:
        rts 
// ------------------------------
L_JSR_8D89_8C9F_OK: //Lightning Bolts?
// ------------------------------
        dec RASTERVALUE 
        bne !Exit+

        lda VICRASTER                          //  Raster Position
        and #%01111111                          //
        ora #%00000001
        sta RASTERVALUE 
        lda SPRITE_7_X_POSITION 
        bne !Exit+
        sta VOICE3CTRREG                          //  Voice 3: Control Register
        inc $35 
        lda $35 
        and #%00000001
        clc 
        adc #Spr14_Vertical_Spark                                
        sta SPRITEPOINTER7 
        lda SPRITE_6_X_POSITION 
        sta SPRITE_7_X_POSITION 
        lda SPRITE_6_Y_POSITION 
        sta SPRITE_7_Y_POSITION 
        lda #Spr1_X_Laser_Upright
        sta $4002 
        sta VOICE3FQHIGH                          //  Voice 3: Frequency Control - High-Byte
        jsr SOUND.InitV3NoiseGen                            // L_JSR_85BC_8DB9_OK
// ------------------------------
//L_BRS_8DBC_8DC7_OK:
//L_BRS_8DBC_8DF1_OK:
//L_BRS_8DBC_8DFC_OK:
!Exit:
// ------------------------------
        rts 

//********************************************************************
                                                // L_JSR_8DBD_8355_OK
GameLoop_3:
        dec $37 
        beq !Jump+
        rts
 
    !Jump:    
        lda $36 
        sta $37 
        lda SPRITE_7_X_POSITION 
        beq !Exit+
        sta SPRITE7_X                          //  Sprite 7 X Pos
        lda SPRITE_7_Y_POSITION 
        sta SPRITE7_Y                          //  Sprite 7 Y Pos
        dec $4002                       // SFX
        lda $4002 
        sta VOICE3FQHIGH                          //  Voice 3: Frequency Control - High-Byte
        bne !Jump+
        lda #$00
        sta VOICE3CTRREG                          //  Voice 3: Control Register

    !Jump:
        inc SPRITECOLOUR7                          //  Sprite 7 Color
        lda SPRITEPOINTER7 
        cmp #Spr14_Vertical_Spark                                   // Lighting Bolt Vertical
        bne !Jump+                                        //L_BRS_8DF6_8DE9_OK
        inc SPRITE_7_Y_POSITION 
        lda SPRITE_7_Y_POSITION 
        cmp #232                                        // 232 - Far right of travel
        bne !Exit+
        jmp !Jump++                                        //L_JMP_8DFE_8DF3_OK

    !Jump:                                               //L_BRS_8DF6_8DE9_OK:
        inc SPRITE_7_X_POSITION 
        lda SPRITE_7_X_POSITION 
        cmp #240                                        // 240
        bne !Exit+

    !Jump:                                            //L_JMP_8DFE_8DF3_OK:
        lda #$00
        sta SPRITE7_X                          //  Sprite 7 X Pos
        sta SPRITE_7_X_POSITION 
        sta VOICE3CTRREG                          //  Voice 3: Control Register

    !Exit:                                             // L_BRS_8E08_8E0B_OK
                                                // L_BRS_8E08_8E13_OK
        rts 

/*// =======================
JSR_8E09:        // Routine to decrement threshold 
        dec $3E 
        bne !Exit-
        lda $3D 
        sta $3E 
        lda $38 
        bne !Exit-

        txa 
        pha
        ldy THRESHOLDVALUE              // Get current Threshold value 
        lda SCNROW22 + 30,Y                     // $078E Threshold on screen col 30 row 20
        ldx #$08
    !Loop:                             // BRS_8E1E
        cmp $8E6F,X                     // Threshold indicator chars 
        beq BRS_8E26
        dex 
        bne !Loop-                 // BRS_8E1E
BRS_8E26:
        lda $8E6E,X 
        sta SCNROW22 + 30,Y              // Store threshold guage on screen
        cmp #$20                        // Last char is a space
        beq L_BRS_8E33_8E2E_OK
// ------------------------------
L_BRS_8E30_8E35_OK:
L_JMP_8E30_8E6C_OK:
// ------------------------------
        pla 
        tax 
        rts 
// ------------------------------
L_BRS_8E33_8E2E_OK:
// ------------------------------
        dec THRESHOLDVALUE              // Decrement Threshold Value 
        bne L_BRS_8E30_8E35_OK          // If value still pozitive return

        lda #$14                        // 20
        sta $38 
        ldx #$00
// ------------------------------
L_BRS_8E3D_8E51_OK:
// ------------------------------
        lda ENEMY_SFX_TABLE,X 
        and #$10
        bne L_BRS_8E4E_8E42_OK
        lda ENEMY_X_POS_TABLE,X 
        beq L_BRS_8E4E_8E47_OK
        lda #$1F
        sta ENEMY_SFX_TABLE,X 
// ------------------------------
L_BRS_8E4E_8E42_OK:
L_BRS_8E4E_8E47_OK:
// ------------------------------
        inx 
        cpx #$10
        bne L_BRS_8E3D_8E51_OK
        lda #$00
        sta VOICE2CTRREG                          //  Voice 2: Control Register
        lda #$01
        sta BACKGROUNDCOLOUR0                          //  Background Color 0
        lda #$30
        sta $4001 
        sta VOICE2FQHIGH                          //  Voice 2: Frequency Control - High-Byte
        lda #$08
        sta $21 
        jsr SOUND.InitV2Wave                            // L_JSR_85B6_8E69_OK
        jmp L_JMP_8E30_8E6C_OK

// $8E6F  'Threshold' indicator on play screen        
        .byte   $20,$72,$73,$74,$75,$76,$77,$78,$79*/
 //============================================================================         
ZoneCleared:                                       // L_JMP_8E78_86AD_OK
        ldx #$00
        lda #WHITE
        sta COLOURTOPLOT 
        lda #$0C                                // Row 12
        sta SCREENROWTOPLOT 
        lda #$05                                // Column 5
        sta SCREENCOLUMNTOPLOT 

    !Loop:                              // L_BRS_8E86_8E97_OK
        lda TXT_ZONE_CLEARED,X                             // 'Zone 00 Cleared' text
        sta CHARTOPLOT 
        stx ZP_TEMP_VAR_2 
        jsr UTILS.CharPlot                            // L_JSR_804C_8E8D_OK
        inc SCREENCOLUMNTOPLOT 
        ldx ZP_TEMP_VAR_2 
        inx 
        cpx #15                                 // No.of chars to plot
        bne !Loop-                  // L_BRS_8E86_8E97_OK

PlotCurrentLevelNumber:                          // Add level number to above text
          
        ldx CURRENTLEVELNUMBER 
    !Loop:                              // L_BRS_8E9B_8EAE_OK
        inc $05EB                               // Plot Zone No. to screen 
        lda $05EB 
        cmp #$3A                                // Is first digit = 9?
        bne !Jump+                          // L_BRS_8EAD_8EA3_OK
        lda #$30                                // Store a '0' in next digit
        sta $05EB 
        inc $05EA 

    !Jump:                                      // L_BRS_8EAD_8EA3_OK
        dex 
        bne !Loop-                  // L_BRS_8E9B_8EAE_OK

        lda #$00
        sta VOICE1CTRREG                          //  Voice 1: Control Register
        sta VOICE2CTRREG                          //  Voice 2: Control Register
        sta VOICE3CTRREG                          //  Voice 3: Control Register
        lda #$0C
        sta ZP_TEMP_VAR_2 
// ------------------------------
L_BRS_8EBF_8EE1_OK:
// ------------------------------
        lda #$20
        sta $4000 
        sta VOICE1FQHIGH                          //  Voice 1: Frequency Control - High-Byte
        jsr SOUND.InitV1Wave                            // L_JSR_85B0_8EC7_OK
// ------------------------------
L_BRS_8ECA_8EDD_OK:
// ------------------------------
        inc $4000 
        inc BACKGROUNDCOLOUR1                           //  Background Color 1, Multi-Color Register 0
        ldy #$00
// ------------------------------
L_BRS_8ED2_8ED3_OK:
// ------------------------------
        dey 
        bne L_BRS_8ED2_8ED3_OK
        lda $4000 
        sta VOICE1FQHIGH                          //  Voice 1: Frequency Control - High-Byte
        cmp #$80
        bne L_BRS_8ECA_8EDD_OK
        dec ZP_TEMP_VAR_2 
        bne L_BRS_8EBF_8EE1_OK
        lda #$02
        sta BACKGROUNDCOLOUR1                           //  Background Color 1, Multi-Color Register 0
        lda #$00
        sta VOICE1CTRREG                          //  Voice 1: Control Register
        lda CURRENTLEVELNUMBER 
        asl 
        sta ZP_TEMP_VAR_2 
// ------------------------------
L_BRS_8EF2_8F1E_OK:
// ------------------------------
        lda #$80
        sta $4001 
        sta VOICE2FQHIGH                          //  Voice 2: Frequency Control - High-Byte
        jsr SOUND.InitV2Wave                            // L_JSR_85B6_8EFA_OK
// ------------------------------
L_JMP_8EFD_1759_OK:
L_JMP_8EFD_8F19_OK:
// ------------------------------
        dec $4001 
        ldy #$07
        ldx #$01
        jsr PLAYER.UpdateScore                            // L_JSR_8976_8F04_OK
        ldy #$00
// ------------------------------
L_BRS_8F09_8F0A_OK:
// ------------------------------
        dey 
        bne L_BRS_8F09_8F0A_OK
        lda $4001 
        sta VOICE2FQHIGH                          //  Voice 2: Frequency Control - High-Byte
        cmp #$10
        beq L_BRS_8F1C_8F14_OK
        dec BACKGROUNDCOLOUR2                          //  Background Color 2, Multi-Color Register 1
        jmp L_JMP_8EFD_8F19_OK
// ------------------------------
L_BRS_8F1C_8F14_OK:
// ------------------------------
        dec ZP_TEMP_VAR_2 
        bne L_BRS_8EF2_8F1E_OK
        jsr SCREEN.ElectricShots                               // L_JSR_9443_8F20_OK
        lda #$28
        sta ZP_TEMP_VAR_2 
        lda #GRAY3
        sta BACKGROUNDCOLOUR2                          //  Background Color 2, Multi-Color Register 1
        lda #$00
        sta VOICE2CTRREG                          //  Voice 2: Control Register
        jsr SOUND.InitV2Wave                            // L_JSR_85B6_8F31_OK
// ------------------------------
L_BRS_8F34_8F4E_OK:
// ------------------------------
        lda #$80
        sta $4001 
        sta VOICE2FQHIGH                          //  Voice 2: Frequency Control - High-Byte
// ------------------------------
L_BRS_8F3C_8F4A_OK:
// ------------------------------
        dec $4001 
        ldy #$30
// ------------------------------
L_BRS_8F41_8F42_OK:
// ------------------------------
        dey 
        bne L_BRS_8F41_8F42_OK
        lda $4001 
        sta VOICE2FQHIGH                          //  Voice 2: Frequency Control - High-Byte
        bne L_BRS_8F3C_8F4A_OK
        dec ZP_TEMP_VAR_2 
        bne L_BRS_8F34_8F4E_OK
        jmp IncreaseLevelNumber                         // L_JMP_8F62_8F50_OK


// $8F53 'Zone 00 Cleared' in CBM Screen Codes
TXT_ZONE_CLEARED: 
       .byte $1A,$0F,$0E,$05,$20,$30,$30,$20,$03,$0C,$05,$01,$12,$05,$04
     

IncreaseLevelNumber:                             // L_JMP_8F62_8F50_OK
        inc CURRENTLEVELNUMBER 
        lda CURRENTLEVELNUMBER 
        cmp #20                        // Max No. Levels = 20
        bne !Jump+                        // L_BRS_8F6C_8F68_OK
        dec CURRENTLEVELNUMBER 

!Jump:                                    // L_BRS_8F6C_8F68_OK
       jmp MAINGAMELOOP.NewLevel                   // L_JMP_82EC_8F6C_OK


