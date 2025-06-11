--https://vk.com/gmodleak

net.Receive("Inventory.Slot", function(len)
  local ply = LocalPlayer()
  local inv = ply:Inventory()
  local id = net.ReadUInt(10)
  local tbl = net.ReadTable()

  -- If the table is empty, set it to nil so we'll delete the slot
  if (table.Count(tbl) == 0) then
    tbl = nil
  end

  inv:Set(id, tbl)
end)

net.Receive("Inventory.Bank.Slot", function(len)
  local ply = LocalPlayer()
  local inv = ply:Inventory()
  local id = net.ReadUInt(10)
  local tbl = net.ReadTable()

  -- If the table is empty, set it to nil so we'll delete the slot
  if (table.Count(tbl) == 0) then
    tbl = nil
  end

  inv:Set(id, tbl, true)
end)

net.Receive("Inventory.FullSync", function(len)
  local ply = LocalPlayer()
  local inv = ply:Inventory()
  local inventory = net.ReadTable()
  local bank = net.ReadTable()
  local bankRows = net.ReadUInt(8)

  inv:SetInventory(inventory)
  inv:SetBank(bank)
end)

net.Receive("Inventory.Message", function(len)
  local str = net.ReadString()
  local ply = LocalPlayer()
  local inv = ply:Inventory()
  inv:Message(str)
end)

net.Receive("Inventory.Admin.Search", function(len)
  local ply = LocalPlayer()
  local data = net.ReadTable()

  hook.Run("Inventory.Admin.Search", data)
end)