--https://vk.com/gmodleak

local PANEL = {}

XeninUI:CreateFont("Inventory.Admin.Title", 30)

local function GetNameAsync(sid64)
	local p = XeninUI.Promises.new()
	local ply = player.GetBySteamID64(sid64)

	if (IsValid(ply)) then
		p:resolve({ sid64 = sid64, name = ply:Nick()} )
	else
		steamworks.RequestPlayerInfo(sid64, function(name)
			if (name == "" or name == nil) then
				p:reject()
			else
				p:resolve({ sid64 = sid64, name = name})
			end
		end)
	end
	
	return p
end

function PANEL:Init()
	self.Rows = {}

	self.Top = self:Add("Panel")
	self.Top:Dock(TOP)
	self.Top:DockMargin(16, 0, 16, 0)

	self.Top.Title = self.Top:Add("DLabel")
	self.Top.Title:SetText(Inventory:GetPhrase("Admin.Management.Loading"))
	self.Top.Title:Dock(LEFT)
	self.Top.Title:DockMargin(0, 12, 0, 8)
	self.Top.Title:SetFont("Inventory.Admin.Title")
	self.Top.Title:SetContentAlignment(4)
	self.Top.Title:SizeToContents()

	self.Top.Search = self.Top:Add("XeninUI.TextEntry")
	self.Top.Search:Dock(RIGHT)
	self.Top.Search:DockMargin(0, 12, 0, 8)
	self.Top.Search:SetPlaceholder(Inventory:GetPhrase("Admin.Management.Search"))
	self.Top.Search.textentry:SetUpdateOnType(true)
	self.Top.Search.textentry.OnValueChange = function(pnl, text)
		pnl.Loading = true

		self:RemoveRows()

		XeninUI:Debounce("Inventory.Admin.Search", 0.5, function()
			if (text == "") then 
				net.Start("Inventory.Admin.Search")
					net.WriteBool(true)
					net.WriteTable(player.GetHumans())
				net.SendToServer()

				return
			end
			local results = {}
			for i, v in pairs(player.GetHumans()) do
				if (!IsValid(v)) then continue end
				if (!v:Nick():lower():find(text)) then continue end

				table.insert(results, v)
			end

			if (#results > 0) then
				net.Start("Inventory.Admin.Search")
					net.WriteBool(true)
					net.WriteTable(results)
				net.SendToServer()
			else
				net.Start("Inventory.Admin.Search")
					net.WriteBool(false)
					net.WriteTable({ text })
				net.SendToServer()
			end
		end)
	end
	self.Top.Search.textentry.PaintOver = function(pnl, w, h)
		if (!pnl.Loading) then return end

		pnl:NoClipping(false)
			XeninUI:DrawCircle(w - h / 2, h / 2, h * 0.8, 30, Color(0, 0, 0, 100))
			XeninUI:DrawLoadingCircle(w - h / 2, h / 2, h * 1.2, XeninUI.Theme.Green)
		pnl:NoClipping(true)
	end
	self.Top.Search.textentry:AddHook("Inventory.Admin.Search", "Inventory.Admin.TextEntry", function(pnl, data)
		local tbl = {}

		-- First get their names
		local nameTbl = {}
		for i, v in pairs(data) do
			-- DO NOT ALLOW BOTS
			if (i >= "90071996842377216") then continue end

			table.insert(nameTbl, GetNameAsync(i))
		end

		-- Construct the data
		local tbl = {}
		local p = XeninUI.Promises
		p.all(nameTbl):next(function(results)
			for i, v in ipairs(results) do
				table.insert(tbl, {
					sid64 = v.sid64,
					nick = v.name,
					inv = data[v.sid64].inv,
					bank = data[v.sid64].bank
				})
			end

			self:BuildPage(tbl)

			pnl.Loading = nil
		end)
	end)

	self.Scroll = self:Add("XeninUI.Scrollpanel.Wyvern")
	self.Scroll:Dock(FILL)
	self.Scroll:DockMargin(16, 8, 16, 16)

	net.Start("Inventory.Admin.Search")
		net.WriteBool(true)
		net.WriteTable(player.GetHumans())
	net.SendToServer()
end

XeninUI:CreateFont("Inventory.Admin.Row.Title", 24)
XeninUI:CreateFont("Inventory.Admin.Row.Subtitle", 18)
XeninUI:CreateFont("Inventory.Admin.Row.Interact", 20)

function PANEL:RemoveRows()
	for i, v in ipairs(self.Rows) do
		v:Remove()
		self.Rows[i] = nil
	end

	self.Top.Title:SetText(Inventory:GetPhrase("Admin.Management.Searching"))
	self.Top.Title:SizeToContents()
end

function PANEL:BuildPage(tbl)
	for i, v in ipairs(self.Rows) do
		v:Remove()
		self.Rows[i] = nil
	end

	self.Top.Title:SetText(#tbl .. " results")
	self.Top.Title:SizeToContents()

	for i, v in pairs(tbl) do
		local panel = self.Scroll:Add("DPanel")
		panel:Dock(TOP)
		panel:DockMargin(0, 0, 8, 8)
		panel:SetTall(64)
		panel.Online = player.GetBySteamID64(v.sid64)
		panel.Paint = function(pnl, w, h)
			XeninUI:DrawRoundedBox(6, 0, 0, w, h, XeninUI.Theme.Navbar)

			XeninUI:DrawShadowText(v.nick, "Inventory.Admin.Row.Title", h, h / 2 + 3 - 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 2, 125)
			XeninUI:DrawShadowText(panel.Online and Inventory:GetPhrase("Admin.Management.Online") or Inventory:GetPhrase("Admin.Management.Offline"), "Inventory.Admin.Row.Subtitle", h, h / 2 + 2, panel.Online and Color(180, 180, 180) or XeninUI.Theme.Red, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, 125)
		end

		panel.Avatar = panel:Add("XeninUI.Avatar")
		panel.Avatar:SetVertices(30)
		panel.Avatar.avatar:SetSteamID(v.sid64, 128)
		
		panel.Inspect = panel:Add("DButton")
		panel.Inspect:SetText(Inventory:GetPhrase("Admin.Management.OpenInventory"))
		panel.Inspect:SetFont("Inventory.Admin.Row.Interact")
		panel.Inspect.TextColor = Color(220, 220, 220)
		panel.Inspect.Color = XeninUI.Theme.Background
		panel.Inspect.Paint = function(pnl, w, h)
			pnl:SetTextColor(pnl.TextColor)

			XeninUI:DrawRoundedBox(h / 2, 0, 0, w, h, pnl.Color)
		end
		panel.Inspect.OnCursorEntered = function(pnl)
			pnl:LerpColor("TextColor", color_white)
			pnl:LerpColor("Color", XeninUI.Theme.Primary)
		end
		panel.Inspect.OnCursorExited = function(pnl)
			pnl:LerpColor("TextColor", Color(220, 220, 220))
			pnl:LerpColor("Color", XeninUI.Theme.Background)
		end
		panel.Inspect.DoClick = function(pnl)
			local pnl = vgui.Create("Inventory.Admin.Player")
			pnl:SetData(v)
		end
		
		panel.PerformLayout = function(pnl, w, h)
			panel.Avatar:SetPos(8, 8)
			panel.Avatar:SetSize(h - 16, h - 16)

			panel.Inspect:SizeToContentsX(32)
			panel.Inspect:SizeToContentsY(16)
			panel.Inspect:AlignRight(8)
			panel.Inspect:CenterVertical()
		end

		table.insert(self.Rows, panel)
	end
end

function PANEL:PerformLayout(w, h)
	self.Top:SetTall(54)

	self.Top.Search:SetWide(250)
end

vgui.Register("Inventory.Admin.Management", PANEL, "XeninUI.Panel")