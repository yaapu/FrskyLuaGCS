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

local frameNames = {}
-- copter
frameNames[0]   = "GEN"
frameNames[2]   = "QUAD"
frameNames[3]   = "COAX"
frameNames[4]   = "HELI"
frameNames[13]  = "HEX"
frameNames[14]  = "OCTO"
frameNames[15]  = "TRI"
frameNames[29]  = "DODE"
-- plane
frameNames[1]   = "WING"
frameNames[16]  = "FLAP"
frameNames[19]  = "VTOL2"
frameNames[20]  = "VTOL4"
frameNames[21]  = "VTOLT"
frameNames[22]  = "VTOL"
frameNames[23]  = "VTOL"
frameNames[24]  = "VTOL"
frameNames[25]  = "VTOL"
frameNames[28]  = "FOIL"
-- rover
frameNames[10]  = "ROV"
-- boat
frameNames[11]  = "BOAT"

local gpsStatuses = {}

gpsStatuses[0]="NoGPS"
gpsStatuses[1]="NoLock"
gpsStatuses[2]="2DFIX"
gpsStatuses[3]="3DFIX"
gpsStatuses[4]="DGPS"
gpsStatuses[5]="RTK"
gpsStatuses[6]="RTK"

------------------------------
-- TELEMETRY DATA
------------------------------
local telemetry = {}
-- STATUS 
telemetry.flightMode = 0
telemetry.simpleMode = 0
telemetry.landComplete = 0
telemetry.statusArmed = 0
telemetry.battFailsafe = 0
telemetry.ekfFailsafe = 0
telemetry.imuTemp = 0
-- GPS
telemetry.numSats = 0
telemetry.gpsStatus = 0
telemetry.gpsHdopC = 100
telemetry.gpsAlt = 0
-- BATT 1
telemetry.batt1volt = 0
telemetry.batt1current = 0
telemetry.batt1mah = 0
-- BATT 2
telemetry.batt2volt = 0
telemetry.batt2current = 0
telemetry.batt2mah = 0
-- HOME
telemetry.homeDist = 0
telemetry.homeAlt = 0
telemetry.homeAngle = -1
-- VELANDYAW
telemetry.vSpeed = 0
telemetry.hSpeed = 0
telemetry.yaw = 0
-- ROLLPITCH
telemetry.roll = 0
telemetry.pitch = 0
telemetry.range = 0 
-- PARAMS
telemetry.frameType = -1
telemetry.frame = nil
telemetry.batt1Capacity = 0
telemetry.batt2Capacity = 0
-- GPS
telemetry.lat = nil
telemetry.lon = nil
telemetry.homeLat = nil
telemetry.homeLon = nil
-- WP
telemetry.wpNumber = 0
telemetry.wpDistance = 0
telemetry.wpXTError = 0
telemetry.wpBearing = 0
telemetry.wpCommands = 0
-- RC channels
telemetry.rcchannels = {}
-- VFR
telemetry.airspeed = 0
telemetry.throttle = 0
telemetry.baroAlt = 0
-- Total distance
telemetry.totalDist = 0

--------------------------------
-- STATUS DATA
--------------------------------
local status = {}
-- MESSAGES
status.messages = {}
status.msgBuffer = ""
status.lastMsgValue = 0
status.lastMsgTime = 0
status.lastMessage = nil
status.lastMessageSeverity = 0
status.lastMessageCount = 1
status.messageCount = 0
-- LINK STATUS
status.noTelemetryData = 1
status.hideNoTelemetry = false
-- FLVSS 1
status.cell1min = 0
status.cell1sum = 0
-- FLVSS 2
status.cell2min = 0
status.cell2sum = 0
-- FC 1
status.cell1sumFC = 0
status.cell1maxFC = 0
-- FC 2
status.cell2sumFC = 0
status.cell2maxFC = 0
--------------------------------
status.cell1count = 0
status.cell2count = 0

status.battsource = "na"

status.batt1sources = {
  vs = false,
  fc = false
}
status.batt2sources = {
  vs = false,
  fc = false
}
-- SYNTH VSPEED SUPPORT
status.vspd = 0
status.synthVSpeedTime = 0
status.prevHomeAlt = 0
-- FLIGHT TIME
status.lastTimerStart = 0
status.timerRunning = 0
status.flightTime = 0
-- EVENTS
status.lastStatusArmed = 0
status.lastGpsStatus = 0
status.lastFlightMode = 0
status.lastSimpleMode = 0
-- battery levels
status.batLevel = 99
status.battLevel1 = false
status.battLevel2 = false
status.lastBattLevel = 14
-- LINK STATUS
status.showDualBattery = false
status.showMinMaxValues = false
-- MAP
status.screenTogglePage = 1
status.mapZoomLevel = 1
-- FLIGHTMODE
status.strFlightMode = nil
status.modelString = nil

