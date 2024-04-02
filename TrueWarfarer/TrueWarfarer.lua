
local re = re
local sdk = sdk
local imgui = imgui
local log = log
local json = json

local CN_FONT_NAME = 'NotoSansSC-Bold.otf'
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

log.info("True Warfarer Loaded");

local Config = json.load_file('true-warfarer.json') or {}
if Config.Enabled == nil then
	Config.Enabled = true
end
if Config.FontSize == nil then
    Config.FontSize = 24
end

if Config.RearmStaminaCostRemoved == nil then
    Config.RearmStaminaCostRemoved = false
end

local function FindIndex(table, value)
	for i = 1, #table do
		if table[i] == value then
			return i;
		end
	end

	return nil;
end

local Languages = {"EN", "CN"}
if Config.Language == nil or FindIndex(Languages, Config.Language) == nil then
	Config.Language = "EN"
end

local font

local PlayerManager
local function GetPlayerManager()
    if PlayerManager == nil then
        PlayerManager = sdk.get_managed_singleton('app.AppSingleton`1<app.CharacterManager>'):call('get_Instance')
    end
	return PlayerManager
end
local GUIManager = sdk.get_managed_singleton("app.GuiManager")
local function GetGUIManager()
    if GUIManager == nil then GUIManager = sdk.get_managed_singleton("app.PawnManager") end
	return GUIManager
end

local JobMap = {
    ["EN"] = {
        [1] = "Fighter",
        [2] = "Archer",
        [3] = "Mage",
        [4] = "Theif",
        [5] = "Warrior",
        [6] = "Sorcerer",
        [7] = "Mystic Spearhand",
        [8] = "Magick Archer",
        [9] = "Trickster",
        [10] = "Warfarer",
    },
    ["CN"] = {
        [1] = "战士",
        [2] = "弓箭手",
        [3] = "法师",
        [4] = "盗贼",
        [5] = "斗士",
        [6] = "巫师",
        [7] = "魔剑士",
        [8] = "魔弓手",
        [9] = "幻术师",
        [10] = "龙选者",
    },
}

local function GetJobName(id)
    if JobMap[Config.Language] then
        return JobMap[Config.Language][id]
    end
    return JobMap["EN"][id]
end

