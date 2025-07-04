--https://vk.com/gmodleak

local ITEM = Inventory:CreateItem()
ITEM.Hover = "Inventory.Weapon.Hover"
ITEM.Models = {
  ["armor_tier5"] = "models/Items/item_item_crate.mdl"
}

ITEM:AddAction("Drop", 2, function(self, ply, ent, tbl)
  local trace = {}
  trace.start = ply:EyePos()
  trace.endpos = trace.start + ply:GetAimVector() * 85
  trace.filter = ply

  local tr = util.TraceLine(trace)
  local weapon = ents.Create(tbl.ent)
  local model = self:GetModel(tbl.ent)
  weapon:SetPos(tr.HitPos)
  weapon.ammoadd = weapons.Get(ent) and weapons.Get(ent).Primary.DefaultClip
  
  weapon:Spawn()
end)

function ITEM:GetDisplayName(ent)
  if (!IsValid(ent)) then return "" end

  return self:GetName(ent)
end

function ITEM:GetItem(ent)
  return ent
end

function ITEM:GetData(ent)
  return {}
end

function ITEM:GetModel(ent)
  local entClass = istable(ent) and ent.ent or isentity(ent) and ent:GetClass() or ent

  return self.Models[entClass] or "models/Items/item_item_crate.mdl"
end

function ITEM:OnPickup(ply, ent)
  if (!IsValid(ent)) then return end

  local info = {
    ent = ent:GetClass(),
    dropEnt = ent:GetClass(),
    amount = 1,
    data = self:GetData(ent)
  }
  self:Pickup(ply, ent, info)

  return true
end

-- Register all the suits you have here as entities
ITEM:Register("armor_tier5")
