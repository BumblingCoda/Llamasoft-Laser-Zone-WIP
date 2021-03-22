
GameLoopTimer:

    dec GAMELOOPTIMER2 
    beq !Jump+ 
    rts 

!Jump:
    jsr UTILS.GetJoyStatus 
    jsr UTILS.GetCollisionStatus
    lda #$2C                          //Reset game tick counter
    sta GAMELOOPTIMER1                //Reset
    lda TRAINMODEFLAG                 //Training Mode Selected?
    bne !Jump+                        //If Yes, dont plot Baddies 
    jsr PlotBaddies                   //JSR_8641
    lda SPRSPRCOLLISION 
    and #%00000011                         //Check for Sprite 0 & 1 collisions                                
    beq !Jump+
    jmp PLAYER.PlayerDeath //$86A0       

!Jump:
    jsr MovePlayers
    jsr UTILS.CheckForBackgroundCollision
    jsr FireControl
    jsr GameLoopTimer




!Continue:  
    lda #$18
    sta GAMELOOPTIMER2 
    jsr CheckPlayerBulletFired
    jsr SOUND.SoundFX_1
    jsr UTILS.CheckForCMDRKey
    jsr SOUND.SoundFX_2

    ldx #$04
!Loop:                                        // L_BRS_8501_8513_OK
    lda SPRITE1_X,X                         //  Get X position for Sprites 2 - 5
    beq !Jump+
    jsr JSR_8516                            // L_JSR_8516_8506_OK

!Jump:                                        // L_BRS_8509_8504_OK
    lda SPRITE3_X,X                         // Get Sprite 3+ X Pos
    beq !Jump+
    jsr JSR_8563                            // L_JSR_8563_850E_OK

!Jump:                                        // L_BRS_8511_850C_OK
    dex 
    dex 
    bne !Loop-
    rts 
//=============================================================================
//
//=============================================================================
                                                // L_JSR_8516_8506_OK
JSR_8516:
    dec SPRITE1_Y,X                          //  Sprite 1 Y Pos
    lda SPRITE1_Y,X                          //  Sprite 1 Y Pos
    cmp #$20                                // 32 left edge of screen
    beq ResetSprite_X_pos 
    txa 
    clc 
    ror
    tay 
    lda SPRITEPOINTER1,Y 
    cmp #Spr6_Vertical_Bullet_Angled        // Sprite 6 $3140 $C5 Angled Bullet
    bne !Jump+
    inc SPRITE1_X,X                          //  Sprite 1 X Pos
    lda SPRITE1_X,X                          //  Sprite 1 X Pos
    cmp #$F0                                // 240 Far right of track?
    beq ResetSprite_X_pos                  // BRS_855D

!Jump:
    lda SPRBGNDCOLLISION                    // Check Sprites 2 & 3 for bkgrn collision  
    and #%00001100                          // $0C
    beq !Exit+                        // BRS_855C
    lda SPRITE1_X,X                          //  Y-Axis Laser X Pos
    sta $1A 
    lda SPRITE1_Y,X                          //  Sprite 1 Y Pos
    sta $1B 
    lda #$00
    sta SPRITE1_X,X                          //  Sprite 1 X Pos
    sta $1C 
    stx ZP_TEMP_VAR_2 
    jsr ENEMY.EnemyDeath                            // L_JSR_87D3_854E_OK
    ldx ZP_TEMP_VAR_2 
    lda $1C 
    beq !Exit+ 
    lda $1A 
    sta SPRITE1_X,X                       
!Exit:
    rts 

ResetSprite_X_pos:
    lda #$00
    sta SPRITE1_X,X
    rts 
//=============================================================================
//
//=============================================================================
JSR_8563:
        dec SPRITE3_X,X                          //  Sprite 3 - 6 (Bullet)X Pos
        lda SPRITE3_X,X                          //  Sprite 3 - 6 X Pos
        cmp #MAX_BULLET_TRAVEL_LEFT              // Pos 32 - Far left of game screen
        beq TurnOffBullets                     // BRS_85AA
        txa 
        clc 
        ror 
        tay 
        lda SPRITEPOINTER3,Y 
        cmp #Spr8_Horizontal_Bullet_Angled              // Sprite 8 $31C0 $C7 Downward Angled Bullet
        bne L_BRS_8582                                  // L_BRS_8582_8576_OK
        inc SPRITE3_Y,X                                 //  Sprite 3 - 6 Y Pos
        lda SPRITE3_Y,X                                 //  Sprite 3 - 6 Y Pos
        cmp #MAX_BULLET_TRAVEL_RIGHT                    // 228 Far right of game screen
        beq TurnOffBullets                             // L_BRS_85AA_8580_OK

