       >>SOURCE FREE

IDENTIFICATION DIVISION.
PROGRAM-ID. WasteCutter.
*> WasteCutter: bureaucracy-slaying TUI. Cut waste, manage approval,
*> survive scandals, advisors, and interest groups -- all in COBOL.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT SCORE-FILE ASSIGN TO "scores.dat"
        ORGANIZATION IS LINE SEQUENTIAL
        FILE STATUS IS SCORE-STATUS.

DATA DIVISION.
FILE SECTION.
FD  SCORE-FILE.
01  SCORE-REC                   PIC X(120).

WORKING-STORAGE SECTION.
*> ---- Core run state ----
01  PLAYER-NAME                 PIC X(20) VALUE SPACES.
01  WASTE-CUT                   PIC 9(12) VALUE 0.
01  APPROVAL                    PIC S9(3)  VALUE 65.
01  TURNS-LEFT                  PIC 9(2)   VALUE 12.
01  TERM-NUM                    PIC 9      VALUE 1.
01  CONTINUE-FLAG               PIC X      VALUE "Y".
01  CHOICE                      PIC 9      VALUE 0.
01  GAME-OVER-KIND              PIC X      VALUE " ".
    *> M=mob R=resign V=victory T=technocrat C=chainsaw
    *> S=solid I=incomplete Q=quiet hero

*> ---- Location (1-4) ----
01  LOC-ID                      PIC 9 VALUE 1.
01  LOCATION-NAME               PIC X(14) VALUE "Oval Office".
01  DOSSIER-LINE                PIC X(70) VALUE SPACES.

01  LOC-NAME-DATA.
    05 FILLER                   PIC X(14) VALUE "Oval Office  ".
    05 FILLER                   PIC X(14) VALUE "Pentagon     ".
    05 FILLER                   PIC X(14) VALUE "Congress     ".
    05 FILLER                   PIC X(14) VALUE "EPA          ".
01  LOC-NAME-TAB REDEFINES LOC-NAME-DATA.
    05 LOC-NAME                 PIC X(14) OCCURS 4 TIMES.

*> Bold waste mult in tenths (10 = 1.0x)
01  LOC-BOLD-DATA.
    05 FILLER                   PIC 99 VALUE 10.
    05 FILLER                   PIC 99 VALUE 14.
    05 FILLER                   PIC 99 VALUE 08.
    05 FILLER                   PIC 99 VALUE 11.
01  LOC-BOLD-TAB REDEFINES LOC-BOLD-DATA.
    05 LOC-BOLD-PCT             PIC 99 OCCURS 4 TIMES.

*> Extra scandal approval damage by location
01  LOC-SCAND-DATA.
    05 FILLER                   PIC S99 VALUE +05.
    05 FILLER                   PIC S99 VALUE +00.
    05 FILLER                   PIC S99 VALUE -02.
    05 FILLER                   PIC S99 VALUE +01.
01  LOC-SCAND-TAB REDEFINES LOC-SCAND-DATA.
    05 LOC-SCAND-X              PIC S99 OCCURS 4 TIMES.

*> Investigate / rally / media approval mods by location
01  LOC-INV-DATA.
    05 FILLER                   PIC S99 VALUE +03.
    05 FILLER                   PIC S99 VALUE +02.
    05 FILLER                   PIC S99 VALUE +05.
    05 FILLER                   PIC S99 VALUE +06.
01  LOC-INV-TAB REDEFINES LOC-INV-DATA.
    05 LOC-INV-AP               PIC S99 OCCURS 4 TIMES.

01  LOC-RALLY-DATA.
    05 FILLER                   PIC S99 VALUE +04.
    05 FILLER                   PIC S99 VALUE +02.
    05 FILLER                   PIC S99 VALUE +08.
    05 FILLER                   PIC S99 VALUE +05.
01  LOC-RALLY-TAB REDEFINES LOC-RALLY-DATA.
    05 LOC-RALLY-AP             PIC S99 OCCURS 4 TIMES.

01  LOC-MEDIA-DATA.
    05 FILLER                   PIC S99 VALUE +05.
    05 FILLER                   PIC S99 VALUE +03.
    05 FILLER                   PIC S99 VALUE +06.
    05 FILLER                   PIC S99 VALUE +04.
01  LOC-MEDIA-TAB REDEFINES LOC-MEDIA-DATA.
    05 LOC-MEDIA-AP             PIC S99 OCCURS 4 TIMES.

01  LOC-DOSSIER-DATA.
    05 FILLER PIC X(70) VALUE
       "Executive suite: optics rule. Scandals bite harder here.     ".
    05 FILLER PIC X(70) VALUE
       "Defense contractors circle. Bold cuts pay huge; unions heat. ".
    05 FILLER PIC X(70) VALUE
       "Horse-trading floor. Rallies & leaks thrive; bold cuts stall.".
    05 FILLER PIC X(70) VALUE
       "Green labyrinth. Audits shine; media spins every cut.        ".
01  LOC-DOSSIER-TAB REDEFINES LOC-DOSSIER-DATA.
    05 LOC-DOSSIER              PIC X(70) OCCURS 4 TIMES.

*> ---- Current waste target / event ----
01  TARGET-TITLE                PIC X(42) VALUE SPACES.
01  TARGET-BASE                 PIC 9(12) VALUE 100000000.
01  TARGET-INVESTIGATED         PIC X VALUE "N".
01  TARGET-IDX                  PIC 99 VALUE 1.
01  EVT-COUNT                   PIC 99 VALUE 12.

01  EVT-TITLE-DATA.
    05 FILLER PIC X(42) VALUE "Bridge to Nowhere expansion             ".
    05 FILLER PIC X(42) VALUE "Synergy workshop consultant army        ".
    05 FILLER PIC X(42) VALUE "Museum of Bureaucratic Excellence       ".
    05 FILLER PIC X(42) VALUE "Stealth umbrella procurement            ".
    05 FILLER PIC X(42) VALUE "Bipartisan junket to Maui                ".
    05 FILLER PIC X(42) VALUE "Study on studying studies                ".
    05 FILLER PIC X(42) VALUE "Gold-plated desalination pilot           ".
    05 FILLER PIC X(42) VALUE "Empty data center in the desert          ".
    05 FILLER PIC X(42) VALUE "Presidential portrait refresh fund       ".
    05 FILLER PIC X(42) VALUE "Carrier pigeon modernization             ".
    05 FILLER PIC X(42) VALUE "Climate-themed yacht for outreach        ".
    05 FILLER PIC X(42) VALUE "Endless RFPs for new RFP software        ".
01  EVT-TITLE-TAB REDEFINES EVT-TITLE-DATA.
    05 EVT-TITLE                PIC X(42) OCCURS 12 TIMES.

