-- Takes dropped items nearby and checks the quick_craft.kv table for a recipe match
function QuickCraftWorkshop(keys)
    print("QuickCrafting")
    local caster = keys.caster
    local range = 500--keys.Range, should be an ability special with AbilityCastRange
       
    -- Table used to look up herb recipes, can move this if other functions need it
    local recipeTable = GameRules.QuickCraft['Recipes']

    local myMaterials = {}
    local itemTable = {}

    -- Get all items dropped nearby
    local drops = Entities:FindAllByClassnameWithin("dota_item_drop", caster:GetAbsOrigin(), range)  --get the item in the slot
    
    print("Check for match")
    local match
    -- Check if the items dropped match any recipe
    -- The order that the reciepes are compared might matter in the results, it will be a bit random with this method
    for recipeName,recipeIngredients in pairs(recipeTable) do 
        
        -- If the drop list contains enough of the ingredient items defined in the reciepeTable, it can be crafted and the drops need to be consumed
        local craftingItems = CanCraft(caster, recipeName, drops)
        if craftingItems then
            match = recipeName
            -- Create the resulting item
            caster:AddItem(CreateItem(recipeName, nil, nil))

            -- Clear the physical drops returned by the CanCraft aux
            ClearCraftingItems(craftingItems)   

            break  --end the function, only one item per mix
        end
    end

    if match then return
        print("QuickCrafting Created "..match)
    else
        print("No matches for QuickCrafting")
    end
end

-- Returns a list of crafting drops if the itemName can be crafted with the passed drops, false otherwise
function CanCraft( building, itemName, droppedContainers )
    local recipeTable = GameRules.QuickCraft[building:GetUnitName()]
    local required = recipeTable[itemName]
    
    local craftingItems = {}

    -- Go through the drops and check if there's enough of each ingredient
    for k,drop in pairs(droppedContainers) do
        local item = drop:GetContainedItem()
        local itemName = item:GetAbilityName()

        -- If the item is required for this craft, add if we don't have enough
        if required[itemName] then
            -- At least it will require 1 of the item
            if not craftingItems[itemName] then
                craftingItems[itemName] = {}
                table.insert(craftingItems[itemName], drop)

            -- If it requires more than 1 and we still don't have enough, keep adding
            elseif #craftingItems[itemName] < required[itemName] then
                table.insert(craftingItems[itemName], drop)
            end
        end
    end

    --[[ Debug Prints
    -- Compare that the craftingItems key & #values  and  required key & value match, that means we have enough ingredients
    print("Required Items for "..itemName..":")
    for k,v in pairs(required) do
        print(" "..k,v)
    end
    print("Crafting Items for "..itemName..":")
    for k,v in pairs(craftingItems) do
        print(" "..k,#v)
    end
    print("------------------------------------")]]

    -- Check that the crafting and the required items match, break at first fail
    for k,v in pairs(required) do
        if not craftingItems[k] or (#craftingItems[k] < required[k]) then
            return false
        end
    end

    return craftingItems
end

function ClearCraftingItems( droppedIngredients )
    print("Craft succesful, clearing items:")
    for dropNames,dropTable in pairs(droppedIngredients) do
        for k,drop in pairs(dropTable) do
            print("  Consumed",drop, drop:GetClassname(), drop:GetContainedItem():GetAbilityName())
            drop:RemoveSelf()
        end 
    end
end