       >>SOURCE FREE

IDENTIFICATION DIVISION.
PROGRAM-ID. WasteCutter.

DATA DIVISION.
WORKING-STORAGE SECTION.
01 PLAYER-NAME      PIC X(30).
01 WASTE-CUT       PIC 9(12) VALUE 0.
01 CHOICE          PIC 9 VALUE 0.
01 CONTINUE-FLAG   PIC X VALUE 'Y'.
01 APPROVAL        PIC S9(3) VALUE 65.
01 TURNS-LEFT      PIC 9(2) VALUE 12.
01 LOCATION        PIC X(15) VALUE "Oval Office".
01 EVENT-TEXT      PIC X(60) VALUE SPACES.

SCREEN SECTION.
01 MAIN-SCREEN.
   05 BLANK SCREEN BACKGROUND-COLOR 0 FOREGROUND-COLOR 7.
   05 LINE 1 COL 1 PIC X(80) VALUE ALL "=" FOREGROUND-COLOR 1.
   05 LINE 2 COL 20 VALUE "WASTE CUTTER" FOREGROUND-COLOR 14 HIGHLIGHT.
   05 LINE 2 COL 40 VALUE "- Cut Government Waste! -" FOREGROUND-COLOR 11.
   05 LINE 3 COL 1 PIC X(80) VALUE ALL "=" FOREGROUND-COLOR 1.

   05 LINE 5 COL 5 VALUE "Player:" FOREGROUND-COLOR 10.
   05 LINE 5 COL 15 PIC X(30) FROM PLAYER-NAME FOREGROUND-COLOR 15.
   05 LINE 5 COL 55 VALUE "Total Cut:" FOREGROUND-COLOR 10.
   05 LINE 5 COL 67 PIC ZZZ,ZZZ,ZZZ,ZZ9 FROM WASTE-CUT FOREGROUND-COLOR 14.

   05 LINE 6 COL 5 VALUE "Approval:" FOREGROUND-COLOR 10.
   05 LINE 6 COL 15 PIC Z99 FROM APPROVAL FOREGROUND-COLOR 14.
   05 LINE 6 COL 25 VALUE "Turns:" FOREGROUND-COLOR 10.
   05 LINE 6 COL 33 PIC 99 FROM TURNS-LEFT FOREGROUND-COLOR 14.
   05 LINE 6 COL 45 VALUE "Location:" FOREGROUND-COLOR 10.
   05 LINE 6 COL 56 PIC X(15) FROM LOCATION FOREGROUND-COLOR 15.

   05 LINE 8 COL 5 VALUE "Mission Briefing:" FOREGROUND-COLOR 11.
   05 LINE 9 COL 5 PIC X(70) FROM EVENT-TEXT FOREGROUND-COLOR 13.

   05 LINE 11 COL 5 VALUE "Available Actions:" FOREGROUND-COLOR 11.
   05 LINE 13 COL 10 VALUE "1. Investigate waste          (+$30M, +Approval)".
   05 LINE 14 COL 10 VALUE "2. Propose bold cuts         (+$200M, -Approval risk)".
   05 LINE 15 COL 10 VALUE "3. Rally public support      (+Approval, +$20M)".
   05 LINE 16 COL 10 VALUE "4. Media leak                (+Approval, small cut)".
   05 LINE 17 COL 10 VALUE "5. Relocate to new dept      (change flavor)".
   05 LINE 18 COL 10 VALUE "6. Quit mission".

   05 LINE 20 COL 5 VALUE "Enter choice (1-6): " FOREGROUND-COLOR 15.
   05 LINE 20 COL 26 PIC 9 TO CHOICE FOREGROUND-COLOR 14.

   05 LINE 24 COL 1 PIC X(80) VALUE ALL "=" FOREGROUND-COLOR 1.

