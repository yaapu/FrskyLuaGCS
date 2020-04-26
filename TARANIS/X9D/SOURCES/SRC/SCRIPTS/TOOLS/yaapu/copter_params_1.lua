local description = "Copter Params"
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
--]]local parameters = {
  --[[
    Controls which parameters (normally PID gains) are being tuned with transmitter's channel 6 knob
  --]]  {"TUNE",{"None","Stab Roll/Pitch kP","Rate Roll/Pitch kP","Rate Roll/Pitch kI","Rate Roll/Pitch kD","Stab Yaw kP","Rate Yaw kP","Rate Yaw kD","Rate Yaw Filter","Motor Yaw Headroom","AltHold kP","Throttle Rate kP","Throttle Accel kP","Throttle Accel kI","Throttle Accel kD","Loiter Pos kP","Velocity XY kP","Velocity XY kI","WP Speed","Acro RollPitch kP","Acro Yaw kP","RC Feel","Heli Ext Gyro","Declination","Circle Rate","RangeFinder Gain","Rate Pitch kP","Rate Pitch kI","Rate Pitch kD","Rate Roll kP","Rate Roll kI","Rate Roll kD","Rate Pitch FF","Rate Roll FF","Rate Yaw FF","Winch","SysID Magnitude",},{0,1,4,5,21,3,6,26,56,55,14,7,34,35,36,12,22,28,10,25,40,45,13,38,39,41,46,47,48,49,50,51,52,53,54,57,58,},},

  --[[
    Minimum value that the parameter currently being tuned with the transmitter's channel 6 knob will be set to
  --]]  {"TUNE_MIN",0,1000000,0.1,"",},
  
  --[[
    Maximum value that the parameter currently being tuned with the transmitter's channel 6 knob will be set to
  --]]  {"TUNE_MAX",0,1000000,0.1,"",},
}

return {list=parameters,description=description}
