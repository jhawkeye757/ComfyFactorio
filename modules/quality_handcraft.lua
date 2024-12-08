local Event = require 'utils.event'
local quality_init = require("quality_init") -- Import the quality_init module

-- Probability for quality progression (default 1%)
local QUALITY_PROGRESSION_PROBABILITY = .02 -- 2% chance as a decimal

-- Handle handcrafting quality progression
local function on_player_crafted_item(event)
    local player = game.get_player(event.player_index)
    local crafted_stack = event.item_stack

    if player and crafted_stack.valid_for_read and crafted_stack.quality ~= nil then
        -- Calculate quality progression using quality_init
        local initial_quality = crafted_stack.quality
        local result_quality = quality_init.calculate_quality(initial_quality, QUALITY_PROGRESSION_PROBABILITY)

        -- Update the crafted item with new quality
        crafted_stack.set_stack({
            name = crafted_stack.name,
            count = crafted_stack.count,
            health = crafted_stack.health,
            quality = result_quality.name
        })

        -- Notify player (optional)
        -- player.print({"", "Crafted item with quality: ", result_quality.localised_name})
    end
end

-- Handle mining quality progression
local function on_player_mined_entity(event)
    local player = game.get_player(event.player_index)
    local mined_entity = event.entity

    if player and mined_entity and (mined_entity.type == "resource" or mined_entity.type == "tree" or mined_entity.type == "simple-entity" or mined_entity.type == "fish") then
        for i = 1, #event.buffer do
            local dropped_stack = event.buffer[i]
            if dropped_stack.valid_for_read and dropped_stack.quality ~= nil then
                -- Calculate quality progression using quality_init
                local initial_quality = dropped_stack.quality
                local result_quality = quality_init.calculate_quality(initial_quality, QUALITY_PROGRESSION_PROBABILITY)

                -- Update the mined item with new quality
                dropped_stack.set_stack({
                    name = dropped_stack.name,
                    count = dropped_stack.count,
                    quality = result_quality.name
                })

                -- Notify player (optional)
                -- player.print({"", "Mined resource with quality: ", result_quality.localised_name})
            end
        end
    end
end

-- Register event handlers using the Event system
Event.add(defines.events.on_player_crafted_item, on_player_crafted_item)
Event.add(defines.events.on_player_mined_entity, on_player_mined_entity)

return {}
