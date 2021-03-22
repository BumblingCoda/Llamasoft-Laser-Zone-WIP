// Remake of Jeff Minter's Laser Zone
// Coded for 8 or 16k cartridge
// Coded using Kick Assembler January 2021

// Put transfer code here if needed

#import "Constants.asm"
#import "IO.asm"          
#import "memory.asm"
//#import "breakpoints.asm"

//----------------------------------------------------------
// Code for creating the breakpoint file sent to Vice.
//----------------------------------------------------------
.var _useBinFolderForBreakpoints = cmdLineVars.get("usebin") == "true"
.var _createDebugFiles = cmdLineVars.get("afo") == "true"
.print "File creation " + [_createDebugFiles
? "enabled (creating breakpoint file)"
: "disabled (no breakpoint file created)"]
.var brkFile
.if(_createDebugFiles) {
.if(_useBinFolderForBreakpoints)
.eval brkFile = createFile("bin/breakpoints.txt")
else
.eval brkFile = createFile("breakpoints.txt")
}
.macro break() {
.if(_createDebugFiles) {
.eval brkFile.writeln("break " + toHexString(*))
}
}

*=$8000  "Cartridge Header"

	.byte $10,$80                   //cold start vector
    .byte $10,$80                   //warm start vector
    .byte $C3, $C2, $CD, $38, $30	// "CBM80"

*=$8010 "Entry"    
 
Initialisation:{ 
    
    jsr INIT.Initialise     
    jsr SCREEN.VICScreenBlank 
    jsr INIT.InitialiseSprites
    jsr SCREEN.ClearCharScreen
    jsr SCREEN.DrawLaserTracks      //Draw Laser Tracks
    jsr SCREEN.DrawGameScreen
    jsr SCREEN.DrawInitLasers
    }   
 
StartUp: {

    jsr INIT.InitSID
    jsr SCREEN.DrawThreshold
    jsr TITLE.DrawTitleScreen 
    jsr SCREEN.DisplayLlamas
    jmp TITLE.TitleScreenOptions
//
    }

MAINGAMELOOP: {

    StartGame:
        jsr SCREEN.VICScreenBlank         
        lda #$FF                                // Turn ON all Sprites
        sta SPRITEENABLE                        //  Sprite display Enable
        lda #$00                            //$80E4
        sta NumEnemiesForRound              //$38 
        sta $1F50                           //Does'nt seem to do anything...
        sta $1F51 
        //jsr INIT.InitElectro

JMP_825B:
       
        //lda #$00                                // Turn off all Sprites
        //sta SPRITEENABLE                          //  Sprite display Enable
        //jsr INIT.GetLevelParams                            // L_JSR_901A_8263_OK
        //jsr INIT.LevelAttackParams                      // L_JSR_8FE7_8265_OK
        //lda #$FF                                // Turn ON all Sprites
        //sta SPRITEENABLE                        //  Sprite display Enable
        //jsr SCREEN.DrawThresholdGauge                  // L_JMP_82EC_826B_OK

      
NewLevel:
        jsr SCREEN.DrawThresholdGauge               // L_JMP_82EC_826B_OK
        lda TRAINMODEFLAG
        beq !Jump+
        jsr TITLE.DisplayTrainingMode 
    !Jump:
        jsr INIT.GetLevelParams                          // L_JSR_901A_8263_OK
        jsr INIT.InitialiseSprites 
        jsr BATTLESTATION.BattleStations
        jsr SCREEN.VICScreenBlank  
        jsr UTILS.GetCollisionStatus
        lda #00
        sta SPRSPRCOLLISION
        sta SPRBGNDCOLLISION
    
    JMP_8301:
        lda $D01E                          // Sprite to Sprite Collision Detect
        jsr SCREEN.DrawInitLasers                            //L_JSR_82BF_8304_OK

        lda #$00
        sta ELECTRO_SFX_TIMER 
        sta SPRSPRCOLLISION 
        sta SPRBGNDCOLLISION 
        sta $1D 
        sta SFXloop_timer 
        sta SPRITE_6_X_POSITION 
        sta SPRITE_7_X_POSITION 
        sta $D404                          // Voice 1: Control Register
        sta $D40B                          // Voice 2: Control Register
        sta $D412                          // Voice 3: Control Register
      
        ldx #$0C
    !Loop:                                        //L_BRS_8322_8326_OK
        sta $D003,X                          // Sprite 1 Y Pos
        dex 
        bne !Loop-
        ldx #$00
    !Loop:                                        //L_BRS_832A_8334_OK
        sta ENEMY_X_POS_TABLE,X 
        sta ENEMY_Y_POS_TABLE,X 
        sta ENEMY_SFX_TABLE,X 
        inx 
        bne !Loop-
        lda #$03
        sta $1F 
        sta $20 
        lda #$18
        sta RASTERVALUE 
        lda #$30    //08
        sta $36 
        sta ATTACKWAVESPEED
        //jsr INIT.LevelAttackParams   
 

MasterGameLoop:

        dec GameLoopTimer1 
        bne !Jump+
        lda #$2C                                // Reset game tick counter
        sta GameLoopTimer1                     // Reset game loop timer 
        /* lda #240
        cmp VICRASTER
        bne MasterGameLoop */

        
        jsr UTILS.GetJoyStatus 
        jsr UTILS.GetCollisionStatus
        lda SPRSPRCOLLISION 
        and #%00000011                              // Check for Sprite 0 & 1 collisions                                
        beq !Continue+                              //BRS_8397
        jmp PLAYER.PlayerDeath                      // L_JMP_8990_8394_OK
    !Continue:    
        jsr GameLoop_1
    
    !Jump:
        dec GAMELOOPTIMER2                                 // Game loop Timer?
        bne !Jump+           
        jsr GameLoop_2                       // L_JSR_84EA_834C_OK
    !Jump:    
        jsr JSR_886F                            // L_JSR_886F_834F_OK
        jsr JSR_8C8A                            // L_JSR_8C8A_8352_OK
        jsr GameLoop_3                            // L_JSR_8DBD_8355_OK
            
        jmp MasterGameLoop

 
GameOver:
        //jsr MAINGAMELOOP.GameOver                                        // BRS_8B35
        jsr TITLE.DisplayGameOver                     // L_JSR_9459_8B35_OK
        jsr TITLE.DrawTitleScreen                     // L_JSR_91A4_8B38_OK
        jsr SCREEN.DrawLaserTracks                     // L_JSR_810F_8B3B_OK
        jmp MAINGAMELOOP.StartGame            

}


#import "battlestations.asm"
#import "gameloop.asm"
#import "player.asm"
#import "enemies.asm"
#import "sfx.asm"
#import "Screen.asm"
#import "title.asm"
#import "Utils.asm"
#import "init.asm"
#import "tables.asm"


//*=$95D5
        rti                             //point the NMI Vector here.   

*=$A600 "Chars"
#import "assets/chars.asm"
*=$AC00 "Sprites"
#import "assets/sprites.asm"