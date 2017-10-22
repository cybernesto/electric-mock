*ELECTRIC DUET MUSIC PLAYER FOR THE CRICKET

CHN       = $1D
SONG      = $1E
LEFTCHN   = $10
RIGHTCHN  = $20
ENAREG    = $07
VOL_A     = $08
TONE      = $06
DURATION  = $08

ACIACMD2  = $C0AA
ACIACTL2  = $C0AB
ACIAST2   = $C0A9
ACIARXTX2 = $C0A8

          ORG $300

          JSR INIT
          JSR RESET
          LDA #LEFTCHN
          STA CHN
          JSR ENACHN
          LDA #RIGHTCHN
          STA CHN
          JSR ENACHN
          JMP LOOP

SETVOL    NOP
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
          JSR OUT
          INY
          LDA (SONG),Y
          BEQ SKIP       ;IF 0 KEEP LTTSA
          JSR CONVFREQ
SKIP      LDA TONE
          JSR OUT
          INC CHN
          LDA CHN
          JSR OUT
          LDA TONE+1
          JSR OUT
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


INIT      LDA #$0B
          STA ACIACMD2
          LDA #$9E
          STA ACIACTL2
          RTS

OUT       PHA            ;SAVE BYTE TO SEND OUT
WT        LDA ACIAST2    ;READ STATUS OF SERIAL PORT
          AND #$10       ;SEE IF IT'S READY TO RECEIVE A BYTE
          BEQ WT         ;NOT READY, WAIT
          PLA            ;REGET BYTE TO SEND OUT
          STA ACIARXTX2  ;SEND IT
          RTS

IN        LDA ACIAST2    ;IS THERE A BYTE TO GET YET?
          AND #$08
          BEQ IN         ;NOPE, WAIT FOR IT
          LDA ACIARXTX2  ;GET INCOMING BYTE
          RTS

RESET     LDA #$A1
          JSR OUT
          RTS

ENACHN    LDA #ENAREG
          ORA CHN
          JSR OUT
          LDA #%00111110
          JSR OUT
          LDA #VOL_A
          ORA CHN
          JSR OUT
          LDA #$0F
          JSR OUT
          RTS

OCTAVE    DFB 1
TEMPO     DFB 8
TEMP      DFB 0
