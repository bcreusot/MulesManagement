--[[
	-------------------
	***** Mules Management *****
	* Benjamin Creusot - Todo
	* 17/04/2014 
	* v1.0
		Manage easily your mules. Automatically places items in your bank
    * MM = MulesManagement
	-------------------
]]--


 -- Global Vars
MMVars = "MulesManagementVars"
currentVersion = "2.0"

othersElementsMM = {
    "ITEMTYPE_WEAPON",
    "ITEMTYPE_WEAPON_BOOSTER",
    "ITEMTYPE_ARMOR",
    "ITEMTYPE_ARMOR_BOOSTER",
    "ITEMTYPE_COSTUME",
    "ITEMTYPE_DISGUISE",
    "ITEMTYPE_DRINK",
    "ITEMTYPE_FOOD",
    "ITEMTYPE_AVA_REPAIR",
    "ITEMTYPE_LOCKPICK",
    "ITEMTYPE_POTION",
    "ITEMTYPE_POISON",
    "ITEMTYPE_RECIPE",
    "ITEMTYPE_SCROLL",
    "ITEMTYPE_SIEGE",
    "ITEMTYPE_SOUL_GEM",
    "ITEMTYPE_TABARD",
    "ITEMTYPE_TROPHY"
}
craftingElementsMM = {
    "CRAFTING_TYPE_RAW",
    "CRAFTING_TYPE_BLACKSMITHING",
    "CRAFTING_TYPE_CLOTHIER",     
    "CRAFTING_TYPE_ENCHANTING",   
    "CRAFTING_TYPE_ALCHEMY",      
    "CRAFTING_TYPE_PROVISIONING", 
    "CRAFTING_TYPE_WOODWORKING",  
    "ITEMTYPE_STYLE_MATERIAL",
    "ITEMTYPE_WEAPON_TRAIT",
    "ITEMTYPE_ARMOR_TRAIT"
}
characterType = {
    "MM_CHARACTER_TYPE_MAIN",
    "MM_CHARACTER_TYPE_MULE"
}
langages = {
    "English",
    "Francais"
}

-- Main Vars
MulesManagement = {}
MulesManagement.Saved = {}

local function placeItemsMM(fromBag, fromSlot, toBag, toSlot, maxDestQuantity)
    --d("[" .. fromBag .. "," .. fromSlot .."] => [" .. toBag .. "," .. toSlot .."] (" .. maxDestQuantity .. ")")
    ClearCursor()
    if CallSecureProtected("PickupInventoryItem", fromBag, fromSlot, maxDestQuantity) then
        CallSecureProtected("PlaceInInventory", toBag, toSlot)
    end
    ClearCursor()
end

local function getTranslated(text)
    return langage[MulesManagement.Saved["langage"]][text]
end

local function isMoveable(craftingType, itemType)
    craftingTypeName = ""
    itemTypeName = ""
    if CRAFTING_TYPE_TRANSLATION_MM[craftingType] then
        craftingTypeName = CRAFTING_TYPE_TRANSLATION_MM[craftingType]
    end    
    if ITEMTYPE_TRANSLATION_MM[itemType] then
        d(itemType)
        itemTypeName = ITEMTYPE_TRANSLATION_MM[itemType]
    end

    --If the All filter is selectec
    if MulesManagement.Saved.all then
        d("all")
        return true
    end
    --CRAFT and RAW Material Test
    if (craftingType ~= CRAFTING_TYPE_INVALID and MulesManagement.Saved[craftingTypeName]) then 
        --if it's a raw material
        if not (itemType == ITEMTYPE_ALCHEMY_BASE or itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL or itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL or itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL) then
            d("wanted but not raw")
            return true
        elseif MulesManagement.Saved["CRAFTING_TYPE_RAW"] then
            d("wanted and raw")
            return true
        else
            d("not wanted and raw")
            return false
        end
    end
    --OTHERS
    if (itemType ~= ITEMTYPE_NONE and MulesManagement.Saved[itemTypeName]) then
        d("itemtype : " ..itemTypeName)
        if craftingTypeName ~= nil then
            d("craft :" .. craftingTypeName)
        end
        return true
    end
    return false
end

local function displayChat(itemName, quantity, moved)
    startString,endString = string.find(itemName,"%^")
    itemName = string.sub(itemName,0,startString-1)
    if MulesManagement.Saved["spamChat"] then
        if moved then
            d(quantity .. " " .. itemName .. " " .. getTranslated("itemsMoved"))
        else
            d(quantity .. " " .. itemName .. " " .. getTranslated("itemsStacked"))
        end
    end
end

