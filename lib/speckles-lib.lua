---
-- helpers for Speckles
---
function setupControls()
    params:add_separator("Oscillator")
    -- Param / Controlspec for amplitude
    params:add{
        type = "control",
        id = "amp",
        controlspec = controlspec.new(0, -- minVal
        1, -- maxVal
        "linear", -- warp (exp, db, lin)
        0, -- step (rounded)
        1, -- default initial value
        "" -- units
        ),
        action = engine.amp
    }

    -- Param / Controlspec for engine density
    params:add{
        type = "control",
        id = "density",
        controlspec = controlspec.new(0.01, -- minVal
        440, -- maxVal
        "exp", -- warp (exp, db, lin)
        0, -- step (rounded)
        1, -- default initial value
        "Hz" -- units
        ),
        action = engine.density
    }

    params:add_separator("Filter")
    -- filter type lp/hp
    params:add_number("filter", "filter", 0, 3, 0)
    params:set_action("filter", function(v)
        engine.filter(v)
    end)

    params:add{
        type = "control",
        id = "filter_freq",
        controlspec = controlspec.new(0.01, -- minVal
        20000, -- maxVal
        "exp", -- warp (exp, db, lin)
        0, -- step (rounded)
        440, -- default initial value
        "Hz" -- units
        ),
        action = engine.filter_freq
    }
    params:add{
        type = "control",
        id = "reso",
        controlspec = controlspec.new(0, -- minVal
        1, -- maxVal
        "lin", -- warp (exp, db, lin)
        0.01, -- step (rounded)
        0, -- default initial value
        "" -- units
        ),
        action = engine.reso
    }
    -- params:add_control("filter_freq", "filter_freq", controlspec.WIDEFREQ)
    -- params:set_action("filter_freq", function(v) engine.filter_freq(v) end)

    -- params:add_control("reso", "reso", controlspec.RQ)
    -- params:set_action("reso", function(v) engine.reso(v) end)
    params:add_separator()

end

--
-- General Controls:
-- Encoder 1 - Volume
-- Button 1 - Standard norns
-- function
-- Button 2 - Change Page

function drawInstructions()
    screen.move(1, 8)
    screen.text("CONTROLS")
    screen.stroke()
    screen.close()

    screen.move(1, 18)
    screen.text("E1 - Volume")
    screen.stroke()
    screen.close()

    screen.move(1, 28)
    screen.text("B2 - Change Page")
    screen.stroke()
    screen.close()

    screen.move(1, 38)
    screen.text("B3, E2, E3 Page dependant")
    screen.stroke()
    screen.close()
end

-- Handles the changing of filter type with button 3 on page 2
function handleFilterTypeControl()
    local value = params:get("filter")
    if value == 3 then
      -- so it wraps!
        params:set("filter", 0)
    else
        params:set("filter", value + 1)
    end
    -- we get the new value in order to update UI
    local updatedValue = params:get("filter")
    -- the +1 is cause Lua uses 1 based index...
    -- update the current filterType UI
    theSpeckles.filterUI.filterTypes:set_index(updatedValue + 1)
    if updatedValue ~= 0 then
      -- set it active if not disabled
      local filterTypeIndex = theSpeckles.filterUI.filterTypes.index
      theSpeckles.filterUI.filter:set_active(true)
      -- update the filter graph with new type
      theSpeckles.filterUI.filter:edit(theSpeckles.filterUI.filters[filterTypeIndex])
    else
      -- disabled we do not want the filter graph active
      theSpeckles.filterUI.filter:set_active(false)
    end
end
