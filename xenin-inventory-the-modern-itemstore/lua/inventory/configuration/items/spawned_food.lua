--https://vk.com/gmodleak

local ITEM = Inventory:CreateItem()
ITEM.Hover = "Inventory.Weapon.Hover"

ITEM:AddAction("Use", 1, function(self, ply, ent, tbl)
  if (CLIENT) then return true end

	local energy = ply:getDarkRPVar("Energy") + tbl.data.energy
	ply:setDarkRPVar("Energy", math.Clamp(energy, 0, 100))

	umsg.Start("AteFoodIcon", ply)
	umsg.End()
end, function() return true end)

ITEM:AddAction("Drop", 2, function(self, ply, ent, tbl)
  local trace = {}
  trace.start = ply:EyePos()
  trace.endpos = trace.start + ply:GetAimVector() * 85
  trace.filter = ply

  local tr = util.TraceLine(trace)
  local weapon = ents.Create("spawned_food")
  local model = self:GetModel(tbl)
  weapon:SetModel(tbl.data.model)
  weapon:SetPos(tr.HitPos)
  weapon:Setowning_ent(ply)
	weapon.FoodEnergy = tbl.data.energy
  weapon.FoodName = tbl.data.name
  weapon.foodItem = tbl.data.foodItem

  weapon:Spawn()
end)

function ITEM:GetDisplayName(ent)
  if (!IsValid(ent)) then return "" end

  return self:GetName(ent)
end

function ITEM:GetData(ent)
	return {
		energy = ent.FoodEnergy,
    name = ent.FoodName,
    foodItem = ent.foodItem,
		model = ent:GetModel()
	}
end

function ITEM:GetName(ent)
  if (isentity(ent)) then
    local tbl = FoodItems
    local mdl = ent:GetModel()

    for i, v in pairs(tbl) do
      if (v.model != mdl) then continue end

      return v.name
    end

    return "Unknown food name"
  end

  return ent.data.name or "Unknown food name"
end

function ITEM:GetModel(ent)
	return ent.data.model or "xd.mdl"	
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

ITEM:Register("spawned_food")

