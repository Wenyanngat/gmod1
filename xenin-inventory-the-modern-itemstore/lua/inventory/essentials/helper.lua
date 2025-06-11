--https://vk.com/gmodleak

function Inventory:GetItems()
  return self.Config.Items
end

function Inventory:GetItem(index)
  return self.Config.Items[index] or (self.Config.WhitelistEntities[index] and self.Config.Items["base_entity"])
end

function Inventory:GetRarity(ent)
  if (isstring(ent) or istable(ent) or isentity(ent) and !ent.GetRarity) then
    local entClass = istable(ent) and ent.ent or ent
    if (isentity(entClass)) then
      local item = Inventory:GetItem(entClass:GetClass())

      if (item and item.Rarity) then
        return item.Rarity
      end

      entClass = entClass.GetWeaponClass and entClass:GetWeaponClass() or entClass:GetClass()
    end
    
    if (istable(ent) and ent.data and ent.data.rarity) then
      local item = Inventory:GetItem(ent.dropEnt)
      if (item and item.Rarity) then
        return item.Rarity
      end

      return ent.data.rarity
    end

    if (!isstring(ent) and ent.dropEnt) then
      local item = Inventory:GetItem(ent.dropEnt)
      if (item and item.Rarity) then
        return item.Rarity
      end
    end

    if (isstring(ent)) then
      local item = Inventory:GetItem(ent)
      if (item and item.Rarity) then
        return item.Rarity
      end
    end

    return self.Config.Rarities[entClass] or 1
  end

  if (isentity(ent) and IsValid(ent) and ent.GetRarity) then
    return ent:GetRarity()
  end

  return 1
end

function Inventory:AddItem(index, tbl)
  self.Config.Items[index] = tbl
end

function Inventory:IsAdmin(ply)
  return Inventory.Config.Admins[ply:GetUserGroup()]
end