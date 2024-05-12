local category = "fuel-unification"
local assembler = "fuel-unifier"
local fuel_names = {fluid = "heat-transfer-fluid", item = "heat-conducting-fuel"}

data:extend({
    {
        type = "fluid",
        name = fuel_names.fluid,
        icons = {{
            icon = "__base__/graphics/icons/fluid/light-oil.png",
            icon_size = 64,
            icon_mipmaps = 4,
            tint = {r=1, g=0.2, b=0.5}
        }},
        heat_capacity = "1MJ",
        base_color = {r=1, g=0.1, b=0.1},
        flow_color = {r=1, g=1, b=1},
        default_temperature = 15,
        max_temperature = 100
    }
})

if mods["aai-industry"] then
    category = "fuel-processing"
else
    data:extend({
        {
            type = "recipe-category",
            name = category
        }
    })

    local assembler_proto = table.deepcopy(data.raw["assembling-machine"]["chemical-plant"])
    assembler_proto.name = assembler
    assembler_proto.module_specification.module_slots = 1

    data:extend({assembler_proto})
end

if mods["aai-industry"] then
    return
end
