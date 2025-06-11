--https://vk.com/gmodleak

local PANEL = {}

function PANEL:Init()
  self.Bank = self:Add("Inventory.Bank.Internal")

  self.Inventory = self:Add("XeninUI.Frame")
  self.Inventory.closeBtn:SetVisible(false)
  self.Inventory:SetTitle(Inventory:GetPhrase("Inventory.Title"))
  self.Inventory.Paint = function(pnl, w, h)
    draw.RoundedBox(6, 0, 0, w, h, XeninUI.Theme.Background)
  end

  self.Inventory.Panel = self.Inventory:Add("Inventory.Slots")
  self.Inventory.Panel:SetColumns(Inventory.Config.BankItemsPerRow)
  self.Inventory.Panel:Dock(FILL)
  self.Inventory.Panel:DockMargin(8, 8, 8, 8)
  self.Inventory.Panel:CreateFields(LocalPlayer():Inventory():GetInventory(), true)
end

function PANEL:PerformLayout(w, h)
  local size = w / 2 - 64 / 2

  self.Bank:SetSize(size, h)
  self.Inventory:SetSize(size, h)
  self.Inventory:SetPos(w - self.Inventory:GetWide(), 0)
end

vgui.Register("Inventory.Bank", PANEL)

XeninUI:CreateFont("Inventory.Bank.Upgrade", 18)

local PANEL = {}

function PANEL:Init()
  self:SetTitle(Inventory:GetPhrase("Bank.Title"))

  self.Inventory = self:Add("Inventory.Slots")
  self.Inventory:SetColumns(Inventory.Config.BankItemsPerRow)
  self.Inventory:Dock(FILL)
  self.Inventory:DockMargin(8, 8, 8, 8)

  self:Refresh()
end

function PANEL:Refresh()
  local inv = LocalPlayer():Inventory()
  local tbl = inv:GetBank()

  self.Inventory:CreateFields(tbl, true, inv:GetBankSlots(), true)
end

function PANEL:CreateFields()
  local tbl = {} -- LocalPlayer():Inventory():GetBank()

  self.Inventory:CreateFields(tbl, true)
end

vgui.Register("Inventory.Bank.Internal", PANEL, "XeninUI.Frame")

local PANEL = {}

function PANEL:Init()
  self.Panel = self:Add("Inventory.Bank")
  self.Panel.Bank.closeBtn.DoClick = function(pnl)
    self:Remove()
  end

  self.Blur = 0
  self:Lerp("Blur", 4, 0.15)

  Inventory.Bank = self
end

function PANEL:PerformLayout(w, h)
  local width = math.min(ScrW(), 1400)
  local height = math.min(ScrH(), 828)

  self.Panel:SetSize(width, height)
  self.Panel:SetPos(w / 2 - width / 2, h / 2 - height / 2)
end

function PANEL:OnRemove()
  Inventory.Bank = nil
end

function PANEL:Paint(w, h)
  XeninUI:DrawBlur(self, self.Blur)
end

vgui.Register("Inventory.Bank.Frame", PANEL, "EditablePanel")

/*
concommand.Add("inventory_bank", function()
  if (IsValid(Inventory.Frame)) then return end

  local frame = vgui.Create("Inventory.Bank.Frame")
  frame:SetSize(ScrW(), ScrH())
  frame:Center()
  frame:MakePopup()
end)
*/