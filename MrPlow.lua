MrPlow = {}

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
local ITEM_TYPE_ORDER = {
	[ITEMTYPE_WEAPON] = 					1,
	[ITEMTYPE_ARMOR] = 						2,
	[ITEMTYPE_FOOD] = 						3,
	[ITEMTYPE_DRINK] = 						4, 
	[ITEMTYPE_RECIPE] =  					5,	
	[ITEMTYPE_POTION] =  					6,
	[ITEMTYPE_POISON] =   					7,
	[ITEMTYPE_SCROLL] = 		  			8,
	[ITEMTYPE_CONTAINER] = 		  			9,
	[ITEMTYPE_AVA_REPAIR] =   				10,	
	[ITEMTYPE_BLACKSMITHING_BOOSTER] = 		11,
	[ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = 12, 
	[ITEMTYPE_BLACKSMITHING_MATERIAL] = 	13, 
	[ITEMTYPE_CLOTHIER_BOOSTER] = 			14,
	[ITEMTYPE_CLOTHIER_RAW_MATERIAL] = 		15, 
	[ITEMTYPE_CLOTHIER_MATERIAL] = 			16, 
	[ITEMTYPE_WOODWORKING_BOOSTER] = 		17,
	[ITEMTYPE_WOODWORKING_RAW_MATERIAL] = 	18, 
	[ITEMTYPE_WOODWORKING_MATERIAL] = 		19, 
	[ITEMTYPE_ALCHEMY_BASE] = 				20,
	[ITEMTYPE_REAGENT] = 					21, 
	[ITEMTYPE_ENCHANTING_RUNE] =   			22,
	[ITEMTYPE_INGREDIENT] =   				23,
	[ITEMTYPE_STYLE_MATERIAL] =   			24,
	[ITEMTYPE_GLYPH_WEAPON] =   			25,
	[ITEMTYPE_GLYPH_ARMOR] =   				26,
	[ITEMTYPE_GLYPH_JEWELRY] =   			27,
	[ITEMTYPE_SOUL_GEM] =   				28,
	[ITEMTYPE_SIEGE] =   					29,
	[ITEMTYPE_LURE] = 		  				30,
	[ITEMTYPE_TRASH] = 	  					31,
	[ITEMTYPE_TROPHY] =   					32,
	[ITEMTYPE_LOCKPICK] =					33,
	[ITEMTYPE_ARMOR_TRAIT] =   				34,
	[ITEMTYPE_WEAPON_TRAIT] =   			35,
}

function MrPlow:Loaded(...)
	local eventCode, addonName = ...
	if addonName ~= "MrPlow" then return end

	LibSort:Register("Item Sort", "Item Type", "The type of item", "itemType", function(...) return MrPlow:ItemType(...) end)
	LibSort:Register("Item Sort", "Weapon Type", "The type of weapon", "weaponType", function(...) return MrPlow:WeaponType(...) end)
	LibSort:Register("Item Sort", "Armour Equip Type", "The type of armour", "armorEquipType", function(...) return MrPlow:ArmourEquipType(...) end)
	LibSort:Register("Item Sort", "Armour Type", "The weight of armour", "armorType", function(...) return MrPlow:ArmorType(...) end)
	
	LibSort:Register("Item Sort", "Subjective Level", "The calculated subjective level", "subjectiveLevel", function(slotType, bag, index) return GetItemLevel(bag, index) end)

	LibSort:RegisterDefaultOrder("Item Sort", {"Item Type", "Weapon Type", "Armour Equip Type", "Armour Type"}, {"Subjective Level"})
end

function MrPlow:ItemType(slotType, bag, index)
	if watchedSlots[slotType] then
		return ITEM_TYPE_ORDER[GetItemType(bag, index)] or 100
	end
end

function MrPlow:WeaponType(slotType, bag, index)
	if watchedSlots[slotType] then
		local _, _, _, _, _, equipType = GetItemInfo(bag, index)		
		if equipType > 0 then
			if IS_WEAPON[equipType] then
				return WEAPON_ORDER[GetItemWeaponType(GetItemLink(bag, index))]
			end
		end
	end
end

function MrPlow:ArmorType(slotType, bag, index)
	if watchedSlots[slotType] then
		local _, _, _, _, _, equipType = GetItemInfo(bag, index)
		if equipType <= 9 and equipType > 0  then
			return GetItemArmorType(GetItemLink(bag, index))
		end
	end
end

function MrPlow:ArmourEquipType(slotType, bag, index)
	if watchedSlots[slotType] then
		local _, _, _, _, _, equipType = GetItemInfo(bag, index)
		return ARMOUR_ORDER[equipType] 
	end
end



EVENT_MANAGER:RegisterForEvent("MrPlowLoaded", EVENT_ADD_ON_LOADED, function(...) MrPlow:Loaded(...) end)
	