L_BRS_8582:                                              // L_BRS_8582_8576_OK
        lda SPRBGNDCOLLISION                            // Check if a bullet sprite has hit a background char
        and #%00110000                            // $30 Sprites 4 & 5 bkgrnd collision?
        beq !Exit+                             // L_BRS_855C_8586_OK

        lda SPRITE3_X,X                          //  Sprite 3-6 X Pos
        sta $1A 
        lda SPRITE3_Y,X                          //  Sprite 3-6 Y Pos
        sta $1B 
        lda #$00
        sta SPRITE3_X,X                          // Set Sprite 3 X Pos to 0
        sta $1C 
        stx ZP_TEMP_VAR_2 
        jsr ENEMY.EnemyDeath                            // Enemy Char Death L_JSR_87D3_859B_OK
        ldx ZP_TEMP_VAR_2 
        lda $1C 
        beq !Exit+
        lda $1A 
        sta SPRITE3_X,X                          //  Sprite 3-6 X Pos

!Exit: //BRS_85A9                                           // L_BRS_85A9_85A2_OK
        rts 

TurnOffBullets:
        lda #$00
        sta SPRITE3_X,X
        rts 

//=============================================================================
//
//=============================================================================
CheckPlayerBulletFired:                                  // JSR_85DD
        lda PLAYER_BULLET_FIRED                    // 0 = no bullet fired 
        bne BulletFired                             // L_BRS_85E2_85DF_OK
        rts 

BulletFired:                                         // L_BRS_85E2_85DF_OK
        dec $4000 
        lda $4000 
        sta VOICE1FQHIGH                          //  Voice 1: Frequency Control - High-Byte
        cmp PLAYER_BULLET_FIRED                   // Get value in location $15
        bne !Exit+                            // L_BRS_85DC_85ED_OK

        lda #$40
        sta $4000 
        sta VOICE1FQHIGH                          //  Voice 1: Frequency Control - High-Byte
        lda PLAYER_BULLET_FIRED
        sec 
        sbc #$08
        sta PLAYER_BULLET_FIRED 
        cmp #$08                                // Exit routine if = 8
        bne !Exit+                            // L_BRS_85DC_8600_OK

        lda #$00
        sta PLAYER_BULLET_FIRED                   // Reset Bullet Flag 
        sta VOICE1CTRREG                          //  Voice 1: Control Register
    !Exit:   
        rts 

//=============================================================================
//
//=============================================================================
    JMP_8301:
            lda SPRITE2SPRITECOLL                   //  Clear Sprite to Sprite Collision Detect
            jsr SCREEN.DrawInitLasers                      // L_JSR_82BF_8304_OK
            lda #$00
            sta ELECTRO_SFX_TIMER
            sta SPRSPRCOLLISION 
            sta SPRBGNDCOLLISION 
            sta $1D                                 // Possibly SFX vars
            sta $1E 
            sta SPRITE_6_X_POSITION 
            sta SPRITE_7_X_POSITION 
            sta VOICE1CTRREG                          //  Voice 1: Control Register
            sta VOICE2CTRREG                          //  Voice 2: Control Register
            sta VOICE3CTRREG                          //  Voice 3: Control Register

        SetSprites2to7:
            ldx #$0C                                 // 12
        !Loop:                                     // L_BRS_8322_8326_OK
            sta SPRITE1_Y,X                          // Set Sprites 2-7 Y pos. to 12
            dex 
            bne !Loop-                         // BRS_8322  
          
            ldx #$00
        !Loop:                                        // L_BRS_832A_8334_OK
            sta ENEMY_X_POS_TABLE,X                             // Clear out Enemy Char location arrays 
            sta ENEMY_Y_POS_TABLE,X 
            sta ENEMY_SFX_TABLE,X 
            inx 
            bne !Loop-
            lda #$03
            sta $1F 
            sta $20 
            lda #$18
            sta RASTERVALUE 
            lda #$08
            sta $36 
            lda $17 
            nop 
            sta $17 
            rts     //return to Maingameloop
//=============================================================
//Main game loop                              
    

