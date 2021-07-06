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


local description = "PLANE TUNE"
local labelWidth = 83
local columnWidth = 160
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
  {"RLL_RATE_P"     , 0.08, 0.35, 0.005     , x=5,y=32+2,label="P"},
  {"RLL_RATE_I"     , 0.01, 0.6, 0.01       , x=5,y=32+18,label="I"},
  {"RLL_RATE_D"     , 0.001, 0.03, 0.001    , x=5,y=32+34,label="D"},

  {"PTCH_RATE_P"    , 0.08, 0.35, 0.005     , x=165,y=32+2,label="P"},
  {"PTCH_RATE_I"    , 0.01, 0.6, 0.01       , x=165,y=32+18,label="I"},
  {"PTCH_RATE_D"    , 0.001, 0.03, 0.001    , x=165,y=32+34,label="D"},
  
  {"YAW2SRV_SLIP"   , 0, 4.0, 0.25        , x=325,y=32+2,label="SLIP"},
  {"YAW2SRV_INT"    , 0.0, 2.0, 0.25      , x=325,y=32+18,label="INT"},
  {"YAW2SRV_DAMP"   , 0.0, 2.0, 0.25      , x=325,y=32+34,label="DAMP"},

  {"LIM_ROLL_CD"    , 0, 90, 1            , x=325,y=32+167,label="Bank Max",mult=100},
  {"LIM_PITCH_MIN"  , -90, 0, 1           , x=325,y=32+183,label="Pitch Min",mult=100},
  {"LIM_PITCH_MAX"  , 0, 90, 1            , x=325,y=32+199,label="Pitch Max",mult=100},
  {"TUNE_PARAM",{"None","FixedWingRollP","FixedWingRollI","FixedWingRollD","FixedWingRollFF","FixedWingPitchP","FixedWingPitchI","FixedWingPitchD","FixedWingPitchFF","Set_RateRollPitch","Set_RateRoll","Set_RatePitch","Set_RateYaw","Set_AngleRollPitch","Set_VelXY","Set_AccelZ",},{0,50,51,52,53,54,55,56,57,101,102,103,104,105,106,107,}},
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