*> Preferred location 0=any, else 1-4; base waste in millions
01  EVT-LOC-DATA.
    05 FILLER PIC 9 VALUE 3.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 3.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC 9 VALUE 3.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 4.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC 9 VALUE 1.
    05 FILLER PIC 9 VALUE 2.
    05 FILLER PIC 9 VALUE 4.
    05 FILLER PIC 9 VALUE 0.
01  EVT-LOC-TAB REDEFINES EVT-LOC-DATA.
    05 EVT-PREF-LOC             PIC 9 OCCURS 12 TIMES.

01  EVT-BASE-M-DATA.
    05 FILLER PIC 999 VALUE 180.
    05 FILLER PIC 999 VALUE 090.
    05 FILLER PIC 999 VALUE 120.
    05 FILLER PIC 999 VALUE 250.
    05 FILLER PIC 999 VALUE 070.
    05 FILLER PIC 999 VALUE 060.
    05 FILLER PIC 999 VALUE 200.
    05 FILLER PIC 999 VALUE 220.
    05 FILLER PIC 999 VALUE 040.
    05 FILLER PIC 999 VALUE 300.
    05 FILLER PIC 999 VALUE 160.
    05 FILLER PIC 999 VALUE 110.
01  EVT-BASE-M-TAB REDEFINES EVT-BASE-M-DATA.
    05 EVT-BASE-M               PIC 999 OCCURS 12 TIMES.

*> ---- Dual feedback ----
01  RESULT-TEXT                 PIC X(70) VALUE SPACES.
01  NEWS-TEXT                   PIC X(70) VALUE SPACES.

*> ---- HUD helpers ----
01  APPR-BAND                   PIC X(6)  VALUE "HIGH  ".
01  PROG-BAR                    PIC X(20) VALUE ALL ".".
01  PROG-FILL                   PIC 99 VALUE 0.
01  PROG-I                      PIC 99 VALUE 0.
01  WIN-GOAL                    PIC 9(12) VALUE 1000000000.
01  REPUTATION                  PIC X(22) VALUE "Fresh Appointee".
01  WASTE-DISP                  PIC ZZZ,ZZZ,ZZZ,ZZ9.
01  TARGET-DISP                 PIC ZZZ,ZZZ,ZZZ,ZZ9.

*> ---- Play tracking / NPCs / factions ----
01  INV-COUNT                   PIC 99 VALUE 0.
01  BOLD-COUNT                  PIC 99 VALUE 0.
01  RALLY-COUNT                 PIC 99 VALUE 0.
01  MEDIA-COUNT                 PIC 99 VALUE 0.
01  CUT-BY-LOC.
    05 CUT-LOC                  PIC 99 OCCURS 4 TIMES VALUE 0.
01  MEDIA-FAVOR                 PIC S9(3) VALUE 50.
01  UNION-HEAT                  PIC S9(3) VALUE 20.
01  DONOR-HEAT                  PIC S9(3) VALUE 30.
01  GREEN-HEAT                  PIC S9(3) VALUE 25.
01  CRISIS-DONE                 PIC X VALUE "N".
01  ADVISOR-READY               PIC X VALUE "N".
01  ADVISOR-CHOICE              PIC 9 VALUE 0.
01  LAST-NPC                    PIC X(18) VALUE SPACES.

01  NPC-NAME-DATA.
    05 FILLER PIC X(18) VALUE "Sec. Hardline     ".
    05 FILLER PIC X(18) VALUE "Gen. Porkbarrel   ".
    05 FILLER PIC X(18) VALUE "Sen. Filibuster   ".
    05 FILLER PIC X(18) VALUE "Dir. Greenlight   ".
01  NPC-NAME-TAB REDEFINES NPC-NAME-DATA.
    05 NPC-NAME                 PIC X(18) OCCURS 4 TIMES.

*> ---- RNG ----
01  WS-TIME                     PIC 9(8) VALUE 0.
01  WS-SEED                     PIC 9(9) VALUE 1.
01  WS-ROLL                     PIC 9(3) VALUE 0.
01  WS-TMP                      PIC S9(7) VALUE 0.
01  WS-AMT                      PIC 9(12) VALUE 0.
01  WS-DELTA                    PIC S9(3) VALUE 0.
01  WS-I                        PIC 99 VALUE 0.
01  WS-J                        PIC 99 VALUE 0.
01  WS-FOUND                    PIC X VALUE "N".

*> ---- End screen strings ----
01  END-TITLE                   PIC X(50) VALUE SPACES.
01  END-LINE-1                  PIC X(60) VALUE SPACES.
01  END-LINE-2                  PIC X(60) VALUE SPACES.
01  END-LINE-3                  PIC X(60) VALUE SPACES.
01  END-COLOR                   PIC 9 VALUE 2.

*> ---- High score ----
01  SCORE-STATUS                PIC XX VALUE "00".
01  SCORE-LINE                  PIC X(120).
01  SCORE-WASTE-EDIT            PIC 9(12).

*> ---- Action menu labels (dynamic hints) ----
01  MENU-1                      PIC X(58) VALUE SPACES.
01  MENU-2                      PIC X(58) VALUE SPACES.
01  MENU-3                      PIC X(58) VALUE SPACES.
01  MENU-4                      PIC X(58) VALUE SPACES.
01  MENU-5                      PIC X(58) VALUE SPACES.
01  MENU-6                      PIC X(58) VALUE SPACES.
01  INV-HINT                    PIC X(12) VALUE "(locked)    ".

