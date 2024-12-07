-- Initialize the scenario
script.on_init(function()
    -- Unlock uncommon quality for the player's force
    if game.forces["player"] then
        game.forces["player"].unlock_quality("uncommon")
    end
end)

-- Probability for quality progression (default 1%)
local QUALITY_PROGRESSION_PROBABILITY = 0.01 -- 1% chance as a decimal


-- Handle handcrafting quality progression
script.on_event(defines.events.on_player_crafted_item, function(event)
    local player = game.get_player(event.player_index)
    local crafted_stack = event.item_stack

    if player and crafted_stack.valid_for_read and crafted_stack.quality ~= nil then
        local current_quality = crafted_stack.quality
        local random_value = math.random()

        -- Calculate quality progression
        local cumulative_probability = QUALITY_PROGRESSION_PROBABILITY
        while random_value <= cumulative_probability do
            if current_quality.next ~= nil and player.force.is_quality_unlocked(current_quality.next.name) then
                current_quality = current_quality.next
                cumulative_probability = cumulative_probability * QUALITY_PROGRESSION_PROBABILITY
            else
                break
            end
        end

        -- Update the crafted item with new quality
        crafted_stack.set_stack({
            name = crafted_stack.name,
            count = crafted_stack.count,
            health = crafted_stack.health,
            quality = current_quality.name
        })

        -- Notify player
        --player.print({"", "Crafted item with quality: ", current_quality.localised_name})
    end
end)

-- Handle mining quality progression
script.on_event(defines.events.on_player_mined_entity, function(event)
    local player = game.get_player(event.player_index)
    local mined_entity = event.entity

    if player and mined_entity and (mined_entity.type == "resource" or mined_entity.type == "tree" or mined_entity.type == "simple-entity" or mined_entity.type == "fish") then
        for i = 1, #event.buffer do
            local dropped_stack = event.buffer[i]
            if dropped_stack.valid_for_read and dropped_stack.quality ~= nil then
                local current_quality = dropped_stack.quality
                local random_value = math.random()

                -- Calculate quality progression
                local cumulative_probability = QUALITY_PROGRESSION_PROBABILITY
                while random_value <= cumulative_probability do
                    if current_quality.next ~= nil and player.force.is_quality_unlocked(current_quality.next.name) then
                        current_quality = current_quality.next
                        cumulative_probability = cumulative_probability * QUALITY_PROGRESSION_PROBABILITY
                    else
                        break
                    end
                end

                -- Update the mined item with new quality
                dropped_stack.set_stack({
                    name = dropped_stack.name,
                    count = dropped_stack.count,
                    quality = current_quality.name
                })

                -- Notify player
                --player.print({"", "Mined resource with quality: ", current_quality.localised_name})
            end
        end
    end
end)
