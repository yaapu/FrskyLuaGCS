#include "includes/ardupilot_inc.lua"
#include "includes/colors_inc.lua"

#define MIN_X 0
#define MIN_Y 32

#define X_COLUMN_1 5
#define X_COLUMN_2 165
#define X_COLUMN_3 325
#define COLUMN_WIDTH 160

local description = "Rover/Boat Tuning"
local labelWidth = 83
local columnWidth = COLUMN_WIDTH
local boxes = {
  {label="Steer 2 Servo"        , x=MIN_X       ,y=MIN_Y        ,width=COLUMN_WIDTH,height=102, color=lcd.RGB(255,255,255)},
  {label="Speed 2 Throttle"     ,x=MIN_X+160    ,y=MIN_Y        ,width=COLUMN_WIDTH,height=102, color=lcd.RGB(255,255,255)},
  {label="Rover"                , x=MIN_X+320   ,y=MIN_Y        ,width=COLUMN_WIDTH,height=102, color=lcd.RGB(255,255,255)},
  
  {label="Steering Mode"        , x=MIN_X       ,y=MIN_Y+122    ,width=COLUMN_WIDTH,height=22, color=lcd.RGB(255,255,255)},
  {label="Throttle 0-100%"      , x=MIN_X+160   ,y=MIN_Y+122    ,width=COLUMN_WIDTH,height=90, color=lcd.RGB(255,255,255)},
}

--[[
VALUE
{ 
  1 name
  2 min  
  3 max 
  4 increment (float)
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
  -- row 1
  {"ATC_STR_RAT_P"        , 0.0, 2.0, 0.01      , x=X_COLUMN_1,y=MIN_Y+2,label="P"},
  {"ATC_STR_RAT_I"        , 0.0, 2.0, 0.01      , x=X_COLUMN_1,y=MIN_Y+18,label="I"},
  {"ATC_STR_RAT_D"        , 0.0, 0.4, 0.001     , x=X_COLUMN_1,y=MIN_Y+34,label="D"},
  {"ATC_STR_RAT_IMAX"     , 0, 4500, 1          , x=X_COLUMN_1,y=MIN_Y+50,label="IMAX"},
  {"ATC_STR_RAT_FF"       , 0, 3, 0.001         , x=X_COLUMN_1,y=MIN_Y+64,label="FF"},
  
  {"ATC_SPEED_P"          , 0.01, 2.0, 0.01     , x=X_COLUMN_2,y=MIN_Y+2,label="P"},
  {"ATC_SPEED_I"          , 0.0, 2.0, 0.01      , x=X_COLUMN_2,y=MIN_Y+18,label="I"},
  {"ATC_SPEED_D"          , 0.0, 4.0, 0.01      , x=X_COLUMN_2,y=MIN_Y+34,label="D"},
  {"ATC_SPEED_IMAX"       , 0, 1, 0.01          , x=X_COLUMN_2,y=MIN_Y+50,label="IMAX"},
  {"ATC_ACCEL_MAX"        , 0.0, 10.0, 0.1      , x=X_COLUMN_2,y=MIN_Y+64,label="Accel Max"},
  {"ATC_BRAKE"            , {"Disable","Enable"}, {0,1}, x=X_COLUMN_2,y=MIN_Y+80,label="Brake"},
  
  {"WP_RADIUS"            , 0.0, 100.0, 0.1     , x=X_COLUMN_3,y=MIN_Y+2,label="WPRad m"},
  {"WP_OVERSHOOT"         , 0.0, 10, 0.1        , x=X_COLUMN_3,y=MIN_Y+18,label="WP ov.sh m"},
  {"TURN_MAX_G"           , 0.1, 10, 0.01       , x=X_COLUMN_3,y=MIN_Y+34,label="Turn Dist"},
  {"NAVL1_PERIOD"         , 0, 60.0, 1          , x=X_COLUMN_3,y=MIN_Y+50,label="Nav Perio"},
  {"NAVL1_DAMPING"        , 0.6, 1, 0.05        , x=X_COLUMN_3,y=MIN_Y+64,label="Nav Damp"},
  
  --row 2
  {"TURN_RADIUS"          , 0, 10, 0.1          , x=X_COLUMN_1,y=MIN_Y+126,label="Turn Speed"},

  {"MOT_PWM_TYPE"         , {"Norm","OS","OS125","BrRelay","BrBip","DS150","DS300","DS600","DS1200"}, {0,1,2,3,4,5,6,7,8}, x=X_COLUMN_2,y=MIN_Y+126,label="Motor Type"},
  {"CRUISE_SPEED"         , 0, 100, 0.1         , x=X_COLUMN_2,y=MIN_Y+142,label="Cruise Spd"},
  {"CRUISE_THROTTLE"      , 0, 100, 1           , x=X_COLUMN_2,y=MIN_Y+158,label="Cruise Thr"},
  {"MOT_THR_MIN"          , 0, 20, 1            , x=X_COLUMN_2,y=MIN_Y+174,label="Thr Min"},
  {"MOT_THR_MAX"          , 30, 100, 1          , x=X_COLUMN_2,y=MIN_Y+190,label="Thr Max"},
}

return {
  list=parameters,
  description=description,
  boxes=boxes,
  labelWidth=labelWidth,
  columnWidth=columnWidth,
  listType=2 -- tuning panel
}