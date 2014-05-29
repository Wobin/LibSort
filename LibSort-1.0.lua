local MAJOR, MINOR = "LibSort-1.0", 1
local LibSort, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not LibSort then return end	--the same or newer version of this lib is already loaded into memory 

local defaultType = {["number"] = 0, ["boolean"] = false, ["string"] = ""}

LibSort.RegisteredCallbacks = {}

function LibStub:Loaded(event, name)
    if name ~= "ZO_Ingame" then return end
    
    self.savedVars = ZO_SavedVars:New("ZO_Ingame_SavedVariables", 1, "LibSort")
    self.control:UnregisterForEvent(EVENT_ADD_ON_LOADED)

    -- Hook for BindSlot allows us to inject sort datapoints
	self.hookedBindSlot = ZO_Inventory_BindSlot
	ZO_Inventory_BindSlot = 
		function(...)
			-- First setup the default ZO datapoints
			self.hookedBindSlot(...)
			local control, slotType, index, bag = ...
			local slot = control:GetParent()

			-- If, for whatever reason, we're not actually dealing with sortable stuff...
			if not slot or not slot.dataEntry or not slot.dataEntry.data then return end

			-- Now inject our requirements
			for addon, callbacks in pairs(LibSort.RegisteredCallbacks) do
				for name, data in pairs(callbacks) do
					slot.dataEntry.data[data.key] = data.func(slotType, bag, index) or defaultType[data.dataType]
				end
			end
		end	
end

EVENT_MANAGER:RegisterForEvent("LibSortLoaded", EVENT_ADD_ON_LOADED, function(...) LibSort:Loaded(...) end)

--------- API ---------

function LibSort:Unregister(addonName, name)
	self.RegisteredCallbacks[name] = nil
end

function LibSort:Register(addonName, name, desc, key, func)
	self:RegisterNumeric(addonName, name, key, func)
end

function LibSort:RegisterNumeric(addonName, name, desc, key, func)
	if not self.RegisteredCallbacks[addonName] then self.RegisteredCallbacks[addonName] = {} end
	self.RegisteredCallbacks[addonName][name] = {key = key, func = func, desc = desc, dataType = "number"}
end

function LibSort:RegisterBoolean(addonName, name, desc, key, func)
	if not self.RegisteredCallbacks[addonName] then self.RegisteredCallbacks[addonName] = {} end
	self.RegisteredCallbacks[addonName][name] = {key = key, func = func, desc = desc, dataType = "boolean"}
end

function LibSort:RegisterString(addonName, name, desc, key, func)
	if not self.RegisteredCallbacks[addonName] then self.RegisteredCallbacks[addonName] = {} end
	self.RegisteredCallbacks[addonName][name] = {key = key, func = func, desc = desc, dataType = "string"}
end

function LibSort:RegisterDefaultOrder(addonName, keyTable)
	self.DefaultOrders[addonName] = keyTable
end
