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


--[[
0	MAV_SEVERITY_EMERGENCY	System is unusable. This is a "panic" condition.
1	MAV_SEVERITY_ALERT	Action should be taken immediately. Indicates error in non-critical systems.
2	MAV_SEVERITY_CRITICAL	Action must be taken immediately. Indicates failure in a primary system.
3	MAV_SEVERITY_ERROR	Indicates an error in secondary/redundant systems.
4	MAV_SEVERITY_WARNING	Indicates about a possible future error if this is not resolved within a given timeframe. Example would be a low battery warning.
5	MAV_SEVERITY_NOTICE	An unusual event has occured, though not an error condition. This should be investigated for the root cause.
6	MAV_SEVERITY_INFO	Normal operational messages. Useful for logging. No action is required for these messages.
7	MAV_SEVERITY_DEBUG	Useful non-operational messages that can assist in debugging. These should not occur during normal operation.
--]]
local mavSeverity = {}

mavSeverity[0]="EMR"
mavSeverity[1]="ALR"
mavSeverity[2]="CRT"
mavSeverity[3]="ERR"
mavSeverity[4]="WRN"
mavSeverity[5]="NOT"
mavSeverity[6]="INF"
mavSeverity[7]="DBG"

--[[
	MAV_TYPE_GENERIC=0,               /* Generic micro air vehicle. | */
	MAV_TYPE_FIXED_WING=1,            /* Fixed wing aircraft. | */
	MAV_TYPE_QUADROTOR=2,             /* Quadrotor | */
	MAV_TYPE_COAXIAL=3,               /* Coaxial helicopter | */
	MAV_TYPE_HELICOPTER=4,            /* Normal helicopter with tail rotor. | */
	MAV_TYPE_ANTENNA_TRACKER=5,       /* Ground installation | */
	MAV_TYPE_GCS=6,                   /* Operator control unit / ground control station | */
	MAV_TYPE_AIRSHIP=7,               /* Airship, controlled | */
	MAV_TYPE_FREE_BALLOON=8,          /* Free balloon, uncontrolled | */
	MAV_TYPE_ROCKET=9,                /* Rocket | */
	MAV_TYPE_GROUND_ROVER=10,         /* Ground rover | */
	MAV_TYPE_SURFACE_BOAT=11,         /* Surface vessel, boat, ship | */
	MAV_TYPE_SUBMARINE=12,            /* Submarine | */
  MAV_TYPE_HEXAROTOR=13,            /* Hexarotor | */
	MAV_TYPE_OCTOROTOR=14,            /* Octorotor | */
	MAV_TYPE_TRICOPTER=15,            /* Tricopter | */
	MAV_TYPE_FLAPPING_WING=16,        /* Flapping wing | */
	MAV_TYPE_KITE=17,                 /* Kite | */
	MAV_TYPE_ONBOARD_CONTROLLER=18,   /* Onboard companion controller | */
	MAV_TYPE_VTOL_DUOROTOR=19,        /* Two-rotor VTOL using control surfaces in vertical operation in addition. Tailsitter. | */
	MAV_TYPE_VTOL_QUADROTOR=20,       /* Quad-rotor VTOL using a V-shaped quad config in vertical operation. Tailsitter. | */
	MAV_TYPE_VTOL_TILTROTOR=21,       /* Tiltrotor VTOL | */
	MAV_TYPE_VTOL_RESERVED2=22,       /* VTOL reserved 2 | */
	MAV_TYPE_VTOL_RESERVED3=23,       /* VTOL reserved 3 | */
	MAV_TYPE_VTOL_RESERVED4=24,       /* VTOL reserved 4 | */
	MAV_TYPE_VTOL_RESERVED5=25,       /* VTOL reserved 5 | */
	MAV_TYPE_GIMBAL=26,               /* Onboard gimbal | */
	MAV_TYPE_ADSB=27,                 /* Onboard ADSB peripheral | */
	MAV_TYPE_PARAFOIL=28,             /* Steerable, nonrigid airfoil | */
	MAV_TYPE_DODECAROTOR=29,          /* Dodecarotor | */
]]
local frameType = nil
local frameTypes = {}
-- copter
frameTypes[0]   = "c"
frameTypes[2]   = "c"
frameTypes[3]   = "c"
frameTypes[4]   = "h"
frameTypes[13]  = "c"
frameTypes[14]  = "c"
frameTypes[15]  = "c"
frameTypes[29]  = "c"
-- plane
frameTypes[1]   = "p"
frameTypes[16]  = "p"
frameTypes[19]  = "p"
frameTypes[20]  = "p"
frameTypes[21]  = "p"
frameTypes[22]  = "p"
frameTypes[23]  = "p"
frameTypes[24]  = "p"
frameTypes[25]  = "p"
frameTypes[28]  = "p"
-- rover
frameTypes[10]  = "r"
-- boat
frameTypes[11]  = "b"


