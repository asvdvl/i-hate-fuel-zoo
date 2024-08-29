local assembler = "fuel-unifier"
local fluid_assembler = 'fluid-'..assembler
local assemblers_tech_effects = {assembler, assembler.."-recraft", fluid_assembler.."-recraft"}

script.on_init(function ()
    --search for tech
    local techs = {}
    for name, tech_table in pairs(game.technology_prototypes) do
        for _, effect in pairs(tech_table.effects) do
            if effect.type == "unlock-recipe" and (effect.recipe == assembler or effect.recipe == fluid_assembler) then
                for _, asm_name in pairs(assemblers_tech_effects) do
                    if effect.recipe == asm_name then
                        techs[name] = true
                    end
                end
            end
        end
    end

    --check for researched
    for tech_name in pairs(techs) do
        for _, force in pairs(game.forces) do
            local tech = force.technologies[tech_name]
            if tech.researched then
                for _, asm in pairs(assemblers_tech_effects) do
                    force.recipes[asm].enabled = true
                end
            end
        end
    end
end)