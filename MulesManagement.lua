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


othersElementsMM = {
    ITEMTYPE_WEAPON,
    ITEMTYPE_ARMOR
}
craftingElementsMM = {
    CRAFTING_TYPE_BLACKSMITHING,
    CRAFTING_TYPE_CLOTHIER,
    CRAFTING_TYPE_ENCHANTING,
    CRAFTING_TYPE_ALCHEMY,
    CRAFTING_TYPE_PROVISIONING,
    CRAFTING_TYPE_WOODWORKING
}
characterType = {
    MM_CHARACTER_TYPE_MAIN,
    MM_CHARACTER_TYPE_MULE
}
itemsFilter = {
    MM_ITEMS_FILTER_ALL,
    MM_ITEMS_FILTER_CRAFT
}
langages = {
    "English",
    "Francais"
}

-- Main Vars
MulesManagement = {}
MulesManagement.Saved = {}

local function placeItemsMM(fromBag, fromSlot, toBag, toSlot, maxDestQuantity)
    --d("place items")
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
    --If the All filter is selectec
    if MulesManagement.Saved.itemsFilter == getTranslated(MM_ITEMS_FILTER_ALL) then
        return true
    end
    --If the craft filter is selected
    if (craftingType ~= CRAFTING_TYPE_INVALID and MulesManagement.Saved[craftingType]) then
        return true
    end
    return false
end

local function moveItemsMM(paramFromBag, paramDestinationBag)
    nbItemsMove = 0
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
        --if the slot is not empty
        if(itemStack > 0 and itemName ~= nil) and itemStack < itemMaxStack then
            itemsTables[itemName]           = {}
            itemsTables[itemName].stack     = itemStack
            itemsTables[itemName].maxStack  = itemMaxStack
            itemsTables[itemName].slot      = slotDest
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

        --if the slot is not empty
        if(itemStack > 0 and itemName ~= nil) then
            --Get the crafting type
            usedInCraftingType, itemType, extraInfo1, extraInfo2, extraInfo3 = GetItemCraftingInfo(fromBag, slotFrom)
            --Check if we work on that item or not
            if isMoveable(usedInCraftingType, itemType) then
                --if the item is already present on the dest
                if(itemsTables[itemName]) then
                    destItem = itemsTables[itemName]
                    maxDestQuantity = destItem.maxStack - destItem.stack
                    --If there is enough place
                    if maxDestQuantity - itemStack >= 0 then
                        placeItemsMM(fromBag, slotFrom, destinationBag, destItem.slot, itemStack)
                    else
                        --place as mush as we can then fill another spot
                        placeItemsMM(fromBag, slotFrom, destinationBag, destItem.slot, maxDestQuantity)
                        nbItemsMove = nbItemsMove + 1
                        d("itemName : " .. itemName)
                        slotTmp = table.remove(slotAvalaibleDest,1)
                        if DoesBagHaveSpaceFor(destinationBag, fromBag, slotFrom) and slotTmp ~= nil then
                            placeItemsMM(fromBag, slotFrom, destinationBag, slotTmp, itemStack-maxDestQuantity)
                        end
                    end
                --No item found in the destination
                else
                    slotTmp = table.remove(slotAvalaibleDest,1)
                    if DoesBagHaveSpaceFor(destinationBag, fromBag, slotFrom) and slotTmp ~= nil then
                        d("itemName : " .. itemName)
                        d("fromBag : " .. fromBag )
                        d("slotFrom : " .. slotFrom )
                        d("destinationBag : " .. destinationBag )
                        d("slotTmp : " .. slotTmp )
                        d("itemStack : " .. itemStack )
                        placeItemsMM(fromBag, slotFrom, destinationBag, slotTmp, itemStack)
                        nbItemsMove = nbItemsMove + 1
                    end
                end
            end

        end

    end
    d(nbItemsMove .. " " .. getTranslated("itemsMoved"))
end

