--https://vk.com/gmodleak

local INV = {}
INV.inventory = {}
INV.bank = {}

AccessorFunc(INV, "m_player", "Player")

function INV.New(ply, inv, bank)
  local self = table.Copy(INV)

  self:SetPlayer(ply)
  self:SetInventory(inv)
  self:SetBank(bank)

  return self
end

function INV:SetInventory(tbl)
  self.inventory = tbl or {}
end

function INV:GetBankSlots()
  return Inventory.Config.BankSlots.Paid[self:GetPlayer():GetUserGroup()] or Inventory.Config.BankSlots.Free
end

function INV:GetInventory()
  return self.inventory
end

function INV:GetBank()
  return self.bank
end

function INV:Message(str)
  if (SERVER) then
    net.Start("Inventory.Message")
      net.WriteString(str)
    net.Send(self:GetPlayer())
  else
    chat.AddText(Inventory.Config.PrefixCol, Inventory.Config.PrefixText .. " ", color_white, str)
  end
end

function INV:SetBank(tbl)
  self.bank = tbl or {}
end
  
function INV:Get(id, bank)
  local str = bank and "bank" or "inventory"
  return self[str][id]
end

function INV:Set(id, contents, bank)
  local str = bank and "bank" or "inventory"
  self[str][id] = contents
end

function INV:SetSlots(slots)
  if (!slots) then
    local donator = self:GetPlayer():GetUserGroup()

    slots = donator and Inventory.Config.Slots.Paid[donator] or Inventory.Config.Slots.Free
  end

  self.slots = slots
end

function INV:GetSlots()
  local donator = self:GetPlayer():GetUserGroup()

  return donator and Inventory.Config.Slots.Paid[donator] or Inventory.Config.Slots.Free
end

function INV:AddItem(index, ent, dropEnt, model, amount, data, bank)
  local tbl = self[bank and "bank" or "inventory"]
  local amt = tbl and tbl.amount or 0

  tbl[index] = {
    id = index,
    ent = ent,
    dropEnt = dropEnt,
    model = model,
    amount = amt + amount,
    data = data
  }
end

function INV:Add(ent, dropEnt, model, amount, data, ignoreDatabase)
  data = data or {}
  local rarity = Inventory:GetRarity(dropEnt)
  local cat = Inventory.Config.Categories[rarity]
  if (!cat) then return end
  local item = Inventory:GetItem(dropEnt)
  local maxStack = Inventory.Config.WhitelistEntities[dropEnt] and 1 or item.MaxStack or cat.maxStack
  local count = table.Count(self:GetInventory())
  local slots = self:GetSlots()
  local slotsRequired = math.ceil(amount / maxStack)
  if ((count + slotsRequired) > slots) then return end
  local newSlot
  local newAmount
  -- Lets start by indexing while we go through
  local tbl = {}
  local earliestEmpty
  for i = 1, slots do
    local slot = self:Get(i)

    if (slot) then
      tbl[i] = slot
    elseif (!slot and !earliestEmpty) then
      earliestEmpty = i
    end
  end

  -- We count down this variable. If it's over 0 when we're done we'll later need to insert into a new slot
  local amountTemp = amount 
  -- Now we scan if the item already exists (by ent, not dropEnt)
  for i, slot in pairs(tbl) do
    if (slot.ent != ent) then continue end
    if (slot.dropEnt != dropEnt) then continue end
    if (slot.amount >= maxStack) then continue end
    if (amountTemp <= 0) then break end
    local amt = math.Clamp(amount + (slot.amount or 0), 0, maxStack)
    if (amt <= 0) then continue end

    self:AddItem(i, ent, dropEnt, model, amt, data)
    amountTemp = amountTemp - amt

    if (SERVER) then
      if (!ignoreDatabase) then
        self:SaveSlot(i)
      end

      self:NetworkSlot(i)
    end

    tbl[i] = nil
  end

  -- If there's any remaining we'll store em in a new slot
  if (amountTemp > 0) then
    -- If there's more than one stack worth we'll do it recursively, else just add it to this slot
    if (amountTemp > maxStack) then
      self:AddItem(earliestEmpty, ent, dropEnt, model, maxStack, data)
      if (!self:Add(ent, dropEnt, model, amountTemp - maxStack, data, ignoreDatabase)) then return end
    else
      self:AddItem(earliestEmpty, ent, dropEnt,model, amountTemp, data)
    end

    if (SERVER) then
      if (!ignoreDatabase) then
        self:SaveSlot(earliestEmpty)
      end

      self:NetworkSlot(earliestEmpty)
    end
  end

  return true
end

function INV:CanUseBank()
  local ply = self:GetPlayer()
  local npcs = ents.FindByClass("bank_npc")

  for i, v in pairs(npcs) do
    local dist = ply:GetPos():Distance(v:GetPos())

    if (dist > 200) then continue end

    return true
  end
