print ('[ITT] itt.lua' )

TEAM_COLORS = {}
TEAM_COLORS[DOTA_TEAM_GOODGUYS] = { 52, 85, 255 } -- Blue
TEAM_COLORS[DOTA_TEAM_BADGUYS] = { 255, 52, 85 } -- Red
TEAM_COLORS[DOTA_TEAM_CUSTOM_1] = { 61, 210, 150 } -- Teal
TEAM_COLORS[DOTA_TEAM_CUSTOM_2] = { 140, 42, 244 } -- Purple
TEAM_COLORS[DOTA_TEAM_CUSTOM_3] = { 243, 201, 9 } -- Yellow
TEAM_COLORS[DOTA_TEAM_CUSTOM_4] = { 255, 108, 0 } -- Orange
TEAM_COLORS[DOTA_TEAM_CUSTOM_5] = { 101, 212, 19 } -- Green
TEAM_COLORS[DOTA_TEAM_CUSTOM_6] = { 197, 77, 168 } -- Pink
TEAM_COLORS[DOTA_TEAM_CUSTOM_7] = { 129, 83, 54 } -- Brown
TEAM_COLORS[DOTA_TEAM_CUSTOM_8] = { 199, 228, 13 } -- Olive
PLAYER_COLORS = {}
PLAYER_COLORS[0] = { 52, 85, 255 } -- Blue
PLAYER_COLORS[1] = { 255, 52, 85 } -- Red
PLAYER_COLORS[2] = { 61, 210, 150 } -- Teal
PLAYER_COLORS[3] = { 140, 42, 244 } -- Purple
PLAYER_COLORS[4] = { 243, 201, 9 } -- Yellow
PLAYER_COLORS[5] = { 255, 108, 0 } -- Orange
PLAYER_COLORS[6] = { 101, 212, 19 } -- Green
PLAYER_COLORS[7] = { 197, 77, 168 } -- Pink
PLAYER_COLORS[8] = { 129, 83, 54 } -- Brown
PLAYER_COLORS[9] = { 199, 228, 13 } -- Olive
PLAYER_COLORS[10] = { 105, 105, 255 } -- Light Blue
PLAYER_COLORS[11] = { 128, 128, 128 } -- Gray

playerList = {}
maxPlayerID = 0

GAME_TICK_TIME              = 0.1   -- The game should update every tenth second
GAME_CREATURE_TICK_TIME     = 120    -- Time for each creature spawn
GAME_BUSH_TICK_TIME         = 30    --1in2 chance any bush will actually spawn so average timer is 2x
GAME_TROLL_TICK_TIME        = 0.5   -- Its really like its wc3!
FLASH_ACK_THINK             = 2
WIN_GAME_THINK              = 0.5 -- checks if you've won every x seconds

BUILDING_TICK_TIME          = 0.03
DROPMODEL_TICK_TIME         = 0.03

-- Game periods determine what is allowed to spawn, from start (0) to X seconds in
GAME_PERIOD_GRACE           = 420
GAME_PERIOD_EARLY           = 900

-- Grace period respawn time in seconds
GRACE_PERIOD_RESPAWN_TIME    = 3

DEBUG_SPEW = 1

-- Tick time is 300s
-- https://github.com/island-troll-tribes/wc3-client/blob/1562854dd098180752f0f4a99df0c4968697b38b/src/systems/spawning/Spawn%20Normal.j#L3
-- GAME_ITEM_TICK_TIME         = 300

-- Using a shorter time for testing's sake
--GAME_ITEM_TICK_TIME         = 15

-- If this is enabled the game is in testing mode, and as a result nobody can win
GAME_TESTING_CHECK          = true 
-- Use this variable for anything that can ONLY happen during testing
-- REMEMBER TO DISABLE BEFORE PUBLIC RELEASE

