mod_gui = require("mod-gui")
science_flow = nil
resource_flow = nil
main_frame = nil
main_frame_flow = nil
main_frame_button = nil
detect_science_recipe = function(ingrs, c)
    local red_sc = 0
    local green_sc = 0
    local blue_sc = 0
    local gray_sc = 0
    local purple_sc = 0
    local yellow_sc = 0
    local white_sc = 0
    for i, ingr in ipairs(ingrs) do
        if ingr.name == "automation-science-pack" then
            red_sc = c
        elseif ingr.name == "logistic-science-pack" then
            green_sc = c
        elseif ingr.name == "chemical-science-pack" then
            blue_sc = c
        elseif ingr.name == "military-science-pack" then
            gray_sc = c
        elseif ingr.name == "production-science-pack" then
            purple_sc = c
        elseif ingr.name == "utility-science-pack" then
            yellow_sc = c
        elseif ingr.name == "space-science-pack" then
            white_sc = c
        end
    end
    return {
        red = red_sc,
        green = green_sc,
        blue = blue_sc,
        gray = gray_sc,
        purple = purple_sc,
        yellow = yellow_sc,
        white = white_sc
    }
end
recursive_technology_recipe = function(tech, player)
    if not tech.researched then
        if next(tech.prerequisites) == nil then
            return detect_science_recipe(tech.research_unit_ingredients, tech.research_unit_count)
        else
            local totalScience = detect_science_recipe(tech.research_unit_ingredients, tech.research_unit_count)
            for x, prereq in pairs(tech.prerequisites) do
                local stech = player.force.technologies[x]
                local science = recursive_technology_recipe(stech, player)
                totalScience.red = totalScience.red + science.red
                totalScience.green = totalScience.green + science.green
                totalScience.blue = totalScience.blue + science.blue
                totalScience.gray = totalScience.gray + science.gray
                totalScience.purple = totalScience.purple + science.purple
                totalScience.yellow = totalScience.yellow + science.yellow
                totalScience.white = totalScience.white + science.white
            end
            return totalScience
        end
    else
        return {
            red = 0,
            green = 0,
            blue = 0,
            gray = 0,
            purple = 0,
            yellow = 0,
            white = 0
        }
    end
