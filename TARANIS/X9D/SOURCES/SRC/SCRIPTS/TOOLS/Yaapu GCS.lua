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






--------------------------------------------------------------------------------
-- CONFIGURATION MENU
--------------------------------------------------------------------------------
local conf = {
  language = "en",
  disableMsgBeep = 2,
  enableDebug = false
}

local msgRequestStatus = {
  [0] = "IDLE",
  [1] = "READ_REQ",
  [2] = "SET_REQ",
  [3] = "WAIT",
  [4] = "ERR_EXP",
  [5] = "OK",
  [6] = "ERR_IDX",
  [7] = "ERR_RNG",
}


local mavResult = {
  [0] = "ACCEPT",
  [1] = "REJECT",
  [2] = "DENIED",
  [3] = "UNSUPP",
  [4] = "FAILED",
  [5] = "PROGRES",
}

local utils = {}
local mavLib = {}
local frame = {}
local drawLib = {}

--------------------
-- pages
--------------------
local pages = {}
local pageFiles = {}

-- parameters used to check specific vehicle params at boot
local globalParams = {}
local globalParamsDone = false

local basePath = "/SCRIPTS/TOOLS/yaapu/"
local libBasePath = basePath
local cfgPath = "/MODELS/yaapu/"

local bitmaps = {}
local blinktime = getTime()
local blinkon = false

local menu  = {
  selectedItem = 1,
  editSelected = false,
  offset = 0,
  wrapOffset = 0, -- changes according to enabled/disabled features and panels
  page = 0,
}

local sportPacket = {
  sensor_id = nil,
  frame_id = nil,
  data_id = nil,
  value = nil
}

local mavlite_message= {
  msgid = -1,
  len = 0,
  payload = {},
  checksum = 0
}

local mavlite_status = {
  parse_state = 0,
  current_rx_seq = 0,
  payload_next_byte = 0
}

local idx = 1 -- index of the current item being processed by processItems()
local page = 1


utils.doLibrary = function(filename)
  local f = assert(loadScript(libBasePath..filename..".lua"))
  -- recover memory
  collectgarbage()
  collectgarbage()
  return f()
end

-----------------------------
-- clears the loaded table 
-- and recovers memory
-----------------------------
utils.clearTable = function(t)
  if type(t)=="table" then
    for i,v in pairs(t) do
      if type(v) == "table" then
        utils.clearTable(v)
      end
      t[i] = nil
    end
  end
  t = nil
  collectgarbage()
  collectgarbage()
  maxmem = 0
end  

local function getItemByName(items,name)
  for idx=1,#items
  do
    if items[idx][1] == name then
      return items[idx]
    end
  end
  return nil
end

local function getItemByCommandID(items,cmd_id)
  for idx=1,#items
  do
    if items[idx].cmd_id == cmd_id then
      return items[idx]
    end
  end
  return nil
end

local function telemetryEnabled()
  if getRSSI() == 0 then
    status.noTelemetryData = 1
  end
  return status.noTelemetryData == 0
end

local function incMenuItem(items,idx)
  if type(items[idx][2]) == "table" then
    if items[idx].value == nil then
      items[idx].value = 1
    else
      items[idx].value = items[idx].value + 1
    end
    if items[idx].value > #items[idx][2] then
      items[idx].value = 1
    end
  else
    items[idx].value = items[idx].value + items[idx][4]
    if items[idx].value > items[idx][3] then
      items[idx].value = items[idx][3]
    end
  end
end

local function decMenuItem(items,idx)
  if type(items[idx][2]) == "table" then
    if items[idx].value == nil then
      items[idx].value = 1
    else
      items[idx].value = items[idx].value - 1
    end
    if items[idx].value < 1 then
      items[idx].value = #items[idx][2]
    end
  else
    items[idx].value = items[idx].value - items[idx][4]
    if items[idx].value < items[idx][2] then
      items[idx].value = items[idx][2]
    end
  end
end

local function getDecimalCount(num)
  local strNum = tostring(num)
  local pos = string.find(strNum,"%.")
  -- recover memory
  collectgarbage()
  collectgarbage()
  return pos == nil and 0 or #strNum - pos
end

-- model and opentx version
local ver, radio, maj, minor, rev = getVersion()
local drawLine = nil



