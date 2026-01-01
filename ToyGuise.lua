-- ToyGuise.lua - Grid of owned transformation/disguise toys! Click to use.

local debug = false -- Set to false to disable debug prints
local COLUMNS = 8  -- Number of columns in the grid, TODO: Player settable
local BUTTON_SIZE = 30 -- Size of each toy button, TODO: Player settable
local BUTTON_SPACING = 10


--Window frame
local frame = CreateFrame("Frame", "ToyGuiseFrame", UIParent, "BackdropTemplate")
frame:SetSize(COLUMNS * (BUTTON_SIZE + BUTTON_SPACING) + 20, 400)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetFrameStrata("DIALOG")
frame:SetToplevel(true)
frame.buttons = {}

-- Window frame Backdrop appearance
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
frame:SetBackdropColor(0, 0, 0, 0.8)

-- Window Title
local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -15)
title:SetText("ToyGuise")

-- Window Draggable
frame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then self:StartMoving() end
end)
frame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)

-- Window Close
local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", -5, -5)
close:SetScript("OnClick", function() frame:Hide() end)


local function GetOwnedToysSorted()
    local ownedToys = {}
    if debug then print("|cFFFFFF00ToyGuise Debug: Checking owned toys...|r") end
    
    for _, toyData in ipairs(TRANSFORMATION_TOYS) do
        local toyID = toyData.id
        if PlayerHasToy(toyID) then
            if C_ToyBox.IsToyUsable(toyID) then
                table.insert(ownedToys, toyData)
                if debug then print("|cFF00FF00Usable & Owned: " .. toyID .. " (" .. toyData.name .. ")|r") end
            else
                if debug then print("|cFFFF8888Owned but Unusable: " .. toyID .. " (" .. toyData.name .. ") - likely wrong faction|r") end
            end
        end
    end
    
    table.sort(ownedToys, function(a, b)
        return a.name < b.name
    end)
    
    if debug then print("|cFFFFFF00ToyGuise Debug: Found " .. #ownedToys .. " usable transformation toys.|r") end
    return ownedToys
end

-- Create/refresh toy buttons in window/frame
local function CreateToyButtons()

    -- Hide & clear old buttons
    for _, btn in ipairs(frame.buttons) do
        btn:Hide()
        btn:ClearAllPoints()
    end
    wipe(frame.buttons)

    local row, col = 0, 0
    local usableCount = 0

    local PLAYER_TRANSFORMATION_TOYS = GetOwnedToysSorted()

    for _, toyData in ipairs(PLAYER_TRANSFORMATION_TOYS) do
        local toyID = toyData.id
        usableCount = usableCount + 1

        if debug then print("|cFF00FF00Creating button for: " .. toyID .. " (" .. toyData.name .. ")|r") end

        local btn = CreateFrame("Button", nil, frame, "SecureActionButtonTemplate")
        btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
        btn:SetPoint("TOPLEFT", frame, "TOPLEFT", 20 + col * (BUTTON_SIZE + BUTTON_SPACING), -60 - row * (BUTTON_SIZE + BUTTON_SPACING))

        -- Icon
        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints()
        icon:SetTexture(C_Item.GetItemIconByID(toyID))
        btn.icon = icon

        -- Always fully saturated — we only include usable toys
        icon:SetDesaturated(false)

        -- Cooldown swirl + numbers
        local cd = CreateFrame("Cooldown", nil, btn, "CooldownFrameTemplate")
        cd:SetAllPoints()
        cd:SetDrawEdge(false)
        cd:SetHideCountdownNumbers(false)
        btn.cd = cd

        -- Click to use
        btn:SetAttribute("type", "toy")
        btn:SetAttribute("toy", toyID)


        -- Tooltip
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetToyByItemID(toyID)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", GameTooltip_Hide)

        -- Cooldown handling
        local start, duration = C_Item.GetItemCooldown(toyID)
        if duration and duration > 0 then
            cd:SetCooldown(start, duration)
            cd:Show()
        else
            cd:Hide()
        end

        btn:Show()
        table.insert(frame.buttons, btn)

        col = col + 1
        if col >= COLUMNS then
            col = 0
            row = row + 1
        end
    end

    -- Resize frame and update title
    local rowsNeeded = math.ceil(usableCount / COLUMNS)
    frame:SetHeight(100 + rowsNeeded * (BUTTON_SIZE + BUTTON_SPACING) + 20)
    title:SetText("ToyGuise (" .. usableCount .. ")")

    if debug then print("|cFFFFFF00ToyGuise: " .. usableCount .. " buttons created!|r") end
end

-- Keep OnShow for manual toggles / refreshes
frame:SetScript("OnShow", CreateToyButtons)


-- Global event handler - fixes first-load empty grid
local eventFrame = CreateFrame("Frame")
local addonName = "ToyGuise"

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- SavedVariables are ready
        ToyGuiseDB = ToyGuiseDB or {}
        local db = ToyGuiseDB
        db.minimap = db.minimap or { hide = false }

        -- Setup minimap button (libs already loaded via embeds.xml or TOC)
        local LDB = LibStub("LibDataBroker-1.1")
        local LDBIcon = LibStub("LibDBIcon-1.0")

        local minimapButton = LDB:NewDataObject("ToyGuise", {
            type = "launcher",
            label = "ToyGuise",
            icon = "Interface\\Icons\\inv_misc_toy_04",  -- Change to your custom icon if desired
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
                --tt:AddLine(" |cFFFFAA00Right-Click:|r Hide this button", 1, 1, 1)
            end,
        })

        LDBIcon:Register("ToyGuise", minimapButton, db.minimap)
        LDBIcon:Show("ToyGuise")

        self:UnregisterEvent("ADDON_LOADED")

    elseif event == "PLAYER_LOGIN" then
        -- Toy APIs are now reliable
        self:RegisterEvent("TOYS_UPDATED")
        self:RegisterEvent("BAG_UPDATE_COOLDOWN")
        if frame:IsShown() then
            CreateToyButtons()
        end

    elseif event == "TOYS_UPDATED" or event == "BAG_UPDATE_COOLDOWN" then
        if frame:IsShown() then
            CreateToyButtons()
        end
    end
end)


-- Slash command: toggle + resource check
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

frame:Hide()