SCREEN SECTION.
01  MAIN-SCREEN.
    05 BLANK SCREEN BACKGROUND-COLOR 0 FOREGROUND-COLOR 7.
    05 LINE 1 COL 1 PIC X(80) VALUE ALL "=" FOREGROUND-COLOR 1.
    05 LINE 2 COL 18 VALUE "WASTE CUTTER" FOREGROUND-COLOR 14
       HIGHLIGHT.
    05 LINE 2 COL 32 VALUE " - Bureaucracy Slayer - " FOREGROUND-COLOR 11.
    05 LINE 2 COL 58 VALUE "Term " FOREGROUND-COLOR 10.
    05 LINE 2 COL 63 PIC 9 FROM TERM-NUM FOREGROUND-COLOR 14.
    05 LINE 3 COL 1 PIC X(80) VALUE ALL "=" FOREGROUND-COLOR 1.

    05 LINE 4 COL 2 VALUE "Agent:" FOREGROUND-COLOR 10.
    05 LINE 4 COL 9 PIC X(20) FROM PLAYER-NAME FOREGROUND-COLOR 15.
    05 LINE 4 COL 30 VALUE "Title:" FOREGROUND-COLOR 10.
    05 LINE 4 COL 37 PIC X(22) FROM REPUTATION FOREGROUND-COLOR 14.
    05 LINE 4 COL 61 VALUE "Turns:" FOREGROUND-COLOR 10.
    05 LINE 4 COL 68 PIC 99 FROM TURNS-LEFT FOREGROUND-COLOR 14.

    05 LINE 5 COL 2 VALUE "Cut:$" FOREGROUND-COLOR 10.
    05 LINE 5 COL 7 PIC ZZZ,ZZZ,ZZZ,ZZ9 FROM WASTE-CUT
       FOREGROUND-COLOR 14.
    05 LINE 5 COL 28 VALUE "Goal:$1.0B [" FOREGROUND-COLOR 10.
    05 LINE 5 COL 40 PIC X(20) FROM PROG-BAR FOREGROUND-COLOR 11.
    05 LINE 5 COL 60 VALUE "]" FOREGROUND-COLOR 10.

    05 LINE 6 COL 2 VALUE "Approval:" FOREGROUND-COLOR 10.
    05 LINE 6 COL 12 PIC ZZ9 FROM APPROVAL FOREGROUND-COLOR 14.
    05 LINE 6 COL 16 VALUE "%" FOREGROUND-COLOR 14.
    05 LINE 6 COL 18 VALUE "[" FOREGROUND-COLOR 10.
    05 LINE 6 COL 19 PIC X(6) FROM APPR-BAND FOREGROUND-COLOR 14.
    05 LINE 6 COL 25 VALUE "]" FOREGROUND-COLOR 10.
    05 LINE 6 COL 28 VALUE "Loc:" FOREGROUND-COLOR 10.
    05 LINE 6 COL 33 PIC X(14) FROM LOCATION-NAME FOREGROUND-COLOR 15.
    05 LINE 6 COL 49 VALUE "Media" FOREGROUND-COLOR 10.
    05 LINE 6 COL 55 PIC ZZ9 FROM MEDIA-FAVOR FOREGROUND-COLOR 11.
    05 LINE 6 COL 59 VALUE "Union" FOREGROUND-COLOR 10.
    05 LINE 6 COL 65 PIC ZZ9 FROM UNION-HEAT FOREGROUND-COLOR 12.

    05 LINE 7 COL 2 VALUE "Target:" FOREGROUND-COLOR 11.
    05 LINE 7 COL 10 PIC X(42) FROM TARGET-TITLE FOREGROUND-COLOR 15.
    05 LINE 7 COL 54 VALUE "$" FOREGROUND-COLOR 10.
    05 LINE 7 COL 55 PIC ZZZ,ZZZ,ZZZ,ZZ9 FROM TARGET-BASE
       FOREGROUND-COLOR 14.
    05 LINE 8 COL 2 VALUE "Audit:" FOREGROUND-COLOR 11.
    05 LINE 8 COL 9 PIC X(12) FROM INV-HINT FOREGROUND-COLOR 13.
    05 LINE 9 COL 2 VALUE "Dossier:" FOREGROUND-COLOR 10.
    05 LINE 9 COL 11 PIC X(70) FROM DOSSIER-LINE FOREGROUND-COLOR 7.

    05 LINE 10 COL 2 VALUE "RESULT:" FOREGROUND-COLOR 11.
    05 LINE 10 COL 10 PIC X(70) FROM RESULT-TEXT FOREGROUND-COLOR 15.
    05 LINE 11 COL 2 VALUE "NEWS:  " FOREGROUND-COLOR 12.
    05 LINE 11 COL 10 PIC X(70) FROM NEWS-TEXT FOREGROUND-COLOR 13.

    05 LINE 13 COL 2 VALUE "Actions:" FOREGROUND-COLOR 11.
    05 LINE 14 COL 4 PIC X(58) FROM MENU-1 FOREGROUND-COLOR 7.
    05 LINE 15 COL 4 PIC X(58) FROM MENU-2 FOREGROUND-COLOR 7.
    05 LINE 16 COL 4 PIC X(58) FROM MENU-3 FOREGROUND-COLOR 7.
    05 LINE 17 COL 4 PIC X(58) FROM MENU-4 FOREGROUND-COLOR 7.
    05 LINE 18 COL 4 PIC X(58) FROM MENU-5 FOREGROUND-COLOR 7.
    05 LINE 19 COL 4 PIC X(58) FROM MENU-6 FOREGROUND-COLOR 7.

    05 LINE 21 COL 2 VALUE "Choice (1-6): " FOREGROUND-COLOR 15.
    05 LINE 21 COL 16 PIC 9 TO CHOICE FOREGROUND-COLOR 14.
    05 LINE 22 COL 2 VALUE
       "Factions react. Investigate before bold cuts. Relocate is free."
       FOREGROUND-COLOR 8.
    05 LINE 24 COL 1 PIC X(80) VALUE ALL "=" FOREGROUND-COLOR 1.

01  ADVISOR-SCREEN.
    05 BLANK SCREEN BACKGROUND-COLOR 0 FOREGROUND-COLOR 7.
    05 LINE 2 COL 20 VALUE "*** ADVISOR INTERVENTION ***"
       FOREGROUND-COLOR 14 HIGHLIGHT.
    05 LINE 4 COL 5 VALUE "Your advisor corners you in the hallway."
       FOREGROUND-COLOR 11.
    05 LINE 6 COL 5 PIC X(70) FROM RESULT-TEXT FOREGROUND-COLOR 15.
    05 LINE 8 COL 5 VALUE "1." FOREGROUND-COLOR 10.
    05 LINE 8 COL 8 PIC X(60) FROM MENU-1 FOREGROUND-COLOR 7.
    05 LINE 9 COL 5 VALUE "2." FOREGROUND-COLOR 10.
    05 LINE 9 COL 8 PIC X(60) FROM MENU-2 FOREGROUND-COLOR 7.
    05 LINE 11 COL 5 VALUE "Choose (1-2): " FOREGROUND-COLOR 15.
    05 LINE 11 COL 20 PIC 9 TO ADVISOR-CHOICE FOREGROUND-COLOR 14.

