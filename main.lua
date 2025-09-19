local api = require("api")
local michaelClientLib = require("dress_up/michael_client")

local dress_up_addon = {
	name = "Dress-Up",
	author = "Michaelqt",
	version = "1.0",
	desc = "Preview the visual appearance of equipment."
}
local RELAX_ANIMATION_NAME = "fist_ba_relaxed_rand_idle"
local dressUpModelViewerX = 365
local dressUpModelViewerY = 700
local turnLeft = false
local turnRight = false
local mouseX = nil
local drag = false

local itemsHelper
local animationHelper

local dressUpWindow
local isFirstOpen
local currentPage
local currentCategory
local categories
local animCategories
local animCurrentCategory
local animations
local items
local itemsFromAPI
local ddsPaths
local pageSize = 1000

local lastCostumeIdEquipped

local loadTimer = 0
local loadRate = 100
local currentLoadId = "1"
local finishedLoading = false



--- Helper Functions
local function toggleDressUpWindow(isShown)
    if dressUpWindow ~= nil then    
        dressUpWindow:Show(isShown)
    end 
end 
local function modelViewerEquipItem(itemId, animation, modelViewer)
    defaultAnimation = RELAX_ANIMATION_NAME
    if animation == nil then 
        modelViewer:EquipItem(itemId)
        modelViewer:PlayAnimation(defaultAnimation, true)
    else
        modelViewer:EquipItem(itemId)
        modelViewer:PlayAnimation(animation, true)
    end 
end 
local function modelViewerDyeCostume(dyeItemId, animation, modelViewer)
    defaultAnimation = RELAX_ANIMATION_NAME
    if animation == nil then 
        modelViewer:EquipCostume(lastCostumeIdEquipped, 3, dyeItemId)
        modelViewer:ApplyModel()
        modelViewer:PlayAnimation(defaultAnimation, true)
    else
        modelViewer:EquipCostume(lastCostumeIdEquipped, 3, dyeItemId)
        modelViewer:PlayAnimation(animation, true)
    end 
end 

local function DataSetFunc(subItem, data, setValue)
    if setValue then
        local str = string.format("%s", data.value)
        local id = data.id
        subItem.id = id
        subItem.textbox:SetText(str)
        F_SLOT.SetIconBackGround(subItem.subItemIcon, data.dds)
    end
end

local function LayoutSetFunc(frame, rowIndex, colIndex, subItem)
    local subItemIcon = CreateItemIconButton("subItemIcon", subItem)
    subItemIcon:Show(true)
    F_SLOT.ApplySlotSkin(subItemIcon, subItemIcon.back, SLOT_STYLE.BUFF)
    F_SLOT.SetIconBackGround(subItemIcon, "game/ui/icon/icon_item_1338.dds")
    subItemIcon:AddAnchor("TOPLEFT", subItem, 0, 0)

    subItem:SetExtent(300, 25)
    local textbox = subItem:CreateChildWidget("textbox", "textbox", 0, true)
    textbox:AddAnchor("TOPLEFT", subItem, 45, 0)
    textbox:AddAnchor("BOTTOMRIGHT", subItem, 0, 0)
    textbox.style:SetAlign(ALIGN.LEFT)
    ApplyTextColor(textbox, FONT_COLOR.DEFAULT)
    subItem.textbox = textbox

    local clickOverlay = subItem:CreateChildWidget("button", "clickOverlay", 0, true)
    clickOverlay:AddAnchor("TOPLEFT", subItem, 0, 0)
    clickOverlay:AddAnchor("BOTTOMRIGHT", subItem, 0, 0)
    function clickOverlay:OnClick()
        local itemId = tonumber(subItem.id) 
        if categories[currentCategory] == "Dyes" then 
            modelViewerDyeCostume(itemId, nil, dressUpWindow.modelViewer)
        end
        if categories[currentCategory] == "Costume" then 
            lastCostumeIdEquipped = itemId
            modelViewerEquipItem(itemId, nil, dressUpWindow.modelViewer)
        else 
            modelViewerEquipItem(itemId, nil, dressUpWindow.modelViewer)
        end 
    end 
    clickOverlay:SetHandler("OnClick", clickOverlay.OnClick)
    subItem.clickOverlay = clickOverlay
