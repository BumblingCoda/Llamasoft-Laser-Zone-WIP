
//-------------------------------------------------------------------------------
// SCREEN & SPRITE POINTERS
//-------------------------------------------------------------------------------
.label SPRITEPOINTER0  = $07F8
.label SPRITEPOINTER1  = $07F9
.label SPRITEPOINTER2  = $07FA
.label SPRITEPOINTER3  = $07FB
.label SPRITEPOINTER4  = $07FC
.label SPRITEPOINTER5  = $07FD
.label SPRITEPOINTER6  = $07FE
.label SPRITEPOINTER7  = $07FF

//-------------------------------------------------------------------------------
// VIC
//-------------------------------------------------------------------------------
.label SPRITE0_X               = $D000 //53248 Sprite 0 X Coordinate
.label SPRITE0_Y               = $D001 //53249 Sprite 0 Y Coordinate
.label SPRITE1_X               = $D002
.label SPRITE1_Y               = $D003
.label SPRITE2_X               = $D004
.label SPRITE2_Y               = $D005
.label SPRITE3_X               = $D006
.label SPRITE3_Y               = $D007
.label SPRITE4_X               = $D008
.label SPRITE4_Y               = $D009
.label SPRITE5_X               = $D00A
.label SPRITE5_Y               = $D00B
.label SPRITE6_X               = $D00C
.label SPRITE6_Y               = $D00D
.label SPRITE7_X               = $D00E
.label SPRITE7_Y               = $D00F
.label SPRXMSB                 = $D010 //Sprite x most significant bit
.label VICCONTROLREG1          = $D011 //VIC Control Register 1
.label VICRASTER               = $D012 //Raster
.label LPX                     = $D013 //Light-pen x-position
.label LPY                     = $D014 //Light-pen y-position
.label SPRITEENABLE            = $D015 //Sprite display enable
.label VICCONTROLREG2          = $D016 //VIC Control Register 2
.label SPRITEEXPAND_Y          = $D017 //Sprite Y vertical expand
.label VICMEMCTRLREG           = $D018 //VIC Memory Control Register
.label VICINT                  = $D019 //VIC Interrupt Flag Register
.label IRQMR                   = $D01A //IRQ Mask Register
.label SPRITEDATAPRTY          = $D01B //Sprite/data priority
.label SPRITEMCSELECT          = $D01C //Sprite multi-colour select
.label SPRITEEXPAND_X          = $D01D //Sprite X horizontal expand
.label SPRITE2SPRITECOLL       = $D01E //53278 Sprite to sprite collision
.label SPRITE2BACKGNDCOL       = $D01F //53278 Sprite to background collision
.label BORDERCOLOUR            = $D020 //Screen border colour
.label BACKGROUNDCOLOUR0       = $D021 //Screen background colour 1
.label BACKGROUNDCOLOUR1       = $D022 //Screen background colour 2
.label BACKGROUNDCOLOUR2       = $D023 //Screen background colour 3
.label BACKGROUNDCOLOUR3       = $D024 //Screen background colour 4
.label SPRITEMULTICOLOUR0      = $D025 //Sprite multi-colour register 1
.label SPRITEMULTICOLOUR1      = $D026 //Sprite multi-colour register 2
.label SPRITECOLOUR0           = $D027 //Sprite 0 colour
.label SPRITECOLOUR1           = $D028
.label SPRITECOLOUR2           = $D029
.label SPRITECOLOUR3           = $D02A
.label SPRITECOLOUR4           = $D02B
.label SPRITECOLOUR5           = $D02C
.label SPRITECOLOUR6           = $D02D
.label SPRITECOLOUR7           = $D02E

//-------------------------------------------------------------------------------
// SID
//-------------------------------------------------------------------------------
.label VOICE1FQLOW             = $D400 //V1 frequency low-byte
.label VOICE1FQHIGH            = $D401 //V1 frequency high-byte
.label PWL1                    = $D402 //V1 pulse waveform low-byte
.label PWH1                    = $D403 //V1 pulse waveform high-byte
.label VOICE1CTRREG            = $D404 //V1 control register
.label VOICE1ATTACKDECAY       = $D405 //V1 attack/decay
.label SUREL1                  = $D406 //V1 sustain/release
.label VOICE2FQLOW             = $D407 //V2 frequency low-byte
.label VOICE2FQHIGH            = $D408 //V2 frequency high-byte
.label PWL2                    = $D409 //V2 pulse waveform low-byte
.label PWH2                    = $D40A //V2 pulse waveform high-byte
.label VOICE2CTRREG            = $D40B //V2 control register
.label VOICE2ATTACKDECAY       = $D40C //V2 attack/decay
.label SUREL2                  = $D40D //V2 sustain/release
.label VOICE3FQLOW             = $D40E //V3 frequency low-byte
.label VOICE3FQHIGH            = $D40F //V3 frequency high-byte
.label PWL3                    = $D410 //V3 pulse waveform low-byte
.label PWH3                    = $D411 //V3 pulse waveform high-byte
.label VOICE3CTRREG            = $D412 //V3 control register
.label VOICE3ATTACKDECAY       = $D413 //V3 attack/decay
.label SUREL3                  = $D414 //V3 sustain/release
.label FLTCUTLO                = $D415 //Filter cut off frequency
.label FLTCUTHI                = $D416 //Filter cut off frequency
.label FLTCON                  = $D417 //Filter Control
.label SIDVOLUMECONTROL        = $D418 //Volume
.label SIDRAND                 = $D41B //Oscillator 3 random number generator



.label COLOURRAM0      		= $D800 //Colour RAM $D800-$D8ff
.label COLOURRAM1			= $D900 //Colour RAM $D900-$D9FF 
.label COLOURRAM2			= $DA00 //Colour RAM $DA00-$DAFF
.label COLOURRAM3			= $DB00 //Colour RAM $DB00-$DBFF


.label CIAPort_A			= $DC00 //CIA port A
.label CIAPort_B			= $DC01 //CIA port B
.label DDRPort_B            = $DC03 //Data direction register port B
.label VICBANK				= $DD00
.label DDRPort_A            = $DD02 //Data direction register port A

