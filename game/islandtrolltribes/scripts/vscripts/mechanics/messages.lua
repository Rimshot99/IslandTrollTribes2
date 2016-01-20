function SendErrorMessage( pID, string )
    Notifications:ClearBottom(pID)
    Notifications:ClearBottomFromAll()
    Notifications:Bottom(pID, {text=string, style={color='#E62020'}, duration=2})
    EmitSoundOnClient("General.Cancel", PlayerResource:GetPlayer(pID))
end

function GetEnglishTranslation(key, tooltipType)
    -- Adjust for 
    if tooltipType == "ability" then
        key = "DOTA_Tooltip_ability_"..key
    end
    return GameRules.EnglishTooltips.Tokens[key]
end