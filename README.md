#LibSort 1.0


Currently, the way ESO sorts items is essentially by column, you have a data point for each item, eg, **name** and you sort the list of objects by that data point.

One thing that this default sorting mechanism offers, however, is a tiebreaker option. If we're sorting by **name** and a tiebreaker is required, because we are comparing two items with the same name, it falls to the tiebreaker datapoint to determine order of result, eg **stackSize**

Now the general sorting of items in the real world doesn't just fall to a single data point, or two. It generally requires a series of different datapoints to sort by, and we can take advantage of this 'tiebreaker' to 
chain together lists of different datapoints to sort by. So we can sort by **Name**, then by **StackSize**, then by **SlotId**. 

That's well and fine for what's existing in the current set of datapoints, however we have access to a lot more information about the item than is currently being stored.

To do this, however, we need to inject the required datapoints into the list object so that it has the required information to process the sort order as ascertained by our adjustment of how the tiebreakers chain together.

	ZO_Inventory_BindSlot(control, slotType, index, bag) 

is the function we need to hook. It's a C side function, which means we don't actually know what it does exactly, but we don't need to. We might be able to prehook it, but chances are it recreates the data object so any
prehooking work would be wiped out. So we posthook it.

We now have information about the item, where it's from (*slotType*) and where it is (*bag* and *index*)

And thanks to the new API, we have two new functions that will return information about the item in regards to what sort of weapon or armour it is.

So as an example, we'll use the new Weapon info function to inject data to allow the game to sort by weapontype

	GetItemWeaponType(link)

is the function we're using to obtain the information required. 

Or at least through

	local link = GetItemLink(bag, index)
	local weaponType = GetItemWeaponType(link)

If we then inject this information into the data object
	
	control:GetParent().dataEntry.data.weaponType = weaponType

we can then include another entry into the sortKeys for default header

	local sortKeys = ZO_Inventory_GetDefaultHeaderSortKeys()
	sortKeys["weaponType"] = {isNumeric = true, tiebreaker = "name"}

and we will end up sorting by the type of weapon returned by that function. (Note that as it's a pure number, and not necessarily in the order you may want, you'll have to actually adjust the real value of the datapoint to something more suitable)

---

In any case, now that we know what we need to do, this library should do most of the heavy lifting for you. Chances are I'll have to give it it's own Settings panel so people can reorder the sort order as they wish, but you should be able to register your addon to allow data injection and process the index/bag combinations to store whatever datapoints you want.