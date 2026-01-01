-- ToyGuise.lua - Grid of owned transformation/disguise toys! Click to use.

local debug = false -- Set to false to disable debug prints
local COLUMNS = 8            -- Number of columns in the grid
local BUTTON_SIZE = 30       -- Size of each toy button
local BUTTON_SPACING = 10     -- Spacing between buttons
local MAX_EXPECTED_TOYS = 150  -- :Limit for transformation toys for memory pre-allocation

-- Main window frame
local frame = CreateFrame("Frame", "ToyGuiseFrame", UIParent, "BackdropTemplate")
frame:SetSize(COLUMNS * (BUTTON_SIZE + BUTTON_SPACING) + 20, 400)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetFrameStrata("HIGH")
frame:SetToplevel(true)
frame.buttons = {}  -- Pool of reusable buttons

-- Backdrop
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
frame:SetBackdropColor(0, 0, 0, 0.8)

-- Title
local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -15)
title:SetText("ToyGuise")

-- Draggable
frame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then self:StartMoving() end
end)
frame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)

-- Close button
local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", -5, -5)
close:SetScript("OnClick", function() frame:Hide() end)

-- Cached toys (no version tracking needed anymore)
local cachedToys = {}

-- Get owned transformation toys, sorted by name
local function GetOwnedToysSorted()
    -- Always rebuild from our curated list - cheap and reliable
    wipe(cachedToys)
    for _, toyData in ipairs(TRANSFORMATION_TOYS) do
        local toyID = toyData.id
        if PlayerHasToy(toyID) and C_ToyBox.IsToyUsable(toyID) then
            table.insert(cachedToys, toyData)
        end
    end
    table.sort(cachedToys, function(a, b) return a.name < b.name end)
    return cachedToys
end

-- Set up a new button
local function SetupNewButton(btn)
    btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)

    -- Icon
    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    btn.icon = icon

    -- Cooldown
    local cd = CreateFrame("Cooldown", nil, btn, "CooldownFrameTemplate")
    cd:SetAllPoints()
    cd:SetDrawEdge(false)
    cd:SetHideCountdownNumbers(false)
    btn.cd = cd

    -- Secure action
    btn:SetAttribute("type", "toy")

    -- Tooltip
    btn:SetScript("OnEnter", function(self)
        if self.toyID then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetToyByItemID(self.toyID)
            GameTooltip:Show()
        end
    end)
    btn:SetScript("OnLeave", GameTooltip_Hide)
end

-- Reset a button to a clean state
local function ResetButton(btn)
    btn:ClearAllPoints()
    btn:Hide()
    btn:SetAttribute("toy", nil)
    btn.toyID = nil
    if btn.icon then btn.icon:SetTexture() end
    btn.cd:Hide()
end

-- Update an existing button with new toy data
local function UpdateButton(btn, toyData)
    local toyID = toyData.id
    btn.toyID = toyID
    btn.icon:SetTexture(C_Item.GetItemIconByID(toyID))
    btn:SetAttribute("toy", toyID)

    -- Cooldown
    local start, duration = C_Item.GetItemCooldown(toyID)
    if duration and duration > 0 then
        btn.cd:SetCooldown(start, duration)
        btn.cd:Show()
    else
        btn.cd:Hide()
    end
end

-- Update only cooldowns
local function UpdateCooldownsOnly()
    for _, btn in ipairs(frame.buttons) do
        if btn.toyID and btn:IsShown() then
            local start, duration = C_Item.GetItemCooldown(btn.toyID)
            if duration and duration > 0 then
                btn.cd:SetCooldown(start, duration)
                btn.cd:Show()
            else
                btn.cd:Hide()
            end
        end
    end
end

