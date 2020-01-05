--[[

--]]

#include "includes/ardupilot_inc.lua"
#include "includes/mavlite_inc.lua"
#include "includes/telemetry_inc.lua"
#include "includes/colors_inc.lua"

#ifdef HUDRATE
local hudcounter = 0
local hudrate = 0
local hudstart = 0
#endif

#ifdef MEMDEBUG
local maxmem = 0
#endif

--------------------------------------------------------------------------------
-- CONFIGURATION MENU
--------------------------------------------------------------------------------
local conf = {
  language = "en"
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

local msgShortRequestStatus = {
  [0] = "na", -- "na", -- NA
  [1] = "gv", -- "get",-- GV
  [2] = "sv", -- "set",-- SV
  [3] = "wt", -- "wait",-- WT
  [4] = "ex",-- EX
  [5] = "ok", -- OK
  [6] = "va",-- VA
  [7] = "rn",-- RN
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

--------------------
-- params pages
--------------------
local params = {}
local paramsPages = {}

--------------------
-- commands pages
--------------------
local commands = {}
local commandsPages = {}

-- parameters used to check specific vehicle params at boot
local globalParams = {}

--------------------
-- tuning page
--------------------
local tuning = {}
local tuningPages = {}

local basePath = "/SCRIPTS/YAAPU/"
local libBasePath = basePath.."LIB/"

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
  parse_state = PARSE_STATE_IDLE,
  current_rx_seq = 0,
  payload_next_byte = 0
}

local idx = 1 -- index of the current item being processed by processItems()
local page = 1

utils.doLibrary = function(filename)
  local f = assert(loadScript(libBasePath..filename..".lua"))
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

utils.drawBottomBar = function()
  lcd.setColor(CUSTOM_COLOR,COLOR_BARS)
  -- black bar
  lcd.drawFilledRectangle(0,BOTTOMBAR_Y+3, LCD_W, 17, CUSTOM_COLOR)
  -- message text
  local msg = status.messages[(status.messageCount + #status.messages) % (#status.messages+1)][1]
  
  if status.messages[(status.messageCount + #status.messages) % (#status.messages+1)][2] < 4 then
    lcd.setColor(CUSTOM_COLOR,lcd.RGB(255,70,0))  
  elseif status.messages[(status.messageCount + #status.messages) % (#status.messages+1)][2] == 4 then
      lcd.setColor(CUSTOM_COLOR,lcd.RGB(255,255,0))  
  else
    lcd.setColor(CUSTOM_COLOR,COLOR_TEXT)
  end
  lcd.drawText(1, LCD_H - 20, msg, CUSTOM_COLOR)
end

#ifdef TESTMODE
local function telemetryEnabled(status)
  return true
end
#else --TESTMODE
local function telemetryEnabled()
  if getRSSI() == 0 then
    status.noTelemetryData = 1
  end
  return status.noTelemetryData == 0
end
#endif --TESTMODE

local function drawWarning(text)
  lcd.setColor(CUSTOM_COLOR,COLOR_WHITE)
  lcd.drawFilledRectangle(48,74, 384, 84, CUSTOM_COLOR)
  lcd.setColor(CUSTOM_COLOR,COLOR_NOTELEM)
  lcd.drawFilledRectangle(50,76, 380, 80, CUSTOM_COLOR)
  lcd.setColor(CUSTOM_COLOR,COLOR_TEXT)
  lcd.drawText(65, 80, text, DBLSIZE+CUSTOM_COLOR)
  lcd.drawText(130, 130, VERSION, SMLSIZE+CUSTOM_COLOR)
end

local function drawBars(items)
  lcd.setColor(CUSTOM_COLOR,COLOR_BARS)
  lcd.drawFilledRectangle(0,TOPBAR_Y, LCD_W, 20, CUSTOM_COLOR)
  lcd.drawRectangle(0, TOPBAR_Y, LCD_W, 20, CUSTOM_COLOR)
  local itemIdx = string.format("%d/%d",menu.selectedItem,#items)
  lcd.setColor(CUSTOM_COLOR,COLOR_WHITE)
  lcd.drawText(LCD_W,BOTTOMBAR_Y+1,itemIdx,CUSTOM_COLOR+RIGHT)
end

local function drawMessageScreen()
  for i=0,#status.messages do
    if  status.messages[(status.messageCount + i) % (#status.messages+1)][2] == 4 then
      lcd.setColor(CUSTOM_COLOR,lcd.RGB(255,255,0))
    elseif status.messages[(status.messageCount + i) % (#status.messages+1)][2] < 4 then
      lcd.setColor(CUSTOM_COLOR,lcd.RGB(255,70,0))  
    else
      lcd.setColor(CUSTOM_COLOR,COLOR_TEXT)
    end
    lcd.drawText(0,2+13*i, status.messages[(status.messageCount + i) % (#status.messages+1)][1],SMLSIZE+CUSTOM_COLOR)
  end
end

local function incMenuItem(items,idx)
  if type(items[idx][2]) == "table" then
    items[idx].value = items[idx].value + 1
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
    items[idx].value = items[idx].value - 1
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
  collectgarbage()
  collectgarbage()
  return pos == nil and 0 or #strNum - pos
end

local function drawPanelItem(panel,idx)
  lcd.setColor(CUSTOM_COLOR,COLOR_TEXT)    
  
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

local function drawListItem(items,idx)
  lcd.setColor(CUSTOM_COLOR,COLOR_TEXT)    
  lcd.drawText(2,MENU_Y + (idx-menu.offset-1)*16, items[idx][1],CUSTOM_COLOR+SMLSIZE)
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
    lcd.drawText(280,MENU_Y + (idx-menu.offset-1)*16, "--------",flags+CUSTOM_COLOR+SMLSIZE)
  else
    if type(items[idx][2]) == "table" then -- COMBO
      lcd.drawText(280,MENU_Y + (idx-menu.offset-1)*16, items[idx][2][items[idx].value],flags+CUSTOM_COLOR+SMLSIZE)
    else
      lcd.drawText(280,MENU_Y + (idx-menu.offset-1)*16, string.format(items[idx].fstring,items[idx].value,(items[idx][5]~=nil and items[idx][5] or "")),flags+CUSTOM_COLOR+SMLSIZE)
    end
  end
  lcd.drawText(LCD_W-2,MENU_Y + (idx-menu.offset-1)*16, msgRequestStatus[items[idx].status],flags+CUSTOM_COLOR+SMLSIZE+RIGHT)
end

local function drawCommandItem(items,idx)
  lcd.setColor(CUSTOM_COLOR,COLOR_TEXT)    
  lcd.drawText(2,MENU_Y + (idx-menu.offset-1)*16, items[idx][1],CUSTOM_COLOR+SMLSIZE)
  
  if idx == menu.selectedItem then
    if menu.editSelected then
        flags = INVERS+BLINK
    else
      flags = INVERS
    end
  else
    flags = 0
  end
  
  lcd.drawText(280,MENU_Y + (idx-menu.offset-1)*16, items[idx][2][items[idx].value],flags+CUSTOM_COLOR+SMLSIZE)
  
  if items[idx].result == nil then
    lcd.drawText(LCD_W-2,MENU_Y + (idx-menu.offset-1)*16, msgRequestStatus[items[idx].status],flags+CUSTOM_COLOR+SMLSIZE+RIGHT)
  else
    lcd.drawText(LCD_W-2,MENU_Y + (idx-menu.offset-1)*16, mavResult[items[idx].result],flags+CUSTOM_COLOR+SMLSIZE+RIGHT)
  end
end

local function writeItem(idxToSave)
  if page <= #tuningPages then
    tuning[page].list[idxToSave].status = STATUS_SET_REQUEST
  elseif page <= ( #tuningPages + #paramsPages ) then
    params[page - #tuningPages].list[idxToSave].status = STATUS_SET_REQUEST
  else
    commands[page - (#tuningPages + #paramsPages)].list[idxToSave].result = nil
    commands[page - (#tuningPages + #paramsPages)].list[idxToSave].status = STATUS_SET_REQUEST
  end
  -- force this item as next to be processed
  idx = idxToSave
end

local function drawList(params,event)
  local items = params.list
  drawBars(items)
  if event == EVT_ENTER_BREAK then
    if menu.editSelected == true then
      -- confirm modified value
      writeItem(menu.selectedItem)
    else
      -- save last value for undo
      items[menu.selectedItem].lastValue = items[menu.selectedItem].value
    end
    if items[menu.selectedItem].value ~= nil then
      menu.editSelected = not menu.editSelected
      menu.updated = true
    else
      -- trigger refresh
      if items[menu.selectedItem].status == STATUS_IDLE or items[menu.selectedItem].status == STATUS_DONE or items[menu.selectedItem].status == STATUS_WAIT_EXPIRED then
        items[menu.selectedItem].status = STATUS_GET_REQUEST
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
    if menu.selectedItem - MENU_PAGESIZE > menu.offset then
      menu.offset = menu.offset + 1
    end
  end
  --wrap
  if menu.selectedItem > #items then
    menu.selectedItem = 1 
    menu.offset = 0
  elseif menu.selectedItem  < 1 then
    menu.selectedItem = #items
    menu.offset =  math.max(0,#items - MENU_PAGESIZE)
  end
  
  if params.listType == nil then -- paramters
  -- draw list
    for m=1+menu.offset,math.min(#items,MENU_PAGESIZE+menu.offset) do
      lcd.setColor(CUSTOM_COLOR,COLOR_TEXT)   
      drawListItem(items,m)
    end
  elseif params.listType == 2 then -- tuning panels
  -- draw list
    for m=1,#items do
      lcd.setColor(CUSTOM_COLOR,COLOR_TEXT)   
      drawPanelItem(params,m)
    end
  -- draw boxes
    for b=1,#params.boxes do
      lcd.setColor(CUSTOM_COLOR,params.boxes[b].color)   
      lcd.drawRectangle(params.boxes[b].x,params.boxes[b].y,params.boxes[b].width,params.boxes[b].height,CUSTOM_COLOR)
      lcd.setColor(CUSTOM_COLOR,COLOR_BLACK)   
      lcd.drawFilledRectangle(params.boxes[b].x+5,params.boxes[b].y-10,params.boxes[b].width-10,14,CUSTOM_COLOR)
      lcd.setColor(CUSTOM_COLOR,COLOR_WHITE)   
      lcd.drawText(params.boxes[b].x+8,params.boxes[b].y-12,params.boxes[b].label,CUSTOM_COLOR+SMLSIZE)
    end
  elseif params.listType == 3 then -- commands
  -- draw list
    for m=1+menu.offset,math.min(#items,MENU_PAGESIZE+menu.offset) do
      lcd.setColor(CUSTOM_COLOR,COLOR_TEXT)   
      drawCommandItem(items,m)
    end
  end
  -- page title
  lcd.setColor(CUSTOM_COLOR,COLOR_WHITE)
  lcd.drawText(0,0,string.format("%s - %d/%d",params.description, page, #paramsPages+#tuningPages+#commandsPages),CUSTOM_COLOR)
end

#ifdef COMPILE
local function compile()
  local files = {
    "mavlite",
    "default_params",
    "default_commands",
    
    "plane_tune",
    "qplane_tune",
    
    "copter_tune",
    "heli_tune",
    "rover_tune",
  }
  
  -- compile all layouts for all panes
  for i=1,#files do
    loadScript(libBasePath..files[i]..".lua","c")
  end
end
#endif

local function processMavliteMessage(msg)
  if msg.msgid == 23 then
    local param_value = mavLib.msg_get_float(msg,0)
    local param_name = mavLib.msg_get_string(msg,4)
#ifdef TELEMETRY_DEBUG
    utils.pushMessage(7,string.format("RX: ID=%d, %s : %f",msg.msgid,param_name,param_value))
#endif
  elseif msg.msgid == 22 then -- PARAM_VALUE
    local param_value = mavLib.msg_get_float(msg,0)
    local param_name = mavLib.msg_get_string(msg,4)

    utils.pushMessage(7,string.format("RX: ID=%d, %s : %f",msg.msgid,param_name,param_value))
    
    local item = getItemByName(globalParams,param_name)
    
    if item == nil then
      local paramsPage = (page <= #tuningPages and tuning[page] or params[page-#tuningPages])
      if paramsPage  ~= nil then
        item = getItemByName(page <= #tuningPages and tuning[page].list or params[page-#tuningPages].list,param_name)
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
        item.status = success == true and STATUS_DONE or STATUS_UNDEF_INDEX
      else
        item.value = param_value * (item.mult == nil and 1 or 1/item.mult)
        -- make all digits visible even if the increment has a lower resolution!
        -- when in panel mode precision is limited to 4 just like MP
        local precision = item.label == nil and 6 or 4
        
        item.fstring = "%.0"..tostring(math.min(precision,math.max(getDecimalCount(item.value),math.max(1,getDecimalCount(item[4]))))).."f %s"
        if item.value < item[2] or item.value > item[3] then
          -- update status
          item.status = STATUS_OUT_OF_RANGE
        else
          -- update status
          item.status = STATUS_DONE
        end
      end
    end
    
    collectgarbage()
    collectgarbage()
  elseif msg.msgid == 77 then -- CMD_ACK
    local cmd_id = mavLib.msg_get_uint16(msg,0)
    local mav_result = mavLib.msg_get_uint8(msg,2)

    utils.pushMessage(7,string.format("RX: ID=%d, CMD=%d, RESULT=%d",msg.msgid, cmd_id, mav_result))
    
    local item = getItemByCommandID( commands[page-(#tuningPages + #paramsPages)].list, cmd_id)
    
    if item ~= nil then
      -- update status
      item.result = mav_result
      item.status = STATUS_DONE      
    end
  end
end

local function formatMessage(severity,msg)
  local clippedMsg = msg
  
  if #msg > 50 then
    clippedMsg = string.sub(msg,1,50)
    msg = nil
    collectgarbage()
    collectgarbage()
  end
  
  if status.lastMessageCount > 1 then
    return string.format("%02d:%s (x%d) %s", status.messageCount, mavSeverity[severity], status.lastMessageCount, clippedMsg)
  else
    return string.format("%02d:%s %s", status.messageCount, mavSeverity[severity], clippedMsg)
  end
end

utils.getBitmap = function(name)
  if bitmaps[name] == nil then
    bitmaps[name] = Bitmap.open("/SCRIPTS/YAAPU/IMAGES/"..name..".png")
  end
  return bitmaps[name],Bitmap.getSize(bitmaps[name])
end

utils.unloadBitmap = function(name)
  if bitmaps[name] ~= nil then
    bitmaps[name] = nil
    -- force call to luaDestroyBitmap()
    collectgarbage()
    collectgarbage()
  end
end

utils.drawBlinkBitmap = function(bitmap,x,y)
  if blinkon == true then
      lcd.drawBitmap(utils.getBitmap(bitmap),x,y)
  end
end

utils.playSound = function(soundFile,skipHaptic)
  playFile(soundFileBasePath .."/"..conf.language.."/".. soundFile..".wav")
end

utils.pushMessage = function(severity, msg, silent)
  if silent == nil then
    if severity < 5 then
      utils.playSound("../err",true)
    else
      utils.playSound("../inf",true)
    end
  end
  
  if msg == status.lastMessage then
    status.lastMessageCount = status.lastMessageCount + 1
  else  
    status.lastMessageCount = 1
    status.messageCount = status.messageCount + 1
  end
  if status.messages[(status.messageCount-1) % MAX_MESSAGES] == nil then
    status.messages[(status.messageCount-1) % MAX_MESSAGES] = {}
  end
  status.messages[(status.messageCount-1) % MAX_MESSAGES][1] = formatMessage(severity,msg)
  status.messages[(status.messageCount-1) % MAX_MESSAGES][2] = severity
  
  status.lastMessage = msg
  status.lastMessageSeverity = severity
  -- Collect Garbage
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
    paramId = bit32.extract(sp.value,24,4)
    paramValue = bit32.extract(sp.value,0,24)
    if paramId == 1 then -- frame type
      telemetry.frameType = paramValue
    end 
#ifndef FULL_TELEMETRY
  end
#else
  elseif sp.data_id == 0x5006 then -- ROLLPITCH
    -- roll [0,1800] ==> [-180,180]
    telemetry.roll = (math.min(bit32.extract(sp.value,0,11),1800) - 900) * 0.2
    -- pitch [0,900] ==> [-90,90]
    telemetry.pitch = (math.min(bit32.extract(sp.value,11,10),900) - 450) * 0.2
    -- number encoded on 11 bits: 10 bits for digits + 1 for 10^power
    telemetry.range = bit32.extract(sp.value,22,10) * (10^bit32.extract(sp.value,21,1)) -- cm
  elseif sp.data_id == 0x5005 then -- VELANDYAW
    telemetry.vSpeed = bit32.extract(sp.value,1,7) * (10^bit32.extract(sp.value,0,1)) * (bit32.extract(sp.value,8,1) == 1 and -1 or 1)-- dm/s 
    telemetry.hSpeed = bit32.extract(sp.value,10,7) * (10^bit32.extract(sp.value,9,1)) -- dm/s
    telemetry.yaw = bit32.extract(sp.value,17,11) * 0.2
  elseif sp.data_id == 0x5001 then -- AP STATUS
    telemetry.flightMode = bit32.extract(sp.value,0,5)
    telemetry.simpleMode = bit32.extract(sp.value,5,2)
    telemetry.landComplete = bit32.extract(sp.value,7,1)
    telemetry.statusArmed = bit32.extract(sp.value,8,1)
    telemetry.battFailsafe = bit32.extract(sp.value,9,1)
    telemetry.ekfFailsafe = bit32.extract(sp.value,10,2)
    -- IMU temperature: 0 means temp =< 19°, 63 means temp => 82°
    telemetry.imuTemp = bit32.extract(sp.value,26,6) + 19 -- C°
  elseif sp.data_id == 0x5002 then -- GPS STATUS
    telemetry.numSats = bit32.extract(sp.value,0,4)
    -- offset  4: NO_GPS = 0, NO_FIX = 1, GPS_OK_FIX_2D = 2, GPS_OK_FIX_3D or GPS_OK_FIX_3D_DGPS or GPS_OK_FIX_3D_RTK_FLOAT or GPS_OK_FIX_3D_RTK_FIXED = 3
    -- offset 14: 0: no advanced fix, 1: GPS_OK_FIX_3D_DGPS, 2: GPS_OK_FIX_3D_RTK_FLOAT, 3: GPS_OK_FIX_3D_RTK_FIXED
    telemetry.gpsStatus = bit32.extract(sp.value,4,2) + bit32.extract(sp.value,14,2)
    telemetry.gpsHdopC = bit32.extract(sp.value,7,7) * (10^bit32.extract(sp.value,6,1)) -- dm
    telemetry.gpsAlt = bit32.extract(sp.value,24,7) * (10^bit32.extract(sp.value,22,2)) * (bit32.extract(sp.value,31,1) == 1 and -1 or 1)-- dm
  elseif sp.data_id == 0x5003 then -- BATT
    telemetry.batt1volt = bit32.extract(sp.value,0,9)
    -- telemetry max is 51.1V, 51.2 is reported as 0.0, 52.3 is 0.1...60 is 88
    -- if 12S and V > 51.1 ==> Vreal = 51.2 + telemetry.batt1volt
    if conf.cell1Count == 12 and telemetry.batt1volt < 240 then
      -- assume a 2Vx12 as minimum acceptable "real" voltage
      telemetry.batt1volt = 512 + telemetry.batt1volt
    end
    telemetry.batt1current = bit32.extract(sp.value,10,7) * (10^bit32.extract(sp.value,9,1))
    telemetry.batt1mah = bit32.extract(sp.value,17,15)
  elseif sp.data_id == 0x5008 then -- BATT2
    telemetry.batt2volt = bit32.extract(sp.value,0,9)
    -- telemetry max is 51.1V, 51.2 is reported as 0.0, 52.3 is 0.1...60 is 88
    -- if 12S and V > 51.1 ==> Vreal = 51.2 + telemetry.batt1volt
    if conf.cell2Count == 12 and telemetry.batt2volt < 240 then
      -- assume a 2Vx12 as minimum acceptable "real" voltage
      telemetry.batt2volt = 512 + telemetry.batt2volt
    end
    telemetry.batt2current = bit32.extract(sp.value,10,7) * (10^bit32.extract(sp.value,9,1))
    telemetry.batt2mah = bit32.extract(sp.value,17,15)
  elseif sp.data_id == 0x5004 then -- HOME
    telemetry.homeDist = bit32.extract(sp.value,2,10) * (10^bit32.extract(sp.value,0,2))
    telemetry.homeAlt = bit32.extract(sp.value,14,10) * (10^bit32.extract(sp.value,12,2)) * 0.1 * (bit32.extract(sp.value,24,1) == 1 and -1 or 1)
    telemetry.homeAngle = bit32.extract(sp.value, 25,  7) * 3
  elseif sp.data_id == 0x5007 then -- PARAMS
    paramId = bit32.extract(sp.value,24,4)
    paramValue = bit32.extract(sp.value,0,24)
    if paramId == 1 then
      telemetry.frameType = paramValue
    elseif paramId == 4 then
      telemetry.batt1Capacity = paramValue
    elseif paramId == 5 then
      telemetry.batt2Capacity = paramValue
    elseif paramId == 6 then
      telemetry.wpCommands = paramValue
    end 
  elseif sp.data_id == 0x5009 then -- WAYPOINTS @1Hz
    telemetry.wpNumber = bit32.extract(sp.value,0,10) -- wp index
    telemetry.wpDistance = bit32.extract(sp.value,12,10) * (10^bit32.extract(sp.value,10,2)) -- meters
    telemetry.wpXTError = bit32.extract(sp.value,23,4) * (10^bit32.extract(sp.value,22,1)) * (bit32.extract(sp.value,27,1) == 1 and -1 or 1)-- meters
    telemetry.wpBearing = bit32.extract(sp.value,29,3) -- offset from cog with 45° resolution 
  elseif sp.data_id == 0x50F2 then -- VFR
    telemetry.airspeed = bit32.extract(sp.value,1,7) * (10^bit32.extract(sp.value,0,1)) -- dm/s
    telemetry.throttle = bit32.extract(sp.value,8,7)
    telemetry.baroAlt = bit32.extract(sp.value,17,10) * (10^bit32.extract(sp.value,15,2)) * 0.1 * (bit32.extract(sp.value,27,1) == 1 and -1 or 1)
  end
#endif
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

    mavLib.msg_set_flota(msg, paramValue,0)
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

local function initParams(items)
  for idx=1,#items
  do
    if type(items[idx][2]) ~= "table" and items[idx].value ~= nil then
      -- make all digits visible even if the increment has a lower resolution!
      local precision = items[idx].label == nil and 6 or 4
      items[idx].fstring = "%.0"..tostring(math.min(precision,math.max(getDecimalCount(items[idx].value),math.max(1,getDecimalCount(items[idx][4]))))).."f %s"
      collectgarbage()
      collectgarbage()
    end
    -- initialize
    if items[idx].status == nil then
      items[idx].status = STATUS_GET_REQUEST
      items[idx].timer = 0
    end
  end
end

local function initCommands(items)
  for idx=1,#items
  do
    if items[idx].status == nil then
      items[idx].status = STATUS_IDLE
      items[idx].timer = 0
    end
  end
end

--[[
  Process max MAX_ITEMS_PER_CYCLE items async
  idx is global so it passes all items in separate invocations to prevent cpu kill
--]]
local function processItemsParamGet(items)
  local now = getTime()
  local itemsProcessed = 1
  while idx <= #items
  do
#ifdef TESTMODE    
    -- fake Q_ENABLE debug only
    if items[idx][1] == "Q_ENABLE" then
      items[idx].value = 1.0
      return
    end
#endif
    -- check if a refresh is needed
    if items[idx].status == STATUS_GET_REQUEST then
      local msg = createMsgParamRequestRead(items[idx][1])
      if mavLib.msg_send(msg,utils) == true then
        items[idx].status = STATUS_WAIT_RESPONSE
        items[idx].timer = getTime()
      end
      utils.clearTable(msg)
      msg = nil
    end
    idx = idx + 1
    if idx > #items then
      idx = 1
    end
    -- limit the number of items of this invocation to prevent a cpu kill
    itemsProcessed = itemsProcessed + 1
    if itemsProcessed > MAX_ITEMS_PER_CYCLE then
      break
    end
  end
  collectgarbage()
  collectgarbage()
end

local function processItemsParamSet(items)
  for i=1,#items
  do
    -- check if a refresh is needed
    if items[i].status == STATUS_SET_REQUEST then
      if items[i].value ~= nil then
        local value = items[i].value * (items[i].mult == nil and 1 or items[i].mult)
        
        if type(items[i][2]) == "table" then
          value = items[i][3][items[i].value]
        end
        
        local msg = createMsgParamSet(items[i][1], value)
        --utils.pushMessage(7,"SET: "..items[i][1].." = "..tostring(value))
        if mavLib.msg_send(msg,utils) == true then
          items[i].status = STATUS_WAIT_RESPONSE
          items[i].timer = getTime()
        end
        utils.clearTable(msg)
        msg = nil
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
    if items[i].status == STATUS_SET_REQUEST then
      if items[i].value ~= nil then
        
        local msg = createMsgCommandLong(items[i].cmd_id, items[i][3][items[i].value])
        print(string.format("cmd_id=%d, param_count=%d",items[i].cmd_id, #items[i][3][items[i].value]))
        if mavLib.msg_send(msg,utils) == true then
          items[i].status = STATUS_WAIT_RESPONSE
          items[i].timer = getTime()
        end
        
        utils.clearTable(msg)
        msg = nil
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
    if items[i].status == STATUS_WAIT_RESPONSE then 
      -- check timer
      if now - items[i].timer > 1000 then
        items[i].status = STATUS_WAIT_EXPIRED
        items[i].timer = now
      end
    elseif items[i].status == STATUS_WAIT_EXPIRED then
      items[i].status = STATUS_GET_REQUEST
    end
  end
end

local function processCommandTimers(items)
  local now = getTime()
  for i=1,#items
  do
    -- check if a refresh is needed
    if items[i].status == STATUS_WAIT_RESPONSE then 
      -- check timer
      if now - items[i].timer > 300 then
        items[i].status = STATUS_WAIT_EXPIRED
        items[i].timer = now
      end
    end
  end
end

local sendMavliteTimer = getTime()

local refreshTimer = 0

local function background()
  for i=1,TELEMETRY_LOOPS
  do
    local sensor_id,frame_id,data_id,value = sportTelemetryPop()
    
    if sensor_id  ~= nil then
      
      sportPacket.sensor_id = sensor_id
      sportPacket.frame_id = frame_id
      sportPacket.data_id = data_id
      sportPacket.value = value
      
      if sportPacket.frame_id == SPORT_DATA_FRAME then
        status.noTelemetryData = 0
        -- no telemetry dialog only shown once
        status.hideNoTelemetry = true
        
        processTelemetry(sportPacket)
      elseif sportPacket.frame_id == SPORT_DOWNLINK_FRAME then
#ifdef TELEMETRY_DEBUG
        utils.pushMessage(7,string.format("%04X:%08X",sportPacket.data_id,sportPacket.value))
#endif        
        processSportData(sportPacket)
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
    if tuning[page] ~= nil then
        processItemTimers(tuning[page].list)
        processItemsParamGet(tuning[page].list)
        processItemsParamSet(tuning[page].list)
    elseif params[page-#tuningPages] ~= nil then
        processItemTimers(params[page-#tuningPages].list)
        processItemsParamGet(params[page-#tuningPages].list)
        processItemsParamSet(params[page-#tuningPages].list)
    elseif commands[page-(#tuningPages+#paramsPages)] ~= nil then
        processCommandTimers(commands[page-(#tuningPages+#paramsPages)].list)
        processCommandSet(commands[page-(#tuningPages+#paramsPages)].list)
    end
    
    refreshTimer = getTime()
  end
  -- send pending packets
  mavLib.process_sport_tx_queue(utils)
  -- blinking support
  if (getTime() - blinktime) > 65 then
    blinkon = not blinkon
    blinktime = getTime()
  end
  collectgarbage()
  collectgarbage()
end


local function initFrameSpecificPages(frameName)
  -- look for frame specific pages
  local found = 1
  
  while found > 0 do
    local page = string.format("/SCRIPTS/YAAPU/CFG/%s_params_%d.lua",frameName,found)
    
    local file = io.open(page,"r")
    
    if file == nil then
      break
    end
    io.close(file)
    paramsPages[#paramsPages+1] = page
    utils.pushMessage(7,paramsPages[#paramsPages])
    found=found+1
  end
  collectgarbage()
  collectgarbage()
end

local searchFrameParams = true

local function loadFrameSpecificPages()
  if tuning[page] ~= nil then
    return
  end
  
  local frame = "plane"
  
  if telemetry.frameType ~= -1 then
    if frameTypes[telemetry.frameType] == "c" then
      tuningPages[1] = "copter_tune"
      frame = "copter"
    elseif frameTypes[telemetry.frameType] == "h" then
      tuningPages[1] = "heli_tune"
      frame = "heli"
    elseif frameTypes[telemetry.frameType] == "p" then
      local param = getItemByName(globalParams,"Q_ENABLE")
      
      if param == nil then
        globalParams[#globalParams+1] = {"Q_ENABLE"  , 0, 1, 1 ,status=STATUS_GET_REQUEST,timer=0}
      else
        if param.value ~= nil then
          if param.value > 0 then
            tuningPages[1] = "plane_tune"
            tuningPages[2] = "qplane_tune"
            frame = "qplane"
          else
            tuningPages[1] = "plane_tune"
            frame = "plane"
          end
        end
      end
    elseif frameTypes[telemetry.frameType] == "r" or frameTypes[telemetry.frameType] == "b" then
      tuningPages[1] = "rover_tune"
      frame = "rover"
    end
    
    if tuningPages[page] ~= nil then
      if page <= #tuningPages then 
        tuning[page] = utils.doLibrary(tuningPages[page])
      end
      
      if tuning[page].list then
        initParams(tuning[page].list)
      end
      
      collectgarbage()
      collectgarbage()
      maxmem = 0
      
      if searchFrameParams == true then
        initFrameSpecificPages(frame)
        searchFrameParams = false
      end
    end
  end
end

local function getModelFilename()
  local info = model.getInfo()
  return "/SCRIPTS/YAAPU/CFG/" .. string.lower(string.gsub(info.name, "[%c%p%s%z]", ""))
end

local function createEmptyModelFiles()
  -- create the default model parameters file only if missing
  local pf = assert(io.open(getModelFilename().."_params_1.lua","a+"))
  if pf ~= nil then
    io.close(pf)
  end
  
  local pf = assert(io.open(getModelFilename().."_commands_1.lua","a+"))
  if pf ~= nil then
    io.close(pf)
  end
end

local function initParamsPages()
  -- look for global frametype specific
  paramsPages[#paramsPages+1] = libBasePath.."default_params.lua"
  utils.pushMessage(7,paramsPages[#paramsPages])
  
  -- look for model specific pages
  local found = 1
  
  while found > 0 do
    local page = string.format("%s_params_%d.lua",getModelFilename(),found)
    
    local file = io.open(page,"r")
    
    if file == nil then
      break
    end
    local str = io.read(file,10)
    io.close(file)
    if #str == 0 then
      break
    end
    paramsPages[#paramsPages+1] = page
    utils.pushMessage(7,paramsPages[#paramsPages])
    found=found+1
  end
  collectgarbage()
  collectgarbage()
end

local function loadParamsPages()
  if params[page-#tuningPages] ~= nil then
    return
  end
  
  if page > #tuningPages then
    local p = loadScript(paramsPages[page-#tuningPages])
    if p == nil then
      params[page-#tuningPages] = nil
    else
      params[page-#tuningPages] = p()
    end
    collectgarbage()
    collectgarbage()
  end
  
  if params[page-#tuningPages].list then
    initParams(params[page-#tuningPages].list)
  end
  
  maxmem = 0
end

local function initCommandsPages()
  -- look for global frametype specific
  commandsPages[#commandsPages+1] = libBasePath.."default_commands.lua"
  utils.pushMessage(7,commandsPages[#commandsPages])
  
  -- look for model specific command pages
  local found = 1
  
  while found > 0 do
    local page = string.format("%s_commands_%d.lua",getModelFilename(),found)
    
    local file = io.open(page,"r")
    
    if file == nil then
      break
    end
    local str = io.read(file,10)
    io.close(file)
    if #str == 0 then
      break
    end
    commandsPages[#commandsPages+1] = page
    utils.pushMessage(7,commandsPages[#commandsPages])
    found=found+1
  end
  collectgarbage()
  collectgarbage()
end

local function loadCommandsPages()
  if commands[page-(#tuningPages+#paramsPages)] ~= nil then
    return
  end
  if page > (#tuningPages+#paramsPages) then
    local p = loadScript(commandsPages[page-(#tuningPages+#paramsPages)])
    if p == nil then
      commands[page-(#tuningPages+#paramsPages)] = nil
    else
      commands[page-(#tuningPages+#paramsPages)] = p()
    end
    collectgarbage()
    collectgarbage()
  end
  
  if commands[page-(#tuningPages+#paramsPages)].list then
    initCommands(commands[page-(#tuningPages+#paramsPages)].list)
  end
  
  maxmem = 0
end

local showMessageScreen = false
--------------------------
-- RUN
--------------------------
local function run(event)
#ifdef HUDRATE
  ------------------------
  -- CALC HUD REFRESH RATE
  ------------------------
  local hudnow = getTime()
  if hudcounter == 0 then
    hudstart = hudnow
  else
    hudrate = hudrate*0.8 + 100*(hudcounter/(hudnow - hudstart + 1))*0.2
  end
  hudcounter=hudcounter+1
  if hudnow - hudstart + 1 > 1000 then
    hudcounter = 0
  end
#endif --HUDRATE  
  background()
  if showMessageScreen == true then
    lcd.setColor(CUSTOM_COLOR, COLOR_BLACK)
  else
    lcd.setColor(CUSTOM_COLOR, COLOR_BG)
  end
  lcd.clear(CUSTOM_COLOR)
  ---------------------
  -- DRAW ITEMS
  ---------------------  
  if showMessageScreen then
    drawMessageScreen()
    
    if event == EVT_EXIT_BREAK or event == 516 then
      showMessageScreen = false
    end
  else
    -- prevent page switch if frametype unknown
    if event == 513 and telemetry.frameType ~= -1 then
      
#ifndef CACHE_TUNING      
      utils.clearTable(tuning[page])
      tuning[page] = nil
#endif
#ifndef CACHE_PARAMS      
      utils.clearTable(params[page-#tuningPages])
      params[page-#tuningPages] = nil
#endif      
      collectgarbage()
      collectgarbage()
      -- on page swithc clear tx queue
      mavLib.clear_tx_queue()
      
      page = page+1
      -- on page switch reset item counter
      idx = 1
      
      if page > (math.max(1,#commandsPages) + math.max(1,#paramsPages) + #tuningPages) then
        page = 1
      end
      
    end
    
    utils.drawBottomBar()
    
    if page <= #tuningPages or #tuningPages == 0 then --from 0 to #tuningPages ==> display tuning pages
      if tuning[page] ~= nil then
        drawList(tuning[page], event)
      else
        if telemetry.frameType ~= -1 then
          drawWarning("...loading")
        else
          drawWarning("...getting vehicle type")
        end
        loadFrameSpecificPages()
      end
    elseif page > #tuningPages and page <= (#tuningPages + #paramsPages) then  -- from #tuningPages + 1 to #tuningPages + #paramPages ==> display param pages
      if params[page-#tuningPages] ~= nil then
        drawList(params[page-#tuningPages], event)
      else
        drawWarning("...loading")
        loadParamsPages()
      end
    elseif page > (#tuningPages + #paramsPages) then  -- from #tuningPages + #paramPages ==> display commands pages
      if commands[page-(#tuningPages + #paramsPages)] ~= nil then
        drawList(commands[page-(#tuningPages + #paramsPages)], event)
      else
        drawWarning("...loading")
        loadCommandsPages()
      end
    end
    
    if event == 517 then
      showMessageScreen = true
    end
  end
  
  -- no telemetry/minmax outer box
  if telemetryEnabled() == false then
    utils.drawBlinkBitmap("warn",0,0)  
  end

#ifdef HUDRATE    
  lcd.setColor(CUSTOM_COLOR,COLOR_YELLOW)
  local hudrateTxt = string.format("%.1ffps",hudrate)
  lcd.drawText(480,3,hudrateTxt,SMLSIZE+CUSTOM_COLOR+RIGHT)
#endif --HUDRATE
#ifdef MEMDEBUG
  lcd.setColor(CUSTOM_COLOR,lcd.RGB(255,0,0))
  maxmem = math.max(maxmem,collectgarbage("count")*1024)
  -- test with absolute coordinates
  lcd.drawNumber(450,LCD_H-14,maxmem,SMLSIZE+MENU_TITLE_COLOR+RIGHT)
#endif
#ifdef DEBUGEVT
  if event > 0 then
    utils.pushMessage(7,tostring(event))
  end
#endif
  return 0
end

local function init()
#ifdef COMPILE
  compile()
#endif
  -- if missing create a template file for parameters and commands
  createEmptyModelFiles()
  
  -- load mavlite library
  mavLib = utils.doLibrary("mavlite")  
  
  -- look for general and model specific param pages
  initParamsPages()
  -- look for general and model specific command pages
  initCommandsPages()
    
  #ifdef PLANE
  telemetry.frameType = 1
  #endif
  
  #ifdef COPTER
  telemetry.frameType = 2
  #endif
  
  #ifdef HELI
  telemetry.frameType = 4
  #endif
  
  #ifdef ROVER
  telemetry.frameType = 10
  #endif
  
  #ifdef BOAT
  telemetry.frameType = 11
  #endif
  
  #ifdef QPLANE
  telemetry.frameType = 20
  #endif
  
  -- ok done
  utils.pushMessage(7,VERSION)
  
  collectgarbage()
  collectgarbage()
end

--------------------------------------------------------------------------------
-- SCRIPT END
--------------------------------------------------------------------------------
return {run=run, init=init}