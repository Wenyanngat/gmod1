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
  local weapon = ents.Create("spawned_weapon")
  local model = self:GetModel(tbl.ent)
  weapon:SetModel(model)
  weapon:SetWeaponClass(ent)
  weapon:SetPos(tr.HitPos)
  weapon.ammoadd = weapons.Get(ent) and weapons.Get(ent).Primary.DefaultClip
  
  weapon:Spawn()
end)

ITEM:AddAction("Drop All", 3, function(self, ply, ent, tbl)
  local trace = {}
  trace.start = ply:EyePos()
  trace.endpos = trace.start + ply:GetAimVector() * 85
  trace.filter = ply

  local tr = util.TraceLine(trace)
  local weapon = ents.Create("spawned_weapon")
  local model = self:GetModel(tbl.ent)
  weapon:SetModel(model)
  weapon:SetWeaponClass(ent)
  weapon:SetPos(tr.HitPos)
  weapon:Setamount(tbl.amount)
  weapon.ammoadd = weapons.Get(ent) and weapons.Get(ent).Primary.DefaultClip
  
  weapon:Spawn()
end)

function ITEM:GetDisplayName(ent)
  if (!IsValid(ent)) then return "" end

  return self:GetName(ent)
end

function ITEM:GetName(ent)
  local tbl = weapons.Get(ent.ent)
  if (!tbl) then return ent.ent end

  return tbl.PrintName or ent.ent
end

function ITEM:OnPickup(ply, ent)
  if (!IsValid(ent)) then return end

  local info = {
    ent = ent:GetWeaponClass(),
    dropEnt = ent:GetClass(),
    amount = ent:Getamount(),
    data = self:GetData(ent)
  }
  self:Pickup(ply, ent, info)

  return true
end

ITEM:Register("spawned_weapon")

if (CLIENT) then
  local PANEL = {}

  XeninUI:CreateFont("Inventory.Hover.Title", 22)
  XeninUI:CreateFont("Inventory.Hover.Subtitle", 18)
  XeninUI:CreateFont("Inventory.Weapons.Hover.Stats", 16)

  function PANEL:SetInfo(tbl)
    self.Alpha = 0
    self:LerpAlpha(255, 0.15)
    
    local item = Inventory:GetItem(tbl.dropEnt)
    local name = item and item:GetName(tbl)
    local data = tbl.data
    local rarity = Inventory:GetRarity(tbl)

    self.wepTbl = weapons.Get(tbl.ent)
    self.title = name
    self.rarity = rarity
    local tbl = Inventory.Config.Categories[rarity]
    if (tbl) then
      --self.title = tbl.name .. " " .. name
      self.tbl = tbl
    end

    self.stats = data.stats or {}
  end

  function PANEL:Paint(w, h)
    local aX, aY = self:LocalToScreen()
    BSHADOWS.BeginShadow()
      draw.RoundedBox(6, aX, aY, w, h, XeninUI.Theme.Primary)
    BSHADOWS.EndShadow(1, 2, 2)
    
    local y = 8
    draw.SimpleText(self.title, "Inventory.Hover.Title", 9, 9, Color(0, 0, 0, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.SimpleText(self.title, "Inventory.Hover.Title", 8, 8, self.tbl and self.tbl.color or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
  end

  function PANEL:PerformLayout(w, h)
    surface.SetFont("Inventory.Hover.Title")
    local tw, th = surface.GetTextSize(self.title or "")
    local width = tw + 16
    local height = 16 + th

    self:SetSize(width, height)
  end

  vgui.Register("Inventory.Weapon.Hover", PANEL)
end
