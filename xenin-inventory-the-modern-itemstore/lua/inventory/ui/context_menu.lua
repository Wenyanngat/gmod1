--https://vk.com/gmodleak

local PANEL = {}

function PANEL:Init()
  self.Background = Color(0, 0, 0, 200)
end

function PANEL:DragHover()
  if (self.lock) then return end

  self.lock = true
  self:LerpColor("Background", Color(0, 0, 0, 240))
end

function PANEL:DragHoverExited()
  self.lock = nil

  self:LerpColor("Background", Color(0, 0, 0, 200))
end

vgui.Register("Inventory.ActionField", PANEL)

XeninUI:CreateFont("Inventory.ContextMenu.Action", 40)
XeninUI:CreateFont("Inventory.ContextMenu.Action.Small", 29)

function Inventory:VerticalText(text, font, col, x, y)
	surface.SetFont(font)
	surface.SetTextColor(col)
	local prevh = 0 
	for i = 1, #text do
		local w, h = surface.GetTextSize(string.sub(text, 1, i - 1))
		local actualw, actualh = surface.GetTextSize(string.sub(text, i, i))
		prevh = prevh + h - 3
		surface.SetTextPos(x - actualw / 2, y + prevh )
		surface.DrawText(string.sub(text, i, i))
	end
end

local PANEL = {}

