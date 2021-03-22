TABLES:{

// $885F Enemy Chars Skulls 1 &2 & Spiders 1 & 2
ENEMY_CHARS: 
  	
	.byte $48,$49,$4A,$4B,$4C,$4D,$4E,$4F,$50,$51,$52,$53,$54,$55,$56,$57
	
//Attack wave arrays?
//20 levels in total

L8F6F: //$8F6F
        .byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02
        .byte $01,$01,$02,$02

L8F83: // $8F83
        .byte $03,$03,$03,$03,$02,$02,$02,$02,$03,$03,$03,$03,$02,$02,$02,$02
        .byte $03,$03,$02,$01

L8F97: // $8F97
        .byte $10,$07,$16,$0C,$0D,$0A,$1C,$0C,$09,$08,$1E,$0A,$0A,$09,$09,$08
        .byte $08,$07,$07,$06

L8FAB: // $8FAB IDS timer
            //$FF
        .byte $08,$1E,$14,$12,$12,$12,$12,$0E,$0C,$0C,$0C,$09,$09,$09,$09,$09
        .byte $08,$08,$07,$02

L8FBF: // $8FBF  Attack wave speed 
            //$18  
        .byte $30,$1A,$10,$16,$14,$11,$11,$16,$16,$15,$0D,$14,$14,$13,$13,$12
        .byte $12,$12,$10,$0E

L8FD3: // 8FD3        $C0
        .byte $20,$B8,$B0,$A0,$A0,$90,$80,$70,$68,$60,$58,$50,$50,$48,$40,$40
        .byte $38,$30,$30,$20

// ------------------------------
// $8AEC - gets copied to $1500
// Looks like co-ordinates for explosion sprites
// $8AEC
EXPLOSIONDATA_1: 
        .byte $8A,$83,$8C,$82,$8F,$87        // 138,131,134,130,143
// $8AF1
EXPLOSIONDATA_2:
        .byte $8F,$83,$10,$15,$9E,$08        // 135,143,131,16,21
// $8AF6
EXPLOSIONDATA_3:
        .byte $9F,$87,$8E,$09,$07,$05        // 158,08,159,135,142
// $8AFB
EXPLOSIONDATA_4:       
        .byte $85,$8C,$8A,$86,$87,$83
//$09,$07,$05,

// $8939 Background Colour Cycle Table?
ColourCycle_Table:
        .byte $00,$06,$02,$04,$05,$03,$07,$01,$08,$0E,$0A,$0C,$0D,$0B,$0F,$09


}


