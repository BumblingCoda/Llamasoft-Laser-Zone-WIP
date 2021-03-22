
TITLE: {
//=============================================================================
//JMP_92A1
//=============================================================================
    TitleScreenOptions:
// Title Screen Key detect loop
    GetKeyPress:
        
        lda VICRASTER
        cmp #$250
        bne GetKeyPress

        lda CURRENTKEYPRESS 
        cmp #KEY_NONE                        //$40 = no keypress
        bne WorkoutKeyPress 
        jsr AnimateLlamas
              
          /*       lda $A2
                and #%10000000
                bne BlinkRed
                lda #WHITE
                jmp Blink
         
         BlinkRed:
                lda #RED

        Blink:
                ldx #$04
        !Loop:
                sta $DAD8,x
                dex
                bne !Loop- */
       /*  KeyPressDelayLoop:
            ldx #$10
            ldy #$00
        !Loop:
            dey 
            bne !Loop-
            dex 
            bne !Loop- */
            jmp GetKeyPress

//=============================================================================
// Accumulator contains current key press value   
// Check what keys are pressed and set game options accordingly       
//=============================================================================
    WorkoutKeyPress:
        cmp #KEY_SPACE                  // Space Key pressed?
        bne CheckFor_T_Key              // If yes, start game.
        lda #$00
        sta TRAINMODEFLAG 
        jsr GetGameStyle
        jmp MAINGAMELOOP.StartGame

    CheckFor_T_Key:                     //Select Training Mode                         
        cmp #KEY_T                      // Start game in "training" mode
        bne CheckFor_F1_Key            
        lda #$FF                     
        sta TRAINMODEFLAG 
        jsr GetGameStyle             
        jmp MAINGAMELOOP.StartGame             
//=============================================================================
// Choose Game Options
//=============================================================================

    CheckFor_F1_Key:                        //Solo or Competition Mode                        
        cmp #KEY_F1                  
        bne CheckFor_F3_Key            
        jmp TwoPlayerCompMode               //Competition mode selected     

    CheckFor_F3_Key:                        //Choose Solo or Co-operative mode                        
        cmp #KEY_F3                  
        bne CheckFor_F5_Key            
        jmp SoloCoOpMode
       
    CheckFor_F5_Key:                          //Increases start level number                        
        cmp #KEY_F5                  
        bne CheckFor_F7_Key            
        jmp StartLevelSelect         
        
    CheckFor_F7_Key:                          //Choose number of Joysticks to use                       
        cmp #KEY_F7                  
        bne GetKeyPress              
        lda $05C2 
        cmp #$14
        beq GetKeyPress              
        inc $066D                    
        lda $066D 
        cmp #$33
        beq ResetJoyNumber           
        jmp WaitForKey             

//===============================================

    ResetJoyNumber:
            lda #$31
            sta $066D 
            jmp WaitForKey

    StartLevelSelect:
            inc $061D 
            lda $061D 
            cmp #$3A                                // Have we gone past 9?
            beq ResetLevelCount
            jmp WaitForKey

    ResetLevelCount:
            lda #$31                                // Reset Level select back to 1
            sta $061D 
            jmp WaitForKey

    SoloCoOpMode:
            lda $05C2 
            cmp #$09
            beq CoOpMode
    
            ldx #00
    !Loop:
            lda TXT_INDCOOP,X                             // $9348 Load 'solo' 
            and #$3F
            sta $05C2,X                              // Write to screen RAM                             
            inx
            cpx #14 
            bne !Loop-
            jmp WaitForKey            


    CoOpMode:
            ldx #00
    !Loop:
            lda TXT_COOP,X                         // $9358 Load 'cooperative'
            and #$3F
            sta $05C2,X                            // Write to screen RAM
            inx
            cpx #14 
            bne !Loop-
            lda #$32
            sta $066D 
            jmp WaitForKey
    
    TwoPlayerCompMode:
            lda $0572 
            cmp #$03
            beq PrintSoloToScreen

//PrintCompetitionToScreen
            ldx #00
        !Loop: 
            lda TXT_COMPETITION,X                              // $93A5 Print 'competition' to screen
            and #$3F
            sta $0572,X     //$0571
            inx
            cpx #14
            bne !Loop-
            jmp WaitForKey

    PrintSoloToScreen:
            ldx #00
        !Loop:
            lda TXT_SOLOPLAY,X                                  // $9395 Print 'solo' to screen
            and #$3F
            sta $0572,X 
            inx
            cpx #14
            bne !Loop-

    WaitForKey:                                              // $938D
            lda CURRENTKEYPRESS 
            cmp #KEY_NONE                                       // wait for a keypress
            bne WaitForKey
            jmp GetKeyPress

//=============================================================================
//
//=============================================================================
    GetGameStyle:
                lda #$00
                sta NUMPLAYERS 
                lda $0572 
                cmp #$13                            // 'S' Solo mode selected
                beq OnePlayer
                lda #$02                            // 2 = Team Mode
                sta NUMPLAYERS 

        OnePlayer:                                                // L_BRS_93C5_93BF_OK
                lda #$00
                sta TEAMMODEFLAG 
                lda $05C2 
                cmp #$09                // 'I' Individual
                beq GetLevelNumber      // Skip to GetLevelNumber if solo player
                lda #$01                // Set Team Mode flag for co-operative play
                sta TEAMMODEFLAG 

        GetLevelNumber:
                lda $061D               // Level number 
                sec 
                sbc #$30
                sta CURRENTLEVELNUMBER

        GetNumJoysticks:
                lda $066D 
                sec 
                sbc #$30
                sta NUMBEROFJOYSTICKS
                rts 
//=============================================================================
//
//=============================================================================
    AnimateLlamas:{

            ldx #$06
        !Loop:
            lda TABLES.ColourCycle_Table,x   
            sta SPRITECOLOUR1,X                     //  Incr Sprite Colour 1 on sprites 1-6
            txa 
            asl  
            tay 
            lda SPRITE1_Y,Y                          // Get Sprites 1-6 Y Pos
            clc 
            adc #$01                                // Move Llama down by 1 pixel
            sta SPRITE1_Y,Y                         // Store new Sprite 1-6 Y Pos
            dex 
            bne !Loop-                              // Loop until all Llamas done
        !Exit: 
            rts
        } 
//=============================================================================
//
//=============================================================================

DrawElectro:
        ldx #$09
    !Loop:
        lda $06EE,X                     // Electro Chars on screen 
        sta $1E00,X 

        lda $078E,X                     // Threshold Gauge
        sta $1E10,X 

        lda $1E20,X 
        sta $06EE,X                     // Electro chars on screen 

        lda $1E30,X 
        sta $078E,X                     // Threshold Guage
        dex 
        bne !Loop-

        lda THRESHOLDVALUE                         // Threshold Gauge tracker 
        sta $45 
        lda $46 
        sta THRESHOLDVALUE 
        lda $38 
        sta $1F50 
        lda $1F51 
        sta $38 
        rts 

//=============================================================================
//
//=============================================================================
    UpdateThreshold:{                                 // L_JSR_90B6_905A_OK

        ldx #$09
    !Loop:                             // L_BRS_90B8_90D1_OK
        lda SCNROW18 + 30,X                             // $06EE Electro symbols on screen
        sta $1E20,X 
        lda SCNROW22 + 30,X                             // $078EThreshold Gauge Char
        sta $1E30,X 

        lda $1E00,X 
        sta $06EE,X                             // Update Electro Symbols on screen
        lda $1E10,X 
        sta $078E,X                             // Update Threshold Gauge on screen 
        dex 

        bne !Loop-                 // L_BRS_90B8_90D1_OK
        lda THRESHOLDVALUE 
        sta $46 
        lda $45 
        sta THRESHOLDVALUE 
        lda $38 
        sta $1F51 
        lda $1F50 
        sta $38 
        rts
    } 

//=============================================================================
//Game Over Screen
//=============================================================================
DisplayGameOver:
                                                // JSR_9459
        jsr SCREEN.VICScreenBlank                                    // L_JSR_8B4C_9459_OK

PlotSkulls:
        lda #$09                                // 1001 = MC Mode (Double width) White
        sta COLOURTOPLOT 

        ldx #$18                                        // 24
    !Loop:                                           // L_BRS_9462_947E_OK
        stx SCREENCOLUMNTOPLOT 
        lda #$07
        sta SCREENROWTOPLOT 
        lda #$4C                                // Skull char 1
        sta CHARTOPLOT 
        jsr UTILS.PrintCharTileSet                    // L_JSR_861E_946C_OK
        lda #$0C                                // 12  No of skulls to print
        sta SCREENROWTOPLOT 
        stx SCREENCOLUMNTOPLOT 
        lda #$4C                                // Skull char 1
        sta CHARTOPLOT 
        jsr UTILS.PrintCharTileSet                            // L_JSR_861E_9479_OK
        dex 
        dex 
        bne !Loop-                               // L_BRS_9462_947E_OK
        lda #$01
        sta COLOURTOPLOT 
        lda #$0A
        sta SCREENROWTOPLOT 
        lda #$08
        sta SCREENCOLUMNTOPLOT 

PrintGameOver:
        ldx #$00
    !Loop:                                  // L_BRS_948E_94A1_OK
        lda TEXT_GAME_OVER,X                             // $94D5 Get'Game Over' char data
        and #$3F                                // Convert to CBM Screen Codes
        sta CHARTOPLOT 
        stx $20 
        jsr UTILS.CharPlot                            // Plot to screen
        ldx $20 
        inc SCREENCOLUMNTOPLOT                  // Add 1 to column number
        inx 
        cpx #$09                                // All chars written to screen?
        bne !Loop-                      // L_BRS_948E_94A1_OK

GameOverSFX:
        lda #$A0
        sta $20 
        lda #$00
        sta VOICE3CTRREG                          //  Voice 3: Control Register
        jsr SOUND.InitV3NoiseGen                            // L_JSR_85BC_94AC_OK

    !Loop:                                // L_BRS_94AF_94C6_OK
        ldx $20 
        lda $A800,X 
        sta VOICE3FQHIGH                           //  Voice 3: Frequency Control - High-Byte

        ldx #$05
        ldy #$00
    !Loop:                                       // 
        inc BACKGROUNDCOLOUR2                          //  Background Color 2, Multi-Color Register 1
        dey 
        bne !Loop-                           // L_BRS_94BB_94BF_OK
        dex 
        bne !Loop-                           // L_BRS_94BB_94C2_OK
        dec $20 
        bne !Loop--                            // L_BRS_94AF_94C6_OK
        lda #$00
        sta VOICE3CTRREG                          //  Voice 3: Control Register
        lda #$0E
        sta BACKGROUNDCOLOUR2                          //  Background Color 2, Multi-Color Register 1
        jsr SCREEN.VICScreenBlank                            // L_JMP_8B4C_94D2_OK
        rts

//=============================================================================
//Training Mode
//=============================================================================
DisplayTrainingMode:                                    // L_JMP_9500_92D0_OK
        jsr SCREEN.VICScreenBlank                            // L_JSR_8B4C_9500_OK
        lda #$0C
        sta SCREENROWTOPLOT 
        lda #GREEN
        sta COLOURTOPLOT 
        lda #$04
        sta SCREENCOLUMNTOPLOT 
 
        ldx #$00
    !Loop:
        lda TEXT_TRAINING,X                             // $9568 Get 'Enter Training Mode' 
        and #$3F                                        // Convert to CBM Screen Codes
        sta CHARTOPLOT 
        stx ZP_COUNTER 
        jsr UTILS.CharPlot
        ldx ZP_COUNTER 
        inc SCREENCOLUMNTOPLOT 
        inx 
        cpx #19                                         // All chars plotted?
        bne !Loop-

        jsr SOUND.TrainingSFX
        jsr SCREEN.VICScreenBlank 
        rts
    
//=============================================================================
//
//=============================================================================

 DrawTitleScreen:
        jsr SCREEN.VICScreenBlank          //$8B4C
        ldx #$00
        lda #$03
        sta SCREENCOLUMNTOPLOT 
        lda #$01
        sta COLOURTOPLOT 
    !Loop:
        lda #$02
        sta SCREENROWTOPLOT 
        stx ZP_COUNTER 
        lda TS_LINE_1,X 
        jsr UTILS.PlotTitleScreen  
        lda #GREEN
        sta COLOURTOPLOT 
        lda TS_LINE_2,X 
        jsr UTILS.PlotTitleScreen 
        lda #$01
        sta COLOURTOPLOT 
        lda TS_LINE_3,X 
        jsr UTILS.PlotTitleScreen
        inc SCREENROWTOPLOT 
        lda TS_LINE_4,X 
        jsr UTILS.PlotTitleScreen
        lda TS_LINE_5,X 
        jsr UTILS.PlotTitleScreen 
        lda TS_LINE_6,X 
        jsr UTILS.PlotTitleScreen 
        lda TS_LINE_7,X 
        jsr UTILS.PlotTitleScreen 
        inc SCREENROWTOPLOT 
        lda TS_LINE_8,X 
        jsr UTILS.PlotTitleScreen 
        inx 
        inc SCREENCOLUMNTOPLOT 
        cpx #$13
        bne !Loop- 
        rts                   

}

