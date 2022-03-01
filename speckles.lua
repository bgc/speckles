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



-- initialization
function init()

  setupScreen()

  -- Start drawing to screen
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
  if button == 2 and state == 1 then
    theSpeckles.pages:set_index_delta(1,true)
  end
  --always have redraw at the end
  redraw()
end

-- Encoder functionality
function enc(encoder, delta)
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