01  END-SCREEN.
    05 BLANK SCREEN BACKGROUND-COLOR 0 FOREGROUND-COLOR 7.
    05 LINE 2 COL 1 PIC X(80) VALUE ALL "=" FOREGROUND-COLOR 1.
    05 LINE 4 COL 15 PIC X(50) FROM END-TITLE FOREGROUND-COLOR 14
       HIGHLIGHT.
    05 LINE 6 COL 10 PIC X(60) FROM END-LINE-1 FOREGROUND-COLOR 15.
    05 LINE 7 COL 10 PIC X(60) FROM END-LINE-2 FOREGROUND-COLOR 11.
    05 LINE 8 COL 10 PIC X(60) FROM END-LINE-3 FOREGROUND-COLOR 13.
    05 LINE 10 COL 10 VALUE "Agent: " FOREGROUND-COLOR 10.
    05 LINE 10 COL 18 PIC X(20) FROM PLAYER-NAME FOREGROUND-COLOR 15.
    05 LINE 11 COL 10 VALUE "Title: " FOREGROUND-COLOR 10.
    05 LINE 11 COL 18 PIC X(22) FROM REPUTATION FOREGROUND-COLOR 14.
    05 LINE 12 COL 10 VALUE "Waste cut: $" FOREGROUND-COLOR 10.
    05 LINE 12 COL 22 PIC ZZZ,ZZZ,ZZZ,ZZ9 FROM WASTE-CUT
       FOREGROUND-COLOR 14.
    05 LINE 13 COL 10 VALUE "Approval: " FOREGROUND-COLOR 10.
    05 LINE 13 COL 21 PIC ZZ9 FROM APPROVAL FOREGROUND-COLOR 14.
    05 LINE 13 COL 25 VALUE "%  [" FOREGROUND-COLOR 14.
    05 LINE 13 COL 29 PIC X(6) FROM APPR-BAND FOREGROUND-COLOR 14.
    05 LINE 13 COL 35 VALUE "]" FOREGROUND-COLOR 14.
    05 LINE 15 COL 10 VALUE "Score saved to scores.dat (if writable)."
       FOREGROUND-COLOR 8.
    05 LINE 17 COL 10 VALUE "Press ENTER to exit..." FOREGROUND-COLOR 15.
    05 LINE 19 COL 1 PIC X(80) VALUE ALL "=" FOREGROUND-COLOR 1.

01  TITLE-SCREEN.
    05 BLANK SCREEN BACKGROUND-COLOR 0 FOREGROUND-COLOR 7.
    05 LINE 3 COL 15 VALUE "=========================================="
       FOREGROUND-COLOR 1.
    05 LINE 5 COL 22 VALUE "W A S T E   C U T T E R" FOREGROUND-COLOR 14
       HIGHLIGHT.
    05 LINE 6 COL 20 VALUE "The COBOL Bureaucracy Slayer"
       FOREGROUND-COLOR 11.
    05 LINE 8 COL 12 VALUE
       "Cut pork. Manage approval. Dodge scandals." FOREGROUND-COLOR 7.
    05 LINE 9 COL 12 VALUE
       "Investigate before you swing the chainsaw." FOREGROUND-COLOR 7.
    05 LINE 10 COL 12 VALUE
       "Locations matter. Factions remember." FOREGROUND-COLOR 7.
    05 LINE 12 COL 12 VALUE "Win: cut $1B+ with approval 50%+."
       FOREGROUND-COLOR 10.
    05 LINE 13 COL 12 VALUE "Die: approval hits zero. Mob time."
       FOREGROUND-COLOR 12.
    05 LINE 15 COL 12 VALUE "Enter callsign: " FOREGROUND-COLOR 15.
    05 LINE 15 COL 29 PIC X(20) TO PLAYER-NAME FOREGROUND-COLOR 14.
    05 LINE 17 COL 15 VALUE "=========================================="
       FOREGROUND-COLOR 1.

PROCEDURE DIVISION.
MAIN-LOGIC.
    PERFORM INIT-RUN
    PERFORM GAME-LOOP UNTIL CONTINUE-FLAG = "N" OR TURNS-LEFT = 0
        OR GAME-OVER-KIND = "M"
    PERFORM RESOLVE-ENDING
    PERFORM SAVE-HIGH-SCORE
    PERFORM SHOW-END-SCREEN
    STOP RUN.

INIT-RUN.
    ACCEPT WS-TIME FROM TIME
    IF WS-TIME = 0
        MOVE 1 TO WS-SEED
    ELSE
        MOVE WS-TIME TO WS-SEED
    END-IF
    *> Seed RNG (RANDOM with arg re-seeds and returns a value)
    COMPUTE WS-ROLL = FUNCTION INTEGER(FUNCTION RANDOM(WS-SEED) * 100)
    DISPLAY TITLE-SCREEN
    ACCEPT TITLE-SCREEN
    IF PLAYER-NAME = SPACES
        MOVE "Anonymous" TO PLAYER-NAME
    END-IF
    MOVE 1 TO LOC-ID
    PERFORM APPLY-LOCATION
    PERFORM PICK-TARGET
    MOVE "Welcome, waste slayer. Balance steel and soft power."
        TO RESULT-TEXT
    MOVE "Wire services online. Congress is already leaking."
        TO NEWS-TEXT
    PERFORM REFRESH-HUD
    PERFORM BUILD-MENUS.

GAME-LOOP.
    MOVE 0 TO CHOICE
    PERFORM REFRESH-HUD
    PERFORM BUILD-MENUS
    DISPLAY MAIN-SCREEN
    ACCEPT MAIN-SCREEN
    EVALUATE CHOICE
        WHEN 1
            PERFORM DO-INVESTIGATE
        WHEN 2
            PERFORM DO-BOLD-CUT
        WHEN 3
            PERFORM DO-RALLY
        WHEN 4
            PERFORM DO-MEDIA
        WHEN 5
            PERFORM DO-RELOCATE
        WHEN 6
            MOVE "R" TO GAME-OVER-KIND
            MOVE "N" TO CONTINUE-FLAG
        WHEN OTHER
            MOVE "Invalid input. The bureaucracy sighs at you."
                TO RESULT-TEXT
    END-EVALUATE
    IF CONTINUE-FLAG = "Y" AND GAME-OVER-KIND NOT = "M"
        PERFORM MAYBE-SCANDAL
        PERFORM MAYBE-CRISIS
        PERFORM MAYBE-ADVISOR
        PERFORM MAYBE-NPC-NEWS
        PERFORM UPDATE-REPUTATION
        PERFORM CLAMP-ALL
        IF APPROVAL <= 0
            MOVE "M" TO GAME-OVER-KIND
            MOVE "N" TO CONTINUE-FLAG
        END-IF
    END-IF.

*> ============================================================
*> Actions
*> ============================================================
DO-INVESTIGATE.
    IF TURNS-LEFT = 0
        EXIT PARAGRAPH
    END-IF
    SUBTRACT 1 FROM TURNS-LEFT
    ADD 1 TO INV-COUNT
    MOVE "Y" TO TARGET-INVESTIGATED
    *> Small verified cut: 15% of target base
    COMPUTE WS-AMT = TARGET-BASE * 15 / 100
    ADD WS-AMT TO WASTE-CUT
    COMPUTE WS-DELTA = 5 + LOC-INV-AP(LOC-ID)
    ADD WS-DELTA TO APPROVAL
    ADD 3 TO MEDIA-FAVOR
    MOVE WS-AMT TO WASTE-DISP
    MOVE SPACES TO RESULT-TEXT
    STRING "Audit unlocks the books. Confirmed cut ~$"
        DELIMITED BY SIZE
        FUNCTION TRIM(WASTE-DISP)
        DELIMITED BY SIZE
        ". Bold cuts now armed."
        DELIMITED BY SIZE
        INTO RESULT-TEXT
    END-STRING
    MOVE "Inspectors General nod. Cred ticks up." TO NEWS-TEXT
    PERFORM ROLL-100
    IF WS-ROLL < 20
        ADD 2 TO APPROVAL
        MOVE "Quiet whistleblower confirms your findings."
            TO NEWS-TEXT
    END-IF.

