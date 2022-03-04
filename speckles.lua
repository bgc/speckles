-----------------------------------
--
-- Early dampish leap
-- A faithful, giant dog chirps
-- whilst watching the snake
--
-- ↓ Instructions & Disclaimer ↓ 
-----------------------------------
-- scriptname: speckles
-- Dust2 based engine,
-- because I like Dust2
-- v0.0.1 by: 
-- @bgc
-- as part of
-- illusory discontinuity
-- https://illusorydiscontinuity.com
-- llllllll.co/t/???????????
--
-- General Controls:
-- Encoder 1 - Volume
-- Button 1 - Standard norns
-- function
-- Button 2 - Change Page
--
-- All others are page
-- dependant
-----------------------------------

-- Setup engine
engine.name = "Speckles"

--Imports
local UI = require "ui"
local ControlSpec = require "controlspec"

-- libs
local speckles_lib = include "lib/speckles-lib"


-- Globals
local SCREEN_FRAMERATE = 15
local screen_refresh_metro

local theSpeckles = {}
theSpeckles.pages = UI.Pages.new(1,2)

local function setupScreen()
  screen.level(15)
  screen.aa(0)
  screen.line_width(1)
  screen.font_face(1)
  screen.font_size(8)
end

local function setupControls()

  -- Param / Controlspec for amplitude
  params:add{
    type="control",
    id="amp",
    controlspec=controlspec.new(
      0, --minVal
      1, --maxVal
      "linear", --warp (exp, db, lin)
      0, -- step (rounded)
      1, --default initial value
      "" --units
    ),
    action=engine.amp,
  }

  -- Param / Controlspec for engine frequency
  params:add{
    type="control",
    id="freq",
    controlspec=controlspec.new(
      0.01, --minVal
      180, --maxVal
      "exp", --warp (exp, db, lin)
      0, -- step (rounded)
      1, --default initial value
      "Hz" --units
    ),
    action=engine.freq,
  }

  -- filter type lp/hp
  params:add_number("filter", "filter", 0, 3, 0)
  params:set_action("filter", function(v) engine.filter(v) end)
  
  params:add{
    type="control",
    id="filter_freq",
    controlspec=controlspec.new(
      0.01, --minVal
      20000, --maxVal
      "exp", --warp (exp, db, lin)
      0, -- step (rounded)
      440, --default initial value
      "Hz" --units
    ),
    action=engine.filter_freq,
  }
  params:add{
    type="control",
    id="reso",
    controlspec=controlspec.new(
      0, --minVal
      1, --maxVal
      "lin", --warp (exp, db, lin)
      0.01, -- step (rounded)
      0, --default initial value
      "" --units
    ),
    action=engine.reso,
  }
  -- params:add_control("filter_freq", "filter_freq", controlspec.WIDEFREQ)
  -- params:set_action("filter_freq", function(v) engine.filter_freq(v) end)

  -- params:add_control("reso", "reso", controlspec.RQ)
  -- params:set_action("reso", function(v) engine.reso(v) end)

end

-- initialization
function init()
  engine.list_commands()
  setupScreen()
  setupControls()


  -- Start drawing to screen (after all the inits)
  screen_refresh_metro = metro.init()
  screen_refresh_metro.event = function()
    if screen_dirty then
      screen_dirty = false
      redraw()
    end
  end
  screen_refresh_metro:start(1 / SCREEN_FRAMERATE)
end


--Keys functionality 
function key(button, state)
  local screen = theSpeckles.pages.index

  if button == 2 and state == 1 then
    theSpeckles.pages:set_index_delta(1,true)
  end
  if screen == 2 then
    print("screen 2")
    if button == 3 and state == 1 then
      local value = params:get("filter")
      print("filter value ")
      print(value)
      if value == 3 then
        params:set("filter", 0)
        print('setting filter to: ')
        print(params:get("filter"))
      else
        params:set("filter", value + 1)
        print('setting filter to: ')
        print(params:get("filter"))
      end
    end
  end
  --always have redraw at the end
  redraw()
end

-- Encoder functionality
function enc(encoder, delta)
  -- encoder 1 is shared amongst screens
  if encoder == 1 then
    params:delta("amp", delta)
  end

  local screen = theSpeckles.pages.index
  
  if screen == 1 then
    if encoder == 2 then
      params:delta("freq", delta)
    end
  end

    if screen == 2 then
    if encoder == 2 then
      params:delta("filter_freq", delta)
    end
    if encoder == 3 then
      params:delta("reso", delta)
    end
  end
  --always have redraw at the end
  redraw()
end

-- Screen functionality
function redraw()
  -- clear screen
  screen.clear()
  theSpeckles.pages:redraw()

  -- Render Instructions on last page
  if theSpeckles.pages.index == 2 then
    drawInstructions()
  end
  screen.update()
end

function cleanup()
  -- deinitialization
end