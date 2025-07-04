--https://vk.com/gmodleak

local ITEM = Inventory:CreateItem()
ITEM.Hover = "Inventory.Money.Hover"
ITEM.MaxStack = 2 ^ 64
ITEM.DontDisplayAmount = true

ITEM:AddAction("Drop Amount", 1, function(self, ply, ent, tbl, amt)
  if (CLIENT) then return true end

  local trace = {}
  trace.start = ply:EyePos()
  trace.endpos = trace.start + ply:GetAimVector() * 85
  trace.filter = ply

  local tr = util.TraceLine(trace)
  local weapon = ents.Create("spawned_money")
  local model = self:GetModel()
  weapon:Setamount(amt)
  weapon:SetPos(tr.HitPos)
  weapon:Spawn()
end)

ITEM:AddAction("Drop All", 2, function(self, ply, ent, tbl)
  local trace = {}
  trace.start = ply:EyePos()
  trace.endpos = trace.start + ply:GetAimVector() * 85
  trace.filter = ply

  local tr = util.TraceLine(trace)
  local weapon = ents.Create("spawned_money")
  local model = self:GetModel()
  weapon:Setamount(tbl.amount or tbl.data.Amount)
  weapon:SetPos(tr.HitPos)
  weapon:Spawn()
end)

function ITEM:GetDisplayName(ent)
  if (!IsValid(ent)) then return "" end

  return self:GetName(ent)
end

function ITEM:GetName(ent)
  if (istable(ent)) then
    return Inventory:GetPhrase("Inventory.Money", { money = DarkRP.formatMoney(ent.amount or ent.data.Amount) })
  end
  
  return Inventory:GetPhrase("Inventory.Money", { money = DarkRP.formatMoney(ent:Getamount()) })
end

function ITEM:GetItem(ent)
  return ent
end

function ITEM:GetModel(ent)
  return GAMEMODE.Config.moneyModel
end

function ITEM:GetData(ent)
  return {}
end

function ITEM:OnPickup(ply, ent)
  if (!IsValid(ent)) then return end

  local info = {
    ent = ent:GetClass(),
    dropEnt = ent:GetClass(),
    amount = ent:Getamount(),
    data = self:GetData(ent)
  }
  self:Pickup(ply, ent, info)

  return true
end

ITEM:Register("spawned_money")

if (CLIENT) then
  local PANEL = {}

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
    self.data = data
    self.realData = tbl
    local tbl = Inventory.Config.Categories[rarity]
    if (tbl) then
      --self.title = tbl.name .. " " .. name
      self.tbl = tbl
    end
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

  vgui.Register("Inventory.Money.Hover", PANEL)

  local PANEL = {}

  XeninUI:CreateFont("Inventory.Drop.Field", 16)

  function PANEL:Init()
    self:SetSize(ScrW(), ScrH())
    self:SetBackgroundWidth(380)
    self:SetBackgroundHeight(144)
    self:MakePopup()

    self.textentry = self.background:Add("XeninUI.TextEntry")
    self.textentry:SetPlaceholder("Amount")
    self.textentry.textentry.OnEnter = function() self.accept:DoClick() end
    self.textentry.textentry:RequestFocus()

    self.accept = self.background:Add("DButton")
    self.accept:SetText("Accept")
    self.accept:SetFont("Inventory.Drop.Field")
    self.accept:SetTextColor(Color(225, 225, 225))
    self.accept.background = XeninUI.Theme.Navbar
    self.accept.Paint = function(pnl, w, h)
      draw.RoundedBox(6, 0, 0, w, h, pnl.background)
    end
    self.accept.OnCursorEntered = function(pnl)
      pnl:LerpColor("background", XeninUI.Theme.Primary)
    end
    self.accept.OnCursorExited = function(pnl)
      pnl:LerpColor("background", XeninUI.Theme.Navbar)
    end
    self.accept.DoClick = function(pnl)
      if (!self:CheckFunction()) then return end

      self:PassedFunction()
    end
  end

  function PANEL:PerformLayout(w, h)
    self.BaseClass.PerformLayout(self, w, h)

    local w = self.background:GetWide()
    local h = self.background:GetTall()
    local x = 16
    local y = 56

    self.textentry:SetPos(x, y)
    self.textentry:SetWide(w - self.textentry.x - x)
    self.textentry:SetTall(36)

    self.accept:AlignRight(x)
    self.accept:SetPos(self.accept.x, self.textentry.y + self.textentry:GetTall() + 8)
    self.accept:SizeToContentsX(24)
    self.accept:SizeToContentsY(12)
  end

  vgui.Register("Inventory.DropAmount", PANEL, "XeninUI.Popup")
end

