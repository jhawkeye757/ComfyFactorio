local Event = require 'utils.event'
local quality_init = require("quality_init") -- Import the quality_init module

-- Function to handle the on_entity_spawned event
local function on_entity_spawned(event)
    local spawned_entity = event.entity
    local spawner = event.spawner

    if spawned_entity and spawner then
        -- Fetch the evolution factor for the surface
        local surface = spawned_entity.surface
        local evolution_factor = game.forces["enemy"].get_evolution_factor(surface)
        local enemy_quality_probability = evolution_factor * 0.5

        -- Calculate quality progression using quality_init
        local initial_quality = spawner.quality or global.NORMAL_QUALITY
        local result_quality = quality_init.calculate_quality(initial_quality, enemy_quality_probability)

        if result_quality.name ~= spawner.quality then
            -- Replace entity with upgraded quality
            local position = spawned_entity.position
            local force = spawned_entity.force
            local name = spawned_entity.name

            -- Destroy the original entity
            spawned_entity.destroy()

            -- Create a replacement entity with the desired quality
            surface.create_entity({
                name = name,
                position = position,
                force = force,
                quality = result_quality
            })
        end
    end
end

-- Register the event handler using the Event module
Event.add(defines.events.on_entity_spawned, on_entity_spawned)

-- Expose the module (optional, if needed for other modules)
return {}
