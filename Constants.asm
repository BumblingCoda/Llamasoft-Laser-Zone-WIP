//-------------------------------------------------------------------------------
//Characters
//-------------------------------------------------------------------------------
.label CHAR_SPACE				= $20
.label CHAR_ZERO            	= $30          
.label CHAR_ONE             	= $31
.label CHAR_LASER_TRACK_1   	= $40
.label CHAR_LASER_TRACK_5   	= $44
.label CHAR_LASER_TRACK_7   	= $46
.label CHAR_SKULL_1		    	= $48
.label CHAR_SKULL_2		    	= $4C
.label CHAR_SPIDER_1			= $50
.label CHAR_SPIDER_2			= $54
.label CHAR_ENEMY_FRAGMENT  	= $70
.label CHAR_THRESHOLD       	= $79          
//--------------------------	--------------------------------------------------
// COLOUR CONSTANTS
//-------------------------------------------------------------------------------
.const BLACK                    = $0
.const WHITE                    = $1
.const RED                      = $2
.const CYAN                     = $3
.const PURPLE                   = $4
.const GREEN                    = $5
.const BLUE                     = $6
.const YELLOW                   = $7
.const ORANGE                   = $8
.const BROWN                    = $9
.const LIGHTRED                 = $A
.const GRAY1                    = $B
.const GRAY2                    = $C
.const LIGHTBLUE                = $D
.const GRAY3                    = $E


//-------------------------------------------------------------------------------
// SOUND CONSTANTS
//-------------------------------------------------------------------------------
.const SND_DISABLE_VOICE               = 8
.const SND_TRIANGLE_GATE_OFF           = 16
.const SND_TRIANGLE_GATE_ON            = 17
.const SND_SAW_GATE_OFF                = 32
.const SND_SAW_GATE_ON                 = 33
.const SND_PULSE_GATE_OFF              = 64
.const SND_PULSE_GATE_ON               = 65
.const SND_NOISE_GATE_OFF              = 128
.const SND_NOISE_GATE_ON               = 129
.const SND_LOW_PASS_FILTER_MASK_ON     = %00010000


//-------------------------------------------------------------------------------
// INPUT CONSTANTS
//-------------------------------------------------------------------------------
.const KEY_F1                          = $4
.const KEY_F3                          = $5
.const KEY_F5                          = $6
.const KEY_F7                          = $3
.const KEY_SPACE                       = $3C
.const KEY_NONE                        = $40
.const KEY_J                           = 74
.const KEY_K                           = 75
.const KEY_P                           = $29
.const KEY_T                           = $16
.const JOY_UP                          = $1
.const JOY_DOWN                        = $2
.const JOY_LEFT                        = $4
.const JOY_RIGHT                       = $8
.const JOY_FIRE                        = $10



//-------------------------------------------------------------------------------
// GENERAL CONSTANTS
//-------------------------------------------------------------------------------
.const MAX_BULLET_TRAVEL_LEFT          = $05
.const MAX_BULLET_TRAVEL_RIGHT         = $E4
.const BULLET_TRAVEL_SPEED             = $18
          

.const CLRRAMBASE                      = $D800

.const CURRENTSCORECOLOURRAM           = $DBC0
.const HISCORECOLOURRAM                = $DB98
//-------------------------------------------------------------------------------
// SPRITE CONSTANTS
//-------------------------------------------------------------------------------
.const Spr1_X_Laser_Upright				= $C0    //Sprite 1 $3000 $C0 Horizontal Laser Upright
.const Spr2_X_Laser_Angled				= $C1
.const Spr3_Y_Laser_Upright				= $C2    
.const Spr4_Y_Laser_Angled				= $C3
.const Spr5_Vertical_Bullet           	= $C4    
.const Spr6_Vertical_Bullet_Angled   	= $C5
.const Spr7_Horizontal_Bullet         	= $C6    
.const Spr8_Horizontal_Bullet_Angled  	= $C7
.const Spr9_Player_Explosion          	= $C8
.const Spr10_IDS_Frame_1              	= $C9
.const Spr11_IDS_Frame_2              	= $CA          
.const Spr12_IDS_Frame_3              	= $CB 
.const Spr13_ZAP                      	= $CC 
.const Spr14_Vertical_Spark           	= $CD 
.const Spr15_Horizontal_Spark         	= $CE
.const Spr16_Llamasoft_Pet            	= $CF 


