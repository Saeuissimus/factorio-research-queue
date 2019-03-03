local big_size = 64
local small_size = 32

data.raw["gui-style"].default["rq-tool-selected-filter"] =
{
    type = "button_style",
    parent = "image_tab_selected_slot",
    width = 36,
    height = 36
}

data.raw["gui-style"].default["rq-tool-inactive-filter"] =
{
    type = "button_style",
    parent = "image_tab_slot",
    width = 36,
    height = 36
}

data.raw["gui-style"].default["rq-tool-frame"] =
{
    type = "frame_style",
    width = 20,
    height = 20,
    scalable = true,
    align = "left",
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    flow_style =
    {
        type = "flow_style",
        horizontal_spacing = 0,
        vertical_spacing = 0
    },
    font = "rq-label-text"
}

data.raw["gui-style"].default["rq-ingredient-sprite"] =
{
    type = "button_style",
    parent = "small_slot_button",
    scalable = true,
    align = "left",
}

if bobmods ~= nil then
    if bobmods.modules ~= nil then
        log("research queue: Found Bob mods modules")
        data.raw["gui-style"].default["rq-bobsmodules"] =
        {
            type = "checkbox_style",
            top_padding = 0,
            right_padding = 0,
            bottom_padding = 0,
            left_padding = 0,
            width = small_size,
            height = small_size,
            scalable = false,
            left_click_sound =
            {
                {
                filename = "__core__/sound/gui-click.ogg",
                volume = 1
                }
            },
            default_background =
            {
                filename = "__bobmodules__/graphics/icons/god-module.png",
                priority = "extra-high-no-scale",
                width = 32,
                height = 32,
                x = 0,
                y = 0
            },
            hovered_background =
            {
                filename = "__bobmodules__/graphics/icons/god-module.png",
                priority = "extra-high-no-scale",
                width = 32,
                height = 32,
                x = 0,
                y = 0
            },
            clicked_background =
            {
                filename = "__bobmodules__/graphics/icons/god-module.png",
                priority = "extra-high-no-scale",
                width = 32,
                height = 32,
                x = 0,
                y = 0
            },
            checked =
            {
                filename = "__research-queue__/graphics/gui_elements.png",
                priority = "extra-high-no-scale",
                width = 32,
                height = 32,
                x = 96,
                y = 64
            }
        }
    end
end

if data.raw.technology["alien-research"] then
    log("research queue: Found Bob mods aliens")
    data.raw["gui-style"].default["rq-bobsalien"] =
    {
        type = "checkbox_style",
        top_padding = 0,
        right_padding = 0,
        bottom_padding = 0,
        left_padding = 0,
        width = small_size,
        height = small_size,
        scalable = false,
        left_click_sound =
        {
            {
            filename = "__core__/sound/gui-click.ogg",
            volume = 1
            }
        },
        default_background =
        {
            filename = "__base__/graphics/icons/alien-artifact-goo.png",
            priority = "extra-high-no-scale",
            width = 32,
            height = 32,
            x = 0,
            y = 0
        },
        hovered_background =
        {
            filename = "__base__/graphics/icons/alien-artifact-goo.png",
            priority = "extra-high-no-scale",
            width = 32,
            height = 32,
            x = 0,
            y = 0
        },
        clicked_background =
        {
            filename = "__base__/graphics/icons/alien-artifact-goo.png",
            priority = "extra-high-no-scale",
            width = 32,
            height = 32,
            x = 0,
            y = 0
        },
        checked =
        {
            filename = "__research-queue__/graphics/gui_elements.png",
            priority = "extra-high-no-scale",
            width = 32,
            height = 32,
            x = 96,
            y = 64
        }
    }
end

data.raw["gui-style"].default["rq-top-button"] =
{
    type = "button_style",
    parent = "button",
    left_click_sound =
    {
        {
        filename = "__core__/sound/gui-click.ogg",
        volume = 1
        }
    },
}

data:extend(
{
    {
        type = "sprite",
        name = "rq-text-view-icon",
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        x = 0,
        y = 64
    },
    {
        type = "sprite",
        name = "rq-completed-research-icon",
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        x = 0,
        y = 96
    }
})