DO-BOLD-CUT.
    IF TURNS-LEFT = 0
        EXIT PARAGRAPH
    END-IF
    SUBTRACT 1 FROM TURNS-LEFT
    ADD 1 TO BOLD-COUNT
    ADD 1 TO CUT-LOC(LOC-ID)
    PERFORM ROLL-100
    IF TARGET-INVESTIGATED = "Y"
        *> Armed cut: higher payout, milder base risk
        COMPUTE WS-AMT = TARGET-BASE * LOC-BOLD-PCT(LOC-ID) / 10
        COMPUTE WS-AMT = WS-AMT * 120 / 100
        MOVE -10 TO WS-DELTA
        EVALUATE TRUE
            WHEN WS-ROLL < 12
                *> Backlash
                COMPUTE WS-AMT = WS-AMT * 70 / 100
                MOVE -22 TO WS-DELTA
                MOVE "Armed cut, but protests explode. Backlash!"
                    TO RESULT-TEXT
            WHEN WS-ROLL < 22
                *> Hidden goldmine
                COMPUTE WS-AMT = WS-AMT * 150 / 100
                MOVE -6 TO WS-DELTA
                MOVE "Jackpot: audit trail led to a goldmine of waste!"
                    TO RESULT-TEXT
            WHEN OTHER
                MOVE "Investigated strike lands. Pork vaporized."
                    TO RESULT-TEXT
        END-EVALUATE
    ELSE
        *> Blind cut: halfish payout, nastier risk
        COMPUTE WS-AMT = TARGET-BASE * LOC-BOLD-PCT(LOC-ID) / 10
        COMPUTE WS-AMT = WS-AMT * 55 / 100
        MOVE -18 TO WS-DELTA
        EVALUATE TRUE
            WHEN WS-ROLL < 25
                COMPUTE WS-AMT = WS-AMT * 40 / 100
                MOVE -28 TO WS-DELTA
                MOVE "Blind slash hit a popular program. PR disaster."
                    TO RESULT-TEXT
            WHEN WS-ROLL < 35
                COMPUTE WS-AMT = WS-AMT * 160 / 100
                MOVE -12 TO WS-DELTA
                MOVE "Blind luck: you gutted a pure grift by accident."
                    TO RESULT-TEXT
            WHEN OTHER
                MOVE "Bold un-audited cuts. Waste falls; tempers rise."
                    TO RESULT-TEXT
        END-EVALUATE
    END-IF
    ADD WS-AMT TO WASTE-CUT
    ADD WS-DELTA TO APPROVAL
    *> Faction heat by location
    EVALUATE LOC-ID
        WHEN 2
            ADD 12 TO UNION-HEAT
            ADD 5 TO DONOR-HEAT
        WHEN 3
            ADD 8 TO DONOR-HEAT
            SUBTRACT 3 FROM MEDIA-FAVOR
        WHEN 4
            ADD 14 TO GREEN-HEAT
            ADD 4 TO MEDIA-FAVOR
        WHEN OTHER
            ADD 6 TO DONOR-HEAT
    END-EVALUATE
    MOVE NPC-NAME(LOC-ID) TO LAST-NPC
    MOVE WS-AMT TO WASTE-DISP
    MOVE SPACES TO NEWS-TEXT
    STRING "Markets notice: $"
        DELIMITED BY SIZE
        FUNCTION TRIM(WASTE-DISP)
        DELIMITED BY SIZE
        " excised. "
        DELIMITED BY SIZE
        FUNCTION TRIM(LAST-NPC)
        DELIMITED BY SIZE
        " fumes."
        DELIMITED BY SIZE
        INTO NEWS-TEXT
    END-STRING
    *> Target resolved -- pull a new one
    MOVE "N" TO TARGET-INVESTIGATED
    PERFORM PICK-TARGET.

DO-RALLY.
    IF TURNS-LEFT = 0
        EXIT PARAGRAPH
    END-IF
    SUBTRACT 1 FROM TURNS-LEFT
    ADD 1 TO RALLY-COUNT
    COMPUTE WS-AMT = 20000000 + (LOC-RALLY-AP(LOC-ID) * 1000000)
    ADD WS-AMT TO WASTE-CUT
    COMPUTE WS-DELTA = 8 + LOC-RALLY-AP(LOC-ID)
    PERFORM ROLL-100
    IF WS-ROLL < 15
        SUBTRACT 5 FROM WS-DELTA
        MOVE "Rally is sparsely attended. Soft bounce only."
            TO RESULT-TEXT
    ELSE
        IF WS-ROLL > 90
            ADD 5 TO WS-DELTA
            MOVE "Crowd erupts. Clips go viral. Mandate swells."
                TO RESULT-TEXT
        ELSE
            MOVE "Town halls land. Support climbs; modest cuts stick."
                TO RESULT-TEXT
        END-IF
    END-IF
    ADD WS-DELTA TO APPROVAL
    ADD 4 TO MEDIA-FAVOR
    SUBTRACT 3 FROM UNION-HEAT
    MOVE "Polls tick up. Cable books your surrogates." TO NEWS-TEXT.

DO-MEDIA.
    IF TURNS-LEFT = 0
        EXIT PARAGRAPH
    END-IF
    SUBTRACT 1 FROM TURNS-LEFT
    ADD 1 TO MEDIA-COUNT
    COMPUTE WS-AMT = 10000000 + (LOC-MEDIA-AP(LOC-ID) * 500000)
    ADD WS-AMT TO WASTE-CUT
    COMPUTE WS-DELTA = 6 + LOC-MEDIA-AP(LOC-ID)
    PERFORM ROLL-100
    EVALUATE TRUE
        WHEN WS-ROLL < 18
            *> Blowback
            COMPUTE WS-DELTA = 0 - WS-DELTA
            SUBTRACT 8 FROM MEDIA-FAVOR
            MOVE "Leak boomerangs: you look reckless on primetime."
                TO RESULT-TEXT
            MOVE "Op-eds eviscerate the 'chainsaw cosplay'." TO NEWS-TEXT
        WHEN WS-ROLL > 85
            ADD 5 TO WS-DELTA
            ADD 10 TO MEDIA-FAVOR
            ADD 15000000 TO WASTE-CUT
            MOVE "Explosive dossier drops. Network feeds for days."
                TO RESULT-TEXT
            MOVE "FOIA dump trends worldwide. Donors sweat." TO NEWS-TEXT
        WHEN OTHER
            ADD 6 TO MEDIA-FAVOR
            MOVE "Strategic leak exposes waste. Narrative shifts."
                TO RESULT-TEXT
            MOVE "Sunday shows debate your charts, not your hair."
                TO NEWS-TEXT
    END-EVALUATE
    ADD WS-DELTA TO APPROVAL.

