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
#define VERSION "Yaapu Ardupilot Lua 0.2-dev"
-- load and compile of lua files
--#define LOADSCRIPT
#ifdef LOADSCRIPT
#define LOAD_LUA
#endif
-- uncomment to force compile of all chunks, comment for release
--#define COMPILE
#ifdef COMPILE
#define LOAD_LUA
#endif
-- fix for issue OpenTX 2.2.1 on X10/X10S - https://github.com/opentx/opentx/issues/5764
#define X10_OPENTX_221

---------------------
-- MAVLITE CONFIG
---------------------
#define TELEMETRY_LOOPS 20

---------------------
-- DEV FEATURE CONFIG
---------------------
-- enable events debug
--#define DEBUGEVT
-- cache tuning pages
#define CACHE_TUNING
-- cache params pages
#define CACHE_PARAMS
-- enable full telemetry debug
--#define TELEMETRY_DEBUG
-- enable full telemetry decoding
--#define FULL_TELEMETRY
-- enable memory debuging 
#define MEMDEBUG
-- enable dev code
--#define DEV
-- use radio channels imputs to generate fake telemetry data
--#define TESTMODE
#ifdef TESTMODE
#endif

---------------------
-- DEBUG REFRESH RATES
---------------------
-- calc and show hud refresh rate
#define HUDRATE
-- calc and show telemetry process rate
#define BGTELERATE

#define TOPBAR_Y 0
#define TOPBAR_HEIGHT 20
#define TOPBAR_WIDTH LCD_W

#define BOTTOMBAR_Y LCD_H-20
#define BOTTOMBAR_HEIGHT 20
#define BOTTOMBAR_WIDTH LCD_W
#define MAX_MESSAGES 20

--------------------------------------------------------------------------------
-- MENU VALUE,COMBO
--------------------------------------------------------------------------------
#define TYPEVALUE 0
#define TYPECOMBO 1
#define MENU_Y 25
#define MENU_PAGESIZE 14
#define MENU_ITEM_X 300

-----------------------
-- LIBRARY LOADING
-----------------------
#ifdef LOAD_LUA
#define loadMenuLib() dofile(basePath..menuLibFile..".lua")
#else
#define loadMenuLib() dofile(basePath..menuLibFile..".luac")
#endif

--[[
  status of pending mavlite messages
]]--
#define STATUS_IDLE 0 
#define STATUS_GET_REQUEST 1
#define STATUS_SET_REQUEST 2
#define STATUS_WAIT_RESPONSE 3
#define STATUS_WAIT_EXPIRED 4
#define STATUS_DONE 5
#define STATUS_UNDEF_INDEX 6
#define STATUS_OUT_OF_RANGE 7

#define MAX_ITEMS_PER_CYCLE 1

