local description = "Shared Commands"
--[[
  1 label,
  2 CMD_ID
  2 options names,  
  3 params array, {0,0,0,0,0,0,0} up to 7 parameters
--]]--[[
CALIBRATE 241
params
1: Gyro Temperature	1: gyro calibration, 3: gyro temperature calibration	min:0 max:3 increment:1
2: Magnetometer	1: magnetometer calibration	min:0 max:1 increment:1
3: Ground Pressure	1: ground pressure calibration	min:0 max:1 increment:1
4: Remote Control	1: radio RC calibration, 2: RC trim calibration	min:0 max:1 increment:1
5: Accelerometer	1: accelerometer calibration, 2: board level calibration, 3: accelerometer temperature calibration, 4: simple accelerometer calibration	min:0 max:4 increment:1
6: Compmot or Airspeed	1: APM: compass/motor interference calibration (PX4: airspeed calibration, deprecated), 2: airspeed calibration	min:0 max:2 increment:1
7: ESC or Baro	1: ESC calibration, 3: barometer temperature calibration	min:0 max:3 increment:1

REBOOT 246
params
1: Autopilot	0: Do nothing for autopilot, 1: Reboot autopilot, 2: Shutdown autopilot, 3: Reboot autopilot and keep it in the bootloader until upgraded.	min:0 max:3 increment:1
2: Companion	0: Do nothing for onboard computer, 1: Reboot onboard computer, 2: Shutdown onboard computer, 3: Reboot onboard computer and keep it in the bootloader until upgraded.
--]]local commands = {
  {"CALIBRATE"  , {"Ground Pressure","Accelerometer","Board Level"}, { {0,0,1}, {0,0,0,0,1}, {0,0,0,0,2} }, cmd_id=241, value=1 },
  {"FENCE ENABLE"  , {"Disable","Enable","Floor Only"}, { {0}, {1}, {2} }, cmd_id=207, value=1 },
  {"REBOOT"  , {"Autopilot","Onboard Computer"}, { {1,0}, {0,1} }, cmd_id=246, value=1 },
  {"MODE"  , {"CIRCLE", "ACRO", "FBWB", "TAKEOFF"}, { {1}, {4}, {6}, {13} }, cmd_id=176, value=1},
  --{"COMPASS"  , {"Start Cal"}, { {0,0,1,0,0} }, cmd_id=24, value=1 },
}

return {
  list=commands,
  description=description,
  listType=3 -- commands
}