local function writeItem(idxToSave)
  if pages[page].listType == 4 then
    -- config menu changed, save to file
    local item = pages[page].list[idxToSave]
    if type(item[2]) == "table" then -- COMBO
      conf[item.property] = item[3][item.value]
    else
    end
  else
    pages[page].list[idxToSave].status = 2
    if pages[page].listType == 3 then
      -- commands
      pages[page].list[idxToSave].result = nil
    end
  end
  -- force this item as next to be processed
  idx = idxToSave
end

local function drawList(myPage, event)
  local items = myPage.list
  drawLib.drawBars(myPage, menu)
  if event == EVT_ENTER_BREAK then
    if menu.editSelected == true then
      -- confirm modified value
      writeItem(menu.selectedItem)
    else
      -- save last value for undo
      items[menu.selectedItem].lastValue = items[menu.selectedItem].value
    end
    if items[menu.selectedItem].value ~= nil or items[menu.selectedItem].status == 6 then
      menu.editSelected = not menu.editSelected
      menu.updated = true
    else
      -- trigger refresh
      if items[menu.selectedItem].status == 0  or items[menu.selectedItem].status == 5 or items[menu.selectedItem].status == 4 then
        items[menu.selectedItem].status = 1
      end
    end
  elseif menu.editSelected and (event == EVT_EXIT_BREAK ) then
    items[menu.selectedItem].value = items[menu.selectedItem].lastValue
    menu.editSelected = not menu.editSelected
    menu.updated = false
  elseif menu.editSelected and (event == EVT_PLUS_BREAK or event == EVT_ROT_LEFT or event == EVT_PLUS_REPT) then
    incMenuItem(items,menu.selectedItem)
  elseif menu.editSelected and (event == EVT_MINUS_BREAK or event == EVT_ROT_RIGHT or event == EVT_MINUS_REPT) then
    decMenuItem(items,menu.selectedItem)
  elseif not menu.editSelected and (event == EVT_PLUS_BREAK or event == EVT_ROT_LEFT) then
    menu.selectedItem = (menu.selectedItem - 1)
    if menu.offset >=  menu.selectedItem then
      menu.offset = menu.offset - 1
    end
  elseif not menu.editSelected and (event == EVT_MINUS_BREAK or event == EVT_ROT_RIGHT) then
    menu.selectedItem = (menu.selectedItem + 1)
    if menu.selectedItem - 7 > menu.offset then
      menu.offset = menu.offset + 1
    end
  end
  --wrap
  if menu.selectedItem > #items then
    menu.selectedItem = 1 
    menu.offset = 0
  elseif menu.selectedItem  < 1 then
    menu.selectedItem = #items
    menu.offset =  math.max(0,#items - 7)
  end
  
  if myPage.listType == nil or myPage.listType == 4 then -- paramters or config menu
  -- draw list
    for m=1+menu.offset,math.min(#items,7+menu.offset) do
      drawLib.drawListItem(items, m, menu, msgRequestStatus, myPage.listType == 4)
    end
  elseif myPage.listType == 2 then -- tuning panels
  -- draw list
    for m=1+menu.offset,math.min(#items,7+menu.offset) do
      drawLib.drawListItem(items,m,menu,msgRequestStatus)
    end
  elseif myPage.listType == 3 then -- commands
  -- draw list
    for m=1+menu.offset,math.min(#items,7+menu.offset) do
      drawLib.drawCommandItem(items,m,menu,msgRequestStatus,mavResult)
    end
  end
  -- page title
end


local function processMavliteMessage(msg)
  if msg.msgid == 23 then
    local param_value = mavLib.msg_get_float(msg,0)
    local param_name = mavLib.msg_get_string(msg,4)
    if conf.enableDebug == true then
      utils.pushMessage(7,string.format("RX: ID=%d, %s : %f",msg.msgid,param_name,param_value), true)
    end
  elseif msg.msgid == 22 then -- PARAM_VALUE
    local param_value = mavLib.msg_get_float(msg,0)
    local param_name = mavLib.msg_get_string(msg,4)
    if conf.enableDebug == true then
      utils.pushMessage(7,string.format("RX: ID=%d, %s : %f",msg.msgid,param_name,param_value), true)
    end
    local item = getItemByName(globalParams,param_name)
    
    if item == nil then
      if pages[page]  ~= nil then
        item = getItemByName(pages[page].list, param_name)
      end
    end
    
    if item ~= nil then
      -- update value
      if type(item[2]) == "table" then -- COMBO
        -- look value up
        local success = false
        
        for i=1,#item[3]
        do
          if item[3][i] == param_value then
            item.value = i
            success = true
            break
          end
        end
        item.status = success == true and 5 or 6
      else
        item.value = param_value * (item.mult == nil and 1 or 1/item.mult)
        -- make all digits visible even if the increment has a lower resolution!
        -- when in panel mode precision is limited to 4 just like MP
        local precision = item.label == nil and 6 or 4
        
        item.fstring = "%.0"..tostring(math.min(precision,math.max(getDecimalCount(item.value),math.max(1,getDecimalCount(item[4]))))).."f %s"
        if item.value < item[2] or item.value > item[3] then
          -- update status
          item.status = 7
        else
          -- update status
          item.status = 5
        end
      end
    end
    -- recover memory
    collectgarbage()
    collectgarbage()
  elseif msg.msgid == 77 then -- CMD_ACK
    local cmd_id = mavLib.msg_get_uint16(msg,0)
    local mav_result = mavLib.msg_get_uint8(msg,2)
    if conf.enableDebug == true then
      utils.pushMessage(7,string.format("RX: ID=%d, CMD=%d, RESULT=%d",msg.msgid, cmd_id, mav_result), true)
    end
    local item = getItemByCommandID( pages[page].list, cmd_id)
    
    if item ~= nil then
      -- update status
      item.result = mav_result
      item.status = 5      
    end
  end
end

local function formatMessage(severity,msg)
  local clippedMsg = msg
  
  if #msg > 38 then
    clippedMsg = string.sub(msg,1,38)
    msg = nil
  end
  -- recover memory
  collectgarbage()
  collectgarbage()
  local txt = string.format("%02d:%s %s", status.messageCount, mavSeverity[severity], clippedMsg)
  -- recover memory
  collectgarbage()
  collectgarbage()
  return txt
end



utils.pushMessage = function(severity, msg, silent)
  status.messages[1][1] = formatMessage(severity,msg)
  status.messageCount = status.messageCount + 1
  -- recover memory
  collectgarbage()
  collectgarbage()
end

local function processTelemetry(sp)
  if sp.data_id == 0x5000 then -- MESSAGES
    if sp.value ~= status.lastMsgValue then
      status.lastMsgValue = sp.value
      local c
      local msgEnd = false
      for i=3,0,-1
      do
        c = bit32.extract(sp.value,i*8,7)
        if c ~= 0 then
          status.msgBuffer = status.msgBuffer .. string.char(c)
          -- recover memory
          collectgarbage()
          collectgarbage()
        else
          msgEnd = true;
          break;
        end
      end
      if msgEnd then
        local severity = (bit32.extract(sp.value,7,1) * 1) + (bit32.extract(sp.value,15,1) * 2) + (bit32.extract(sp.value,23,1) * 4)
        utils.pushMessage( severity, status.msgBuffer)
        status.msgBuffer = nil
        -- recover memory
        collectgarbage()
        collectgarbage()
        status.msgBuffer = ""
      end
    end
  elseif sp.data_id == 0x5007 then -- PARAMS
    local paramId = bit32.extract(sp.value,24,4)
    local paramValue = bit32.extract(sp.value,0,24)
    if paramId == 1 then -- frame type
      telemetry.frameType = paramValue
    end 
  elseif sp.data_id == 0x5003 then -- BATT
    telemetry.batt1volt = bit32.extract(sp.value,0,9)
  end
end

local function processSportData(sportPacket)
  mavLib.process_sport_rx_data(mavlite_message, mavlite_status, processMavliteMessage, sportPacket)
end

local function createMsgParamRequestRead(paramName)
    
    local msg = {
      msgid = 20,
      len = 0,
      payload = {},
      checksum = 0
    }

    mavLib.msg_set_string(msg,paramName,0)
    
    collectgarbage()
    collectgarbage()
    
    return msg
end

local function createMsgParamSet(paramName, paramValue)
    
    local msg = {
      msgid = 23,
      len = 0,
      payload = {},
      checksum = 0
    }

    mavLib.msg_set_float(msg, paramValue,0)
    mavLib.msg_set_string(msg, paramName,4)
    
    collectgarbage()
    collectgarbage()
    
    return msg
end

local function createMsgCommandLong(cmdId,params)
    
    local msg = {
      msgid = 76,
      len = 0,
      payload = {},
      checksum = 0
    }

    local options = mavLib.bit8_pack(0,#params,3,0)
    mavLib.msg_set_uint16(msg,cmdId,0)
    mavLib.msg_set_uint8(msg,options,2)
    for i=1,#params
    do
      mavLib.msg_set_float(msg,params[i],3+(4*(i-1)))
    end
    
  collectgarbage()
  collectgarbage()
    
    return msg
end

local function initPageItems(myPage)
  local items = myPage.list
  
  for idx=1,#items
  do
    if myPage.listType ~= 3 then
      if type(items[idx][2]) ~= "table" and items[idx].value ~= nil then
        -- make all digits visible even if the increment has a lower resolution!
        local precision = items[idx].label == nil and 6 or 4
        items[idx].fstring = "%.0"..tostring(math.min(precision,math.max(getDecimalCount(items[idx].value),math.max(1,getDecimalCount(items[idx][4]))))).."f %s"
        collectgarbage()
        collectgarbage()
      end
    end
    -- initialize
    if items[idx].status == nil then
      items[idx].status = myPage.listType == 3 and 0  or 1
      items[idx].timer = 0
    end
  end
  collectgarbage()
  collectgarbage()
end

-- idx is global
local function processItemsParamGet(items)
  local itemsProcessed = 0
  while idx <= #items
  do
    -- check if a refresh is needed
    if items[idx].status == 1 then
      if mavLib.queue_empty() then
        local msg = createMsgParamRequestRead(items[idx][1])
        if mavLib.queue_message(msg) == true then
          items[idx].status = 3
          items[idx].timer = getTime()
        end
      end
    end
    idx = idx + 1
    if idx > #items then
      idx = 1
    end
    -- limit the number of items of this invocation to prevent a cpu kill
    itemsProcessed = itemsProcessed + 1
    if itemsProcessed > 5 then
      break
    end
  end
  collectgarbage()
  collectgarbage()
end
--]]

local function processItemsParamSet(items)
  for i=1,#items
  do
    -- check if a refresh is needed
    if items[i].status == 2 then
      if items[i].value ~= nil then
        local value = items[i].value * (items[i].mult == nil and 1 or items[i].mult)
        
        if type(items[i][2]) == "table" then
          value = items[i][3][items[i].value]
        end
        if mavLib.queue_empty() then
          local msg = createMsgParamSet(items[i][1], value)
          
          if mavLib.queue_message(msg) == true then
            items[i].status = 3
            items[i].timer = getTime()
          end
        end
      end
    end
  end
  collectgarbage()
  collectgarbage()
end

local function processCommandSet(items)
  for i=1,#items
  do
    -- check if a refresh is needed
    if items[i].status == 2 then
      if items[i].value ~= nil then
        if mavLib.queue_empty() then
          local msg = createMsgCommandLong(items[i].cmd_id, items[i][3][items[i].value])
          if mavLib.queue_message(msg) == true then
            items[i].status = 3
            items[i].timer = getTime()
          end
        end
      end
    end
  end
  collectgarbage()
  collectgarbage()
end

local function processItemTimers(items)
  local now = getTime()
  for i=1,#items
  do
    -- check if a refresh is needed
    if items[i].status == 3 then 
      -- check timer
      if now - items[i].timer > 500 then
        items[i].status = 4
        items[i].timer = now
      end
    elseif items[i].status == 4 then
      items[i].status = 1
    end
  end
end

local function processCommandTimers(items)
  local now = getTime()
  for i=1,#items
  do
    -- check if a refresh is needed
    if items[i].status == 3 then 
      -- check timer
      if now - items[i].timer > 300 then
        items[i].status = 4
        items[i].timer = now
      end
    end
  end
end

local sendMavliteTimer = getTime()
local refreshTimer = getTime()
local uplinkTimer = getTime()
local timer2Hz = getTime()
local flushtime = getTime()

local last_frame_id
local last_data_id
local last_value

local last_mav_frame_id
local last_mav_data_id
local last_mav_value

local last_pkt = ""
local last_mav_pkt = ""

local function background()
  for i=1,30
  do
    local sensor_id, frame_id, data_id, value = sportTelemetryPop()
    
    if sensor_id  ~= nil then
      if last_frame_id ~= frame_id or last_data_id ~= data_id or last_value ~= value then
        last_frame_id = frame_id
        last_data_id = data_id
        last_value = value
        
        sportPacket.frame_id = frame_id
        sportPacket.data_id = data_id
        sportPacket.value = value
      
        if sportPacket.frame_id == 0x10 then
          status.noTelemetryData = 0
          -- no telemetry dialog only shown once
          status.hideNoTelemetry = true
          
          processTelemetry(sportPacket)
        elseif sportPacket.frame_id == 0x32 then
          -- skip mav interleaved packet copies
          if last_mav_frame_id ~= frame_id or last_mav_data_id ~= data_id or last_mav_value ~= value then
            last_mav_frame_id = frame_id
            last_mav_data_id = data_id
            last_mav_value = value
            if conf.enableDebug == true then
              utils.pushMessage(7,string.format("RX: %02X:%04X:%08X", sportPacket.frame_id, sportPacket.data_id, sportPacket.value),true)
            end
            processSportData(sportPacket)
          end
        end
      end
    end  
  end
  
  
  --[[
  if getTime() - sendMavliteTimer > 25 then
    local msg = {
      msgid = 20,
      len = 0,
      payload = {},
      checksum = 0
    }
    
    mavLib.msg_set_string(msg,"Q_ENABLE",0)
    local success = mavLib.msg_send(msg,utils)
    utils.pushMessage((success and 7 or 4),"TX: Q_ENABLE:"..(success and "OK" or "KO"))
    
    sendMavliteTimer = getTime()
  end
  --]]
  
  if getTime() - refreshTimer > 25 then
    -- process global parameters
    processItemTimers(globalParams)
    processItemsParamGet(globalParams)
    
    -- process vehicle parameters
    if pages[page] ~= nil then
      if pages[page].listType == 3 then
        processCommandTimers(pages[page].list)
        processCommandSet(pages[page].list)
      elseif pages[page].listType ~= 4 then
        -- do not process config menu items
        processItemTimers(pages[page].list)
        processItemsParamGet(pages[page].list)
        processItemsParamSet(pages[page].list)
      end
    end
    refreshTimer = getTime()
  end
  
  for i=1,5
  do
    mavLib.process_sport_tx_queue(utils, conf)
  end
  
  collectgarbage()
  collectgarbage()
end

local function isFileEmpty(filename)
  local file = io.open(filename,"r")
  if file == nil then
    return true
  end
  local str = io.read(file,10)
  io.close(file)
  if #str < 10 then
    return true
  end
  return false
end

local function searchPages(filepath, prefix, pages, pageType)
  -- look for frame specific pages
  local found = 1
  while found > 0 do
    local page = string.format("%s%s_%s_%d.lua",filepath, prefix, pageType, found)
    if isFileEmpty(page) then
      break
    end
    pages[#pages+1] = page
    found=found+1
  end
  collectgarbage()
  collectgarbage()
end

--[[
  wait for frame type from telemetry and ask for Q_PLANE if required
--]]
local function getFrameType()
  if telemetry.frameType ~= -1 then
    if frameTypes[telemetry.frameType] == "c" then
      return "copter"
    elseif frameTypes[telemetry.frameType] == "h" then
      return "heli"
    elseif frameTypes[telemetry.frameType] == "p" then
      local param = getItemByName(globalParams,"Q_ENABLE")
      if param == nil then
        globalParams[#globalParams+1] = {"Q_ENABLE"  , 0, 1, 1 ,status=1,timer=0}
      else
        if param.value ~= nil then
          if param.value > 0 then
            return "qplane"
          else
            return "plane"
          end
        end
      end
    elseif frameTypes[telemetry.frameType] == "r" or frameTypes[telemetry.frameType] == "b" then
      return "rover"
    end
  else
    drawLib.drawWarning("...detecting vehicle")
  end
  return nil
end

local function getModelFilename()
  local info = model.getInfo()
  --return "/MODELS/yaapu/" .. string.lower(string.gsub(info.name, "[%c%p%s%z]", "")..".cfg")
  return string.lower(string.gsub(info.name, "[%c%p%s%z]", ""))
end

local function searchDefaultPages(pageType,pages)
  -- look for global frametype specific
  local page = libBasePath.."default_"..pageType..".lua"
  if isFileEmpty(page) then
    return
  end
  pages[#pages+1] = libBasePath.."default_"..pageType..".lua"
end

local function initPage(pageNames, pages, idx)
  if pages[idx] ~= nil then
    return
  end
  
  if pageNames[idx] == nil then
    return
  end
  
  if idx > 0 then
    local p = loadScript(pageNames[idx])
    if p == nil then
      pages[idx] = nil
    else
      pages[idx] = p()
    end
  end
  
  if pages[idx] == nil then
    return
  end
  
  if pages[idx].list and pages[idx].listType ~= 4 then
    initPageItems(pages[idx])
  end
  
  collectgarbage()
  collectgarbage()
  maxmem = 0
end




local showMessageScreen = false
local pageSearchDone = false
local pageSearchStep = 0

local function searchAllPages(myPages)
  if telemetry.frame == nil then
    telemetry.frame = getFrameType()
  end
  
  if pageSearchStep == 0 then
    --[[
      frame specific pages:
        a) tuning pages
        b) params
        c) comnmands pages
    --]]
    if telemetry.frame ~= nil then
      if telemetry.frame == "qplane" then
        myPages[1] = libBasePath.."qplane_tune.lua"
        myPages[2] = libBasePath.."plane_tune.lua"
      else
        myPages[1] = libBasePath..telemetry.frame.."_tune.lua"
      end
      pageSearchStep = 1
    end
  elseif pageSearchStep == 1 then
    -- params pages
    searchPages(libBasePath, telemetry.frame, myPages,"params")
    if telemetry.frame == "qplane" then
      searchPages(libBasePath, "plane", myPages,"params")
    elseif telemetry.frame == "heli" then
      searchPages(libBasePath, "copter", myPages,"params")
    end
    searchDefaultPages("params", myPages)
    searchPages(cfgPath, getModelFilename(), myPages, "params")
    pageSearchStep = 2
  elseif pageSearchStep == 2 then
    -- commands pages
    searchPages(libBasePath, telemetry.frame, myPages, "commands")
    if telemetry.frame == "qplane" then
      searchPages(libBasePath, "plane", myPages, "commands")
    elseif telemetry.frame == "heli" then
      searchPages(libBasePath, "copter", myPages, "commands")
    end
    searchDefaultPages("commands", myPages)
    searchPages(cfgPath, getModelFilename(), myPages, "commands")
    pageSearchStep = 3
  elseif pageSearchStep == 3 then
    -- config pages
    myPages[#myPages+1] = libBasePath.."config_menu.lua"
    pageSearchStep = 4
  end
end

local function drawScreen(event)
  if showMessageScreen then
    drawLib.drawMessageScreen(status)
    
    if event == EVT_EXIT_BREAK or event == 516 then
      showMessageScreen = false
    end
  else
    drawLib.drawTopBar(status,telemetryEnabled,telemetry)
    if telemetryEnabled() then
      -- prevent page switch if frametype unknown
      if (event == 513 or event == EVT_PAGE_BREAK) and telemetry.frameType ~= -1 then
        utils.clearTable(pages[page])
        pages[page] = nil
        collectgarbage()
        collectgarbage()
        
        page = page + 1
        -- on page switch reset item counter
        mavLib.clear_sport_tx_queue()
        idx = 1
        
        if page > math.max(1, #pageFiles) then
          page = 1
        end
      end
      
      if pages[page] ~= nil then
        drawList(pages[page], event)
        drawLib.drawBottomBar(status)
      else
        drawLib.drawWarning("...loading")
        initPage(pageFiles, pages, page)
      end
    end
      if event == 517 then
        showMessageScreen = true
      end
  end
end

local function drawNoTelemetry()
  -- no telemetry/minmax outer box
  if telemetryEnabled() == false then
    drawLib.drawWarning("no telemetry data")
  end
end

local function calcStats()
end

local function drawStats()
end

local function clearScreen()
  lcd.clear()
end
--------------------------
-- RUN
--------------------------
local function run(event)

  calcStats()
  background()
  searchAllPages(pageFiles)
  clearScreen()
  drawScreen(event)
  drawNoTelemetry()  
  drawStats()

  return 0
end

local function init()
  -- load mavlite library
  mavLib = utils.doLibrary("mavlite")  
  drawLib = utils.doLibrary("taranis")
  -- ok done
  utils.pushMessage(7,"Yaapu LuaGCS 1.0")
  -- recover memory
  collectgarbage()
  collectgarbage()
end

--------------------------------------------------------------------------------
-- SCRIPT END
--------------------------------------------------------------------------------
return {run=run, init=init}
