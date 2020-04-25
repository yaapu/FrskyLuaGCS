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
-- enable events debug
--#define DEBUGEVT
-- cache tuning pages
--#define CACHE_TUNING
-- cache params pages
--#define CACHE_PARAMS
-- enable full telemetry debug
--#define DEBUG_SPORT
--#define DEBUG_MAVLITE
-- enable full telemetry decoding
--#define FULL_TELEMETRY
-- enable memory debuging 
-- enable dev code
--#define DEV
-- use radio channels imputs to generate fake telemetry data
--#define TESTMODE


---------------------
-- DEBUG REFRESH RATES
---------------------
-- calc and show hud refresh rate
-- calc and show telemetry process rate





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






local description = "Plane Tuning"
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
--]]local parameters = {
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
