SCREEN: {

ClearCharScreen:{          
        ldx #$00
    !Loop:
         lda #CHAR_SPACE
         sta SCREENRAM,X 
         sta SCREENRAM + 100,X 
         sta SCREENRAM + 200,X 
         sta SCREENRAM + 300,X 
         dex 
         bne !Loop-
         rts
    } 
//=============================================================================
//
//=============================================================================
	DrawLaserTracks:{                
		DoVerticalTrack:
        		lda #$0F        // 15
        		sta $16         
        		sta $1917 
        		lda #$1C        // 28
        		sta $17 
        		sta $1817 
		
        		lda #$0B        // 11 - No. of iterations. Prints 2 rows per loop
        		sta ZP_COUNTER  
        		lda #$0F       
        		sta COLOURTOPLOT 
		
        		lda #$00
        		sta SCREENROWTOPLOT                     // Start at top row 
			!Loop:
        		lda #28                                // screen column 28
        		sta SCREENCOLUMNTOPLOT 
        		lda #CHAR_LASER_TRACK_7                 // Laser rail char 7
        		sta CHARTOPLOT 
        		jsr UTILS.CharPlot
		
        		inc CHARTOPLOT                          // Print Char $47 - Laser rail char 2 
        		inc SCREENCOLUMNTOPLOT                    // Inc screen column x 1 
        		jsr UTILS.CharPlot
		
        		lda #CHAR_LASER_TRACK_5                  // Laser rail char 5
        		sta CHARTOPLOT 
        		lda #28
        		sta SCREENCOLUMNTOPLOT
        		inc SCREENROWTOPLOT 
        		jsr UTILS.CharPlot
		
        		inc CHARTOPLOT
        		inc SCREENCOLUMNTOPLOT 
        		jsr UTILS.CharPlot 
        		inc SCREENROWTOPLOT 
		
        		dec ZP_COUNTER  
        		bne !Loop-
    
		DoHorizontalTrack:
        		lda #$0D                              // 13 - No. of iterations. Prints to Column 25
        		sta ZP_COUNTER                        // Print 4x char 12 times
        		lda #23                               // 23
        		sta SCREENROWTOPLOT                   // Screen Row Number 
        		lda #$00
        		sta SCREENCOLUMNTOPLOT 
			!Loop:
        		lda #CHAR_LASER_TRACK_1                                        // Horiz. Laser rail char 1
        		sta CHARTOPLOT 
        		jsr UTILS.CharPlot
		
        		inc CHARTOPLOT                        // Horiz. Laser rail char 2 
        		inc SCREENCOLUMNTOPLOT 
        		jsr UTILS.CharPlot
		
        		inc SCREENROWTOPLOT                   // Go to Row 24 
        		dec SCREENCOLUMNTOPLOT                // Go back 1 char
        		inc CHARTOPLOT                        // Horiz. Laser rail char 3
        		jsr UTILS.CharPlot 
		
        		inc SCREENCOLUMNTOPLOT                // Go forward 1 char 
        		inc CHARTOPLOT                        // Horiz. Laser rail char 4
        		jsr UTILS.CharPlot
		
        		dec SCREENROWTOPLOT 
        		inc SCREENCOLUMNTOPLOT 
        		dec ZP_COUNTER  
        		bne !Loop-
		
        		lda #31                                // Column 31
        		sta SCREENCOLUMNTOPLOT 
        		rts
        }   
//=============================================================================
//
//=============================================================================
	DrawThreshold:{
        		ldx #$09
			!Loop: 
        		lda TXT_BOLTS,X                                 // 'electro'
        		sta $1E20,X 
        		lda #CHAR_THRESHOLD                             // Threshold char
        		sta $1E10,X                                     // Threshold Counter 
        		dex 
        		bne !Loop-
		
        		lda #$09                                        // Max threshold value
        		sta THRESHOLDVALUE 
        		sta $45 
        		sta $46 
        		lda CURRENTLEVELNUMBER 
        		sta $43 
        		sta $44 
        		rts
    }
//=============================================================================
// Draw Horizontal & X-Axis Lasers in start positions
//=============================================================================
	DrawInitLasers: {                           //L_JSR_82BF_8304_OK
        		lda #$00
        		sta SPRITEEXPAND_Y                
                sta SPRITEEXPAND_X                //  
        		lda #$03                          //  Sprites 1 & 2 MC mode
        		sta SPRITEMCSELECT                //  Sprites Multi-Color Mode Select
        		lda #Spr1_X_Laser_Upright          // Sprite 1 $3000 $C0 X-Axis Laser Upright
        		sta SPRITEPOINTER0 
        		lda #Spr3_Y_Laser_Upright         // Sprite 3 $32080 $C2 Y-Axis Laser
        		sta SPRITEPOINTER1 
        		lda #$D9                          // 217  X-Axis Laser Track
        		sta SPRITE0_Y                     //  Sprite 0 Y Pos
        		lda #$E2                          // 226
        		sta SPRITE1_X                     //  Sprite 1 X Pos
        		lda #$80                          // 128  Start at middle of X-Axis track
        		sta SPRITE0_X                     //  Sprite 0 X Pos
        		sta SPRITE1_Y                     // 128 Start at middle of Y-Axis track
        		lda SPRITE2BACKGNDCOL             //  Sprite to Background Collision Detect
        		rts 
    }
//=============================================================================
//
//=============================================================================
    DrawThresholdGauge:{                              //JMP_82EC
        //jsr INIT.GetLevelParams                      //L_JSR_8FE7_82EC_OK
        lda #$09                                //Max threshold value
        sta THRESHOLDVALUE 
        lda #$00
        sta $38 

        ldx #$09
        lda #CHAR_THRESHOLD                       //Threshold char
    !Loop:                                    
        sta $078E,X                             //Draw Threshold Gauge on screen
        dex 
        bne !Loop-
        rts
    }

//////////////////////////////////////////////////////////////////////


//=============================================================================
//
//=============================================================================


    VICScreenBlank:{                                       //L_JMP_8B4C
                lda #$00
                sta SCREENROWTOPLOT 
                lda #$20                                //'SPACE' char
                sta CHARTOPLOT 

            !Loop: 
                lda #$00
                sta SCREENCOLUMNTOPLOT 

            !Loop:  
                jsr UTILS.CharPlot 
                inc SCREENCOLUMNTOPLOT 
                lda SCREENCOLUMNTOPLOT 
                cmp #28                                //Have we reached column 28?
                bne !Loop- 
        
                inc SCREENROWTOPLOT 
                lda SCREENROWTOPLOT 
                cmp #23                                 //Have we reached row 23?
                bne !Loop--
        
                jsr INIT.InitVIC
        
                lda #$00
                sta VOICE3CTRREG                          //  Voice 3: Control Register
                rts 
             }
//=============================================================================
// Display Llamas on Title Screen?
//=============================================================================

    DisplayLlamas:{                                 
                lda #32                                // Y starting position
                sta ZP_TEMP_VAR_1 
                ldx #$06                                // No. of Llama sprites to display
            !Loop:
                lda #Spr16_Llamasoft_Pet                // Sprite 16 $33C0 $CF Llama
                sta SPRITEPOINTER1,X                    // Fill Sprites 2-7 with Llamas 
                txa 
                asl                                   // Divide x 2 to get next sprite  
                tay 
                lda ZP_TEMP_VAR_1 
                sta SPRITE1_X,Y                         // Set Sprites 1-6 X Pos
                sta SPRITE1_Y,Y                         // Set Sprites 1-6 Y Pos
                clc 
                adc #36                                // Space Llamas 36 pixels apart
                sta ZP_TEMP_VAR_1 
                dex 
                bne !Loop-
        
                lda #255                                // Sprites go behind background
                sta SPRITEDATAPRTY                      //  Sprite to Background Display Priority
                rts
        }

//=============================================================================
//
//=============================================================================

    PlotThreshold:

            ldx #$09
        !Loop:
            lda $06EE,X                     //Electro Chars on screen 
            sta $1E00,X 
    
            lda $078E,X                     //Threshold Gauge
            sta $1E10,X 
    
            lda $1E20,X 
            sta $06EE,X                     //Electro chars on screen 
    
            lda $1E30,X 
            sta $078E,X                     //Threshold Guage
            dex 
            bne !Loop-
    
            lda THRESHOLDVALUE               //Threshold Gauge tracker 
            sta $45 
            lda $46 
            sta THRESHOLDVALUE 
            lda $38 
            sta $1F50 
            lda $1F51 
            sta $38 
            rts 

//===================================================================        
//
//====================================================================

        UpdateThreshold:

            ldx #$09
        !Loop:
            lda SCNROW18 + 30,X                             //$06EE Electro symbols on screen
            sta $1E20,X 
            lda SCNROW22 + 30,X                             //$078EThreshold Gauge Char
            sta $1E30,X 
    
            lda $1E00,X 
            sta $06EE,X                             //Update Electro Symbols on screen
            lda $1E10,X 
            sta $078E,X                             //Update Threshold Gauge on screen 
            dex 
    
            bne !Loop-
            lda THRESHOLDVALUE 
            sta $46 
            lda $45 
            sta THRESHOLDVALUE 
            lda $38 
            sta $1F51 
            lda $1F50 
            sta $38 
            rts 

//========================================================================
//
//=======================================================================

    ElectricShots:                                          // L_JSR_9443_8F20_OK
        ldx #$02
    !Loop:                                           // L_BRS_9445_9450_OK
        lda $06EF,X                                      // Get char from screen
        cmp #$20                                        // is it a space?
        beq DrawChar                             // if yes draw zap char  // L_BRS_9453_944A_OK
        inx                                             // Jump a space
        inx 
        cpx #$0A                        // 10
        bne !Loop-                              // L_BRS_9445_9450_OK
        rts 

    DrawChar:                                             // L_BRS_9453_944A_OK
        lda #$65                                        // Electro/Zap character
        sta $06EF,X 
        rts                 

// Draw Game Screen
    DrawGameScreen:            
            ldx #$00
            lda #WHITE
            sta COLOURTOPLOT 
            lda #$0C
            sta SCREENROWTOPLOT 
            lda #$1F
            sta SCREENCOLUMNTOPLOT
           
        Loop:
//Title_Laser
            lda TXT_LASER,X             // 'Laser' 
            sta CHARTOPLOT 
            stx ZP_TEMP_VAR_1           // No. of chars to print 
            lda #$03
            sta SCREENROWTOPLOT 
            jsr UTILS.CharPlot
//Title_Zone
            ldx ZP_TEMP_VAR_1 
            inc SCREENROWTOPLOT 
            lda TXT_ZONE,X             // 'Zone'  
            sta CHARTOPLOT 
            jsr UTILS.CharPlot

//Title_Score_1

            ldx ZP_TEMP_VAR_1 
            lda TXT_SCORE1,X             // 'Score 1'
            sta CHARTOPLOT 
            lda #$06
            sta SCREENROWTOPLOT 
            jsr UTILS.CharPlot

//Title_Score
            ldx ZP_TEMP_VAR_1 
            lda TXT_000000,X             // '000000'           
            sta CHARTOPLOT 
            lda #$08
            sta SCREENROWTOPLOT 
            jsr UTILS.CharPlot
    
            lda #$0D
            sta SCREENROWTOPLOT 
            jsr UTILS.CharPlot
            lda #$0B
            sta SCREENROWTOPLOT 

//Title_Score_2
            ldx ZP_TEMP_VAR_1 
            lda TXT_SCORE2,X             // 'Score 2' 
            sta CHARTOPLOT 
            jsr UTILS.CharPlot

//Title_Electro
            ldx ZP_TEMP_VAR_1 
            lda #$10
            sta SCREENROWTOPLOT 
            lda TXT_ELECTRO,X             // 'Electro'
            sta CHARTOPLOT
            jsr UTILS.CharPlot

//Title_EBolts
            ldx ZP_TEMP_VAR_1 
            lda #$12
            sta SCREENROWTOPLOT 
            lda #CYAN
            sta COLOURTOPLOT 
            lda TXT_BOLTS,X                             // 3 x Lightning Bolts
            sta CHARTOPLOT 
            jsr UTILS.CharPlot                            // L_JSR_804C_81FF_OK

//Title_NoLives
            lda #$07                                // Plot to row 7
            sta SCREENROWTOPLOT 
            ldx ZP_TEMP_VAR_1                                 // No. chars to plot 
            lda TXT_LIVESLEFT,X                             // 4 x lives left char
            sta CHARTOPLOT 
            lda #PURPLE
            sta COLOURTOPLOT 
            jsr UTILS.CharPlot
    
            lda #$0C
            sta SCREENROWTOPLOT                     // Plot Player 2 Lives 
            jsr UTILS.CharPlot

//Title_Threshold
            ldx ZP_TEMP_VAR_1 
            lda TXT_THRESHOLD,X                             // 'Threshold' 
            sta CHARTOPLOT 
            lda #WHITE
            sta COLOURTOPLOT 
            lda #$14
            sta SCREENROWTOPLOT 
            jsr UTILS.CharPlot 
            lda #$16
            sta SCREENROWTOPLOT 
            lda #$79
            sta CHARTOPLOT
            jsr UTILS.CharPlot

//Title_HighScore
            ldx ZP_TEMP_VAR_1 
            lda $1F80,X                                   // Score scratchpad '0000000' 
            sta CHARTOPLOT 
            lda #$01
            sta SCREENROWTOPLOT 
            lda #YELLOW 
            sta COLOURTOPLOT 
            jsr UTILS.CharPlot
            ldx ZP_TEMP_VAR_1 
            inc SCREENCOLUMNTOPLOT 
            inx 
            cpx #$09                // All chars printed?
            beq !Exit+
        
            lda WHITE
            sta COLOURTOPLOT 
            jmp Loop
        !Exit:
            rts 
   
        
//===================================================
} // End of Screen
// $826E Play Area Text
TXT_LASER:
        .byte $58,$59,$5A,$5B,$5C,$5D,$5E,$20,$20       // 'Laser '
// $8277
TXT_ZONE:
        .byte $20,$20,$20,$20,$60,$5F,$61,$62,$63       // 'Zone'
// $8280
TXT_SCORE1:                                   
        .byte $20,$13,$03,$0F,$12,$05,$20,$31,$20       // 'Score 1'
// $8289       
TXT_SCORE2:
        .byte $20,$13,$03,$0F,$12,$05,$20,$32,$20       // 'Score 2'
// $8292 
TXT_000000:
        .byte $20,$30,$30,$30,$30,$30,$30,$30,$20       // '000000'
// $829B
TXT_ELECTRO:
        .byte $20,$66,$67,$68,$69,$6A,$6B,$6C,$20       // 'Electro'
// $82A4
TXT_BOLTS:
        .byte $20,$20,$65,$20,$65,$20,$65,$20,$20       // 3 x Lightning Bolts
// $82AD
TXT_LIVESLEFT:
        .byte $20,$64,$20,$64,$20,$64,$20,$64,$20       // 4 x lives left char            
// $82B6
TXT_THRESHOLD:        
        .byte $14,$08,$12,$05,$13,$08,$0F,$0C,$04       // 'Threshold'
