local description = "Copter Commands"
--[[
  1 label,
  2 CMD_ID
  2 options names,  
  3 params array, {0,0,0,0,0,0,0} up to 7 parameters
--]]--[[
  enum control_mode_t {
      STABILIZE =     0,  // manual airframe angle with manual throttle
      ACRO =          1,  // manual body-frame angular rate with manual throttle
      ALT_HOLD =      2,  // manual airframe angle with automatic throttle
      AUTO =          3,  // fully automatic waypoint control using mission commands
      GUIDED =        4,  // fully automatic fly to coordinate or fly at velocity/direction using GCS immediate commands
      LOITER =        5,  // automatic horizontal acceleration with automatic throttle
      RTL =           6,  // automatic return to launching point
      CIRCLE =        7,  // automatic circular flight with automatic throttle
      LAND =          9,  // automatic landing with horizontal position control
      DRIFT =        11,  // semi-automous position, yaw and throttle control
      SPORT =        13,  // manual earth-frame angular rate control with manual throttle
      FLIP =         14,  // automatically flip the vehicle on the roll axis
      AUTOTUNE =     15,  // automatically tune the vehicle's roll and pitch gains
      POSHOLD =      16,  // automatic position hold with manual override, with automatic throttle
      BRAKE =        17,  // full-brake using inertial/GPS system, no pilot input
      THROW =        18,  // throw to launch mode using inertial/GPS system, no pilot input
      AVOID_ADSB =   19,  // automatic avoidance of obstacles in the macro scale - e.g. full-sized aircraft
      GUIDED_NOGPS = 20,  // guided mode but only accepts attitude and altitude
      SMART_RTL =    21,  // SMART_RTL returns to home by retracing its steps
      FLOWHOLD  =    22,  // FLOWHOLD holds position with optical flow without rangefinder
      FOLLOW    =    23,  // follow attempts to follow another vehicle or ground station
      ZIGZAG    =    24,  // ZIGZAG mode is able to fly in a zigzag manner with predefined point A and point B
      SYSTEMID  =    25,  // System ID mode produces automated system identification signals in the controllers
      AUTOROTATE =   26,  // Autonomous autorotation
  };
--]]local commands = {
  {"MODE"  , 
    { "STABILIZE","ACRO", "ALT_HOLD","AUTO","GUIDED", "LOITER","RTL","CIRCLE","LAND","DRIFT","SPORT","FLIP","AUTOTUNE","POSHOLD","BRAKE","THROW","AVOID_ADSB","GUIDED_NOGPS","SMART_RTL","FLOWHOLD","FOLLOW","ZIGZAG","SYSTEMID", "AUTOROTATE"}, 
    { {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {9}, {11}, {13}, {14}, {15}, {16}, {17}, {18}, {19}, {20}, {21}, {22}, {23}, {24}, {25}, {26}, }, 
    cmd_id=176, 
    value=1
  },
}

return {
  list=commands,
  description=description,
  listType=3 -- commands
}
