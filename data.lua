local category = "fuel-unification"
local assembler = "fuel-unifier"
local item_recipe_name = ""
local fuel_params = {
    fluid = {
        name = "heat-transfer-fluid",
        value = "10MJ"
    },
    item = {
        name = "heat-conducting-fuel",
        value = "10MJ"
    }
}
local tint = {1, 0.5, 0.5}
local timeToCraft = 100 / settings.startup["i-hate-fuel-zoo-convert-efficiency"].value

local function get_parent_assembler()
    return table.deepcopy(data.raw["assembling-machine"]["chemical-plant"])
end

if mods["aai-industry"] then
    category = "fuel-processing"
    assembler = "fuel-processor"
    local asm = data.raw["assembling-machine"]["fuel-processor"]
    asm.fixed_recipe = ""
    item_recipe_name = "fuel-processing"
    fuel_params.item.name = "processed-fuel"
    fuel_params.item.value = data.raw["item"]["processed-fuel"].fuel_value
    fuel_params.fluid.value = fuel_params.item.value
else
    data:extend({
        {
            type = "recipe-category",
            name = category
        },
        {
            type = "item-subgroup",
            name = category,
            group = "intermediate-products"
        }
    })

    --assembler
    local assembler_proto = get_parent_assembler()
    assembler_proto.name = assembler
    assembler_proto.module_specification.module_slots = 0
    assembler_proto.crafting_categories = {category}
    assembler_proto.energy_usage = "10MW"
    assembler_proto.allowed_effects = {}

    assembler_proto.energy_source = {
        type = "burner",
        fuel_inventory_size = 1,
    }

    assembler_proto.tint = tint

    for _, anim in pairs(assembler_proto.animation) do
        for _, layer in pairs(anim.layers) do
            if layer.filename and not layer.draw_as_shadow and layer.hr_version then
                layer.tint = tint
                layer.hr_version.tint = tint
            end
        end
    end

    --items
    local assembler_item_proto = table.deepcopy(data.raw["item"]["chemical-plant"])
    assembler_item_proto.subgroup = "smelting-machine"
    assembler_item_proto.name = assembler
    assembler_item_proto.place_result = assembler
    assembler_item_proto.icon = assembler_proto.icon
    assembler_item_proto.icon_size = assembler_proto.icon_size
    assembler_item_proto.icon_mipmaps = assembler_proto.icon_mipmaps

    local fuel_proto = table.deepcopy(data.raw["item"]["solid-fuel"])
    fuel_proto.name = fuel_params.item.name
    fuel_proto.fuel_value = fuel_params.item.value

    fuel_proto.tint = tint

    data:extend({assembler_proto, assembler_item_proto, fuel_proto})
    data:extend({
        {
            type = "recipe",
            name = fuel_params.item.name,
            enabled = true,
            energy_required = 1,
            ingredients = {},
            category = category,
            results = {{type = 'item', name = fuel_params.item.name, amount = 1}},
        }
    })
    item_recipe_name = fuel_params.item.name
end

data.raw["recipe"][item_recipe_name].energy_required = timeToCraft

--fluid
data:extend({
    {
        type = "fluid",
        name = fuel_params.fluid.name,
        icon = "__i-hate-fuel-zoo__/graphics/icons/heat-transfer-fluid.png",
        icon_size = 64,
        icon_mipmaps = 4,
        heat_capacity = "1kJ",
        fuel_value = fuel_params.fluid.value,
        gas_temperature = 15,
        base_color = tint,
        flow_color = tint,
        default_temperature = 100,
        max_temperature = 100
    }
})

--recipe
data:extend({
    {
        type = "recipe",
        name = fuel_params.fluid.name,
        enabled = true,
        energy_required = timeToCraft,
        ingredients = {},
        category = category,
        hide_from_player_crafting = true,
        results = {{type = 'fluid', name = fuel_params.fluid.name, amount = 1}},
    }
})

--assembler
local input_fb = {
    pipe_connections = {},
    production_type = "input-output",
    pipe_covers = {},
    pipe_picture = {},
    base_area = 1,
    base_level = -1,
    height = 2,
}
local asm_fluid_input = 'fluid-'..assembler
local assembler_proto = table.deepcopy(data.raw["assembling-machine"][assembler])
assembler_proto.name = asm_fluid_input
if assembler_proto.icons then
    assembler_proto.icons[1].tint = table.deepcopy(tint)
    assembler_proto.icons[1].tint[3] = 0.8
else
    if not assembler_proto.tint then
        assembler_proto.tint = tint
    end
    assembler_proto.tint[3] = 0.8
end

if not assembler_proto.fluid_boxes then
    assembler_proto.fluid_boxes = get_parent_assembler().fluid_boxes
end

for key, fb in pairs(assembler_proto.fluid_boxes) do
    if fb.production_type == "input" then
        table.insert(input_fb.pipe_connections, fb.pipe_connections[1])
        input_fb.pipe_covers = fb.pipe_covers
        input_fb.pipe_picture = fb.pipe_picture
        assembler_proto.fluid_boxes[key] = nil
    end
end
assembler_proto.energy_source = {
    type = "fluid",
    fluid_box = input_fb,
    burns_fluid = true,
    scale_fluid_usage = true
}

--items
local assembler_item_proto = table.deepcopy(data.raw["item"][assembler])
assembler_item_proto.name = asm_fluid_input
assembler_item_proto.place_result = asm_fluid_input

data:extend({assembler_proto, assembler_item_proto})
