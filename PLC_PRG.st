PROGRAM PLC_PRG
VAR CONSTANT
    cStepCount : UINT := 4;
END_VAR
VAR
    // ============================================================
    //  CONFIGURATION - edit only this section
    //  Each step opens all selected valves together for its duration.
    //  Valve bits (left to right): 8 7 6 5 4 3 2 1.
    //  Example: 2#10000001 opens valves 1 and 8 together.
    //  Set a step's time or valve mask to 0 to SKIP that step.
    //  To add/remove steps, update cStepCount and both lists.
    // ============================================================
    aStepValves : ARRAY[1..cStepCount] OF BYTE := [
        2#10000001,
        2#01000010,
        2#00100100,
        2#00011000
    ];
    aStepTime : ARRAY[1..cStepCount] OF TIME := [
        T#30S,
        T#30S,
        T#30S,
        T#30S
    ];
    // ============================ END ============================

    // Direct hardware mapping: byValves IS the physical output byte
    // (CPX-E-8DO), same as in the original working code.
    byValves AT %QB0 : BYTE;

    fbTimer : TON;

    // Internal variables - no need to edit these
    uiCurrentStep : UINT := 0;   // currently active step, 0 = none
    uiNextStep    : UINT;
    i             : UINT;
END_VAR

// ================================================================
// BODY
// ================================================================

// If there is no active step yet, find the first enabled one.
IF uiCurrentStep = 0 THEN
    FOR i := 1 TO cStepCount DO
        IF (aStepTime[i] > T#0S) AND (aStepValves[i] <> BYTE#0) THEN
            uiCurrentStep := i;
            EXIT;
        END_IF;
    END_FOR;
END_IF;

IF uiCurrentStep = 0 THEN
    fbTimer(IN := FALSE, PT := T#1S);
ELSE
    fbTimer(IN := TRUE, PT := aStepTime[uiCurrentStep]);
    IF fbTimer.Q THEN
        fbTimer(IN := FALSE, PT := T#1S);
        uiNextStep := uiCurrentStep;
        uiCurrentStep := 0;
        FOR i := 1 TO cStepCount DO
            uiNextStep := uiNextStep + 1;
            IF uiNextStep > cStepCount THEN
                uiNextStep := 1;
            END_IF;
            IF (aStepTime[uiNextStep] > T#0S) AND (aStepValves[uiNextStep] <> BYTE#0) THEN
                uiCurrentStep := uiNextStep;
                EXIT;
            END_IF;
        END_FOR;
        IF uiCurrentStep <> 0 THEN
            fbTimer(IN := TRUE, PT := aStepTime[uiCurrentStep]);
        END_IF;
    END_IF;
END_IF;

// Commit the entire output byte once, closing/opening valves together.
IF uiCurrentStep = 0 THEN
    byValves := BYTE#0;
ELSE
    byValves := aStepValves[uiCurrentStep];
END_IF;
