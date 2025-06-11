--https://vk.com/gmodleak

concommand.Add("xenin_inventory_import_itemstore", function(ply, cmd, args)
	if (IsValid(ply) and !ply:IsSuperAdmin()) then return end
	local sqlToMySQL = args[1] == "sql"

	local conn = Inventory.Database:GetConnection()

	local function Inventory(result)
		print(#result .. " inventory rows")

		local c = 0
		for i, v in pairs(result) do
			if (!v.Class) then continue end
			-- Why does itemstore store EMPTY slots as a row?
			if (v.Class == "") then continue end
			-- If it's not a registered item then just ignore
			if (!Inventory.Config.Items[v.Class] or !Inventory.Config.WhitelistEntities[v.Class]) then continue end

			c = c + 1

			local class = v.Class
			local sid64 = v.SteamID
			local slot = v.Slot
			local data = v.Data and util.JSONToTable(v.Data) or {}
			local isWeapon = v.Class == "spawned_weapon"
			local isShipment = v.Class == "spawned_shipment"

			Inventory.Database:SaveSlot(
				sid64, 
				slot, 
				isWeapon and data.Class or isShipment and data.Class or v.Class, 
				v.Class, 
				data.Amount or 1, 
				data or {}
			)
		end

		print("Processed " .. c .. " rows in inventory")
	end

	local function Bank(result)
		print(#result .. " bank rows")

		local c = 0
		for i, v in pairs(result) do
			if (!v.Class) then continue end
			-- Why does itemstore store EMPTY slots as a row?
			if (v.Class == "") then continue end
			-- If it's not a registered item then just ignore
			if (!Inventory.Config.Items[v.Class] or !Inventory.Config.WhitelistEntities[v.Class]) then continue end
			
			c = c + 1

			local class = v.Class
			local sid64 = v.SteamID
			local slot = v.Slot
			local data = v.Data and util.JSONToTable(v.Data) or {}
			local isWeapon = v.Class == "spawned_weapon"
			local isShipment = v.Class == "spawned_shipment"
			
			Inventory.Database:SaveBankSlot(
				sid64, 
				slot, 
				isWeapon and data.Class or isShipment and data.Class or v.Class, 
				v.Class, 
				data.Amount or 1, 
				data or {}
			)
		end
		print("Processed " .. c .. " rows in bank")
	end

	if (sqlToMySQL) then
		local inv = sql.Query("SELECT * FROM Inventories")
		if (inv == false) then
			print("Failed to load inventory. Error: " .. sql.LastError())
		end

		local bank = sql.Query("SELECT * FROM Inventories")
		if (bank == false) then
			print("Failed to load bank. Error: " .. sql.LastError())
		end
		if (!bank or !inv) then print("SQL importing. Failed to load bank or inventory!") return end

		Inventory(inv)
		Bank(bank)
	else
		conn.query("SELECT * FROM Inventories", function(result)
			Inventory(result)
		end, function(err)
			print("Failed to load inventory. Error: " .. err)
		end)
		
		conn.query("SELECT * FROM Banks", function(result)
			Bank(result)
		end, function(err)
			print("Failed to load bank. Error: " .. err)
		end)
	end
end)