local WeaponValidSkillMap = {
    [1] = {
        [0] = "None",
        -- Fighter
        [1] = "Burst Strike",
        [2] = "Cloudward Slash",
        [3] = "Shield Pummel",
        [4] = "Full Moon Slash",
        [5] = "Launchboard",
        [6] = "Shield Drum",
        [7] = "Gutting Skewer",
        [8] = "Hindsight Sweep",
        [9] = "Flawless Guard",
        [10] = "Vengeful Slash",
        [11] = "Divine Defense",
        [12] = "BravesRaid",
        [100] = "Job10_00",
    },
    [2] = {
        [0] = "None",
        -- Archer
        [13] = "Manifold Shot",
        [14] = "Cascade Shot",
        [15] = "Deathly Arrow",
        [16] = "Lyncean Sight",
        [17] = "Erupting Shot",
        [18] = "Deluging Shot",
        [19] = "Incendiary Shot",
        [20] = "Nocuous Shot",
        [21] = "Tempest Shot",
        [22] = "Spiral Arrow",
        [23] = "FullBlast", -- Master
        [100] = "Job10_00",
    },
    [3] = {
        [0] = "None",
        -- Mage
        [24] = "High Flagration",
        [25] = "High Levin",
        [26] = "High Frigor",
        [27] = "High Spellhold",
        [28] = "High Palladium",
        [29] = "Fire Affinity",
        [30] = "Ice Affnity",
        [31] = "Lighting Affnity",
        [32] = "High Empyrean",
        [33] = "High Halidom",
        [34] = "High Celerity",
        [35] = "Argent Succor",
        [36] = "High Solemnity",
        [37] = "Celestial Paean", -- Master
        [100] = "Job10_00",
    },
    [4] = {
        [0] = "None",
        -- Theif
        [38] = "Cutting Wind",
        [39] = "Skull Splitter",
        [40] = "Implicate",
        [41] = "Masterful Kill",
        [42] = "Formless Feint", -- Master
        [43] = "Draw and Quarter",
        [44] = "Ignited Blades",
        [45] = "Smoke Shroud",
        [46] = "Powder Blast",
        [47] = "Concussive Leap",
        [48] = "Shadow Veil",
        [49] = "Plunder",
        [101] = "Blades of the Pyre", -- Master
        [100] = "Job10_00",
    },
    [5] = {
        [0] = "None",
        -- Warrior
        [50] = "Ravening Lunge",
        [51] = "Razing Sweep",
        [52] = "Heavenward Sunder",
        [53] = "Windstorm Slash",
        [54] = "Diluvian Strike",
        [55] = "Tidal Wrath",
        [56] = "Roar",
        [57] = "Mountain Breaker",
        [58] = "Indomitable Lash",
        [59] = "Inspirit",
        [60] = "Catapult Launch",
        [61] = "ArcOf0bliteration", -- Master
        [100] = "Job10_00",
    },
    [6] = {
        [0] = "None",
        -- Sorcerer
        [24] = "火焰风暴",
        [25] = "雷电暴雨",
        [26] = "冰霜之矛",
        [27] = "咒语填充",
        [62] = "High Salamander",
        [63] = "High Hagol",
        [64] = "High Thundermine",
        [65] = "High Decanter",
        [66] = "High Seism",
        [67] = "Augural Flare",
        [68] = "Meteoron", -- Master
        [69] = "Maelstorm", -- Master
        [100] = "Job10_00",
    },
    [7] = {
        [0] = "None",
        -- Mystic Spearhand
        [70] = "Devout Offringe",
        [71] = "Unto Heven",
        [72] = "Ravinour's Hond",
        [73] = "Dragoun's Foin",
        [74] = "Mirour Shelde",
        [75] = "Seching Storm",
        [76] = "Skiedragoun's Feste",
        [77] = "Magike Speregonne",
        [78] = "Moment's Charge",
        [79] = "DanceOfDeath", -- Master
        [100] = "Job10_00",
    },
    [8] = {
        [0] = "None",
        -- Magick Archer
        [80] = "FlameLance",
        [81] = "BurningLight",
        [82] = "FrostTrace",
        [83] = "FrostBlock",
        [84] = "ThunderChain",
        [85] = "ReflectThunder",
        [86] = "AbsorbArrow",
        [87] = "LifeReturn",
        [88] = "CounterArrow",
        [89] = "SleepArrow",
        [90] = "SeriesArrow",
        [91] = "SpiritArrow", -- Master
        [100] = "Job10_00",
    },
    [9] = {
        [0] = "None",
        -- Trickster
        [92] = "Illusive Divider",
        [93] = "Tricky Terrace",
        [94] = "Visitant Aura",
        [95] = "Suffocating Shroud",
        [96] = "Binding Effigy",
        [97] = "Aromatic Resurgence",
        [98] = "Fragrant Alarum",
        [99] = "SmokeDragon", -- Master
        [100] = "Job10_00",
    },
    [10] = {
        -- Warfarer
        [100] = "Job10_00",
        [1] = "一闪突刺",
        [2] = "空裂斩",
        [3] = "盾牌猛击",
        [4] = "圆月斩",
        [5] = "舞空之盾",
        [6] = "盾牌引诱",
        [7] = "剜心之击",
        [8] = "转向斩击",
        [9] = "完美防御",
        [10] = "反击劈砍",
        [11] = "战神之魂",
        [12] = "BravesRaid", -- Master TODO

        [13] = "连续射击",
        [14] = "扇形射击",
        [15] = "终结射击",
        [16] = "缩距射击",
        [17] = "火药箭射击",
        [18] = "濡湿箭射击",
        [19] = "浸油箭射击",
        [20] = "追毒箭射击",
        [21] = "怒涛射击",
        [22] = "漩涡射击",
        [23] = "FullBlast", -- Master TODO

        [24] = "火焰风暴",
        [25] = "雷电暴雨",
        [26] = "冰霜之矛",
        [27] = "咒语填充",
        [28] = "护卫之灵",
        [29] = "火焰的馈赠",
        [30] = "冰霜的馈赠",
        [31] = "雷电的馈赠",
        [32] = "神圣灵珠",
        [33] = "纯净法阵",
        [34] = "极速法阵",
        [35] = "紧急恢复",
        [36] = "强制沉默",
        [37] = "Celestial Paean", -- Master

        [38] = "镰鼬风",
        [39] = "断头台",
        [40] = "拉近",
        [41] = "格挡暗杀",
        [43] = "剜刺穿透",
        [44] = "带炎刃",
        [45] = "烟幕",
        [46] = "爆炎线",
        [47] = "爆跳",
        [48] = "隐身",
        [49] = "强夺",
        [42] = "Formless Feint", -- Master
        [101] = "Blades of the Pyre", -- Theif Master

        [50] = "战神突刺",
        [51] = "地平斩",
        [52] = "苍天斩",
        [53] = "烈风斩",
        [54] = "贯江",
        [55] = "退潮",
        [56] = "勇吼",
        [57] = "山崩地裂",
        [58] = "魔人斩",
        [59] = "斗志昂扬",
        [60] = "舞空跳肩",
        [61] = "ArcOf0bliteration", -- Master: TODO

        [62] = "火灵之尾",
        [63] = "暴雪涌泉",
        [64] = "雷暴伏特",
        [65] = "生命窃取",
        [66] = "岩石之击",
        [67] = "火焰集束",
        [68] = "Meteoron", -- Master
        [69] = "Maelstorm", -- Master

        [70] = "献上贡品",
        [71] = "送往绝界",
        [72] = "掠夺魔手",
        [73] = "飞龙突刺",
        [74] = "反弹神衣",
        [75] = "追踪魔刃",
        [76] = "天龙之牙",
        [77] = "魔枪发射",
        [78] = "屏息蓄力",
        [79] = "DanceOfDeath", -- Master: TODO

        [80] = "噬炎魔矢",
        [81] = "天照魔球",
        [82] = "冷追魔弹",
        [83] = "冰块魔枪",
        [84] = "雷锁魔桩",
        [85] = "跳弹魔使",
        [86] = "转命魔弓",
        [87] = "返命魔弓",
        [88] = "抗反魔盾",
        [89] = "昏睡魔弹",
        [90] = "无尽魔矢",
        [91] = "SpiritArrow", -- Master

        [92] = "幻壁之烟",
        [93] = "朦胧地板",
        [94] = "出窍虚香",
        [95] = "广域迷烟",
        [96] = "附身幻影",
        [97] = "振奋烈香",
        [98] = "察知炯烟",
        [99] = "SmokeDragon", -- Master: TODO
    },

}

