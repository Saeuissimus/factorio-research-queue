local mod_gui = require("mod-gui")

function init()
    if global.researchQ == nil then global.researchQ = {} end
    if global.labs == nil then global.labs = {} end
    local forces = game.forces
    for name, force in pairs(forces) do
        if global.researchQ[name] == nil then
            global.researchQ[name] = {}
            if force.current_research then
                table.insert(global.researchQ[name], force.current_research.name)
            end
        end
        global.labs[name] = map_all_entities({type = "lab", force = force})
    end
    if global.showIcon == nil then global.showIcon = {} end
    if global.showResearched == nil then global.showResearched = {} end
    if global.offset_queue == nil then global.offset_queue = {} end
    if global.offset_tech == nil then global.offset_tech = {} end
    if global.showExtended == nil then global.showExtended = {} end
    if global.science_packs == nil then global.science_packs = {} end
    local item_prototypes = game.item_prototypes
    for name, item in pairs(item_prototypes) do
        if item.type == "tool" then
            global.science_packs[name] = {}
        end
    end
    global.bobsmodules = {
        ["module-case"] = true,
        ["module-circuit-board"] = true,
        ["speed-processor"] = true,
        ["effectivity-processor"] = true,
        ["productivity-processor"] = true,
        ["pollution-clean-processor"] = true,
        ["pollution-create-processor"] = true
    }
    if global.showBobsmodules == nil then global.showBobsmodules = {} end
    global.bobsaliens = {
        ["alien-science-pack-blue"] = true,
        ["alien-science-pack-orange"] = true,
        ["alien-science-pack-purple"] = true,
        ["alien-science-pack-yellow"] = true,
        ["alien-science-pack-green"] = true,
        ["alien-science-pack-red"] = true
    }
    if global.showBobsaliens == nil then global.showBobsaliens = {} end
end

function player_init(player_index)
    if global.researchQ == nil then init() end
    local player = game.players[player_index]
    local top = mod_gui.get_button_flow(player)
    if not top.research_Q then top.add{type = "button", name = "research_Q", caption = "RQ", style = "rq-top-button"} end
    global.showIcon[player_index] = true
    global.showResearched[player_index] = false
    global.offset_queue[player_index] = 0
    global.offset_tech[player_index] = 0
    global.showExtended[player_index] = false
    for name, science in pairs(global.science_packs) do
        if player.force.recipes[name] ~= nil then
        science[player_index] = player.force.recipes[name].enabled
        else science[player_index] = false
        end
    end
    global.showBobsmodules[player_index] = player.force.technologies["modules"].researched
    if player.force.technologies["alien-research"] then
        global.showBobsaliens[player_index] = player.force.technologies["alien-research"].researched
    else
        global.showBobsaliens[player_index] = false
    end
end

--remote.add_interface("RQ", {popup = function(bool)
--  global.pop_when_empty_queue = false
--end})


function map_all_entities(input)
    -- input = {name = string, type = string, force = string or force, surface = string or {table of surface(s)}
    local map = {}

    if type(input.surface) == "string" then input.surface = {game.surfaces[input.surface]} end
    local surfaces = input.surface or game.surfaces

    for _, surface in pairs(surfaces) do
        for chunk in surface.get_chunks() do
            local entities = surface.find_entities_filtered{
                area = {left_top = {chunk.x*32, chunk.y*32}, right_bottom = {(chunk.x+1)*32, (chunk.y+1)*32}},
                name = input.name,
                type = input.type,
                force = input.force}
            for _, entity in ipairs(entities) do
                map[entity] = entity
            end
        end
    end
    return map
end