end
-- Item Scroll Filling Data
local function fillItemData(itemScrollList, pageIndex, searchText)
    local startingIndex = 1
    if pageIndex > 1 then 
        startingIndex = ((pageIndex - 1) * pageSize) + 1 
    end
    itemScrollList:DeleteAllDatas()

    -- If there is search text, cut that list down.
    if searchText ~= nil then
        local count = 1
        local categoryName = categories[currentCategory]
        for _, itemObject in pairs(items[categoryName]) do
            if string.find(itemObject.name:lower(), searchText:lower()) then 
                local ddsPath = ""
                if itemObject.path == nil then 
                    ddsPath = ddsPaths[itemObject.id]
                else 
                    ddsPath = itemObject.path
                end     
                local itemData = {
                    dds = "game/ui/icon/" .. tostring(ddsPath),
                    id = itemObject.id,
                    value = itemObject.name, 
                    isViewData = true, 
                    isAbstention = false
                }
                itemScrollList:InsertData(count, 1, itemData, false)
                count = count + 1
            end 
        end
    else -- Otherwise, draw it all.
        local count = 1
        local categoryName = categories[currentCategory]
        for _, itemObject in pairs(items[categoryName]) do
            local ddsPath = ""
            if itemObject.path == nil and ddsPaths[itemObject.id] then 
                ddsPath = "game/ui/icon/" .. ddsPaths[itemObject.id]
            else 
                ddsPath = itemObject.path
            end 
            -- api.Log:Info(itemObject)
            local itemData = {
                dds = ddsPath,
                id = itemObject.id,
                value = itemObject.name, 
                isViewData = true, 
                isAbstention = false
            }
            itemScrollList:InsertData(count, 1, itemData, false)
            count = count + 1
        end
    end 
end 
-- Initializes the model viewer to use the player's model and equipment.
local function initModelViewer(modelViewer)
    modelViewer.equippedWeapon = false
    -- modelViewer:Initialize()
    modelViewer:Init("player", true)
    modelViewer:PlayAnimation(RELAX_ANIMATION_NAME, true)
    if isFirstOpen == true then 
        modelViewer:AdjustCameraPos(0, 1, 0)
        isFirstOpen = false
    end
    dressUpWindow.itemScrollList:SetPageByItemCount(1000, pageSize)
    fillItemData(dressUpWindow.itemScrollList, 1, nil)
end
-- Determine whether the chat message is from the player and should open the addon
local function isChatMessageFromPlayer(channel, unit, isHostile, name, message, speakerInChatBound, specifyName, factionName, trialPosition)
    local playerName = api.Unit:GetUnitNameById(api.Unit:GetUnitId("player"))
    if playerName == name and message == "!dressup" then
        initModelViewer(dressUpWindow.modelViewer)
        toggleDressUpWindow(true)
        --return true
    end
    --return false
