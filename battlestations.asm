BATTLESTATION:{

BattleStations:

	PlotSkull_1:

    	lda #02                                 //Column 0
        sta SCREENCOLUMNTOPLOT 
        lda #12                                 //Row 12
        sta SCREENROWTOPLOT 
        lda #$09                                //MC Mode (Double Width & White)
        sta COLOURTOPLOT 
        lda #CHAR_SKULL_1                                //Skull Upper Left Char
        sta CHARTOPLOT 
        jsr UTILS.PrintCharTileSet                    //Prints Skull chars
 
	PlotSkull_2:
        lda #22                                 //Move to Column 22
        sta SCREENCOLUMNTOPLOT 
        lda #12                                 //Row 12
        sta SCREENROWTOPLOT 
        lda #CHAR_SPIDER_1                                //Skull Upper Left Char
        sta CHARTOPLOT 
        jsr UTILS.PrintCharTileSet
  
	PlotZoneClearedText:
        lda #12
        sta SCREENROWTOPLOT 
        lda #6
        sta SCREENCOLUMNTOPLOT 
        lda #WHITE
        sta COLOURTOPLOT 

	PlotPrimaryZone:
        ldx #$00
	!Loop:
        lda TXT_PRI_ZONE,X                      //'Primary Zone'
        ldy NUMPLAYERS 
        cpy #$02                                //Check for 2 players
        bne SinglePlayer

	PlotSecondaryZone:
          
        lda TXT_SEC_ZONE,X                        //'Secondary Zone' 
	SinglePlayer:
        sta CHARTOPLOT 
        stx ZP_COUNTER 
        jsr UTILS.CharPlot

	PlotBattleStations:
        ldx ZP_COUNTER 
        lda TXT_BATTLESTATIONS,X                  //'Battle Stations' 
        sta CHARTOPLOT 
        lda #15
        sta SCREENROWTOPLOT 
        lda #GREEN
        sta COLOURTOPLOT 
        jsr UTILS.CharPlot

        lda #12
        sta SCREENROWTOPLOT 
        ldx ZP_COUNTER 
        inc SCREENCOLUMNTOPLOT 
        inx 
        cpx #15
        bne !Loop-

	SFX1:
        lda #$70
        sta ZP_COUNTER 
        lda #$00
        sta VOICE1CTRREG                                //Voice 1: Control Register
        jsr SOUND.InitV1Wave

	SFXLoop: 
        ldy VICRASTER                                   //Raster Position
        lda $A000,Y                                     //Restart Vectors
        sta VOICE1FQHIGH                                //Voice 1: Frequency Control - High-Byte

	CycleBackgroundColours: 
        ldy #$00
        ldx #$05

	!Loop:
        inc BACKGROUNDCOLOUR1                           //Background Color 1, Multi-Color Register 0
        dey 
        bne !Loop-
        dex 
        bne !Loop-
        dec ZP_COUNTER 
        bne SFXLoop
        
		lda #$00
        sta VOICE1CTRREG                                //Voice 1: Control Register
        lda #RED
        sta BACKGROUNDCOLOUR1  
        rts
}
// $8F53 'Zone 00 Cleared' in CBM Screen Codes
TEXT_ZONE_CLEARED: 
       .byte $1A,$0F,$0E,$05,$20,$30,$30,$20,$03,$0C,$05,$01,$12,$05,$0

//$9176 Primary Zone
TXT_PRI_ZONE:
        .byte $20,$10,$12,$09,$0D,$01,$12,$19,$20,$20,$1A,$0F,$0E,$05
//$9186 Secondary Zone
TXT_SEC_ZONE:
        .byte $20,$13,$05,$03,$0F,$0E,$04,$01,$12,$19,$20,$20,$1A,$0F,$0E,$05

//$9196 Battle Stations
TXT_BATTLESTATIONS:
        .byte $02,$01,$14,$14,$0C,$05,$20,$13,$14,$01,$14,$09,$0F,$0E,$13
        
	