01 GAME-OVER-SCREEN.
   05 BLANK SCREEN BACKGROUND-COLOR 0 FOREGROUND-COLOR 4.
   05 LINE 4 COL 15 VALUE "==========================================".
   05 LINE 6 COL 22 VALUE "GAME OVER - Your approval hit ZERO." HIGHLIGHT.
   05 LINE 8 COL 30 VALUE "ANGRY MOB RIOTS!" HIGHLIGHT.
   05 LINE 9 COL 32 VALUE "TESLAS BURN!" HIGHLIGHT.
   05 LINE 10 COL 25 VALUE "AOC CROWNED SUPREME LEADER!" HIGHLIGHT.
   05 LINE 12 COL 15 VALUE "==========================================".
   05 LINE 15 COL 25 VALUE "Press ENTER to exit...".

PROCEDURE DIVISION.
MAIN-LOGIC.
    DISPLAY "Enter your name, waste slayer: " WITH NO ADVANCING
    ACCEPT PLAYER-NAME
    MOVE "Welcome! Balance bold action with public support." TO EVENT-TEXT

    PERFORM GAME-LOOP UNTIL CONTINUE-FLAG = 'N' OR TURNS-LEFT = 0 OR APPROVAL <= 0

    IF APPROVAL <= 0
        DISPLAY GAME-OVER-SCREEN
        ACCEPT OMITTED
        STOP RUN
    END-IF

    IF WASTE-CUT >= 1000000000 AND APPROVAL >= 50
        DISPLAY "VICTORY! You slashed $" WASTE-CUT " with strong approval. Hero of the people!"
    ELSE IF WASTE-CUT >= 400000000
        DISPLAY "Solid effort. You cut significant waste but faced resistance."
    ELSE
        DISPLAY "Mission incomplete. Waste lingers and approval tanked."
    END-IF
    DISPLAY "Final: $" WASTE-CUT " cut | Approval: " APPROVAL
    STOP RUN.

GAME-LOOP.
    MOVE 0 TO CHOICE
    DISPLAY MAIN-SCREEN
    ACCEPT MAIN-SCREEN
    SUBTRACT 1 FROM TURNS-LEFT
    EVALUATE CHOICE
        WHEN 1
            ADD 30000000 TO WASTE-CUT
            ADD 5 TO APPROVAL
            MOVE "Investigation reveals waste. Smart move boosts credibility." TO EVENT-TEXT
        WHEN 2
            ADD 200000000 TO WASTE-CUT
            SUBTRACT 15 FROM APPROVAL
            MOVE "Bold cuts hit hard! Public angry but waste plummets." TO EVENT-TEXT
        WHEN 3
            ADD 20000000 TO WASTE-CUT
            ADD 10 TO APPROVAL
            MOVE "Rallies succeed. Support surges, small wins add up." TO EVENT-TEXT
        WHEN 4
            ADD 50000000 TO WASTE-CUT
            ADD 8 TO APPROVAL
            MOVE "Media exposes waste. Approval rises, cuts made." TO EVENT-TEXT
        WHEN 5
            EVALUATE LOCATION
                WHEN "Oval Office" MOVE "Pentagon" TO LOCATION
                WHEN "Pentagon" MOVE "Congress" TO LOCATION
                WHEN "Congress" MOVE "EPA" TO LOCATION
                WHEN "EPA" MOVE "Oval Office" TO LOCATION
            END-EVALUATE
            MOVE "Relocated. New challenges ahead." TO EVENT-TEXT
        WHEN 6
            MOVE 'N' TO CONTINUE-FLAG
        WHEN OTHER
            MOVE "Invalid. Focus!" TO EVENT-TEXT
    END-EVALUATE
    IF APPROVAL > 100 MOVE 100 TO APPROVAL END-IF
    IF APPROVAL < 0 MOVE 0 TO APPROVAL END-IF
    IF FUNCTION MOD(TURNS-LEFT, 4) = 0
        SUBTRACT 8 FROM APPROVAL
        MOVE "Breaking: Scandal rocks administration! Approval hit." TO EVENT-TEXT
    END-IF
    IF APPROVAL > 100 MOVE 100 TO APPROVAL END-IF
    IF APPROVAL < 0 MOVE 0 TO APPROVAL END-IF
    IF APPROVAL <= 0
        DISPLAY GAME-OVER-SCREEN
        ACCEPT OMITTED
        STOP RUN
    END-IF.
