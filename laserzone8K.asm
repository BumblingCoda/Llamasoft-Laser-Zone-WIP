



;                                               L_JMP_825B_810C_OK
JMP_825B
        lda #$00                                ;Turn off all Sprites
        sta SpriteEnable                          ; Sprite display Enable
        jsr IntLevelParams                      ;L_JSR_8FE7_8265_OK
        jsr JSR_901A                            ;L_JSR_901A_8263_OK
        lda #$FF                                ;Turn ON all Sprites
        sta SpriteEnable                        ; Sprite display Enable
        jmp DrawThresholdGauge                  ;L_JMP_82EC_826B_OK




DrawThresholdGauge                              ;JMP_82EC
        jsr IntLevelParams                      ;L_JSR_8FE7_82EC_OK
        lda #$09                                ;Max threshold value
        sta ThresholdValue 
        lda #$00
        sta $38 

        ldx #$09
        lda #CHAR_THRESHOLD                                ;Threshold char
.gaugeLooper                                    ;L_BRS_82FB_82FF_OK
        sta $078E,X                             ;Draw Threshold Gauge on screen
        dex 
        bne .gaugeLooper

;Looks like a game or level/life reset
JMP_8301
        lda Sprite2SpriteColl                   ; Clear Sprite to Sprite Collision Detect
        jsr DrawInitLasers                      ;L_JSR_82BF_8304_OK
        lda #$00
        sta NumberOfEletros 
        sta SprSprCollision 
        sta SprBgndCollision 
        sta $1D                                 ;Possibly SFX vars
        sta $1E 
        sta SPRITE_6_X_POSITION 
        sta SPRITE_7_X_POSITION 
        sta Voice1CTRreg                          ; Voice 1: Control Register
        sta Voice2CTRreg                          ; Voice 2: Control Register
        sta Voice3CTRreg                          ; Voice 3: Control Register

SetSprites2to7
        ldx #$0C                                 ;12
.yPosLooper                                     ;L_BRS_8322_8326_OK
        sta Sprite1_Y,X                          ;Set Sprites 2-7 Y pos. to 12
        dex 
        bne .yPosLooper                         ;BRS_8322  
          
        ldx #$00
BRS_832A                                        ;L_BRS_832A_8334_OK
        sta ENEMY_X_POS_TABLE,X                             ;Clear out Enemy Char location arrays 
        sta ENEMY_Y_POS_TABLE,X 
        sta ENEMY_SFX_TABLE,X 
        inx 
        bne BRS_832A
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

;Main game loop                                 ;L_JMP_8349_835B_OK
GameLoop
        jsr GameLoopTimer_1                     ;L_JSR_835E_8349_OK
        jsr GameLoopTimer                       ;L_JSR_84EA_834C_OK
        jsr JSR_886F                            ;L_JSR_886F_834F_OK
        jsr JSR_8C8A                            ;L_JSR_8C8A_8352_OK
        jsr JSR_8DBD                            ;L_JSR_8DBD_8355_OK
        jsr ShiftKeyPressed                    ;L_JSR_94DE_8358_OK
        jmp GameLoop                            ;L_JMP_8349_835B_OK


BRS_8472                                                ;L_BRS_8472_845F_OK
        ldx #$04
.sprite1Xloop 
        lda Sprite1_X,X                                 ;Get Sprites 2-6 X Pos
        beq BRS_8480                                    ;L_BRS_8480_8477_OK
        dex 
        dex 
        bne .sprite1Xloop                               ;L_BRS_8474_847B_OK
        jmp .checkJoy_2_Fire                            ;L_JMP_844B_847D_OK

;


                                                ;L_JMP_85B0_861B_OK
                                                ;L_JSR_85B0_8EC7_OK
                                                ;L_JSR_85B0_914D_OK
                                                ;L_JSR_85B0_952B_OK


K

BRS_86D9                                        ;L_BRS_86D9_86D4_OK
        inx 
        cpx #16                                ;Max no of enemies? ;$10
        bne BRS_86CA 
        rts 

JSR_86DF        ;SFX
        lda ENEMY_SFX_TABLE,X 
        and #%01000000                          ;$40
        beq BRS_86E9
        jmp JMP_877F                            ;L_JMP_877F_86E6_OK




JMP_877F
        lda ENEMY_SFX_TABLE,X 
        and #$80
        beq BRS_87B0                            ;L_BRS_87B0_8784_OK
        jmp JMP_8789                            ;L_JMP_8789_8786_OK











;If CMDR key pressed clear screen of enemies                                                 








BRS_8C83                                                ;L_BRS_8C83_8C7B_OK
        jsr L_JSR_8D6A_8C83_OK
        jsr L_JSR_8D71_8C86_OK
                                                        ;L_BRS_8C89_8C8C_OK
                                                        ;L_BRS_8C89_8C90_OK
.JSR_8C8AExit    
        rts 

;This routine runs every game loop                                 ;L_JSR_8C8A_8352_OK
JSR_8C8A
        lda SPRITE_6_X_POSITION  
        beq .JSR_8C8AExit                                       ;L_BRS_8C89_8C8C_OK
        dec $2E 
        bne .JSR_8C8AExit                                       ;L_BRS_8C89_8C90_OK
        lda $2D 
        sta $2E 
        lda SPRITE_6_X_POSITION  
        cmp #$FF                                        ;Spriye 6 X pos >255?
        bne .lessThanFF
        jmp L_JMP_8D78_8C9C_OK

