--https://vk.com/gmodleak

local ITEM = Inventory:CreateItem()
ITEM.Hover = "Inventory.Weapon.Hover"

ITEM:AddAction("Equip", 1, function(self, ply, ent, tbl)
  if (CLIENT) then return true end

  ply:Give(ent)
  ply:SelectWeapon(ent)

  return true
end, function(self, ply, slot)
  local ent = slot.ent
  local data = slot.data
  local name = self:GetName(slot)

  return !ply:HasWeapon(ent), "You already have a(n) " .. name .. " equipped"
end)

ITEM:AddAction("Drop", 2, function(self, ply, ent, tbl)
  local trace = {}
  trace.start = ply:EyePos()
  trace.endpos = trace.start + ply:GetAimVector() * 85
  trace.filter = ply

  local tr = util.TraceLine(trace)
  local baseweapon = ents.Create("bw_weapon")
  local weapon = weapons.Get( ent )
  baseweapon.WeaponClass = tbl.ent
  baseweapon:SetPos(tr.HitPos)
  baseweapon.ammoadd = weapons.Get(ent) and weapons.Get(ent).Primary.DefaultClip

  baseweapon:Spawn()
  baseweapon:SetModel( weapon.WorldModel )
end)

function ITEM:GetDisplayName(ent)
  if (!IsValid(ent)) then return "" end

  return ent.WeaponClass
end

function ITEM:GetName(ent)
  local tbl = weapons.Get(ent.ent)
  if (!tbl) then return ent.PrintName end

  return tbl.PrintName or ent.WeaponClass
end

function ITEM:OnPickup(ply, ent)
  if (!IsValid(ent)) then return end

  local info = {
    ent = ent.WeaponClass,
    dropEnt = ent:GetClass(),
    amount = 1,
    data = self:GetData(ent)
  }
  self:Pickup(ply, ent, info)

  return true
end

ITEM:Register("bw_weapon")