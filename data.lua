local category = "fuel-unification"
local assembler = "fuel-unifier"
local fuel_params = {
    fluid = {
        name = "heat-transfer-fluid",
        value = "1MJ"
    },
    item = {
        name = "heat-conducting-fuel",
        value = "10MJ"
    }
}
local tint = {1, 0.5, 0.5}

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

if mods["aai-industry"] then
    category = "fuel-processing"
    assembler = "fuel-processor"
    fuel_params.item.name = "processed-fuel"
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
    local assembler_proto = table.deepcopy(data.raw["assembling-machine"]["chemical-plant"])
    assembler_proto.name = assembler
    assembler_proto.module_specification.module_slots = 0
    assembler_proto.crafting_categories = {category}
    assembler_proto.energy_usage = fuel_params.fluid.value

    assembler_proto.energy_source = {
        type = "burner",
        fuel_inventory_size = 1,
    }

    assembler_proto.icons = {{
        icon = assembler_proto.icon,
        icon_size = assembler_proto.icon_size,
        icon_mipmaps = assembler_proto.icon_mipmaps,
        tint = tint
    }}
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
    assembler_item_proto.icons = assembler_proto.icons

    local fuel_proto = table.deepcopy(data.raw["item"]["solid-fuel"])
    fuel_proto.name = fuel_params.item.name
    fuel_proto.fuel_value = fuel_params.item.value

    fuel_proto.icons = {{
        icon = fuel_proto.icon,
        icon_size = fuel_proto.icon_size,
        icon_mipmaps = fuel_proto.icon_mipmaps,
        tint = tint
    }}

    --wipe icons
    local protos = {assembler_proto, assembler_item_proto, fuel_proto}
    local icon_list = {"icon", "icon_size", "icon_mipmaps"}
    for _, proto in pairs(protos) do
        for _, key_icon in pairs(icon_list) do
            proto[key_icon] = nil
        end
    end
    data:extend(protos)

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
end

--recipe
data:extend({
    {
        type = "recipe",
        name = fuel_params.fluid.name,
        enabled = true,
        energy_required = 1,
        ingredients = {},
        category = category,
        results = {{type = 'fluid', name = fuel_params.fluid.name, amount = 1}},
    }
})

--assembler
local input_fb = {}
local asm_fluid_input = assembler.."-fluid-input"
local assembler_proto = table.deepcopy(data.raw["assembling-machine"][assembler])
assembler_proto.name = asm_fluid_input
assembler_proto.energy_usage = fuel_params.fluid.value

for key, fb in pairs(assembler_proto.fluid_boxes) do
    if fb.production_type == "input" then
        input_fb = fb
        assembler_proto.fluid_boxes[key] = nil
        break
    end
end
assembler_proto.energy_source = {
    type = "fluid",
    fluid_box = input_fb,
    scale_fluid_usage = true
}

--items
local assembler_item_proto = table.deepcopy(data.raw["item"][assembler])
assembler_item_proto.name = asm_fluid_input
assembler_item_proto.place_result = asm_fluid_input


