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


-- X-Lite Support

----------------------
--- COLORS
----------------------

--#define COLOR_LABEL 0x7BCF
--#define COLOR_BG 0x0169






local description = "ROVER TUNE"
local labelWidth = 83
local columnWidth = 160
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
  --row 2
  {"TURN_RADIUS"          , 0, 10, 0.1          , x=5,y=32+126,label="Turn Speed"},
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
