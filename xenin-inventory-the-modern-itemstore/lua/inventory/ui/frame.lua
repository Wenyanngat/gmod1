--https://vk.com/gmodleak

local PANEL = {}

function PANEL:Init()
  Inventory.Frame = self

  self.topNavbar = vgui.Create("Panel", self)
  self.topNavbar:Dock(TOP)

	self.navbar = vgui.Create("XeninUI.Navbar", self.topNavbar)
	self.navbar:Dock(FILL)
	self.navbar:SetBody(self)
  self.navbar:AddTab(Inventory:GetPhrase("Inventory.Tabs.Inventory"), "Inventory.Inventory")
  /*
  self.navbar:AddTab("BANK", "Panel")
  self.navbar:AddTab("MARKETPLACE", "Panel")
  self.navbar:AddTab("TRADING", "Panel")
  self.navbar:AddTab("INBOX", "Panel")
  */
  self.navbar:SetActive(Inventory:GetPhrase("Inventory.Tabs.Inventory"))
end

function PANEL:OnRemove()
  Inventory.Frame = nil
end

function PANEL:PerformLayout(w, h)
  self.BaseClass.PerformLayout(self, w, h)

  self.topNavbar:SetTall(56)
end
vgui.Register("Inventory.Frame", PANEL, "XeninUI.Frame")

concommand.Add("inventory", function()
  if (IsValid(Inventory.Frame)) then return end

  local frame = vgui.Create("Inventory.Frame")
  local width = math.min(ScrW(), 1100)
  local height = math.min(ScrH(), 828)
  frame:SetSize(width, height)
  frame:Center()
  frame:MakePopup()
  frame:SetTitle("Inventory")
end)