//============================================================
//Routine to move lasers 
//============================================================
MovePlayers:                   //$835E
    
    lda SPRITEPOINTER0                      //Get Sprite 0 data address 
    sta ZP_COUNTER 
    cmp Spr1_X_Laser_Upright               //Is it Sprite 1 X-Axis Laser Upright
    beq !Jump+
    lda JOYSTICK_1 
    and #%00010000                          //$10 fire button pressed?
    bne !Jump++                            

!Jump:
    lda Spr1_X_Laser_Upright          
    sta ZP_COUNTER 
    lda JOYSTICK_1 
    and #%00011001                          //$19 Joy 1 R U & F
    cmp #%00011001                      //Is R U & F pressed on Joy 1?
    bne !Jump+
    inc ZP_COUNTER 

!Jump: 
    lda SPRITEPOINTER1 
    sta ZP_TEMP_VAR_1 
    cmp Spr3_Y_Laser_Upright              //Sprite 3 $32080 $C2 Vertical Laser
    beq !Jump+
    lda JOYSTICK_2 
    and #%00010000                           //Joy 2's fire button pressed?
    bne !Jump++

!Jump:                                          // L_BRS_83C3_83BB_OK
    lda #Spr3_Y_Laser_Upright                   // Get Y Axis Laser Upright
    sta ZP_TEMP_VAR_1                                                 // Store here
    lda JOYSTICK_2
    and #%00010110                              // $16 00010110 Joy 2 D L & F
    cmp #%00010110
    bne !Jump+
    
    inc ZP_TEMP_VAR_1                         // Get Sprite Pointer from location and inc x1 
!Jump:                                      //BRS_83D1 
    lda ZP_TEMP_VAR_1 
    sta SPRITEPOINTER1 
    lda ZP_COUNTER 
    sta SPRITEPOINTER0 
    lda SPRITEPOINTER0 
    cmp #Spr2_X_Laser_Angled                  // $C1 Laser Angled
    beq MoveLaser2Up 

MoveLaser1Left:
    lda JOYSTICK_1                      // Get Joystick Position 
    and #%00000100                      // $04 Joystick Left?
    beq MoveLaser1Right                 
    dec SPRITE0_X                       //  Move Laser to the Left
    lda SPRITE0_X                       //  Store in Register
    cmp #$18                            // Has the bottom laser reached the Far left?
    bne MoveLaser1Right
    lda #$D0                            // If yes, rap around bottom laser to far right
    sta SPRITE0_X                       // Store new pos. in register
                                         
MoveLaser1Right:                        
    lda JOYSTICK_1 
    and #%1000                           //8 = Joy 1 Right
    beq MoveLaser2Up                    
    inc SPRITE0_X                       //  Sprite 0 X Pos
    lda SPRITE0_X                       //  Sprite 0 X Pos
    cmp #$D1                            // Have we reached far right of track?
    bne MoveLaser2Up
    lda #$19                            // Wrap around Laser
    sta SPRITE0_X                       //  Sprite 0 X Pos

MoveLaser2Up:                           
    lda SPRITEPOINTER1 
    cmp #Spr4_Y_Laser_Angled            // Horizontal Laser
    beq CheckJoy_1_Fire
    lda JOYSTICK_2 
    and #$01                            // Joy 2 Up
    beq MoveLaser2Down                  
    dec SPRITE1_Y                       //  Move Sprite 1 up
    lda SPRITE1_Y                       //  Sprite 1 Y Pos
    cmp #$2F                            // Have we reached top of track?
    bne MoveLaser2Down
    lda #$D0                            // Yes,so wrap around
    sta SPRITE1_Y                       //  Sprite 1 Y Pos

MoveLaser2Down:                                                   
    lda JOYSTICK_2 
    and #$02                             // Joy 2 Down
    beq CheckJoy_1_Fire 
    inc SPRITE1_Y                        //  Sprite 1 Y Pos
    lda SPRITE1_Y                        //  Sprite 1 Y Pos
    cmp #$D1                             // Have we reached bottom of the track?
    bne CheckJoy_1_Fire
    lda #$30                             // Yes, so wrap around
    sta SPRITE1_Y                        //  Sprite 1 Y Pos
    rts
 
