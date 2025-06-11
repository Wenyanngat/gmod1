--https://vk.com/gmodleak

local PANEL = {}

function PANEL:Init()
  Inventory.AdminFrame = self

  self.topNavbar = vgui.Create("Panel", self)
  self.topNavbar:Dock(TOP)

	self.navbar = vgui.Create("XeninUI.Navbar", self.topNavbar)
	self.navbar:Dock(FILL)
	self.navbar:SetBody(self)
  self.navbar:AddTab(Inventory:GetPhrase("Admin.Tabs.Management"), "Inventory.Admin.Management")
  /*
  self.navbar:AddTab("TRADING LOGS", "Panel")
  */
  self.navbar:SetActive(Inventory:GetPhrase("Admin.Tabs.Management"))
end

function PANEL:OnRemove()
  Inventory.AdminFrame = nil
end

function PANEL:PerformLayout(w, h)
  self.BaseClass.PerformLayout(self, w, h)

  self.topNavbar:SetTall(56)
end
vgui.Register("Inventory.Admin", PANEL, "XeninUI.Frame")

concommand.Add("inventory_admin", function()
  if (IsValid(Inventory.Frame)) then return end
  local inv = LocalPlayer():Inventory()
  if (!Inventory:IsAdmin(LocalPlayer())) then
    inv:Message(Inventory:GetPhrase("Admin.Tabs.NotAdmin"))

    return
  end

  local frame = vgui.Create("Inventory.Admin")
  local width = math.min(ScrW(), XeninUI.Frame.Width)
  local height = math.min(ScrH(), XeninUI.Frame.Height + 100)
  frame:SetSize(width, height)
  frame:Center()
  frame:MakePopup()
  frame:SetTitle(Inventory:GetPhrase("Admin.Title"))
end)