local soundFileBasePath = "/SOUNDS/yaapu0"


local function drawWarning(text)
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  lcd.drawFilledRectangle(48,74, 384, 84, CUSTOM_COLOR)
  lcd.setColor(CUSTOM_COLOR,0xF800)
  lcd.drawFilledRectangle(50,76, 380, 80, CUSTOM_COLOR)
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  lcd.drawText(65, 80, text, DBLSIZE+CUSTOM_COLOR)
  lcd.drawText(130, 130, "Yaapu LuaGCS ".."1.0.3", SMLSIZE+CUSTOM_COLOR)
end

local function drawBars(page, menu)
  lcd.setColor(CUSTOM_COLOR,0x0000)
  lcd.drawFilledRectangle(0,0, LCD_W, 18, CUSTOM_COLOR)
  lcd.drawRectangle(0, 0, LCD_W, 18, CUSTOM_COLOR)
  
  --[[
  local itemIdx = string.format("%d/%d",menu.selectedItem,#page.list)
  lcd.setColor(CUSTOM_COLOR,COLOR_WHITE)
  lcd.drawText(LCD_W,190,itemIdx,CUSTOM_COLOR+RIGHT)
  --]]
end

local function drawTopBar(status,telemetryEnabled,telemetry)
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  local time = getDateTime()
  local strtime = string.format("%02d:%02d:%02d",time.hour,time.min,time.sec)
  lcd.drawText(LCD_W, 0+4, strtime, SMLSIZE+RIGHT+CUSTOM_COLOR)
  -- RSSI
  if telemetryEnabled() == false then
    lcd.setColor(CUSTOM_COLOR,0xF800)    
    lcd.drawText(285-23, 0, "NO TELEM", 0 +CUSTOM_COLOR)
  else
    lcd.drawText(285, 0, "RS:", 0 +CUSTOM_COLOR)
    lcd.drawText(285 + 30,0, getRSSI(), 0 +CUSTOM_COLOR)  
  end
  lcd.setColor(CUSTOM_COLOR,0xFFFF)    
  -- tx voltage
  local vtx = string.format("Tx:%.1fv",getValue(getFieldInfo("tx-voltage").id))
  lcd.drawText(350,0, vtx, 0+CUSTOM_COLOR)
end

local function drawBottomBar(status)
  lcd.setColor(CUSTOM_COLOR,0x0000)
  -- black bar
  lcd.drawFilledRectangle(0,LCD_H-20+3, LCD_W, 17, CUSTOM_COLOR)
  -- message text
  local msg = status.messages[(status.messageCount + #status.messages) % (#status.messages+1)][1]
  
  if status.messages[(status.messageCount + #status.messages) % (#status.messages+1)][2] < 4 then
    lcd.setColor(CUSTOM_COLOR,lcd.RGB(255,70,0))  
  elseif status.messages[(status.messageCount + #status.messages) % (#status.messages+1)][2] == 4 then
      lcd.setColor(CUSTOM_COLOR,lcd.RGB(255,255,0))  
  else
    lcd.setColor(CUSTOM_COLOR,0xFFFF)
  end
  lcd.drawText(1, LCD_H - 20, msg, CUSTOM_COLOR)
end

local function drawCommandItem(items,idx,menu,msgRequestStatus,mavResult)
  lcd.setColor(CUSTOM_COLOR,0xFFFF)    
  lcd.drawText(2,18 + (idx-menu.offset-1)*16, items[idx][1],CUSTOM_COLOR+SMLSIZE)
  if idx == menu.selectedItem then
    if menu.editSelected then
        flags = INVERS+BLINK
    else
      flags = INVERS
    end
  else
    flags = 0
  end
  lcd.drawText(280,18 + (idx-menu.offset-1)*16, items[idx][2][items[idx].value],flags+CUSTOM_COLOR+SMLSIZE)
  if items[idx].result == nil then
    lcd.drawText(LCD_W-2,18 + (idx-menu.offset-1)*16, msgRequestStatus[items[idx].status],flags+CUSTOM_COLOR+SMLSIZE+RIGHT)
  else
    lcd.drawText(LCD_W-2,18 + (idx-menu.offset-1)*16, mavResult[items[idx].result],flags+CUSTOM_COLOR+SMLSIZE+RIGHT)
  end
end

local function drawListItem(items, idx, menu, msgRequestStatus, configMenu)
  lcd.setColor(CUSTOM_COLOR,0xFFFF)    
  lcd.drawText(2,18 + (idx-menu.offset-1)*16, items[idx][1],CUSTOM_COLOR+SMLSIZE)
  
  if idx == menu.selectedItem then
    if menu.editSelected then
        flags = INVERS+BLINK
    else
      flags = INVERS
    end
  else
    flags = 0
  end
  
  local xPos = 165
  
  if configMenu then
    flags = flags + RIGHT
    xPos = LCD_W - 2
  end
  
  if items[idx].value == nil then
    lcd.drawText(xPos,18 + (idx-menu.offset-1)*16, "--------",flags+CUSTOM_COLOR+SMLSIZE)
  else
    if type(items[idx][2]) == "table" then -- COMBO
      local option = tostring(items[idx][2][items[idx].value])
      if #option > 25 then
        option = string.sub(option,1,25)
      end
      lcd.drawText(xPos,18 + (idx-menu.offset-1)*16, option ,flags+CUSTOM_COLOR+SMLSIZE)
    else
      lcd.drawText(xPos,18 + (idx-menu.offset-1)*16, string.format(items[idx].fstring,items[idx].value,(items[idx][5]~=nil and items[idx][5] or "")),flags+CUSTOM_COLOR+SMLSIZE)
    end
  end
  if not configMenu then
    lcd.drawText(LCD_W-2,18 + (idx-menu.offset-1)*16, msgRequestStatus[items[idx].status],flags+CUSTOM_COLOR+SMLSIZE+RIGHT)
  end
end

local function drawPanelItem(panel,idx,menu,msgShortRequestStatus)
  lcd.setColor(CUSTOM_COLOR,0xFFFF)    
  local items = panel.list
  lcd.drawText(items[idx].x,items[idx].y, items[idx].label,CUSTOM_COLOR+SMLSIZE)
  local flags = SMLSIZE
  if idx == menu.selectedItem then
    if menu.editSelected then
        flags = flags+INVERS+BLINK
    else
      flags = flags+INVERS
    end
  end
  if items[idx].value == nil then
    lcd.drawText(items[idx].x+panel.labelWidth,items[idx].y, "--------",flags+CUSTOM_COLOR)
  else
    if type(items[idx][2]) == "table" then
      lcd.drawText(items[idx].x+panel.labelWidth,items[idx].y, items[idx][2][items[idx].value],flags+CUSTOM_COLOR)
    else
      lcd.drawText(items[idx].x+panel.labelWidth,items[idx].y, string.format(items[idx].fstring,items[idx].value,(items[idx][5]~=nil and items[idx][5] or "")),flags+CUSTOM_COLOR)
    end
  end
  lcd.drawText(items[idx].x+panel.columnWidth-5,items[idx].y, msgShortRequestStatus[items[idx].status],CUSTOM_COLOR+RIGHT+SMLSIZE)
end

local function drawMessageScreen(status)
  for i=0,#status.messages do
    if  status.messages[(status.messageCount + i) % (#status.messages+1)][2] == 4 then
      lcd.setColor(CUSTOM_COLOR,lcd.RGB(255,255,0))
    elseif status.messages[(status.messageCount + i) % (#status.messages+1)][2] < 4 then
      lcd.setColor(CUSTOM_COLOR,lcd.RGB(255,70,0))  
    else
      lcd.setColor(CUSTOM_COLOR,0xFFFF)
    end
    lcd.drawText(0,2+13*i, status.messages[(status.messageCount + i) % (#status.messages+1)][1],SMLSIZE+CUSTOM_COLOR)
  end
end

local function drawStatusBar(status,telemetry,model,gpsStatuses)
  local yDelta = 36 -- (4-1)*12
  lcd.setColor(CUSTOM_COLOR,0x10A3)
  lcd.drawFilledRectangle(0,215-yDelta,LCD_W,LCD_H-(215-yDelta),CUSTOM_COLOR)
  -- flight time
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  lcd.drawTimer(LCD_W, 216-yDelta, model.getTimer(2).value, CUSTOM_COLOR+RIGHT)
  -- flight mode
  if status.strFlightMode ~= nil then
    lcd.drawText(1,216-yDelta,status.strFlightMode,CUSTOM_COLOR)
  end
  -- arming status
  if telemetry.statusArmed == 1 then
    lcd.setColor(CUSTOM_COLOR,0xF800)
    lcd.drawText(115,216-yDelta,"ARM",CUSTOM_COLOR)
  else
    lcd.setColor(CUSTOM_COLOR,0x1FEA)
    lcd.drawText(100,216-yDelta,"DISARM",CUSTOM_COLOR)
  end
  -- GPS
  local strStatus = gpsStatuses[telemetry.gpsStatus]
  local strSats = telemetry.numSats == 15 and string.format("(%d+)",telemetry.numSats) or string.format("(%d)",telemetry.numSats)
  if telemetry.gpsStatus  > 2 then
    lcd.setColor(CUSTOM_COLOR,0x1FEA)
    lcd.drawText(185,216-yDelta, string.format("%s%s", strStatus, strSats),CUSTOM_COLOR)
  else
    lcd.setColor(CUSTOM_COLOR,0xF800)
    lcd.drawText(185,216-yDelta, string.format("%s", strStatus, strSats),CUSTOM_COLOR)
  end
  -- battery
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  lcd.drawText(290,216-yDelta, string.format("%.01fv",telemetry.batt1volt*0.1),CUSTOM_COLOR+PREC1)
  -- current
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  lcd.drawText(360,216-yDelta, string.format("%.01fA",telemetry.batt1current*0.1),CUSTOM_COLOR+PREC1)
  -- battperc
  if telemetry.ekfFailsafe == 1 then
    lcd.setColor(CUSTOM_COLOR,0xF800)
    lcd.drawText(355,216-yDelta,"EKF_FS",CUSTOM_COLOR)
  else
    if telemetry.battFailsafe == 1 then
      lcd.setColor(CUSTOM_COLOR,0xF800)
      lcd.drawText(355,216-yDelta,"BAT_FS",CUSTOM_COLOR)
    end
  end
  -- yaw
  lcd.setColor(CUSTOM_COLOR,0x8C71)
  lcd.drawText(0,236-yDelta, "Hdg", CUSTOM_COLOR)
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  lcd.drawNumber(38,236-yDelta,telemetry.yaw,CUSTOM_COLOR)
  -- altitude
  lcd.setColor(CUSTOM_COLOR,0x8C71)
  lcd.drawText(95,236-yDelta, "Alt", CUSTOM_COLOR)
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  lcd.drawText(123,236-yDelta, string.format("%dm",telemetry.homeAlt),CUSTOM_COLOR)
  -- distance
  lcd.setColor(CUSTOM_COLOR,0x8C71)
  lcd.drawText(185,236-yDelta, "Dist", CUSTOM_COLOR)
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  lcd.drawText(223,236-yDelta, string.format("%dm",telemetry.homeDist),CUSTOM_COLOR)
  -- speed
  lcd.setColor(CUSTOM_COLOR,0x8C71)
  lcd.drawText(290,236-yDelta, "Spd", CUSTOM_COLOR)
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  lcd.drawText(324,236-yDelta, string.format("%dm/s",telemetry.hSpeed*0.1),CUSTOM_COLOR)
  -- vspeed
  lcd.setColor(CUSTOM_COLOR,0x8C71)
  lcd.drawText(395,236-yDelta, "VSI", CUSTOM_COLOR)
  lcd.setColor(CUSTOM_COLOR,0xFFFF)
  lcd.drawText(425,236-yDelta, string.format("%dm/s",telemetry.vSpeed*0.1),CUSTOM_COLOR)
  -- status text messages
  local offset = math.min(4,#status.messages+1)
  for i=0,offset-1 do
    if status.messages[(status.messageCount + i - offset) % (#status.messages+1)][2] < 4 then
      lcd.setColor(CUSTOM_COLOR,lcd.RGB(255,70,0))
    elseif status.messages[(status.messageCount + i - offset) % (#status.messages+1)][2] == 4 then
      lcd.setColor(CUSTOM_COLOR,lcd.RGB(255,255,0))
    else
      lcd.setColor(CUSTOM_COLOR,0xFFFF)
    end
    lcd.drawText(1,(256-yDelta)+(12*i), status.messages[(status.messageCount + i - offset) % (#status.messages+1)][1],SMLSIZE+CUSTOM_COLOR)
  end
end
return {
  drawWarning=drawWarning,
  drawBars=drawBars,
  drawTopBar=drawTopBar,
  drawBottomBar=drawBottomBar,
  drawCommandItem=drawCommandItem,
  drawListItem=drawListItem,
  drawMessageScreen=drawMessageScreen,
  drawPanelItem=drawPanelItem,
  drawStatusBar=drawStatusBar,
}

