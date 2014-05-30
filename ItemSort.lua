ItemSort = {}

local LibSort = LibStub("LibSort-1.0", 1)

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

	
	LibSort:RegisterDefaultOrder("Item Sort", {"Weapon Type", "Armour Equip Type", "Armour Type", "Subjective Level"})

	LibSort:Register("Item Sort", "Subjective Level", "The calculated subjective level", "subjectiveLevel", function(slotType, bag, index) return GetItemLevel(bag, index) end)
	LibSort:Register("Item Sort", "Weapon Type", "The type of weapon", "weaponType", function(...) return ItemSort:WeaponType(...) end)
	LibSort:Register("Item Sort", "Armour Type", "The weight of armour", "armorType", function(...) return ItemSort:ArmorType(...) end)
	LibSort:Register("Item Sort", "Armour Equip Type", "The type of armour", "armorEquipType", function(...) return ItemSort:ArmourEquipType(...) end)
end

function ItemSort:WeaponType(slotType, bag, index)
	if watchedSlots[slotType] then
		local _, _, _, _, _, equipType = GetItemInfo(bag, index)		
		if equipType > 0 then
			if IS_WEAPON[equipType] then
				return WEAPON_ORDER[GetItemWeaponType(GetItemLink(bag, index))]
			end
		end
	end
end

function ItemSort:ArmorType(slotType, bag, index)
	if watchedSlots[slotType] then
		local _, _, _, _, _, equipType = GetItemInfo(bag, index)
		if equipType <= 9 and equipType > 0  then
			return GetItemArmorType(GetItemLink(bag, index))
		end
	end
end

function ItemSort:ArmourEquipType(slotType, bag, index)
	if watchedSlots[slotType] then
		local _, _, _, _, _, equipType = GetItemInfo(bag, index)
		return ARMOUR_ORDER[equipType] 
	end
end



EVENT_MANAGER:RegisterForEvent("ItemSortLoaded", EVENT_ADD_ON_LOADED, function(...) ItemSort:Loaded(...) end)