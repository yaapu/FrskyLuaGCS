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


local description = "QPLANE TUNE"
local panel = true
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
  {"Q_A_RAT_RLL_P"        , 0.01, 0.5, 0.005        , x=3,y=32+43,label="P"},
  {"Q_A_RAT_RLL_I"        , 0.01, 2.0, 0.01         , x=3,y=32+59,label="I"},
  {"Q_A_RAT_RLL_D"        , 0.0, 0.05, 0.001        , x=3,y=32+75,label="D"},
  {"Q_A_RAT_PIT_P"        , 0.01, 0.5, 0.005        , x=123,y=32+43,label="P"},
  {"Q_A_RAT_PIT_I"        , 0.01, 2.0, 0.01         , x=123,y=32+59,label="I"},
  {"Q_A_RAT_PIT_D"        , 0.0, 0.05, 0.001        , x=123,y=32+75,label="D"},
  {"Q_A_RAT_YAW_P"        , 0.1, 2.5, 0.005         , x=243,y=32+43,label="P"},
  {"Q_A_RAT_YAW_I"        , 0.01, 1.0, 0.01         , x=243,y=32+59,label="I"},
  {"Q_A_RAT_YAW_D"        , 0.0, 0.02, 0.001        , x=243,y=32+75,label="D"},
  -- row 4
  {"Q_AUTOTUNE_AXES", {"All","Roll","Ptch","Yaw","R+P","R+Y","P+Y"}, {7,1,2,4,3,5,6}, x=123,y=32+184,label="Axis"},
  {"Q_AUTOTUNE_AGGR"      , 0.05, 0.1, 0.01         , x=123,y=32+200,label="Aggr"},
  {"TUNE_PARAM",{"None","RateRollPI","RateRollP","RateRollI","RateRollD","RatePitchPI","RatePitchP","RatePitchI","RatePitchD","RateYawPI","RateYawP","RateYawI","RateYawD","AngleRollP","AnglePitchP","AngleYawP","PosXYP","PosZP","VelXYP","VelXYI","VelZP","AccelZP","AccelZI","AccelZD",},{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,}},
  {"TUNE_RANGE",0,1000000,1,"",},
}

return {
  list=parameters,
  description=description,
  boxes=boxes,
  labelWidth=labelWidth,
  columnWidth=columnWidth,
  listType=2 -- tuning panel
}

