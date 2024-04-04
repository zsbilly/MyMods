
local re = re
local sdk = sdk
local imgui = imgui
local log = log
local json = json
local hotkeys = require("Hotkeys/Hotkeys")
local CN_FONT_NAME = 'NotoSansSC-Bold.otf'
local t_CN_FONT_NAME = 'NotoSansCJKtc-Bold.otf'

local CN_FONT_SIZE = 18
local CJK_GLYPH_RANGES = {
    0x0020, 0x00FF, -- Basic Latin + Latin Supplement
    0x2000, 0x206F, -- General Punctuation
    0x3000, 0x30FF, -- CJK Symbols and Punctuations, Hiragana, Katakana
    0x31F0, 0x31FF, -- Katakana Phonetic Extensions
    0xFF00, 0xFFEF, -- Half-width characters
    0x4e00, 0x9FAF, -- CJK Ideograms
    0,
}

local fontCN = imgui.load_font(CN_FONT_NAME, CN_FONT_SIZE, CJK_GLYPH_RANGES)

log.info("AnAlternativeSkillSwapper Loaded");

local Config = json.load_file('AnAlternativeSkillSwapper.json') or {}
local Locstring = json.load_file("locstrings-truewarfarer.json") or {}
if Config.Enabled == nil then
	Config.Enabled = true
end
if Config.FontSize == nil then
    Config.FontSize = 24
end
if Config.Hotkeys == nil then
    Config.Hotkeys = {
		["ModifierKey"] = "Alt",
		["Left"] = "Q",
		["Up"] = "E",
        ["Right"] = "C",
        ["Down"] = "Z",
	}
end

hotkeys.setup_hotkeys(Config.Hotkeys)
if Config.RearmStaminaCostRemoved == nil then
    Config.RearmStaminaCostRemoved = false
end

local function FindIndex(table, value)
    for i = 1, #table do if table[i] == value then return i; end end
    return nil;
end

local Languages = {"EN", "CN","t_CN"}
if Config.Language == nil or FindIndex(Languages, Config.Language) == nil then
    Config.Language = "EN"
end

local PlayerManager
local function GetPlayerManager()
    if PlayerManager == nil then
        PlayerManager = sdk.get_managed_singleton(
                            'app.AppSingleton`1<app.CharacterManager>'):call(
                            'get_Instance')
    end
    return PlayerManager
end
local GUIManager
local function GetGUIManager()
    if GUIManager == nil then
        GUIManager = sdk.get_managed_singleton("app.GuiManager")
    end
    return GUIManager
end
local function GetJobNameLoc(id)
    if Locstring[Config.Language] and Locstring[Config.Language]["jobNames"] then
        return Locstring[Config.Language]["jobNames"][id]
    end
    if Locstring["EN"] then
        return Locstring["EN"]["jobNames"][id]
    end
    return id
end

local function GetSkillNameLoc(id)
    if Locstring[Config.Language] and Locstring[Config.Language]["skillNames"] then
        return Locstring[Config.Language]["skillNames"][tostring(id)]
    end
    if Locstring["EN"] then
    -- log.debug("skillname: " .. json.dump_string(Locstring["EN"]["skillNames"], 2))
        return Locstring["EN"]["skillNames"][tostring(id)]
    end
    return tostring(id)
end

local WeaponValidSkillMap = {
    [1] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 100},
    [2] = {0, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 100},
    [3] = {0, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 100},
    [4] = {0, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 101, 100},
    [5] = {0, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 100},
    [6] = {0, 24, 25, 26, 27, 62, 63, 64, 65, 66, 67, 68, 69, 100},
    [7] = {0, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 100},
    [8] = {0, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 100},
    [9] = {0, 92, 93, 94, 95, 96, 97, 98, 99, 100},
    [10] = {0}
}

local function SetCurrentJobSkills(skills)
    local playerMgr = GetPlayerManager();
    if not playerMgr then return end

    local player = playerMgr:call("get_ManualPlayer()");
    if not player then return end

    local human = player:call("get_Human");
    if not human then return end

    local jobCtx = human:call("get_JobContext")
    if not jobCtx then return end

    local currentJob = jobCtx:get_field("CurrentJob")
    if not currentJob then return end

    local skillCtx = human:call("get_SkillContext")
    if not skillCtx then return end

    for i = 1, 4 do skillCtx:setSkill(currentJob, skills[i], i - 1) end

    local gui = GetGUIManager();
    if gui then gui:call("setupKeyGuideCustomSkill()") end

end

local function GetSkillSetByJobId(currentJob)
    local playerMgr = GetPlayerManager();
    if not playerMgr then return end

    local player = playerMgr:call("get_ManualPlayer()");
    if not player then return end

    local human = player:call("get_Human");
    if not human then return end

    local jobCtx = human:call("get_JobContext")
    if not jobCtx then return end

    local activatedSkillSet = Config.SkillSets[currentJob];
    -- log.debug("activatedSkillSet: " .. json.dump_string(activatedSkillSet, 2))

    return Config.SkillSets[currentJob]