//=================================================================
//
//================================================================== 
FireControl:
 
    CheckJoy_1_Fire:
                                      // L_JSR_8C03_843D_OK check coll.
        lda JOYSTICK_1 
        and #%00010000  // #$10                                    // Joy 1 Fire Button Pressed?
        bne NoFireJoy1                                            // L_BRS_8457_8444_OK
        lda #$07                                                // Colour laser dish brown
        sta SPRITEMULTICOLOUR1                                  //  MC Mode Sprites 0-2 turn off Sprites 3-7                                                // L_JMP_844B_8461

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
        bne !Exit+                             // BRS_8471
        jmp JMP_84AF                                    // L_JMP_84AF_846E_OK

    !Exit:                                    // L_BRS_8471_846C_OK
        rts 

    BRS_8472:                                                // L_BRS_8472_845F_OK
        ldx #$04
    !Loop: 
        lda SPRITE1_X,X                                 // Get Sprites 2-6 X Pos
        beq VerticalBullets                                    // L_BRS_8480_8477_OK
        dex 
        dex 
        bne !Loop-
        jmp CheckJoy_2_Fire                            // L_JMP_844B_847D_OK

//=================================================================================
//
//=================================================================================
DoBullets:

        VerticalBullets:                                       // L_BRS_8480_8477_OK
            txa 
            clc 
            ror
            tay 
            lda #Spr5_Vertical_Bullet               // Sprite 5 $3100 $C4 Vertical (Y-Axis) Bullet                       
            sta SPRITEPOINTER1,Y 
            lda SPRITEPOINTER0                      // Get Laser1 sprite data pointer 
            cmp #Spr1_X_Laser_Upright               // Is X-Axis Laser pointed vertical?
            beq X_AxisLaserUpright
    
            lda #Spr6_Vertical_Bullet_Angled        // Get Sprite 6 $3140 $C5 definition 
            sta SPRITEPOINTER1,Y 

        X_AxisLaserUpright:
            lda #216                                // 
            sta SPRITE1_Y,X                         //Sprite 1 Y Pos
            lda SPRITE0_X                           //Get Laser 1 X Pos
            clc 
            adc #$08
            ldy SPRITEPOINTER0 
            cpy #Spr2_X_Laser_Angled                // Is Sprite 0 pointing to sprite2?
            bne !BulletSFX+                           
    
            adc #$08
        !BulletSFX:
            sta SPRITE1_X,X                         //  Sprite 1 X Pos
            jsr SOUND.BulletSFX
            jsr SOUND.InitV1Wave       
            jsr SOUND.BulletSFX
            rts

//==========================

        JMP_84AF:
            ldx #$04
        !Loop:                                       // L_BRS_84B1_84B8_OK
            lda SPRITE3_X,X                         // Get Sprites 3-6 X position
            beq HorizontalBullets                            // L_BRS_84BB_84B4_OK
            dex                                     // Skip Y location 
            dex 
            bne !Loop-
            rts 


        HorizontalBullets:                                        // L_BRS_84BB_84B4_OK
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
            cpy #Spr4_Y_Laser_Angled                // Sprite 4 $30C0 $C3 Y-Axis Laser Angled
            bne !Jump+
            adc #$08

        !Jump:                                        // L_BRS_84E4_84E0_OK
            sta SPRITE3_Y,X                         //  Sprite 3 Y Pos
            jsr SOUND.BulletSFX                           // L_JMP_860A_84E7_OK
            jsr SOUND.InitV1Wave  
            //jmp SOMEWHERE???
//======================================================================

//=============================================================================
//
//=============================================================================
    PlotBaddies:                                    ;JSR_8641:
        dec $1817 
        beq !Jump+
        rts 

    !Jump:                                         // L_BRS_8647_8644_OK
        lda $17 
        sta $1817 
        dec $1917                               // Counts down during attack waves 
        beq !Jump+
        jmp JMP_86A0                            // L_JMP_86A0_8651_OK

    !Jump:                                        // L_BRS_8654_864F_OK
        ldx #$00
        lda $16                                 // counts down during attack wave
        sta $1917 
        lda $38 
        jmp JMP_86A0                           // L_BRS_8651_865D_OK


    EnemyCharPosLooper:                             // L_BRS_865F_8665_OK
        lda ENEMY_X_POS_TABLE,X                             // Vertical Enemy Char X-Y locations 
        beq NoMoreVerticalEnemies              // Branch no attack wave
        inx 
        bne EnemyCharPosLooper 
        jmp JMP_86A0                            // L_JMP_86A0_8667_OK

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
        beq !Jump+
        inx 
        bne VerticalEnemyLooper
        jmp JMP_86A0                            // L_JMP_86A0_868A_OK