-- Main refresh function
local function RefreshToyButtons(fullRefresh)
    if fullRefresh then
        local ownedToys = GetOwnedToysSorted()
        local numToys = #ownedToys

        local row, col = 0, 0
        for i, toyData in ipairs(ownedToys) do
            local btn = frame.buttons[i]
            UpdateButton(btn, toyData)
            btn:SetPoint("TOPLEFT", frame, "TOPLEFT",
                20 + col * (BUTTON_SIZE + BUTTON_SPACING),
                -60 - row * (BUTTON_SIZE + BUTTON_SPACING))
            btn:Show()

            col = col + 1
            if col >= COLUMNS then
                col = 0
                row = row + 1
            end
        end

        -- Hide excess buttons
        for i = numToys + 1, #frame.buttons do
            ResetButton(frame.buttons[i])
        end

        -- Resize frame
        local rowsNeeded = math.ceil(numToys / COLUMNS)
        local height = 100 + rowsNeeded * (BUTTON_SIZE + BUTTON_SPACING) + 20
        frame:SetHeight(height)
        title:SetText("ToyGuise (" .. numToys .. ")")
    else
        UpdateCooldownsOnly()
    end

    if debug then print("|cFFFFFF00ToyGuise: " .. (fullRefresh and "Full refresh" or "Cooldown update") .. "|r") end
end

-- Refresh when shown
frame:SetScript("OnShow", function() RefreshToyButtons(true) end)

-- Event handler
local eventFrame = CreateFrame("Frame")
local addonName = "ToyGuise"
local needFullRefresh = false

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        ToyGuiseDB = ToyGuiseDB or {}
        local db = ToyGuiseDB
        db.minimap = db.minimap or { hide = false }

        local LDB = LibStub("LibDataBroker-1.1")
        local LDBIcon = LibStub("LibDBIcon-1.0")

        local minimapButton = LDB:NewDataObject("ToyGuise", {
            type = "launcher",
            label = "ToyGuise",
            icon = "Interface\\Icons\\inv_misc_toy_04",
            OnClick = function(self, button)
                if button == "LeftButton" then
                    if InCombatLockdown() then
                        print("|cFFFF0000ToyGuise:|r Cannot toggle in combat!")
                        return
                    end
                    if frame:IsShown() then
                        frame:Hide()
                    else
                        frame:Show()
                    end
                elseif button == "RightButton" then
                    print("|cFF00FF00ToyGuise:|r Left-click minimap to toggle!")
                end
            end,
            OnTooltipShow = function(tt)
                tt:AddLine("ToyGuise", 1, 1, 1)
                tt:AddLine(" |cFF00FF00Left-Click:|r Toggle toy grid", 1, 1, 1)
            end,
        })

        LDBIcon:Register("ToyGuise", minimapButton, db.minimap)
        LDBIcon:Show("ToyGuise")

        -- Pre-allocate button pool
        for i = 1, MAX_EXPECTED_TOYS do
            local btn = CreateFrame("Button", nil, frame, "SecureActionButtonTemplate")
            SetupNewButton(btn)
            ResetButton(btn)
            table.insert(frame.buttons, btn)
        end

        self:UnregisterEvent("ADDON_LOADED")

    elseif event == "PLAYER_LOGIN" then
        self:RegisterEvent("TOYS_UPDATED")
        self:RegisterEvent("BAG_UPDATE_COOLDOWN")

        if frame:IsShown() then
            RefreshToyButtons(true)
        end

    elseif event == "TOYS_UPDATED" then
        needFullRefresh = true
        if frame:IsShown() then
            RefreshToyButtons(true)
        end

    elseif event == "BAG_UPDATE_COOLDOWN" then
        if frame:IsShown() then
            if needFullRefresh then
                RefreshToyButtons(true)
                needFullRefresh = false
            else
                RefreshToyButtons(false)
            end
        end
    end
end)

-- Slash commands
SLASH_TOYGUISE1 = "/toyguise"
SLASH_TOYGUISE2 = "/tg"
SlashCmdList["TOYGUISE"] = function(msg)
    local cmd = string.lower(strtrim(msg or ""))
    if cmd == "mem" or cmd == "perf" then
        collectgarbage("collect")
        UpdateAddOnMemoryUsage()
        UpdateAddOnCPUUsage()
        local mem = GetAddOnMemoryUsage("ToyGuise")
        local cpu = GetAddOnCPUUsage("ToyGuise")
        print("|cFF00FF00=== ToyGuise Resources ===|r")
        print("|cFFFFFFAA Memory: |r" .. string.format("%.1f", mem) .. " KB")
        print("|cFFFFFFAA CPU (last 5s): |r" .. string.format("%.2f", cpu) .. " ms")
        print("|cFFFFFFAA Total Heap: |r" .. string.format("%.1f", collectgarbage("count") / 1024) .. " MB")
    else
        if frame:IsShown() then
            frame:Hide()
        else
            frame:Show()
        end
    end
end

-- Start hidden
frame:Hide()