//-------------------------------------------------------------------------------
// TEXT CONSTANTS
// Uses custom character set located at $2000.
// 
//-------------------------------------------------------------------------------
// $9568 'Enter Training Mode' using screen display codes
TEXT_TRAINING:
        .byte $45,$4E,$54,$45,$52,$20,$54,$52,$41,$49,$4E,$49,$4E,$47,$20,$4D,$4F,$44,$45


// $94D5 'Game Over'
TEXT_GAME_OVER:
        .byte $47,$41,$4D,$45,$20,$4F,$56,$45,$52



//$9395 'solo'
TXT_SOLOPLAY:
        .byte $53,$4F,$4C,$4F,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
//$93A5 'competition'
TXT_COMPETITION:
        .byte $43,$4F,$4D,$50,$45,$54,$49,$54,$49,$4F,$4E,$20,$20,$20

//$9349 'Individual Co Operative'
TXT_INDCOOP:
        .byte $49,$4E,$44,$49,$56,$49,$44,$55,$41,$4C,$20,$20,$20,$20

//$9359 'Co Operative'
TXT_COOP:
        .byte $43,$4F,$20,$4F,$50,$45,$52,$41,$54,$49,$56,$45,$20,$20



// 'An Original Concept'
TS_LINE_1:
        .byte $41,$4E,$20,$4F,$52,$49,$47,$49,$4E,$41,$4C,$20,$43,$4F,$4E,$43,$45,$50,$54

