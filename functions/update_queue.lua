if not rq then rq = {} end
require("util")

function research_is_in_queue(research_name, queue, start, last)
    start = start or 1
    last = last or #queue
    for i = start, last do
        if research_name == queue[i] then
            return true
        end
    end
    return false
end

function check_queue(force)
    for i, tech in ipairs(global.researchQ[force.name]) do
        -- checks if the technology still exists
        if force.technologies[tech] then
            for _, pre in pairs(force.technologies[tech].prerequisites) do
                -- checks if the prerequisite is already researched
                -- checks if the prerequisite is in the queue before the technology
                if not pre.researched and not research_is_in_queue(pre.name, global.researchQ[force.name], 1, i) then
                    remove_research(force, tech)
                end
            end
        else
            remove_research(force, tech)
        end
    end
end

function prompt_overwrite_research(player, research_name)
    if player.force.current_research ~= research_name then
        if player.gui.center.Q then player.gui.center.Q.destroy() end
        local warning = player.gui.center.add{type = "frame", name = "warning", style = "frame"}
        warning.add{type = "frame", name = "warning-icon", style = "rq-warning-icon"}
        local text = warning.add{type = "flow", name = "rq-warning-text", style = "vertical_flow", direction = "vertical"}
        local caption = "Overwrite current research? (" .. math.ceil(player.force.research_progress * 1000) / 10 .. "% done)"
        text.add{type = "label", name = "rq-warning-text-content", caption = caption, style = "description_label"}
        local buttons = text.add{type = "flow", name = "rq-warning-buttons", style = "horizontal_flow", direction = "horizontal"}
        buttons.add{type = "button", name = "rq-overwrite-yes", style = "button", caption = "Yes"}
        buttons.add{type = "button", name = "rq-overwrite-no", style = "button", caption = "No"}
    end
end

function est_time(force)
    if not force.current_research then
        return nil
    end

    local est = {}
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
            --if base lab then use energy values
            if lab.name == "lab" then
                speed = speed + ( (1 + speed_modifier) * (1 + productivity_modifier) * math.min(lab.energy / (math.max(1 + consumption_modifier, 0.2) * 60 * 160 / 9), 1) )
            -- ignore energy values for modded labs, only check if it has energy or not
            else
                speed = speed + ( (1 + speed_modifier) * (1 + productivity_modifier) * math.min(lab.energy, 1) )
            end
        end
    end

    speed = speed * (1 + force.laboratory_speed_modifier)

    for i, tech in ipairs(global.researchQ[force.name]) do
        local t = (1 - force.research_progress) * force.current_research.research_unit_count * force.current_research.research_unit_energy / speed
        if force.current_research.name == tech then
            est[i] = t
        elseif i == 1 then
            est[i] = t + force.technologies[tech].research_unit_count * force.technologies[tech].research_unit_energy / speed
        elseif i > 2 and global.researchQ[force.name][i-1] == force.current_research.name then
            est[i] = est[i - 2] + force.technologies[tech].research_unit_count * force.technologies[tech].research_unit_energy / speed
        else
            est[i] = est[i - 1] + force.technologies[tech].research_unit_count * force.technologies[tech].research_unit_energy / speed
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
    local research_index = row_from_research_name(force, research_name)
    table.remove(global.researchQ[force.name], research_index)

    for index, _ in pairs(force.players) do
        if global.offset_queue[index] > 0 then global.offset_queue[index] = global.offset_queue[index] - 1 end
    end
    -- TODO: restrict the check to affected parts of the queue
    check_queue(force)
    --starts the new researches for the new top item in the queue
    if force.current_research == research_name and global.researchQ[force.name][1] ~= nil then
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
    local research_index = row_from_research_name(force, research_name)
    for i = 1, math.min(times, research_index - 1) do
        local force = player.force
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


