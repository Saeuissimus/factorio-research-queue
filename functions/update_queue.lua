if not rq then rq = {} end
require("util")

function research_is_in_queue(research_name, queue, start, last)
    local start = start or 1
    local last = last or #queue
    for i = start, last do
        if research_name == queue[i] then
            return true
        end
    end
    return false
end

-- techs_to_remove should map tech names to removal flags
function check_queue(force, techs_to_remove)
    local queue = global.researchQ[force.name]
    techs_to_remove = techs_to_remove or {}
    for i, tech in ipairs(queue) do
        local should_be_removed = techs_to_remove[tech] or force.technologies[tech] == nil
        if not should_be_removed then
            for _, pre in pairs(force.technologies[tech].prerequisites) do
                if not(pre.researched or techs_to_remove[pre.name] == false) then
                    should_be_removed = true
                    break
                end
            end
        end
        techs_to_remove[tech] = should_be_removed
    end

    -- log(serpent.block(techs_to_remove))
    for i = #queue, 1, -1 do
        local tech = queue[i]
        if techs_to_remove[tech] then
            table.remove(queue, i)
        end
    end
end

function prompt_overwrite_research(player, research_name)
    if player.force.current_research ~= research_name then
        if player.gui.center.Q then player.gui.center.Q.destroy() end
        local warning = player.gui.center.add{type = "frame", name = "warning", style = "frame"}
        warning.add{type = "frame", name = "warning-icon", style = "rq-warning-icon"}
        local text = warning.add{type = "flow", name = "rq-warning-text", style = "vertical_flow", direction = "vertical"}
        local caption = {"rq-gui.tech-prompt-overwrite", math.ceil(player.force.research_progress * 1000) / 10}
        text.add{type = "label", name = "rq-warning-text-content", caption = caption, style = "description_label"}
        local buttons = text.add{type = "flow", name = "rq-warning-buttons", style = "horizontal_flow", direction = "horizontal"}
        buttons.add{type = "button", name = "rq-overwrite-yes", style = "button", caption = {"rq-gui.accept"}}
        buttons.add{type = "button", name = "rq-overwrite-no", style = "button", caption = {"rq-gui.cancel"}}
    end
end

function est_time(force, last_tech_index)
    if not force.current_research then
        return nil
    end

    local est = {}
    last_tech_index = last_tech_index or #global.researchQ[force.name]
    if last_tech_index == 0 then
        return est
    end

    local speed = 0
    for key, lab in pairs(global.labs[force.name]) do
        if not lab.valid then
            global.labs[force.name][key] = nil
        else
            local speed_modifier = 0
            local productivity_modifier = 0
            local consumption_modifier = 0
            for item, count in pairs(lab.get_module_inventory().get_contents()) do
                module_effect = game.item_prototypes[item].module_effects
                if module_effect.speed then speed_modifier = speed_modifier + module_effect.speed.bonus * count end
                if module_effect.productivity then productivity_modifier = productivity_modifier + module_effect.productivity.bonus * count end
                if module_effect.consumption then consumption_modifier = consumption_modifier + module_effect.consumption.bonus * count end
            end
            -- if base lab then use energy values
            if lab.name == "lab" then
                speed = speed + ( (1 + speed_modifier) * (1 + productivity_modifier) * math.min(lab.energy / (math.max(1 + consumption_modifier, 0.2) * 60 * 160 / 9), 1) )
            -- ignore energy values for modded labs, only check if it has energy or not
            else
                speed = speed + ( (1 + speed_modifier) * (1 + productivity_modifier) * math.min(lab.energy, 1) )
            end
        end
    end

    speed = speed * (1 + force.laboratory_speed_modifier)

    local initial_eta = (1 - force.research_progress) * force.current_research.research_unit_count * force.current_research.research_unit_energy / speed
    for i, tech in ipairs(global.researchQ[force.name]) do
        if force.current_research.name == tech then
            est[i] = initial_eta
        else
            local current_saved_progress = force.get_saved_technology_progress(tech)
            local current_remaining_progress = current_saved_progress and (1 - current_saved_progress) or 1
            local current_eta = current_remaining_progress * force.technologies[tech].research_unit_count * force.technologies[tech].research_unit_energy / speed
            if i == 1 then
                est[i] = initial_eta + current_eta
            elseif i > 2 and global.researchQ[force.name][i-1] == force.current_research.name then
                est[i] = est[i - 2] + current_eta
            else
                est[i] = est[i - 1] + current_eta
            end
        end
        if i == last_tech_index then
            break
        end
    end
    return est
