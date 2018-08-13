;;; https://github.com/cosmonaut
;;; NES demo 3 -- movable sprite with background
;;; up/down/left/right move sprite
;;; a/b cycle sprite color palette
    
;;; Inspiration from:
;;; https://github.com/michaelcmartin/Ophis/blob/master/examples/hello_nes/hello_prg.oph
;;; Nerdy Nights Out: http://nintendoage.com/pub/faq/NA/index.html?load=nerdy_nights_out.html
;;; https://github.com/algofoogle/nes-gamedev-examples
    
    
;;; iNES header
.byte $4e,$45,$53,$1a,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00


; NES demo2 program (moving sprite)

.alias	sprites	$0200	; Keep our OAM DMA here.

.data
.org	$0000
.space	count	1               ;counter for cycling palette of sprite
.space  buttons 1               ;memory for storing button readout
.space  ptr 2                   ;pointer
.space	palette 32              ;palette data (optional placeholder)

.text
.org	$C000

reset:
    sei                         ;disable irqs
    cld                         ;disable decimal mode

*   bit $2002                   ;wait for vblank to make sure ppu is ready
    bpl -
*   bit $2002                   ;wait for vblank to make sure ppu is ready
    bpl -
    
    ldx #$40
    stx $4017                   ;disable apu frame irq
    ldx #$ff
    txs                         ;set up tack
    inx                         ;now x = 0
    stx $2000                   ;disable NMI
    stx $2001                   ;disable rendering
    stx $4010                   ;disable DMC IRQs

;;; Clear ram
clrmem:
    lda #$00
    sta $0000,x
    sta $0100,x
    sta $0200,x
    sta $0300,x
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    inx
    bne clrmem

;;; load NES background and sprite palettes
ldpalettes:
    lda $2002
    lda #$3f
    sta $2006
    lda #$00
    sta $2006
    ldx #$00
ldploop:
    lda prom,x
    sta $2007
    inx
    cpx #$20
    bne ldploop

;;; Load sprites into ram
ldsprites:
    ldx #$00
ldsloop:
    lda graphics,x
    sta sprites,x
    inx
    cpx #$10
    bne ldsloop

;;; Load background into $2000
    lda #<nametable             ;store nametable address in 0 page pointer
    sta ptr
    lda #>nametable
    sta ptr+1

    ;; set up nametable address
    lda $2002                   ;reset latch
    lda #$20
    sta $2006                   ;high byte of $2000
    lda #$00
    sta $2006                   ;low byte of $2000
    ldy #0                      ;index -- start at 0
    ldx #$04                    ;used to increment pointer high byte to get all 1024 bytes
bgloop:
    lda (ptr),y                 ;load nametable byte
    sta $2007                   ;store nametable byte
    iny
    bne bgloop                  ;repeat...
    inc ptr+1                   ;increment the pointer high byte to get next 256 nametable bytes...
    dex
    bne bgloop                  ;loop until all 1024 nametable bytes are finished.
    
    lda #$10                    ;Prime counter for palette cycling when hitting a or b
    sta count
    
    lda #$80                    ;enable NMI, sprites
    sta buttons                 ;prime button readout counter
    sta $2000
    lda #%00011110              ;enable sprites (disable left 8 px clipping)
    sta $2001
    lda #$00
    sta $2005
    sta $2005
    cli                         ;enable interrupts
    
forev:
    jmp forev

;;; The nmi/vblank interrupt
nmi:
    lda #$00
    sta $2003
    lda #$02
    sta $4014                   ;Start sprite DMA at address $0200

    ;; read controller 1
    ;; more info: https://wiki.nesdev.com/w/index.php/Controller_Reading
    lda #$01
    sta $4016                   ;strobe controller 1
    sta buttons                 ;put 0x01 in 'buttons' memory
    lsr 
    sta $4016
btnlp:
    lda $4016
    lsr 
    rol buttons                 ;bit shift buttons memory
    bcc btnlp

;;; Parse information about button presses
btnchk:
rdupdown:                       ;Avoid parsing simultaneous press of up AND down
    lda #$0c
    and buttons
    cmp #$0c
    beq rdleftright
rdup:
    lda #$08
    and buttons
    beq rddown
    lda $0200
    sec
    sbc #$01
    sta $0200
rddown:
    lda #$04
    and buttons
    beq rdleftright
    lda $0200
    clc
    adc #$01
    sta $0200
    
rdleftright:                    ;Avoid parsing simultanius R/L presses
    lda #$03
    and buttons
    cmp #$03
    beq rdab
rdleft:
    lda #$02
    and buttons
    beq rdright
    lda $0203
    sec
    sbc #$01
    sta $0203
rdright:
    lda #$01
    and buttons
    beq rdab
    lda $0203
    clc
    adc #$01
    sta $0203

rdab:                           ;Avoid parsing simultaneous a/b presses
    lda #$c0
    and buttons
    cmp #$c0
    beq done
rda:
    lda #$80
    and buttons
    beq rdb
    
    dec count
    bne rdb
    lda #$10
    sta count
    
    lda $0202
    clc
    adc #$01
    and #$03
    sta $0202
rdb:
    lda #$40
    and buttons
    beq done

    dec count
    bne done
    lda #$10
    sta count
    
    lda $0202
    sec
    sbc #$01
    and #$03
    sta $0202

    
done:   
    rti


.advance $e000
prom:
    .byte $0f,$00,$10,$30,$0f,$01,$21,$31,$0f,$06,$16,$26,$0f,$09,$19,$29 ;bg palette
    ;; .byte $0F,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$0F ;bg palette
    .byte $0F,$1C,$15,$14,$31,$02,$38,$3C,$0c,$1b,$2a,$39,$03,$24,$18,$11 ;sprite palette

;;; Memory containing information on 4 sprites to draw.
;;; Specifically, a circle sprite in each corner of the screen.
graphics:
    .byte $08,$06,$00,$08
    .byte $08,$06,$02,$f0
    .byte $e0,$06,$03,$08
    .byte $e0,$06,$01,$f0

;;; The background nametable (created with NES Screen Tool)
nametable:
.incbin "nam1.nam"              ;contains all 1024 bytes of name table and attributes
    

;;; Location of nmi (vblank), reset, and IRQ vectors
.advance $fffa
    .word nmi, reset, $0000
    
;;; CHR memory (See imag.chr)
.org $0000
.incbin "imag.chr"
;;; CHR file taken from https://github.com/algofoogle/nes-gamedev-examples
    
