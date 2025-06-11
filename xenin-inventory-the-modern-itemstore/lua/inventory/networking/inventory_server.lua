--https://vk.com/gmodleak

util.AddNetworkString("Inventory.Swap")
util.AddNetworkString("Inventory.Slot")
util.AddNetworkString("Inventory.FullSync")
util.AddNetworkString("Inventory.Message")
-- Popup actions
util.AddNetworkString("Inventory.Equip")
util.AddNetworkString("Inventory.Drop")
util.AddNetworkString("Inventory.DropAll")
util.AddNetworkString("Inventory.Destroy")
util.AddNetworkString("Inventory.Use")
util.AddNetworkString("Inventory.UseTwice")
util.AddNetworkString("Inventory.RepairEquipped")
util.AddNetworkString("Inventory.DropAmount")
util.AddNetworkString("Inventory.DropAmount.Data")

-- Bank related
util.AddNetworkString("Inventory.Swap.InventoryToBank")
util.AddNetworkString("Inventory.Swap.Bank")
util.AddNetworkString("Inventory.Bank.Slot")

-- Admin
util.AddNetworkString("Inventory.Admin.RemoveItem")
util.AddNetworkString("Inventory.Admin.Clear")
util.AddNetworkString("Inventory.Admin.Search")

net.Receive("Inventory.Admin.RemoveItem", function(len, ply)
  local isAdmin = Inventory:IsAdmin(ply)
  if (!isAdmin) then return end
  local sid64 = net.ReadString()
  local id = net.ReadUInt(16)
  local bank = net.ReadBool()
  local target = player.GetBySteamID64(sid64)

  if (IsValid(target)) then
    local inv = target:Inventory()
    inv:Set(id, nil, bank)
    inv:DeleteSlot(id, bank)
    inv:NetworkSlot(id, bank)
    inv:Message(Inventory:GetPhrase("Admin.Clear.Slot", { id = id, type = bank and "bank" or "inventory" }))
  else
    Inventory.Database["Delete" .. (bank and "Bank" or "") .. "Slot"](
      Inventory.Database,
      sid64,
      id
    )
  end
end)

net.Receive("Inventory.Admin.Clear", function(len, ply)
  local isAdmin = Inventory:IsAdmin(ply)
  if (!isAdmin) then return end
  local sid64 = net.ReadString()
  local bank = net.ReadBool()
  local target = player.GetBySteamID64(sid64)

  if (IsValid(target)) then
    local inv = target:Inventory()
    local tbl = bank and inv:GetBank() or inv:GetInventory()
    for i, v in pairs(tbl) do
      inv:Set(v.id, nil, bank)
      inv:DeleteSlot(v.id, bank)
      inv:NetworkSlot(v.id, bank)
    end

    inv:Message(Inventory:GetPhrase("Admin.Clear", { type = bank and "bank" or "inventory"}))
  else
    Inventory.Database:Clear(sid64, bank)
  end
end)

net.Receive("Inventory.Admin.Search", function(len, ply)
  local isAdmin = Inventory:IsAdmin(ply)
  if (!isAdmin) then return end
  local isOnline = net.ReadBool()
  local data = net.ReadTable()

  if (isOnline) then
    local tbl = {}

    for i, v in pairs(data) do
      if (!IsValid(v)) then continue end

      local inv = v:Inventory()
      tbl[v:SteamID64()] = {
        inv = inv:GetInventory(),
        bank = inv:GetBank()
      }
    end

    net.Start("Inventory.Admin.Search")
      net.WriteTable(tbl)
    net.Send(ply)
  else
    local sid64 = data[1]
    sid64 = sid64:Trim()
    if (sid64:find("STEAM_0")) then
      local convert = util.SteamIDTo64(sid64)

      if (convert and convert != "") then
        sid64 = convert
      end
    end

    Inventory.Database:GetInventory(sid64, function(inventory)
      Inventory.Database:GetBank(sid64, function(bank)
        inventory = inventory or {}    
        bank = bank or {}

        local invTemp = {}
        for i, v in pairs(inventory) do
          invTemp[tonumber(v.slot)] = Inventory.GetInventoryStructure(v)
        end
        local bankTemp = {}
        for i, v in pairs(bank) do
          bankTemp[tonumber(v.slot)] = Inventory.GetInventoryStructure(v)
        end

        local tbl = {}

        if (table.Count(invTemp) > 0 or table.Count(bankTemp) > 0) then
          tbl[sid64] = {
            inv = invTemp,
            bank = bankTemp
          }
        end

        net.Start("Inventory.Admin.Search")
          net.WriteTable(tbl)
        net.Send(ply)
      end)
    end)
  end
end)

