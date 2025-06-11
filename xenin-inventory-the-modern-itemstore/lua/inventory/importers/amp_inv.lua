--https://vk.com/gmodleak

concommand.Add("xenin_inventory_import_amp", function(ply)
	if (IsValid(ply) and !ply:IsSuperAdmin()) then return end

	local conn = Inventory.Database:GetConnection()

	local sql = [[
		SELECT * FROM INV_Items
	]]
	
	conn.query(sql, function(result)
		if (!istable(result)) then return end
		if (#result == 0) then return end

		for i, v in pairs(result) do
			local bank = tobool(v.Banked)
			local isWeapon = v.Class == "spawned_weapon"
			local isShipment = v.Class == "spawned_shipment"
			local sid64 = v.Owner_ID
			local slot = v.ID
			local data = util.JSONToTable(v.Data)
			local isSpecial = isWeapon or isShipment

			Inventory.Database[bank and "SaveBankSlot" or "SaveSlot"](Inventory.Database, sid64, slot, isWeapon and data.WeaponClass or isShipment and (CustomShipments[data.Contents] and CustomShipments[data.Contents].entity) or data.Class or v.Class, v.Class, data.Amount or 1, data or {})
		end
	end)
end)