local function moveItemsMM(paramFromBag, paramDestinationBag)
    nbItemsMove = 0
    nbItemsStack = 0
    --types of bags
    destinationBag = paramDestinationBag
    fromBag        = paramFromBag
    --get the number of slot in the destination
    bagIcon, bagSlots = GetBagInfo(destinationBag)
    -- last slot in destination => set out of range of the bag
    lastSlotDest = bagSlots + 1

    --slot avalaible in dest
    slotAvalaibleDest = {}
    --Register all the item in the destination to stack the pile
    itemsTables = {}
    --iteration to get all the slots
    for slotDest = 0, bagSlots-1 do
        itemStack, itemMaxStack = GetSlotStackSize(destinationBag, slotDest)
        itemName = GetItemName(destinationBag, slotDest)
        idItem   = GetItemInstanceId(destinationBag, slotDest)
        --if the slot is not empty
        if(itemStack > 0 and itemName ~= nil and idItem ~= nil) and itemStack < itemMaxStack then
            itemsTables[idItem]           = {}
            itemsTables[idItem].stack     = itemStack
            itemsTables[idItem].maxStack  = itemMaxStack
            itemsTables[idItem].slot      = slotDest
        else
            table.insert(slotAvalaibleDest,slotDest)
        end
    end
    
    --Iterate over the from bag to send the items at their rightfull place
    --get the number of slot in the destination
    bagIcon, bagSlots = GetBagInfo(fromBag)
    for slotFrom = 0, bagSlots-1 do
        itemStack, itemMaxStack = GetSlotStackSize(fromBag, slotFrom)
        itemName = GetItemName(fromBag, slotFrom)
        idItem   = GetItemInstanceId(fromBag, slotFrom)

        --if the slot is not empty
        if(itemStack > 0 and itemName ~= nil and idItem ~= nil) then
            --Get the crafting type
            usedInCraftingType, itemType, extraInfo1, extraInfo2, extraInfo3 = GetItemCraftingInfo(fromBag, slotFrom)
            itemType = GetItemType(fromBag, slotFrom)
            --Check if we work on that item or not
            if itemsTables[idItem] or isMoveable(usedInCraftingType, itemType) then
                --if the item is already present on the dest and its not a full stack
                if(itemsTables[idItem]) and itemStack ~= itemMaxStack then
                    destItem = itemsTables[idItem]
                    maxDestQuantity = destItem.maxStack - destItem.stack
                    --If there is enough place
                    -- STACK ONLY --
                    if maxDestQuantity - itemStack >= 0 then
                        placeItemsMM(fromBag, slotFrom, destinationBag, destItem.slot, itemStack)
                        --If there is just enough place
                        if itemStack == itemsTables[idItem].itemMaxStack then
                            table.remove(slotAvalaibleDest,idItem)
                        else
                            itemsTables[idItem].stack = itemsTables[idItem].stack + itemStack
                        end
                        nbItemsStack = nbItemsStack + 1
                        displayChat(itemName, itemStack, false)
                    -- STACK & MOVE --
                    else
                        --place as mush as we can then fill another spot
                        placeItemsMM(fromBag, slotFrom, destinationBag, destItem.slot, maxDestQuantity)
                        nbItemsStack = nbItemsStack + 1
                        displayChat(itemName, maxDestQuantity, false)
                        slotTmp = table.remove(slotAvalaibleDest,1)
                        if DoesBagHaveSpaceFor(destinationBag, fromBag, slotFrom) and slotTmp ~= nil then
                            placeItemsMM(fromBag, slotFrom, destinationBag, slotTmp, itemStack-maxDestQuantity)
                            itemsTables[idItem].stack    = itemStack-maxDestQuantity
                            itemsTables[idItem].slotDest = slotTmp
                            nbItemsMove = nbItemsMove + 1
                            displayChat(itemName, itemStack-maxDestQuantity, true)
                        end
                    end
                --No item found in the destination
                -- MOVE --
                else
                    slotTmp = table.remove(slotAvalaibleDest,1)
                    if DoesBagHaveSpaceFor(destinationBag, fromBag, slotFrom) and slotTmp ~= nil then
                        placeItemsMM(fromBag, slotFrom, destinationBag, slotTmp, itemStack)
                        if itemStack ~= itemMaxStack then
                            itemsTables[idItem]           = {}
                            itemsTables[idItem].stack     = itemStack
                            itemsTables[idItem].maxStack  = itemMaxStack
                            itemsTables[idItem].slot      = slotTmp
                        end
                        nbItemsMove = nbItemsMove + 1
                        displayChat(itemName, itemStack, true)
                    end
                end
            end

        end

    end
    d("----------------------")
    d(nbItemsMove .. " " .. getTranslated("itemsMoved"))
    d(nbItemsStack .. " " .. getTranslated("itemsStacked"))
    d("----------------------")
end

function bankOpeningMM(eventCode, addOnName, isManual)
    if isManual then
        return
    end

    ClearCursor()
    --redirect if main or mules
    if MulesManagement.Saved["characterType"] == getTranslated("MM_CHARACTER_TYPE_MAIN") then
        moveItemsMM(BAG_BACKPACK, BAG_BANK)
    elseif MulesManagement.Saved["characterType"] == getTranslated("MM_CHARACTER_TYPE_MULE") then
        moveItemsMM(BAG_BANK, BAG_BACKPACK)
    end
end

