
ENEMY:{
// Enemy Char Death (skull etc)?              // L_JSR_87D3_859B_OK
    EnemyDeath:
        lda $1A         // Convert Bullet X pos to screen column
        sec 
        sbc #20
        clc 
        ror 
        clc 
        ror
        clc 
        ror 
        sta SCREENCOLUMNTOPLOT 
        lda $1B         // // Convert Bullet Y pos to screen row 
        sec 
        sbc #50
        clc 
        ror
        clc 
        ror
        clc 
        ror
        sta SCREENROWTOPLOT 
        jsr UTILS.GetScreenRowAddress                  // L_JSR_8046_87ED_OK

CheckForEnemies:
        ldx #16
    !Loop:    
        cmp TABLES.ENEMY_CHARS,X                             // Enemy Char byte array 
        beq EnemyCharDetected                 // BRS_87FF
        dex 
        bne !Loop-
        lda #$01
        sta $1C 
        rts 
// ========================

EnemyCharDetected:                              // L_BRS_87FF_87F5_OK
        ldx #$00
    !Loop:                                   // L_BRS_8801_8815_OK
        lda ENEMY_X_POS_TABLE,X              // Horizontal Enemy X pos 
        sta ZP_TEMP_VAR_1 
        cmp SCREENCOLUMNTOPLOT 
        beq CheckRowNumber                  // L_BRS_881C_8808_OK
        inc ZP_TEMP_VAR_1 
        lda ZP_TEMP_VAR_1 
        cmp SCREENCOLUMNTOPLOT 
        beq CheckRowNumber                   // L_BRS_881C_8810_OK

    !Loop:                                         // L_BRS_8812_882B_OK
        inx 
        cpx #16
        bne !Loop--                       // BRS_8801

        lda #$01
        sta $1C 
        rts 

    CheckRowNumber:                               // L_BRS_881C_8810_OK
        lda ENEMY_Y_POS_TABLE,X 
        sta ZP_TEMP_VAR_1 
        cmp SCREENROWTOPLOT 
        beq !Jump+                            // L_BRS_882D_8823_OK
        inc ZP_TEMP_VAR_1 
        lda ZP_TEMP_VAR_1 
        cmp SCREENROWTOPLOT 
        bne !Loop-

    !Jump:                                        // L_BRS_882D_8823_OK
        lda #$01
        sta ZP_TEMP_VAR_1 
        lda ENEMY_SFX_TABLE,X 
        and #$40
        beq !Jump+                            // L_BRS_883C_8836_OK
        lda #$04
        sta ZP_TEMP_VAR_1 

    !Jump:                                        // L_BRS_883C_8836_OK
        txa 
        pha 
        ldx ZP_TEMP_VAR_1 
        ldy #$05
        jsr PLAYER.UpdateScore                            // L_JSR_8976_8842_OK
        pla 
        tax 
        lda #$1F
        sta ENEMY_SFX_TABLE,X 
        lda #$03
        sta $21 
        lda #$20
        sta $4001 
        sta VOICE2FQHIGH                         //  Voice 2: Frequency Control - High-Byte
        jsr SOUND.InitV2Wave                           // L_JSR_85B6_8858_OK
        jsr CheckDeathSat                           // L_JSR_8C10_885B_OK
        rts 

//===========================================================================
// Check for Iratian Death Satellite
//===========================================================================

CheckDeathSat:										//JSR_8C10
        dec IRATIANSATELLITETIMER_2 
        beq DoSat                       // L_BRS_8C15_8C12_OK
        rts

	DoSat:{                           // L_BRS_8C15_8C12_OK
        lda IRATIANSATELLITETIMER_1 
        sta IRATIANSATELLITETIMER_2 
    
        lda #ORANGE
        sta SPRITE_6_COLOUR 
        lda SPRITE_6_X_POSITION 
        bne !Exit+
       
        lda #Spr10_IDS_Frame_1                      // Sprite 10 $3240 $C9 IDS Frame 1
        sta SPRITEPOINTER6                         // Load IDS Sprite data pos into Sprite 6
        lda #WHITE
        sta SPRITECOLOUR6                          //  Sprite 6 Color
        jsr SOUND.DeathSatSFX
        lda VICRASTER                          //  Raster Position
        and #%00000001
        beq !Jump+
    
        lda #$20
        sta SPRITE_6_X_POSITION 
        lda VICRASTER                          //  Raster Position
        and #%00111111
        clc
        adc #$40
        sta SPRITE_6_Y_POSITION 
 
 	!Exit:
        rts 

	!Jump:										//L_BRS_8C43_8C33_OK
        lda #$40
        sta SPRITE_6_Y_POSITION                 // Add 64 to Y position
        lda VICRASTER                          //  Raster Position
        and #%01111111                          // 127
        clc
        adc #$20
        sta SPRITE_6_X_POSITION                 // Add 32 to X position 
        rts
        } 
//=============================================================================
//
//=============================================================================

PlotEnemies:
        lda ENEMY_SFX_TABLE,X 
        and #%01000000                          // $40
        beq !Cont+                              //BRS_86E9
        jmp JMP_877F                            // L_JMP_877F_86E6_OK

    !Cont:    
        lda ENEMY_SFX_TABLE,X 
        and #%10000000                          // $80
        beq PlotSkull
        jmp PlotSpider                            // L_JMP_872E_86F0_OK

    PlotSkull:                                       // L_BRS_86F3_86EE_OK
        inc ENEMY_X_POS_TABLE,X 
        lda ENEMY_X_POS_TABLE,X 
        cmp #$1A        // 26
        bne PlotSkullLoop                           // JMP_8705
        lda ENEMY_SFX_TABLE,X 
        ora #$40        // 6
        sta ENEMY_SFX_TABLE,X 

    PlotSkullLoop:                                       // JMP_8705
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
        beq !Jump+
        lda #CHAR_SKULL_2                            // $4C Alternate Skull Char
        sta CHARTOPLOT 
    !Jump:    
        jsr PlotEnemy
        rts

//=============================================================================

PlotSpider:                                     //JMP_872E:
        lda #$0F
        sta COLOURTOPLOT 
        inc ENEMY_Y_POS_TABLE,X 
        lda ENEMY_Y_POS_TABLE,X 
        cmp #$15
        bne PlotSpiderLoop                            // L_BRS_8744_873A_OK
       
        lda ENEMY_SFX_TABLE,X 
        ora #$40
        sta ENEMY_SFX_TABLE,X 

    PlotSpiderLoop:                                      // JMP_8744
        lda ENEMY_X_POS_TABLE,X 
        sta SCREENCOLUMNTOPLOT  
        lda ENEMY_Y_POS_TABLE,X 
        sta SCREENROWTOPLOT 
        lda #CHAR_SPIDER_1                      // $50 Spider Char
        sta CHARTOPLOT 
        lda ENEMY_SFX_TABLE,X 
        and #$01
        bne !Jump+                            // L_BRS_8722_8757_OK
        lda #CHAR_SPIDER_2                                // $54 Alternate Spider char
        sta CHARTOPLOT 
    !Jump:    
        jsr PlotEnemy                            // L_JMP_8722_875D_OK
        rts

JMP_877F:
        lda ENEMY_SFX_TABLE,X 
        and #$80
        bne !Jump+                            // L_BRS_87B0_8784_OK
        jmp BRS_87B0
!Jump:
        lda $25 
        and #$01
        beq !Exit+                            // L_BRS_87A9_878D_OK
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
        bpl !Jump+                            // L_BRS_87A6_879E_OK
        dec ENEMY_X_POS_TABLE,X 
        dec ENEMY_X_POS_TABLE,X 

    !Jump:                                        // L_BRS_87A6_879E_OK
        inc ENEMY_X_POS_TABLE,X 
    !Exit:                                        // L_BRS_87A9_878D_OK
        lda #$0F
        sta COLOURTOPLOT 
        jmp PlotSpiderLoop                            // L_JMP_8744_87AD_OK

BRS_87B0:                                        // L_BRS_87B0_8784_OK
        lda $25 
        and #$01
        beq !Exit+                            // L_BRS_87D0_87B4_OK
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
        bpl !Jump+                            // L_BRS_87CD_87C5_OK
        dec ENEMY_Y_POS_TABLE,X 
        dec ENEMY_Y_POS_TABLE,X 

    !Jump:                                        // L_BRS_87CD_87C5_OK
        inc ENEMY_Y_POS_TABLE,X 

    !Exit:                                        // L_BRS_87D0_87B4_OK
        jmp PlotSkullLoop
 
 PlotEnemy:
        jsr UTILS.PrintCharTileSet                            // L_JSR_861E_8722_OK
        lda ENEMY_SFX_TABLE,X 
        eor #$01
        sta ENEMY_SFX_TABLE,X 
        rts 

 }      