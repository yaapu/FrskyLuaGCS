--
-- An FRSKY S.Port <passthrough protocol> based Telemetry script for the Horus X10 and X12 radios
--
-- Copyright (C) 2018-2019. Alessandro Apostoli
-- https://github.com/yaapu
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

---------------------
-- MAIN CONFIG
-- 480x272 LCD_W x LCD_H
---------------------

---------------------
-- VERSION
---------------------
-- load and compile of lua files
--#define LOADSCRIPT
-- enable mavlite logging to file
--#define LOGTOFILE
-- uncomment to force compile of all chunks, comment for release
--#define COMPILE
-- fix for issue OpenTX 2.2.1 on X10/X10S - https://github.com/opentx/opentx/issues/5764


---------------------
-- MAVLITE CONFIG
---------------------

---------------------
-- DEV FEATURE CONFIG
---------------------
-- enable pages debug
--#define DEBUG_PAGES
-- enable events debug
-- cache tuning pages
--#define 
-- cache params pages
--#define 
-- enable full telemetry debug
-- enable full telemetry decoding
--#define FULL_TELEMETRY
-- enable memory debuging 
--#define MEMDEBUG
-- enable dev code
--#define DEV
-- use radio channels imputs to generate fake telemetry data
--#define TESTMODE


---------------------
-- DEBUG REFRESH RATES
---------------------
-- calc and show hud refresh rate
--#define HUDRATE
-- calc and show telemetry process rate
--#define BGTELERATE





--------------------------------------------------------------------------------
-- MENU VALUE,COMBO
--------------------------------------------------------------------------------

-----------------------
-- LIBRARY LOADING
-----------------------

--[[
  status of pending mavlite messages
]]


-- X-Lite Support

----------------------
--- COLORS
----------------------

--#define COLOR_LABEL 0x7BCF
--#define COLOR_BG 0x0169






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
  {"RLL_RATE_P"     , 0.08, 0.35, 0.005   , x=5,y=32+2,label="P"},
  {"RLL_RATE_I"     , 0.01, 0.6, 0.01     , x=5,y=32+18,label="I"},
  {"RLL_RATE_D"     , 0.001, 0.03, 0.001  , x=5,y=32+34,label="D"},
  {"RLL_RATE_IMAX"   , 0, 4500, 1          , x=5,y=32+50,label="IMAX"},

  {"PTCH_RATE_P"    , 0.08, 0.35, 0.005   , x=165,y=32+2,label="P"},
  {"PTCH_RATE_I"    , 0.01, 0.6, 0.01     , x=165,y=32+18,label="I"},
  {"PTCH_RATE_D"    , 0.001, 0.03, 0.001  , x=165,y=32+34,label="D"},
  {"PTCH_RATE_IMAX"  , 0, 4500, 1          , x=165,y=32+50,label="IMAX"},
  
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