DO-RELOCATE.
    *> Free action: no turn cost -- strategic reposition
    ADD 1 TO LOC-ID
    IF LOC-ID > 4
        MOVE 1 TO LOC-ID
    END-IF
    PERFORM APPLY-LOCATION
    MOVE "N" TO TARGET-INVESTIGATED
    PERFORM PICK-TARGET
    MOVE SPACES TO RESULT-TEXT
    STRING "Motorcade rolls to "
        DELIMITED BY SIZE
        FUNCTION TRIM(LOCATION-NAME)
        DELIMITED BY SIZE
        ". New battlefield, new pork."
        DELIMITED BY SIZE
        INTO RESULT-TEXT
    END-STRING
    MOVE DOSSIER-LINE TO NEWS-TEXT.

*> ============================================================
*> World systems
*> ============================================================
APPLY-LOCATION.
    MOVE LOC-NAME(LOC-ID) TO LOCATION-NAME
    MOVE LOC-DOSSIER(LOC-ID) TO DOSSIER-LINE.

PICK-TARGET.
    *> Prefer events matching location; fall back to random
    MOVE "N" TO WS-FOUND
    PERFORM ROLL-100
    COMPUTE TARGET-IDX = FUNCTION MOD(WS-ROLL + LOC-ID * 3, EVT-COUNT)
        + 1
    PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EVT-COUNT
        COMPUTE WS-J = FUNCTION MOD(TARGET-IDX + WS-I - 2, EVT-COUNT)
            + 1
        IF EVT-PREF-LOC(WS-J) = 0 OR EVT-PREF-LOC(WS-J) = LOC-ID
            MOVE WS-J TO TARGET-IDX
            MOVE "Y" TO WS-FOUND
            MOVE EVT-COUNT TO WS-I
        END-IF
    END-PERFORM
    IF WS-FOUND = "N"
        PERFORM ROLL-100
        COMPUTE TARGET-IDX = FUNCTION MOD(WS-ROLL, EVT-COUNT) + 1
    END-IF
    MOVE EVT-TITLE(TARGET-IDX) TO TARGET-TITLE
    COMPUTE TARGET-BASE = EVT-BASE-M(TARGET-IDX) * 1000000
    *> Term 2 crisis economy: slightly fatter targets
    IF TERM-NUM >= 2
        COMPUTE TARGET-BASE = TARGET-BASE * 115 / 100
    END-IF
    MOVE "N" TO TARGET-INVESTIGATED.

MAYBE-SCANDAL.
    *> Probabilistic scandal; likelier late game / high heat / term 2
    PERFORM ROLL-100
    COMPUTE WS-TMP = 12 + (UNION-HEAT / 10) + (GREEN-HEAT / 12)
    IF TERM-NUM >= 2
        ADD 8 TO WS-TMP
    END-IF
    IF TURNS-LEFT <= 4
        ADD 5 TO WS-TMP
    END-IF
    IF WS-ROLL < WS-TMP
        COMPUTE WS-DELTA = 8 + LOC-SCAND-X(LOC-ID)
        PERFORM ROLL-100
        IF WS-ROLL < 30
            ADD 5 TO WS-DELTA
            MOVE "Breaking: ethics probe opened. Approval cratering."
                TO NEWS-TEXT
        ELSE
            MOVE "Breaking: minor scandal cycles the feeds. Ouch."
                TO NEWS-TEXT
        END-IF
        SUBTRACT WS-DELTA FROM APPROVAL
        *> Do not overwrite RESULT-TEXT -- dual channel
    END-IF.

MAYBE-CRISIS.
    *> Mid-run campaign arc: once when turns drop to 6
    IF CRISIS-DONE = "Y"
        EXIT PARAGRAPH
    END-IF
    IF TURNS-LEFT > 6
        EXIT PARAGRAPH
    END-IF
    MOVE "Y" TO CRISIS-DONE
    MOVE 2 TO TERM-NUM
    PERFORM ROLL-100
    EVALUATE TRUE
        WHEN WS-ROLL < 34
            SUBTRACT 12 FROM APPROVAL
            ADD 15 TO UNION-HEAT
            MOVE "CRISIS: shutdown theater begins on the Hill."
                TO NEWS-TEXT
            MOVE "Term 2 pressure: every cut is a televised fight."
                TO RESULT-TEXT
        WHEN WS-ROLL < 67
            SUBTRACT 8 FROM APPROVAL
            ADD 12 TO MEDIA-FAVOR
            MOVE "CRISIS: viral documentary paints you as villain."
                TO NEWS-TEXT
            MOVE "Term 2: media knife-fight. Spin or be spun."
                TO RESULT-TEXT
        WHEN OTHER
            ADD 80000000 TO TARGET-BASE
            ADD 10 TO DONOR-HEAT
            MOVE "CRISIS: emergency supplemental packed with pork."
                TO NEWS-TEXT
            MOVE "Term 2: a fatter target just waddled into view."
                TO RESULT-TEXT
    END-EVALUATE
    MOVE "Crisis Actor" TO REPUTATION.

MAYBE-ADVISOR.
    IF ADVISOR-READY = "Y"
        MOVE "N" TO ADVISOR-READY
        EXIT PARAGRAPH
    END-IF
    *> Roughly every 3-4 turns, and not on resign path
    IF FUNCTION MOD(TURNS-LEFT, 4) NOT = 1
        EXIT PARAGRAPH
    END-IF
    IF TURNS-LEFT = 0
        EXIT PARAGRAPH
    END-IF
    PERFORM RUN-ADVISOR
    MOVE "Y" TO ADVISOR-READY.

