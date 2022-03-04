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
--
-- PAGE 1
-- Encoder 2 - speckles density
-- PAGE 2
-- Encoder 2 - filter freq
-- Encoder 3 - filter resonance
-- Button 3 - filter type
-- 0 - none
-- 1 - low pass
-- 2 - band pass
-- 3 - high pass
-----------------------------------
-- Setup engine
engine.name = "Speckles"

-- Imports
local UI = require "ui"
local ControlSpec = require "controlspec"

-- libs
local speckles_lib = include "lib/speckles-lib"

-- Globals
local SCREEN_FRAMERATE = 15
local screen_refresh_metro

local theSpeckles = {}
theSpeckles.pages = UI.Pages.new(1, 2)

local oscUI = {}

local function setupScreen()
    screen.level(15)
    screen.aa(0)
    screen.line_width(1)
    screen.font_face(1)
    screen.font_size(8)
end

local function setupUI()
    -- UI.Dial.new (x, y, size, value, min_value, max_value, rounding, start_value, markers, units, title)
    oscUI.freq = UI.Dial.new(12, 34, 20, params:get('density'), 0.01, 440, 0.01, 1, {}, 'i/s')
end

-- initialization
function init()
    engine.list_commands()
    setupScreen()
    -- found in ./lib/speckles-lib
    setupControls()
    setupUI()

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

-- Keys functionality 
function key(button, state)
    local screen = theSpeckles.pages.index

    -- button 2  is shared amongst screens
    if button == 2 and state == 1 then
        theSpeckles.pages:set_index_delta(1, true)
    end

    if screen == 2 then
        if button == 3 and state == 1 then
            local value = params:get("filter")
            if value == 3 then
                params:set("filter", 0)
            else
                params:set("filter", value + 1)
            end
        end
    end
    -- always have redraw at the end
    redraw()
end

-- Encoder functionality
function enc(encoder, delta)
    -- encoder 1 is shared amongst screens
    if encoder == 1 then
        params:delta("amp", delta)
    end

    local screen = theSpeckles.pages.index

    -- handle encoder 2
    if encoder == 2 then
        -- screen 1 encoder 2 is the engine density
        if screen == 1 then
            params:delta("density", delta)
            oscUI.freq:set_value(params:get("density"))
        end
        -- screen 2 encoder 2 is filter frequency
        if screen == 2 then
            params:delta("filter_freq", delta)
        end
    end

    -- handle encoder 3
    if encoder == 3 then
        -- screen 2 encoder 3 is filter resonance
        if screen == 2 then
            params:delta("reso", delta)
        end
    end

    -- always have redraw at the end
    redraw()
end

-- Screen functionality
function redraw()
    -- clear screen
    screen.clear()

    -- redraw pages control
    theSpeckles.pages:redraw()

    if theSpeckles.pages.index == 1 then
        screen.move(7, 31)
        screen.text("Density")
        screen.stroke()
        screen.close()
        oscUI.freq:redraw()
    end

    -- Render Instructions on last page
    if theSpeckles.pages.index == 2 then
        -- found in ./lib/speckles-lib
        drawInstructions()
    end

    screen.update()
end

function cleanup()
    -- deinitialization
end
