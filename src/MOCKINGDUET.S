*ELECTRIC DUET MUSIC PLAYER FOR THE MOCKINGBOARD
*COPYRIGHT 2014 CYBERNESTO

CHN       = $1D
SONG      = $1E
LEFTCHN   = $00
RIGHTCHN  = $02
ENAREG    = $07
VOL_A     = $08
VOL_B     = $09
TONE      = $06
DURATION  = $08


          ORG $300

          JSR INIT
          JSR RESET
          JSR ENACHN
          JMP LOOP

SETVOL
NEXT      LDA SONG
          CLC
          ADC #$03
          STA SONG
          BCC LOOP
          INC SONG+1
LOOP      LDY #$00
          LDA (SONG),Y
          CMP #$01
          BEQ SETVOL
          BPL SETNOTE    ;SET DURATION
END       JSR RESET
          RTS

SETNOTE   STA DURATION
          LDA #LEFTCHN
SEND      STA CHN
          STA $C401
          JSR SETREG1
          INY
          LDA (SONG),Y
          BEQ SKIP       ;IF 0 KEEP LTTSA
          JSR CONVFREQ
SKIP      LDA TONE
          STA $C401
          JSR WRDATA1
          INC CHN
          LDA CHN
          STA $C401
          JSR SETREG1
          LDA TONE+1
          STA $C401
          JSR WRDATA1
          LDA #RIGHTCHN
          STA CHN
          CPY #$02
          BNE SEND
          LDX DURATION
W1        LDY TEMPO
W2        DEC TEMP
          BNE W2
          DEY
          BNE W2
          DEX
          BNE W1
          BIT $C000
          BMI END
          JMP NEXT

CONVFREQ  LDX OCTAVE
          INX
          PHA
          LDA #$00
          STA TONE+1
          PLA
DECOCT    DEX
          BMI LOBYTE
          ASL
          ROL TONE+1
          JMP DECOCT
LOBYTE    STA TONE
          RTS


RESET     LDA #$00
          STA $C400
          STA $C480
          LDA #$04
          STA $C400
          STA $C480
          RTS

INIT      LDA #$FF
          STA $C403
          STA $C483
          LDA #$07
          STA $C402
          STA $C482
          RTS

SETREG1   LDA #$07
          STA $C400
          LDA #$04
          STA $C400
          RTS

WRDATA1   LDA #$06
          STA $C400
          LDA #$04
          STA $C400
          RTS

ENACHN    LDA #ENAREG
          STA $C401
          JSR SETREG1
          LDA #%00111100
          STA $C401
          JSR WRDATA1
          LDA #VOL_A
          STA $C401
          JSR SETREG1
          LDA #$0F
          STA $C401
          JSR WRDATA1
          LDA #VOL_B
          STA $C401
          JSR SETREG1
          LDA #$0F
          STA $C401
          JSR WRDATA1
          RTS

OCTAVE    DFB 1
TEMPO     DFB 8
TEMP      DFB 0