end

-- pre: research_name has not been researched already
function add_research(force, research_name)
    --checks if the prerequisites are already researched, if not call this function for those techs first.
    for _, pre in pairs(force.technologies[research_name].prerequisites) do
        if not pre.researched then
            add_research(force, pre.name)
        end
    end
    if not research_is_in_queue(research_name, global.researchQ[force.name]) then
        table.insert(global.researchQ[force.name], research_name)
    end
end

function remove_research(force, research_name)
    for index, _ in pairs(force.players) do
        if global.offset_queue[index] > 0 then global.offset_queue[index] = global.offset_queue[index] - 1 end
    end
    local is_top_tech = global.researchQ[force.name][1] == research_name
    local techs_to_remove = {}
    techs_to_remove[research_name] = true
    -- log(serpent.block(techs_to_remove))
    check_queue(force, techs_to_remove)
    --starts the new researches for the new top item in the queue
    if (force.current_research == research_name or is_top_tech) and global.researchQ[force.name][1] ~= nil then
        force.current_research = global.researchQ[force.name][1]
    end
end

function row_from_research_name(force, research_name)
    --find the queue index corresponding to the technology
    for i, tech in ipairs(global.researchQ[force.name]) do
        if tech == research_name then
            return i
        end
    end
end

function is_prerequisite(research_name, prerequisites)
    for _, pre in pairs(prerequisites) do
        if pre.name == research_name then return true end
    end
    return false
end

-- move research_name up _times_ times in the queue
function up(player, research_name, times)
    local moved_by_count = 0
    local force = player.force
    local research_index = row_from_research_name(force, research_name)
    for i = 1, math.min(times, research_index - 1) do
        if is_prerequisite(global.researchQ[force.name][research_index - i], force.technologies[research_name].prerequisites) then
            break
        end
        moved_by_count = moved_by_count + 1
    end

    if moved_by_count > 0 then
        local new_index = research_index - moved_by_count
        table.remove(global.researchQ[force.name], research_index)
        table.insert(global.researchQ[force.name], new_index, research_name)
        --starts the new top research
        if moved_by_count == 1 and new_index == 1 and
           force.current_research.name ~= research_name then
            prompt_overwrite_research(player, research_name)
        end
    end
end