RUN-ADVISOR.
    PERFORM ROLL-100
    EVALUATE TRUE
        WHEN WS-ROLL < 40
            MOVE "Pollster: soft-pedal cuts for a week, bank goodwill."
                TO RESULT-TEXT
            MOVE "Smile for cameras; delay the chainsaw." TO MENU-1
            MOVE "Ignore pollster; double down on the mission." TO MENU-2
            MOVE 0 TO ADVISOR-CHOICE
            DISPLAY ADVISOR-SCREEN
            ACCEPT ADVISOR-SCREEN
            IF ADVISOR-CHOICE = 1
                ADD 8 TO APPROVAL
                ADD 5 TO MEDIA-FAVOR
                MOVE "You charm the room. Approval cushion built."
                    TO RESULT-TEXT
            ELSE
                SUBTRACT 4 FROM APPROVAL
                ADD 25000000 TO WASTE-CUT
                MOVE "You snub the pollster. A few more millions fall."
                    TO RESULT-TEXT
            END-IF
        WHEN WS-ROLL < 75
            MOVE "Counsel: leak now or wait for a cleaner audit trail?"
                TO RESULT-TEXT
            MOVE "Leak immediately -- seize the narrative." TO MENU-1
            MOVE "Wait; finish the investigation first." TO MENU-2
            MOVE 0 TO ADVISOR-CHOICE
            DISPLAY ADVISOR-SCREEN
            ACCEPT ADVISOR-SCREEN
            IF ADVISOR-CHOICE = 1
                ADD 6 TO MEDIA-FAVOR
                PERFORM ROLL-100
                IF WS-ROLL < 40
                    SUBTRACT 10 FROM APPROVAL
                    MOVE "Rushed leak backfires. Anchors smell blood."
                        TO RESULT-TEXT
                ELSE
                    ADD 5 TO APPROVAL
                    ADD 20000000 TO WASTE-CUT
                    MOVE "Premature leak still lands. Narrative owned."
                        TO RESULT-TEXT
                END-IF
            ELSE
                ADD 4 TO APPROVAL
                MOVE "Y" TO TARGET-INVESTIGATED
                MOVE "Patience: books open wider. Cut unlocked."
                    TO RESULT-TEXT
            END-IF
        WHEN OTHER
            MOVE "Operative: a rival NPC wants a deal on your turf."
                TO RESULT-TEXT
            *> STRING does not clear the target -- wipe leftover menu text
            MOVE SPACES TO MENU-1
            STRING "Cut a deal with "
                DELIMITED BY SIZE
                FUNCTION TRIM(NPC-NAME(LOC-ID))
                DELIMITED BY SIZE
                "."
                DELIMITED BY SIZE
                INTO MENU-1
            END-STRING
            MOVE "Refuse. No deals with the swamp." TO MENU-2
            MOVE 0 TO ADVISOR-CHOICE
            DISPLAY ADVISOR-SCREEN
            ACCEPT ADVISOR-SCREEN
            IF ADVISOR-CHOICE = 1
                ADD 10 TO APPROVAL
                SUBTRACT 8 FROM UNION-HEAT
                SUBTRACT 8 FROM GREEN-HEAT
                COMPUTE WS-AMT = TARGET-BASE * 20 / 100
                ADD WS-AMT TO WASTE-CUT
                MOVE "Horse-trade done. Partial cut, cooler factions."
                    TO RESULT-TEXT
            ELSE
                SUBTRACT 5 FROM APPROVAL
                ADD 6 TO DONOR-HEAT
                MOVE "You refuse the deal. Respect + enemies rise."
                    TO RESULT-TEXT
            END-IF
    END-EVALUATE
    MOVE "Hallway whispers become tomorrow's headline." TO NEWS-TEXT.

MAYBE-NPC-NEWS.
    *> If player has been cutting a dept hard, NPC reappears
    IF LAST-NPC = SPACES
        EXIT PARAGRAPH
    END-IF
    IF CUT-LOC(LOC-ID) < 2
        EXIT PARAGRAPH
    END-IF
    PERFORM ROLL-100
    IF WS-ROLL < 35
        MOVE SPACES TO NEWS-TEXT
        STRING FUNCTION TRIM(LAST-NPC)
            DELIMITED BY SIZE
            " returns fire: op-ed + donors + FOIA barrage."
            DELIMITED BY SIZE
            INTO NEWS-TEXT
        END-STRING
        SUBTRACT 3 FROM APPROVAL
    END-IF.

UPDATE-REPUTATION.
    EVALUATE TRUE
        WHEN BOLD-COUNT >= 5 AND WASTE-CUT >= 800000000
            MOVE "Chainsaw Czar" TO REPUTATION
        WHEN INV-COUNT >= 5 AND APPROVAL >= 70
            MOVE "Audit Nerd Supreme" TO REPUTATION
        WHEN MEDIA-COUNT >= 4 AND MEDIA-FAVOR >= 70
            MOVE "Narrative Warlord" TO REPUTATION
        WHEN RALLY-COUNT >= 4 AND APPROVAL >= 75
            MOVE "People's Accountant" TO REPUTATION
        WHEN WASTE-CUT >= 500000000 AND APPROVAL >= 60
            MOVE "Steady Scalpel" TO REPUTATION
        WHEN APPROVAL < 35
            MOVE "Public Enemy Lite" TO REPUTATION
        WHEN BOLD-COUNT >= 3
            MOVE "Budget Hawk" TO REPUTATION
        WHEN INV-COUNT >= 3
            MOVE "Forensic Bureaucrat" TO REPUTATION
        WHEN OTHER
            MOVE "Fresh Appointee" TO REPUTATION
    END-EVALUATE
    IF CRISIS-DONE = "Y" AND REPUTATION = "Fresh Appointee"
        MOVE "Second-Term Survivor" TO REPUTATION
    END-IF.

*> ============================================================
*> HUD / menus / clamp / rng
*> ============================================================
REFRESH-HUD.
    *> Approval band
    EVALUATE TRUE
        WHEN APPROVAL >= 60
            MOVE "HIGH  " TO APPR-BAND
        WHEN APPROVAL >= 35
            MOVE "WATCH " TO APPR-BAND
        WHEN OTHER
            MOVE "DANGER" TO APPR-BAND
    END-EVALUATE
    *> Progress bar toward $1B (20 chars)
    MOVE ALL "." TO PROG-BAR
    COMPUTE PROG-FILL = WASTE-CUT / 50000000
    IF PROG-FILL > 20
        MOVE 20 TO PROG-FILL
    END-IF
    PERFORM VARYING PROG-I FROM 1 BY 1 UNTIL PROG-I > PROG-FILL
        MOVE "#" TO PROG-BAR(PROG-I:1)
    END-PERFORM
    IF TARGET-INVESTIGATED = "Y"
        MOVE "ARMED       " TO INV-HINT
    ELSE
        MOVE "locked      " TO INV-HINT
    END-IF.

BUILD-MENUS.
    IF TARGET-INVESTIGATED = "Y"
        MOVE "1. Investigate target   (already armed; small +$)"
            TO MENU-1
        MOVE "2. Propose BOLD cuts    (ARMED: big $ , less risk)"
            TO MENU-2
    ELSE
        MOVE "1. Investigate target   (+$, +AP, unlock bold)"
            TO MENU-1
        MOVE "2. Propose BOLD cuts    (blind: risky, smaller $)"
            TO MENU-2
    END-IF
    MOVE "3. Rally public support (+AP, modest $)" TO MENU-3
    MOVE "4. Media campaign/leak  (+AP or blowback)" TO MENU-4
    MOVE "5. Relocate department  (FREE; new dossier/target)"
        TO MENU-5
    MOVE "6. Resign mission" TO MENU-6.

