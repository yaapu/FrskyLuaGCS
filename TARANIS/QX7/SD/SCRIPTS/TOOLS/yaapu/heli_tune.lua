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


local description = "HELI TUNE"
local labelWidth = 54
local columnWidth = 120
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
  
  -- row 2
  {"ATC_RAT_RLL_P"        , 0.08, 0.35, 0.005       , x=3,y=32+43,label="P"},
  {"ATC_RAT_RLL_I"        , 0.01, 0.6, 0.01         , x=3,y=32+59,label="I"},
  {"ATC_RAT_RLL_D"        , 0.001, 0.03, 0.0005     , x=3,y=32+75,label="D"},
  
  {"ATC_RAT_PIT_P"        , 0.08, 0.35, 0.005       , x=123,y=32+43,label="P"},
  {"ATC_RAT_PIT_I"        , 0.01, 0.6, 0.01         , x=123,y=32+59,label="I"},
  {"ATC_RAT_PIT_D"        , 0.001, 0.03, 0.0005     , x=123,y=32+75,label="D"},
  
  {"ATC_RAT_YAW_P"        , 0.18, 0.6, 0.005        , x=243,y=32+43,label="P"},
  {"ATC_RAT_YAW_I"        , 0.01, 0.06, 0.01        , x=243,y=32+59,label="I"},
  {"ATC_RAT_YAW_D"        , 0.0, 0.02, 0.0005       , x=243,y=32+75,label="D"},
}

return {
  list=parameters,
  description=description,
  boxes=boxes,
  labelWidth=labelWidth,
  columnWidth=columnWidth,
  listType=2 -- tuning panel
}