// ------------------------------
    !Jump:                                       // L_BRS_868D_8685_OK
// ------------------------------
        lda #$80                // 128
        sta ENEMY_SFX_TABLE,X 
        lda #$00
        sta ENEMY_Y_POS_TABLE,X                            // Enemy Char Y location array 
        iny 
        lda $A000,Y                          //  Restart Vectors
        and #$17
        sta ENEMY_X_POS_TABLE,X 

    JMP_86A0:                               //Check enemy count and decrease
        lda $38                             // Check Enemy count to go 
        beq !Jump+
        lda #$00
        sta BACKGROUNDCOLOUR0                    //  Background Color 0
        dec $38 
        bne !Jump+                              // If 0 jump to Zone Cleared
        jmp ZoneCleared                          // L_JMP_8E78_86AD_OK
    
    !Jump:                                         // L_BRS_86B0_86AB_OK
        ldx #$00

    GetEnemyPlotLocation:                                // L_BRS_86B2_86C4_OK
        lda ENEMY_X_POS_TABLE,X                             // Fetch enemy char X location
        beq GotLastEnemy                       // L_BRS_86C1_86B5_OK
        sta SCREENCOLUMNTOPLOT 
        lda ENEMY_Y_POS_TABLE,X                             // Fetch enemy char Y location 
        sta SCREENROWTOPLOT 
        jsr UTILS.PlotSpaceChar                        // L_JSR_8760_86BE_OK

    GotLastEnemy:                                        // L_BRS_86C1_86B5_OK
        inx 
        cpx #16                                // Max no of enemies?
        bne GetEnemyPlotLocation                            // L_BRS_86B2_86C4_OK

        inc $25                                  // game tic timer for enemies
        ldx #$00
    !Loop:                                        // L_BRS_86CA_86DC_OK
        lda ENEMY_X_POS_TABLE,X                    // Fetch enemy char X location
        beq BRS_86D9
        lda ENEMY_SFX_TABLE,X 
        and #%00010000                          // $10
        bne !Loop-
        jsr JSR_86DF                            // L_JSR_86DF_86D6_OK

    BRS_86D9:                                        // L_BRS_86D9_86D4_OK
        inx 
        cpx #16                                // Max no of enemies? // $10
        bne !Loop- 
        rts 

    JSR_86DF:        // SFX
        lda ENEMY_SFX_TABLE,X 
        and #%01000000                          // $40
        beq !Jump+
        jmp JMP_877F                            // L_JMP_877F_86E6_OK

    !Jump:                                         // L_BRS_86E9_86E4_OK
        lda ENEMY_SFX_TABLE,X 
        and #%10000000                          // $80
        beq !Jump+
        jmp JMP_872E                            // L_JMP_872E_86F0_OK

    !Jump:                                        // L_BRS_86F3_86EE_OK
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
        lda ENEMY_X_POS_TABLE,X                     // Get enemy char Y location to plot 
        sta SCREENCOLUMNTOPLOT  
        lda ENEMY_Y_POS_TABLE,X                     // Get enemy char X location to plot 
        sta SCREENROWTOPLOT 
        lda #$48                                    // Skull 1 Char
        sta CHARTOPLOT 
        lda ENEMY_SFX_TABLE,X 
        and #$01
        beq PlotEnemy
        lda #$4C                                        // Alternate Skull Char
        sta CHARTOPLOT 

    PlotEnemy:
        jsr UTILS.PrintCharTileSet                            // L_JSR_861E_8722_OK
        lda ENEMY_SFX_TABLE,X 
        eor #$01
        sta ENEMY_SFX_TABLE,X 
        rts 

    JMP_872E:
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
        lda #$50                // Spider Char
        sta CHARTOPLOT 
        lda ENEMY_SFX_TABLE,X 
        and #$01
        bne PlotEnemy                            // L_BRS_8722_8757_OK
        lda #$54                // Alternate Spider char
        sta CHARTOPLOT 
        jmp PlotEnemy                            // L_JMP_8722_875D_OK

    JMP_877F:
        lda ENEMY_SFX_TABLE,X 
        and #$80
        beq BRS_87B0                            // L_BRS_87B0_8784_OK
        jmp JMP_8789                            // L_JMP_8789_8786_OK

    JMP_8789:
        lda $25 
        and #$01
        beq BRS_87A9                            // L_BRS_87A9_878D_OK
        lda SPRITE0_X                         //  Sprite 0 X Pos
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
        jmp PlotSpider                            // L_JMP_8744_87AD_OK

        BRS_87B0:                                        // L_BRS_87B0_8784_OK
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