function PANEL:Init()
  Inventory.ContextFrame = self

  self.Left = self:Add("Inventory.ActionField")
  self.Left.Paint = function(pnl, w, h)
    if (!dragndrop.IsDragging()) then return end
    local drag = dragndrop.m_Dragging[1]
    if (drag and drag.isInventoryField) then
      local item = Inventory:GetItem(drag.dropEnt)
      if (item.Actions["Drop"]) then
        draw.RoundedBoxEx(6, 0, 0, w, h, pnl.Background, true, false, false, false)

        local fontHeight = draw.GetFontHeight("Inventory.ContextMenu.Action")
        local str = Inventory:GetPhrase("Inventory.Popup.Drop"):upper()
        fontHeight = 40

        Inventory:VerticalText(str, "Inventory.ContextMenu.Action", color_white, w / 2, h / 2 - 10 - ((fontHeight * #str) / 2))
      elseif (item.Actions["Drop Amount"]) then
        draw.RoundedBoxEx(6, 0, 0, w, h, pnl.Background, true, false, false, false)

        local fontHeight = draw.GetFontHeight("Inventory.ContextMenu.Action")
        local str = Inventory:GetPhrase("Inventory.Popup.Drop Amount"):upper()
        fontHeight = 40

        Inventory:VerticalText(str, "Inventory.ContextMenu.Action", color_white, w / 2, h / 2 - 10 - ((fontHeight * #str) / 2))
      end
    end
  end
  self.Left:Receiver("Inventory.Field", function(pnl, tbl, dropped)
    if (!dropped) then return end
    local droppedPnl = tbl[1]
    if (!droppedPnl) then return end
    local item = droppedPnl.dropEnt
    if (!item) then return end
    item = Inventory:GetItem(item)
    if (!item) then return end

    if (item.Actions["Drop"]) then
      droppedPnl.Popup[Inventory:GetPhrase("Inventory.Popup.Drop")](droppedPnl, droppedPnl:GetID())
    elseif (item.Actions["Drop Amount"]) then
      droppedPnl.Popup[Inventory:GetPhrase("Inventory.Popup.Drop Amount")](droppedPnl, droppedPnl:GetID())
    end
  end)

  self.Top = self:Add("Inventory.ActionField")
  self.Top.Paint = function(pnl, w, h)
    if (!dragndrop.IsDragging()) then return end
    local drag = dragndrop.m_Dragging[1]
    if (drag and drag.isInventoryField) then
      local item = Inventory:GetItem(drag.dropEnt)
      if (item.Actions["Equip"] or item.Actions["Use"]) then
        surface.SetDrawColor(pnl.Background)
        surface.DrawRect(0, 0, w, h)

        local str = item.Actions["Equip"] and Inventory:GetPhrase("Inventory.Popup.Equip") or Inventory:GetPhrase("Inventory.Popup.Use")
        str = str:upper()
        draw.SimpleText(str, "Inventory.ContextMenu.Action", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      end
    end
  end
  self.Top:Receiver("Inventory.Field", function(pnl, tbl, dropped)
    if (!dropped) then return end
    local droppedPnl = tbl[1]
    if (!droppedPnl) then return end
    local item = droppedPnl.dropEnt
    if (!item) then return end
    item = Inventory:GetItem(item)
    if (!item) then return end

    if (item.Actions["Equip"]) then
      droppedPnl.Popup[Inventory:GetPhrase("Inventory.Popup.Equip")](droppedPnl, droppedPnl:GetID())
    elseif (item.Actions["Use"]) then
      droppedPnl.Popup[Inventory:GetPhrase("Inventory.Popup.Use")](droppedPnl, droppedPnl:GetID())
    end
  end)

  self.Right = self:Add("Inventory.ActionField")
  self.Right.Paint = function(pnl, w, h)
    if (!dragndrop.IsDragging()) then return end
    local drag = dragndrop.m_Dragging[1]
    if (drag and drag.isInventoryField) then
      local item = Inventory:GetItem(drag.dropEnt)

      local amt = drag.info.data.amount or drag.info.data.Amount or 0
      if (item.Actions["Drop All"] and (drag:GetAmount() > 1 or amt > 1)) then
        draw.RoundedBoxEx(6, 0, 0, w, h, pnl.Background, false, true, false, false)

        local fontHeight = draw.GetFontHeight("Inventory.ContextMenu.Action")
        local str = Inventory:GetPhrase("Inventory.Popup.Drop All"):upper()
        fontHeight = 40

        Inventory:VerticalText(str, "Inventory.ContextMenu.Action", color_white, w / 2, h / 2 - 10 - ((fontHeight * #str) / 2))
      end
    end
  end    
  self.Right:Receiver("Inventory.Field", function(pnl, tbl, dropped)
    if (!dropped) then return end
    local droppedPnl = tbl[1]
    if (!droppedPnl) then return end
    local item = droppedPnl.dropEnt
    if (!item) then return end
    item = Inventory:GetItem(item)
    if (!item) then return end

    if (item.Actions["Drop All"] and (droppedPnl:GetAmount() > 1 or droppedPnl.info.data.amount > 1 or droppedPnl.info.data.Amount > 1)) then
      droppedPnl.Popup[Inventory:GetPhrase("Inventory.Popup.Drop All")](droppedPnl, droppedPnl:GetID()) 
    end
  end)

  self.Inventory = self:Add("XeninUI.Frame")
  self.Inventory.closeBtn:SetVisible(false)
  self.Inventory:SetTitle(Inventory:GetPhrase("Inventory.Title"))
  self.Inventory.Paint = function(pnl, w, h)
    draw.RoundedBox(6, 0, 0, w, h, XeninUI.Theme.Background)
  end

  self.Inventory.Panel = self.Inventory:Add("Inventory.Slots")
  self.Inventory.Panel:SetColumns(Inventory.Config.ContextMenuColumns or 6)
  self.Inventory.Panel:Dock(FILL)
  self.Inventory.Panel:DockMargin(8, 8, 8, 8)
  self.Inventory.Panel:CreateFields(LocalPlayer():Inventory():GetInventory(), true)
end

function PANEL:PerformLayout(w, h)
  self.Left:SetPos(0, 0)
  self.Left:SetSize(150, h)

  self.Top:SetPos(150, 0)
  self.Top:SetSize(w - 300, 150)

  self.Right:SetPos(w - 150, 0)
  self.Right:SetSize(150, h)

  self.Inventory:SetPos(150, 150)
  self.Inventory:SetSize(w - 300, h - 150)
end

vgui.Register("Inventory.Context", PANEL)

hook.Add("OnContextMenuOpen", "Inventory", function()
  timer.Simple(0, function()
    if (!IsValid(Inventory.ContextFrame)) then
      local frame = g_ContextMenu:Add("Inventory.Context")
      local tbl = Inventory.Config.ContextMenuSize or {}
      tbl.Width = tbl.Width or 1000
      tbl.Height = tbl.Height or 534
      local width = math.min(ScrW() - 200, tbl.Width)
      local height = math.min(ScrH(), tbl.Height)

      frame:SetSize(width, height)
      frame:SetPos(ScrW() / 2 - width / 2, ScrH() - height - 10)
      frame:SetMouseInputEnabled(true)
    end
  end)
end)

hook.Add("OnContextMenuClose", "Inventory", function()
  if (IsValid(Inventory.ContextFrame)) then
    Inventory.ContextFrame:Remove()
  end
end)

local LastHoverThink = nil
local LastHoverChangeTime = 0
local LastX = 0
local LastY = 0

function dragndrop.HoverThink()
	local hovered = vgui.GetHoveredPanel()
	local x = gui.MouseX()
	local y = gui.MouseY()

  if (LastHoverThink != hovered and IsValid(LastHoverThink) and LastHoverThink.DragHoverExited) then
    local dragging = LastHoverThink:IsDragging() 

    if (!dragging) then
      LastHoverThink:DragHoverExited()
    end
  end

	if (LastHoverThink != hovered || x != LastX || y != LastY) then
		LastHoverChangeTime = SysTime()
		LastHoverThink = hovered
	end

	-- Hovered panel might do stuff when we're hovering it
	-- so give it a chance to do that now.
	if (IsValid(LastHoverThink)) then
		LastX = x
		LastY = y

    local dragging = LastHoverThink:IsDragging() 

    if (!dragging) then
		  LastHoverThink:DragHover(SysTime() - LastHoverChangeTime)
    end
	end
end