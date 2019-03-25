function get_queued_research(research_queue)
    local mapped_research = {}
    for _, tech in ipairs(research_queue) do
        mapped_research[tech] = true
    end
    return mapped_research
end

function options(player)
    local caption = player.gui.center.Q.add2q.add{type = "label", name = "options_caption", caption = {"rqon-gui.options"}}
    caption.style.minimal_width = player.mod_settings["research-queue-the-old-new-thing-table-width"].value * 68
    local columns = player.mod_settings["research-queue-the-old-new-thing-table-width"].value
    -- The ratio is higher than this I think, but this is good enough for now.
    columns = bit32.arshift(columns, -1) - bit32.arshift(columns, 2)
    local options = player.gui.center.Q.add2q.add{type = "table", name = "options", style = "rqon-table2", column_count = columns}
    player.gui.center.Q.add2q.add{type = "textfield", name = "rqon-text-filter", text = global.text_filter or "", tooltip = {"rqon-gui.prefix-text-search"}}

    options.add{type = "button", name = "rqonextend-button", style = global.showExtended[player.index] and "rqon-compact-button" or "rqon-extend-button"}

    local text_view_style, text_view_tooltip = nil, nil
    if global.showIcon[player.index] then
        text_view_style = "rqon-tool-inactive-filter"
        text_view_tooltip = {"rqon-gui.use-tech-labels"}
    else
        text_view_style = "rqon-tool-selected-filter"
        text_view_tooltip = {"rqon-gui.use-tech-icons"}
    end
    options.add{type = "sprite-button", name = "rqontext", sprite = "rqon-text-view-icon",
                style = text_view_style, tooltip = text_view_tooltip }

    local completed_research_style, completed_research_tooltip = nil, nil
    if global.showResearched[player.index] then
        completed_research_style = "rqon-tool-selected-filter"
        completed_research_tooltip = {"rqon-gui.stop-showing-researched-techs"}
    else
        completed_research_style = "rqon-tool-inactive-filter"
        completed_research_tooltip = {"rqon-gui.show-researched-techs"}
    end
    options.add{type = "sprite-button", name = "rqonscience", sprite = "rqon-completed-research-icon",
                style = completed_research_style, tooltip = completed_research_tooltip}

    local item_prototypes = game.item_prototypes

    for name, science in pairs(global.science_packs) do
        if global.showExtended[player.index] or not (global.bobsmodules[name] or global.bobsaliens[name]) then
            -- Technology icon. If the user clicks this, it will toggle the filter for this specific ingredient.
            local filter_style, tooltip = nil, nil
            if science[player.index] then
                filter_style = "rqon-tool-selected-filter"
                tooltip = {"rqon-gui.exclude_science_pack", item_prototypes[name].localised_name}
            else
                filter_style = "rqon-tool-inactive-filter"
                tooltip = {"rqon-gui.stop_science_pack_exclusion", item_prototypes[name].localised_name}
            end
            options.add{type = "sprite-button", name = "rqon-science" .. name,
                        style = filter_style, sprite = "item/" .. name, tooltip = tooltip}

        elseif global.bobsmodules[name] and not options["rqon-bobsmodules"] then
            local checkbox_state, checkbox_tooltip = nil, nil
            if global.showBobsmodules[player.index] then
                checkbox_state = false
                checkbox_tooltip = {"rqon-gui.stop-showing-bobs-modules-techs"}
            else
                checkbox_state = true
                checkbox_tooltip = {"rqon-gui.show-bobs-modules-techs"}
            end
            options.add{type = "checkbox", name = "rqon-bobsmodules", style = "rqon-bobsmodules", state = checkbox_state, tooltip = checkbox_tooltip}
        elseif global.bobsaliens[name] and not options["rqon-bobsaliens"] then
            local checkbox_state, checkbox_tooltip = nil, nil
            if global.showBobsaliens[player.index] then
                checkbox_state = false
                checkbox_tooltip = {"rqon-gui.stop-showing-bobs-aliens-techs"}
            else
                checkbox_state = true
                checkbox_tooltip = {"rqon-gui.show-bobs-aliens-techs"}
            end
            options.add{type = "checkbox", name = "rqon-bobsaliens", style = "rqon-bobsalien", state = checkbox_state, tooltip = checkbox_tooltip}
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
    local caption = player.gui.center.Q.add2q.add{type = "label", name = "add2q_caption", caption = {"rqon-gui.technology-list"}}
    caption.style.minimal_width = player.mod_settings["research-queue-the-old-new-thing-table-width"].value * 68
    --create a smaller table if text is displayed.
    local column_count = nil
    local width_hack = nil
    if global.showIcon[player.index] then
        column_count = player.mod_settings["research-queue-the-old-new-thing-table-width"].value
        width_hack = 34
    else
        column_count = math.floor(player.mod_settings["research-queue-the-old-new-thing-table-width"].value / 3)
        width_hack = 3 * 34
    end
    local rqon_table = player.gui.center.Q.add2q.add{type = "table", name = "add2q_table", style = "rqon-table1", column_count = column_count}
    rqon_table.style.width = player.mod_settings["research-queue-the-old-new-thing-table-width"].value * 68 + width_hack
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
                local background = tech.researched and "rqon-done-" or queued_techs[tech.name] and "rqon-inq-" or "rqon-available-"
                count = count + 1
                if global.showIcon[player.index] then
                    -- Build GUI objects for icon view
                    background = background .. "frame"
                    local row = math.ceil(count / player.mod_settings["research-queue-the-old-new-thing-table-width"].value)
                    if global.offset_tech[player.index] < row and row <= (player.mod_settings["research-queue-the-old-new-thing-table-height"].value + global.offset_tech[player.index]) then
                        local bg_frame = rqon_table.add{type = "frame", name = "rqon" .. name .. "background_frame", style = background}
                        --technology icon
                        local tech_icon = bg_frame.add{type = "sprite-button", name = "rqon-add" .. name,
                                                       sprite = "technology/" .. name, style = "rqon-button", tooltip = tech.localised_name}

                        --finds if the technology has a number (eg, automation-2) and creates a label with that number
                        local caption = string.match(name, "%-%d+")
                        if caption then caption = string.gsub(caption, "%-", " ") end
                        tech_icon.add{type = "label", name = name .. "label", style = "rqon-label", caption = caption,
                                      ignored_by_interaction = true, enabled = caption and string.len(caption) > 0}
                    elseif row > player.mod_settings["research-queue-the-old-new-thing-table-height"].value + global.offset_tech[player.index] then
                        should_draw_down_button = true
                        break
                    end
                else
                    -- Build GUI objects for "named" view
                    -- FIXME The scroll down or up buttons in this view are not stable due to the variable length of the names of technologies
                    background = background .. "button"
                    local row = math.ceil(count / math.floor(player.mod_settings["research-queue-the-old-new-thing-table-width"].value / 3))
                    if global.offset_tech[player.index] < row and row <= ((player.mod_settings["research-queue-the-old-new-thing-table-height"].value*2) + global.offset_tech[player.index]) then
                        local frame = rqon_table.add{type = "frame", name = "rqontextframe" .. name, style = "outer_frame"}

                        --technology icon
                        frame.add{type = "sprite-button", name = name .. "icon", style = "rqon-small-dummy-button", tooltip = tech.localised_name,
                                  sprite = "technology/" .. name, ignored_by_interaction = true}

                        frame.add{type = "button", name = "rqon-add" .. name, caption = tech.localised_name, style = background, tooltip = tech.localised_name}
                    elseif row > (player.mod_settings["research-queue-the-old-new-thing-table-height"].value * 2) + global.offset_tech[player.index] then
                        should_draw_down_button = true
                        break
                    end
                end
            end
        end
    end
    -- This is to allow the window to render mostly the same once you click on one of the buttons
    player.gui.center.Q.add2q.add{type = "button", name = "rqonscrolltechup", style = "rqon-up-button", enabled = global.offset_tech[player.index] > 0}
    player.gui.center.Q.add2q.add{type = "button", name = "rqonscrolltechdown", style = "rqon-down-button", enabled = should_draw_down_button}
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
        player.gui.center.Q.add{type = "frame", name = "add2q", caption = {"rqon-gui.add-to-queue"}, style = "technology_preview_frame", direction = "vertical"}
        options(player)
        technologies(player, queued_techs)
    end
end
