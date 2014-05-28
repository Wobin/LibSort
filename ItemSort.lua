ItemSort = {}

local watchedSlots = {[SLOT_TYPE_GUILD_BANK_ITEM] = true, [SLOT_TYPE_ITEM] = true, [SLOT_TYPE_BANK_ITEM] = true }

local IS_WEAPON = { [EQUIP_TYPE_MAIN_HAND] = true, [EQUIP_TYPE_OFF_HAND] = true, [EQUIP_TYPE_ONE_HAND] = true, [EQUIP_TYPE_TWO_HAND] = true}

local WEAPON_ORDER = {
	[WEAPONTYPE_AXE] =  1,
	[WEAPONTYPE_DAGGER] =  2,
	[WEAPONTYPE_HAMMER] = 3,
	[WEAPONTYPE_SWORD] = 4,

	[WEAPONTYPE_TWO_HANDED_AXE] = 5,
	[WEAPONTYPE_TWO_HANDED_HAMMER] = 6, 
	[WEAPONTYPE_TWO_HANDED_SWORD] = 7,
	
	[WEAPONTYPE_BOW] = 8,
	
	[WEAPONTYPE_FIRE_STAFF] = 9,
	[WEAPONTYPE_FROST_STAFF] =  10,
	[WEAPONTYPE_LIGHTNING_STAFF] = 11,
	[WEAPONTYPE_HEALING_STAFF] = 12,

	[WEAPONTYPE_NONE] = 13,
	[WEAPONTYPE_RUNE] = 14,
	[WEAPONTYPE_SHIELD] = 15	
}

local ARMOUR_ORDER = {
	[EQUIP_TYPE_HEAD] = 1,
	[EQUIP_TYPE_NECK] = 2,
	[EQUIP_TYPE_SHOULDERS] = 3,
	[EQUIP_TYPE_CHEST] = 4,
	[EQUIP_TYPE_HAND] = 5,
	[EQUIP_TYPE_RING] = 6,
	[EQUIP_TYPE_WAIST] = 7, 
	[EQUIP_TYPE_LEGS] = 8,
	[EQUIP_TYPE_FEET] = 9,

	[EQUIP_TYPE_MAIN_HAND] = 10,
	[EQUIP_TYPE_OFF_HAND] = 11,
	[EQUIP_TYPE_ONE_HAND] = 12,
	[EQUIP_TYPE_TWO_HAND] = 13,
	[EQUIP_TYPE_COSTUME] = 14,	
}

function ItemSort:Loaded(...)
	local eventCode, addonName = ...
	if addonName ~= "ItemSort" then return end

	ItemSort.hookedFunction = ZO_Inventory_BindSlot
	ZO_Inventory_BindSlot = 
		function(...)
			ItemSort.hookedFunction(...)
			local control, slotType, index, bag = ...
			local slot = control:GetParent()

			if not slot or not slot.dataEntry or not slot.dataEntry.data then return end
			
			-- Damnit, it's a subjective item level
			local iLevel = GetItemLevel(bag, index)

			slot.dataEntry.data.subjectiveItemLevel = iLevel
			slot.dataEntry.data.weaponType = 0
			slot.dataEntry.data.armorType = 0

			if watchedSlots[slotType] then
				local _, _, _, _, _, equipType = GetItemInfo(bag, index)
				slot.dataEntry.data.armorEquipType = ARMOUR_ORDER[equipType] or 0
				if equipType > 0 then
					local link = GetItemLink(bag, index)
									
					if IS_WEAPON[equipType] then
						slot.dataEntry.data.weaponType = WEAPON_ORDER[GetItemWeaponType(link)]
					else
						slot.dataEntry.data.armorType = GetItemArmorType(link)
					end
				end
			end
		end	
	local sortKeys = ZO_Inventory_GetDefaultHeaderSortKeys()
	sortKeys["weaponType"] = {isNumeric = true, tiebreaker = "armorEquipType"}
	sortKeys["armorEquipType"] = {isNumeric = true, tiebreaker = "armorType"}
	sortKeys["armorType"] = {isNumeric = true, tiebreaker = "subjectiveItemLevel"}
	sortKeys["subjectiveItemLevel"] = {isNumeric = true, tiebreaker = "name"}
	sortKeys["age"] = { tiebreaker = "weaponType", isNumeric = true }

	zo_callLater(ItemSort.SetupArrows, 100)
end

function ItemSort:SetupArrows()

	ItemSortBank:SetParent(ZO_PlayerBankSortBy)
	PLAYER_INVENTORY.inventories[INVENTORY_BANK].sortHeaders:AddHeader(ItemSortBank)
	
	ItemSortGuild:SetParent(ZO_GuildBankSortBy)
	PLAYER_INVENTORY.inventories[INVENTORY_GUILD_BANK].sortHeaders:AddHeader(ItemSortGuild)
	

	ZO_PreHook(PLAYER_INVENTORY, "ChangeSort", function(self, key, inventoryType, order) d(inventoryType) PLAYER_INVENTORY.inventories[inventoryType].sortFn = nil end)	
end


EVENT_MANAGER:RegisterForEvent("ItemSortLoaded", EVENT_ADD_ON_LOADED, function(...) ItemSort:Loaded(...) end)