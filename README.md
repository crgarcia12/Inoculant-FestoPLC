# Inoculant-FestoPLC

CODESYS (Festo Automation Suite) program for a Festo **CPX-E-CEC-C1** controller with a
**CPX-E-8DO** digital output module attached, used to sequence up to 8 solenoid valves
(inoculant dosing application).

## How to upload (download) a new program
1. Open `Festo Automation Suite`. Select the PLC and click `Open PPlugin`

![Open Festo plugin](readme-media/1.OpenFesto.png)

2. Connect and Open Codesys

![Connect and Open Codesys](readme-media/2.ConnectCodesys.png)

3. Paste the code. There are two code sections, 1. The `Variable declaration` and 2. The `Body`. Make sure you paste each part in the right place

![Login to the device](readme-media/3.Code.png)


4. Login to the device. You will be prompted to enter a password. (tips Guemes Lea)

![Login to the device](readme-media/4.Login.png)

5. Start the program and Create a boot application.
Boot application will make sure the program starts automatically when the device is powered on.

![Login to the device](readme-media/5.StartAndBootApp.png)

You are done!

## What this does

`PLC_PRG.st` cycles through 4 configurable steps, skipping any disabled ones. Each step opens a selected group
of valves together for a configurable duration. A single output-byte assignment
switches directly to the next group, then the sequence loops back to the first
enabled step.

The default sequence runs each pump/valve pair together for **30 seconds**:
**1+8**, **2+7**, **3+6**, **4+5**, then repeats.

- Up to 8 valves are supported, mapped to the 8 bits of the `byValves : BYTE` output
  (bit 0 = valve 1, bit 1 = valve 2, ... bit 7 = valve 8), which is wired to the
  CPX-E-8DO digital outputs.
- Each step has a valve mask (`aStepValves[N]`) and duration (`aStepTime[N]`),
  initialized directly in the two arrays.
  In a binary mask, the bits from left to right represent valves **8 7 6 5 4 3 2 1**.
  For example, `2#10000001` selects valves 1+8, and `2#01000010` selects valves 2+7.
- A single set bit runs one valve; multiple set bits run valves in parallel.
  A valve may appear in more than one step.
- Setting a step's time to `T#0S` or its mask to `2#00000000` skips that step.
  If all steps are disabled, all valves remain closed.
- At each transition, the outgoing valves close and the incoming valves open in
  the same output update, with no intentional all-off gap. Valves shared by
  consecutive steps remain on.
- To add or remove steps, update `cStepCount` and the entries in both array
  initializers. The sequencing logic needs no changes.

## Files

- `PLC_PRG.st` — Structured Text (ST) source for the CODESYS program.
  The file contains two parts, separated by a `// BODY` marker:
  - Declaration part (top): variables, including the configuration section.
  - Body part (bottom): the sequencing logic.

## Status

Work in progress. Detailed setup/deployment instructions (how to import this into
Festo Automation Suite / CODESYS, wiring, and how to make it start automatically on
power-up) will be added later.
