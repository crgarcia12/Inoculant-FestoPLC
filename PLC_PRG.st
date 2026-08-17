PROGRAM PLC_PRG
VAR
    // ============================================================
    //  CONFIGURATION - edit only this section
    //  Set how long (seconds) each valve stays open.
    //  Set a valve's time to T#0S to SKIP that valve (it will not open).
    // ============================================================
    tValve1_Time     : TIME := T#3S;
    tValve2_Time     : TIME := T#5S;
    tValve3_Time     : TIME := T#0S;
    tValve4_Time     : TIME := T#2S;
    tValve5_Time     : TIME := T#0S;
    tValve6_Time     : TIME := T#0S;
    tValve7_Time     : TIME := T#0S;
    tValve8_Time     : TIME := T#0S;
    // ============================ END ============================

    // Direct hardware mapping: byValves IS the physical output byte
    // (CPX-E-8DO), same as in the original working code.
    byValves AT %QB0 : BYTE;

    fbTimer : TON;

    // Internal variables - no need to edit these
    aValveTime     : ARRAY[1..8] OF TIME;
    byCurrentValve : BYTE := 0;   // currently active valve (1..8), 0 = none
    byNextValve    : BYTE;
    i              : BYTE;
END_VAR

// ================================================================
// BODY
// ================================================================

// Copy configuration into the working array (every cycle)
aValveTime[1] := tValve1_Time;
aValveTime[2] := tValve2_Time;
aValveTime[3] := tValve3_Time;
aValveTime[4] := tValve4_Time;
aValveTime[5] := tValve5_Time;
aValveTime[6] := tValve6_Time;
aValveTime[7] := tValve7_Time;
aValveTime[8] := tValve8_Time;

// If there is no active valve yet, find the first one with a time > 0
IF byCurrentValve = 0 THEN
    FOR i := 1 TO 8 DO
        IF aValveTime[i] > T#0S THEN
            byCurrentValve := i;
            EXIT;
        END_IF;
    END_FOR;
END_IF;

IF byCurrentValve = 0 THEN
    // No valve has a time configured: keep everything off
    byValves := BYTE#0;
    fbTimer(IN := FALSE, PT := T#1S);
ELSE
    byValves := SHL(BYTE#1, byCurrentValve - 1);

    fbTimer(IN := NOT fbTimer.Q, PT := aValveTime[byCurrentValve]);

    IF fbTimer.Q THEN
        // Find the next valve with a time > 0 (cyclic)
        byNextValve := byCurrentValve;
        FOR i := 1 TO 8 DO
            byNextValve := byNextValve + 1;
            IF byNextValve > 8 THEN
                byNextValve := 1;
            END_IF;
            IF aValveTime[byNextValve] > T#0S THEN
                EXIT;
            END_IF;
        END_FOR;
        byCurrentValve := byNextValve;
    END_IF;
END_IF;
