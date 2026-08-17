PROGRAM PRG_ValveSequencer
VAR_OUTPUT
    byValves : BYTE;
END_VAR

VAR
    fbTimer : TON;

    // ============================================================
    //  CONFIGURACION - edite solo esta seccion
    //  Ponga TRUE en las valvulas que quiera usar en la secuencia
    //  y ajuste el tiempo (segundos) que cada una permanece abierta.
    // ============================================================
    xValve1_Enabled : BOOL := TRUE;
    xValve2_Enabled : BOOL := TRUE;
    xValve3_Enabled : BOOL := FALSE;
    xValve4_Enabled : BOOL := TRUE;
    xValve5_Enabled : BOOL := FALSE;
    xValve6_Enabled : BOOL := FALSE;
    xValve7_Enabled : BOOL := FALSE;
    xValve8_Enabled : BOOL := FALSE;

    tValve1_Time     : TIME := T#3S;
    tValve2_Time     : TIME := T#5S;
    tValve3_Time     : TIME := T#5S;
    tValve4_Time     : TIME := T#2S;
    tValve5_Time     : TIME := T#5S;
    tValve6_Time     : TIME := T#5S;
    tValve7_Time     : TIME := T#5S;
    tValve8_Time     : TIME := T#5S;
    // ============================ FIN ============================

    // Variables internas - no es necesario editarlas
    aValveEnabled  : ARRAY[1..8] OF BOOL;
    aValveTime     : ARRAY[1..8] OF TIME;
    byCurrentValve : BYTE := 0;   // valvula activa actual (1..8), 0 = ninguna
    byNextValve    : BYTE;
    i              : BYTE;
END_VAR

// ================================================================
// BODY
// ================================================================

// Copiar configuracion a los arrays de trabajo (siempre al inicio del ciclo)
aValveEnabled[1] := xValve1_Enabled;  aValveTime[1] := tValve1_Time;
aValveEnabled[2] := xValve2_Enabled;  aValveTime[2] := tValve2_Time;
aValveEnabled[3] := xValve3_Enabled;  aValveTime[3] := tValve3_Time;
aValveEnabled[4] := xValve4_Enabled;  aValveTime[4] := tValve4_Time;
aValveEnabled[5] := xValve5_Enabled;  aValveTime[5] := tValve5_Time;
aValveEnabled[6] := xValve6_Enabled;  aValveTime[6] := tValve6_Time;
aValveEnabled[7] := xValve7_Enabled;  aValveTime[7] := tValve7_Time;
aValveEnabled[8] := xValve8_Enabled;  aValveTime[8] := tValve8_Time;

// Si aun no hay valvula activa, buscar la primera habilitada
IF byCurrentValve = 0 THEN
    FOR i := 1 TO 8 DO
        IF aValveEnabled[i] THEN
            byCurrentValve := i;
            EXIT;
        END_IF;
    END_FOR;
END_IF;

IF byCurrentValve = 0 THEN
    // Ninguna valvula habilitada: no activar nada
    byValves := BYTE#0;
    fbTimer(IN := FALSE, PT := T#1S);
ELSE
    byValves := SHL(BYTE#1, byCurrentValve - 1);

    fbTimer(IN := NOT fbTimer.Q, PT := aValveTime[byCurrentValve]);

    IF fbTimer.Q THEN
        // Buscar la siguiente valvula habilitada (ciclico)
        byNextValve := byCurrentValve;
        FOR i := 1 TO 8 DO
            byNextValve := byNextValve + 1;
            IF byNextValve > 8 THEN
                byNextValve := 1;
            END_IF;
            IF aValveEnabled[byNextValve] THEN
                EXIT;
            END_IF;
        END_FOR;
        byCurrentValve := byNextValve;
    END_IF;
END_IF;