end 
-- OnUpdate for addon, for controlling model viewer.
local function OnUpdate(dt)
    local modelViewer = dressUpWindow.modelViewer
    if drag == true  then
        local newMouseX, _ = api.Input:GetMousePos()
        local value = (newMouseX - mouseX) * 25
        modelViewer:AddRotation(value * dt / 1000)
        mouseX = newMouseX
    elseif turnLeft == true then 
        modelViewer:AddRotation(-200 * dt / 1000)
    elseif turnRight == true then 
        modelViewer:AddRotation(200 * dt / 1000)
    end 

    loadTimer = loadTimer + dt
    if loadTimer > loadRate and finishedLoading == false then 
        loadTimer = 0
        for i=1, 5000 do 
            local itemInfo = api.Item:GetItemInfoByType(tonumber(currentLoadId))
            -- api.Log:Info(itemInfo.item_impl)
            if itemInfo.item_impl ~= "invalid_impl" then 
                local name = itemInfo.name or "DO NOT TRANSLATE"
                local path = itemInfo.path or ""
                local category = itemInfo.category or "DO NOT TRANSLATE"
                local slotTypeNum = itemInfo.slotTypeNum or "0"
                local slotType = itemInfo.slotType or "DO NOT TRANSLATE"
                local itemUsage = itemInfo.itemUsage or "DO NOT TRANSLATE"
                local lookType = itemInfo.lookType or -1
                local itemType = itemInfo.itemType or -1
                -- for key,value in pairs(itemInfo) do
                --     api.Log:Info("[Dress Up] Item Info: " .. tostring(key) .. " | " .. tostring(value))
                -- end
                -- api.Log:Info(currentLoadId)
                -- api.Log:Info(itemUsage)
                local isDoNotTranslate = string.find(name, "DO NOT TRANSLATE")
                if itemUsage == "equip" and isDoNotTranslate == nil then 
                    -- First, insert it into "All"
                    if slotTypeNum ~= nil and itemInfo.item_impl ~= "accessory" and itemInfo.item_impl ~= "misc" and itemInfo.item_impl ~= "slave_equipment" and itemInfo.item_impl ~= "mate_armor" then
                        itemsFromAPI["All"] = itemsFromAPI["All"] or {}
                        table.insert(itemsFromAPI["All"], {id = currentLoadId, name = name})
                        if slotTypeNum == 1 then 
                            -- Head
                            itemsFromAPI["Head"] = itemsFromAPI["Head"] or {}
                            table.insert(itemsFromAPI["Head"], {id = currentLoadId, name = name, path = path})
                        elseif slotTypeNum == 3 then
                            -- Shirt
                            itemsFromAPI["Chest"] = itemsFromAPI["Chest"] or {}
                            table.insert(itemsFromAPI["Chest"], {id = currentLoadId, name = name, path = path})
                        elseif slotTypeNum == 4 then 
                            -- Waist
                        elseif slotTypeNum == 5 then 
                            -- Pants
                            itemsFromAPI["Legs"] = itemsFromAPI["Legs"] or {}
                            table.insert(itemsFromAPI["Legs"], {id = currentLoadId, name = name, path = path})
                        elseif slotTypeNum == 6 then 
                            -- Hand
                            itemsFromAPI["Hands"] = itemsFromAPI["Hands"] or {}
                            table.insert(itemsFromAPI["Hands"], {id = currentLoadId, name = name, path = path})
                        elseif slotTypeNum == 7 then 
                            -- Feet
                            itemsFromAPI["Feet"] = itemsFromAPI["Feet"] or {}
                            table.insert(itemsFromAPI["Feet"], {id = currentLoadId, name = name, path = path})
                        elseif slotTypeNum == 8 then 
                            -- Wrists
                        elseif slotTypeNum == 9 then 
                            -- Cloak
                            itemsFromAPI["Cloak"] = itemsFromAPI["Cloak"] or {}
                            table.insert(itemsFromAPI["Cloak"], {id = currentLoadId, name = name, path = path})
                        elseif slotTypeNum == 13 then 
                            -- Underwear
                        elseif slotTypeNum == 14 or slotTypeNum == 15 or slotTypeNum == 16 or slotTypeNum == 17 or slotTypeNum == 18 or slotTypeNum == 20 or slotTypeNum == 21 then 
                            -- 1H weapons
                            itemsFromAPI[category] = itemsFromAPI[category] or {}
                            table.insert(itemsFromAPI[category], {id = currentLoadId, name = name, path = path})
                            -- for key,value in pairs(itemInfo) do
                            --     api.Log:Info("[Dress Up] Item Info: " .. tostring(key) .. " | " .. tostring(value))
                            -- end
                            -- api.Log:Info(category)
                        elseif slotTypeNum == 31 then 
                            -- Costume
                            itemsFromAPI["Costume"] = itemsFromAPI["Costume"] or {}
                            table.insert(itemsFromAPI["Costume"], {id = currentLoadId, name = name, path = path})
                        else
                            -- api.Log:Info("[Dress Up] Unhandled slotTypeNum: " .. tostring(slotTypeNum) .. " for item ID: " .. tostring(currentLoadId) .. " | " .. tostring(name) .. " | " .. tostring(itemInfo.item_impl))
                        end 
                        
                    end
                end 
            end 
            
             
            currentLoadId = X2Util:StrNumericAdd(currentLoadId, "1")
        end 
        if tonumber(currentLoadId) < 500000 and tonumber(currentLoadId) > 105000 then
            currentLoadId = "8000000"
        elseif tonumber(currentLoadId) < 8800000 and tonumber(currentLoadId) > 8100000 then 
            currentLoadId = "9000000"
        elseif tonumber(currentLoadId) > 9100000 then 
            finishedLoading = true
            itemsFromAPI["Dyes"] = items["Dyes"]
            items = itemsFromAPI
            fillItemData(dressUpWindow.itemScrollList, 1, nil)
            api.Log:Info("[Dress Up] Finished loading items from API.")
        end 
        -- api.Log:Info("[Dress Up] Addon is attempting a load.")
    end
