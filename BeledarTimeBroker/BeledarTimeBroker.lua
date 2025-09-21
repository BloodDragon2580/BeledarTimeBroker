local LDB = LibStub:GetLibrary("LibDataBroker-1.1")

local L = {
    enUS = {
        ["Spawn Timer"] = "Beledar Spawn Timer",
        ["Next spawn in"] = "Next Beledar spawn in",
        ["Ctrl + Click to send to General chat."] = "Ctrl + Click to send to General chat.",
        ["Alt + Click to send to Guild chat."] = "Alt + Click to send to Guild chat.",
        ["beledartimer"] = "Beledar Timer",
        ["now"] = "now"
    },
    deDE = {
        ["Spawn Timer"] = "Beledar Spawn Timer",
        ["Next spawn in"] = "Nächster Beledar Spawn in",
        ["Ctrl + Click to send to General chat."] = "Strg + Klicken, um im Allgemein-Chat zu senden.",
        ["Alt + Click to send to Guild chat."] = "Alt + Klicken, um im Gilden-Chat zu senden.",
        ["beledartimer"] = "Beledar Timer",
        ["now"] = "jetzt"
    },
    frFR = {
        ["Spawn Timer"] = "Minuteur de spawn de Beledar",
        ["Next spawn in"] = "Prochain spawn de Beledar dans",
        ["Ctrl + Click to send to General chat."] = "Ctrl + Clic pour envoyer dans le canal Général.",
        ["Alt + Click to send to Guild chat."] = "Alt + Clic pour envoyer dans le canal de Guilde.",
        ["beledartimer"] = "Minuteur Beledar",
        ["now"] = "maintenant"
    },
    esES = {
        ["Spawn Timer"] = "Temporizador de aparición de Beledar",
        ["Next spawn in"] = "Siguiente aparición de Beledar en",
        ["Ctrl + Click to send to General chat."] = "Ctrl + Clic para enviar al chat General.",
        ["Alt + Click to send to Guild chat."] = "Alt + Clic para enviar al chat de Hermandad.",
        ["beledartimer"] = "Temporizador Beledar",
        ["now"] = "ahora"
    },
    itIT = {
        ["Spawn Timer"] = "Timer di spawn di Beledar",
        ["Next spawn in"] = "Prossimo spawn di Beledar tra",
        ["Ctrl + Click to send to General chat."] = "Ctrl + Clic per inviare nella chat Generale.",
        ["Alt + Click to send to Guild chat."] = "Alt + Clic per inviare nella chat di Gilda.",
        ["beledartimer"] = "Timer Beledar",
        ["now"] = "adesso"
    },
    ptBR = {
        ["Spawn Timer"] = "Cronômetro de surgimento de Beledar",
        ["Next spawn in"] = "Próximo surgimento de Beledar em",
        ["Ctrl + Click to send to General chat."] = "Ctrl + Clique para enviar ao chat Geral.",
        ["Alt + Click to send to Guild chat."] = "Alt + Clique para enviar ao chat da Guilda.",
        ["beledartimer"] = "Cronômetro Beledar",
        ["now"] = "agora"
    },
    ruRU = {
        ["Spawn Timer"] = "Таймер появления Беледара",
        ["Next spawn in"] = "Следующее появление Беледара через",
        ["Ctrl + Click to send to General chat."] = "Ctrl + Клик, чтобы отправить в общий чат.",
        ["Alt + Click to send to Guild chat."] = "Alt + Клик, чтобы отправить в чат гильдии.",
        ["beledartimer"] = "Таймер Беледара",
        ["now"] = "сейчас"
    },
    zhCN = {
        ["Spawn Timer"] = "贝勒达刷新计时器",
        ["Next spawn in"] = "下次贝勒达刷新于",
        ["Ctrl + Click to send to General chat."] = "Ctrl + 点击发送到综合频道。",
        ["Alt + Click to send to Guild chat."] = "Alt + 点击发送到公会频道。",
        ["beledartimer"] = "贝勒达计时器",
        ["now"] = "现在"
    },
    koKR = {
        ["Spawn Timer"] = "벨레다르 스폰 타이머",
        ["Next spawn in"] = "다음 벨레다르 스폰까지",
        ["Ctrl + Click to send to General chat."] = "Ctrl + 클릭으로 일반 채팅에 보내기.",
        ["Alt + Click to send to Guild chat."] = "Alt + 클릭으로 길드 채팅에 보내기.",
        ["beledartimer"] = "벨레다르 타이머",
        ["now"] = "지금"
    },
    jaJP = {
        ["Spawn Timer"] = "ベレダル出現タイマー",
        ["Next spawn in"] = "次のベレダル出現まで",
        ["Ctrl + Click to send to General chat."] = "Ctrl + クリックで一般チャットに送信。",
        ["Alt + Click to send to Guild chat."] = "Alt + クリックでギルドチャットに送信。",
        ["beledartimer"] = "ベレダルタイマー",
        ["now"] = "今"
    }
}