data.raw["gui-style"].default["rq-done-frame"] =
{
    type = "frame_style",
    width = big_size + 4,
    height = big_size + 4,
    scalable = false,
    align = "center",
    graphical_set =
    {
        border = 0,
        filename = "__core__/graphics/gui.png",
        priority = "extra-high-no-scale",
        width = 36,
        height = 36,
        x = 111,
        y = 108
    },
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    flow_style =
    {
        type = "flow_style",
        horizontal_spacing = 0,
        vertical_spacing = 0
    }
}

data.raw["gui-style"].default["rq-inq-frame"] =
{
    type = "frame_style",
    width = big_size + 4,
    height = big_size + 4,
    scalable = false,
    align = "center",
    graphical_set =
    {
        border = 2,
        filename = "__core__/graphics/gui.png",
        priority = "extra-high-no-scale",
        width = 36,
        height = 36,
        x = 111,
        y = 72
    },
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    flow_style =
    {
        type = "flow_style",
        horizontal_spacing = 0,
        vertical_spacing = 0
    }
}

data.raw["gui-style"].default["rq-available-frame"] =
{
    type = "frame_style",
    width = big_size + 4,
    height = big_size + 4,
    scalable = false,
    align = "center",
    graphical_set =
    {
        border = 2,
        filename = "__core__/graphics/gui.png",
        priority = "extra-high-no-scale",
        width = 36,
        height = 36,
        x = 75,
        y = 72
    },
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    flow_style =
    {
        type = "flow_style",
        horizontal_spacing = 0,
        vertical_spacing = 0
    }
}

data.raw["gui-style"].default["rq-button"] =
{
    type = "button_style",
    font = "default",
    default_font_color = {r = 1, g = 1, b = 1},
    align = "center",
    scalable = false,
    left_click_sound =
    {
        {
        filename = "__core__/sound/gui-click.ogg",
        volume = 1
        }
    },
    width = big_size,
    height = big_size,
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    default_graphical_set =
    {
        border = 2,
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        x = 96,
        y = 96
    },
    hovered_font_color = {r = 1, g = 1, b = 1},
    hovered_graphical_set =
    {
        border = 2,
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        x = 0,
        y = 0
    },
    clicked_font_color = {r = 1, g = 1, b = 1},
    clicked_graphical_set =
    {
        border = 2,
        filename = "__core__/graphics/gui.png",
        priority = "extra-high-no-scale",
        width = 36,
        height = 36,
        x = 148,
        y = 0
    },
}

data.raw["gui-style"].default["rq-dummy-button"] =
{
    type = "button_style",
    font = "default",
    default_font_color = {r = 1, g = 1, b = 1},
    align = "center",
    scalable = false,
    width = big_size,
    height = big_size,
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    default_graphical_set =
    {
        border = 2,
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        x = 96,
        y = 96
    },
    hovered_font_color = {r = 1, g = 1, b = 1},
    hovered_graphical_set =
    {
        border = 2,
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        x = 96,
        y = 96
    },
    clicked_font_color = {r = 1, g = 1, b = 1},
    clicked_graphical_set =
    {
        border = 2,
        filename = "__core__/graphics/gui.png",
        priority = "extra-high-no-scale",
        width = 36,
        height = 36,
        x = 96,
        y = 96
    },
}

data.raw["gui-style"].default["rq-small-dummy-button"] =
{
    type = "button_style",
    font = "default",
    default_font_color = {r = 1, g = 1, b = 1},
    align = "center",
    scalable = false,
    width = small_size,
    height = small_size,
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    default_graphical_set =
    {
        border = 2,
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        x = 96,
        y = 96
    },
    hovered_font_color = {r = 1, g = 1, b = 1},
    hovered_graphical_set =
    {
        border = 2,
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        x = 96,
        y = 96
    },
    clicked_font_color = {r = 1, g = 1, b = 1},
    clicked_graphical_set =
    {
        border = 2,
        filename = "__core__/graphics/gui.png",
        priority = "extra-high-no-scale",
        width = 36,
        height = 36,
        x = 96,
        y = 96
    },
}

data:extend(
{{
    type = "font",
    name = "rq-label-text",
    from = "default-bold",
    size = 14,
    border = true,
    border_color = {}
}})

data.raw["gui-style"].default["rq-label"] =
{
    type = "label_style",
    parent = "label",
    font = "rq-label-text",
    -- font = "default-bold",
    scalable = true,
    width = big_size,
    height = big_size,
}

data.raw["gui-style"].default["rq-small-label"] =
{
    type = "label_style",
    parent = "rq-label",
    width = 20,
    height = 20,
}

