local description = "Shared Params"
--[[
VALUE
{ 
  1 name,
  2 min,  
  3 max, 
  4 increment
  5 unit of measure, 
}

COMBO
{
  1 name, 
  2 label list, 
  3 value list, 
}
--]]
local parameters = {
  {"ARMING_RUDDER"  , {"No","Arm","Arm/Disarm"}, {0,1,2}, value=1 },
  
  {"ARSPD_USE"      , {"No","Yes","Thr=0"}, {0,1,2} },
  {"ARSPD_FBW_MIN"  , 5, 100, 1, "m/s", value = 2 },
  {"ARSPD_FBW_MAX"  , 5, 100, 1, "m/s" },
  
  --{"AUTOTUNE_LEVEL" , 1, 10, 1 },
  
  --{"FENCE_MINALT"   , 1, 32767, 1, "m" },
  --{"FENCE_MAXALT"   , 1, 32767, 1, "m" },
  
  --{"WP_RADIUS"      , 1, 32767, 1, "m" },
  --{"WP_LOITER_RAD"  , 1, 32767, 1, "m" },
}

return {list=parameters,description=description}