--Merchant Boat paths, and other lists
PATH1 = {"path_ship_waypoint_1","path_ship_waypoint_2","path_ship_waypoint_3","path_ship_waypoint_4","path_ship_waypoint_5", "path_ship_waypoint_6", "path_ship_waypoint_7"}
PATH2 = {"path_ship_waypoint_8","path_ship_waypoint_9","path_ship_waypoint_4","path_ship_waypoint_5", "path_ship_waypoint_6", "path_ship_waypoint_7"}
PATH3 = {"path_ship_waypoint_1","path_ship_waypoint_2","path_ship_waypoint_3","path_ship_waypoint_4","path_ship_waypoint_5", "path_ship_waypoint_10", "path_ship_waypoint_11", "path_ship_waypoint_12"}
PATH4 = {"path_ship_waypoint_8","path_ship_waypoint_9","path_ship_waypoint_4","path_ship_waypoint_5", "path_ship_waypoint_10", "path_ship_waypoint_11", "path_ship_waypoint_12"}
PATH_LIST = {PATH1, PATH2, PATH3, PATH4}
SHOP_UNIT_NAME_LIST = {"npc_ship_merchant_1", "npc_ship_merchant_2", "npc_ship_merchant_3"}
TOTAL_SHOPS = #SHOP_UNIT_NAME_LIST
MAX_SHOPS_ON_MAP = 1

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function ITT:InitGameMode()
    GameMode = GameRules:GetGameModeEntity()

    -- This is the creature thinker. All neutral creature spawn logic goes here
    GameMode:SetThink( "OnCreatureThink", ITT, "CreatureThink", 2 )
    GameMode.neutralCurNum = {}
    GameMode.neutralCurNum["npc_creep_elk_wild"] = 0
    GameMode.neutralCurNum["npc_creep_hawk"] = 0
    GameMode.neutralCurNum["npc_creep_fish"] = 0
    GameMode.neutralCurNum["npc_creep_fish_green"] = 0
    GameMode.neutralCurNum["npc_creep_wolf_jungle"] = 0
    GameMode.neutralCurNum["npc_creep_bear_jungle"] = 0
    GameMode.neutralCurNum["npc_creep_lizard"] = 0
    GameMode.neutralCurNum["npc_creep_panther"] = 0
    GameMode.neutralCurNum["npc_creep_panther_elder"] = 0
    GameMode.neutralCurNum["npc_creep_mammoth"] = 0

    -- DebugPrint
    Convars:RegisterConvar('debug_spew', tostring(DEBUG_SPEW), 'Set to 1 to start spewing debug info. Set to 0 to disable.', 0)

    -- This is the troll thinker. All logic on the player's heros should be checked here
    GameMode:SetThink( "OnTrollThink", ITT, "TrollThink", 0 )

    -- This is the building thinker. All logic on building crafting goes here
    GameMode:SetThink( "OnBuildingThink", ITT, "BuildingThink", 0 )

    -- This is the item thinker. All random item spawn logic goes here
    GameMode:SetThink( "OnItemThink", ITT, "ItemThink", 0 )

     -- This is the herb bush thinker. All herb spawn logic goes here
    GameMode:SetThink( "OnBushThink", ITT, "BushThink", 0 )

     -- This is the boat thinker. All boat logic goes here
    GameMode:SetThink( "OnBoatThink", ITT, "BoatThink", 0 )

    GameMode:SetThink("OnCheckWinThink", ITT,"CheckWinThink",0)
    
    boatStartTime = math.floor(GameRules:GetGameTime())
    GameMode.spawnedShops = {}
    GameMode.shopEntities = Entities:FindAllByName("entity_ship_merchant_*")

    GameMode:SetThink("FixDropModels", ITT, "FixDropModels", 0)

    GameMode:SetCustomHeroMaxLevel ( 6 ) -- No accidental overleveling

    -- Disable buybacks to stop instant respawning.
    GameMode:SetBuybackEnabled( false )
    GameMode:SetStashPurchasingDisabled(true)

    --GameRules:GetGameModeEntity():ClientLoadGridNav()
    GameRules:SetSameHeroSelectionEnabled( true )
    GameRules:SetTimeOfDay( 0.75 )
    GameRules:SetHeroRespawnEnabled( true )
    GameRules:SetHeroSelectionTime(0)
    GameRules:SetPreGameTime(GAME_PERIOD_GRACE)
    GameRules:SetPostGameTime( 60.0 )
    GameRules:SetTreeRegrowTime( 60.0 )
    GameRules:SetCreepMinimapIconScale( 0.7 )
    GameRules:SetRuneMinimapIconScale( 0.7 )
    GameRules:SetGoldTickTime( 60.0 )
    GameRules:SetGoldPerTick( 0 )

    -- Listen for a game event.
    -- A list of events is findable here: https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/Built-In_Engine_Events
    -- A bunch of those are broken, so be warned
    -- Custom events can be made in /scripts/custom_events.txt
    -- BROKEN:
    -- dota_item_drag_end dota_item_drag_begin dota_inventory_changed dota_inventory_item_changed
    -- dota_inventory_changed_query_unit dota_inventory_item_added
    -- WORK:
    -- dota_item_picked_up dota_item_purchased
    ListenToGameEvent('player_connect_full', Dynamic_Wrap(ITT, 'OnPlayerConnectFull'), self)

    -- Use this for assigning items to heroes initially once they pick their hero.
    ListenToGameEvent( "dota_player_pick_hero", Dynamic_Wrap( ITT, "OnPlayerPicked" ), self )

    -- Use this for dealing with subclass spawning
    ListenToGameEvent( "npc_spawned", Dynamic_Wrap( ITT, "OnNPCSpawned" ), self )

    --Listener for items picked up, used for telegather abilities
    ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(ITT, 'OnItemPickedUp'), self)

    ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(ITT, 'OnPlayerGainedLevel'), self)

    --Listener for storing hero information and revive
    ListenToGameEvent("dota_player_killed", Dynamic_Wrap(ITT, 'OnDotaPlayerKilled'), self)

    -- Listener for drops and for removing buildings from block table
    ListenToGameEvent("entity_killed", Dynamic_Wrap( ITT, "OnEntityKilled" ), self )

    ListenToGameEvent("entity_hurt", Dynamic_Wrap(ITT, 'On_entity_hurt'), self)
    ListenToGameEvent('player_chat', Dynamic_Wrap(ITT, 'OnPlayerChat'), self)

    -- Panorama Listeners
    CustomGameEventManager:RegisterListener( "update_selected_entities", Dynamic_Wrap(ITT, 'OnPlayerSelectedEntities'))
    CustomGameEventManager:RegisterListener( "player_selected_class", Dynamic_Wrap( ITT, "OnClassSelected" ) )
    CustomGameEventManager:RegisterListener( "player_selected_subclass", Dynamic_Wrap( ITT, "OnSubclassChange" ) )

    CustomGameEventManager:RegisterListener( "player_sleep", Dynamic_Wrap( ITT, "Sleep" ) )
    CustomGameEventManager:RegisterListener( "player_eat_meat", Dynamic_Wrap( ITT, "EatMeat" ) )
    CustomGameEventManager:RegisterListener( "player_drop_meat", Dynamic_Wrap( ITT, "DropMeat" ) )
    CustomGameEventManager:RegisterListener( "player_drop_all_meat", Dynamic_Wrap( ITT, "DropAllMeat" ) )
    CustomGameEventManager:RegisterListener( "player_panic", Dynamic_Wrap( ITT, "Panic" ) )

    CustomGameEventManager:RegisterListener( "player_bush_gather", Dynamic_Wrap( ITT, "BushGather" ) )

    -- Building Helper commands
    CustomGameEventManager:RegisterListener( "building_helper_build_command", Dynamic_Wrap(BuildingHelper, "BuildCommand"))
    CustomGameEventManager:RegisterListener( "building_helper_cancel_command", Dynamic_Wrap(BuildingHelper, "CancelCommand"))
    
    -- Store and update selected units of each pID
    GameRules.SELECTED_UNITS = {}

    -- Filters
    GameMode:SetExecuteOrderFilter( Dynamic_Wrap( ITT, "FilterExecuteOrder" ), self )

    --for multiteam
    ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( ITT, 'OnGameRulesStateChange' ), self )

    --multiteam stuff
    self.m_TeamColors = {}
    print("DOTA_TEAM_GOODGUYS "..DOTA_TEAM_GOODGUYS, "DOTA_TEAM_BADGUYS "..DOTA_TEAM_BADGUYS, "DOTA_TEAM_CUSTOM_1 "..DOTA_TEAM_CUSTOM_1)
    self.m_TeamColors[DOTA_TEAM_GOODGUYS] = { 255, 0, 0 }
    self.m_TeamColors[DOTA_TEAM_BADGUYS] = { 0, 255, 0 }
    self.m_TeamColors[DOTA_TEAM_CUSTOM_1] = { 0, 0, 255 }
    print(self.m_TeamColors[DOTA_TEAM_GOODGUYS], self.m_TeamColors[DOTA_TEAM_BADGUYS], self.m_TeamColors[DOTA_TEAM_CUSTOM_1])

    self.m_VictoryMessages = {}
    self.m_VictoryMessages[DOTA_TEAM_GOODGUYS] = "#VictoryMessage_GoodGuys"
    self.m_VictoryMessages[DOTA_TEAM_BADGUYS] = "#VictoryMessage_BadGuys"
    self.m_VictoryMessages[DOTA_TEAM_CUSTOM_1] = "#VictoryMessage_Custom1"

    self.m_GatheredShuffledTeams = {}
    self.m_NumAssignedPlayers = 0

    self:GatherValidTeams()

    self.vUserIds = {}
    self.vPlayerUserIds = {}

    GameRules:GetGameModeEntity():SetThink( "OnThink", self, 1 )

    --initial bush spawns
    --place entities starting with spawner_ plus the appropriate name to spawn to corresponding bush on game start
    local bush_herb_spawners = Entities:FindAllByClassname("npc_dota_spawner")
    GameRules.Bushes = {}
    for _,spawner in pairs(bush_herb_spawners) do
        local spawnerName = spawner:GetName()
        if string.find(spawnerName, "_bush_") then
            local bush_name = string.sub(string.gsub(spawner:GetName(), "spawner_", ""), 5)
            local bush = CreateUnitByName(bush_name, spawner:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
            if bush then
                table.insert(GameRules.Bushes, bush)
            end
        end
    end
    local bushCount = #GameRules.Bushes
    print("Spawned "..bushCount.." bushes total")

    -- Change random seed
    local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
    math.randomseed(tonumber(timeTxt))

    -- spawner_npc_bush_herb
    -- spawner_npc_bush_river
    -- spawner_npc_bush_mushroom
    -- spawner_npc_bush_thistle
    -- spawner_npc_bush_stash
    -- spawner_npc_bush_herb_yellow
    -- spawner_npc_bush_herb_blue
    -- spawner_npc_bush_herb_purple
    -- spawner_npc_bush_herb_orange
    -- spawner_npc_bush_thief
    -- spawner_npc_bush_scout

    --prepare neutral spawns
    self.NumPassiveNeutrals = 0
    self.NumAggressiveNeutrals = 0

    GameRules.APPLIER = CreateItem("item_apply_modifiers", nil, nil)

    -- Custom Stats for STR/AGI/INT
    Stats:Init()

    -- KV Tables
    GameRules.ClassInfo = LoadKeyValues("scripts/kv/class_info.kv")
    GameRules.BushInfo = LoadKeyValues("scripts/kv/bush_info.kv")
    GameRules.ItemInfo = LoadKeyValues("scripts/kv/item_info.kv")
    GameRules.QuickCraft = LoadKeyValues("scripts/kv/quick_craft.kv")
    GameRules.AbilityKV = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
    GameRules.ItemKV = LoadKeyValues("scripts/npc/npc_items_custom.txt")
    GameRules.UnitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")
    GameRules.HeroKV = LoadKeyValues("scripts/npc/npc_heroes_custom.txt")

    -- Check Syntax
    if (not GameRules.AbilityKV) or (not GameRules.ItemKV) or (not GameRules.UnitKV) or (not GameRules.HeroKV) then
        print("--------------------------------------------------\n\n")
        print("SYNTAX ERROR IN KEYVALUE FILES")
        print("npc_abilities_custom: ", GameRules.AbilityKV)
        print("npc_items_custom:     ", GameRules.ItemKV)
        print("npc_units_custom:     ", GameRules.UnitKV)
        print("npc_heroes_custom:    ", GameRules.HeroKV)
        print("--------------------------------------------------\n\n")
    end

    -- items_game parsing
    GameRules.ItemsGame = LoadKeyValues("scripts/items/items_game.txt")
    modelmap = {}
    itemskeys = GameRules.ItemsGame['items']
    MapModels()

    -- Allow cosmetic swapping
    SendToServerConsole( "dota_combine_models 0" )

    -- Lua Modifiers
    LinkLuaModifier("modifier_chicken_form", "heroes/beastmaster/subclass_modifiers.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_pack_leader", "heroes/beastmaster/subclass_modifiers.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_shapeshifter", "heroes/beastmaster/subclass_modifiers.lua", LUA_MODIFIER_MOTION_NONE)
    
    -- Grace Period
    GameMode:SetFixedRespawnTime(GRACE_PERIOD_RESPAWN_TIME)
    Timers:CreateTimer({
        endTime = GAME_PERIOD_GRACE,
        callback = function()
            print("End of grace period.")
            GameRules:SetHeroRespawnEnabled( false )
            UnblockMammoth()
        end
    })
end

 --disables rosh pit
function UnblockMammoth()
    print("Trying to delete ent_blockers")
    local ent = Entities:FindAllByName("ent_blocker")
    if table.getn(ent) > 0 then
        type(ent)
        for i,v in pairs(ent) do
            print("deleting ent"..i)
            v:SetEnabled(false,false)
            v:RemoveSelf()
        end
    else
        print("name entblocker doesn't exist")
    end
end

local classes = { 
    [1] = "hunter",
    [2] = "gatherer",
    [3] = "scout",
    [4] = "thief",
    [5] = "priest",
    [6] = "mage",
    [7] = "beastmaster",
}

--Handler for class selection at the beginning of the game
function ITT:OnClassSelected(event)
    local playerID = event.PlayerID
    local class_name = event.selected_class
    local player = PlayerResource:GetPlayer(playerID)
    local team = PlayerResource:GetTeam(playerID)

    -- Handle random selection
    if class_name == "random" then
        class_name = classes[RandomInt(1,7)]
    end

    local hero_name = GameRules.ClassInfo['Classes'][class_name]

    local player_name = PlayerResource:GetPlayerName(playerID)
    if player_name == "" then player_name = "Player "..playerID end

    print("SelectClass "..hero_name)

    CustomGameEventManager:Send_ServerToTeam(team, "team_update_class", { class_name = class_name, player_name = player_name})

    PrecacheUnitByNameAsync(hero_name, function()
        CreateHeroForPlayer(hero_name, player)
        print("[ITT] CreateHeroForPlayer: ",playerID,hero_name)
    end, playerID)
end

-- This code is written by Internet Veteran, handle with care.
--Distribute slot locked items based off of the class.
function ITT:OnPlayerPicked( keys )
    local spawnedUnit = EntIndexToHScript( keys.heroindex )

    local class = spawnedUnit:GetClassname()
end

-- This code is written by Internet Veteran, handle with care.
--Do the same now for the subclasses
function ITT:OnNPCSpawned( keys )
    local spawnedUnit = EntIndexToHScript( keys.entindex )
    --print("spawned unit: ", spawnedUnit:GetUnitName(), spawnedUnit:GetClassname(), spawnedUnit:GetName(), spawnedUnit:GetEntityIndex())
    
    -- add it to the gridnav to stop people building on it
    --BuildingHelper:AddUnit(spawnedUnit)

    if spawnedUnit:IsRealHero() then
        if not spawnedUnit.bFirstSpawned then
            spawnedUnit.bFirstSpawned = true
            ITT:OnHeroInGame(spawnedUnit)
        else
            ITT:OnHeroRespawn(spawnedUnit)
        end
    end
end

function ITT:OnHeroInGame( hero )

    -- Remove starting gold
    hero:SetGold(0, false)

    -- Create locked slots
    ITT:CreateLockedSlots(hero)

    -- Add Innate Skills
    ITT:AdjustSkills(hero)

    -- Initial Heat
    Heat:Start(hero)

    -- Init Meat, Health and Energy Loss
    ApplyModifier(hero, "modifier_meat_passive")
    ApplyModifier(hero, "modifier_hunger")

    -- Set Wearables
    ITT:SetDefaultCosmetics(hero)

    -- Adjust Stats
    Stats:ModifyBonuses(hero)
end

function ITT:OnHeroRespawn( hero )

    -- Restart Heat
    Heat:Start(hero)

    -- Restart Meat tracking
    ApplyModifier(hero, "modifier_meat_passive")
end

-- This handles locking a number of inventory slots for some classes
-- This means that players do not need to manually reshuffle them to craft
function ITT:CreateLockedSlots(hero)
    
    local lockedSlotsTable = GameRules.ClassInfo['LockedSlots']
    local className = GetHeroClass(hero)
    local lockedSlotNumber = lockedSlotsTable[className]
    
    local lockN = 5
    for n=0,lockedSlotNumber-1 do
        hero:AddItem(CreateItem("item_slot_locked", hero, spawnedUnit))
        hero:SwapItems(0, lockN)
        lockN = lockN -1
    end
end

-- Sets the hero skills for the level as defined in the 'SkillProgression' class_info.kv
-- Called on spawn and every time a hero gains a level or chooses a subclass
function ITT:AdjustSkills( hero )
    local skillProgressionTable = GameRules.ClassInfo['SkillProgression']
    local class = GetHeroClass(hero)
    local level = hero:GetLevel() --Level determines what skills to add or levelup
    hero:SetAbilityPoints(0) --All abilities are learned innately

    -- If the hero has a subclass, use that table instead
    if HasSubClass(hero) then
        class = GetSubClass(hero)
    end

    local class_skills = skillProgressionTable[class]
    if not class_skills then
        print("ERROR: No 'SkillProgression' table found for"..class.."!")
        return
    end

    -- Check for any skill in the 'unlearn' subtable
    local unlearn_skills = skillProgressionTable[class]['unlearn']
    if unlearn_skills then
        local unlearn_skills_level = unlearn_skills[tostring(level)]
        if unlearn_skills_level then
            local unlearn_ability_names = split(unlearn_skills_level, ",")

            for _,abilityName in pairs(unlearn_ability_names) do
                local ability = hero:FindAbilityByName(abilityName)
                if ability then
                    hero:RemoveAbility(abilityName)
                end
            end
        end
    end
    
    -- Learn/Upgrade all abilities for this level    
    local level_skills = skillProgressionTable[class][tostring(level)]
    if level_skills and level_skills ~= "" then
        print("[ITT] AdjustSkills for "..class.." at level "..level)
        local ability_names = split(level_skills, ",")

        -- If the ability already exists, upgrade it, otherwise add it at level 1
        for _,abilityName in pairs(ability_names) do
            local ability = hero:FindAbilityByName(abilityName)
            if ability then
                ability:UpgradeAbility(false)
            else
                TeachAbility(hero, abilityName)
            end
        end
        print("------------------------------")
    else
        print("No skills to change for "..class.." at level "..level)
    end

    AdjustAbilityLayout(hero)
    PrintAbilities(hero)
end


function ITT:OnEntityKilled(keys)
    local dropTable = {
        --{"unit_name", {"item_1", drop_chance}, {"mutually_exclusive_item_1", "mutually_exclusive_item_2", drop_chance}},
        {"npc_creep_elk_wild", {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_hide_elk", 100}, {"item_bone", 100}},
        {"npc_creep_wolf_jungle", {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_hide_wolf", 100}, {"item_bone", 100}},
        {"npc_creep_bear_jungle", {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_hide_jungle_bear", 100}, {"item_bone", 100}},
        {"npc_creep_bear_jungle_adult", {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_hide_jungle_bear", 100}, {"item_bone", 100}},
        {"npc_creep_panther", {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_bone", 100}, {"item_bone", 100}},
        {"npc_creep_panther_elder", {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_bone", 100}, {"item_bone", 100}},
        {"npc_creep_lizard", {"item_meat_raw", 100}},
        {"npc_creep_fish_green", {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}},
        {"npc_creep_fish", {"item_meat_raw", 100}},
        {"npc_creep_hawk", {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_bone", 100}, {"item_egg_hawk", 10}},
        {"npc_creep_mammoth", {"item_bone", 100},{"item_bone", 100},{"item_bone", 100},{"item_bone", 100},{"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_meat_raw", 100}, {"item_horn_mammoth", 100}, {"item_horn_mammoth", 50}}
    }
    local spawnTable = {
                        {"npc_creep_elk_wild","npc_creep_fawn"},
                        {"npc_creep_wolf_jungle","npc_creep_wolf_pup"},
                        {"npc_creep_bear_jungle","npc_creep_bear_cub"},
                        {"npc_creep_bear_jungle_adult","npc_creep_bear_cub"}}

    local killedUnit = EntIndexToHScript(keys.entindex_killed)
    local killer = EntIndexToHScript(keys.entindex_attacker or 0)
    -- local keys.entindex_inflictor --long
    -- local keys.damagebits --long
    local unitName = killedUnit:GetUnitName()
    print(unitName .. " has been killed")

    -- Corpses
    if string.find(unitName, "creep") then
        corpse = CreateUnitByName("npc_creep_corpse", killedUnit:GetAbsOrigin(), false, nil, nil, 0)
        corpse.killer = killer

        -- Set the corpse invisible until the dota corpse disappears
        corpse:AddNoDraw()
            
        -- Keep a reference to its name and expire time
        corpse.corpse_expiration = GameRules:GetGameTime() + 90
        corpse.unit_name = killedUnit:GetUnitName()

        -- Set custom corpse visible
        Timers:CreateTimer(3, function() if IsValidEntity(corpse) then corpse:RemoveNoDraw() end end)

        -- Remove itself after the corpse duration
        Timers:CreateTimer(90, function()
            if corpse and IsValidEntity(corpse) then
                corpse:RemoveSelf()
            end
        end)
    end

    if string.find(unitName, "building") then
        killedUnit:RemoveBuilding(2, false)
    end
    
    -- remove from gridnav
    -- cannot get this to work properly, have not found any side effects to not removing units
    -- but it seems like it should happen
    -- print("unit is ", killedUnit)
    -- BuildingHelper:RemoveUnit(killedUnit)

    --deal with killed heros
    if killedUnit.IsHero and killedUnit:IsHero() then
        --if it's a hero, drop all carried raw meat, plus 3, and a bone
        meatStacks = killedUnit:GetModifierStackCount("modifier_meat_passive", nil)
        for i= 1, meatStacks+3, 1 do
            local newItem = CreateItem("item_meat_raw", nil, nil)
            CreateItemOnPositionSync(killedUnit:GetOrigin() + RandomVector(RandomInt(20,100)), newItem)
        end
        local newItem = CreateItem("item_bone", nil, nil)
        CreateItemOnPositionSync(killedUnit:GetOrigin() + RandomVector(RandomInt(20,100)), newItem)

        -- Launch all carried items excluding the fillers
        for i=0,5 do
            local item = killedUnit:GetItemInSlot(i)
            if item and item:GetAbilityName() ~= "item_slot_locked" then
                killedUnit:DropItemAtPositionImmediate(item, killedUnit:GetAbsOrigin())
                local pos = killedUnit:GetAbsOrigin()
                local pos_launch = pos+RandomVector(RandomFloat(100,150))
                item:LaunchLoot(false, 200, 0.75, pos_launch)
            end
        end


    else
    --drop system
    for _,v in pairs(dropTable) do
        if unitName == v[1] then
            for itemNum = 2,#v,1 do
                itemName = v[itemNum][1]
                itemChance = v[itemNum][2]

                if RandomInt(0, 100) <= itemChance then
                    local newItem = CreateItem(itemName, nil, nil)
                    CreateItemOnPositionSync(killedUnit:GetOrigin() + RandomVector(RandomInt(20,100)), newItem)
                end
            end
        end
    end

    --spawn young animals
    local dieRoll = RandomInt(1,20)
    local chance = 1
    local bonusChance = killedUnit:GetModifierStackCount("modifier_spawn_chance",nil)
    if bonusChance ~= nil then
        chance = chance + bonusChance
    end

    if dieRoll <= chance then
        print("Success! Spawning young animal")
        for _,v in pairs(spawnTable) do
            if unitName == v[1] then
                CreateUnitByName(v[2],killedUnit:GetOrigin(), true,nil,nil,killer:GetTeam())
            end
        end
    end

    --tracking number of neutrals
    --local numOfUnit = GameMode.neutralCurNum[unitName]
    if GameMode.neutralCurNum[unitName] ~= nil then
        GameMode.neutralCurNum[unitName] = GameMode.neutralCurNum[unitName] - 1
        end
    end
end

function ITT:OnDotaPlayerKilled(keys)
    local playerId = keys.PlayerID
    print(playerId)
    --print(PlayerResource:GetPlayer(playerID):GetAssignedHero())
end

function ITT:On_entity_hurt(data)
    --print("entity_hurt")
    local attacker = EntIndexToHScript(data.entindex_attacker)
    local killed = EntIndexToHScript(data.entindex_killed)
    if (string.find(killed:GetUnitName(), "elk") or string.find(killed:GetUnitName(), "fish") or string.find(killed:GetUnitName(), "hawk")) then
        killed.state = "flee"
    end
    --print("attacker: "..attacker:GetUnitName(), "killed: "..killed:GetUnitName())

end

function ITT:FixDropModels(dt)
    for _,v in pairs(Entities:FindAllByClassname("dota_item_drop")) do
        if not v.ModelFixInit then
            --print("initing.. " .. v:GetContainedItem():GetAbilityName())
            v.ModelFixInit = true
            v.OriginalOrigin = v:GetOrigin()
            v.OriginalAngles = v:GetAngles()
            local custom = GameRules.ItemKV[v:GetContainedItem():GetAbilityName()].Custom
            if custom then
                --print("found custom")
                if custom.ModelOffsets then
                    local offsets = GameRules.ItemKV[v:GetContainedItem():GetAbilityName()].Custom.ModelOffsets
                    v:SetOrigin( v.OriginalOrigin - Vector(offsets.Origin.x, offsets.Origin.y, offsets.Origin.z))
                    v:SetAngles( v.OriginalAngles.x - offsets.Angles.x, v.OriginalAngles.y - offsets.Angles.y, v.OriginalAngles.z - offsets.Angles.z)
                end
                if custom.ModelScale then v:SetModelScale(custom.ModelScale) end
            end
        end
    end
    return DROPMODEL_TICK_TIME
end

-- This updates state on each troll
-- Every half second it updates heat, checks inventory for items, etc
-- Add anything you want to run regularly on each troll to this
function ITT:OnTrollThink()

    --if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        -- Will not run until pregame ends
       -- return 1
    --end

    -- This will run on every player, do stuff here
    for i=1, maxPlayerID, 1 do
        --Hunger(i)
        --Energy(i)
        --Heat(i)
        InventoryCheck(i)
        --print("burn")
    end
    return GAME_TROLL_TICK_TIME
end

function ITT:OnBuildingThink()
    --RE-ENABLE AFTER TESTING
    --if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        --Will not run until pregame ends
        --return 1
    --end

    -- Find all buildings
    buildings = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                                  Vector(0, 0, 0),
                                  nil,
                                  FIND_UNITS_EVERYWHERE,
                                  DOTA_UNIT_TARGET_TEAM_BOTH,
                                  DOTA_UNIT_TARGET_BUILDING,
                                  DOTA_UNIT_TARGET_FLAG_NONE,
                                  FIND_ANY_ORDER,
                                  false)
    --check each for their type, and run crafting with the corresponding table
    for i, building in pairs(buildings) do
        if building:GetUnitName() == "npc_building_armory" then
            CraftItems(building, ARMORY_RECIPE_TABLE, ITEM_ALIAS_TABLE)
        elseif building:GetUnitName() == "npc_building_workshop" then
            CraftItems(building, WORKSHOP_RECIPE_TABLE, ITEM_ALIAS_TABLE)
        elseif building:GetUnitName() == "npc_building_hut_witch_doctor" then
            CraftItems(building, WDHUT_RECIPE_TABLE, ITEM_ALIAS_TABLE)
        end
    end
    return GAME_TROLL_TICK_TIME
end

-- This is similar, but handles spawning creatures
function ITT:OnCreatureThink()

    MAXIMUM_PASSIVE_NEUTRALS    = 300 --this isn't implemented yet
    MAXIMUM_AGGRESSIVE_NEUTRALS = 20

    if math.floor(GameRules:GetGameTime())>GAME_PERIOD_EARLY then
    neutralSpawnTable = {
        --{"creep_name", "spawner_name", spawn_chance, number_to_spawn},
        {"npc_creep_elk_wild",      "spawner_neutral_elk",      100, 2},
        {"npc_creep_hawk",          "spawner_neutral_hawk",     100, 2},
        {"npc_creep_fish",          "spawner_neutral_fish",     100, 5},
        {"npc_creep_fish_green",    "spawner_neutral_fish",     100, 2},
        {"npc_creep_wolf_jungle",   "spawner_neutral_wolf",     100, 1},
        {"npc_creep_bear_jungle",   "spawner_neutral_bear",     100, 1},
        {"npc_creep_lizard",        "spawner_neutral_lizard",   100, 1},
        {"npc_creep_panther",       "spawner_neutral_panther",  100, 1},
    --  {"npc_creep_mammoth",       "spawner_neutral_mammoth",  0, 0},
    --   {"npc_creep_panther_elder", "spawner_neutral_panther",  100, 1},
    }
        elseif math.floor(GameRules:GetGameTime())>GAME_PERIOD_GRACE then
        neutralSpawnTable = {
        --{"creep_name", "spawner_name", spawn_chance, number_to_spawn},
        {"npc_creep_elk_wild",      "spawner_neutral_elk",      100, 2},
        {"npc_creep_hawk",          "spawner_neutral_hawk",     100, 2},
        {"npc_creep_fish",          "spawner_neutral_fish",     100, 5},
        {"npc_creep_fish_green",    "spawner_neutral_fish",     100, 2},
        {"npc_creep_wolf_jungle",   "spawner_neutral_wolf",     66, 1},
        {"npc_creep_bear_jungle",   "spawner_neutral_bear",     50, 1},
        {"npc_creep_lizard",        "spawner_neutral_lizard",   33, 1},
        {"npc_creep_panther",       "spawner_neutral_panther",  5, 1},
    --  {"npc_creep_mammoth",       "spawner_neutral_mammoth",  0, 0},
    --   {"npc_creep_panther_elder", "spawner_neutral_panther",  100, 1},
    }
    else --at the start
        neutralSpawnTable = {
        --{"creep_name", "spawner_name", spawn_chance, number_to_spawn},
        {"npc_creep_elk_wild",      "spawner_neutral_elk",      100, 2},
        {"npc_creep_hawk",          "spawner_neutral_hawk",     10, 2},
        {"npc_creep_fish",          "spawner_neutral_fish",     0, 5},
        {"npc_creep_fish_green",    "spawner_neutral_fish",     0, 2},
        {"npc_creep_wolf_jungle",   "spawner_neutral_wolf",     10, 1},
        {"npc_creep_bear_jungle",   "spawner_neutral_bear",     0, 1},
        {"npc_creep_lizard",        "spawner_neutral_lizard",   0, 1},
        {"npc_creep_panther",       "spawner_neutral_panther",  0, 1},
    --  {"npc_creep_mammoth",       "spawner_neutral_mammoth",  100, 1},
    --   {"npc_creep_panther_elder", "spawner_neutral_panther",  100, 1},
        }
        
        -- Spawn the mammoth at start
        -- This needs to go on its spot
        if (GameMode.neutralCurNum["npc_creep_mammoth"] == 0) then
            SpawnCreature("npc_creep_mammoth", "spawner_neutral_mammoth")
        end
            
        
    
    end

    neutralMaxTable = {}
        neutralMaxTable["npc_creep_elk_wild"] = 20
        neutralMaxTable["npc_creep_hawk"] = 8
        neutralMaxTable["npc_creep_fish"] = 20
        neutralMaxTable["npc_creep_fish_green"] = 10
        neutralMaxTable["npc_creep_wolf_jungle"] = 12
        neutralMaxTable["npc_creep_bear_jungle"] = 8
        neutralMaxTable["npc_creep_lizard"] = 8
        neutralMaxTable["npc_creep_panther"] = 4
        --neutralMaxTable["npc_creep_mammoth"] = 1
        --neutralMaxTable["npc_creep_panther_elder"] = 4

    for _,v in pairs(neutralSpawnTable) do
        local creepName = v[1]
        local spawnerName = v[2]
        local spawnChance = v[3]
        local numToSpawn = v[4]
        for i=1,numToSpawn do
            if (spawnChance >= RandomInt(1, 100)) and (GameMode.neutralCurNum[creepName] < neutralMaxTable[creepName]) then
                -- Don't spawn fish on land
                if creepName == "npc_creep_fish_green" or creepName == "npc_creep_fish" then
                    SpawnRandomCreature(creepName, true)
                else
                    SpawnRandomCreature(creepName, false)
                end
            end
        end
    end

    return GAME_CREATURE_TICK_TIME
end


function ITT:OnBushThink()
    --print("--Creating Items on Bushes--")
    
    local bushes = GameRules.Bushes
    
    for k,bush in pairs(bushes) do
        if bush.RngWeight == nil then --rng weight maks it so there's a chance a bush won't spawn but you won't get rng fucked
            bush.RngWeight = 0 --if rng weight doesnt exist declare it to a value that's unlikely to spawn for the first few ticks
        end

        local rand = RandomInt(-4,4) --randomize between -4 and +4, since the min is 0 with the best rng on the minimum number you will still not get a spawn
        
        if rand + bush.RngWeight >= 5 then 
            bush.RngWeight = bush.RngWeight - 1 --if spawn succeeds reduce the odds of the next spawn

            local bush_name = bush:GetUnitName()
            local bushTable = GameRules.BushInfo[bush_name]
            local possibleChoices = TableCount(bushTable)
            local randomN = tostring(RandomInt(1, possibleChoices))
            local bush_random_item = bushTable[randomN]

            GiveItemStack(bush, bush_random_item)

        else
            bush.RngWeight = bush.RngWeight + 1 --if spawn fails increase odds for next run
        end
    end

    return GAME_BUSH_TICK_TIME
end

function ITT:OnBoatThink()
    local currentTime = math.floor(GameRules:GetGameTime())
    local numShopsSpawned = 0
    for k,_ in pairs(GameMode.spawnedShops) do
        numShopsSpawned = numShopsSpawned + 1
    end

    if numShopsSpawned < MAX_SHOPS_ON_MAP then
        local pathNum = RandomInt(1, #PATH_LIST)
        local path = PATH_LIST[pathNum]

        local initialWaypoint = Entities:FindByName(nil, path[1])
        local spawnOrigin = initialWaypoint:GetOrigin()

        local merchantNum = RandomInt(1, TOTAL_SHOPS)
        unitName = SHOP_UNIT_NAME_LIST[merchantNum]
        local shopUnit = CreateUnitByName(unitName, spawnOrigin, false, nil, nil, DOTA_TEAM_NEUTRALS)
        shopUnit.path = path
        print("Spawning " .. unitName .. " on path " .. pathNum .. " at time " .. currentTime)
    end

    for _,shopUnit in pairs(GameMode.spawnedShops) do
        local shopent = nil
        for _,entity in pairs(GameMode.shopEntities) do
            local nameToFind = string.sub(shopUnit:GetUnitName(), 5)
            if string.find(entity:GetName(), nameToFind) then
                shopent = entity
            end
        end

        if shopent == nil then
            print("No Shop Ent Found!")
            return 0.1
        end

        --local shopent = Entities:FindAllByClassname("ent_dota_shop")
        if shopUnit ~= nil then
            if shopUnit:IsAlive() then
                shopent:SetOrigin(shopUnit:GetOrigin())
                shopent:SetForwardVector(shopUnit:GetForwardVector())
            else
                shopent:SetOrigin(Vector(10000,10000,120))
            end
        else
            shopent:SetOrigin(Vector(10000,10000,120))
        end
    end

    return 0.1
end

--This function checks if you won the game or not
function ITT:OnCheckWinThink()
   if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then --waits for pregame to end before you can win
    --win check here
        local goodteam = 0 --tallies for the 3 teams, X = players alive
        local badteam  = 0
        local cust1team = 0
        for playerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
            local player = PlayerResource:GetPlayer(playerID)
            if PlayerResource:IsValidPlayer(playerID) then
                local hero = player:GetAssignedHero()
                if nil ~= hero then
                    if hero:IsAlive() then
                        local team = PlayerResource:GetTeam(playerID)
                        if team == DOTA_TEAM_GOODGUYS then
                            goodteam = goodteam + 1
                        elseif team == DOTA_TEAM_BADGUYS then
                            badteam = badteam + 1
                        elseif team == DOTA_TEAM_CUSTOM_1 then
                            cust1team = cust1team + 1
                        else
                            print("Error 21232: Faction not found")
                        end
                    end
                end
            end
        end
        if goodteam==0 and badteam==0 and cust1team==0 then
            print("Draw")
            if not GAME_TESTING_CHECK then
                GameRules:SetSafeToLeave( true )
                --GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )     
            end
            return -1
        elseif cust1team==0 and badteam==0 then
            print("Team 1 wins")
            if not GAME_TESTING_CHECK then
                GameRules:SetSafeToLeave( true )
                GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )

            end
            return -1
        elseif goodteam==0 and cust1team==0 then
            print("Team 2 wins")     
            if not GAME_TESTING_CHECK then
                GameRules:SetSafeToLeave( true )
                GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )
            end
            return -1
        elseif goodteam==0 and badteam==0 then
            print("Team 3 wins")
            if not GAME_TESTING_CHECK then
                GameRules:SetSafeToLeave( true )
                GameRules:SetGameWinner( DOTA_TEAM_CUSTOM_1 )
            end
            return -1
        end
    end
    return WIN_GAME_THINK
end

-- When players connect, add them to the players list and begin operations on them
function ITT:OnPlayerConnectFull(keys)
    print ('[ITT] OnConnectFull')

    local entIndex = keys.index+1
    -- The Player entity of the joining user
    local ply = EntIndexToHScript(entIndex)

    -- The Player ID of the joining player
    local playerID = ply:GetPlayerID()

    playerList[playerID] = playerID
    maxPlayerID = maxPlayerID + 1

    -- Update the user ID table with this user
    self.vUserIds[keys.userid] = ply
    self.vPlayerUserIds[playerID] = keys.userid
end

-- Listener to handle item pickup (the rest of the pickup logic is tied to the order filter and item function mechanics)
function ITT:OnItemPickedUp(event)    
    if not event.HeroEntityIndex then
        print("A building just picked an item")
        return
    end

    local hero = EntIndexToHScript( event.HeroEntityIndex )
    local originalItem = EntIndexToHScript(event.ItemEntityIndex)
    local itemName = event.itemname

    local itemSlotRestriction = GameRules.ItemInfo['ItemSlots'][itemName]
    if itemSlotRestriction then
        local maxCarried = GameRules.ItemInfo['MaxCarried'][itemSlotRestriction]
        local count = GetNumItemsOfSlot(hero, itemSlotRestriction)

        -- Drop the item if the hero exceeds the possible max carried amount
        if count > maxCarried then
            local origin = hero:GetAbsOrigin()
            hero:DropItemAtPositionImmediate(originalItem, origin)
            local pos_launch = origin+RandomVector(100)
            originalItem:LaunchLoot(false, 200, 0.75, pos_launch)

            SendErrorMessage(hero:GetPlayerOwnerID(), "#error_cant_carry_more_"..itemSlotRestriction) --Concatenated error message
        end
    end

    local hasTelegather = hero:HasModifier("modifier_telegather")
    local hasTelethief = hero:HasModifier("modifier_thief_telethief")

    -- Related to RadarTelegathererInit
    if hasTelegather then

        local targetFire = hero.targetFire
        local newItem = CreateItem(originalItem:GetName(), nil, nil)

        local itemList = {"item_tinder", "item_flint", "item_stone", "item_stick", "item_bone", "item_meat_raw", "item_crystal_mana", "item_clay_ball", "item_river_root", "item_river_stem", "item_thistles", "item_acorn", "item_acorn_magic", "item_mushroom"}
        for key,value in pairs(itemList) do
            if value == originalItem:GetName() then
                print( "Teleporting Item", originalItem:GetName())
                hero:RemoveItem(originalItem)
                local itemPosition = targetFire:GetAbsOrigin() + RandomVector(RandomInt(100,150))
                CreateItemOnPositionSync(itemPosition,newItem)
                newItem:SetOrigin(itemPosition)
            end
        end
    end

    -- Related to TeleThiefInit
    if hasTelethief then
        
        local newItem = CreateItem(originalItem:GetName(), nil, nil)
        local fireLocation = hero.fire_location

        local radius = hero.radius
        local teamNumber = hero:GetTeamNumber()
        local buildings = FindUnitsInRadius(teamNumber, caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        
        if buildings ~= null then
            print("Teleporting Item", originalItem:GetName())
            hero:RemoveItem(originalItem)
            local itemPosition = targetFire:GetAbsOrigin() + RandomVector(RandomInt(100,150))
            CreateItemOnPositionSync(itemPosition,newItem)
            newItem:SetOrigin(itemPosition)
        else
            print("Did not find enemy buildings")
        end
    end
end

--Listener to handle level up
function ITT:OnPlayerGainedLevel(event)
    local player = EntIndexToHScript(event.player)
    local playerID = player:GetPlayerID()
    local hero = player:GetAssignedHero()
    local class = GetHeroClass(hero)
    local level = event.level

    print("[ITT] OnPlayerLevelUp - Player "..playerID.." ("..class..") has reached level "..level)
	
    -- If the hero reached level 6 and hasn't unlocked a subclass, make the button clickable
    if level >= 6 and not HasSubClass(hero) then
        CustomGameEventManager:Send_ServerToPlayer(player, "player_unlock_subclass", {})
    end
	
	if level == 6 and not HasSubClass(hero) then
        local particleName = "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_spirit_form_ambient.vpcf"
        hero.subclassAvailableParticle = ParticleManager:CreateParticleForTeam(particleName, PATTACH_ABSORIGIN_FOLLOW, hero, hero:GetTeamNumber())

        EmitSoundOnClient("SubSelectReady", PlayerResource:GetPlayer(playerID))
    end

    -- Update skills
    ITT:AdjustSkills( hero )
end

function print_dropped_vecs(cmdname)
    local items = Entities:FindAllByClassname("dota_item_drop")
    for _,v in pairs(items) do
        print(v:GetClassname())
        local now = v:GetOrigin()
        v:SetOrigin(Vector(now.x, now.y, now.z - 146))
        v:SetModelScale(1.8)
    end
end

function print_fix_diffs(cmdname)
    local items = Entities:FindAllByClassname("dota_item_drop")
    for _,v in pairs(items) do
        local angs = v:GetAngles()
        local difforig = v.OriginalOrigin - v:GetOrigin()
        local diffangs = {x = v.OriginalAngles.x - angs.x, y = v.OriginalAngles.y - angs.y, z = v.OriginalAngles.z - angs.z} --i dunno either, exception w/o :__sub just for this
        print(v:GetContainedItem():GetAbilityName() .. " Offsets: ")
        print("\"Custom\"")
        print("{")
        print("    \"ModelOffsets\"")
        print("    {")
        print("        \"Origin\"")
        print("        {")
        print("            \"x\" \"" .. difforig.x .. "\"")
        print("            \"y\" \"" .. difforig.x .. "\"")
        print("            \"z\" \"" .. difforig.z .. "\"")
        print("        }")
        print("        \"Angles\"")
        print("        {")
        print("            \"x\" \"" .. diffangs.x .. "\"")
        print("            \"y\" \"" .. diffangs.x .. "\"")
        print("            \"z\" \"" .. diffangs.z .. "\"")
        print("        }")
        print("    }")
        print("}")
    end
end

Convars:RegisterCommand("print_fix_diffs", function(cmdname) print_fix_diffs(cmdname) end, "Give any item", 0)
Convars:RegisterCommand("print_dropped_vecs", function(cmdname) print_dropped_vecs(cmdname) end, "Give any item", 0)

--multiteam stuff

---------------------------------------------------------------------------
-- Game state change handler
---------------------------------------------------------------------------
function ITT:OnGameRulesStateChange()
    local nNewState = GameRules:State_Get()
--  print( "OnGameRulesStateChange: " .. nNewState )

    if nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then
        print("DOTA_GAMERULES_STATE_HERO_SELECTION")
        --self:AssignAllPlayersToTeams()
        GameRules:GetGameModeEntity():SetThink( "BroadcastPlayerTeamAssignments", self, 0 ) -- can't do this immediately because the player resource doesn't have the names yet
    end
end

---------------------------------------------------------------------------
-- Helper functions
---------------------------------------------------------------------------
function ShuffledList( list )
    local result = {}
    local count = #list
    for i = 1, count do
        local pick = RandomInt( 1, #list )
        result[ #result + 1 ] = list[ pick ]
        table.remove( list, pick )
    end
    return result
end

function TableCount( t )
    local n = 0
    for _ in pairs( t ) do
        n = n + 1
    end
    return n
end

---------------------------------------------------------------------------
-- Scan the map to see which teams have spawn points
---------------------------------------------------------------------------
function ITT:GatherValidTeams()
  print( "GatherValidTeams:" )

    local foundTeams = {}
    for _, playerStart in pairs( Entities:FindAllByClassname( "info_player_start_dota" ) ) do
        foundTeams[  playerStart:GetTeam() ] = true
    end

  print( "GatherValidTeams - Found spawns for a total of " .. TableCount(foundTeams) .. " teams" )

    local foundTeamsList = {}
    for t, _ in pairs( foundTeams ) do
        table.insert( foundTeamsList, t )
    end

    self.m_GatheredShuffledTeams = foundTeamsList
    print("gather shuffled teams", self.m_GatheredShuffledTeams, #self.m_GatheredShuffledTeams, #foundTeamsList)
    print( "Final shuffled team list:" )
    for _, team in pairs( self.m_GatheredShuffledTeams ) do
     print( " - " .. team .. " ( " .. GetTeamName( team ) .. " )" )
    end
end


---------------------------------------------------------------------------
-- Assign all real players to a team
---------------------------------------------------------------------------
function ITT:AssignAllPlayersToTeams()
  print( "Assigning players to teams..." )
    for playerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
        if nil ~= PlayerResource:GetPlayer( playerID ) then
            local teamID = self:GetNextTeamAssignment()
            print( " - Player " .. playerID .. " assigned to team " .. teamID )
            PlayerResource:SetCustomTeamAssignment( playerID, teamID )
        end
    end
end

---------------------------------------------------------------------------
-- Get the color associated with a given teamID
---------------------------------------------------------------------------
function ITT:ColorForTeam( teamID )
    local color = self.m_TeamColors[teamID]
    if color == nil then
        color = { 255, 255, 255 } -- default to white
    end
    return color
end

---------------------------------------------------------------------------
-- Determine a good team assignment for the next player
---------------------------------------------------------------------------
function ITT:GetNextTeamAssignment()
    if #self.m_GatheredShuffledTeams == 0 then
      print( "CANNOT ASSIGN PLAYER - NO KNOWN TEAMS" )
        return DOTA_TEAM_NOTEAM
    end

    -- haven't assigned this player to a team yet
    print( "m_NumAssignedPlayers = " .. self.m_NumAssignedPlayers )

    -- If the number of players per team doesn't divide evenly (ie. 10 players on 4 teams => 2.5 players per team)
    -- Then this floor will round that down to 2 players per team
    -- If you want to limit the number of players per team, you could just set this to eg. 1
    local playersPerTeam = 3 --math.floor( DOTA_MAX_TEAM_PLAYERS / #self.m_GatheredShuffledTeams )
    print( "playersPerTeam = " .. playersPerTeam )

    local teamIndexForPlayer = math.floor( self.m_NumAssignedPlayers / playersPerTeam )
    print( "teamIndexForPlayer = " .. teamIndexForPlayer )

    -- Then once we get to the 9th player from the case above, we need to wrap around and start assigning to the first team
    if teamIndexForPlayer >= #self.m_GatheredShuffledTeams then
        teamIndexForPlayer = teamIndexForPlayer - #self.m_GatheredShuffledTeams
        print( "teamIndexForPlayer => " .. teamIndexForPlayer )
    end

    teamAssignment = self.m_GatheredShuffledTeams[ 1 + teamIndexForPlayer ]
    print( "teamAssignment = " .. teamAssignment )

    self.m_NumAssignedPlayers = self.m_NumAssignedPlayers + 1

    return teamAssignment
end


---------------------------------------------------------------------------
-- Put a label over a player's hero so people know who is on what team
---------------------------------------------------------------------------
function ITT:MakeLabelForPlayer( nPlayerID )
    if not PlayerResource:HasSelectedHero( nPlayerID ) then
        return
    end

    local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
    if hero == nil then
        return
    end

    local teamID = PlayerResource:GetTeam( nPlayerID )
    local color = self:ColorForTeam( teamID )
    hero:SetCustomHealthLabel( GetTeamName( teamID ), color[1], color[2], color[3] )
end

---------------------------------------------------------------------------
-- Tell everyone the team assignments during hero selection
---------------------------------------------------------------------------
function ITT:BroadcastPlayerTeamAssignments()
    print("BroadcastPlayerTeamAssignments")
    for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
        local nTeamID = PlayerResource:GetTeam( nPlayerID )
        if nTeamID ~= DOTA_TEAM_NOTEAM then
            GameRules:SendCustomMessage( "#TeamAssignmentMessage", nPlayerID, -1 )
        end
    end
end

---------------------------------------------------------------------------
-- Update player labels and the scoreboard
---------------------------------------------------------------------------
function ITT:OnThink()
    for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS-1) do
        self:MakeLabelForPlayer( nPlayerID )
    end

    return 1
end


---------------------------------------------------------------------------

-- Called whenever a player changes its current selection, it keeps a list of entity indexes
function ITT:OnPlayerSelectedEntities( event )
    local pID = event.pID

    GameRules.SELECTED_UNITS[pID] = event.selected_entities

    -- This is for Building Helper to know which is the currently active builder
    local mainSelected = GetMainSelectedEntity(pID)
    if IsValidEntity(mainSelected) and IsBuilder(mainSelected) then
        local player = PlayerResource:GetPlayer(pID)
        player.activeBuilder = mainSelected
    end
end