local status = {
  messages = {},
  messageCount = 1,
  msgBuffer = "",
  lastMsgValue = 0,
}
status.messages[1] = {} -- only 1 message for Taranis radios

local telemetry = {
  frameType = -1,
  batt1volt = 0,
}

----------------------
--- COLORS
----------------------

--#define COLOR_LABEL 0x7BCF
--#define COLOR_BG 0x0169





local function drawWarning(text)
  lcd.drawFilledRectangle(12,18, 105, 30, SOLID)
  lcd.drawRectangle(12,18, 105, 30, ERASE)
  lcd.drawText(30, 29, text, INVERS)
end
local function drawBars(page, menu)
  local itemIdx = string.format("%s %d/%d",string.sub(page.description,1,10),menu.selectedItem,#page.list)
  lcd.drawText(0,0,itemIdx,SMLSIZE+INVERS)
end
local function drawTopBar(status,telemetryEnabled,telemetry)
  lcd.drawFilledRectangle(0,0, LCD_W, 7, SOLID+FORCE)
  lcd.drawText(LCD_W,0, string.format("RS:%d",getRSSI()), SMLSIZE+INVERS+RIGHT)  
  lcd.drawText(LCD_W-30,0, string.format("%.01fV",telemetry.batt1volt*100), SMLSIZE+INVERS+RIGHT)  
end


local function drawBottomBar(status)
  -- black bar
  lcd.drawFilledRectangle(0,LCD_H-8, LCD_W, 8, SOLID+FORCE)
  -- message text
  local msg = status.messages[1][1]
  lcd.drawText(1, LCD_H - 7, msg, SMLSIZE+INVERS)
end

local function drawCommandItem(items,idx,menu,msgRequestStatus,mavResult)
  lcd.drawText(0,7 + (idx-menu.offset-1)*7, string.sub(items[idx][1],1,6),SMLSIZE)
  if idx == menu.selectedItem then
    if menu.editSelected then
        flags = INVERS+BLINK
    else
      flags = INVERS
    end
  else
    flags = 0
  end
  lcd.drawText(LCD_W-15,7 + (idx-menu.offset-1)*7, string.sub(items[idx][2][items[idx].value],1,16),flags+SMLSIZE+RIGHT)
  if items[idx].result == nil then
    lcd.drawText(LCD_W,7 + (idx-menu.offset-1)*7, msgRequestStatus[items[idx].status],flags+SMLSIZE+RIGHT)
  else
    lcd.drawText(LCD_W,7 + (idx-menu.offset-1)*7, mavResult[items[idx].result],flags+SMLSIZE+RIGHT)
  end
end

local function drawListItem(items,idx,menu,msgRequestStatus)
  lcd.drawText(2,7 + (idx-menu.offset-1)*7, items[idx][1],SMLSIZE)
  if idx == menu.selectedItem then
    if menu.editSelected then
        flags = INVERS+BLINK
    else
      flags = INVERS
    end
  else
    flags = 0
  end
  if items[idx].value == nil then
    lcd.drawText(LCD_W-15,7 + (idx-menu.offset-1)*7, "---",SMLSIZE+flags+RIGHT)
  else
    if type(items[idx][2]) == "table" then -- COMBO
      lcd.drawText(LCD_W-15,7 + (idx-menu.offset-1)*7, items[idx][2][items[idx].value],SMLSIZE+flags+RIGHT)
    else
      lcd.drawText(LCD_W-15,7 + (idx-menu.offset-1)*7, string.format(items[idx].fstring,items[idx].value,(items[idx][5]~=nil and items[idx][5] or "")),flags+SMLSIZE+RIGHT)
    end
  end
  lcd.drawText(LCD_W,7 + (idx-menu.offset-1)*7, msgRequestStatus[items[idx].status],flags+SMLSIZE+RIGHT)
end

local function drawMessageScreen(status)
  for i=0,#status.messages do
    lcd.drawText(1,1+7*i, status.messages[(status.messageCount + i) % (#status.messages+1)][1],SMLSIZE)
  end
end

local function drawStatusBar(status,telemetry,model,gpsStatuses)
end

return {
  drawWarning=drawWarning,
  drawBars=drawBars,
  drawTopBar=drawTopBar,
  drawBottomBar=drawBottomBar,
  drawCommandItem=drawCommandItem,
  drawListItem=drawListItem,
  drawMessageScreen=drawMessageScreen,
  drawStatusBar=drawStatusBar,
}

