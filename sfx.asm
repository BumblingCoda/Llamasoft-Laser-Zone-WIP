SOUND: {

InitV1Wave:
        lda #%00010001                          // V1 Tri Wave & Gate bit
        sta VOICE1CTRREG                          //  Voice 1: Control Register
        rts 

InitV2Wave:                                      // JSR_85B6
        lda #%00010001                          // V2 Tri Wave & Gate bit
        sta VOICE2CTRREG                          //  Voice 2: Control Register
        rts 

InitV3NoiseGen:                                  // JSR_85BC
        lda #%10000001                           // Select V3 noise gen & set gate bit
        sta VOICE3CTRREG                          //  Voice 3: Control Register
        rts 
 
//================================================

BulletSFX:                                       // JMP_860A
        lda #$38
        sta PLAYER_BULLET_FIRED                  // Bullet fired flag 
        lda #$40
        sta $4000 
        sta VOICE1FQHIGH                        //  Voice 1: Frequency Control - High-Byte
        lda #$00                                // Reset Voice 1
        sta VOICE1CTRREG                        //  Voice 1: Control Register
        jsr InitV1Wave
        rts                        // L_JMP_85B0_861B_OK

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


SoundFX_1:                                       //JSR_8958
        lda $21 
        beq !Exit+
        dec $4001 
        lda $4001 
        sta VOICE2FQHIGH                        //Voice 2: Frequency Control - High-Byte
        bne !Exit+
        lda #$20
        sta $4001 
        dec $21 
        bne !Exit+
        lda #$00
        sta VOICE2CTRREG                          //  Voice 2: Control Register
        !Exit:   
        rts 
//======================================================================

SoundFX_2:                                         // L_JSR_8BDB_84FC_OK
        lda $24 
        beq !Exit+                             // L_BRS_8BDA_8BDD_OK
        inc BACKGROUNDCOLOUR2                    //  Background Color 2, Multi-Color Register 1
        inc $4002 
        lda $4002 
        sta VOICE3FQHIGH                         //  Voice 3: Frequency Control - High-Byte
        cmp #$60
        bne !Exit+                            // L_BRS_8BDA_8BED_OK
        lda #$40
        sta $4002 
        dec $24 
        bne !Exit+                             // L_BRS_8BDA_8BF6_OK
        lda #$00
        sta VOICE3CTRREG                        //  Voice 3: Control Register
        lda #$0E
        sta BACKGROUNDCOLOUR2                   //  Background Color 2, Multi-Color Register 1
                                               // L_BRS_8C02_8C07_OK
!Exit:
        rts 

//=============================================================================
//
//=============================================================================

PlayerDead:
        lda #$00
        sta VOICE1CTRREG                          //  Voice 1: Control Register
        sta VOICE2CTRREG                          //  Voice 2: Control Register
        //ldx #$F8
        //txs 
        lda #$04
        sta VOICE3FQHIGH                                //  Voice 3: Frequency Control - High-Byte
        jsr InitV3NoiseGen
        rts

//==========================================================================
//
//==========================================================================
TrainingSFX:

        lda #$00
        sta VOICE1FQHIGH                                //  Voice 1: Frequency Control - High-Byte
        jsr InitV1Wave                                    // L_JSR_85B0_952B_OK

        lda #$05
        sta ZP_COUNTER 
SFXLooper1:                                             // L_BRS_9532_955E_OK
        lda #$00
        sta ZP_TEMP_VAR_1 

SFXLooper2:                                             // L_BRS_9536_9549_OK
        lda ZP_TEMP_VAR_1 
        sta VOICE1FQHIGH                                //  Voice 1: Frequency Control - High-Byte
 

                                                        // L_BRS_953D_953E_OK
       ldx #$05                                         // L_BRS_953D_9541_OK
SFXLooper3:                                             // $953D
        dey 
        bne SFXLooper3                                 // L_BRS_953D_953E_OK
        dex 
        bne SFXLooper3                                 // L_BRS_953D_9541_OK
        inc ZP_TEMP_VAR_1 
        lda ZP_TEMP_VAR_1 
        cmp #$20
        bne SFXLooper2                                         // L_BRS_9536_9549_OK

SFXLooper4:                                                     // L_BRS_954B_955A_OK
        lda ZP_TEMP_VAR_1 
        sta VOICE1FQHIGH                          //  Voice 1: Frequency Control - High-Byte
        ldx #$05
                                                                // L_BRS_9552_9553_OK
                                                                // L_BRS_9552_9556_OK
SFXLooper5:
        dey 
        bne SFXLooper5                                         // L_BRS_9552_9553_OK
        dex 
        bne SFXLooper5                                         // L_BRS_9552_9556_OK
        dec ZP_TEMP_VAR_1 
        bne SFXLooper4                                         // L_BRS_954B_955A_OK
        dec ZP_COUNTER 
        bne SFXLooper1                                         // L_BRS_9532_955E_OK
        lda #$00
        sta VOICE1CTRREG                                        //  Voice 1: Control Register
        rts
//=============================================================================
//L_JSR_8C51_8C2B_OK
//=============================================================================
   
	DeathSatSFX:{

        lda VICRASTER                          //  Raster Position
        tay 
        and #%01111111                          // 127
        ora #%00000001
        sta $2C 
        lda $A080,Y                          //  BASIC Operator Vectors
        and #$07
        sta $28 
        lda $A081,Y 
        and #$01
        beq !Jump+								//L_BRS_8C6F_8C67_OK
        lda $28 
        ora #%10000000                          // 128
        sta $28 

	!Jump:										//L_BRS_8C6F_8C67_OK
        lda $A082,Y 
        and #$07
        sta $2A 
        lda $A083,Y 
        and #$01
        beq !Jump+                                    // L_BRS_8C83_8C7B_OK
        lda $2A 
        ora #$80
        sta $2A 

	!Jump:                                                // L_BRS_8C83_8C7B_OK
        jsr L8D6A
        jsr L8D71
        rts
        } 

        L8D6A:	
 	lda $28 
        and #%01111111                                  //$7F
        sta $29 
        rts 

  	L8D71:	
  		lda $2A 
        and #%01111111                                  //$7F
        sta $2B 
        rts
//=============================================================================
//
//=============================================================================
}
  