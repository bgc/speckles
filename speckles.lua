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
-- https://github.com/bgc/speckles
-- llllllll.co/t/???????????
--
-- General Controls:
-- Encoder 1 - Volume
-- Button 1 - Standard norns
-- function
-- Button 3 - Change screen
--
-- All others are screen
-- dependant
--
-- SCREEN 1
-- Encoder 2 - speckles density
-- Encoder 3 - Panning
-- Button 2 - Toggle main Reverb
--
-- SCREEN 2
-- Encoder 2 - filter freq
-- Encoder 3 - filter resonance
-- Button 2 - filter type
-- 0 - none
-- 1 - low pass
-- 2 - band pass
-- 3 - high pass
--
-- SCREEN 3
-- Encoder 2 - LFO rate
-- Encoder 3 - LFO amount
-- Button 2 - N.A.
--
-----------------------------------



-- Setup engine
engine.name = "Speckles"

-- Imports
local UI = require "ui"
local ControlSpec = require "controlspec"
local fGraph = require "filtergraph"

-- Engine Global
theSpeckles = {}
theSpeckles.oscUI = {}
theSpeckles.filterUI = {}
theSpeckles.lfoUI = {}

-- libs
local speckles_lib = include "lib/speckles-lib"

-- Globals
local SCREEN_FRAMERATE = 15
local screen_refresh_metro



local function setupScreen()
    screen.level(15)
    screen.aa(0)
    screen.line_width(1)
    screen.font_face(1)
    screen.font_size(8)
end

available_screens = {'Osc', 'Filter', 'LFO', 'Help'}

local function setupUI()
    theSpeckles.tabs = UI.Tabs.new(1, available_screens)
    -- UI.Dial.new (x, y, size, value, min_value, max_value, rounding, start_value, markers, units, title)
    theSpeckles.oscUI.freq = UI.Dial.new(12, 34, 20, params:get('density'), 0.01, 440, 0.01, 1, {}, 'i/s')
    theSpeckles.oscUI.panning = UI.Dial.new(58, 34, 20, params:get('panning'), -1, 1, 0.01, 0, {-1, 0, 1}, '')
    theSpeckles.oscUI.reverb_states = {'OFF', 'ON'}
    theSpeckles.oscUI.reverb = UI.List.new(94, 34, params:get('reverb'), theSpeckles.oscUI.reverb_states)

    theSpeckles.filterUI.filters = {"disabled", "lowpass", "bandpass", "highpass"}
    theSpeckles.filterUI.filter = fGraph.new()
    theSpeckles.filterUI.filter:set_active(false)
    theSpeckles.filterUI.filter:set_position_and_size(2, 22, 66, 34)
    theSpeckles.filterUI.filterTypes = UI.List.new(74, 22, 1, theSpeckles.filterUI.filters)

    theSpeckles.lfoUI.rate = UI.Dial.new(12, 34, 20, params:get('rate'), 0.01, 20, 0.01, 1, {}, 'hz')
    theSpeckles.lfoUI.amount = UI.Dial.new(58, 34, 20, params:get('amount'), 0, 1, 0.01, 0, {}, '')
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
    local screen = theSpeckles.tabs.index

    -- button 2  is shared amongst screens
    if button == 3 and state == 1 then
        theSpeckles.tabs:set_index_delta(1, true)
    end
    if screen == 1 then
        if button == 2 and state == 1 then
            local current = params:get("reverb")
            if current == 2 then
                params:set("reverb", 1)
                theSpeckles.oscUI.reverb:set_index(1)
            else
                params:set("reverb", 2)
                theSpeckles.oscUI.reverb:set_index(2)
            end
        end
    end

    if screen == 2 then
        if button == 2 and state == 1 then
            handleFilterTypeControl()
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

    local screen = theSpeckles.tabs.index

    -- handle encoder 2
    if encoder == 2 then
        -- screen 1 encoder 2 is the engine density
        if screen == 1 then
            params:delta("density", delta)
            theSpeckles.oscUI.freq:set_value(params:get("density"))
        end
        -- screen 2 encoder 2 is filter frequency
        if screen == 2 then
            local currentFilterType = theSpeckles.filterUI.filter:filter_type()
            local filterSlope = theSpeckles.filterUI.filter:get_slope()
            local resonance = params:get("reso")
            params:delta("filter_freq", delta) 
            local filterFreq = params:get("filter_freq")
            theSpeckles.filterUI.filter:edit(currentFilterType, filterSlope, filterFreq, resonance)
        end
        -- screen 3 encoder 3 is LFO rate
        if screen == 3 then
            params:delta("rate", delta)
            theSpeckles.lfoUI.rate:set_value(params:get("rate"))
        end
    end

    -- handle encoder 3
    if encoder == 3 then
        -- screen 1 encoder 3 is the engine panning
        if screen == 1 then
            params:delta("panning", delta)
            theSpeckles.oscUI.panning:set_value(params:get("panning"))
        end
        -- screen 2 encoder 3 is filter resonance
        if screen == 2 then
            local currentFilterType = theSpeckles.filterUI.filter:filter_type()
            local filterSlope = theSpeckles.filterUI.filter:get_slope()
            local filterFreq = theSpeckles.filterUI.filter:get_freq()
            params:delta("reso", delta)
            local resonance = params:get("reso")
            theSpeckles.filterUI.filter:edit(currentFilterType, filterSlope, filterFreq, resonance)
        end
        -- screen 3 encoder 3 is LFO amount
        if screen == 3 then
            params:delta("amount", delta)
            theSpeckles.lfoUI.amount:set_value(params:get("amount"))
        end
    end

    -- always have redraw at the end
    redraw()
end

-- Screen functionality
function redraw()
    -- clear screen
    screen.clear()

    -- redraw tabs control
    local activeTab = theSpeckles.tabs.index
    theSpeckles.tabs:redraw() -- redraw tabs

    if activeTab == 1 then
        screen.move(7, 28)
        screen.text("Density")
        screen.stroke()
        screen.close()
        theSpeckles.oscUI.freq:redraw()
        screen.move(52, 28)
        screen.text("Panning")
        screen.stroke()
        screen.close()
        theSpeckles.oscUI.panning:redraw()
        screen.move(94, 28)
        screen.text("Reverb")
        screen.stroke()
        screen.close()
        theSpeckles.oscUI.reverb:redraw()
    elseif activeTab == 2 then
        printFilterValues()
        theSpeckles.filterUI.filterTypes:redraw()
        if theSpeckles.filterUI.filter:get_active() then
            theSpeckles.filterUI.filter:redraw()
        end
    elseif activeTab == 3 then
        screen.move(7, 28)
        screen.text("Rate")
        screen.stroke()
        screen.close()
        theSpeckles.lfoUI.rate:redraw()
        screen.move(52, 28)
        screen.text("Amount")
        screen.stroke()
        screen.close()
        theSpeckles.lfoUI.amount:redraw()
    -- Render Instructions on last page
    elseif activeTab == 4 then
        -- found in ./lib/speckles-lib
        drawInstructions()
    end

    screen.update()
end

function cleanup()
    -- deinitialization
end