local SkillMap = {
    ["EN"] = {
        -- Fighter
        [1] = "Burst Strike",
        [2] = "Cloudward Slash",
        [3] = "Shield Pummel",
        [4] = "Full Moon Slash",
        [5] = "Launchboard",
        [6] = "Shield Drum",
        [7] = "Gutting Skewer",
        [8] = "Hindsight Sweep",
        [9] = "Flawless Guard",
        [10] = "Vengeful Slash",
        [11] = "Divine Defense",
        [12] = "Riotous Fury", -- Master

        -- Archer
        [13] = "Manifold Shot",
        [14] = "Cascade Shot",
        [15] = "Deathly Arrow",
        [16] = "Lyncean Sight",
        [17] = "Erupting Shot",
        [18] = "Deluging Shot",
        [19] = "Incendiary Shot",
        [20] = "Nocuous Shot",
        [21] = "Tempest Shot",
        [22] = "Spiral Arrow",
        [23] = "Heavenly Shot", -- Master

        -- Mage
        [24] = "High Flagration",
        [25] = "High Levin",
        [26] = "High Frigor",
        [27] = "High Spellhold",
        [28] = "High Palladium",
        [29] = "Fire Affinity",
        [30] = "Ice Affnity",
        [31] = "Lighting Affnity",
        [32] = "High Empyrean",
        [33] = "High Halidom",
        [34] = "High Celerity",
        [35] = "Argent Succor",
        [36] = "High Solemnity",
        [37] = "Celestial Paean", -- Master

        -- Theif
        [38] = "Cutting Wind",
        [39] = "Skull Splitter",
        [40] = "Implicate",
        [41] = "Masterful Kill",
        [42] = "Formless Feint", -- Master
        [43] = "Draw and Quarter",
        [44] = "Ignited Blades",
        [45] = "Smoke Shroud",
        [46] = "Powder Blast",
        [47] = "Concussive Leap",
        [48] = "Shadow Veil",
        [49] = "Plunder",

        -- Warrior
        [50] = "Ravening Lunge",
        [51] = "Razing Sweep",
        [52] = "Heavenward Sunder",
        [53] = "Windstorm Slash",
        [54] = "Diluvian Strike",
        [55] = "Tidal Wrath",
        [56] = "Roar",
        [57] = "Mountain Breaker",
        [58] = "Indomitable Lash",
        [59] = "Inspirit",
        [60] = "Catapult Launch",
        [61] = "Arc of Might", -- Master

        -- Sorcerer
        [62] = "High Salamander",
        [63] = "High Hagol",
        [64] = "High Thundermine",
        [65] = "High Decanter",
        [66] = "High Seism",
        [67] = "Augural Flare",
        [68] = "Meteoron", -- Master
        [69] = "Maelstorm", -- Master

        -- Mystic Spearhand
        [70] = "Devout Offringe",
        [71] = "Unto Heven",
        [72] = "Ravinour's Hond",
        [73] = "Dragoun's Foin",
        [74] = "Mirour Shelde",
        [75] = "Seching Storm",
        [76] = "Skiedragoun's Feste",
        [77] = "Magike Speregonne",
        [78] = "Moment's Charge",
        [79] = "Wild Furie", -- Master

        -- Magick Archer
        [80] = "Blazefang Arrow",
        [81] = "Candescent Orb",
        [82] = "Frosthunter Bolt",
        [83] = "Arctic Bolt",
        [84] = "Boltchain Stake",
        [85] = "Ricochet Hunter",
        [86] = "Lifetaking Arrow",
        [87] = "Recovery Arrow",
        [88] = "Fortalice",
        [89] = "Soporific Bolt",
        [90] = "Sagittate Avalanche",
        [91] = "Martyr's Bolt",

        -- Trickster
        [92] = "Illusive Divider",
        [93] = "Tricky Terrace",
        [94] = "Visitant Aura",
        [95] = "Suffocating Shroud",
        [96] = "Binding Effigy",
        [97] = "Aromatic Resurgence",
        [98] = "Fragrant Alarum",
        [99] = "Dragon's Delusion", -- Master

        -- Warfarer
        [100] = "Rearmanent",

        [101] = "Blades of the Pyre", -- Theif Master
    },
    ["CN"] = {
        -- Fighter
        [1] = "一闪突刺",
        [2] = "空裂斩",
        [3] = "盾牌猛击",
        [4] = "圆月斩",
        [5] = "舞空之盾",
        [6] = "盾牌引诱",
        [7] = "剜心之击",
        [8] = "转向斩击",
        [9] = "完美防御",
        [10] = "反击劈砍",
        [11] = "战神之魂",
        [12] = "BravesRaid", -- Master TODO

        -- Archer
        [13] = "连续射击",
        [14] = "扇形射击",
        [15] = "终结射击",
        [16] = "缩距射击",
        [17] = "火药箭射击",
        [18] = "濡湿箭射击",
        [19] = "浸油箭射击",
        [20] = "追毒箭射击",
        [21] = "怒涛射击",
        [22] = "漩涡射击",
        [23] = "FullBlast", -- Master TODO

        -- Mage
        [24] = "火焰风暴",
        [25] = "雷电暴雨",
        [26] = "冰霜之矛",
        [27] = "咒语填充",
        [28] = "护卫之灵",
        [29] = "火焰的馈赠",
        [30] = "冰霜的馈赠",
        [31] = "雷电的馈赠",
        [32] = "神圣灵珠",
        [33] = "纯净法阵",
        [34] = "极速法阵",
        [35] = "紧急恢复",
        [36] = "强制沉默",
        [37] = "神之鼓励", -- Master

        -- Theif
        [38] = "镰鼬风",
        [39] = "断头台",
        [40] = "拉近",
        [41] = "格挡暗杀",
        [42] = "心如明镜", -- Master
        [43] = "剜刺穿透",
        [44] = "带炎刃",
        [45] = "烟幕",
        [46] = "爆炎线",
        [47] = "爆跳",
        [48] = "隐身",
        [49] = "强夺",

        [101] = "绝火超炎刃", -- Theif Master

        -- Warrior
        [50] = "战神突刺",
        [51] = "地平斩",
        [52] = "苍天斩",
        [53] = "烈风斩",
        [54] = "贯江",
        [55] = "退潮",
        [56] = "勇吼",
        [57] = "山崩地裂",
        [58] = "魔人斩",
        [59] = "斗志昂扬",
        [60] = "舞空跳肩",
        [61] = "ArcOf0bliteration", -- Master: TODO

        -- Sorcerer
        [62] = "火灵之尾",
        [63] = "暴雪涌泉",
        [64] = "雷暴伏特",
        [65] = "生命窃取",
        [66] = "岩石之击",
        [67] = "火焰集束",
        [68] = "流星陨落", -- Master
        [69] = "暴怒龙卷", -- Master

        -- Mystic Spearhand
        [70] = "献上贡品",
        [71] = "送往绝界",
        [72] = "掠夺魔手",
        [73] = "飞龙突刺",
        [74] = "反弹神衣",
        [75] = "追踪魔刃",
        [76] = "天龙之牙",
        [77] = "魔枪发射",
        [78] = "屏息蓄力",
        [79] = "DanceOfDeath", -- Master: TODO

        -- Magick Archer: TODO
        [80] = "噬炎魔矢",
        [81] = "天照魔球",
        [82] = "冷追魔弹",
        [83] = "冰块魔枪",
        [84] = "雷锁魔桩",
        [85] = "跳弹魔使",
        [86] = "转命魔弓",
        [87] = "返命魔弓",
        [88] = "抗反魔盾",
        [89] = "昏睡魔弹",
        [90] = "无尽魔矢",
        [91] = "SpiritArrow",

        -- Trickster
        [92] = "幻壁之烟",
        [93] = "朦胧地板",
        [94] = "出窍虚香",
        [95] = "广域迷烟",
        [96] = "附身幻影",
        [97] = "振奋烈香",
        [98] = "察知炯烟",
        [99] = "SmokeDragon", -- Master: TODO

        -- Warfarer: TODO
        [100] = "快速切换武装",
    }
}