// 'By Jeff Minter'
TS_LINE_2:
        .byte $20,$20,$42,$59,$20,$4A,$45,$46,$46,$20,$4D,$49,$4E,$54,$45,$52,$20,$20,$20

// 'Copyright 1983 Llamasoft'S
TS_LINE_3:
        .byte $3D,$20,$20,$31,$39,$38,$33,$20,$20,$20,$4C,$4C,$41,$4D,$41,$53,$4F,$46,$54

// 'F1: Solo'
TS_LINE_4:
        .byte $20,$20,$20,$46,$31,$3A,$20,$53,$4F,$4C,$4F,$20,$20,$20,$20,$20,$20,$20,$20

// 'F3: Individual'
TS_LINE_5:
        .byte $20,$20,$20,$46,$33,$3A,$20,$49,$4E,$44,$49,$56,$49,$44,$55,$41,$4C,$20,$20

// 'F5: Level 1'
TS_LINE_6:
        .byte $20,$20,$20,$46,$35,$3A,$20,$4C,$45,$56,$45,$4C,$20,$20,$20,$20,$20,$20,$31

// 'F7: Joysticks 1'
TS_LINE_7:
        .byte $20,$20,$20,$46,$37,$3A,$20,$4A,$4F,$59,$53,$54,$49,$43,$4B,$53,$20,$20,$31

// 'Press Fire To Begin'
TS_LINE_8:
        .byte $50,$52,$45,$53,$53,$20,$46,$49,$52,$45,$20,$54,$4F,$20,$42,$45,$47,$49,$4E