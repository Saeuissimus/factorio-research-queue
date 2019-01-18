if not rq then rq = {} end

function options(player)
    local caption = player.gui.center.Q.add2q.add{type = "label", name = "options_caption", caption = "Options"}
    caption.style.minimal_width = player.mod_settings["research-queue-table-width"].value * 68
    local options = player.gui.center.Q.add2q.add{type = "table", name = "options", style = "rq-table2", column_count = player.mod_settings["research-queue-table-width"].value}
    local text_filter = player.gui.center.Q.add2q.add{type = "textfield", name = "rq-text-filter", text = global.text_filter or ""}
    text_filter.focus()

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

function check_tech_ingredients(player, tech, forbidden_ingredients)
    if matches(tech.research_unit_ingredients, "name", forbidden_ingredients) then
        return false
    end

    --checks if the prerequisites match given same criteria
    for _, pre in pairs(player.force.technologies[tech.name].prerequisites) do
        if not pre.researched and not check_tech_ingredients(player, pre, forbidden_ingredients) then
            return false
        end
    end

    return true
end

function technologies(player)
    local caption = player.gui.center.Q.add2q.add{type = "label", name = "add2q_caption", caption = "List of technologies"}
    caption.style.minimal_width = player.mod_settings["research-queue-table-width"].value * 68
    --create a smaller table if text is displayed.
    if global.showIcon[player.index] then
        column_count = player.mod_settings["research-queue-table-width"].value
    else
        column_count = math.floor(player.mod_settings["research-queue-table-width"].value / 3)
    end
    local rq_table = player.gui.center.Q.add2q.add{type = "table", name = "add2q_table", style = "rq-table1", column_count = column_count}
    local count = 0
    for name, tech in pairs(player.force.technologies) do
        if tech.enabled and (not tech.researched or global.showResearched[player.index]) then --checks if the research is enabled and either not completed or if it should show completed.
            if (global.showExtended[player.index] or not tech.upgrade or not any(tech.prerequisites, "upgrade") or any(tech.prerequisites, "researched") or matches(tech.prerequisites, "name", global.researchQ[player.force.name])) then
            -- ^checks if the research is an upgrade technology and whether or not to show it.
                local forbidden_ingredients = {} -- create a table of research ingredients that the research may not have.
                for item, science in pairs(global.science_packs) do
                    if not science[player.index] then table.insert(forbidden_ingredients, item) end
                end

--              player.print(serpent.line(tech.localised_name))
--              player.print(serpent.line(tech.name))

                 -- filter technologies for selected ingredients and text mask
                if check_tech_ingredients(player, tech, forbidden_ingredients) and
                        (
                            not global.text_filter
                            or global.text_filter == ""
                            or tech.name and string.find(string.lower(tech.name), string.lower(global.text_filter), 1, true)
                            or name and string.find(string.lower(name), string.lower(global.text_filter), 1, true)
--                          or tech.localized_name and string.find(string.lower(tech.localized_name), string.lower(global.text_filter), 1, true)
                        )
                        then
                    local background1, background2 = nil, nil --select the right (color) of background depending on the status of the technology (done/available or in queue)
                    if tech.researched then
                        background1 = "rq-done-frame"
                        background2 = "rq-done-button"
                    else
                        background1 = "rq-available-frame"
                        background2 = "rq-available-button"
                    end
                    for _, q in ipairs(global.researchQ[player.force.name]) do
                        if name == q then
                            background1 = "rq-inq-frame"
                            background2 = "rq-inq-button"
                        end
                    end
                    count = count + 1
                    if global.showIcon[player.index] then
                        local row = math.ceil(count / player.mod_settings["research-queue-table-width"].value)
                        if global.offset_tech[player.index] < row and row <= (player.mod_settings["research-queue-table-height"].value + global.offset_tech[player.index]) then
                            local frame1 = rq_table.add{type = "frame", name = "rq" .. name .. "background_frame", style = background1} --background frame
                            local pcall_status, frame2 = pcall(frame1.add, {type = "frame", name = name .. "frame", style = "rq-tech" .. name, tooltip = name}) --technology icon
                            if not pcall_status then
                                 pcall_status, frame2 = pcall(frame1.add, {type = "button", name = name .. "frame", caption = name, tooltip = name})  --technology icon
                            end

                            local caption = string.match(name, "%-%d+") --finds if the technology has a number (eg, autmation-2) and creates a label with that number
                            if caption then caption = string.gsub(caption, "%-", " ") end
                            local frame3 = frame2.add{type = "label", name = name .. "label", style = "rq-label", caption = caption}
                            local button = frame3.add{type = "button", name = "rq-add" .. name, style = "rq-button", tooltip = tech.localised_name}   --adds the final button that can be clicked on top.

                        elseif row == global.offset_tech[player.index] and not player.gui.center.Q.add2q.rqscrolltechup then
                            player.gui.center.Q.add2q.add{type = "button", name = "rqscrolltechup", style = "rq-up-button"}
                        elseif row > player.mod_settings["research-queue-table-height"].value + global.offset_tech[player.index] and not player.gui.center.Q.add2q.rqscrolltechdown then
                            player.gui.center.Q.add2q.add{type = "button", name = "rqscrolltechdown", style = "rq-down-button"}
                            break
                        end
                    else
                        local row = math.ceil(count / math.floor(player.mod_settings["research-queue-table-width"].value / 3))
                        if global.offset_tech[player.index] < row and row <= ((player.mod_settings["research-queue-table-height"].value*2) + global.offset_tech[player.index]) then
                            local frame = rq_table.add{type = "frame", name = "rqtextframe" .. name, style = "outer_frame"}
                            frame.add{type = "frame", name = name .. "frame", style = "rq-tech" .. name .. "small"}

                            local  pcall_status = pcall(frame.add, {type = "frame", name = name .. "frame", style = "rq-tech" .. name .. "small", tooltip = name})    --technology icon
                            if not pcall_status then
                                pcall_status = pcall(frame.add, {type = "button", name = name .. "frame", caption = name, tooltip = name})    --technology icon
                            end

                            frame.add{type = "button", name = "rq-add" .. name, caption = tech.localised_name, style = background2}
                        elseif row == global.offset_tech[player.index] and not player.gui.center.Q.add2q.rqscrolltechup then
                            player.gui.center.Q.add2q.add{type = "button", name = "rqscrolltechup", style = "rq-up-button"}
                        elseif row > (player.mod_settings["research-queue-table-height"].value*2) + global.offset_tech[player.index] and not player.gui.center.Q.add2q.rqscrolltechdown then
                            player.gui.center.Q.add2q.add{type = "button", name = "rqscrolltechdown", style = "rq-down-button"}
                            break
                        end
                    end
                end
            end
        end
    end
end

function drawGrid(force)
    for _, player in pairs(force.players) do
        if player.gui.center.Q then
            if player.gui.center.Q.add2q then player.gui.center.Q.add2q.destroy() end
            player.gui.center.Q.add{type = "frame", name = "add2q", caption = "Add to queue", style = "technology_preview_frame", direction = "vertical"}
            options(player)
            technologies(player)
--          if not pcall(technologies, player)
--              then  player.print("Failed to load tech...")
--          end
        end
    end
end