local function GetSkillName(id)
    if SkillMap[Config.Language] and SkillMap[Config.Language][id] then
        return SkillMap[Config.Language][id]
    end
    return SkillMap["EN"][id]
end

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
    log.debug("SetCurrentJobSkills called")

    for i = 1, 4 do
        skillCtx:call("setSkill(app.Character.JobEnum, app.HumanCustomSkillID, app.HumanSkillContext.SkillSlot)", currentJob, skills[i], i - 1)
    end

    local gui = GetGUIManager();
    if gui then
        -- log.info("set gui")
        gui:call("setupKeyGuideCustomSkill()")
    end

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
    log.debug("activatedSkillSet: "..json.dump_string(activatedSkillSet, 2))

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
    for i = 1, 4 do
        skills[i] = skillCtx:getSkillID(currentJob, i - 1)
    end

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
    for i = 1, 4 do
        skills[i] = skillCtx:getSkillID(job, i - 1)
    end

    return skills
end

-- init SkillSet

if Config.SkillSets == nil then
    Config.SkillSets = {}
    for i = 1, 10 do
        Config.SkillSets[i] = {100,100,100,100}
    end
end

local skillSlotOptions={ [1]="Left", [2]="Top", [3]="Right", [4]="Down"}
local newIndex
local skillSlotIndex = 1