end

local function GetPlayerCurrentSkills()
    local playerMgr = GetPlayerManager();
    if not playerMgr then return end

    local player = playerMgr:call("get_ManualPlayer()");
    if not player then return end

    local human = player:call("get_Human");
    if not human then return end

    local jobCtx = human:call("get_JobContext")
    if not jobCtx then return end

    local currentJob = jobCtx:get_field("CurrentJob")
    if not currentJob then return end

    local skillCtx = human:call("get_SkillContext")
    if not skillCtx then return end

    local skills = {}
    for i = 1, 4 do skills[i] = skillCtx:getSkillID(currentJob, i - 1) end

    return skills
end

local function GetPlayerSkillsOfJob(job)
    local playerMgr = GetPlayerManager();
    if not playerMgr then return end

    local player = playerMgr:call("get_ManualPlayer()");
    if not player then return end

    local human = player:call("get_Human");
    if not human then return end

    local skillCtx = human:call("get_SkillContext")
    if not skillCtx then return end

    local skills = {}
    for i = 1, 4 do skills[i] = skillCtx:getSkillID(job, i - 1) end

    return skills
end

local function GetPlayerSkillCtx(job)
    local playerMgr = GetPlayerManager();
    if not playerMgr then return end

    local player = playerMgr:call("get_ManualPlayer()");
    if not player then return end

    local human = player:call("get_Human");
    if not human then return end

    local skillCtx = human:call("get_SkillContext")
    if not skillCtx then return end

    return skillCtx
end

local function GetSkillOptionsByJobId(id)
    local validSkills = WeaponValidSkillMap[id]
    local res = {}
    -- log.debug("validskills" .. json.dump_string(res))
    for k,v in pairs(validSkills) do
        if GetSkillNameLoc(v) then
            res[v] = GetSkillNameLoc(v)
        end
    end
    return res
end

-- init SkillSet

if Config.SkillSets == nil then
    Config.SkillSets = {}
    for i = 1, 10 do
        Config.SkillSets[i] = {0,0,0,0}
    end
end

re.on_draw_ui(function()
	local configChanged = false
    if imgui.tree_node("AnAlternativeSkillSwapper") then
		local changed = false

		local langIdx = FindIndex(Languages, Config.Language)
		changed, langIdx = imgui.combo("Language", langIdx, Languages)
		configChanged = configChanged or changed
		Config.Language = Languages[langIdx]
        
        if Config.Language == "CN" then
            imgui.push_font(fontCN)
        end

        if Config.Language == "t_CN"  then imgui.push_font(fontt_CN) end

        if imgui.tree_node("Alternative Set Management") then

            for i = 1, 9 do
                local name = GetJobNameLoc(i)
                
                
                local skillSet = Config.SkillSets[i]
                if not skillSet then
                    Config.SkillSets[i] = {0,0,0,0}
                    skillSet = {0,0,0,0}
                end

                local opened = imgui.tree_node(name)
                
                -- display skill sets
                local idx
                local validSkillOptions = GetSkillOptionsByJobId(i)
                if opened then
                    changed, idx = imgui.combo("Left", skillSet[1], validSkillOptions)
                    skillSet[1] = idx
                    configChanged = configChanged or changed
                    changed, idx = imgui.combo("Top", skillSet[2], validSkillOptions)
                    skillSet[2] = idx
                    configChanged = configChanged or changed
                    changed, idx = imgui.combo("Down", skillSet[3], validSkillOptions)
                    skillSet[3] = idx
                    configChanged = configChanged or changed
                    changed, idx = imgui.combo("Right", skillSet[4], validSkillOptions)
                    skillSet[4] = idx
                    configChanged = configChanged or changed
                    imgui.unindent(24)
                end
            end

            imgui.tree_pop();
        end
        changed = hotkeys.hotkey_setter("ModifierKey")
        configChanged = configChanged or changed
        -- changed = hotkeys.hotkey_setter("Left", "ModifierKey")
        -- configChanged = configChanged or changed
        -- changed = hotkeys.hotkey_setter("Up", "ModifierKey")
        -- configChanged = configChanged or changed
        -- changed = hotkeys.hotkey_setter("Right", "ModifierKey")
        -- configChanged = configChanged or changed
        -- changed = hotkeys.hotkey_setter("Down", "ModifierKey")
        -- configChanged = configChanged or changed
        imgui.tree_pop();
    end



	if configChanged then
        hotkeys.update_hotkey_table(Config.Hotkeys)
		json.dump_file("AnAlternativeSkillSwapper.json", Config)
	end
end)

re.on_config_save(function()
	json.dump_file("AnAlternativeSkillSwapper.json", Config)
end)

local function GetPlayerCurrentJob()
    local playerMgr = GetPlayerManager();
    if not playerMgr then return end

    local player = playerMgr:call("get_ManualPlayer()");
    if not player then return end

    local human = player:call("get_Human");
    if not human then return end

    local jobCtx = human:call("get_JobContext")
    if not jobCtx then return end

    local currentJob = jobCtx:get_field("CurrentJob")
    if not currentJob then return end

    return currentJob