//===============================================================================


    JSR_886F:                                // Called every game cycle from main game loop
        dec $1E 
        beq !Jump+                            // L_BRS_8874_8871_OK
        rts 

    !Jump:                                        // L_BRS_8874_8871_OK
        lda $1D 
        sta $1E 

        ldx #$00
    !Loop:                                         // L_BRS_887A_888B_OK
        lda ENEMY_SFX_TABLE,X                             // Get SFX byte from lookup table 
        and #%00010000
        beq !Exit+                           // L_BRS_8888_887F_OK
        stx ZP_TEMP_VAR_1 
        jsr JSR_888E                            // L_JSR_888E_8883_OK

        ldx ZP_TEMP_VAR_1 
    !Jummp:                             // L_BRS_8888_887F_OK
        inx 
        cpx #%00010000                          // $10
        bne !Loop-                            // L_BRS_887A_888B_OK
 !Exit:
        rts 

    JSR_888E:
        lda ENEMY_SFX_TABLE,X 
        and #$0F
        sta ZP_COUNTER 
        tay 
        lda COLOURTABLE,Y 
        sta BACKGROUNDCOLOUR1                           //  Background Color 1, Multi-Color Register 0
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

//===========================================================================

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
        bne !Exit+                    // L_BRS_8910_891B_OK

        lda SCREENROWTOPLOT 
        cmp #24                                 // Have we reached Row 24 bottom of screen?
        bpl !Exit+                    // L_BRS_8910_8921_OK

        jsr UTILS.GetScreenRowAddress                 // L_JSR_8046_8923_OK
        cmp #$20                                // Is it 'SPACE'?
        beq PlotEnemyFragment                            // L_BRS_8933_8928_OK
        cmp #CHAR_ENEMY_FRAGMENT                // Enemy Explosion Char
        beq PlotEnemyFragment                   // BRS_8933
 
        ldx ZP_TEMP_VAR_2 
        jmp !Exit+                            // L_JMP_8910_8930_OK

    PlotEnemyFragment:
        jsr UTILS.CharPlot                            // L_JSR_804C_8933_OK
        ldx ZP_TEMP_VAR_2 

    !Exit:                                        // L_BRS_8938_8953_OK
        rts 

    JMP_8949:                                        // L_JMP_8949_88CF_OK
        dec $17
        lda $1F 
        sta $20 
        lda $17 
        cmp #$0A
        bne !Exit-
        inc $17 
        rts 

        jsr PLAYER.PlayerDeath

    JMP_8B04:
        lda SCOREBOARDVECTORLO                  // Scoreboard vector lo byte 
        sta ZP_COUNTER 
        jsr UTILS.UpdatePlayerScore                   // L_JSR_941E_8B08_OK

//L_BRS_8B0B_8AF4_OK

        lda SCOREBOARDVECTORHI                    // Scoreboard vector Hi byte  
        sta ZP_TEMP_VAR_1 
        ldx #41                                 // $29
    !Loop:                                         // L_BRS_8B11_8B1C_OK
        dec ZP_COUNTER 
        lda ZP_COUNTER 
        cmp #$FF
        bne !Jump+                            // L_BRS_8B1B_8B17_OK
        dec ZP_TEMP_VAR_1 
    !Jump:                                       // L_BRS_8B1B_8B17_OK
        dex 
        bne !Loop-

        ldy #$08
    !loop:                                        // L_BRS_8B20_8B28_OK
        lda (ZP_COUNTER),Y 
        cmp #$20                                // 'Space' Char
        bne BRS_8B41                            // L_BRS_8B41_8B24_OK
        dey 
        dey 
        bne !Loop-                            // L_BRS_8B20_8B28_OK

    !Loop:                                        // L_BRS_8B2A_8B47_OK
        lda NUMPLAYERS 
        beq !Exit+                            // L_BRS_8B35_8B2C_OK
        cmp #$02
        beq !Exit+                            // L_BRS_8B35_8B30_OK
        jmp JMP_8B74                            // L_JMP_8B74_8B32_OK

    !Exit:
        jmp MAINGAMELOOP.GameOver
    

    BRS_8B41:                                        // L_BRS_8B41_8B24_OK
        lda #$20
        sta (ZP_COUNTER),Y 
        cpy #$02
        beq !Loop-                           // L_BRS_8B2A_8B47_OK
        jmp JMP_8B74                            // L_JMP_8B74_8B49_OK