.lessThanFF                                                     ;L_BRS_8C9F_8C9A_OK
        jsr L_JSR_8D89_8C9F_OK
        dec $29 
        bne L_BRS_8CE7_8CA4_OK
        lda $28 
        and #$80                        ;%10000000
        beq L_BRS_8CB0_8CAA_OK
        inc $26 
        inc $26 
;------------------------------
L_BRS_8CB0_8CAA_OK
;------------------------------
        dec SPRITE_6_X_POSITION  
        inc SpritePointer6 
        lda SpritePointer6 
        cmp #Spr13_ZAP                                ;Sprite 13 $3300 $CC ZAP
        bne L_BRS_8CC1_8CBA_OK
        lda #Spr10_IDS_Frame_1                                ;Sprite 10 $3240 $C9 IDS Frame 1
        sta SpritePointer6 
;------------------------------
L_BRS_8CC1_8CBA_OK
;------------------------------
        lda SPRITE_6_X_POSITION  
        cmp #31
        bne L_BRS_8CD4_8CC5_OK
        lda #48
        sta $2C 
        lda $28 
        ora #$80                ;%10000000
        sta $28 
        jmp L_JMP_8CE4_8CD1_OK
;------------------------------
L_BRS_8CD4_8CC5_OK
;------------------------------
        lda SPRITE_6_X_POSITION  
        cmp #240
        bne L_BRS_8CE4_8CD8_OK
        lda #48
        sta $2C 
        lda $28 
        and #%01111111
        sta $28 
;------------------------------
L_JMP_8CE4_1511_OK
L_JMP_8CE4_8CD1_OK
L_BRS_8CE4_8CD8_OK
;------------------------------
        jsr L_JSR_8D6A_8CE4_OK
;------------------------------
L_BRS_8CE7_8CA4_OK
;------------------------------
        dec $2B 
        bne L_BRS_8D1D_8CE9_OK
        lda $2A 
        and #$80                ;%10000000
        beq L_BRS_8CF5_8CEF_OK
        inc SPRITE_6_Y_POSITION 
        inc SPRITE_6_Y_POSITION 
;------------------------------
L_BRS_8CF5_8CEF_OK
;------------------------------
        dec SPRITE_6_Y_POSITION 
        lda SPRITE_6_Y_POSITION 
        cmp #$3F
        bne L_BRS_8D0A_8CFB_OK
        lda #$30
        sta $2C 
        lda $2A 
        ora #$80
        sta $2A 
        jmp L_JMP_8D1A_8D07_OK
;------------------------------
L_BRS_8D0A_8CFB_OK
;------------------------------
        lda SPRITE_6_Y_POSITION 
        cmp #Spr1_X-Axis_Laser_Upright
        bne L_BRS_8D1A_8D0E_OK
        lda #$30
        sta $2C 
        lda $2A 
        and #$7F
        sta $2A 
;------------------------------
L_JMP_8D1A_1547_OK
L_JMP_8D1A_8D07_OK
L_BRS_8D1A_8D0E_OK
;------------------------------
        jsr L_JSR_8D71_8D1A_OK
;------------------------------
L_BRS_8D1D_8CE9_OK
;------------------------------
        lda SPRITE_6_X_POSITION 
        sta Sprite6_X                          ; Sprite 6 X Pos
        lda SPRITE_6_Y_POSITION 
        sta Sprite6_Y                          ; Sprite 6 Y Pos
        dec $2C 
        bne L_BRS_8D2E_8D29_OK
        jsr L_JSR_8C51_8D2B_OK
;------------------------------
L_BRS_8D2E_8D29_OK
;------------------------------
        lda SprSprCollision 
        and #%01000000                           ;$40 Check for Sprite 6 collision
        beq .noCollisionDetected                ;L_BRS_8D69_8D32_OK

        lda SPRITE_6_COLOUR 
        and #$07
        ora #$01
        sta SpriteColour6                          ; Sprite 6 Color
        dec SPRITE_6_COLOUR 
        bne .noCollisionDetected                        ;L_BRS_8D69_8D3F_OK

        lda #$FF
        sta SPRITE_6_X_POSITION 
        lda #Spr13_ZAP                                ;Sprite 13 $3300 $CC ZAP
        sta SpritePointer6 
        lda #$80
        sta SPRITE_6_COLOUR 
        lda #$00
        sta Voice2CTRreg                          ; Voice 2: Control Register
        ldy #$04
        ldx #$01
        jsr UpdateScore                            ;L_JSR_8976_8D57_OK
        lda #$08
        sta $21 
        lda #$20
        sta $4001 
        sta Voice2FQHigh                          ; Voice 2: Frequency Control - High-Byte
        jsr InitV2Wave                            ;L_JSR_85B6_8D66_OK
                                                        ;L_BRS_8D69_8D32_OK
                                                       ;L_BRS_8D69_8D3F_OK




                                                ;L_JSR_8DBD_8355_OK



          



