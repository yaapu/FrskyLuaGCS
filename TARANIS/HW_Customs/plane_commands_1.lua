local description = "Plane Commands"
--[[
  1 label,
  2 CMD_ID
  2 options names,  
  3 params array, {0,0,0,0,0,0,0} up to 7 parameters
--]]--[[
enum FlightMode {
    MANUAL        = 0,
    CIRCLE        = 1,
    STABILIZE     = 2,
    TRAINING      = 3,
    ACRO          = 4,
    FLY_BY_WIRE_A = 5,
    FLY_BY_WIRE_B = 6,
    CRUISE        = 7,
    AUTOTUNE      = 8,
    AUTO          = 10,
    RTL           = 11
    LOITER        = 12,
    TAKEOFF       = 13,
    AVOID_ADSB    = 14,
    GUIDED        = 15,
    INITIALISING  = 16,
    QSTABILIZE    = 17,
    QHOVER        = 18,
    QLOITER       = 19,
    QLAND         = 20,
    QRTL          = 21,
    QAUTOTUNE	    = 22,
    QACRO         = 23
};
--]]local commands = {
  {"MODE"  ,
    { "MANUAL","CIRCLE", "STABILIZE","TRAINING","ACRO", "FBWA","FBWB","CRUISE","AUTOTUNE","AUTO","RTL","LOITER","TAKEOFF","AVOID_ADSB","GUIDED","INITIALIZING","QSTABILIZE","QHOVER","QLOITER","QLAND","QRTL","QAUTOTUNE","QACRO"}, 
    { {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {10}, {11}, {12}, {13}, {14}, {15}, {16}, {17}, {18}, {19}, {20}, {21}, {22}, {23}, }, 
    cmd_id=176, 
    value=1
  },
 {"CALIBRATE"  , {"Airspeed Sensor"}, { {0,0,1} }, cmd_id=241, value=1 },
  {"FENCE ENABLE"  , {"Disable","Enable","Floor Only"}, { {0}, {1}, {2} }, cmd_id=207, value=1 },
  {"REBOOT"  , {"Autopilot","Onboard Computer"}, { {1,0}, {0,1} }, cmd_id=246, value=1 },
}

return {
  list=commands,
  description=description,
  listType=3 -- commands
}