local function changeLangageMM(val)
    lang = MulesManagement.Saved["langage"]
    MulesManagement.Saved["langage"] = val
    for keyTrad,tradValue in pairs(langage[lang]) do
        if MulesManagement.Saved["characterType"] == tradValue then
            d("keyCharacterType " .. keyTrad)
            d("translate " .. getTranslated(keyTrad))
            MulesManagement.Saved["characterType"] = getTranslated(keyTrad)
        end
    end

    ReloadUI()
end
local function changeCharacterTypeMM(val)
    MulesManagement.Saved["characterType"] = val
    ReloadUI()
end



local function getCharacterTypeList()
    characterTypeList = {}
    for k,v in ipairs(characterType) do
        table.insert(characterTypeList, getTranslated(v))
    end
    return characterTypeList
end


local function optionsMM()
    local textCheckBox = ""
    local LAM = LibStub("LibAddonMenu-1.0")
    local optionsPanelMM = LAM:CreateControlPanel("Mules Management", "Mules Management")
    LAM:AddHeader(optionsPanelMM, "versionMM", "|c3366FF" .. getTranslated("version").."|r:" .. currentVersion)
    LAM:AddHeader(optionsPanelMM, "headerMM", "|c3366FF" .. getTranslated("title").."|r" )

    LAM:AddDropdown(optionsPanelMM, "langageMM", getTranslated("dropDownLangageText"), getTranslated("dropDownLangageTooltip"), langages,
            function() return MulesManagement.Saved["langage"] end,
            changeLangageMM,
            true , getTranslated("reloadWarning"))

    LAM:AddCheckbox(optionsPanelMM, "spamChat", getTranslated("spamChatText"), getTranslated("spamChatTooltip"),
                function() return MulesManagement.Saved["spamChat"] end,
                function(val) MulesManagement.Saved["spamChat"] = val end)
    
    LAM:AddDropdown(optionsPanelMM, "characterTypeMM", getTranslated("dropDownCharacterTypeText"), getTranslated("dropDownCharacterTypeTooltip"), getCharacterTypeList(),
            function() return MulesManagement.Saved["characterType"] end,
            changeCharacterTypeMM,
            true , getTranslated("reloadWarning"))

    
    LAM:AddCheckbox(optionsPanelMM, "allMM", getTranslated("AllText"), getTranslated("AllTooltip"),
                function() return MulesManagement.Saved["all"] end,
                function(val) MulesManagement.Saved["all"] = val end)


    --CRAFT MODE
    LAM:AddHeader(optionsPanelMM, "craftHeaderMM",  "|c3366FF" .. getTranslated("craftHeader").."|r")
	for key,craftKey in pairs(craftingElementsMM) do
        craftName = getTranslated(craftKey) .. ""
        if MulesManagement.Saved["characterType"] == getTranslated("MM_CHARACTER_TYPE_MAIN") then
            textCheckBox = craftName .. " - " .. getTranslated("checkBoxTooltipMain")
        elseif MulesManagement.Saved["characterType"] == getTranslated("MM_CHARACTER_TYPE_MULE") then
            textCheckBox = craftName .. " - " .. getTranslated("checkBoxTooltipMule")
        end
        --The checkbox
        LAM:AddCheckbox(optionsPanelMM, craftKey .. craftName, craftName, textCheckBox,
            function() return MulesManagement.Saved[craftKey] end,
            function(val) MulesManagement.Saved[craftKey] = val end)    
    end

    --OTHERS MODE
    LAM:AddHeader(optionsPanelMM, "othersHeaderMM", "|c3366FF" .. getTranslated("othersHeader").."|r")
        for key,othersKey in pairs(othersElementsMM) do
        othersKey = getTranslated(othersKey) .. ""
        if MulesManagement.Saved["characterType"] == getTranslated("MM_CHARACTER_TYPE_MAIN") then
            textCheckBox = othersKey .. " - " .. getTranslated("checkBoxTooltipMain")
        elseif MulesManagement.Saved["characterType"] == getTranslated("MM_CHARACTER_TYPE_MULE") then
            textCheckBox = othersKey .. " - " .. getTranslated("checkBoxTooltipMule")
        end
        --The checkbox
        LAM:AddCheckbox(optionsPanelMM, othersKey .. othersKey, othersKey, textCheckBox,
            function() return MulesManagement.Saved[othersKey] end,
            function(val) MulesManagement.Saved[othersKey] = val end)    
    end
end

function initMM(eventCode, addOnName)
    if addOnName ~= "MulesManagement" then
        return
    end

    local defaults = {
        ["langage"]                 = "English",
        ["spamChat"]                = false,
        ["characterType"]           = langage["English"]["MM_CHARACTER_TYPE_MAIN"],
        ["all"]                     = false
    }
    
    for k,v in ipairs(craftingElementsMM) do
        defaults[v] = false
    end
    for k,v in ipairs(othersElementsMM) do
        defaults[v] = false
    end

    MulesManagement.Saved = ZO_SavedVars:New(MMVars, 2, nil, defaults, nil)
    optionsMM()
    
    EVENT_MANAGER:RegisterForEvent("MulesManagement", EVENT_OPEN_BANK, bankOpeningMM)
end


EVENT_MANAGER:RegisterForEvent("MulesManagement", EVENT_ADD_ON_LOADED, initMM)