end 



local function OnLoad()
    local settings = api.GetSettings("dress_up")
    local itemsHelper = require("dress_up/items_helper")
    local animationHelper = require("dress_up/animation_helper")

    --- Draw Dress Up Main Window
    dressUpWindow = api.Interface:CreateWindow("dressUpWindow", "Dress Up")
    dressUpWindow:SetHeight(800)
    -- Has the window been opened yet? 
    isFirstOpen = true
    -- What page do we start on?
    currentPage = 1
    -- What category should we view?
    currentCategory = 1
    categories = itemsHelper.categoryData
    -- What animation category should we view?
    animCurrentCategory = 4
    animCategories = animationHelper.categories
    -- We need some animation names
    animations = animationHelper.animationData
    -- We need some items to view.
    items = itemsHelper.itemData
    -- Let's also get a copy of items from the game's API.
    itemsFromAPI = {}
    -- And we need their icons.
    ddsPaths = itemsHelper.ddsData
    -- Let's set the last costume equipped to the current one on the player
    lastCostumeEquipped = api.Equipment:GetEquippedItemTooltipInfo(EQUIP_SLOT.COSPLAY)
    if lastCostumeEquipped ~= nil then 
        lastCostumeIdEquipped = lastCostumeEquipped.lookType
    end 

    -- Michael Addon Menu
    michaelClientLib:initializeMichaelClient()
	local configMenu = ADDON:GetContent(UIC.SYSTEM_CONFIG_FRAME)
	configMenu.michaelClient:AddAddon("Dress-Up", function()
        initModelViewer(dressUpWindow.modelViewer)
		dressUpWindow:Show(true)
	end)


    -- Model Viewer Window
    local modelViewer = dressUpWindow:CreateChildWidget("modelview", "modelViewer", 0, true)
    modelViewer:SetExtent(dressUpModelViewerX, dressUpModelViewerY)
    modelViewer:SetTextureSize(512, 512)
    local width = dressUpModelViewerX * 512 / dressUpModelViewerY
    modelViewer:SetModelViewExtent(width, 512)
    modelViewer:SetModelViewCoords((512 - width) / 2, 0, width, 512)
    modelViewer:AddAnchor("LEFT", dressUpWindow, 5, 0)
    -- TODO: backgrounds? -> modelViewer:SetModelViewBackground("ui/beautyshop/bg.dds")
    --- Model Viewer Controls (zoom, rotate, reset, animations)
    local controlBarYOffset = 0
    local animBarYOffset = 35
    -- Animation Dropdowns + Label
    local animCategoryBtn = api.Interface:CreateComboBox(modelViewer)
    animCategoryBtn:AddAnchor("BOTTOMLEFT", modelViewer, 90, animBarYOffset)
    animCategoryBtn:SetWidth(100)
    animCategoryBtn.dropdownItem = animCategories
    animCategoryBtn:Select(4)
   
    local animCategoryLabel = animCategoryBtn:CreateChildWidget("label", "animCategoryLabel", 0, true)
    animCategoryLabel:SetText("Animation: ")
    animCategoryLabel.style:SetAlign(ALIGN.RIGHT)
    animCategoryLabel.style:SetFontSize(FONT_SIZE.XLARGE)
    ApplyTextColor(animCategoryLabel, FONT_COLOR.DEFAULT)
    animCategoryLabel:AddAnchor("TOPRIGHT", animCategoryBtn, "LEFT", 0, 0)
    -- Animation     
    local animSelectBtn = api.Interface:CreateComboBox(modelViewer)
    animSelectBtn:AddAnchor("TOPLEFT", animCategoryBtn, "TOPRIGHT", 0, 0)
    animSelectBtn:SetWidth(300)
    animSelectBtn.dropdownItem = animations[animCategories[4]]
    animSelectBtn:Select(1)
    -- Animation Category Selection SelectedProc
    function animCategoryBtn:SelectedProc()
        local clickedAnimCategory = animCategories[self:GetSelectedIndex()]
        animCurrentCategory  = self:GetSelectedIndex()
        animSelectBtn.dropdownItem = animations[animCategories[animCurrentCategory]]
        animSelectBtn:Select(1)
    end 
    -- Animation Selection SelectedProc
    function animSelectBtn:SelectedProc()
        local clickedAnimation = animations[animCategories[animCurrentCategory]][self:GetSelectedIndex()]
        modelViewer:PlayAnimation(clickedAnimation, true)
    end 

    --- Custom Crawling Animation Test
    -- local animCrawlingBtn = animSelectBtn:CreateChildWidget("button", "animCrawlingBtn", 0, true)
    -- animCrawlingBtn:AddAnchor("TOPLEFT", animSelectBtn, "TOPRIGHT", 0, 0)
    -- ApplyButtonSkin(animCrawlingBtn, BUTTON_BASIC.DEFAULT)
    -- animCrawlingBtn:SetText("crawling btn")
    -- animationByIdTextEdit = W_CTRL.CreateEdit("equipByIdTextEdit", dressUpWindow)
    -- animationByIdTextEdit:SetExtent(90, 24)
    -- animationByIdTextEdit:AddAnchor("TOPLEFT", animCrawlingBtn, "TOPRIGHT", 0, 4)

    -- local itemInfo = api.Item:GetItemInfoByType(tonumber("9000971"))
    
    -- for key,value in pairs(itemInfo) do
    --     api.Log:Info("[Dress Up] Item Info: " .. tostring(key) .. " | " .. tostring(value))
    -- end
    -- function animCrawlingBtn:OnClick()
    --     local animationName = animationByIdTextEdit:GetText()
    --     modelViewer:PlayAnimation(animationName, true)
    --     api.Log:Info("[CRAWLING] Now playing: " .. tostring(animationName))
    -- end 
    -- animCrawlingBtn:SetHandler("OnClick", animCrawlingBtn.OnClick)


    -- Rotation through buttons
    
    local rotateRight = modelViewer:CreateChildWidget("button", "rotateRight", 0, true)
    rotateRight:AddAnchor("BOTTOMLEFT", modelViewer, 5, controlBarYOffset)
    ApplyButtonSkin(rotateRight, BUTTON_BASIC.ROTATE_RIGHT)
    function rotateRight:OnMouseDown(arg)
        turnRight = true
    end
    rotateRight:SetHandler("OnMouseDown", rotateRight.OnMouseDown)
    function rotateRight:OnMouseUp(arg)
        turnRight = false
    end
    rotateRight:SetHandler("OnMouseUp", rotateRight.OnMouseUp)
    function rotateRight:OnLeave(arg)
        turnRight = false
    end
    rotateRight:SetHandler("OnLeave", rotateRight.OnLeave)
    local rotateLeft = modelViewer:CreateChildWidget("button", "rotateLeft", 0, true)
    rotateLeft:AddAnchor("BOTTOMRIGHT", modelViewer, -5, controlBarYOffset)
    ApplyButtonSkin(rotateLeft, BUTTON_BASIC.ROTATE_LEFT)
    function rotateLeft:OnMouseDown(arg)
        turnLeft = true
    end
    rotateLeft:SetHandler("OnMouseDown", rotateLeft.OnMouseDown)
    function rotateLeft:OnMouseUp(arg)
        turnLeft = false
    end
    rotateLeft:SetHandler("OnMouseUp", rotateLeft.OnMouseUp)
    function rotateLeft:OnLeave(arg)
        turnLeft = false
    end
    rotateLeft:SetHandler("OnLeave", rotateLeft.OnLeave)
    -- Rotation through dragging
    function modelViewer:OnDragStart()
        drag = true
        local newMouseX, _ = api.Input:GetMousePos()
        mouseX = newMouseX
    end
    modelViewer:SetHandler("OnDragStart", modelViewer.OnDragStart)
    function modelViewer:OnDragStop()
        drag = false  
    end
    modelViewer:SetHandler("OnDragStop", modelViewer.OnDragStop)
    modelViewer:EnableDrag(true)
    -- Zoom Controls
    local zoomIn = modelViewer:CreateChildWidget("button", "zoomIn", 0, true)
    zoomIn:AddAnchor("BOTTOMLEFT", modelViewer, 50, controlBarYOffset)
    ApplyButtonSkin(zoomIn, BUTTON_BASIC.DEFAULT)
    zoomIn:SetText("Zoom In")
    function zoomIn:OnClick()
        modelViewer:AdjustCameraPos(0, -0.3, 0)
    end 
    zoomIn:SetHandler("OnClick", zoomIn.OnClick)
    local zoomOut = modelViewer:CreateChildWidget("button", "zoomOut", 0, true)
    zoomOut:AddAnchor("BOTTOMRIGHT", modelViewer, -50, controlBarYOffset)
    ApplyButtonSkin(zoomOut, BUTTON_BASIC.DEFAULT)
    zoomOut:SetText("Zoom Out")
    function zoomOut:OnClick()
        modelViewer:AdjustCameraPos(0, 0.3, 0)
    end 
    zoomOut:SetHandler("OnClick", zoomOut.OnClick)
    -- Reset Model Viewer
    local reset = modelViewer:CreateChildWidget("button", "reset", 0, true)
    reset:AddAnchor("BOTTOM", modelViewer, 0, controlBarYOffset)
    ApplyButtonSkin(reset, BUTTON_BASIC.DEFAULT)
    reset:SetText("Reset")
    function reset:OnClick()
        modelViewer:ClearModel()
        initModelViewer(modelViewer)
        animCategoryBtn:Select(4)
        animCurrentCategory = 4
        animSelectBtn.dropdownItem = animations[animCategories[animCurrentCategory]]
        animSelectBtn:Select(1)
        
    end 
    reset:SetHandler("OnClick", reset.OnClick)

    --- Item Search Scroll List 
    local itemScrollList = W_CTRL.CreatePageScrollListCtrl("itemScrollList", dressUpWindow)
    itemScrollList:SetWidth(300)
    itemScrollList:AddAnchor("TOPRIGHT", dressUpWindow, -10, 120)
    itemScrollList:AddAnchor("BOTTOMRIGHT", dressUpWindow, -10, -40)
    itemScrollList.scroll:AddAnchor("TOPRIGHT", itemScrollList, 0, 0)
    itemScrollList.scroll:AddAnchor("BOTTOMRIGHT", itemScrollList, 0, 0)
    itemScrollList:InsertColumn("", 300, 0, DataSetFunc, nil, nil, LayoutSetFunc)
    itemScrollList:InsertRows(14, false)
    itemScrollList:SetColumnHeight(40)
    -- Name Search Text Edit + Label
    nameSearchTextEdit = W_CTRL.CreateEdit("nameSearchTextEdit", dressUpWindow)
    nameSearchTextEdit:SetExtent(180, 24)
    nameSearchTextEdit:AddAnchor("TOPRIGHT", itemScrollList, 0, -30)
    nameSearchTextEdit.style:SetFontSize(FONT_SIZE.XLARGE)
    nameSearchLabel = nameSearchTextEdit:CreateChildWidget("label", "nameSearchLabel", 0, true)
    nameSearchLabel:SetText("Search Name: ")
    nameSearchLabel.style:SetAlign(ALIGN.RIGHT)
    nameSearchLabel.style:SetFontSize(FONT_SIZE.XLARGE)
    ApplyTextColor(nameSearchLabel, FONT_COLOR.DEFAULT)
    nameSearchLabel:AddAnchor("TOPRIGHT", nameSearchTextEdit, "LEFT", 0, 0)
    -- Name Search OnTextChanged
    function nameSearchTextEdit:OnTextChanged()
        local searchText = nameSearchTextEdit:GetText()
        if #searchText > 2 or #searchText == 0 then 
            fillItemData(itemScrollList, 1, searchText)
        end 
	end
	nameSearchTextEdit:SetHandler("OnTextChanged", nameSearchTextEdit.OnTextChanged)

    -- Equip by ID Text Edit + Button + Label
    equipByIdBtn = dressUpWindow:CreateChildWidget("button", "equipByIdBtn", 0, true)
    ApplyButtonSkin(equipByIdBtn, BUTTON_BASIC.DEFAULT)
    equipByIdBtn:SetText("Equip ID")
    equipByIdBtn:SetExtent(65, 30)
    equipByIdBtn:AddAnchor("TOPRIGHT", itemScrollList, 0, -65)
    equipByIdTextEdit = W_CTRL.CreateEdit("equipByIdTextEdit", dressUpWindow)
    equipByIdTextEdit:SetExtent(115, 24)
    equipByIdTextEdit:AddAnchor("TOPRIGHT", equipByIdBtn, "TOPLEFT", 0, 4)
    equipByIdLabel = equipByIdTextEdit:CreateChildWidget("label", "equipByIdLabel", 0, true)
    equipByIdLabel:SetText("Equip By ID: ")
    equipByIdLabel.style:SetAlign(ALIGN.RIGHT)
    equipByIdLabel.style:SetFontSize(FONT_SIZE.XLARGE)
    ApplyTextColor(equipByIdLabel, FONT_COLOR.DEFAULT)
    equipByIdLabel:AddAnchor("TOPRIGHT", equipByIdTextEdit, "LEFT", 0, 0)
    -- Equip By ID OnClick
    function equipByIdBtn:OnClick()
        local itemId = tonumber(equipByIdTextEdit:GetText())
        if itemId ~= nil then 
            modelViewerEquipItem(itemId, nil, modelViewer)
        else
            api.Log:Info("[Dress Up] " .. equipByIdTextEdit:GetText() .. " is an invalid item ID.")
        end 
    end 
    equipByIdBtn:SetHandler("OnClick", equipByIdBtn.OnClick)

    -- Category Dropdown + Label
    local itemCategoryBtn = api.Interface:CreateComboBox(dressUpWindow)
    itemCategoryBtn:AddAnchor("TOPRIGHT", itemScrollList, 0, 0)
    itemCategoryBtn:SetWidth(180)
    itemCategoryBtn.style:SetFontSize(FONT_SIZE.XLARGE)
    itemCategoryBtn.dropdownItem = categories
    itemCategoryBtn:Select(currentCategory)
    local itemCategoryLabel = itemCategoryBtn:CreateChildWidget("label", "itemCategoryLabel", 0, true)
    itemCategoryLabel:SetText("Item Category: ")
    itemCategoryLabel.style:SetAlign(ALIGN.RIGHT)
    itemCategoryLabel.style:SetFontSize(FONT_SIZE.XLARGE)
    ApplyTextColor(itemCategoryLabel, FONT_COLOR.DEFAULT)
    itemCategoryLabel:AddAnchor("TOPRIGHT", itemCategoryBtn, "LEFT", 0, 0)
    -- Category Selection SelectedProc
    function itemCategoryBtn:SelectedProc()
        local clickedCategory = categories[self:GetSelectedIndex()]
        currentCategory  = self:GetSelectedIndex()
        fillItemData(dressUpWindow.itemScrollList, 1, nil)
    end 

    itemScrollList.pageControl:Show(false)

    -- Data Pagination
    function itemScrollList:OnPageChangedProc(curPageIdx)
        fillItemData(itemScrollList, curPageIdx, nil) 
    end
    
    --- Event Handlers for main window
    -- Whenever there's a chat message, see if we should pop the window up.
    function dressUpWindow:OnEvent(event, ...)
        if event == "CHAT_MESSAGE" then
            if arg ~= nil then 
                isChatMessageFromPlayer(unpack(arg))
            end 
        end
    end
    dressUpWindow:SetHandler("OnEvent", dressUpWindow.OnEvent)
    dressUpWindow:RegisterEvent("CHAT_MESSAGE")
    local eventWnd = dressUpWindow:CreateChildWidget("label", "eventWnd", 0, true)
    -- OnHide handler, clears model and item list
    function dressUpWindow:OnHide()
        modelViewer:ClearModel()
        itemScrollList:DeleteAllDatas()
    end 
    dressUpWindow:SetHandler("OnHide", dressUpWindow.OnHide)

    -- Start disabled by default
    dressUpWindow:Show(false)

    api.On("UPDATE", OnUpdate)
    api.On("CHAT_MESSAGE", isChatMessageFromPlayer)
    api.SaveSettings()
end 

local function OnUnload()
	local settings = api.GetSettings("dress_up")
    -- Blow the window up.
    dressUpWindow:Show(false)
    dressUpWindow:ReleaseHandler("OnEvent")
    dressUpWindow:ReleaseHandler("OnHide")
    dressUpWindow = nil

    items = nil
    itemsFromAPI = nil
    ddsPaths = nil
    animations = nil
    categories = nil

    michaelClientLib:OnUnload()

    api.SaveSettings()
end

dress_up_addon.OnLoad = OnLoad
dress_up_addon.OnUnload = OnUnload

return dress_up_addon