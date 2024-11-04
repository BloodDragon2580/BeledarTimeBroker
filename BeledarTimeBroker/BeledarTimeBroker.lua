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
    }
}

local locale = GetLocale()
local currentLocale = L[locale] or L["enUS"]

local spawnTimes = {
    EU = { "00:00", "03:00", "06:00", "09:00", "12:00", "15:00", "18:00", "21:00" },
    NA = { "23:00", "02:00", "05:00", "08:00", "11:00", "14:00", "17:00", "20:00" }
}

local regionID = GetCurrentRegion()
local region = (regionID == 3) and spawnTimes.EU or spawnTimes.NA

local function ShowSpawnAlert()
	RaidNotice_AddMessage(RaidWarningFrame, currentLocale["Spawn Timer"] .. ": " .. currentLocale["Next spawn in"] .. " " .. currentLocale["now"] .. "!", ChatTypeInfo["RAID_WARNING"])
    
    PlaySoundFile("Sound\\Interface\\RaidWarning.ogg", "Master")
end

local function GetTimeUntilNextSpawn()
    local hours, minutes = GetGameTime()
    local currentMinutes = hours * 60 + minutes

    for _, time in ipairs(region) do
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

    local firstSpawnHour, firstSpawnMinute = region[1]:match("(%d%d):(%d%d)")
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
