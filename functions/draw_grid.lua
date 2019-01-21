if not rq then rq = {} end

function get_queued_research(research_queue)
    local mapped_research = {}
    for _, tech in ipairs(research_queue) do
        mapped_research[tech] = true
    end
    return mapped_research
end

function options(player)
    local caption = player.gui.center.Q.add2q.add{type = "label", name = "options_caption", caption = "Options"}
    caption.style.minimal_width = player.mod_settings["research-queue-table-width"].value * 68
    local options = player.gui.center.Q.add2q.add{type = "table", name = "options", style = "rq-table2", column_count = player.mod_settings["research-queue-table-width"].value}
    player.gui.center.Q.add2q.add{type = "textfield", name = "rq-text-filter", text = global.text_filter or ""}

    options.add{type = "button", name = "rqextend-button", style = global.showExtended[player.index] and "rq-compact-button" or "rq-extend-button"}

    options.add{type = "checkbox", name = "rqtext", style = "rq-text-checkbox", state = global.showIcon[player.index]}

    options.add{type = "checkbox", name = "rqscience", style = "rq-scienceDone-checkbox", state = not global.showResearched[player.index]}

    local item_prototypes = game.item_prototypes

    for name, science in pairs(global.science_packs) do
        if global.showExtended[player.index] or not (global.bobsmodules[name] or global.bobsaliens[name]) then
            -- Technology icon. If the user clicks this, it will toggle the filter for this specific ingredient.
            local filter_style = science[player.index] and "rq-tool-selected-filter" or "rq-tool-inactive-filter"
            -- TODO: write up a templated string for the tooltip to allow for a reasonable tooltip with localizations
            options.add{type = "sprite-button", name = "rq-science" .. name,
                        style = filter_style, sprite = "item/" .. name, tooltip = item_prototypes[name].localised_name}

        elseif global.bobsmodules[name] and not options["rq-bobsmodules"] then
            options.add{type = "checkbox", name = "rq-bobsmodules", style = "rq-bobsmodules", state = not global.showBobsmodules[player.index]}
        elseif global.bobsaliens[name] and not options["rq-bobsaliens"] then
            options.add{type = "checkbox", name = "rq-bobsaliens", style = "rq-bobsalien", state = not global.showBobsaliens[player.index]}
        end
    end
end

function check_tech_ingredients(player, tech, forbidden_ingredients, known_good_techs)
    if known_good_techs[tech.name] == true then
        return true
    elseif known_good_techs[tech.name] == false then
        return false
    elseif matches(tech.research_unit_ingredients, "name", forbidden_ingredients) then
        known_good_techs[tech.name] = false
        return false
    end

    --checks if the prerequisites match given same criteria
    for _, pre in pairs(player.force.technologies[tech.name].prerequisites) do
        if not pre.researched and not check_tech_ingredients(player, pre, forbidden_ingredients, known_good_techs) then
            known_good_techs[tech.name] = false
            return false
        end
    end
    known_good_techs[tech.name] = true
    return true
end

