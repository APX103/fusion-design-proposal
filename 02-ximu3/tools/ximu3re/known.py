"""Symbols confirmed by this reverse-engineering pass (firmware v2.6.0).

Addresses are KSEG0 virtual (0x9D0xxxxx flash, 0x8007xxxx SRAM objects).
Re-locate them on any other firmware version — see README.
"""

from . import FLASH_BASE

KNOWN_SYMBOLS: dict[int, str] = {
    # --- AHRS engine (object at 0x8007CDC0) -------------------------------
    0x9D036AC8: "AhrsUpdate",                 # Madgwick update, full (with mag)
    0x9D0391D0: "AhrsUpdate_partial",         # variant selected by state check
    0x9D041038: "AhrsUpdate_alt",             # variant called on reset path
    0x9D07BFA4: "AhrsInitialiseWindow_Step",  # N-sample mean -> bias/attitude
    0x9D05C740: "AhrsEngine_Configure",       # rate/gain/thresholds assembly
    0x9D07CA98: "AhrsReset",                  # quaternion := (1,0,0,0), states
    0x9D088CB0: "AhrsClearRampFlags",
    0x9D086E88: "AhrsGetQuaternion",
    0x9D0545DC: "AhrsSettings_Apply",         # rebuild engine on config change
    0x9D04A270: "Settings_ApplyAll",          # per-setting reconfigure driver

    # --- 400 Hz sensor pipeline --------------------------------------------
    0x9D038848: "Pipeline_CalibrateAndEmit",  # ic = M*s*(iu-b), timestamps, msgs
    0x9D0384B0: "SpiSensor_StateMachine",     # inertial sensor register FSM

    # --- output stage --------------------------------------------------------
    0x9D048164: "Output_QuatToEulerMessage",  # atan2/asin, +-90 clamp, deg

    # --- library / runtime ---------------------------------------------------
    0x9D0613F8: "cosf",
    0x9D05D940: "atan2f",
    0x9D068AF0: "atanf_approx",
    0x9D087910: "Settings_GetPointer",
    0x9D086D70: "Scheduler_CriticalSection",
    0x9D087C90: "Time_Now64",
}

# RAM objects (not disassemblable, but load-bearing for cross references)
RAM_OBJECTS: dict[int, str] = {
    0x8007CDC0: "g_ahrs (quaternion@+0x38, init window acc@+0xa0, state@+0x90)",
    0x8007C448: "g_calibration (gyro M/s/b @+0x04..+0x38, accel, high-g, mag)",
    0x8007D950: "g_calibrated_samples (+8 gyro, +0x14 accel)",
    0x8007DB98: "g_mag_samples (+8 xyz)",
    0x8007D630: "g_output_manager (Euler/quat messages)",
    0x8007BFFC: "g_aux_output (linear/earth acceleration)",
}

# Float constant pools in flash with identified members
CONST_POOL_SEMANTICS: dict[int, str] = {
    0x9D085B54: "0.5            (AHRS half-factor / default beta)",
    0x9D085B58: "0.0174532925   deg->rad",
    0x9D085B5C: "1.0",
    0x9D085B60: "10.0           rejection threshold (deg)",
    0x9D085B64: "3.0",
    0x9D085B68: "6.28318548     2*pi (anchored heading)",
    0x9D085B6C: "0.980000019    rejection ramp factor",
    0x9D085B70: "2^31 (float compare trick)",
    0x9D085B78: "-1.0",
    0x9D085B7C: "0.00872664619  pi/360 = 0.5*deg2rad (quaternion rate)",
    0x9D085B80: "-90.0          Euler clamp",
    0x9D085B84: "90.0           Euler clamp",
    0x9D085B88: "57.2957764     rad->deg",
    0x9D0882D8: "1.0 / -90 / 90 / 0.5 / 57.2958 / -1  (Euler output pool)",
    0x9D088518: "atanf polynomial {-0.00866, -0.04274, 0.16667, -0.70663}",
    0x9D086EB0: "AHRSEngine static defaults {100, 0, 1, 0.5, 0, 0, 0, 10, 0.01, 5}",
}
