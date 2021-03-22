.label SCREENCOLUMNTOPLOT             = $02
.label SCREENROWTOPLOT                = $03
.label CHARTOPLOT                     = $04
.label COLOURTOPLOT                   = $05

.label ZP_COUNTER                     = $07 //reused for Sprite Pointer tracking
.label ZP_TEMP_VAR_1                  = $08 //reused for Sprite Pointer tracking
.label ZP_TEMP_VAR_2                  = $09          

.label JOYSTICK_1                     = $0D
.label GameLoopTimer1                 = $0E


.label JOY_1_INUSE                    = $0F
.label JOY_2_INUSE                    = $10 

.label JOYSTICK_2                     = $11
.label GAMELOOPTIMER2                 = $12
.label SPRSPRCOLLISION                = $13
.label SPRBGNDCOLLISION               = $14
.label PLAYER_BULLET_FIRED            = $15
//Unkown                        = $16 //Value defined by Level Number
.label ATTACKWAVESPEED                = $17 //Value defined by Level Number

//Sprite_3_X                     = $1A    //Bullet?
//Sprite_3_Y                     = $1B
//Sprite_3_??                    = $1C
//Sprite_3_??                    = $1D
.label SFXloop_timer        			= $1E //Counts down to 0 before continuing game loop
//SFX Vafdiable?                 = $1F
//Unkown2                       = $20
//Unkown2                       = $21
.label SCOREBOARDVECTORLO             = $22
.label SCOREBOARDVECTORHI             = $23
.label ELECTRO_SFX_TIMER               = $24


.label SOME_KIND_OF_TIMER            = $25
.label SPRITE_6_X_POSITION            = $26
.label SPRITE_6_Y_POSITION            = $27
//Death Sat SFX                        = $28
//Death Sat SFX                        = $29        
//Death Sat SFX                        = $2A
//Death Sat SFX                        = $2B   
//Death Sat SFX                        = $2C  
.label Unkown                           = $2D
.label Unkown2                          = $2E
.label IRATIANSATELLITETIMER_1          = $2F
.label IRATIANSATELLITETIMER_2          = $30
.label SPRITE_6_COLOUR                  = $31
.label SPRITE_7_X_POSITION              = $32
.label SPRITE_7_Y_POSITION              = $33
.label RASTERVALUE                      = $34
//Unkown                        = $33
//Unkown                        = $35
//Unkown                        = $36
//Unkown Timer                   = $37
.label NumEnemiesForRound               = $38
.label THRESHOLDVALUE                   = $39

//Unkown                        = $3B //Value defined by Level Number
//Unkown                        = $3C
//Unkown                        = $3D
//Unkown                        = $3E

.label CURRENTLEVELNUMBER               = $3F

.label NUMPLAYERS                       = $40
.label TEAMMODEFLAG                     = $41
.label NUMBEROFJOYSTICKS                = $42
//Unkown                        = $43    //Gets loaded with current level number at startup
//Unkown                        = $44    //Gets loaded with current level number at startup
//Unkown                        = $45    //Gets loaded with threshold value at startup
//Unkown                        = $46    //Gets loaded with threshold value at startup

.label SCREENROWADDRESSLO               = $48    //?          
.label SCREENROWADDRESSHI               = $49    //?

.label TRAINMODEFLAG                    = $4C         
.label CURRENTKEYPRESS                  = $C5

.label SCREENRAM                        = $0400

.label HISCORESCREENADD                 = $0447

.label SCNROW2                          = $0428
.label SCNROW4                          = $04A0
.label SCNROW8                          = $0540
.label SCNROW11                         = $05B8
.label SCNROW12                         = $05E0
.label SCNROW13                         = $0608
.label SCNROW14                         = $0630
.label SCNROW15                         = $0658
.label SCNROW17                         = $06A8
.label SCNROW18                         = $06D0
.label SCNROW19                         = $06F8
.label SCNROW20                         = $0720
.label SCNROW21                         = $0748
.label SCNROW22                         = $0770
.label SCNROW23                         = $0798
.label SCNROW24                         = $07C0

.label SHIFTKEYENABLE                   = $0291
.label SCOREBOARD                        = $1F80


//Data tables
// Need to create these after ther game has started.


.label SCREENROWLOOKUPTABLELO           = $0340
.label SCREENROWLOOKUPTABLEHI           = $0360  

.label ENEMY_X_POS_TABLE                = $1200

.label ENEMY_Y_POS_TABLE                = $1300
.label ENEMY_SFX_TABLE                  = $1400

.label SPRITE_EXPLOSION_X_TABLE1        = $1500
.label SPRITE_EXPLOSION_X_TABLE2        = $1510
.label SPRITE_EXPLOSION_Y_TABLE3        = $1520
.label SPRITE_EXPLOSION_X_TABLE4        = $1530

.label CharSet_Target_Address           = $2000
.label Sprite_Target_Address            = $3000
