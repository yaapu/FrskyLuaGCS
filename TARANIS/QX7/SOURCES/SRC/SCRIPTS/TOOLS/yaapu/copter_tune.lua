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
--#define DEBUGEVT
-- cache tuning pages
--#define CACHE_TUNING
-- cache params pages
--#define CACHE_PARAMS
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



----------------------
--- COLORS
----------------------

--#define COLOR_LABEL 0x7BCF
--#define COLOR_BG 0x0169







local description = "COPTER TUNE"
local panel = true
local labelWidth = 54
local columnWidth = 120
local boxes = {
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
  -- row 2
  {"ATC_RAT_RLL_P"        , 0.01, 0.5, 0.005        , x=3,y=32+43,label="P"},
  {"ATC_RAT_RLL_I"        , 0.01, 2.0, 0.01         , x=3,y=32+59,label="I"},
  {"ATC_RAT_RLL_D"        , 0.0, 0.05, 0.001        , x=3,y=32+75,label="D"},
  
  {"ATC_RAT_PIT_P"        , 0.01, 0.5, 0.005        , x=123,y=32+43,label="P"},
  {"ATC_RAT_PIT_I"        , 0.01, 2.0, 0.01         , x=123,y=32+59,label="I"},
  {"ATC_RAT_PIT_D"        , 0.0, 0.05, 0.001        , x=123,y=32+75,label="D"},
  
  {"ATC_RAT_YAW_P"        , 0.1, 2.5, 0.005         , x=243,y=32+43,label="P"},
  {"ATC_RAT_YAW_I"        , 0.01, 1.0, 0.01         , x=243,y=32+59,label="I"},
  {"ATC_RAT_YAW_D"        , 0.0, 0.02, 0.001        , x=243,y=32+75,label="D"},
  
  -- row 4
  {"AUTOTUNE_AXES"        , {"All","Roll","Ptch","Yaw","R+P","R+Y","P+Y"}, {7,1,2,4,3,5,6}, x=123,y=32+184,label="Axis"},
  {"AUTOTUNE_AGGR"        , 0.05, 0.1, 0.01         , x=123,y=32+200,label="Aggr"},
  {"TUNE",{"None","Stab Roll/Pitch kP","Rate Roll/Pitch kP","Rate Roll/Pitch kI","Rate Roll/Pitch kD","Stab Yaw kP","Rate Yaw kP","Rate Yaw kD","Rate Yaw Filter","Motor Yaw Headroom","AltHold kP","Throttle Rate kP","Throttle Accel kP","Throttle Accel kI","Throttle Accel kD","Loiter Pos kP","Velocity XY kP","Velocity XY kI","WP Speed","Acro RollPitch kP","Acro Yaw kP","RC Feel","Heli Ext Gyro","Declination","Circle Rate","RangeFinder Gain","Rate Pitch kP","Rate Pitch kI","Rate Pitch kD","Rate Roll kP","Rate Roll kI","Rate Roll kD","Rate Pitch FF","Rate Roll FF","Rate Yaw FF","Winch","SysID Magnitude",},{0,1,4,5,21,3,6,26,56,55,14,7,34,35,36,12,22,28,10,25,40,45,13,38,39,41,46,47,48,49,50,51,52,53,54,57,58,},},
  {"TUNE_MIN",0,1000000,0.1,"",},
  {"TUNE_MAX",0,1000000,0.1,"",},
}

return {
  list=parameters,
  description=description,
  boxes=boxes,
  labelWidth=labelWidth,
  columnWidth=columnWidth,
  listType=2 -- tuning panel
}
