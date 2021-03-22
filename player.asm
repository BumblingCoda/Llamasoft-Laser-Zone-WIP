PLAYER:{

//=============================================================
UpdateScore:                                       // JSR_8976        // Check score digits
        sty ZP_TEMP_VAR_1 
	!Loop:                                          // L_BRS_8978_8988_OK
        lda (SCOREBOARDVECTORLO),Y 
        clc 
        adc #$01                                // Add 1 to current score
        sta (SCOREBOARDVECTORLO),Y 
        cmp #$3A                                // Greater than 9?
        bne !Exit+
        lda #$30                                // If greater than 9 replace with 0
        sta (SCOREBOARDVECTORLO),Y 
        dey 
        bne !Loop- 

	!Exit:
        ldy ZP_TEMP_VAR_1 
        dex 
        bne UpdateScore
        rts 

//================================================================
//
//================================================================

PlayerDeath: // L_JMP_8990_8394_OK
       
        jsr SOUND.PlayerDead
      
        lda SPRSPRCOLLISION 					// Get Sprite-Sprite Collisions
        and #%00000001                          // Which Laser Base destroyed?
        beq X_AxisLaserDeath                    // Jump to X axis destruction

Y_AxisLaserDeath:
     
        ldx #$06
	!Loop:                                       //L_BRS_89AB_89E0_OK
        txa 
        asl 
        tay 
        lda SPRITE0_X                           // Sprite 0 X Pos
        sta SPRITE1_X,Y                         // Sprite 1 X Pos
        lda SPRITE0_Y                           // Sprite 0 Y Pos
        sta SPRITE1_Y,Y                         // Sprite 1 Y Pos
        lda #Spr9_Player_Explosion              // Sprite 9 $3200 $C8 Explosion
        sta SPRITEPOINTER1,X 
        lda #$FF                               // Turn all Sprites to MC mode
        sta SPRITEMCSELECT                     //  Sprites Multi-Color Mode Select
        lda #WHITE
        sta SPRITECOLOUR1,X                     //  Sprite 1 Color
        lda TABLES.EXPLOSIONDATA_3,X 
        sta SPRITE_EXPLOSION_X_TABLE1,X 
        and #%01111111                                 // 127    0111 1111 
        sta SPRITE_EXPLOSION_Y_TABLE3,X 
        lda TABLES.EXPLOSIONDATA_4,X 
        sta SPRITE_EXPLOSION_X_TABLE2,X 
        and #%01111111
        sta SPRITE_EXPLOSION_X_TABLE4,X 
        dex 
        bne !Loop-

        lda SPRITEENABLE                        //  Sprite display Enable
        and #%11111110                          // $FE Turn off X axis laser
        sta SPRITEENABLE                        //  Sprite display Enable
        jmp JMP_8A2E
         
X_AxisLaserDeath:
     
        ldx #$06
	!Loop:
        txa
        asl
        tay 
        lda SPRITE1_X                                           //  Sprite 1 X Pos
        sta SPRITE1_X,Y                                         //  Start at Sprite 7 X Pos
        lda SPRITE1_Y                                           //  Stary at Sprite 7 Y Pos
        sta SPRITE1_Y,Y                                         //  Sprite 1 Y Pos
        lda #Spr9_Player_Explosion                              // Sprite 9 $3200 $C8 Explosion
        sta SPRITEPOINTER1,X                                    // Load Sprite 9 in Sprites 2-7

        lda #$FF
        sta SPRITEMCSELECT                         // Turn off MC Sprite mode
        lda #WHITE
        sta SPRITECOLOUR1,X                        // Colour Sprites 1 white

        lda TABLES.EXPLOSIONDATA_1,X                             // 138,131,1340,130,143 Expl. CoOrds
        sta SPRITE_EXPLOSION_X_TABLE1,X          // Store at $1500 
        and #%01111111                                // %01111111
        sta SPRITE_EXPLOSION_Y_TABLE3,X                             // 03,03,09,01,03,06 
        lda TABLES.EXPLOSIONDATA_2,X                             // 135,143,131,16,21 
        sta SPRITE_EXPLOSION_X_TABLE2,X 
        and #%01111111                                // %01111111
        sta SPRITE_EXPLOSION_X_TABLE4,X                             // 07,67,03,16,21
        dex 
        bne !Loop-

      /*   lda SPRITEENABLE                        //  Sprite display Enable
        and #%11111101                          // Turn off Y axis laser
        sta SPRITEENABLE                        //  Sprite display Enable */
//=============================================================================    
JMP_8A2E:
        ldx #$06
    !Loop:									//S_8A30_8A41_OK
        dec SPRITE_EXPLOSION_Y_TABLE3,X 
        bne !Jump+                            // L_BRS_8A38_8A33_OK
        jsr JSR_8A63                            // L_JSR_8A63_8A35_OK

    !Jump:                                         // L_BRS_8A38_8A33_OK
        dec SPRITE_EXPLOSION_X_TABLE4,X 
        bne !Jump+//_8A40_8A3B_OK
        jsr JSR_8A8F                            // L_JSR_8A8F_8A3D_OK

    !Jump:                         // L_BRS_8A40_8A3B_OK
        dex 
        bne !Loop-               // L_BRS_8A30_8A41_OK

        ldx #$01
        inc SPRITEMULTICOLOUR1                   //  Sprite Multi-Color Register 1

// Waste a bit of time
    !Loop:                                        // L_BRS_8A48_8A4E_OK
        ldy #$60
    !Loop:                                       // L_BRS_8A4A_8A4B_OK
        dey 
        bne !Loop-                                 // BRS_8A4A
        dex 
        bne !Loop--                                 // BRS_8A48

        ldx #$06
    !Loop:                                     // L_BRS_8A52_8A5B_OK
        txa    
        asl
        tay
        lda SPRITE1_Y,Y                          //  Sprite 1 Y Pos
        bne !Jump+                            // L_BRS_8A60_8A58_OK
        dex 
        bne !Loop-
        jmp JMP_8B04                        // L_JMP_8B04_8A5D_OK

    !Jump:                                        // L_BRS_8A60_8A58_OK
        jmp JMP_8A2E                        // L_JMP_8A2E_8A60_OK

// ======================
//  Explosion Sprite animation?
// Sprite 2-7 X Positions
JSR_8A63:
    
        lda SPRITE_EXPLOSION_X_TABLE1,X 
        and #$7F
        sta SPRITE_EXPLOSION_Y_TABLE3,X 
        txa 
        asl
        tay 
        lda SPRITE1_X,Y                          //  Sprite 1 X Pos
        bne !Jump+                            // L_BRS_8A74_8A71_OK
        rts 

    Jump:                                        // L_BRS_8A74_8A71_OK
        lda SPRITE_EXPLOSION_X_TABLE1,X 
        and #$80
        bne !Jump+                            // L_BRS_8A85_8A79_OK
        lda SPRITE1_X,Y                          //  Sprite 1 X Pos
        clc 
        adc #$01
        sta SPRITE1_X,Y                          //  Sprite 1 X Pos
        rts 

    !Jump:                                       // L_BRS_8A85_8A79_OK
        lda SPRITE1_X,Y                          //  Sprite 1 X Pos
        sec 
        sbc #$01
        sta SPRITE1_X,Y                          //  Sprite 1 X Pos
        rts 
//=============================================================================
JSR_8A8F:
        lda SPRITE_EXPLOSION_X_TABLE2,X 
        and #%01111111                          // $7F
        sta SPRITE_EXPLOSION_X_TABLE4,X 
        txa 
        asl
        tay 
        lda SPRITE1_Y,Y                          //  Sprite 1 Y Pos
        bne !Jump+                            // L_BRS_8AA0_8A9D_OK
        rts 

// Sprite 2-7 Y Positions
	!Jump:                                        // L_BRS_8AA0_8A9D_OK
        lda SPRITE_EXPLOSION_X_TABLE2,X 
        and #$80
        bne !Jump+                            // L_BRS_8AB3_8AA5_OK
        lda SPRITE1_Y,Y                          //  Sprite 1 Y Pos
        clc 
        adc #$01
        sta SPRITE1_Y,Y                          //  Sprite 1 Y Pos
        jmp JMP_8ABC                            // L_JMP_8ABC_8AB0_OK

	!Jump:                                        // L_BRS_8AB3_8AA5_OK
        lda SPRITE1_Y,Y                          //  Sprite 1 Y Pos
        sec 
        sbc #$01
        sta SPRITE1_Y,Y                          //  Sprite 1 Y Pos

JMP_8ABC:
        lda SPRITE_EXPLOSION_X_TABLE2,X 
        and #$7F
        sta ZP_TEMP_VAR_1 
        lda SPRITE_EXPLOSION_X_TABLE2,X 
        and #$80
        bne !Jump+                            // L_BRS_8ADB_8AC8_OK
        lda ZP_TEMP_VAR_1 
        cmp #$04
        beq !Exit+                            // L_BRS_8A9F_8ACE_OK
        dec ZP_TEMP_VAR_1 

    !Loop:                                        // L_BRS_8AD2_8AE1_OK
        lda ZP_TEMP_VAR_1 
        sta SPRITE_EXPLOSION_X_TABLE2,X 
        sta SPRITE_EXPLOSION_X_TABLE4,X 
    !Exit:    
        rts 

    !Jump:                                        // L_BRS_8ADB_8AC8_OK
        inc ZP_TEMP_VAR_1 
        lda ZP_TEMP_VAR_1 
        cmp #$20
        beq !Loop-                            // L_BRS_8AD2_8AE1_OK
        sta SPRITE_EXPLOSION_X_TABLE4,X 
        ora #$80
        sta SPRITE_EXPLOSION_X_TABLE2,X 
        rts 


//=============================================================================
//
//=============================================================================
UpdatePlayerScore:                              // JSR_941E
        ldy #$01
    !Loop:                                     // L_BRS_9420_9430_OK
        tya 
        tax 
        lda (SCOREBOARDVECTORLO),Y                             // $0560  Scoreboard on screen 
        cmp SCOREBOARD,X                                // $1F80 Score scratchpad 
        beq !Jump+                                   // L_BRS_942D_9427_OK
        bmi !Exit+                          // L_BRS_9432_9429_OK
        bpl PrintHiScore                                 // L_BRS_9433_942B_OK
    !Jump:                                  // L_BRS_942D_9427_OK
        iny 
        cpy #$08                            // Have we reached the last char?
        bne !Loop-                          // L_BRS_9420_9430_OK
    !Exit:                                     // L_BRS_9432_9429_OK
        rts 

PrintHiScore:                                             // L_BRS_9433_942B_OK
        ldy #$07
    !Loop:                                      // L_BRS_9435_9440_OK
        tya 
        tax 
        lda (SCOREBOARDVECTORLO),Y 
        sta SCOREBOARD,X 
        sta HISCORESCREENADD,X                                     // Print score 1 to screen 
        dey 
        bne !Loop-                          // L_BRS_9435_9440_OK
        rts 



}

