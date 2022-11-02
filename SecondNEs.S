.db "NES", $1A, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0

.org $8000
.define PPUCTRL $2000
.define PPUMASK $2001
.define PPUADDR $2006
.define PPUDATA $2007
.define PPUSCROLL $2005
.define JOYPAD1 $4016
.define OAMADDR $2003
.define OAMDATA $2004
.define OAMDMA $4014

.define SCROLLX $01
.define buttons $02
.define spritePosX $03
.define spritePosY $04
.define tileN $05
;.define pivot $06
.define address0 $07
.define address1 $08


start:

    LDA #$3F
    STA PPUADDR
    LDA #0
    STA PPUADDR

;Fill First Palette------------------------------------------------------
    LDA #$20
    STA PPUDATA

    LDA #$28
    STA PPUDATA

    LDA #$38
    STA PPUDATA

    LDA #$0D
    STA PPUDATA

;Fill First Sprite Palette ----------------------------------------------   
    LDA #$3F
    STA PPUADDR
    LDA #$10
    STA PPUADDR

    LDA #$20
    STA PPUDATA

    LDA #$24
    STA PPUDATA

    LDA #$23
    STA PPUDATA

    LDA #$35
    STA PPUDATA

;Fill Second Sprite Palette----------------------------------------------
    LDA #$03
    STA PPUDATA

    LDA #$25
    STA PPUDATA

    LDA #$33
    STA PPUDATA

    LDA #$37
    STA PPUDATA
;----------------------------------------------------
    LDA #%10010000
    STA PPUCTRL

    LDA #%00011110
    STA PPUMASK

;Draw Name Table 0------------------------------------
    LDA #$20
    STA address0
    LDA address0
    STA PPUADDR
    
    LDA #$00
    STA address1
    LDA address1
    STA PPUADDR
        
    LDA #$00
    STA tileN

    LDX #16
    LDY #8
    JMP drawBG1

    drawBG1:
    LDA tileN
    STA PPUDATA
    INC tileN
    DEX 
    BNE drawBG1

    LDA address0
    STA PPUADDR
    LDA address1
    ADC #$20
    STA address1
    STA PPUADDR
    LDX #16 
    DEY
    BNE drawBG1

;Draw Name Table 1------------------------------------
    
    LDA #$24
    STA address0
    LDA address0
    STA PPUADDR
    
    LDA #$00
    STA address1
    LDA address1
    STA PPUADDR
        
    LDA #$40
    STA tileN

    LDX #16
    LDY #8
    JMP drawBG2
    
    drawBG2:
    LDA tileN
    STA PPUDATA
    INC tileN
    DEX
    BNE drawBG2

    LDA address0
    STA PPUADDR
    LDA address1
    ADC #$20
    STA address1
    STA PPUADDR
    LDX #16 
    DEY
    BNE drawBG2
    
    

;Sprite-----------------------------------------------

    LDX #64
    LDA #0
    STA OAMADDR
    BEQ clearOAMpage

    clearOAMpage:
    LDA #$FF
    STA OAMDATA
    LDA #$FF
    STA OAMDATA
    LDA #$FF
    STA OAMDATA
    LDA #$FF
    STA OAMDATA
    DEX
    BNE clearOAMpage

    LDA #$80
    STA spritePosX
    LDA #$78
    STA spritePosY

    LDA #0
    STA OAMADDR
    LDA spritePosY
    STA OAMDATA
    LDA #$F6
    STA OAMDATA
    LDA #%00000001
    STA OAMDATA
    LDA spritePosX
    STA OAMDATA



loop:
  JMP loop

readjoy:

    lda #$01
   
    sta JOYPAD1
    sta buttons
    lsr a        
   
    sta JOYPAD1
    joyloop:
        lda JOYPAD1
        lsr a           ; bit 0 -> Carry
        rol buttons  ; Carry -> bit 0; bit 7 -> Carry
        bcc joyloop
        rts


nmi:
    PHA
    JSR readjoy
    PLA

;Read command-----------------------------
    LDA buttons
    AND #%00000001
    BNE rightCMD
    
    LDA buttons
    AND #%00000010
    BNE leftCMD

    LDA buttons
    AND #%00000100
    BNE downCMD

    LDA buttons
    AND #%00001000
    BNE upCMD

    RTI
   
;Right Command----------------------------
    rightCMD:
    LDA SCROLLX
    CMP #$FF
    BEQ checkSpriteRight
    INC SCROLLX
    LDA SCROLLX
    STA PPUSCROLL
    LDA #$00
    STA PPUSCROLL
    JMP checkSpriteRight

    checkSpriteRight:
    LDA spritePosX
    CMP #$F8
    BEQ skipscroll
    INC spritePosX
    LDA #3
    STA OAMADDR
    LDA spritePosX
    STA OAMDATA
    RTI

;Left command-----------------------------
    leftCMD:
    LDA SCROLLX
    BEQ checkSpriteLeft
    DEC SCROLLX
    LDA SCROLLX
    STA PPUSCROLL
    LDA #$00
    STA PPUSCROLL
    JMP checkSpriteLeft

    checkSpriteLeft:
    LDA spritePosX
    BEQ skipscroll
    DEC spritePosX
    LDA #3
    STA OAMADDR
    LDA spritePosX
    STA OAMDATA
    RTI
    

;Down Command-----------------------------
    downCMD:    
    LDA spritePosY
    CMP #$E8
    BEQ skipscroll
    INC spritePosY
    LDA #0
    STA OAMADDR
    LDA spritePosY
    STA OAMDATA
    RTI

;Up Command-------------------------------
    upCMD:
    LDA spritePosY
    BEQ skipscroll
    DEC spritePosY
    LDA #0
    STA OAMADDR
    LDA spritePosY
    STA OAMDATA
    RTI
;SkipScroll-------------------------------
    skipscroll:
    LDA SCROLLX
    STA PPUSCROLL
    LDA #$00
    STA PPUSCROLL
    
  RTI

irq:
  RTI

.goto $FFFA

.dw nmi
.dw start
.dw irq

.incbin "mario0.chr"
.incbin "aiv256.chr"
