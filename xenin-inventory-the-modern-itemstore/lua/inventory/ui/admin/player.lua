--https://vk.com/gmodleak

local PANEL = {}
local INV = false
local BANK = true

function PANEL:Init()
	self:SetAlpha(0)
	self:AlphaTo(255, 0.15)

	self:SetSize(ScrW(), ScrH())
	self:SetBackgroundWidth(XeninUI.Frame.Width)
	self:SetBackgroundHeight(XeninUI.Frame.Height)
	self:SetTitle(Inventory:GetPhrase("Admin.Player.Title"))
	self:MakePopup()
end

XeninUI:CreateFont("Inventory.Admin.Player.State", 24)

function PANEL:SetData(tbl)
	local ply = LocalPlayer()
	self.data = tbl
	
	self.Top = self.background:Add("DPanel")
	self.Top:Dock(TOP)
	self.Top:DockMargin(0, 0, 0, 0)
	self.Top:SetTall(64)
	self.Top.Paint = function(pnl, w, h)
		XeninUI:DrawRoundedBox(0, 0, 0, w, h, XeninUI.Theme.Navbar)

		XeninUI:DrawShadowText(self.data.nick, "Inventory.Admin.Row.Title", h, h / 2 + 3 - 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, 125)
		XeninUI:DrawShadowText(Inventory:GetPhrase("Admin.Player.Items", { items = self.data.items }), "Inventory.Admin.Row.Subtitle", h, h / 2 + 2, Color(180, 180, 180), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, 125)
	end

	self.Top.Avatar = self.Top:Add("XeninUI.Avatar")
	self.Top.Avatar:SetVertices(30)
	self.Top.Avatar.avatar:SetSteamID(tbl.sid64, 128)
	
	self.Top.Clear = self.Top:Add("DButton")
	self.Top.Clear:SetText(Inventory:GetPhrase("Admin.Player.Clear.Inventory"))
	self.Top.Clear:SetFont("Inventory.Admin.Row.Interact")
	self.Top.Clear.TextColor = Color(220, 220, 220)
	self.Top.Clear.Color = XeninUI.Theme.Background
	self.Top.Clear.Paint = function(pnl, w, h)
		pnl:SetTextColor(pnl.TextColor)

		XeninUI:DrawRoundedBox(h / 2, 0, 0, w, h, pnl.Color)
	end
	self.Top.Clear.OnCursorEntered = function(pnl)
		pnl:LerpColor("TextColor", color_white)
		pnl:LerpColor("Color", XeninUI.Theme.Primary)
	end
	self.Top.Clear.OnCursorExited = function(pnl)
		pnl:LerpColor("TextColor", Color(220, 220, 220))
		pnl:LerpColor("Color", XeninUI.Theme.Background)
	end
	self.Top.Clear.DoClick = function(pnl)
		local bank = self.isBank
		local popup = vgui.Create("XeninUI.Query")
		popup:SetSize(ScrW(), ScrH())
		popup:SetBackgroundWidth(400)
		popup:SetBackgroundHeight(140)
		local str = bank and Inventory:GetPhrase("Admin.Player.Clear.Bank") or Inventory:GetPhrase("Admin.Player.Clear.Inventory")
		popup:SetTitle(str)
		str = Inventory:GetPhrase("Admin.Player.Clear.Popup.Text", {
			type = bank and "bank" or "inventory"
		})
		popup:SetText(str)
		popup:SetAccept(Inventory:GetPhrase("Admin.Player.Clear.Popup.Yes"), function()
			net.Start("Inventory.Admin.Clear")
				net.WriteString(self.data.sid64)
				net.WriteBool(bank)
			net.SendToServer()

			if (bank) then
				self.data.bank = {}
			else
				self.data.inv = {}
			end

			for i, v in pairs(self.Fields) do
				self.Fields[i]:Remove()
				self.Fields[i] = nil
			end
		end)
		popup:SetDecline(Inventory:GetPhrase("Admin.Player.Clear.Popup.No"), function() end)
		popup:MakePopup()
	end

	self.Top.PerformLayout = function(pnl, w, h)
		self.Top.Avatar:SetPos(8, 8)
		self.Top.Avatar:SetSize(h - 16, h - 16)

		self.Top.Clear:SizeToContentsX(32)
		self.Top.Clear:SizeToContentsY(16)
		self.Top.Clear:AlignRight(8)
		self.Top.Clear:CenterVertical()
	end

	self.Type = self.background:Add("XeninUI.Checkbox")
	self.Type:Dock(TOP)
	self.Type:SetTall(40)
	self.Type:SetStateText(Inventory:GetPhrase("Admin.Player.Tabs.Inventory"), Inventory:GetPhrase("Admin.Player.Tabs.Bank"))
	self.Type.font = "Inventory.Admin.Player.State"
	self.Type.OnStateChanged = function(pnl, state)
		self:Build(state)
	end

	self.Scroll = self.background:Add("XeninUI.Scrollpanel.Wyvern")
	self.Scroll:Dock(FILL)
	self.Scroll:DockMargin(8, 16, 8, 8)

  self.Layout = self.Scroll:Add("DIconLayout")
  self.Layout:Dock(FILL)
  self.Layout:DockMargin(0, 0, 8, 0)
  self.Layout:SetSpaceY(8)
  self.Layout:SetSpaceX(8)
  self.Layout.PerformLayout = function(pnl, w, h)
    local children = pnl:GetChildren()
    local count = 8
    local amount = (math.max(1, math.floor(#children / count))) * 276 -- Idfk where the 276 is from, it was in the code I took from an earlier project
    local width = w / math.min(count, #children)

    local x = 0
    local y = 0

    local spacingX = pnl:GetSpaceX()
    local spacingY = pnl:GetSpaceY()
    local border = pnl:GetBorder()
    local innerWidth = w - border * 2 - spacingX * (count - 1)

    for i, child in ipairs(children) do
      if (!IsValid(child)) then continue end
    
      child:SetPos(border + x * innerWidth / count + spacingX * x, border + y * child:GetTall() + spacingY * y)
      child:SetSize(innerWidth / count, innerWidth / count)

      x = x + 1
      if (x >= count) then
        x = 0
        y = y + 1
      end
    end

    pnl:SizeToChildren(false, true)
  end

	self.Fields = {}

	self:Build(INV)
end

function PANEL:Build(bank)
	self.isBank = bank
	self.data.items = bank and table.Count(self.data.bank) or table.Count(self.data.inv)
	local str = bank and Inventory:GetPhrase("Admin.Player.Clear.Bank") or Inventory:GetPhrase("Admin.Player.Clear.Inventory")
	self.Top.Clear:SetText(str)
	self.Top:InvalidateLayout()

	for i, v in pairs(self.Fields) do
		v:Remove()
		self.Fields[i] = nil
	end

	local tbl = self.data[bank and "bank" or "inv"]
	local highestNum = 0
	for i, v in pairs(tbl) do
		if (v.id > highestNum) then
			highestNum = v.id
		end
	end

	for i = 1, highestNum do
		local id = tonumber(i)
		self.Fields[id] = self.Layout:Add("Inventory.Field")
    self.Fields[id]:SetItem(tbl and tbl[id])
    self.Fields[id]:SetDroppable(false, bank)
    self.Fields[id]:SetID(tbl[id] and tbl[id].id or id)
    self.Fields[id]:SetIsAdmin(self.data.sid64)
	end
end

function PANEL:PerformLayout(w, h)
	self.BaseClass.PerformLayout(self, w, h)
end

vgui.Register("Inventory.Admin.Player", PANEL, "XeninUI.Popup")