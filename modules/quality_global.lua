local Event = require 'utils.event'

-- Function to set global effects on all surfaces
local function set_global_effect()
    for _, surface in pairs(game.surfaces) do
        surface.global_effect = {quality = 0.2}
    end

    -- Unregister the on_tick event after execution
    script.on_event(defines.events.on_tick, nil)
end

-- Function to handle newly created surfaces
local function on_surface_created(event)
    local surface = game.surfaces[event.surface_index]
    if surface then
        surface.global_effect = {quality = 0.2}
    end
end

-- Register the function for relevant events
return {
    Event.on_init(set_global_effect),
    Event.add(defines.events.on_surface_created, on_surface_created)
}
