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


local description = "PLANE TUNE"
local labelWidth = 83
local columnWidth = 160
local boxes = {
  {label="Servo Roll Pid"   , x=0       ,y=32      ,width=160,height=70, color=lcd.RGB(255,255,255)},
  {label="Servo Pitch Pid"  , x=0+160   ,y=32      ,width=160,height=70, color=lcd.RGB(255,255,255)},
  {label="Servo Yaw Pid"    , x=0+320   ,y=32      ,width=160,height=70, color=lcd.RGB(255,255,255)},
  {label="L1 Nav"           , x=0       ,y=32+80   ,width=160,height=38, color=lcd.RGB(255,255,255)},
  {label="TECS"             , x=0       ,y=32+130  ,width=160,height=90, color=lcd.RGB(255,255,255)},
  {label="Other Mix's"      , x=0+160   ,y=32+80   ,width=160,height=38, color=lcd.RGB(255,255,255)},
  {label="Throttle %"       , x=0+320   ,y=32+80   ,width=160,height=70, color=lcd.RGB(255,255,255)},
  {label="Airspeed m/s"     , x=0+160   ,y=32+130  ,width=160,height=90, color=lcd.RGB(255,255,255)},
  {label="Nav Angles"       , x=0+320   ,y=32+164  ,width=160,height=56, color=lcd.RGB(255,255,255)},
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
  {"RLL2SRV_P"      , 0.1, 4.0, 0.1       , x=5,y=32+2,label="P"},
  {"RLL2SRV_I"      , 0.0, 1.0, 0.05      , x=5,y=32+18,label="I"},
  {"RLL2SRV_D"      , 0.0, 0.2, 0.01      , x=5,y=32+34,label="D"},
  {"RLL2SRV_IMAX"   , 0, 4500, 1          , x=5,y=32+50,label="IMAX"},

  {"PTCH2SRV_P"     , 0.1, 4.0, 0.1       , x=165,y=32+2,label="P"},
  {"PTCH2SRV_I"     , 0.1, 1.0, 0.05      , x=165,y=32+18,label="I"},
  {"PTCH2SRV_D"     , 0.0, 0.2, 0.01      , x=165,y=32+34,label="D"},
  {"PTCH2SRV_IMAX"  , 0, 4500, 1          , x=165,y=32+50,label="IMAX"},
  
  {"YAW2SRV_SLIP"   , 0, 4.0, 0.25        , x=325,y=32+2,label="SLIP"},
  {"YAW2SRV_INT"    , 0.0, 2.0, 0.25      , x=325,y=32+18,label="INT"},
  {"YAW2SRV_DAMP"   , 0.0, 2.0, 0.25      , x=325,y=32+34,label="DAMP"},
  {"YAW2SRV_IMAX"   , 0, 4500, 1          , x=325,y=32+50,label="IMAX"},

  --row 2
  {"NAVL1_PERIOD"   , 1, 60, 1            , x=5,y=32+82,label="Period"},
  {"NAVL1_DAMPING"  , 0.6, 1.0, 0.05      , x=5,y=32+98,label="Damping"},

  {"KFF_RDDRMIX"    , 1, 10, 0.01         , x=165,y=32+82,label="RudderMix"},
  --{"KFF_THR2PTCH", 0, 5, 0.01           , x=165,y=32+98,label="P to T"},
  
  {"TRIM_THROTTLE"  , 0, 100, 1           , x=325,y=32+82,label="Cruise"},
  {"THR_MIN"        , -100, 100, 1        , x=325,y=32+98,label="Min"},
  {"THR_MAX"        , 0, 100, 1           , x=325,y=32+114,label="Max"},
  {"THR_SLEWRATE"   , 1, 127, 1           , x=325,y=32+130,label="Slew Rate"},
  
  -- row 3
  {"TECS_CLMB_MAX"  , 0.1, 20.0, 0.1      , x=5,y=32+135,label="Climb Max"},
  {"TECS_SINK_MIN"  , 0.1, 10.0, 0.1      , x=5,y=32+152,label="Sink Min"},
  {"TECS_SINK_MAX"  , 0.0, 20.0, 0.1      , x=5,y=32+167,label="Sink Max"},
  {"TECS_PTCH_DAMP" , 0.1, 1, 0.1         , x=5,y=32+183,label="Pitch Damp"},
  {"TECS_TIME_CONST", 3.0, 10.0, 0.2      , x=5,y=32+199,label="Time Const"},

  {"TRIM_ARSPD_CM"  , 0, 100, 0.5         , x=165,y=32+135,label="Cruise",mult=100}, -- m/s but save as cm/s
  {"ARSPD_FBW_MIN"  , 5, 100, 1           , x=165,y=32+152,label="FBW Min"},
  {"ARSPD_FBW_MAX"  , 5, 100, 1           , x=165,y=32+167,label="FBW Max"},
  {"ARSPD_RATIO"    , 0, 100, 0.1         , x=165,y=32+183,label="Ratio"},
  {"LIM_ROLL_CD"    , 0, 90, 1            , x=325,y=32+167,label="Bank Max",mult=100},
  {"LIM_PITCH_MIN"  , -90, 0, 1           , x=325,y=32+183,label="Pitch Min",mult=100},
  {"LIM_PITCH_MAX"  , 0, 90, 1            , x=325,y=32+199,label="Pitch Max",mult=100},
}

return {
  list=parameters,
  description=description,
  boxes=boxes,
  labelWidth=labelWidth,
  columnWidth=columnWidth,
  listType=2 -- tuning panel
}