re.on_draw_ui(function()
	local configChanged = false
    if imgui.tree_node("True Warfarer") then
		local changed = false

		local langIdx = FindIndex(Languages, Config.Language)
		changed, langIdx = imgui.combo("Language", langIdx, Languages)
		configChanged = configChanged or changed
		Config.Language = Languages[langIdx]
        local rearmStaminaCostRemoved
        changed, rearmStaminaCostRemoved = imgui.checkbox("Stamina cost of rearm skill removed (Need to reset the script)", Config.RearmStaminaCostRemoved)
        configChanged = configChanged or changed
        Config.RearmStaminaCostRemoved = rearmStaminaCostRemoved


        
        changed, newIndex = imgui.combo("Apply Rearm skill to all", skillSlotIndex , skillSlotOptions)
        skillSlotIndex= newIndex
        configChanged = configChanged or changed

        imgui.same_line()
        if imgui.button("Apply") then
            for i = 1, 10 do
                local skillSet = Config.SkillSets[i];
                skillSet[skillSlotIndex] = 100
                configChanged = true
            end
        end
        if Config.Language == "CN" then
            imgui.push_font(fontCN)
        end

        if imgui.tree_node("Skill Set Management") then

            for i = 1, 10 do
                local name = GetJobName(i)
                
                
                local skillSet = Config.SkillSets[i]
                if not skillSet then
                    Config.SkillSets[i] = {100,100,100,100}
                    skillSet = {100,100,100,100}
                end

                local opened = imgui.tree_node(name)
                
                -- display skill sets
                local idx
                local validSkills = WeaponValidSkillMap[i]
                for k, _ in pairs(validSkills) do
                    validSkills[k] = GetSkillName(k)
                end
                if opened then
                    changed, idx = imgui.combo("Left", skillSet[1], validSkills)
                    skillSet[1] = idx
                    configChanged = configChanged or changed
                    changed, idx = imgui.combo("Top", skillSet[2], validSkills)
                    skillSet[2] = idx
                    configChanged = configChanged or changed
                    changed, idx = imgui.combo("Down", skillSet[3], validSkills)
                    skillSet[3] = idx
                    configChanged = configChanged or changed
                    changed, idx = imgui.combo("Right", skillSet[4], validSkills)
                    skillSet[4] = idx
                    configChanged = configChanged or changed
                    imgui.unindent(24)
                end
            end

            imgui.tree_pop();
        end

        imgui.tree_pop();
    end
	if configChanged then
		json.dump_file("true-warfarer.json", Config)
	end
end)

