-- Initialize the scenario
script.on_init(function()
    -- Ensure the global table is initialized
    if not global then global = {} end

    -- Create a temporary character to assign the normal quality object to and delete it
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

    -- Unlock uncommon quality for the player's force
    if game.forces["player"] then
        game.forces["player"].unlock_quality("uncommon")
    end
end)



-- Probability for quality (default 1%)
local ENEMY_QUALITY_PROBABILITY = .01 -- 1% chance as a decimal


script.on_event(defines.events.on_entity_spawned, function(event)
    local spawned_entity = event.entity
    local spawner = event.spawner
	
	-- Calculate quality progression
    local current_quality = spawner.quality or global.NORMAL_QUALITY
    local cumulative_probability = ENEMY_QUALITY_PROBABILITY
    local random_value = math.random()
	while random_value <= cumulative_probability do
		if current_quality.next ~= nil and game.forces["player"].is_quality_unlocked(current_quality.next.name) then
			current_quality = current_quality.next
			cumulative_probability = cumulative_probability * ENEMY_QUALITY_PROBABILITY
		else
			break
		end
	end
	
	if current_quality.name ~= "normal" then

		if spawned_entity and spawned_entity.valid then
			-- Store the position and other details
			local surface = spawned_entity.surface
			local position = spawned_entity.position
			local force = spawned_entity.force
			local name = spawned_entity.name

			
			-- Destroy the original entity
			spawned_entity.destroy()

			-- Create a replacement entity with the desired quality
			local replacement = surface.create_entity({
				name = name,
				position = position,
				force = force,
				quality = current_quality
			})
		end
	end
end)