end
calculate_total_raw = function(event)
    local player = game.get_player(event.player_index)
    if not science_flow or not resource_flow then
        science_flow = mod_gui.get_frame_flow(player)["ttrrc_main_frame"]["ttrrc_main_frame_flow"]["ttrrc_total_science_flow"]
        resource_flow = mod_gui.get_frame_flow(player)["ttrrc_main_frame"]["ttrrc_main_frame_flow"]["ttrrc_total_raw_flow"]
    end
    local tech_name = event.element.elem_value
    if tech_name == nil then
        science_flow["ttrrc_total_flow_red"].number = 0
        science_flow["ttrrc_total_flow_green"].number = 0
        science_flow["ttrrc_total_flow_blue"].number = 0
        science_flow["ttrrc_total_flow_gray"].number = 0
        science_flow["ttrrc_total_flow_yellow"].number = 0
        science_flow["ttrrc_total_flow_purple"].number = 0
        science_flow["ttrrc_total_flow_white"].number = 0
        resource_flow["ttrrc_total_flow_iron"].number = 0
        resource_flow["ttrrc_total_flow_copper"].number = 0
        resource_flow["ttrrc_total_flow_stone"].number = 0
        resource_flow["ttrrc_total_flow_coal"].number = 0
        resource_flow["ttrrc_total_flow_oil"].number = 0
    else
        local tech = player.force.technologies[tech_name]
        local red_res
        local grn_res
        local blu_res
        local gry_res
        local prl_res
        local ylw_res
        local wht_res
        local resources
        if game.difficulty_settings.recipe_difficulty == defines.difficulty_settings.recipe_difficulty.expensive then
            -- expensive
            red_res = {1, 4} -- Copper, Iron, Stone, Coal, Crude Oil
            grn_res = {4, 9.5}
            blu_res = {18, 24, 0, 3, 150}
            gry_res = {2.5, 9.5, 10, 5}
            prl_res = {46.7, 102.5, 11.7, 6.7, 74.1}
            ylw_res = {96.7, 66, 0, 17.7, 733.4}
            wht_res = {101.8, 57.5, 0, 10, 324.7}
            resources = {red_res, grn_res, blu_res, gry_res, prl_res, ylw_res, wht_res}
        else
            -- normal
            red_res = {1, 2} -- Copper, Iron, Stone, Coal, Crude Oil
            grn_res = {1.5, 5.5}
            blu_res = {7.5, 12, 0, 1.5, 38.5}
            gry_res = {2.5, 7, 10, 5}
            prl_res = {19.2, 52.5, 11.7, 3.3, 74.1}
            ylw_res = {49.8, 33.3, 0, 3.8, 115.7}
            wht_res = {101.8, 57.5, 0, 10, 324.7}
            resources = {red_res, grn_res, blu_res, gry_res, prl_res, ylw_res, wht_res}
        end
        -- TODO: expensive recipes
        local total_science = recursive_technology_recipe(tech, player)
        science_flow["ttrrc_total_flow_red"].number = total_science.red
        science_flow["ttrrc_total_flow_green"].number = total_science.green
        science_flow["ttrrc_total_flow_blue"].number = total_science.blue
        science_flow["ttrrc_total_flow_gray"].number = total_science.gray
        science_flow["ttrrc_total_flow_yellow"].number = total_science.yellow
        science_flow["ttrrc_total_flow_purple"].number = total_science.purple
        science_flow["ttrrc_total_flow_white"].number = total_science.white
        local total_resources = {0, 0, 0, 0, 0}
        for x, z in ipairs(resources) do
            if x == 1 then
                total_resources[1] = total_resources[1] + (z[1] * total_science.red)
                total_resources[2] = total_resources[2] + (z[2] * total_science.red)
            elseif x == 2 then
                total_resources[1] = total_resources[1] + (z[1] * total_science.green)
                total_resources[2] = total_resources[2] + (z[2] * total_science.green)
            elseif x == 3 then
                total_resources[1] = total_resources[1] + (z[1] * total_science.blue)
                total_resources[2] = total_resources[2] + (z[2] * total_science.blue)
                total_resources[3] = total_resources[3] + (z[3] * total_science.blue)
                total_resources[4] = total_resources[4] + (z[4] * total_science.blue)
                total_resources[5] = total_resources[5] + (z[5] * total_science.blue)
            elseif x == 4 then
                total_resources[1] = total_resources[1] + (z[1] * total_science.gray)
                total_resources[2] = total_resources[2] + (z[2] * total_science.gray)
                total_resources[3] = total_resources[3] + (z[3] * total_science.gray)
                total_resources[4] = total_resources[4] + (z[4] * total_science.gray)
            elseif x == 5 then
                total_resources[1] = total_resources[1] + (z[1] * total_science.purple)
                total_resources[2] = total_resources[2] + (z[2] * total_science.purple)
                total_resources[3] = total_resources[3] + (z[3] * total_science.purple)
                total_resources[4] = total_resources[4] + (z[4] * total_science.purple)
                total_resources[5] = total_resources[5] + (z[5] * total_science.purple)
            elseif x == 6 then
                total_resources[1] = total_resources[1] + (z[1] * total_science.yellow)
                total_resources[2] = total_resources[2] + (z[2] * total_science.yellow)
                total_resources[3] = total_resources[3] + (z[3] * total_science.yellow)
                total_resources[4] = total_resources[4] + (z[4] * total_science.yellow)
                total_resources[5] = total_resources[5] + (z[5] * total_science.yellow)
            elseif x == 7 then
                total_resources[1] = total_resources[1] + (z[1] * total_science.white)
                total_resources[2] = total_resources[2] + (z[2] * total_science.white)
                total_resources[3] = total_resources[3] + (z[3] * total_science.white)
                total_resources[4] = total_resources[4] + (z[4] * total_science.white)
                total_resources[5] = total_resources[5] + (z[5] * total_science.white)
            end
        end
        resource_flow["ttrrc_total_flow_iron"].number = total_resources[1]
        resource_flow["ttrrc_total_flow_copper"].number = total_resources[2]
        resource_flow["ttrrc_total_flow_stone"].number = total_resources[3]
        resource_flow["ttrrc_total_flow_coal"].number = total_resources[4]
        resource_flow["ttrrc_total_flow_oil"].number = total_resources[5]
    end
