
          LST OFF
          DSK /HD1/DCKDLIB/LNK/MUSIC/PLAYER.ED
          REL

********************************
*                              *
*    Source: ELECTRIC DUET     *
*  interruptible pour intros   *
*                              *
********************************

* Utilisation: LDA #<ED_TBL
*              LDY #>ED_TBL
*              JSR PLAYER_ED
*
* ED_TBL  DA  adresse datas musique
*         DFB flag interruption [0=oui,1=non]
*         DA  adresse interruption (0 si non inter)
*         DA  liste des touches autoris{es en sortie
*         DFB flag inter clavier [0=temporaire,1=fin]
*         DA  adresse sortie key temporaire
*         DFB arrete @ la fin du morceau [0=oui,1=non]
*
* Au retour d'une sortie par touche:
*     carry=0 -> reprise
*     carry=1 -> force sortie d{finitive
*
* Utilisation page 0:
* $06/$07/$08/$09/$1D/$1E/$1F/$4E/$4F

********************************

PLAYER_ED ENT
          STA $06        ; sauve pointeur table
          STY $07

* Lecture table

          LDY #10        ; place en pile 11 octets table
:1        LDA ($06),Y
          PHA
          DEY
          BPL :1

          PLA
          STA ED_DATA    ; adr datas low
          PLA
          STA ED_DATA+1  ; adr datas high
          PLA
          STA ED_FLAG    ; flag interruption
          PLA
          STA ED_INTER+1 ; adr low inter
          PLA
          STA ED_INTER+2 ; adr high inter
          PLA
          STA ED_KEYL+1  ; adr low liste touches
          PLA
          STA ED_KEYL+2  ; adr high liste touches
          PLA
          STA ED_FLAGK   ; flag interruption clavier
          PLA
          STA ED_INTERK+1 ; adr low inter clavier
          PLA
          STA ED_INTERK+2 ; adr high inter clavier
          PLA
          STA ED_AGAIN+1 ; recommence du d{but ou arrete


* Player

ED_M      LDA ED_DATA
          STA $1E
          LDA ED_DATA+1
          STA $1F

          LDA #1
          STA $09
          STA $1D

          PHA
          PHA
          PHA
          BNE H0A2B

H0A16     INY
          LDA ($1E),Y
          STA $09
          INY
          LDA ($1E),Y
          STA $1D

H0A20     LDA $1E
          CLC
          ADC #$03
          STA $1E
          BCC H0A2B
          INC $1F

H0A2B     LDY #$00
          LDA ($1E),Y
          CMP #$01
          BEQ H0A16
          BCS H0A45

          PLA
          PLA
          PLA
ED_AGAIN  LDA #$FF       ; [0=fin,1=recommence]
          BNE ED_M       ; reprise du d{but
          RTS            ; fin

H0A38     LDX #$49
          INY
          LDA ($1E),Y
          BNE :1
          LDX #$C9
:1        RTS

H0A45     STA $08
          JSR H0A38
          STX H0A94
          STA $06
          LDX $09
:1        LSR
          DEX
          BNE :1
          STA H0A8C+1
          JSR H0A38
          STX H0ACC
          STA $07
          LDX $1D
:2        LSR
          DEX
          BNE :2
          STA H0AC4+1

********************************

* Interruption par JSR autoris{e ici

          LDA ED_FLAG
          BNE ED_NOINTER

ED_INTER  JSR $FFFF      ; adr interruption

********************************

ED_NOINTER PLA
          TAY
          PLA
          TAX
          PLA
          BNE H0A76

H0A73     BIT $C030
H0A76     CMP #0
          BMI H0A7D
          NOP
          BPL H0A80

H0A7D     BIT $C030

H0A80     STA $4E
          BIT $C000
          BPL NOKEY

          JSR ED_KEY     ; test touche autoris{e
          BCS NOKEY      ; non. Pas de prise en compte

          LDA ED_FLAGK   ; arret d{finitif?
          BNE ED_FIN     ; oui

          STX ED_X       ; sauve registres
          STY ED_Y
          LDA ED_KEYINTER ; touche enfonc{e

ED_INTERK JSR $FFFF      ; interruption touche
          BCS ED_FIN     ; the end (forc{)

          LDX ED_X
          LDY ED_Y
          JMP NOKEY      ; reprise comme si de rien n'{tait

ED_FIN    RTS

NOKEY     DEY
          BNE H0A8C
          BEQ H0A92

H0A8C     CPY #$36
          BEQ H0A94
          BNE H0A96

H0A92     LDY $06
H0A94     EOR #$40
H0A96     BIT $4E
          BVC H0AA1
          BVS H0A9C
H0A9C     BPL H0AA7
          NOP
          BMI H0AAA
H0AA1     NOP
          BMI H0AA7
          NOP
          BPL H0AAA

H0AA7     CMP $C030
H0AAA     DEC $4F
          BNE H0ABF
          DEC $08
          BNE H0ABF
          BVC H0AB7
          BIT $C030
H0AB7     PHA
          TXA
          PHA
          TYA
          PHA
          JMP H0A20

H0ABF     DEX
          BNE H0AC4
          BEQ H0ACA

H0AC4     CPX #$0C
          BEQ H0ACC
          BNE H0ACE

H0ACA     LDX $07
H0ACC     EOR #$80
H0ACE     BVS H0A73
          NOP
          BVC H0A76
          RTS

* Test autorisation touche

ED_KEY    STY ED_Y       ; sauve Y
          LDY #0
ED_KEYL   LDA $FFFF,Y
          BEQ :1         ; fin des touches autoris{es
          CMP $C000
          BEQ :2         ; found!
          INY            ; next
          BNE ED_KEYL

:2        STA ED_KEYINTER
          CLC
          DFB $24        ; bit

:1        SEC            ; bad key
          BIT $C010
          LDY ED_Y
          RTS

********************************

ED_FLAG   DFB 0          ; flag interruption
ED_FLAGK  DFB 0          ; flag interruption clavier
ED_KEYINTER DFB 0        ; touche ayant provoqu{e l'inter
ED_DATA   DFB 0,0        ; adr datas
ED_Y      DFB 0          ; sauvegarde registre Y
ED_X      DFB 0          ; sauvegarde registre X