end

local function getCurrentWeaponJob()
    local playerMgr = GetPlayerManager();
    if not playerMgr then return end

    local player = playerMgr:call("get_ManualPlayer()");
    if not player then return end

    local weaponHolder = player:call("get_WeaponAndItemHolder()")
    if not weaponHolder then return end
    local weaponSlot =  weaponHolder:get_RightWeapon()
    if not weaponSlot then return end
    local weapon = weaponSlot:get_Weapon()
    if not weapon then return end
    local weaponJobEnum = weapon:get_JobProp()
    if not weaponJobEnum then return end
    return weaponJobEnum
end


local modifierKeyDown = false
local leftKeyDown = false
local prevSkills

re.on_frame(function ()
    local currentJob
    currentJob = GetPlayerCurrentJob()
    
    currentWeaponJob = getCurrentWeaponJob()
    if not currentWeaponJob then currentWeaponJob = currentJob end
    local activatedSkillSet = Config.SkillSets[currentWeaponJob];
    if hotkeys.check_hotkey("ModifierKey", true) and prevSkills == nil and modifierKeyDown == false then
        modifierKeyDown = true
        -- log.debug("keydown")
        prevSkills=GetPlayerSkillsOfJob(currentJob);

        -- log.debug("return 0: "..json.dump_string(prevSkills, 2))
        SetCurrentJobSkills(activatedSkillSet)
        
        -- if hotkeys.check_hotkey("Left",true) then 
        --     local skillSet GetPlayerSkillsOfJob(currentJob)
        --     return sdk.to_ptr(activatedSkillSet[1]) 
        -- end
        -- if hotkeys.check_hotkey("Up",true) then 
        --     log.debug("activatedSkillSet: "..json.dump_string(activatedSkillSet[2], 2))
        --     return sdk.to_ptr(activatedSkillSet[2]) 
        -- end
        -- if hotkeys.check_hotkey("Right",true) then 
        --     return sdk.to_ptr(activatedSkillSet[4]) 
        -- end
        -- if hotkeys.check_hotkey("Down",true) then 
        --     return sdk.to_ptr(activatedSkillSet[3]) 
        -- end
        -- log.debug("return 0: "..json.dump_string(activatedSkillSet[2], 2))
        -- return 0
    elseif hotkeys.check_hotkey("ModifierKey") and prevSkills and modifierKeyDown == true then
        -- log.debug("keyUp")
        -- log.debug("prevSkills "..json.dump_string(prevSkills, 2))

        SetCurrentJobSkills(prevSkills)
        prevSkills=nil
        modifierKeyDown = false
        -- if hotkeys.check_hotkey("Left",true) then 
        --     local skillSet GetPlayerSkillsOfJob(currentJob)
        --     return sdk.to_ptr(activatedSkillSet[1]) 
        -- end
        -- if hotkeys.check_hotkey("Up",true) then 
        --     log.debug("activatedSkillSet: "..json.dump_string(activatedSkillSet[2], 2))
        --     return sdk.to_ptr(activatedSkillSet[2]) 
        -- end
        -- if hotkeys.check_hotkey("Right",true) then 
        --     return sdk.to_ptr(activatedSkillSet[4]) 
        -- end
        -- if hotkeys.check_hotkey("Down",true) then 
        --     return sdk.to_ptr(activatedSkillSet[3]) 
        -- end
        -- log.debug("return 0: "..json.dump_string(activatedSkillSet[2], 2))
        -- return 0
    end


end)

-- local function post_function_test(retval)
--     local currentJob
--     currentJob = GetPlayerCurrentJob()
--     log.debug("currentJob: "..json.dump_string(currentJob, 2))
--     if currentJob == 10 then 
--         currentJob = getCurrentWeaponJob()
--     end
--     local activatedSkillSet = Config.SkillSets[currentJob];
--     -- log.debug("activatedSkillSet: "..json.dump_string(activatedSkillSet, 2))
--     if hotkeys.check_hotkey("ModifierKey", true) then
--         if hotkeys.check_hotkey("Left",true) then 
--             return sdk.to_ptr(activatedSkillSet[1]) 
--         end
--         if hotkeys.check_hotkey("Up",true) then 
--             log.debug("activatedSkillSet: "..json.dump_string(activatedSkillSet[2], 2))
--             return sdk.to_ptr(activatedSkillSet[2]) 
--         end
--         if hotkeys.check_hotkey("Right",true) then 
--             return sdk.to_ptr(activatedSkillSet[4]) 
--         end
--         if hotkeys.check_hotkey("Down",true) then 
--             return sdk.to_ptr(activatedSkillSet[3]) 
--         end
--         log.debug("return 0: "..json.dump_string(activatedSkillSet[2], 2))
--         return 0
--     end
    
--     return retval
-- end

-- sdk.hook(sdk.find_type_definition("app.PlayerInputProcessorDetail"):get_method("getCustomSkillID"), function() end, post_function_test, nil)