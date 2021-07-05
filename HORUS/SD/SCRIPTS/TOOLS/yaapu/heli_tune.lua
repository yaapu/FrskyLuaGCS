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







local description = "HELI TUNE"
local labelWidth = 54
local columnWidth = 120
local boxes = {
  {label="Stabilize Roll"     , x=0       ,y=32      ,width=120,height=24, color=lcd.RGB(255,255,255)},
  {label="Stabilize Pitch"    , x=0+120   ,y=32      ,width=120,height=24, color=lcd.RGB(255,255,255)},
  {label="Stabilize Yaw"      , x=0+240   ,y=32      ,width=120,height=24, color=lcd.RGB(255,255,255)},
  {label="Stabilize Loiter"   , x=0+360   ,y=32      ,width=120,height=24, color=lcd.RGB(255,255,255)},
  
  {label="Rate Roll"          , x=0       ,y=32+38   ,width=120,height=90, color=lcd.RGB(255,255,255)},
  {label="Rate Pitch"         , x=0+120   ,y=32+38   ,width=120,height=90, color=lcd.RGB(255,255,255)},
  {label="Rate Yaw"           , x=0+240   ,y=32+38   ,width=120,height=90, color=lcd.RGB(255,255,255)},
  {label="Rate Loiter"        , x=0+360   ,y=32+38   ,width=120,height=74, color=lcd.RGB(255,255,255)},
  
  {label="Throttle Accel"     , x=0       ,y=32+142  ,width=120,height=74, color=lcd.RGB(255,255,255)},
  {label="Throttle Rate"      , x=0+120   ,y=32+142  ,width=120,height=24, color=lcd.RGB(255,255,255)},
  {label="Alt Hold"           , x=0+240   ,y=32+142  ,width=120,height=24, color=lcd.RGB(255,255,255)},
  {label="WP Nav cm/s"        , x=0+360   ,y=32+126  ,width=120,height=90, color=lcd.RGB(255,255,255)},
  
  {label="Autotune"           , x=0+120   ,y=32+180  ,width=120,height=36, color=lcd.RGB(255,255,255)},

  {label="Misc"                , x=0+240   ,y=32+180  ,width=120,height=36, color=lcd.RGB(255,255,255)},
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
  {"ATC_ANG_RLL_P"        , 0, 12.0, 0.05           , x=3,y=32+5,label="P"},
  {"ATC_ANG_PIT_P"        , 0, 12.0, 0.05           , x=123,y=32+5,label="P"},
  {"ATC_ANG_YAW_P"        , 0, 12.0, 0.05           , x=243,y=32+5,label="P"},
  {"PSC_POSXY_P"          , 0.5, 2, 0.1             , x=363,y=32+5,label="P"},
  
  -- row 2
  {"ATC_RAT_RLL_P"        , 0.0, 0.35, 0.005       , x=3,y=32+43,label="P"},
  {"ATC_RAT_RLL_I"        , 0.0, 0.6, 0.01         , x=3,y=32+59,label="I"},
  {"ATC_RAT_RLL_D"        , 0.00, 0.03, 0.0005      , x=3,y=32+75,label="D"},
  {"ATC_RAT_RLL_VFF"      , 0,0.5,.005               , x=3,y=32+91,label="FF"},
  {"ATC_RAT_RLL_IMAX"     , 0, 1, 0.01              , x=3,y=32+107,label="IMAX"},
  --{"ATC_RAT_RLL_FILT"   , 1, 20, 1                , x=3,y=32+107,label="FILT"},
  
  {"ATC_RAT_PIT_P"        , 0.0, 0.35, 0.005       , x=123,y=32+43,label="P"},
  {"ATC_RAT_PIT_I"        , 0.0, 0.6, 0.01         , x=123,y=32+59,label="I"},
  {"ATC_RAT_PIT_D"        , 0.00, 0.03, 0.0005      , x=123,y=32+75,label="D"},
  {"ATC_RAT_PIT_VFF"      , 0,0.5,.01               , x=123,y=32+91,label="FF"},
  {"ATC_RAT_PIT_IMAX"     , 0, 1, 0.01              , x=123,y=32+107,label="IMAX"},
  --{"ATC_RAT_PIT_FILT"   , 1, 20, 1                , x=123,y=32+107,label="FILT"},
  
  {"ATC_RAT_YAW_P"        , 0.0, 0.6, 0.005        , x=243,y=32+43,label="P"},
  {"ATC_RAT_YAW_I"        , 0.0, 0.06, 0.01        , x=243,y=32+59,label="I"},
  {"ATC_RAT_YAW_D"        , 0.0, 0.03, 0.0005        , x=243,y=32+75,label="D"},
  {"ATC_RAT_YAW_VFF"      , 0.0,0.5,.001               , x=243,y=32+91,label="FF"},
  {"ATC_RAT_YAW_IMAX"     , 0, 1, 0.01              , x=243,y=32+107,label="IMAX"},
  --{"ATC_RAT_YAW_FILT"   , 1, 20, 1                , x=243,y=32+107,label="FILT"},
  
  {"PSC_VELXY_P"          , 0.1, 6.0, 0.1           , x=363,y=32+43,label="P"},
  {"PSC_VELXY_I"          , 0.02, 1.0, 0.01         , x=363,y=32+59,label="I"},
  {"PSC_VELXY_D"          , 0.0, 1.0, 0.001         , x=363,y=32+75,label="D"},
  {"PSC_VELXY_IMAX"       , 0, 4500, 10             , x=363,y=32+91,label="IMAX"},
  
  -- row 3
  {"PSC_ACCZ_P"           , 0.5, 1.5, 0.05          , x=3,y=32+147,label="P"},
  {"PSC_ACCZ_I"           , 0.0, 3.0, 0.05          , x=3,y=32+163,label="I"},
  {"PSC_ACCZ_D"           , 0.0, 0.4, 0.01          , x=3,y=32+179,label="D"},
  {"PSC_ACCZ_IMAX"        , 0, 1000, 1              , x=3,y=32+195,label="IMAX"},

  {"PSC_VELZ_P"           , 1, 8.0, 0.25            , x=123,y=32+147,label="P"},

  {"PSC_POSZ_P"           , 1, 3.0, 0.1             , x=243,y=32+147,label="P"},

  {"WPNAV_SPEED"          , 20, 2000, 50            , x=363,y=32+133,label="Speed"},
  {"WPNAV_RADIUS"         , 5, 1000, 1              , x=363,y=32+148,label="Radius"},
  {"WPNAV_SPEED_UP"       , 10, 1000, 50            , x=363,y=32+164,label="Spd Up"},
  {"WPNAV_SPEED_DN"       , 10, 500, 10             , x=363,y=32+180,label="Spd Dn"},
  {"LOIT_SPEED"           , 20, 2000, 50            , x=363,y=32+196,label="Loiter"},
  -- row 4
  {"AUTOTUNE_AXES", 1, 1, {"All","Roll","Ptch","Yaw","R+P","R+Y","P+Y"}, {7,1,2,3,4,5,6}, x=123,y=32+184,label="Axis"},
  {"AUTOTUNE_AGGR"        , 0.05, 0.1, 0.01         , x=123,y=32+196,label="Aggr"},
  {"H_RSC_SETPOINT"       , 10,100,1                , x=243,y=32+184,label="RSC %"},
  {"ATC_HOVR_ROL_TRM"     , 0, 1200, 10               , x=243,y=32+196,label="RllTrim"},
}

return {
  list=parameters,
  description=description,
  boxes=boxes,
  labelWidth=labelWidth,
  columnWidth=columnWidth,
  listType=2 -- tuning panel
}