CLAMP-ALL.
    PERFORM CLAMP-APPROVAL
    IF MEDIA-FAVOR > 100 MOVE 100 TO MEDIA-FAVOR END-IF
    IF MEDIA-FAVOR < 0 MOVE 0 TO MEDIA-FAVOR END-IF
    IF UNION-HEAT > 100 MOVE 100 TO UNION-HEAT END-IF
    IF UNION-HEAT < 0 MOVE 0 TO UNION-HEAT END-IF
    IF DONOR-HEAT > 100 MOVE 100 TO DONOR-HEAT END-IF
    IF DONOR-HEAT < 0 MOVE 0 TO DONOR-HEAT END-IF
    IF GREEN-HEAT > 100 MOVE 100 TO GREEN-HEAT END-IF
    IF GREEN-HEAT < 0 MOVE 0 TO GREEN-HEAT END-IF.

CLAMP-APPROVAL.
    IF APPROVAL > 100 MOVE 100 TO APPROVAL END-IF
    IF APPROVAL < 0 MOVE 0 TO APPROVAL END-IF.

ROLL-100.
    *> GnuCOBOL RANDOM returns 0..1; scale to 0..99
    COMPUTE WS-ROLL = FUNCTION INTEGER(FUNCTION RANDOM * 100).

*> ============================================================
*> Endings + persistence
*> ============================================================
RESOLVE-ENDING.
    PERFORM UPDATE-REPUTATION
    PERFORM REFRESH-HUD
    IF GAME-OVER-KIND = "M"
        MOVE "M" TO GAME-OVER-KIND
        EXIT PARAGRAPH
    END-IF
    IF GAME-OVER-KIND = "R"
        EXIT PARAGRAPH
    END-IF
    *> Turn-limit endings
    EVALUATE TRUE
        WHEN WASTE-CUT >= 1000000000 AND APPROVAL >= 70
             AND INV-COUNT >= BOLD-COUNT
            MOVE "T" TO GAME-OVER-KIND
        WHEN WASTE-CUT >= 1500000000 AND APPROVAL >= 30
             AND APPROVAL < 50
            MOVE "C" TO GAME-OVER-KIND
        WHEN WASTE-CUT >= 1000000000 AND APPROVAL >= 50
            MOVE "V" TO GAME-OVER-KIND
        WHEN WASTE-CUT >= 1000000000 AND APPROVAL >= 40
            MOVE "Q" TO GAME-OVER-KIND
        WHEN WASTE-CUT >= 400000000
            MOVE "S" TO GAME-OVER-KIND
        WHEN OTHER
            MOVE "I" TO GAME-OVER-KIND
    END-EVALUATE.

SHOW-END-SCREEN.
    EVALUATE GAME-OVER-KIND
        WHEN "M"
            MOVE "GAME OVER -- APPROVAL HIT ZERO" TO END-TITLE
            MOVE "ANGRY MOB RIOTS! TESLAS BURN IN THE STREETS!"
                TO END-LINE-1
            MOVE "Cable crowns a new supreme leader of the feed."
                TO END-LINE-2
            MOVE "The waste survives. Your briefing binder does not."
                TO END-LINE-3
        WHEN "R"
            MOVE "RESIGNED -- MISSION ABANDONED" TO END-TITLE
            MOVE "You hand in the badge. The swamp exhales."
                TO END-LINE-1
            MOVE "Staffers recycle your slides into a new task force."
                TO END-LINE-2
            MOVE "History footnotes you as 'almost interesting'."
                TO END-LINE-3
        WHEN "V"
            MOVE "VICTORY -- HERO OF THE PEOPLE" TO END-TITLE
            MOVE "You cleared the $1B bar with a real mandate."
                TO END-LINE-1
            MOVE "Parades optional. Spreadsheets mandatory."
                TO END-LINE-2
            MOVE "Bureaucracy will remember your name (bitterly)."
                TO END-LINE-3
        WHEN "T"
            MOVE "VICTORY -- QUIET TECHNOCRAT" TO END-TITLE
            MOVE "Audits first, chainsaw second. Precision won."
                TO END-LINE-1
            MOVE "High approval, high rigor, low fireworks."
                TO END-LINE-2
            MOVE "Historians call you boring. Accountants call you god."
                TO END-LINE-3
        WHEN "C"
            MOVE "ENDING -- CHAINSAW LEGACY" TO END-TITLE
            MOVE "Record cuts. Bruised polls. Mythic reputation."
                TO END-LINE-1
            MOVE "You are a cautionary tale AND a folk hero."
                TO END-LINE-2
            MOVE "Documentaries will mispronounce your name forever."
                TO END-LINE-3
        WHEN "Q"
            MOVE "NARROW WIN -- MANDATE FRAGILE" TO END-TITLE
            MOVE "You hit the dollar goal on thin political ice."
                TO END-LINE-1
            MOVE "One more scandal and the story flips."
                TO END-LINE-2
            MOVE "Still: the ledger looks cleaner tonight."
                TO END-LINE-3
        WHEN "S"
            MOVE "SOLID EFFORT -- PARTIAL REFORM" TO END-TITLE
            MOVE "Significant waste cut, but short of legend."
                TO END-LINE-1
            MOVE "Opponents call it chaos. Allies call it a start."
                TO END-LINE-2
            MOVE "Reappointments are... under discussion."
                TO END-LINE-3
        WHEN OTHER
            MOVE "MISSION INCOMPLETE" TO END-TITLE
            MOVE "Waste lingers in the crawlspaces of power."
                TO END-LINE-1
            MOVE "Approval never became a coalition."
                TO END-LINE-2
            MOVE "Try again: investigate, relocate, then strike."
                TO END-LINE-3
    END-EVALUATE
    DISPLAY END-SCREEN
    ACCEPT OMITTED.

SAVE-HIGH-SCORE.
    MOVE WASTE-CUT TO SCORE-WASTE-EDIT
    MOVE SPACES TO SCORE-LINE
    STRING
        FUNCTION TRIM(PLAYER-NAME) DELIMITED BY SIZE
        "|" DELIMITED BY SIZE
        REPUTATION DELIMITED BY SIZE
        "|" DELIMITED BY SIZE
        SCORE-WASTE-EDIT DELIMITED BY SIZE
        "|" DELIMITED BY SIZE
        APPROVAL DELIMITED BY SIZE
        "|" DELIMITED BY SIZE
        GAME-OVER-KIND DELIMITED BY SIZE
        INTO SCORE-LINE
    END-STRING
    OPEN EXTEND SCORE-FILE
    IF SCORE-STATUS NOT = "00"
        OPEN OUTPUT SCORE-FILE
    END-IF
    IF SCORE-STATUS = "00"
        WRITE SCORE-REC FROM SCORE-LINE
        CLOSE SCORE-FILE
    END-IF.

END PROGRAM WasteCutter.
