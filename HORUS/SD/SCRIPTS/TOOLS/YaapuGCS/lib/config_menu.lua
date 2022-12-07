local description = "Config"

local parameters = {
  -- {"Numerical value", 1, 10, 1, value=0, code="NUM", fstring="%d rpm"},
  {"disable msg beep",{"no","info","all"}, {1, 2, 3}, value = 2, code= "S2", property="disableMsgBeep"},
  {"enable debug info",{"yes","no"},{true, false}, value = 2, code= "DBG", property="enableDebug"},
  {"disable range checks",{"no","yes"}, {false, true}, value = 1, code= "RN", property="disableRangeChecks"},
  {"version ".." ("..'de4a4dc'..")",{"1.2.0 dev ("..'de4a4dc'..")"}, {true}, value = 1, code= "V", property="version"},
}

return {
  list = parameters,
  description = description,
  listType = 4 -- config  
}