data.raw["gui-style"].default["rq-flow"] =
{
    type = "horizontal_flow_style",
    horizontal_spacing = 0,
    vertical_spacing = 0,
    max_on_row = 0,
    resize_row_to_width = true,
    resize_to_row_height = true
}

data.raw["gui-style"].default["rq-flow-vertical"] =
{
    type = "vertical_flow_style",
    horizontal_spacing = 0,
    vertical_spacing = 0,
    max_on_row = 0,
    resize_row_to_width = true,
    resize_to_row_height = true
}

data.raw["gui-style"].default["rq-frame"] =
{
    type = "frame_style",
    font = "heading-2",
    font_color = {r = 1, g = 1, b = 1},
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    graphical_set =
    {
        type = "composition",
        filename = "__core__/graphics/gui.png",
        priority = "extra-high-no-scale",
        corner_size = {3, 3},
        position = {8, 0}
    },
    flow_style =
    {
        type = "flow_style",
        horizontal_spacing = 1,
        vertical_spacing = 1
    }
}

data.raw["gui-style"].default["rq-up-button"] =
{
    type = "button_style",
    font = "default",
    align = "center",
    scalable = false,
    left_click_sound =
    {
        {
        filename = "__core__/sound/gui-click.ogg",
        volume = 1
        }
    },
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    width = 32,
    height = 16,
    default_graphical_set =
    {
        border = 0,
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 16,
        x = 32,
        y = 0
    },
    hovered_graphical_set =
    {
        border = 0,
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 16,
        x = 64,
        y = 0
    },
    clicked_graphical_set =
    {
        border = 0,
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 16,
        x = 96,
        y = 0
    },
    disabled_graphical_set =
    {
        border = 0,
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 16,
        x = 96,
        y = 96
    }
}

data.raw["gui-style"].default["rq-down-button"] =
{
    type = "button_style",
    font = "default",
    align = "center",
    scalable = false,
    left_click_sound =
    {
        {
        filename = "__core__/sound/gui-click.ogg",
        volume = 1
        }
    },
    top_padding = 1,
    right_padding = 1,
    bottom_padding = 1,
    left_padding = 1,
    width = 32,
    height = 16,
    default_graphical_set =
    {
        border = 0,
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 16,
        x = 32,
        y = 16
    },
    hovered_graphical_set =
    {
        border = 0,
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 16,
        x = 64,
        y = 16
    },
    clicked_graphical_set =
    {
        border = 0,
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 16,
        x = 96,
        y = 16
    },
    disabled_graphical_set =
    {
        border = 0,
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 16,
        x = 96,
        y = 96
    }
}

data.raw["gui-style"].default["rq-cancel-button"] =
{
    type = "button_style",
    font = "default",
    align = "center",
    scalable = false,
    left_click_sound =
    {
        {
        filename = "__core__/sound/gui-click.ogg",
        volume = 1
        }
    },
    top_padding = 1,
    right_padding = 1,
    bottom_padding = 1,
    left_padding = 1,
    width = small_size,
    height = small_size,
    default_graphical_set =
    {
        border = 0,
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        x = 32,
        y = 32
    },
    hovered_graphical_set =
    {
        border = 0,
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        x = 64,
        y = 32
    },
    clicked_graphical_set =
    {
        border = 0,
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        x = 96,
        y = 32
    },
    disabled_graphical_set = {
        border = 0,
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        x = 96,
        y = 96
    }
}

data.raw["gui-style"].default["rq-done-button"] =
{
    type = "button_style",
    font = "default-semibold",
    default_font_color = {r = 1, g = 1, b = 1},
    align = "center",
    left_click_sound =
    {
        {
        filename = "__core__/sound/gui-click.ogg",
        volume = 1
        }
    },
    horizontally_stretchable = "on",
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    default_graphical_set =
    {
        type = "composition",
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        corner_size = {3, 3},
        position = {0, 32}
    },
    hovered_font_color = {r = 1, g = 1, b = 1},
    hovered_graphical_set =
    {
        type = "composition",
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        corner_size = {3, 3},
        position = {8, 32}
    },
    clicked_font_color = {r = 1, g = 1, b = 1},
    clicked_graphical_set =
    {
        type = "composition",
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        corner_size = {3, 3},
        position = {16, 32}
    }
}

