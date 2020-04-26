local description = "Rover Commands"
--[[
  1 label,
  2 CMD_ID
  2 options names,  
  3 params array, {0,0,0,0,0,0,0} up to 7 parameters
--]]--[[
  // Auto Pilot modes
  // ----------------
  enum Number {
      MANUAL       = 0,
      ACRO         = 1,
      STEERING     = 3,
      HOLD         = 4,
      LOITER       = 5,
      FOLLOW       = 6,
      SIMPLE       = 7,
      AUTO         = 10,
      RTL          = 11,
      SMART_RTL    = 12,
      GUIDED       = 15,
      INITIALISING = 16
  };
--]]local commands = {
  {"MODE"  ,
    { "MANUAL","ACRO", "STEERING","HOLD","LOITER", "FOLLOW","SIMPLE","AUTO","RTL","SMART_RTL","GUIDED","INITIALISING",}, 
    { {0}, {1}, {3}, {4}, {5}, {6}, {7}, {10}, {11}, {12}, {15}, {16}, }, 
    cmd_id=176, 
    value=1
  },
}

return {
  list=commands,
  description=description,
  listType=3 -- commands
}