-- This is a messy GUI function. It updates the window that shows the queue somehow.
function updateQ(force)
    local time_estimation = est_time(force)
    for index, player in pairs(force.players) do
        if player.gui.center.Q then
            player.opened = player.gui.center.Q
            if not player.gui.center.Q.current_q then player.gui.center.Q.add{type = "frame", name = "current_q", caption = "Current queue", style = "technology_preview_frame"} end
            if player.gui.center.Q.current_q.list then player.gui.center.Q.current_q.list.destroy() end

            local list = player.gui.center.Q.current_q.add{type = "flow", name = "list", style = "rq-flow-vertical", direction = "vertical"}

            if #global.researchQ[force.name] == 0 then
                list.add{type = "label", name = "empty", caption = "No research queued"}
            else
                for i, tech in ipairs(global.researchQ[force.name]) do
                    local technology = force.technologies[tech]
                    if global.offset_queue[index] < i and i <= (player.mod_settings["research-queue-rows-count"].value + global.offset_queue[index]) then
                        --create a frame for each item in the queue
                        local frame = list.add{type = "frame", name = "rq" .. tech .. "frame", style = "rq-frame"}


                        local pcall_status, _ = pcall(frame.add, {type = "frame", name = "rq" .. tech .. "icon", style = "rq-tech" .. tech, tooltip = name})
                        if not pcall_status then
                            pcall_status, _ = pcall(frame.add, {type = "frame", name = "rq" .. tech .. "icon", tooltip = name})
                        end

                        -- adds a description frame in the frame
                        local description = frame.add{type = "flow", name = "rq" .. tech .. "description", style = "rq-flow-vertical", direction = "vertical"}
                        description.style.minimal_width = 185
                        -- places the name of the technology
                        description.add{type = "label", name = "rq" .. tech .. "name", caption = technology.localised_name, style = "description_label"}
                        -- add the ingredients and time
                        local ingredients = description.add{type = "table", name = "rq" .. tech .. "ingredients", style = "table", column_count = 8}
                        ingredients.add{type = "frame", name = "rqtime", caption = (technology.research_unit_energy / 60), style = "rq-clock"}
                        for _, item in pairs(technology.research_unit_ingredients) do
                            local pcall_status, _ = pcall(ingredients.add, {type = "frame", name = "rq" .. item.name, caption = item.amount, style = "rq-tool" .. item.name .. "frame"})
                            if not pcall_status then
                                pcall_status, _ = pcall(ingredients.add, {type = "frame", name = "rq" .. item.name, caption = item.amount})
                            end
                        end
                        ingredients.add{type = "label", name = "rqresearch_unit_count", caption = "X " .. technology.research_unit_count, style = "label"}
                        local caption = nil
                        if time_estimation and time_estimation[i] ~= math.huge then
                            caption = "Estimated time: " .. util.formattime(time_estimation[i])
                        else
                            caption = "Estimated time: infinity"
                        end
                        description.add{type = "label", name = "rq" .. tech .. "time", caption = caption, style = "label"}


                        --adds the up/cancel/down buttons
                        local buttons = frame.add{type = "table", name = "rq" .. tech .. "buttons", style = "slot_table", column_count = 1}
                        buttons.add{type = "button", name = "rq" .. "upbutton" .. tech, style = "rq-up-button"}
                        buttons.add{type = "button", name = "rq" .. "cancelbutton" .. tech, style = "rq-cancel-button"}
                        buttons.add{type = "button", name = "rq" .. "downbutton" .. tech, style = "rq-down-button"}

                    --adds scrollbuttons to the top and bottom of the list
                    elseif i == global.offset_queue[index] then
                        list.add{type = "button", name = "rqscrollqueueup", style = "rq-up-button"}
                    elseif i > player.mod_settings["research-queue-rows-count"].value + global.offset_queue[index] then
                        list.add{type = "button", name = "rqscrollqueuedown", style = "rq-down-button"}
                        break
                    end
                end
            end
        end
    end
end