// // ============================

    JMP_8B74:
        jsr SCREEN.VICScreenBlank                      // L_JSR_8B4C_8B74_OK
        jsr INIT.GetLevelParams                            // L_JSR_901A_8B77_OK
        jmp JMP_8301                            // L_JMP_8301_8B7A_OK


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
                                                //L_BRS_8D88_8D8B_OK
                                                //L_BRS_8D88_8D98_OK

L_JSR_8D89_8C9F_OK:

        dec RASTERVALUE 
        bne !Exit+

        lda VICRASTER                          //  Raster Position
        and #%01110101                          // $75 127
        ora #$01
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

!Exit:
        rts

//==================================================================

    JSR_8DBD:
        dec $37 
        bne !Exit+
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
        bne !Jump+                                        //L_BRS_8DE1_8DDA_OK
        lda #$00
        sta VOICE3CTRREG                          //  Voice 3: Control Register

    !Jump:                                               //L_BRS_8DE1_8DDA_OK
        inc SPRITECOLOUR7                          //  Sprite 7 Color
        lda SPRITEPOINTER7 
        cmp #Spr14_Vertical_Spark                                   // Lighting Bolt Vertical
        bne !Jump+
        inc SPRITE_7_Y_POSITION 
        lda SPRITE_7_Y_POSITION 
        cmp #232                                        // 232 - Far right of travel
        bne !Exit+
        jmp !Jump+                                      //L_JMP_8DFE_8DF3_OK

    !Jump:                                              //L_BRS_8DF6_8DE9_OK
        inc SPRITE_7_X_POSITION 
        lda SPRITE_7_X_POSITION 
        cmp #240                                        // 240
        bne !Exit+

    !Jump:                                              //L_JMP_8DFE_8DF3_OK
        lda #$00
        sta SPRITE7_X                          //  Sprite 7 X Pos
        sta SPRITE_7_X_POSITION 
        sta VOICE3CTRREG                          //  Voice 3: Control Register
                                            // L_BRS_8E08_8E0B_OK
!Exit:                                                  // L_BRS_8E08_8E13_OK
        rts 

//=====================================================================
//Zone Cleared
//=====================================================================