end
-- Runtime
function createGui(player)
    --[[ if main_frame or mod_gui.get_frame_flow(player)["ttrrc_main_frame"] then
        mod_gui.get_frame_flow(player)["ttrrc_main_frame"].destroy()
        main_frame = nil
    end
    if main_frame_button or mod_gui.get_button_flow(player)["ttrrc_main_frame_button"] then
        mod_gui.get_button_flow(player)["ttrrc_main_frame_button"].destroy()
        main_frame_button = nil
    end ]]
    --game.print(mod_gui.get_frame_flow(player)["ttrrc_main_frame"].." "..mod_gui.get_button_flow(player)["ttrrc_main_frame_button"])
    if mod_gui.get_frame_flow(player)["ttrrc_main_frame"] or mod_gui.get_button_flow(player)["ttrrc_main_frame_frame"] then
        return
    end
    local frame_flow = mod_gui.get_frame_flow(player)
    local button_flow = mod_gui.get_button_flow(player)
    main_frame = frame_flow.add {
        type = "frame",
        name = "ttrrc_main_frame",
        caption = {"ttrrc-main-frame.title"}
    }
    main_frame_flow = main_frame.add {
        type = "flow",
        name = "ttrrc_main_frame_flow",
        direction = "vertical"
    }
    main_frame_button = button_flow.add {
        type = "sprite-button",
        name = "ttrrc_main_frame_button",
        tooltip = "TTRRC",
        sprite = "item/space-science-pack"
    }
    -- main_frame.style.size = {385, 225}
    if game.difficulty_settings.recipe_difficulty == defines.difficulty_settings.recipe_difficulty.expensive then
        main_frame_flow.add {
            type = "label",
            name = "ttrrc_expensive_warning_label_1",
            caption = {"ttrrc-main-frame.expensive-warning-1"}
        }
        main_frame_flow["ttrrc_expensive_warning_label_1"].style.font_color =
            {
                r = 1,
                g = 1,
                b = 0,
                a = 1
            }
        main_frame_flow.add {
            type = "label",
            name = "ttrrc_expensive_warning_label_2",
            caption = {"ttrrc-main-frame.expensive-warning-2"}
        }
        main_frame_flow["ttrrc_expensive_warning_label_2"].style.font_color =
            {
                r = 1,
                g = 1,
                b = 0,
                a = 1
            }
    end
    main_frame_flow.add {
        type = "label",
        name = "ttrrc_technology_label",
        caption = {"ttrrc-main-frame.technology"}
    }
    main_frame_flow.add {
        type = "choose-elem-button",
        name = "ttrrc_technology",
        elem_type = "technology"
    }

    main_frame_flow.add {
        type = "label",
        name = "ttrrc_total_label",
        caption = {"ttrrc-main-frame.total"}
    }
    science_flow = main_frame_flow.add {
        type = "flow",
        name = "ttrrc_total_science_flow"
    }
    science_flow.add {
        type = "sprite-button",
        name = "ttrrc_total_flow_red",
        sprite = "item/automation-science-pack",
        number = 0
    }
    science_flow.add {
        type = "sprite-button",
        name = "ttrrc_total_flow_green",
        sprite = "item/logistic-science-pack",
        number = 0
    }
    science_flow.add {
        type = "sprite-button",
        name = "ttrrc_total_flow_blue",
        sprite = "item/chemical-science-pack",
        number = 0
    }
    science_flow.add {
        type = "sprite-button",
        name = "ttrrc_total_flow_gray",
        sprite = "item/military-science-pack",
        number = 0
    }
    science_flow.add {
        type = "sprite-button",
        name = "ttrrc_total_flow_purple",
        sprite = "item/production-science-pack",
        number = 0
    }
    science_flow.add {
        type = "sprite-button",
        name = "ttrrc_total_flow_yellow",
        sprite = "item/utility-science-pack",
        number = 0
    }
    science_flow.add {
        type = "sprite-button",
        name = "ttrrc_total_flow_white",
        sprite = "item/space-science-pack",
        number = 0
    }

    resource_flow = main_frame_flow.add {
        type = "flow",
        name = "ttrrc_total_raw_flow"
    }
    resource_flow.add {
        type = "sprite-button",
        name = "ttrrc_total_flow_iron",
        sprite = "item/iron-ore",
        number = 0
    }
    resource_flow.add {
        type = "sprite-button",
        name = "ttrrc_total_flow_copper",
        sprite = "item/copper-ore",
        number = 0
    }
    resource_flow.add {
        type = "sprite-button",
        name = "ttrrc_total_flow_stone",
        sprite = "item/stone",
        number = 0
    }
    resource_flow.add {
        type = "sprite-button",
        name = "ttrrc_total_flow_coal",
        sprite = "item/coal",
        number = 0
    }
    resource_flow.add {
        type = "sprite-button",
        name = "ttrrc_total_flow_oil",
        sprite = "fluid/crude-oil",
        number = 0
    }
end
script.on_event(defines.events.on_player_created, function(event)
    local player = game.get_player(event.player_index)
    createGui(player)
end)
script.on_event(defines.events.on_gui_click, function(event)
    local player = game.get_player(event.player_index)
    if event.element.name == "ttrrc_main_frame_button" then
        mod_gui.get_frame_flow(player)["ttrrc_main_frame"].visible = not mod_gui.get_frame_flow(player)["ttrrc_main_frame"].visible
    end
end)
script.on_event(defines.events.on_gui_elem_changed, calculate_total_raw)
script.on_event(defines.events.on_player_joined_game, function(event)
    local player = game.get_player(event.player_index)
    createGui(player)
end)