function down(force, research_name, times)
    local research_index = row_from_research_name(force, research_name)
    local available_positions = 0
    for i = 1, math.min(times, #global.researchQ[force.name] - research_index) do
        if is_prerequisite(research_name, force.technologies[global.researchQ[force.name][research_index + i]].prerequisites) then
            break
        end
        available_positions = available_positions + 1
    end
    if available_positions > 0 then
        table.remove(global.researchQ[force.name], research_index)
        table.insert(global.researchQ[force.name], research_index + available_positions, research_name)
    end
end

-- pre: players should all belong to force
function update_queue_force(force, partial_update, players)
    players = players or force.players
    local last_row = 1
    local active_players = {}
    for _, player in pairs(players) do
        if player.gui.center.Q then
            last_row = math.max(last_row, player.mod_settings["research-queue-rows-count"].value + global.offset_queue[player.index])
            active_players[_] = player
        end
    end
    last_row = math.min(last_row, #global.researchQ[force.name])
    local time_estimation = est_time(force, last_row)

    for _, player in pairs(active_players) do
        update_queue_player(player, partial_update, time_estimation)
    end
end

-- We assume here that the player is connected
-- time_estimation is an optional argument. Useful to cache results for an entire force.
function update_queue_player(player, partial_update, time_estimation)
    local descriptions = draw_queue_frame(player, partial_update)

    if time_estimation == nil then
        local last_row = player.mod_settings["research-queue-rows-count"].value + global.offset_queue[player.index]
        local last = math.min(#global.researchQ[player.force.name], last_row)
        time_estimation = est_time(player.force, last)
    end

    for index, tech_description in pairs(descriptions) do
        update_estimated_time(tech_description, time_estimation[index])
    end
end

-- Draws the window that shows the queue.
function draw_queue_frame(player, partial_update)
    local force = player.force
    local research_queue = global.researchQ[force.name]
    local last_row = player.mod_settings["research-queue-rows-count"].value + global.offset_queue[player.index]
    local start = 1 + global.offset_queue[player.index]
    local last = math.min(#research_queue, last_row)
    local descriptions = {}
    if not partial_update then
        player.opened = player.gui.center.Q
        if not player.gui.center.Q.current_q then
            player.gui.center.Q.add{type = "frame", name = "current_q", caption = {"rq-gui.current-queue"}, style = "technology_preview_frame"}
        end

        local list = nil
        if not player.gui.center.Q.current_q.list then
            list = player.gui.center.Q.current_q.add{type = "flow", name = "list", style = "rq-flow-vertical", direction = "vertical"}
        else
            list = player.gui.center.Q.current_q.list
            list.clear()
        end

        if #research_queue == 0 then
            list.add{type = "label", name = "empty", caption = {"rq-gui.empty-queue"}}
        else
            list.add{type = "button", name = "rqscrollqueueup", style = "rq-up-button", enabled = start > 1}
            local item_prototypes = game.item_prototypes
            for i = start, last do
                local tech_name = research_queue[i]
                descriptions[i] = draw_queued_technology(list, tech_name, force.technologies[tech_name], item_prototypes, player.mod_settings["research-queue-queued-tech-description-width"].value)
            end
            list.add{type = "button", name = "rqscrollqueuedown", style = "rq-down-button", enabled = #research_queue > last_row}
        end
    else
        -- Construct the descriptions list to update them easily
        local list = player.gui.center.Q.current_q.list
        for i = start, last do
            local tech_name = research_queue[i]
            local tech_description = list["rq-frame-" .. tech_name].rqtechdescription
            descriptions[i] = tech_description
        end
    end
    return descriptions
end

function draw_queued_technology(drawn_list, tech_name, technology, item_prototypes, description_width)
    --create a frame for each item in the queue
    local frame = drawn_list.add{type = "frame", name = "rq-frame-" .. tech_name, style = "rq-frame"}

    frame.add{type = "sprite-button", name = "rq-icon" .. tech_name, style = "rq-dummy-button",
              sprite = "technology/" .. tech_name, ignored_by_interaction = true}

    -- adds a description frame in the frame
    local description = frame.add{type = "flow", name = "rqtechdescription", style = "rq-flow-vertical", direction = "vertical"}
    description.style.minimal_width = description_width
    -- places the name of the technology
    description.add{type = "label", name = "rq" .. tech_name .. "name", caption = technology.localised_name, style = "description_label"}
    -- add the ingredients and time
    local ingredients = description.add{type = "table", name = "rq" .. tech_name .. "ingredients", style = "table", column_count = 10}
    ingredients.add{type = "frame", name = "rqtime", caption = (technology.research_unit_energy / 60), style = "rq-clock"}
    for _, item in pairs(technology.research_unit_ingredients) do
        -- This looks a bit clunky? May be worth reworking after 0.17
        local item_localised_name = item_prototypes[item.name].localised_name
        local button = ingredients.add{type = "sprite-button", name = "rq-ingredient" .. item.name, tooltip = item_localised_name,
                                       sprite = "item/" .. item.name, style = "rq-ingredient-sprite"}
        button.add{type = "label", name = "rq-label" .. item.name, style = "rq-small-label",
                   caption = item.amount, ignored_by_interaction = true}
    end
    ingredients.add{type = "label", name = "rqresearch_unit_count", caption = "X " .. technology.research_unit_count, style = "label"}


    --adds the up/cancel/down buttons
    local buttons = frame.add{type = "table", name = "rq" .. tech_name .. "buttons", style = "slot_table", column_count = 1}
    buttons.add{type = "button", name = "rqupbutton" .. tech_name, style = "rq-up-button"}
    buttons.add{type = "button", name = "rqcancelbutton" .. tech_name, style = "rq-cancel-button"}
    buttons.add{type = "button", name = "rqdownbutton" .. tech_name, style = "rq-down-button"}
    return description
end

function update_estimated_time(tech_description, time_estimation)
    local caption = nil
    if time_estimation and time_estimation ~= math.huge then
        caption = {"rq-gui.finite-eta", util.formattime(time_estimation)}
    else
        caption = {"rq-gui.infinite-eta"}
    end

    if tech_description.rqtechtime then
        tech_description.rqtechtime.caption = caption
    else
        tech_description.add{type = "label", name = "rqtechtime", caption = caption, style = "label"}
    end
end