ZoneCleared:                                       // L_JMP_8E78_86AD_OK
        ldx #$00
        lda #WHITE
        sta COLOURTOPLOT 
        lda #$0C                                // Row 12
        sta SCREENROWTOPLOT 
        lda #$05                                // Column 5
        sta SCREENCOLUMNTOPLOT 

    !Loop:                              // L_BRS_8E86_8E97_OK
        lda TEXT_ZONE_CLEARED,X                             //$8F53 'Zone 00 Cleared' text
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
    !Loop:                                     // L_BRS_8E9B_8EAE_OK
        inc $05EB                               // Plot Zone No. to screen 
        lda $05EB 
        cmp #$3A                                // Is first digit = 9?
        bne NextDigit                          // L_BRS_8EAD_8EA3_OK
        lda #$30                                // Store a '0' in next digit
        sta $05EB 
        inc $05EA 

    NextDigit:                                      // L_BRS_8EAD_8EA3_OK
        dex 
        bne !Loop-                  // L_BRS_8E9B_8EAE_OK

        lda #$00
        sta VOICE1CTRREG                          //  Voice 1: Control Register
        sta VOICE2CTRREG                          //  Voice 2: Control Register
        sta VOICE3CTRREG                          //  Voice 3: Control Register
        lda #$0C
        sta ZP_TEMP_VAR_2 
                                                //L_BRS_8EBF_8EE1_OK
    !Loop:
        lda #$20
        sta $4000 
        sta VOICE1FQHIGH                          //  Voice 1: Frequency Control - High-Byte
        jsr SOUND.InitV1Wave                            // L_JSR_85B0_8EC7_OK
    !Loop:                                              //L_BRS_8ECA_8EDD_OK
        inc $4000 
        inc BACKGROUNDCOLOUR1                           //  Background Color 1, Multi-Color Register 0
        ldy #$00
    !Loop:                                              //L_BRS_8ED2_8ED3_OK
        dey 
        bne !Loop-                               //L_BRS_8ED2_8ED3_OK
        lda $4000 
        sta VOICE1FQHIGH                          //  Voice 1: Frequency Control - High-Byte
        cmp #$80
        bne !Loop--
        dec ZP_TEMP_VAR_2 
        bne !Loop---
        lda #$02
        sta BACKGROUNDCOLOUR1                           //  Background Color 1, Multi-Color Register 0
        lda #$00
        sta VOICE1CTRREG                          //  Voice 1: Control Register
        lda CURRENTLEVELNUMBER 
        asl 
        sta ZP_TEMP_VAR_2 

    !Loop:                                      //L_BRS_8EF2_8F1E_OK
        lda #$80
        sta $4001 
        sta VOICE2FQHIGH                          //  Voice 2: Frequency Control - High-Byte
        jsr SOUND.InitV2Wave                            // L_JSR_85B6_8EFA_OK

    !Jump:                                          //L_JMP_8EFD_8F19_OK
        dec $4001 
        ldy #$07
        ldx #$01
        jsr PLAYER.UpdateScore                            // L_JSR_8976_8F04_OK
        ldy #$00
    !Loop:                                          //L_BRS_8F09_8F0A_OK
        dey 
        bne !Loop-                                  //L_BRS_8F09_8F0A_OK
        lda $4001 
        sta VOICE2FQHIGH                          //  Voice 2: Frequency Control - High-Byte
        cmp #$10
        beq !Jump+
        dec BACKGROUNDCOLOUR2                          //  Background Color 2, Multi-Color Register 1
        jmp !Jump-                                  //L_JMP_8EFD_8F19_OK

    !Jump:                                          //L_BRS_8F1C_8F14_OK
        dec ZP_TEMP_VAR_2 
        bne !Loop----
        jsr SCREEN.ElectricShots                               // L_JSR_9443_8F20_OK
        lda #$28
        sta ZP_TEMP_VAR_2 
        lda #GRAY3
        sta BACKGROUNDCOLOUR2                          //  Background Color 2, Multi-Color Register 1
        lda #$00
        sta VOICE2CTRREG                          //  Voice 2: Control Register
        jsr SOUND.InitV2Wave                            // L_JSR_85B6_8F31_OK

    !Loop:                                      //L_BRS_8F34_8F4E_OK
        lda #$80
        sta $4001 
        sta VOICE2FQHIGH                          //  Voice 2: Frequency Control - High-Byte

    !Loop:                                         //L_BRS_8F3C_8F4A_OK
        dec $4001 
        ldy #$30

    !Loop:                                        //L_BRS_8F41_8F42_OK
        dey 
        bne !Loop-
        lda $4001 
        sta VOICE2FQHIGH                          //  Voice 2: Frequency Control - High-Byte
        bne !Loop--
        dec ZP_TEMP_VAR_2 
        bne !Loop---
        jmp IncreaseLevelNumber                         // L_JMP_8F62_8F50_OK


// $8F53 'Zone 00 Cleared' in CBM Screen Codes
TEXT_ZONE_CLEARED: 
       .byte $1A,$0F,$0E,$05,$20,$30,$30,$20,$03,$0C,$05,$01,$12,$05,$04
     

IncreaseLevelNumber:                             // L_JMP_8F62_8F50_OK
        inc CURRENTLEVELNUMBER 
        lda CURRENTLEVELNUMBER 
        cmp #20                        // Max No. Levels = 20
        bne !Exit+                        // L_BRS_8F6C_8F68_OK
        dec CURRENTLEVELNUMBER 

!Exit:                                    // L_BRS_8F6C_8F68_OK
       jmp MAINGAMELOOP.NewLevel            //DrawThresholdGauge                   // L_JMP_82EC_8F6C_OK



//$8939 Background Colour Cycle Table?
COLOURTABLE:
        .byte $00,$06,$02,$04,$05,$03,$07,$01,$08,$0E,$0A,$0C,$0D,$0B,$0F,$09

//===================================================================
// Text for 
//===================================================================

//$9176 Primary Zone
TXT_PRI_ZONE:
        .byte $20,$10,$12,$09,$0D,$01,$12,$19,$20,$20,$1A,$0F,$0E,$05
//$9186 Secondary Zone
TXT_SEC_ZONE:
        .byte $20,$13,$05,$03,$0F,$0E,$04,$01,$12,$19,$20,$20,$1A,$0F,$0E,$05

//$9196 Battle Stations
TXT_BATTLESTATIONS:
        .byte $02,$01,$14,$14,$0C,$05,$20,$13,$14,$01,$14,$09,$0F,$0E,$13
        