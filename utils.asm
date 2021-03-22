UTILS: {

// ===========================
// Expects X loaded with screen row & Y loaded with column

    LookUpScreenRowAddress:                         // JSR_8037
        ldx SCREENROWTOPLOT 
        ldy SCREENCOLUMNTOPLOT 
        lda SCREENROWLOOKUPTABLELO,X                     // Get low byte from lookup table 
        sta SCREENROWADDRESSLO 
        lda SCREENROWLOOKUPTABLEHI,X                     // Get high byte from lookup table
        sta SCREENROWADDRESSHI 
        rts 


    GetScreenRowAddress: 
        jsr LookUpScreenRowAddress
        lda (SCREENROWADDRESSLO),Y 
        rts 

// Plots a single char to screen and set colour RAM
// Load char no. in CharToPlot, colour in ColourToPlot
    CharPlot:
        jsr LookUpScreenRowAddress
        lda CHARTOPLOT 
        sta (SCREENROWADDRESSLO),Y 
        lda SCREENROWADDRESSHI 
        clc 
        adc #$D4                                //Offset to jump to Colour RAM
        sta SCREENROWADDRESSHI
        lda COLOURTOPLOT
        sta (SCREENROWADDRESSLO),Y 
        rts

//====================================================================
//
//====================================================================

    PlotSpaceChar:                              //Blank out after enemies have moved a space
        txa 
        pha 
        tya 
        pha 
        lda #$20                // Space Char
        sta CHARTOPLOT 
        jsr CharPlot                            // L_JSR_804C_8768_OK
        inc SCREENROWTOPLOT 
        jsr CharPlot                            // L_JSR_804C_876D_OK
        inc SCREENCOLUMNTOPLOT 
        jsr CharPlot                            // L_JSR_804C_8772_OK
        dec SCREENROWTOPLOT 
        jsr CharPlot                            // L_JSR_804C_8777_OK
        pla 
        tay 
        pla 
        tax 
        rts 


//=====================================================================
//This routine print 4 x chars as a 2 x 2 tile
//=====================================================================

    PrintCharTileSet:
        txa                                     //Store game registers 
        pha 
        tya 
        pha 
        jsr CharPlot
        inc SCREENROWTOPLOT 
        inc CHARTOPLOT 
        jsr CharPlot
        inc SCREENCOLUMNTOPLOT 
        dec SCREENROWTOPLOT 
        inc CHARTOPLOT 
        jsr CharPlot 
        inc CHARTOPLOT 
        inc SCREENROWTOPLOT 
        jsr CharPlot                          
        pla                                     //Restore game registers 
        tay 
        pla 
        tax 
        rts 

//======================================================================
// This routine plots the title screen text
//======================================================================
        
    PlotTitleScreen: 
        and #$3F                //Convert to CBM screen codes
        sta CHARTOPLOT 
        jsr CharPlot
        ldx ZP_COUNTER 
        lda SCREENROWTOPLOT 
        clc 
        adc #$02                //Skip next row
        sta SCREENROWTOPLOT 
        rts 

//=====================================================================
//Joystick directions = E0 no movement, E1 up, E2 down,E4 left,E8 right
//F0 = fire
//=====================================================================

GetJoyStatus:
        ldx JOY_1_INUSE                          //Is Joystick 1 in use?
        lda CIAPort_A,X                          //Data Port A (Keyboard, Joystick, Paddles)
        eor #$1F
        sta JOYSTICK_1 
        ldx $10                                  //Is Joystick 2 in use? 
        lda CIAPort_A,X                          //Data Port A (Keyboard, Joystick, Paddles)
        eor #$1F
        sta JOYSTICK_2 
        rts

GetCollisionStatus:    
        lda SPRITE2SPRITECOLL                           // $D01E Get any Sprite-Sprite collisions
        sta SPRSPRCOLLISION                             // Store in zPage
        lda SPRITE2BACKGNDCOL                           // $D01F Get Sprite to Background Collisions
        sta SPRBGNDCOLLISION                            // Store in zPage
        rts 

//If CMDR key pressed clear screen of enemies                                                 

    SmartBomb:
          
        CheckForCMDRKey:
            lda $028D                               //Shift Key Flag
            and #$02                                //check Bit 1 1 = CMDR Key pressed
            bne CMDRKeyPressed
            rts 

        CMDRKeyPressed:
            lda ELECTRO_SFX_TIMER 
            beq FireElectro                            // L_BRS_8B8E_8B87_OK
            cmp #$02
            bmi FireElectro
            rts 

        FireElectro:                                    // BRS_8B8E
            ldx #$08                                // Load X with no. of chars to get from screen
        !Loop:                                         // L_BRS_8B90_8B99_OK
            lda $06EF,X                             // Get 8 chars from screen Address $06EF 
            cmp #$20                                // Is it a Space Char?
            bne !Jump+                           // L_BRS_8B9C_8B95_OK
            dex                                     // Move 2 spaces to the left
            dex 
            bne !Loop-                             // L_BRS_8B90_8B99_OK
            rts 

        !Jump:                                      // L_BRS_8B9C_8B95_OK
            lda #CHAR_SPACE                                // Store a space reducing electros by 1
            sta $06EF,X 

            ldx #$00
            stx VOICE3CTRREG                          // Turn off Voice 3
        !Loop:                                          //L_BRS_8BA6_8BC9_OK
            lda ENEMY_X_POS_TABLE,X                             // Enemy X position plot table 
            beq !Jump+
            lda ENEMY_SFX_TABLE,X                             // Think this is SFX for eacxh enemy 
            and #$10
            bne !Jump+
            lda #$1F
            sta ENEMY_SFX_TABLE,X 
            txa                             // Store X & Y values on the stack 
            pha 
            tya 
            pha 
            ldy #$05
            ldx #$04
            jsr PLAYER.UpdateScore                            // L_JSR_8976_8BBF_OK
            pla                             // Pull X & Y values from the stack
            tay 
            pla 
            tax 

        !Jump:
            inx 
            cpx #$10
            bne !Loop-
            lda #$40
            sta $4002 
            sta VOICE3FQHIGH                           //  Voice 3: Frequency Control - High-Byte
            jsr SOUND.InitV3NoiseGen                            // L_JSR_85BC_8BD3_OK
            lda #$08
            sta $24 
        !Exit:
            rts                                     // L_BRS_8BDA_8BF6_OK


//=========================================================================
//JSR_8516
//=========================================================================

BulletCollision:
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
        bne BRS_8535
        inc SPRITE1_X,X                          //  Sprite 1 X Pos
        lda SPRITE1_X,X                          //  Sprite 1 X Pos
        cmp #$F0                                // 240 Far right of track?
        beq ResetSprite_X_pos                  // BRS_855D

BRS_8535:
        lda SPRBGNDCOLLISION                    // Check Sprites 2 & 3 for bkgrn collision  
        and #%00001100                          // $0C
        beq !Exit+                       // BRS_855C

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
        sta SPRITE1_X,X                          //  Sprite 1 X Pos
 
!Exit:
        rts 

ResetSprite_X_pos:
        lda #$00
        sta SPRITE1_X,X                          //  Sprite 1 X Pos
        rts 

//=======================================================================
//JSR_8563
//========================================================================

BulletCheck:
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
        bne !Jump+                                  // L_BRS_8582_8576_OK
        inc SPRITE3_Y,X                                 //  Sprite 3 - 6 Y Pos
        lda SPRITE3_Y,X                                 //  Sprite 3 - 6 Y Pos
        cmp #MAX_BULLET_TRAVEL_RIGHT                    // 228 Far right of game screen
        beq TurnOffBullets                             // L_BRS_85AA_8580_OK

    !Jump:                                           // L_BRS_8582_8576_OK
        lda SPRBGNDCOLLISION                      // Check if a bullet sprite has hit a background char
        and #%00110000                            // $30 Sprites 4 & 5 bkgrnd collision?
        beq !Exit+                              // L_BRS_855C_8586_OK

        lda SPRITE3_X,X                          //  Sprite 3-6 X Pos
        sta $1A 
        lda SPRITE3_Y,X                          //  Sprite 3-6 Y Pos
        sta $1B 
        lda #$00
        sta SPRITE3_X,X                          // Set Sprite 3 X Pos to 0
        sta $1C 
        stx ZP_TEMP_VAR_2 
        jsr ENEMY.EnemyDeath                    // Enemy Char Death L_JSR_87D3_859B_OK
        ldx ZP_TEMP_VAR_2 
        lda $1C 
        beq !Exit+
        lda $1A 
        sta SPRITE3_X,X                          //  Sprite 3-6 X Pos

    !Exit:                                           // L_BRS_85A9_85A2_OK
        rts 

TurnOffBullets:                                 // BRS_85AA
        lda #$00
        sta SPRITE3_X,X                         //  Sprites 3 - 6 X Pos
        rts 


//============================================================================
//Check for Sprite to Background Collisions - has an attacker got to a laser?
//============================================================================
// Check for Sprite collisions 
    CheckForBackgroundCollision:
        lda SPRBGNDCOLLISION 
        and #%00000011                // %0011 Has Sprites 0 or 1 hit background chars?
        beq !Exit+
        lda SPRBGNDCOLLISION 
        sta SPRSPRCOLLISION         //Transfer collision data for Player Death routine 
        jmp PLAYER.PlayerDeath                            // L_JMP_8990_8C0D_OK
    !Exit:   
        rts
//============================================================================
//Routine to decrement threshold 
//============================================================================
    JSR_8E09:        
        dec $3E 
        bne !Exit+
        lda $3D 
        sta $3E 
        lda $38 
        bne !Exit+

        txa 
        pha
        ldy THRESHOLDVALUE             // Get current Threshold value 
        lda SCNROW22 + 30,Y                     // $078E Threshold on screen col 30 row 20
        ldx #$08
    !Loop:                             // BRS_8E1E
        cmp THRESHOLDCHARS + 1,X                     // $8e6f Threshold indicator chars 
        beq !Jump+
        dex 
        bne !Loop-                 // BRS_8E1E
    !Jump:
        lda THRESHOLDCHARS,X 
        sta SCNROW22 + 30,Y              // Store threshold guage on screen
        cmp #$20                        // Last char is a space
        beq !Jump+                      //L_BRS_8E33_8E2E_OK

    JMP_8E30:
    !Loop:
        pla 
        tax 
    !Exit:    
        rts 

    !Jump:                                  //L_BRS_8E33_8E2E_OK
        dec THRESHOLDVALUE              // Decrement Threshold Value 
        bne !Loop-                           // If value still pozitive return

        lda #$14                        // 20
        sta $38 
        ldx #$00
// ------------------------------
//L_BRS_8E3D_8E51_OK
    !Loop:
        lda ENEMY_SFX_TABLE,X 
        and #$10
        bne !Jump+
        lda ENEMY_X_POS_TABLE,X 
        beq !Jump+
        lda #$1F
        sta ENEMY_SFX_TABLE,X 

    !Jump:
        inx 
        cpx #$10
        bne !Loop-
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
        //jmp JMP_8E30
        rts
//==========================================================================
//Game Pause Function - Shift & P key combo pauses game  
//==========================================================================
                                      
    ShiftKeyPressed:                                // L_JSR_94DE_8358_OK
        lda $028D                               // Shift Key pressed? 
        and #$01                                // Bit 0 1 = Shift key pressed 
        bne CheckForKEY_P                        // L_BRS_94E6_94E3_OK
        rts                             //No key pressed

    CheckForKEY_P:                                    // L_BRS_94E6_94E3_OK
        lda CURRENTKEYPRESS                         // Current Key Pressed 
        cmp #KEY_P                              // Is it 'P'?
        bne !Exit-                       // L_BRS_94E5_94EA_OK

        lda TRAINMODEFLAG 
        beq GamePause                       // L_BRS_94F3_94EE_OK
        jmp MAINGAMELOOP.GameOver                            // L_JMP_8B35_94F0_OK

// Game Pause Loop                                // L_BRS_94F3_94EE_OK
                                                // L_BRS_94F3_94F7_OK
    GamePause:
    !Loop:
        lda CURRENTKEYPRESS 
        cmp #KEY_NONE
        bne !Loop-                       // L_BRS_94F3_94F7_OK

    !Loop:                                  // L_BRS_94F9_94FD_OK
        lda CURRENTKEYPRESS 
        cmp #KEY_NONE                                // No key pressed
        beq !Loop-                      // L_BRS_94F9_94FD_OK
   !Exit:      
        rts 

//=============================================================================
//
//=============================================================================


} 


// $8E6F  'Threshold' indicator on play screen
THRESHOLDCHARS:        
        .byte   $20,$72,$73,$74,$75,$76,$77,$78,$79       

