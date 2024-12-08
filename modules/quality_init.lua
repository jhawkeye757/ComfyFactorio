local Event = require 'utils.event'

local function initialize_quality()
    if not global then global = {} end
    if not global.NORMAL_QUALITY then
        local surface = game.surfaces["nauvis"]
        local force = game.forces["player"]
        local spawn_position = force.get_spawn_position(surface)
        local position = surface.find_non_colliding_position("character", spawn_position, 32, 1) or spawn_position
        local temp_character = surface.create_entity({
            name = "character",
            position = position,
            force = force,
            create_build_effect_smoke = false,
            quality = "normal"
        })
        global.NORMAL_QUALITY = temp_character.quality
        temp_character.destroy()
    end
    if game.forces["player"] then
        game.forces["player"].unlock_quality("uncommon")
    end
end

-- Function to calculate quality progression
local function calculate_quality(initial_quality, probability)
    local current_quality = initial_quality
    local cumulative_probability = probability
    local random_value = math.random()

    while random_value <= cumulative_probability do
        if current_quality.next ~= nil and game.forces["player"].is_quality_unlocked(current_quality.next.name) then
            current_quality = current_quality.next
            cumulative_probability = cumulative_probability * probability
        else
            break
        end
    end

    return current_quality
end

-- Register the initialization function using the event handler
Event.on_init(initialize_quality)

-- Expose the `calculate_quality` function for other modules
return {
    calculate_quality = calculate_quality
}
