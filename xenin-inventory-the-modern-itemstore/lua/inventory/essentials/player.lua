--https://vk.com/gmodleak

local function GetInventoryStructure(tbl)
  return {
    id = tonumber(tbl.slot),
    ent = tbl.ent,
    dropEnt = tbl.drop_ent,
    amount = tonumber(tbl.amount),
    data = util.JSONToTable(tbl.data)
  }
end

Inventory.GetInventoryStructure = GetInventoryStructure

hook.Add("PlayerInitialSpawn", "Inventory", function(ply)
  local inv = ply:Inventory()
  local sid64 = ply:SteamID64()

  Inventory.Database:GetInventory(sid64, function(inventory)
    Inventory.Database:GetBank(sid64, function(bank)
      if (IsValid(ply)) then
        inventory = inventory or {}    
        bank = bank or {}

        local invTemp = {}
        for i, v in pairs(inventory) do
          invTemp[tonumber(v.slot)] = GetInventoryStructure(v)
        end
        local bankTemp = {}
        for i, v in pairs(bank) do
          bankTemp[tonumber(v.slot)] = GetInventoryStructure(v)
        end
        inv:SetInventory(invTemp)
        inv:SetBank(bankTemp)

        timer.Simple(3, function()
          if (IsValid(ply)) then
            inv:NetworkAll()
          end
        end)
      end
    end)
  end)
end)

hook.Add("PlayerSay", "Inventory.Commands", function(ply, text)
  text = text:lower()
  local tbl = Inventory.Config.ChatCommands[text]
  local time = ply._nextChatCommand or 0

  if (tbl and time < CurTime()) then
    ply._nextChatCommand = CurTime() + 0.1
    tbl(ply, text)

    return ""
  end
end)

hook.Add("PlayerLoadout", "Inventory.SWEP", function(ply)
  local arrested = ply.isArrested and ply:isArrested()

  if (IsValid(ply) and not arrested and Inventory.Config.SpawnWithInventorySWEP) then
    ply:Give("inventory")
  end
end)

hook.Add("PlayerButtonDown", "Inventory", function(ply, keyCode)
  if (keyCode == KEY_LALT) then
    ply.lAltDown = true
  end

  if (keyCode == Inventory.Config.AltKey and ply.lAltDown and Inventory.Config.PickUpWithALT) then
    local tr = util.TraceLine({
      start = ply:EyePos(),
      endpos = ply:EyePos() + ply:EyeAngles():Forward() * 250,
      filter = ply
    })
    
    local ent = tr.Entity
    if (IsValid(ent)) then
      local tbl = Inventory.Config.Items[ent:GetClass()] or (Inventory.Config.WhitelistEntities[ent:GetClass()] and Inventory.Config.Items["base_entity"])
      if (tbl) then
        if (IsValid(ent) and !ent.ignoreInv) then
          tbl:OnPickup(ply, ent)
        end
      end
    end
  end
end)

hook.Add("PlayerButtonUp", "Inventory", function(ply, keyCode)
  if (keyCode == KEY_LALT) then
    ply.lAltDown = nil
  end

  if (keyCode == Inventory.Config.InventoryKey and Inventory.Config.InventoryKey) then
    ply:ConCommand("inventory")
  end
end)

/*
hook.Add("KeyPress", "Inventory", function(ply, keyCode)
  if (keyCode == Inventory.Config.AltKey and ply.lAltDown and Inventory.Config.PickUpWithALT) then
    local tr = util.TraceLine({
      start = ply:EyePos(),
      endpos = ply:EyePos() + ply:EyeAngles():Forward() * 250,
      filter = ply
    })
    
    local ent = tr.Entity
    if (IsValid(ent)) then
      local tbl = Inventory.Config.Items[ent:GetClass()]
      if (tbl) then
        if (IsValid(ent) and !ent.ignoreInv) then
          tbl:OnPickup(ply, ent)
        end
      end
    end
  end
end)
*/

hook.Add("Initialize", "Inventory.Override", function()
  timer.Simple(10, function()
    local PLY = FindMetaTable("Player")
    
    function PLY:dropDRPWeapon(weapon, callback, ignoreTime)
      callback = callback or function() end

      if (!IsValid(weapon) or weapon:GetModel() == "") then
        DarkRP.notify(self, 1, 4, DarkRP.getPhrase("cannot_drop_weapon"))

        return
      end

      local canDrop = hook.Run("canDropWeapon", self, weapon)
      if (!canDrop) then
        DarkRP.notify(self, 1, 4, DarkRP.getPhrase("cannot_drop_weapon"))

        return
      end

      if (!ignoreTime) then
        local RP = RecipientFilter()
        RP:AddAllPlayers()

        umsg.Start("anim_dropitem", RP)
            umsg.Entity(self)
        umsg.End()
      end

      timer.Simple(!ignoreTime and 1 or 0, function()
        if (!IsValid(self) or !IsValid(weapon)) then return end

        local ammo = self:GetAmmoCount(weapon:GetPrimaryAmmoType())
        self:DropWeapon(weapon) -- Drop it so the model isn't the viewmodel

        local ent = ents.Create("spawned_weapon")
        local model = (weapon:GetModel() == "models/weapons/v_physcannon.mdl" and "models/weapons/w_physics.mdl") or weapon:GetModel()
        model = util.IsValidModel(model) and model or "models/weapons/w_rif_ak47.mdl"

        ent:SetPos(self:GetShootPos() + self:GetAimVector() * 30)
        ent:SetModel(model)
        ent:SetSkin(weapon:GetSkin() or 0)
        ent:SetWeaponClass(weapon:GetClass())
        ent.nodupe = true
        ent.clip1 = weapon:Clip1()
        ent.clip2 = weapon:Clip2()
        ent.ammoadd = ammo

        hook.Call("onDarkRPWeaponDropped", nil, self, ent, weapon)

        self:RemoveAmmo(ammo, weapon:GetPrimaryAmmoType())

        ent:Spawn()

        weapon:Remove()

        callback(ent)
      end)
    end
  end)
end)