re.on_config_save(function()
	json.dump_file("true-warfarer.json", Config)
end)

local isChangingWeapon = false

local function pre_function_consumeStamina(args)
    if (isChangingWeapon == true) then return sdk.PreHookResult.SKIP_ORIGINAL end

end

local function pre_function(args)
    log.info("pre")
    -- equipWeapon(app.WeaponID)
    isChangingWeapon=true

end

local function post_function()
    log.info("post")
    local playerMgr = GetPlayerManager();
    if not playerMgr then return end

    local player = playerMgr:call("get_ManualPlayer()");
    if not player then return end

    local weaponHolder = player:call("get_WeaponAndItemHolder()")
    local weaponSlot =  weaponHolder:get_RightWeapon()
    local weapon = weaponSlot:get_Weapon()
    local weaponJobEnum = weapon:get_JobProp()
    -- local weaponId=args[3]
    -- log.debug(tostring(weaponJobEnum) )

    local skillSet=GetSkillSetByJobId(weaponJobEnum)
    -- log.debug("AfterNext: "..json.dump_string(skillSet, 2))
    SetCurrentJobSkills(skillSet)
    isChangingWeapon=false
end

sdk.hook(sdk.find_type_definition("app.Job10WeaponManager"):get_method("changeWeapon"), pre_function, post_function, nil)


if Config.RearmStaminaCostRemoved == true then
    sdk.hook(sdk.find_type_definition("app.Job10ActionController"):get_method("consumeStaminaAndStartReduceStaminaRecover()"), pre_function_consumeStamina, nil, nil)
end