function technologies(player, queued_techs)
    queued_techs = queued_techs or get_queued_research(global.researchQ[player.force.name])
    local caption = player.gui.center.Q.add2q.add{type = "label", name = "add2q_caption", caption = "List of technologies"}
    caption.style.minimal_width = player.mod_settings["research-queue-table-width"].value * 68
    --create a smaller table if text is displayed.
    local column_count = nil
    local width_hack = nil
    if global.showIcon[player.index] then
        column_count = player.mod_settings["research-queue-table-width"].value
        width_hack = 34
    else
        column_count = math.floor(player.mod_settings["research-queue-table-width"].value / 3)
        width_hack = 3 * 34
    end
    local rq_table = player.gui.center.Q.add2q.add{type = "table", name = "add2q_table", style = "rq-table1", column_count = column_count}
    rq_table.style.width = player.mod_settings["research-queue-table-width"].value * 68 + width_hack
    local count = 0
    local should_draw_down_button = false
    -- Map techs to avoid recursion for already calculated techs
    local known_good_techs = {}
    -- Create a table of research ingredients that the research may not have.
    local forbidden_ingredients = {}
    for item, science in pairs(global.science_packs) do
        forbidden_ingredients[item] = not science[player.index]
    end
    for name, tech in pairs(player.force.technologies) do
        -- checks if the research is enabled and either not completed or if it should show completed.
        if tech.enabled and (not tech.researched or global.showResearched[player.index]) and
          (global.showExtended[player.index] or not tech.upgrade or not any(tech.prerequisites, "upgrade") or
           any(tech.prerequisites, "researched") or matches(tech.prerequisites, "name", queued_techs)) then
            -- ^checks if the research is an upgrade technology and whether or not to show it.

            -- player.print(serpent.line(tech.localised_name))
            -- player.print(serpent.line(tech.name))

            -- filter technologies for selected ingredients and text mask
            if check_tech_ingredients(player, tech, forbidden_ingredients, known_good_techs) and
            (
                not global.text_filter
                or global.text_filter == ""
                or tech.name and string.find(string.lower(tech.name), string.lower(global.text_filter), 1, true)
                or name and string.find(string.lower(name), string.lower(global.text_filter), 1, true)
                -- or tech.localized_name and string.find(string.lower(tech.localized_name), string.lower(global.text_filter), 1, true)
            ) then
                -- Select the right (color) of background depending on the status of the technology (done/available or in queue)
                local background = tech.researched and "rq-done-" or queued_techs[tech.name] and "rq-inq-" or "rq-available-"
                count = count + 1
                if global.showIcon[player.index] then
                    -- Build GUI objects for icon view
                    background = background .. "frame"
                    local row = math.ceil(count / player.mod_settings["research-queue-table-width"].value)
                    if global.offset_tech[player.index] < row and row <= (player.mod_settings["research-queue-table-height"].value + global.offset_tech[player.index]) then
                        local bg_frame = rq_table.add{type = "frame", name = "rq" .. name .. "background_frame", style = background}
                        --technology icon
                        local pcall_status, tech_icon = pcall(bg_frame.add, {type = "frame", name = name .. "frame", style = "rq-tech" .. name, tooltip = tech.localised_name})
                        if not pcall_status then
                             pcall_status, tech_icon = pcall(bg_frame.add, {type = "button", name = name .. "frame", caption = name, tooltip = tech.localised_name})
                        end

                        --finds if the technology has a number (eg, automation-2) and creates a label with that number
                        local caption = string.match(name, "%-%d+")
                        if caption then caption = string.gsub(caption, "%-", " ") end
                        local frame3 = tech_icon.add{type = "label", name = name .. "label", style = "rq-label", caption = caption}
                        -- adds the final button that can be clicked on top.
                        local button = frame3.add{type = "button", name = "rq-add" .. name, style = "rq-button", tooltip = tech.localised_name}
                    elseif row > player.mod_settings["research-queue-table-height"].value + global.offset_tech[player.index] then
                        should_draw_down_button = true
                        break
                    end
                else
                    -- Build GUI objects for "named" view
                    -- FIXME The scroll down or up buttons in this view are not stable due to the variable length of the names of technologies
                    background = background .. "button"
                    local row = math.ceil(count / math.floor(player.mod_settings["research-queue-table-width"].value / 3))
                    if global.offset_tech[player.index] < row and row <= ((player.mod_settings["research-queue-table-height"].value*2) + global.offset_tech[player.index]) then
                        local frame = rq_table.add{type = "frame", name = "rqtextframe" .. name, style = "outer_frame"}
                        frame.add{type = "frame", name = name .. "frame", style = "rq-tech" .. name .. "small"}

                        --technology icon
                        local  pcall_status = pcall(frame.add, {type = "frame", name = name .. "frame", style = "rq-tech" .. name .. "small", tooltip = tech.localised_name})
                        if not pcall_status then
                            pcall_status = pcall(frame.add, {type = "button", name = name .. "frame", caption = name, tooltip = tech.localised_name})
                        end

                        frame.add{type = "button", name = "rq-add" .. name, caption = tech.localised_name, style = background, tooltip = tech.localised_name}
                    elseif row > (player.mod_settings["research-queue-table-height"].value * 2) + global.offset_tech[player.index] then
                        should_draw_down_button = true
                        break
                    end
                end
            end
        end
    end
    -- This is to allow the window to render mostly the same once you click on one of the buttons
    player.gui.center.Q.add2q.add{type = "button", name = "rqscrolltechup", style = "rq-up-button", enabled = global.offset_tech[player.index] > 0}
    player.gui.center.Q.add2q.add{type = "button", name = "rqscrolltechdown", style = "rq-down-button", enabled = should_draw_down_button}
end

function draw_grid_force(force)
    -- Cache the queued techs for the generation of each GUI tree (one per player at most)
    local queued_techs = get_queued_research(global.researchQ[force.name])
    for _, player in pairs(force.players) do
        draw_grid_player(player, queued_techs)
    end
end

function draw_grid_player(player, queued_techs)
    if player.gui.center.Q then
        if player.gui.center.Q.add2q then player.gui.center.Q.add2q.destroy() end
        player.gui.center.Q.add{type = "frame", name = "add2q", caption = "Add to queue", style = "technology_preview_frame", direction = "vertical"}
        options(player)
        technologies(player, queued_techs)
    end
end
