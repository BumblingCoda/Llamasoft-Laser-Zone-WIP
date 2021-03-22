INIT: {
//8073
 
Initialise:{
 //jsr INIT.InitNMIV
    jsr INIT.CopySpriteData                  //Copy Sprite & Char data to lower RAM
    jsr INIT.CreateScreenRowTable                //L_JSR_8010_8078_OK
    jsr INIT.SetUpScoreBoard
    jsr INIT.EnableShiftKey
    jsr INIT.InitVIC                             //  L_JSR_8096_807
    rts
    }
//===================================================================
EnableShiftKey:{
   
        lda #$FF                                //Enable Shift Keys
        sta SHIFTKEYENABLE                      //Shift Key Enable Flag
        rts
        }
//==================================================================
SetUpScoreBoard:{

        ldx #$07
        lda #CHAR_ZERO
    !Loop:
        sta SCOREBOARD,X 
        dex 
        bne !Loop-
        lda #CHAR_SPACE
        sta SCOREBOARD 
        sta SCOREBOARD + 8 
        rts
        }
//============================================
//
//============================================
    InitNMIV: //Not used. 
        sei 
        lda #$D5
        sta $0318           //MIV 
        lda #$95
        sta $0319           //NMIV 
        cli 
        rts
//===========================================
//Copy Sprite and Character Data to Lower RAM
//============================================
CopySpriteData: {
        lda #$36                            //Switch out BASIC
        sta $01                             //to access RAM underneath
    
        ldx #$00
    !Loop:
        lda $A800,X             //Char Set 
        sta CharSet_Target_Address,X 
        lda $A900,X 
        sta CharSet_Target_Address + $100,X 
        lda $AA00,X 
        sta CharSet_Target_Address + $200,X 
        lda $AB00,X 
        sta CharSet_Target_Address + $300,X
      
        lda $AC00,X             //Sprites
        sta Sprite_Target_Address,X 
        lda $AD00,X 
        sta Sprite_Target_Address + $100,X 
        lda $AE00,X 
        sta Sprite_Target_Address + $200,X 
        lda $AF00,X 
        sta Sprite_Target_Address + $300,X 
        inx 
        bne !Loop-
        lda #$37                            // Switch BASIC back in
        sta $01
        rts
        }

//=============================================================================
// Create a table of screen row start addressess in lower RAM. Screen at $0400 
//=============================================================================
CreateScreenRowTable:{
        lda #$04
        sta $49 
        lda #$00
        sta $48 
        ldx #$00
    !Loop:
        lda $48 
        sta SCREENROWLOOKUPTABLELO,X 
        lda $49 
        sta SCREENROWLOOKUPTABLEHI,X 
        lda $48 
        clc 
        adc #$28
        sta $48 
        lda $49 
        adc #$00
        sta $49 
        inx 
        cpx #$1B  //Store 27 values at $0340 & $0360
        bne !Loop-
        rts
        } 

//=============================================================================
// Initialises the VIC chip for a warm start
//=============================================================================
InitVIC: {                                   // JSR $8096
        lda #BLACK
        sta BORDERCOLOUR                    //  Border Color
        sta BACKGROUNDCOLOUR0               //  Background Color 0
        lda #RED
        sta BACKGROUNDCOLOUR1               //  Background Color 1, Multi-Color Register 0
        sta SPRITEMULTICOLOUR0              //  Sprite Multi-Color Register 0
        lda #$0E                            // %1110
        sta BACKGROUNDCOLOUR2               //  Background Color 2, Multi-Color Register 1
        lda #YELLOW
        sta SPRITEMULTICOLOUR1              //  Sprite Multi-Color Register 1
        lda VICCONTROLREG2                  //  Control Register 2
        ora #%00010000                      //  Set MC Mode (Bit 4)
        sta VICCONTROLREG2                  //  Control Register 2
        lda #%00011000                      //  %00011000 Char $2000 VIC $0400
        sta VICMEMCTRLREG                   //  Memory Control Register
        rts
        }

//=============================================================================
//Clear out Sprites 2-7 and load with bullets ready for game.
//=============================================================================

InitialiseSprites:{

        lda #$FF    
        sta SPRITEENABLE                    //  Turn on all sprites
        lda #$01
        ldx #$08
    !Loop:
        sta SPRITEMULTICOLOUR1,X            //Set sprites 
        dex 
        bne !Loop-
   
        ldx #$06
    !Loop: 
        lda #$00
        sta SPRITE1_Y,X 
        sta SPRITE4_Y,X 
        lda #Spr5_Vertical_Bullet           //Preload with bullet sprite
        sta SPRITEPOINTER1,X 
        dex 
        bne !Loop-
        rts
        }
 
 //============================================================================
 //
 //============================================================================   
InitSID:{
        ldx #$18
        lda #$00
    !Loop:
        sta VOICE1FQLOW,X                        //  Voice 1: Frequency Control - Low-Byte
        dex 
        bne !Loop-
        
        lda #$0F                                // %00001111 - Full Volume & Low Pass Filter On
        sta SIDVOLUMECONTROL                    //  Select Filter Mode and Volume
        lda #$0A
        sta VOICE1ATTACKDECAY                   //  Voice 1: Attack / Decay Cycle Control
        sta VOICE2ATTACKDECAY                   //  Voice 2: Attack / Decay Cycle Control
        sta VOICE3ATTACKDECAY                   //  Voice 3: Attack / Decay Cycle Control
        rts 
        }

//============================================================================
//Copy Enemy Character Data to Char set in Lower RAM
// Copies over new characters 
// Switches in different enemy chars depending upon level.
//============================================================================   
LoadEnemyChars:

        ldx CURRENTLEVELNUMBER
        dex 
        txa 
        and #%00000111      //$07
        clc 
        ror           //Divide x 2
        asl           //multiply x 2
        asl           //multiply x 4 
        asl           //multiply x 8
        asl           //multiply x 16
        asl           //multiply x 32
        asl           //multiply x 64
        tax           //X = 192 ($C0) if on Level 7 

CopyCharData:
        lda #$36                                //Switch out BASIC to access RAM
        sta $01  
        ldy #$00
    !Loop: 
        lda $A600,X                             //Get Enemy style 1 
        sta CharSet_Target_Address + $240,Y     //Store in Char set RAM  $2240
 
        lda $A700,X                             //Get Enemy style 2
        sta CharSet_Target_Address + $280,Y     //Store in Char RAM 
        inx 
        iny 
        cpy #64                                 //Get 4 chars worth of data
        bne !Loop-
     
        lda #$37                                //Switch BASIC ROM back in
        sta $01
        rts 

//======================================================================
//Initialise Game Params and jump to start JSR_901A
//======================================================================

GetLevelParams:{
        lda NUMPLAYERS 
        bne SinglePlayer

    ScoreBoard:                         //L_JMP_901E_904F_OK:
        lda #$5F                        // Player 1 scoreboard screen Low byte
        sta SCOREBOARDVECTORLO 
        lda #$05                        // Player 1 scoreboard screen High byte
        sta SCOREBOARDVECTORHI 
        lda #$01
        sta JOY_1_INUSE 
        sta JOY_2_INUSE
        lda TEAMMODEFLAG 
        beq !Jump+                           // L_BRS_9032_902E_OK
        dec JOY_2_INUSE 
    !Jump:                                       // L_BRS_9032_902E_OK
       rts
      

    SinglePlayer:                                      // L_BRS_9035_901C_OK
        inc NUMPLAYERS 
        lda NUMPLAYERS 
        cmp #$02
        beq TwoPlayers                                 // L_BRS_9052_903B_OK

        lda #$01
        sta NUMPLAYERS 
        lda CURRENTLEVELNUMBER 
        sta $43 
        lda $44 
        sta CURRENTLEVELNUMBER 
        jsr TITLE.DrawElectro                          //L_JSR_9086_9049_OK //Guages on screen
        jsr LevelAttackParams                            // L_JSR_8FE7_904C_OK
        jmp ScoreBoard

    TwoPlayers:                                             // L_BRS_9052_903B_OK
        lda CURRENTLEVELNUMBER 
        sta $44 
        lda $43 
        sta CURRENTLEVELNUMBER 
        jsr SCREEN.UpdateThreshold                             // L_JSR_90B6_905A_OK
        jsr LevelAttackParams                              // L_JSR_8FE7_905D_OK
        lda #$27                                        // Player 2 score Low Byte
        sta SCOREBOARDVECTORLO                  
        lda #$06                                        // Player 2 score High Byte
        sta SCOREBOARDVECTORHI 
        lda NUMBEROFJOYSTICKS 
        cmp #$02                                        // Two players?
        bne SingleJoystick

//Number of Joysticks
        lda #$00
    SingleJoystick:                                          // L_BRS_9070_906C_OK
        sta JOY_1_INUSE 
        sta JOY_2_INUSE 
        lda TEAMMODEFLAG 
        bne IndividualPlay                                // L_BRS_907B_9076_OK
        rts                                        //jmp BattleStations
                                                        // L_BRS_907B_9076_OK
    IndividualPlay:
        lda #$00
        sta JOY_2_INUSE 
        lda #$01
        sta JOY_1_INUSE 
        rts                       //jmp BattleStations                     // L_JMP_90E6_9083_OK
        }

//=============================================================================
//Initialise Level Parameters
//===============================================================================

LevelAttackParams:{                                  // JSR_8FE7
        ldx CURRENTLEVELNUMBER                          
        dex 
        lda TABLES.L8F6F,X 
        sta $3D 
        sta $3E 
        lda TABLES.L8F97,X 
        sta $16 
        sta $1917 
        lda TABLES.L8FAB,X                     // Satellite delay timer 
        sta IRATIANSATELLITETIMER_1 
        sta IRATIANSATELLITETIMER_2 
        lda TABLES.L8FBF,X 
        sta ATTACKWAVESPEED 
        sta $1817 
        lda TABLES.L8FD3,X 
        sta $2D 
        lda TABLES.L8F83,X 
        sta $3B 
        sta $3C 
        rts
        }

//=============================================================================
//JMP_80E4
//=============================================================================
 InitElectro:{
        lda #$00
        sta $38 
        sta $1F50 
        sta $1F51 

        ldx #$00
    !Loop:
        lda TXT_BOLTS,X                     //$82A3 Draws Electro Chars on Game Screen
        sta $1E20,X 
        lda #CHAR_THRESHOLD                            // "Electro" Char
        sta $1E10,X 
        inx
        cpx #$09                            // All chars printed? 
        bne !Loop-
  
        lda #$09
        sta THRESHOLDVALUE 
        sta $45 
        sta $46 
        lda $3F 
        sta $43 
        sta $44 
        rts
        }
        
//=============================================================================
//
//=============================================================================

} //End of INIT