local locale = GetLocale()
local currentLocale = L[locale] or L["enUS"]

-- Daily reset times for EU and NA (in 24-hour format)
local resetTimes = {
    EU = { hour = 8, minute = 0 },
    NA = { hour = 4, minute = 0 }
}

local regionID = GetCurrentRegion()
local resetTime = (regionID == 3) and resetTimes.EU or resetTimes.NA

-- Calculate Beledar's spawn times based on reset time
local function GetBeledarSpawnTimes(resetHour, resetMinute)
    local spawnTimes = {}
    local firstSpawnMinutes = (resetHour * 60 + resetMinute) + 60  -- First spawn is 1 hour after reset
    for i = 0, 7 do
        local spawnMinutes = firstSpawnMinutes + (i * 180)  -- Subsequent spawns every 3 hours (180 minutes)
        table.insert(spawnTimes, string.format("%02d:%02d", math.floor(spawnMinutes / 60) % 24, spawnMinutes % 60))
    end
    return spawnTimes
end

local regionSpawnTimes = GetBeledarSpawnTimes(resetTime.hour, resetTime.minute)

local function ShowSpawnAlert()
    RaidNotice_AddMessage(RaidWarningFrame, currentLocale["Spawn Timer"] .. ": " .. currentLocale["Next spawn in"] .. " " .. currentLocale["now"] .. "!", ChatTypeInfo["RAID_WARNING"])
    PlaySoundFile("Sound\\Interface\\RaidWarning.ogg", "Master")
end

local function GetTimeUntilNextSpawn()
    local hours, minutes = GetGameTime()
    local currentMinutes = hours * 60 + minutes

    for _, time in ipairs(regionSpawnTimes) do
        local spawnHour, spawnMinute = time:match("(%d%d):(%d%d)")
        local spawnMinutes = tonumber(spawnHour) * 60 + tonumber(spawnMinute)

        if spawnMinutes > currentMinutes then
            local timeUntilSpawn = spawnMinutes - currentMinutes
            if timeUntilSpawn <= 1 then
                ShowSpawnAlert()
            end
            return string.format("%02dh %02dm", math.floor(timeUntilSpawn / 60), timeUntilSpawn % 60)
        end
    end

    -- Handle the case when the next spawn is the first one the next day
    local firstSpawnHour, firstSpawnMinute = regionSpawnTimes[1]:match("(%d%d):(%d%d)")
    local firstSpawnMinutes = tonumber(firstSpawnHour) * 60 + tonumber(firstSpawnMinute) + 24 * 60
    local timeUntilSpawn = firstSpawnMinutes - currentMinutes
    if timeUntilSpawn <= 1 then
        ShowSpawnAlert()
    end
    return string.format("%02dh %02dm", math.floor(timeUntilSpawn / 60), timeUntilSpawn % 60)
end

local broker = LDB:NewDataObject(currentLocale["Spawn Timer"], {
    type = "data source",
    text = currentLocale["Next spawn in"] .. ": " .. GetTimeUntilNextSpawn(),
    icon = "Interface\\Icons\\Inv_shadowelementalmount_purple",
    OnTooltipShow = function(tooltip)
        tooltip:AddLine(currentLocale["Spawn Timer"])
        tooltip:AddLine(currentLocale["Next spawn in"] .. ": " .. GetTimeUntilNextSpawn())
        tooltip:AddLine(currentLocale["Ctrl + Click to send to General chat."])
        tooltip:AddLine(currentLocale["Alt + Click to send to Guild chat."])
    end,
    OnClick = function(_, button)
        local timeUntilNextSpawn = GetTimeUntilNextSpawn()
        local message = currentLocale["Next spawn in"] .. ": " .. timeUntilNextSpawn

        if button == "LeftButton" and IsControlKeyDown() then
            local generalChatName = (locale == "deDE") and "Allgemein" or "General"
            local generalChannel = GetChannelName(generalChatName)
            if generalChannel and generalChannel > 0 then
                SendChatMessage(message, "CHANNEL", nil, generalChannel)
            else
                print(generalChatName .. " chat channel not found. Make sure you're in the " .. generalChatName .. " chat.")
            end
        elseif button == "LeftButton" and IsAltKeyDown() then
            if IsInGuild() then
                SendChatMessage(message, "GUILD")
            else
                print("You are not in a guild.")
            end
        end
    end
})

local f = CreateFrame("Frame")
f:SetScript("OnUpdate", function(self, elapsed)
    if not self.lastUpdate then self.lastUpdate = 0 end
    self.lastUpdate = self.lastUpdate + elapsed
    if self.lastUpdate > 60 then
        broker.text = currentLocale["Next spawn in"] .. ": " .. GetTimeUntilNextSpawn()
        self.lastUpdate = 0
    end
end)

broker.text = currentLocale["Next spawn in"] .. ": " .. GetTimeUntilNextSpawn()
