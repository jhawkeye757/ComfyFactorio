local Event = require 'utils.event'

-- Function to set global effects on all surfaces
local function set_global_effect()
    for _, surface in pairs(game.surfaces) do
        surface.global_effect = {quality = 0.1}
    end

    -- Unregister the on_tick event after execution
    script.on_event(defines.events.on_tick, nil)
end

return {
    Event.on_init(set_global_effect)
}
