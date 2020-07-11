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


----------------------
--- COLORS
----------------------

--#define COLOR_LABEL 0x7BCF
--#define COLOR_BG 0x0169




local maxmem = 0

--------------------------------------------------------------------------------
-- CONFIGURATION MENU
--------------------------------------------------------------------------------
local utils = {}

local status = {
  messages = {},
  messageCount = 0,
  msgBuffer = "",
  lastMsgValue = 0,
  lastMessageCount = 0,
}


-- default is 
local cfgPath = "/MODELS/yaapu/"
local basePath = "/SCRIPTS/TOOLS/yaapu/"
local libBasePath = basePath
-- check if HORUS
if LCD_W > 212 then -- HORUS
  cfgPath = "/SCRIPTS/YAAPU/CFG/"
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

local function formatMessage(msg)
  local clippedMsg = msg
  if LCD_W > 212 then
    -- HORUS
    if #msg > 50 then
      clippedMsg = string.sub(msg,1,50)
      msg = nil
    end
  elseif LCD_W > 128 then
    --  class
    if #msg > 38 then
      clippedMsg = string.sub(msg,1,38)
      msg = nil
    end
  else
    -- X7 class
    if #msg > 24 then
      clippedMsg = string.sub(msg,1,24)
      msg = nil
    end
  end
  collectgarbage()
  collectgarbage()
  local txt = nil
  if status.lastMessageCount > 1 then
    txt = string.format("%02d:(x%d) %s", status.messageCount, status.lastMessageCount, clippedMsg)
  else
    txt = string.format("%02d:%s", status.messageCount, clippedMsg)
  end
  collectgarbage()
  collectgarbage()
  return txt
end

local function pushMessage(msg)
  if msg == status.lastMessage then
    status.lastMessageCount = status.lastMessageCount + 1
  else  
    status.lastMessageCount = 1
    status.messageCount = status.messageCount + 1
  end
  status.messages[(status.messageCount-1) % 9] = formatMessage(msg)
  status.lastMessage = msg
  -- Collect Garbage
  collectgarbage()
  collectgarbage()
end

local function drawMessageScreen()
  if LCD_W > 212 then
    lcd.setColor(CUSTOM_COLOR,0xFFFF)
    for i=0,#status.messages do
      lcd.drawText(0,2+13*i, status.messages[(status.messageCount + i) % (#status.messages+1)],SMLSIZE+CUSTOM_COLOR)
    end
  else
    for i=0,#status.messages do
      lcd.drawText(1,1+7*i, status.messages[(status.messageCount + i) % (#status.messages+1)],SMLSIZE)
    end
  end
end

local function getModelName()
  local info = model.getInfo()
  return string.lower(string.gsub(info.name, "[%c%p%s%z]", ""))
end

local function getModelFilename()
  return cfgPath .. getModelName()
end

local function createEmptyFiles(pageType)
  local pf = assert(io.open(getModelFilename().."_"..pageType.."_1.lua","a+"))
  if pf ~= nil then
    io.close(pf)
  end
  
  pf = assert(io.open(basePath.."qplane_"..pageType.."_1.lua","a+"))
  if pf ~= nil then
    io.close(pf)
  end
  
  pf = assert(io.open(basePath.."plane_"..pageType.."_1.lua","a+"))
  if pf ~= nil then
    io.close(pf)
  end
  
  pf = assert(io.open(basePath.."copter_"..pageType.."_1.lua","a+"))
  if pf ~= nil then
    io.close(pf)
  end
  
  pf = assert(io.open(basePath.."heli_"..pageType.."_1.lua","a+"))
  if pf ~= nil then
    io.close(pf)
  end
  
  pf = assert(io.open(basePath.."rover_"..pageType.."_1.lua","a+"))
  if pf ~= nil then
    io.close(pf)
  end
end

-- pageType to [params|commands]
local function compileDefaultPages(pageType)
  local page = string.format(libBasePath.."default_%s.lua", pageType)
  local tmp = loadScript(page)
  utils.clearTable(tmp)
  collectgarbage()
  collectgarbage()
  pushMessage(string.format("GLOBAL: default_%s.lua", pageType))
end

local function compileTuningPages()
  local frames = {"plane","qplane","copter","rover","heli"}
  for f=1,#frames do
    local page = string.format(libBasePath.."%s_tune.lua", frames[f])
    local tmp = loadScript(page)
    utils.clearTable(tmp)
    collectgarbage()
    collectgarbage()
    pushMessage(string.format("TUNE: %s_tune.lua", frames[f]))
  end
  collectgarbage()
  collectgarbage()
end

-- pageType to [params|commands]
local function compileFramePages(pageType)
  local frames = {"plane","qplane","copter","rover","heli"}
  for f=1,#frames do
    local found = 1
    while found > 0 do
      local page = string.format(libBasePath.."%s_%s_%d.lua", frames[f], pageType, found)
      local file = io.open(page,"r")
      if file == nil then
        break
      end
      io.close(file)
      tmp = loadScript(page)
      utils.clearTable(tmp)
      collectgarbage()
      collectgarbage()
      pushMessage(string.format("FRAME: %s_%s_%d.lua", frames[f], pageType, found))
      found=found+1
    end
  end
  collectgarbage()
  collectgarbage()
end

-- pageType to [params|commands]
local function compileModelPages(pageType)
  -- look for model specific pages
  local found = 1
  
  while found > 0 do
    page = string.format("%s_%s_%d.lua", getModelFilename(), pageType, found)
    local file = io.open(page,"r")
    if file == nil then
      break
    end
    io.close(file)
    tmp = loadScript(page)
    utils.clearTable(tmp)
    collectgarbage()
    collectgarbage()
    pushMessage(string.format("MODEL: %s_%s_%d.lua", getModelName(), pageType, found))
    found=found+1
  end
  
end

--------------------------
-- RUN
--------------------------
local function run(event)
  if LCD_W > 212 then
    lcd.setColor(CUSTOM_COLOR, 0x0AB1)
    lcd.clear(CUSTOM_COLOR)
  else
    lcd.clear()
  end
  
  drawMessageScreen(status)
  
  if LCD_W > 212 then
    lcd.setColor(CUSTOM_COLOR,lcd.RGB(255,0,0))
    maxmem = math.max(maxmem,collectgarbage("count")*1024)
    -- test with absolute coordinates
    lcd.drawNumber(LCD_W, LCD_H-14, maxmem,SMLSIZE+MENU_TITLE_COLOR+RIGHT)
  else
  maxmem = math.max(maxmem,collectgarbage("count")*1024)
  lcd.drawNumber(LCD_W, LCD_H-7, maxmem,SMLSIZE+INVERS+RIGHT)
  end
  collectgarbage()
  collectgarbage()
  return 0
end

local function init()
  pushMessage("Yaapu LuaGCS 0.9-dev")
  compileDefaultPages("params")
  compileDefaultPages("commands")
  compileTuningPages()
  compileFramePages("params");
  compileFramePages("commands");
  compileModelPages("params")
  compileModelPages("commands")
  createEmptyFiles("params")
  createEmptyFiles("commands")
end

--------------------------------------------------------------------------------
-- SCRIPT END
--------------------------------------------------------------------------------
return {run=run, init=init}