function bankOpeningMM(eventCode, addOnName, isManual)
    if isManual then
        return
    end

    ClearCursor()
    --redirect if main or mules
    if MulesManagement.Saved["characterType"] == getTranslated(MM_CHARACTER_TYPE_MAIN) then
        moveItemsMM(BAG_BACKPACK, BAG_BANK)
    elseif MulesManagement.Saved["characterType"] == getTranslated(MM_CHARACTER_TYPE_MULE) then
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
        elseif MulesManagement.Saved["itemsFilter"] == tradValue then
            d("keyItemsFilter " .. keyTrad)
            d("translate " .. getTranslated(keyTrad))
            MulesManagement.Saved["itemsFilter"]   = getTranslated(keyTrad)
        end
    end

    ReloadUI()
end
local function changeItemsFilterMM(val)
    MulesManagement.Saved["itemsFilter"] = val
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
local function getItemsFilterList()
    itemsFilterList = {}
    for k,v in ipairs(itemsFilter) do
        table.insert(itemsFilterList, getTranslated(v))
    end
    return itemsFilterList
end


local function optionsMM()
    local textCheckBox = ""
    local LAM = LibStub("LibAddonMenu-1.0")
    local optionsPanelMM = LAM:CreateControlPanel("Mules Management", "Mules Management")

    LAM:AddHeader(optionsPanelMM, "headerMM", getTranslated("title"))

    LAM:AddDropdown(optionsPanelMM, "langageMM", getTranslated("dropDownLangageText"), getTranslated("dropDownLangageTooltip"), langages,
            function() return MulesManagement.Saved["langage"] end,
            changeLangageMM,
            true , getTranslated("reloadWarning"))

    LAM:AddDropdown(optionsPanelMM, "characterTypeMM", getTranslated("dropDownCharacterTypeText"), getTranslated("dropDownCharacterTypeTooltip"), getCharacterTypeList(),
            function() return MulesManagement.Saved["characterType"] end,
            changeCharacterTypeMM,
            true , getTranslated("reloadWarning"))

    LAM:AddDropdown(optionsPanelMM, "itemsFilterMM", getTranslated("dropDownItemsFilterText"), getTranslated("dropDownItemsFilterTooltip"), getItemsFilterList(),
            function() return MulesManagement.Saved["itemsFilter"] end,
            changeItemsFilterMM,
            true , getTranslated("reloadWarning"))

    --if it's craft mode !
    if MulesManagement.Saved["itemsFilter"] == getTranslated(MM_ITEMS_FILTER_CRAFT) then
    	for key,craftKey in pairs(craftingElementsMM) do
            craftName = getTranslated(craftKey)
            if MulesManagement.Saved["characterType"] == getTranslated(MM_CHARACTER_TYPE_MAIN) then
                textCheckBox = craftName .. " - " .. getTranslated("craftCheckBoxTooltipMain")
            elseif MulesManagement.Saved["characterType"] == getTranslated(MM_CHARACTER_TYPE_MULE) then
                textCheckBox = craftName .. " - " .. getTranslated("craftCheckBoxTooltipMule")
            end
            --The checkbox
            LAM:AddCheckbox(optionsPanelMM, craftKey .. craftName, craftName, textCheckBox,
                function() return MulesManagement.Saved[craftKey] end,
                function(val) MulesManagement.Saved[craftKey] = val end)
        end
    --if it's others filters mode
    elseif MulesManagement.Saved["itemsFilter"] == getTranslated(MM_ITEMS_FILTER_OTHERS) then

    end
end

function initMM(eventCode, addOnName)
    if addOnName ~= "MulesManagement" then
        return
    end

    local defaults = {
        ["langage"]                 = "English",
        ["characterType"]           = langage["English"][MM_CHARACTER_TYPE_MAIN],
        ["itemsFilter"]             = langage["English"][MM_ITEMS_FILTER_CRAFT]
    }
    
    for k,v in ipairs(craftingElementsMM) do
        defaults[v] = false
    end
    
    MulesManagement.Saved = ZO_SavedVars:New(MMVars, 1, nil, defaults, nil)
    optionsMM()
    
    EVENT_MANAGER:RegisterForEvent("MulesManagement", EVENT_OPEN_BANK, bankOpeningMM)
end


EVENT_MANAGER:RegisterForEvent("MulesManagement", EVENT_ADD_ON_LOADED, initMM)