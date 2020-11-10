local description = "Config"

local parameters = {
  -- {"Numerical value", 1, 10, 1, value=0, code="NUM", fstring="%d rpm"},
  {"disable msg beep",{"no","info","all"}, {1, 2, 3}, value = 2, code= "S2", property="disableMsgBeep"},
  {"enable debug info",{"yes","no"},{true, false}, value = 2, code= "DBG", property="enableDebug"}
}

return {
  list = parameters,
  description = description,
  listType = 4 -- config  
}

