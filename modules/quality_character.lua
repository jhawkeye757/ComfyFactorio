local Event = require 'utils.event'
local quality_init = require("quality_init") -- Import the quality_init module

local quality_character = {}
-- Function to calculate probability based on playtime
local function calculate_probability(player)
    if not player or not player.online_time then return 0 end
    local hours_played = player.online_time / (60 * 60 * 60) -- Convert ticks to hours
    return math.min(hours_played * 0.01, .5) -- Cap the probability at 50%
end

-- Function to handle player spawning
local function spawn_player(player)
    if not player then return end

    -- Handle existing character
    if player.character and player.character.valid then
        player.character.destroy()
    end

    -- Create a new character
    local surface = player.surface
    local spawn_position = player.force.get_spawn_position(surface)
    local position = surface.find_non_colliding_position("character", spawn_position, 32, 1) or spawn_position

    -- Determine character quality using quality_init
    local result_quality = quality_init.calculate_quality(global.NORMAL_QUALITY, calculate_probability(player))

    -- Create character with the determined quality
    local character = surface.create_entity({
        name = "character",
        position = position,
        force = player.force,
        create_build_effect_smoke = false,
        quality = result_quality
    })

    -- Assign character to player
    player.set_controller({
        type = defines.controllers.character,
        character = character
    })

    -- Set player color
    player.color = result_quality.color

    -- Provide default starter items
    local gun_inventory = player.get_inventory(defines.inventory.character_guns)
    local ammo_inventory = player.get_inventory(defines.inventory.character_ammo)

    if gun_inventory and gun_inventory.valid then
        gun_inventory[1].set_stack({
            name = "pistol",
            count = 1,
            quality = result_quality.name
        })
    end

    if ammo_inventory and ammo_inventory.valid then
        ammo_inventory.insert({
            name = "firearm-magazine",
            count = 2,
            quality = result_quality.name
        })
    end
end

-- Event handler for player created
local function on_player_created(event)
    local player = game.get_player(event.player_index)
    spawn_player(player)
end

-- Event handler for player respawned
local function on_player_respawned(event)
    local player = game.get_player(event.player_index)
    spawn_player(player)
end

-- Register the events
Event.add(defines.events.on_player_created, on_player_created)
Event.add(defines.events.on_player_respawned, on_player_respawned)

return quality_character