net.Receive("Inventory.Swap.InventoryToBank", function(len, ply)
  local inv = net.ReadUInt(10)
  local bank = net.ReadUInt(10)
  local invClass = ply:Inventory()
  if (!inv or !bank) then return end

  invClass:SwapBank(inv, bank)
end)

net.Receive("Inventory.Swap.Bank", function(len, ply)
  local from = net.ReadUInt(10)
  local to = net.ReadUInt(10)
  local inv = ply:Inventory()
  if (!from or !to) then return end
  
  inv:Swap(from, to, true)
end)

net.Receive("Inventory.Swap", function(len, ply)
  local from = net.ReadUInt(10)
  local to = net.ReadUInt(10)
  local inv = ply:Inventory()
  if (!from or !to) then return end
  
  inv:Swap(from, to)
end)

net.Receive("Inventory.Equip", function(len, ply)
  local id = net.ReadUInt(10)
  local inv = ply:Inventory()
  local slot = inv:Get(id)
  if (!slot) then return end
  local item = Inventory:GetItem(slot.dropEnt)
  if (!item) then return end
  if (!item.Actions.Equip) then return end
  local canEquip = item.Actions.Equip.Pre(item, ply, slot)
  if (!canEquip) then return end

  if (inv:ReduceAmount(id, 1, true)) then
    item.Actions.Equip.Action(item, ply, slot.ent, slot)
  end
end)

net.Receive("Inventory.Use", function(len, ply)
  local id = net.ReadUInt(10)
  local inv = ply:Inventory()
  local slot = inv:Get(id)
  if (!slot) then return end
  local item = Inventory:GetItem(slot.dropEnt)
  if (!item) then return end
  if (!item.Actions.Use) then return end
  local canEquip = item.Actions.Use.Pre(item, ply, slot)
  if (!canEquip) then return end
  
  if (inv:ReduceAmount(id, 1, true)) then
    item.Actions.Use.Action(item, ply, slot.ent, slot)
  end
end)

net.Receive("Inventory.Drop", function(len, ply)
  local id = net.ReadUInt(10)
  local inv = ply:Inventory()
  local slot = inv:Get(id)
  if (!slot) then return end
  local item = Inventory:GetItem(slot.dropEnt)
  if (!item) then return end
  if (!item.Actions.Drop) then return end

  if (inv:ReduceAmount(id, 1, true)) then
    item.Actions.Drop.Action(item, ply, slot.ent, slot)
  end
end)

net.Receive("Inventory.DropAll", function(len, ply)
  local id = net.ReadUInt(10)
  local inv = ply:Inventory()
  local slot = inv:Get(id)
  if (!slot) then return end
  local item = Inventory:GetItem(slot.dropEnt)
  if (!item) then return end
  if (!item.Actions["Drop All"]) then return end

  if (inv:ReduceAmount(id, slot.amount, true)) then
    item.Actions["Drop All"].Action(item, ply, slot.ent, slot)
  end
end)

net.Receive("Inventory.DropAmount", function(len, ply)
  local id = net.ReadUInt(10)
  local amt = net.ReadUInt(32)
  local inv = ply:Inventory()
  local slot = inv:Get(id)
  if (!slot) then return end
  local item = Inventory:GetItem(slot.dropEnt)
  if (!item) then return end
  if (!item.Actions["Drop Amount"]) then return end

  if (inv:ReduceAmount(id, amt, true)) then
    item.Actions["Drop Amount"].Action(item, ply, slot.ent, slot, amt)
  end
end)

net.Receive("Inventory.DropAmount.Data", function(len, ply)
  local id = net.ReadUInt(10)
  local amt = net.ReadUInt(32)
  local inv = ply:Inventory()
  local slot = inv:Get(id)
  if (!slot) then return end
  local item = Inventory:GetItem(slot.dropEnt)
  if (!item) then return end
  if (!item.Actions["Drop Amount"]) then return end

  local amount = slot.data.amount or slot.data.Amount or slot.amount
  if (amount > slot.amount) then
    local newAmount = (slot.data.amount or slot.data.Amount) - amt
    if (newAmount < 0) then return end

    slot.data.amount = slot.data.amount and newAmount
    slot.data.Amount = slot.data.Amount and newAmount

    item.Actions["Drop Amount"].Action(item, ply, slot.ent, slot, amt)

    if (newAmount == 0) then
      inv:Set(id, nil)
      inv:DeleteSlot(id)
    end
  end
end)

net.Receive("Inventory.Destroy", function(len, ply)
  local id = net.ReadUInt(10)
  local inv = ply:Inventory()
  local slot = inv:Get(id)
  if (!slot) then return end

  inv:Set(id, nil)
  inv:DeleteSlot(id)
end)