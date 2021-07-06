--
-- Author: Alessandro Apostoli https://github.com/yaapu
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY, without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, see <http://www.gnu.org/licenses>.
--


local description = "ROVER TUNE"
local labelWidth = 83
local columnWidth = 160
local boxes = {
  {label="Steer 2 Servo"        , x=0       ,y=32        ,width=160,height=102, color=lcd.RGB(255,255,255)},
  {label="Speed 2 Throttle"     ,x=0+160    ,y=32        ,width=160,height=102, color=lcd.RGB(255,255,255)},
  {label="Rover"                , x=0+320   ,y=32        ,width=160,height=102, color=lcd.RGB(255,255,255)},
  
  {label="Steering Mode"        , x=0       ,y=32+122    ,width=160,height=22, color=lcd.RGB(255,255,255)},
  {label="Throttle 0-100%"      , x=0+160   ,y=32+122    ,width=160,height=90, color=lcd.RGB(255,255,255)},
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
  {"ATC_STR_RAT_P"        , 0.0, 2.0, 0.01      , x=5,y=32+2,label="P"},
  {"ATC_STR_RAT_I"        , 0.0, 2.0, 0.01      , x=5,y=32+18,label="I"},
  {"ATC_STR_RAT_D"        , 0.0, 0.4, 0.001     , x=5,y=32+34,label="D"},
  {"ATC_STR_RAT_IMAX"     , 0, 4500, 1          , x=5,y=32+50,label="IMAX"},
  {"ATC_STR_RAT_FF"       , 0, 3, 0.001         , x=5,y=32+64,label="FF"},
  
  {"ATC_SPEED_P"          , 0.01, 2.0, 0.01     , x=165,y=32+2,label="P"},
  {"ATC_SPEED_I"          , 0.0, 2.0, 0.01      , x=165,y=32+18,label="I"},
  {"ATC_SPEED_D"          , 0.0, 4.0, 0.01      , x=165,y=32+34,label="D"},
  {"ATC_SPEED_IMAX"       , 0, 1, 0.01          , x=165,y=32+50,label="IMAX"},
  {"ATC_ACCEL_MAX"        , 0.0, 10.0, 0.1      , x=165,y=32+64,label="Accel Max"},
  {"ATC_BRAKE"            , {"Disable","Enable"}, {0,1}, x=165,y=32+80,label="Brake"},
  {"WP_RADIUS"            , 0.0, 100.0, 0.1     , x=325,y=32+2,label="WPRad m"},
  {"WP_OVERSHOOT"         , 0.0, 10, 0.1        , x=325,y=32+18,label="WP ov.sh m"},
  {"TURN_MAX_G"           , 0.1, 10, 0.01       , x=325,y=32+34,label="Turn Dist"},
  {"NAVL1_PERIOD"         , 0, 60.0, 1          , x=325,y=32+50,label="Nav Perio"},
  {"NAVL1_DAMPING"        , 0.6, 1, 0.05        , x=325,y=32+64,label="Nav Damp"},
  --row 2
  {"TURN_RADIUS"          , 0, 10, 0.1          , x=5,y=32+126,label="Turn Speed"},
  {"MOT_PWM_TYPE"         , {"Norm","OS","OS125","BrRelay","BrBip","DS150","DS300","DS600","DS1200"}, {0,1,2,3,4,5,6,7,8}, x=165,y=32+126,label="Motor Type"},
  {"CRUISE_SPEED"         , 0, 100, 0.1         , x=165,y=32+142,label="Cruise Spd"},
  {"CRUISE_THROTTLE"      , 0, 100, 1           , x=165,y=32+158,label="Cruise Thr"},
  {"MOT_THR_MIN"          , 0, 20, 1            , x=165,y=32+174,label="Thr Min"},
  {"MOT_THR_MAX"          , 30, 100, 1          , x=165,y=32+190,label="Thr Max"},
}

return {
  list=parameters,
  description=description,
  boxes=boxes,
  labelWidth=labelWidth,
  columnWidth=columnWidth,
  listType=2 -- tuning panel
}