data.raw["gui-style"].default["rq-inq-button"] =
{
    type = "button_style",
    font = "default-semibold",
    default_font_color = {r = 1, g = 1, b = 1},
    align = "center",
    left_click_sound =
    {
        {
        filename = "__core__/sound/gui-click.ogg",
        volume = 1
        }
    },
    horizontally_stretchable = "on",
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    default_graphical_set =
    {
        type = "composition",
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        corner_size = {3, 3},
        position = {0, 40}
    },
    hovered_font_color = {r = 1, g = 1, b = 1},
    hovered_graphical_set =
    {
        type = "composition",
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        corner_size = {3, 3},
        position = {8, 40}
    },
    clicked_font_color = {r = 1, g = 1, b = 1},
    clicked_graphical_set =
    {
        type = "composition",
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        corner_size = {3, 3},
        position = {16, 40}
    }
}

data.raw["gui-style"].default["rq-available-button"] =
{
    type = "button_style",
    font = "default-semibold",
    default_font_color = {r = 1, g = 1, b = 1},
    align = "center",
    left_click_sound =
    {
        {
        filename = "__core__/sound/gui-click.ogg",
        volume = 1
        }
    },
    horizontally_stretchable = "on",
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    default_graphical_set =
    {
        type = "composition",
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        corner_size = {3, 3},
        position = {0, 48}
    },
    hovered_font_color = {r = 1, g = 1, b = 1},
    hovered_graphical_set =
    {
        type = "composition",
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        corner_size = {3, 3},
        position = {8, 48}
    },
    clicked_font_color = {r = 1, g = 1, b = 1},
    clicked_graphical_set =
    {
        type = "composition",
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        corner_size = {3, 3},
        position = {16, 48}
    }
}

data.raw["gui-style"].default["rq-table1"] =
{
    type = "table_style",
    horizontal_spacing = 2,
    vertical_spacing = 2
}

data.raw["gui-style"].default["rq-table2"] =
{
    type = "table_style",
    horizontal_spacing = 6,
    vertical_spacing = 6
}

data.raw["gui-style"].default["rq-compact-button"] =
{
    type = "button_style",
    font = "default",
    align = "center",
    scalable = false,
    left_click_sound =
    {
        {
        filename = "__core__/sound/gui-click.ogg",
        volume = 1
        }
    },
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    width = 32,
    height = 32,
    default_graphical_set =
    {
        border = 0,
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        x = 0,
        y = 128
    },
    hovered_graphical_set =
    {
        border = 0,
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        x = 32,
        y = 128
    },
    clicked_graphical_set =
    {
        border = 0,
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        x = 64,
        y = 128
    }
}

data.raw["gui-style"].default["rq-extend-button"] =
{
    type = "button_style",
    font = "default",
    align = "center",
    scalable = false,
    left_click_sound =
    {
        {
        filename = "__core__/sound/gui-click.ogg",
        volume = 1
        }
    },
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    width = 32,
    height = 32,
    default_graphical_set =
    {
        border = 0,
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        x = 0,
        y = 160
    },
    hovered_graphical_set =
    {
        border = 0,
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        x = 32,
        y = 160
    },
    clicked_graphical_set =
    {
        border = 0,
        filename = "__research-queue__/graphics/gui_elements.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        x = 64,
        y = 160
    }
}

data.raw["gui-style"].default["rq-clock"] =
{
    type = "frame_style",
    width = 20,
    height = 20,
    scalable = true,
    graphical_set =
    {
        border = 0,
        filename = "__core__/graphics/clock-icon.png",
        priority = "extra-high-no-scale",
        width = 32,
        height = 32,
        x = 0,
        y = 0
    },
    align = "left",
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    flow_style =
    {
        type = "flow_style",
        horizontal_spacing = 0,
        vertical_spacing = 0
    },
    font = "rq-label-text"
}

data.raw["gui-style"].default["rq-warning-icon"] =
{
    type = "frame_style",
    width = 80,
    height = 71,
    scalable = true,
    graphical_set =
    {
        border = 0,
        icon_size = 64,
        filename = "__core__/graphics/warning-icon.png",
        priority = "extra-high-no-scale",
        width = 64,
        height = 64,
        x = 0,
        y = 0
    },
    align = "center",
    top_padding = 2,
    right_padding = 2,
    bottom_padding = 2,
    left_padding = 2
}