end

function INV:SwapBank(inv, bank)
  if (!self:CanUseBank()) then return end
  local invTbl = self:Get(inv)
  local bankTbl = self:Get(bank, true)

  if (invTbl) then invTbl.id = bank end
  if (bankTbl) then bankTbl.id = inv end

  self:Set(bank, invTbl, true)
  self:Set(inv, bankTbl)

  if (CLIENT) then
    net.Start("Inventory.Swap.InventoryToBank")
      net.WriteUInt(inv, 10)
      net.WriteUInt(bank, 10)
    net.SendToServer()
  end

  if (SERVER) then
    if (invTbl) then
      self:SaveSlot(bank, true)
    else
      self:DeleteSlot(bank, true)
    end
    if (bankTbl) then
      self:SaveSlot(inv)
    else
      self:DeleteSlot(inv)
    end
  end
end

function INV:Swap(from, to, bank)
  local maxSlots = bank and self:GetBankSlots() or self:GetSlots()
  if (from <= 0 or to <= 0 or to > maxSlots or from > maxSlots) then return end
  
  if (bank and !self:CanUseBank()) then return end
  local toTbl = self:Get(to, bank)
  local fromTbl = self:Get(from, bank)
  
  if (fromTbl) then fromTbl.id = to end
  if (toTbl) then toTbl.id = from end

  self:Set(to, fromTbl, bank)
  self:Set(from, toTbl, bank)

  if (CLIENT) then
    if (bank) then
      net.Start("Inventory.Swap.Bank")
        net.WriteUInt(to, 10)
        net.WriteUInt(from, 10)
      net.SendToServer()
    else
      net.Start("Inventory.Swap")
        net.WriteUInt(to, 10)
        net.WriteUInt(from, 10)
      net.SendToServer()
    end
  end

  if (SERVER) then
    if (fromTbl) then
      self:SaveSlot(to, bank)
    else
      self:DeleteSlot(to, bank)
    end
    if (toTbl) then
      self:SaveSlot(from, bank)
    else
      self:DeleteSlot(from, bank)
    end
  end
end

function INV:ReduceAmount(id, amt, ignoreNetwork)
  local slot = self:Get(id)
  if (!slot) then return end
  local amount = slot.amount
  local newAmount = amount - amt
  if (newAmount < 0) then return end
  if (newAmount == 0) then
    self:Set(id, nil)
    self:DeleteSlot(id)
    if (!ignoreNetwork) then
      self:NetworkSlot(id)
    end
  else
    slot.amount = newAmount
    self:Set(id, slot)
    self:SaveSlot(id)

    if (!ignoreNetwork) then
      self:NetworkSlot(id)
    end
  end

  return true
end

function INV:SaveSlot(id, bank)
  if (CLIENT) then return end

  local ply = self:GetPlayer()
  if (!ply) then return end
  local tbl = self:Get(id, bank)
  if (!tbl) then return end

  local sid64 = ply:SteamID64()
  local slot = id
  local ent = tbl.ent
  local dropEnt = tbl.dropEnt
  local amount = tbl.amount or 1
  local data = tbl.data or {}

  if (bank) then
    Inventory.Database:SaveBankSlot(sid64, slot, ent, dropEnt, amount, data)
  else
    Inventory.Database:SaveSlot(sid64, slot, ent, dropEnt, amount, data)
  end
end

function INV:DeleteSlot(id, bank)
  if (CLIENT) then return end

  local ply = self:GetPlayer()
  if (!ply) then return end

  if (bank) then
    Inventory.Database:DeleteBankSlot(ply:SteamID64(), id)
  else
    Inventory.Database:DeleteSlot(ply:SteamID64(), id)
  end
end

function INV:NetworkSlot(id, bank)
  if (CLIENT) then return end

  if (bank) then
    net.Start("Inventory.Bank.Slot")
      net.WriteUInt(id, 10)
      net.WriteTable(self:Get(id, true) or {})
    net.Send(self:GetPlayer())
  else
    net.Start("Inventory.Slot")
      net.WriteUInt(id, 10)
      net.WriteTable(self:Get(id) or {})
    net.Send(self:GetPlayer())
  end
end

function INV:Pickup(ent)
  if (!ent or !IsValid(ent)) then return end
  local item = Inventory:GetItem(ent:GetClass())
  if (!item) then return end
  if (CLIENT) then return end

  item:OnPickup(self:GetPlayer(), ent)
end

function INV:NetworkAll()
  if (CLIENT) then return end

  net.Start("Inventory.FullSync")
    net.WriteTable(self:GetInventory())
    net.WriteTable(self:GetBank())
  net.Send(self:GetPlayer())
end

local ply = FindMetaTable("Player")
--Entity(1).inventory = nil
function ply:Inventory()
  if (!self.inventory) then
    self.inventory = INV.New(self)
  end

  return self.inventory
end