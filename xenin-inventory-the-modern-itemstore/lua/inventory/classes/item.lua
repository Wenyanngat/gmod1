--https://vk.com/gmodleak

local ITEM = {}
ITEM.Actions = {}

function ITEM:AddAction(name, sortOrder, action, pre, post)
  self.Actions[name] = {
    SortOrder = sortOrder,
    Pre = pre or function() return true end,
    Action = action,
    Post = post or function() end
  }
end

function ITEM:Pickup(ply, ent, tbl)
  local dist = ply:GetPos():Distance(ent:GetPos())
  if (dist > 100) then return end
  local inv = ply:Inventory()
  local amt = table.Count(inv:GetInventory())
  local slots = inv:GetSlots()
  if (amt >= slots) then return end

  inv:Add(tbl.ent, tbl.dropEnt, tbl.model, tbl.amount, tbl.data)

  ent:Remove()
end

function ITEM:OnPickup(ply, ent)
  if (!IsValid(ent)) then return end

  local info = {
    ent = self:GetClass(ent),
    dropEnt = ent:GetClass(),
    amount = ent.Getamount and ent:Getamount() or 1,
    data = self:GetData(ent)
  }
  self:Pickup(ply, ent, info)

  return true
end

function ITEM:GetClass(ent)
  return ent:GetClass()
end

function ITEM:GetAmount()
  return self.data and (self.data.amount or self.data.Amount or 0) or 0
end

function ITEM:GetVisualAmount()
  return nil
end

function ITEM:GetData()
  -- Give no data on default
  return self.data or {}
end

function ITEM:GetName(ent)
  if (isentity(ent)) then
    ent = { ent = ent:GetClass() }
  elseif (isstring(ent)) then
    ent = { ent = ent }
  end

  if (!ent.ent) then return "Unknown name" end

  local entName = scripted_ents.Get(ent.ent) and scripted_ents.Get(ent.ent).PrintName
  if (!entName) then 
    entName = weapons.Get(ent.ent) and weapons.Get(ent.ent).PrintName
  end

  if (entName) then return entName end

  return ent or ""
end

function ITEM:GetRarity(ent)
  return self.Rarity or Inventory:GetRarity(ent)
end

function ITEM:Register(name)
  Inventory:AddItem(name, self)
end

function ITEM:GetModel(ent)
  local oldTbl
  if (istable(ent)) then oldTbl = ent; ent = ent.ent end

  if (self.Model) then return self.Model end

  if (oldTbl) then
    if (oldTbl.data) then
      local mdl = oldTbl.data.model or oldTbl.data.Model 

      if (mdl) then return mdl end
    end
  end
  
  if (IsEntity(ent)) then
    ent = ent.GetWeaponClass and ent:GetWeaponClass() or ent:GetClass()
  end
  
  if (isstring(ent)) then
    local class
    if (IsEntity(ent)) then
      class = ent.GetWeaponClass and ent:GetWeaponClass() or ent:GetClass()
    elseif (isstring(ent)) then
      class = ent
    end

    local wep = weapons.Get(class)
    local mdl = wep and (wep.WorldModel or wep.WM or wep.ViewModel)
    if (mdl) then return mdl end
    local sEnt = scripted_ents.Get(class)
    mdl = sEnt and (sEnt.WorldModel or sEnt.WM or sEnt.ViewModel)
    if (mdl) then return mdl end
  end

  return "xd.mdl"
end

function Inventory:CreateItem()
  return table.Copy(ITEM)
end