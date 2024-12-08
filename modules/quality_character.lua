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
local CHARACTER_QUALITY_PROBABILITY = .01 -- 1% chance as a decimal

-- Kill player command Debug
commands.add_command("kill_player", "Kills the player", function(command)
    local player = game.get_player(command.player_index)
    if player and player.valid and player.character then
        player.character.die()
        game.print(player.name .. " has been killed!")
    else
        game.print("Could not kill the player: No valid character found.")
    end
end)


-- Respawn a player at their force's spawn point
local function spawn_player(player)
    if not player then return end
	
    -- Handle existing character
    if player.character and player.character.valid then
        player.character.destroy() 
    end
    -- Create a new character for the player
    local surface = player.surface
    local spawn_position = player.force.get_spawn_position(surface)
    local position = surface.find_non_colliding_position("character", spawn_position, 32, 1) or spawn_position

    local current_quality = global.NORMAL_QUALITY
    local random_value = math.random()

    -- Calculate quality 
    local cumulative_probability = CHARACTER_QUALITY_PROBABILITY
    while random_value <= cumulative_probability do
        if current_quality.next ~= nil and player.force.is_quality_unlocked(current_quality.next.name) then
            current_quality = current_quality.next
            cumulative_probability = cumulative_probability * CHARACTER_QUALITY_PROBABILITY
        else
            break
        end
    end

    local character = surface.create_entity({
        name = "character",
        position = position,
        force = player.force,
        create_build_effect_smoke = false,
        quality = current_quality,
    })

    -- Assign the player to the new character
    player.set_controller({
        type = defines.controllers.character,
        character = character
    })
	
	player.color = current_quality.color

	-- Provide default starter items
    local gun_inventory = player.get_inventory(defines.inventory.character_guns)
    local ammo_inventory = player.get_inventory(defines.inventory.character_ammo)

    if gun_inventory and gun_inventory.valid then
        -- Insert the pistol into the first gun slot
        gun_inventory[1].set_stack({
            name = "pistol",
            count = 1,
            quality = character.quality.name
        })
    end

    if ammo_inventory and ammo_inventory.valid then
        -- Insert ammunition into the ammo inventory
        ammo_inventory.insert({name = "firearm-magazine", count = 10, quality = character.quality.name})
    end
end

-- Event for respawning a player
script.on_event(defines.events.on_player_respawned, function(event)
    local player = game.get_player(event.player_index)
    spawn_player(player)
end)

-- Event for new player creation
script.on_event(defines.events.on_player_created, function(event)
    local player = game.get_player(event.player_index)
    spawn_player(player)
end)