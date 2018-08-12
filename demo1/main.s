;;; https://github.com/cosmonaut
;;; NES demo 1 -- display static sprites
    
;;; Inspiration from:
;;; https://github.com/michaelcmartin/Ophis/blob/master/examples/hello_nes/hello_prg.oph
;;; Nerdy Nights Out: http://nintendoage.com/pub/faq/NA/index.html?load=nerdy_nights_out.html
;;; https://github.com/algofoogle/nes-gamedev-examples

    
;;; iNES header
.byte $4e,$45,$53,$1a,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00


; NES demo program

.alias	sprites	$0200	; Keep our OAM DMA here.

.data
.org	$0000
.space	palette 32              ;palette data storage

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

    lda #$80                    ;enable NMI, sprites
    sta $2000
    lda #%00010000              ;enable sprites
    sta $2001
    cli                         ;enable interrupts
    
forev:
    jmp forev                   ;main forever loop

;;; NMI interrupt
nmi:
    lda #$00
    sta $2003
    lda #$02
    sta $4014                   ;Start sprite DMA at address $0200

    rti


.advance $e000
prom:
    .byte $0F,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$0F ;bg palette
    .byte $0F,$1C,$15,$14,$31,$02,$38,$3C,$0c,$1b,$2a,$39,$03,$24,$18,$11 ;sprite palette

;;; Memory containing information on 4 sprites to draw.
;;; Specifically, a circle sprite in each corner of the screen.
graphics:
    .byte $08,$06,$00,$08
    .byte $08,$06,$02,$f0
    .byte $e0,$06,$03,$08
    .byte $e0,$06,$01,$f0

;;; Location of nmi (vblank), reset, and IRQ vectors
.advance $fffa
    .word nmi, reset, $0000
    
;;; CHR memory (See imag.chr)
.org $0000
.incbin "imag.chr"
;;; CHR file taken from https://github.com/algofoogle/nes-gamedev-examples    
