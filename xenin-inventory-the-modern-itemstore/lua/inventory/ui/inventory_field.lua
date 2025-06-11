--https://vk.com/gmodleak

local PANEL = {}

XeninUI:CreateFont("Inventory.Field.Name", 15)
XeninUI:CreateFont("Inventory.Field.Name.Small", 12)
XeninUI:CreateFont("Inventory.Field.Name.Smallest", 9)
XeninUI:CreateFont("Inventory.Field.Amount", 15)

AccessorFunc(PANEL, "m_backgroundColor", "BackgroundColor")
AccessorFunc(PANEL, "m_nameColor", "NameColor")
AccessorFunc(PANEL, "m_nameTextColor", "NameTextColor")
AccessorFunc(PANEL, "m_name", "Name")
AccessorFunc(PANEL, "m_amount", "Amount")
AccessorFunc(PANEL, "m_id", "ID")
AccessorFunc(PANEL, "m_isBank", "IsBank")
AccessorFunc(PANEL, "m_isAdmin", "IsAdmin")

PANEL.Popup = {
  [Inventory:GetPhrase("Inventory.Popup.Equip")] = function(self, id, btn)
    local ply = LocalPlayer()
    local inv = ply:Inventory()
    local slot = inv:Get(id)
    if (!slot) then return end
    local item = Inventory:GetItem(slot.dropEnt)
    if (!item) then return end
    if (!item.Actions.Equip) then return end
    local canEquip, reason = item.Actions.Equip.Pre(item, ply, slot, self)

    if (!canEquip) then
      XeninUI:Notify(reason, NOTIFY_ERROR, 4, XeninUI.Theme.Red)
      chat:AddText(XeninUI.Theme.Red, Inventory.Config.PrefixText .. " ", color_white, reason)

      return
    end

    if (inv:ReduceAmount(id, 1)) then
      item.Actions.Equip:Action(ply, slot.ent, slot, self)
      -- Refreshes all info
      self:SetItem(inv:Get(id))

      net.Start("Inventory.Equip")
        net.WriteUInt(id, 10)
      net.SendToServer()
    end
  end,
  [Inventory:GetPhrase("Inventory.Popup.Drop")] = function(self, id, btn)
    local ply = LocalPlayer()
    local inv = ply:Inventory()
    local slot = inv:Get(id)
    if (!slot) then return end
    local item = Inventory:GetItem(slot.dropEnt)
    if (!item) then return end
    if (!item.Actions.Drop) then return end

    if (inv:ReduceAmount(id, 1)) then
      local str = Inventory:GetPhrase("ConCommand.Drop", { item = item:GetName(slot) })
      XeninUI:Notify(str, NOTIFY_GENERIC, 4, XeninUI.Theme.Green)
      chat:AddText(Inventory.Config.PrefixCol, Inventory.Config.PrefixText .. " ", color_white, str)

      self:SetItem(inv:Get(id))

      net.Start("Inventory.Drop")
        net.WriteUInt(id, 10)
      net.SendToServer()
    end
  end,
  [Inventory:GetPhrase("Inventory.Popup.Drop All")] = function(self, id, btn)
    local ply = LocalPlayer()
    local inv = ply:Inventory()
    local slot = inv:Get(id)
    if (!slot) then return end
    local item = Inventory:GetItem(slot.dropEnt)
    if (!item) then return end
    local amount = slot.amount

    if (inv:ReduceAmount(id, amount)) then
      local str = Inventory:GetPhrase("ConCommand.DropAll", { amount = amount, item = item:GetName(slot) })
      XeninUI:Notify(str, NOTIFY_GENERIC, 4, XeninUI.Theme.Green)
      chat:AddText(Inventory.Config.PrefixCol, Inventory.Config.PrefixText .. " ", color_white, str)

      self:SetItem(inv:Get(id))

      net.Start("Inventory.DropAll")
        net.WriteUInt(id, 10)
      net.SendToServer()
    end
  end,
  [Inventory:GetPhrase("Inventory.Popup.Destroy")] = function(self, id, btn)
    local ply = LocalPlayer()
    local inv = ply:Inventory()
    local slot = inv:Get(id)
    if (!slot) then return end
    local item = Inventory:GetItem(slot.dropEnt)
    if (!item) then return end
    local amount = slot.amount

    local popup = vgui.Create("XeninUI.Query")
    popup:SetSize(ScrW(), ScrH())
    popup:SetBackgroundWidth(400)
    popup:SetBackgroundHeight(140)
    popup:SetTitle(Inventory:GetPhrase("ConCommand.Destroy.Popup.Title", { item = item:GetName(slot) }))
    popup:SetText(Inventory:GetPhrase("ConCommand.Destroy.Popup.Desc", { item = item:GetName(slot) }))
    popup:SetAccept(Inventory:GetPhrase("ConCommand.Destroy.Popup.Yes"), function()
      inv:Set(id, nil)
      if (IsValid(self)) then
        self:SetItem(inv:Get(id))
      end

      local str = Inventory:GetPhrase("ConCommand.Destroy", { amount = amount, item = item:GetName(slot) })
      XeninUI:Notify(str, NOTIFY_ERROR, 4, XeninUI.Theme.Green)
      chat:AddText(Inventory.Config.PrefixCol, Inventory.Config.PrefixText .. " ", color_white, str)

      net.Start("Inventory.Destroy")
        net.WriteUInt(id, 10)
      net.SendToServer()
    end)
    popup:SetDecline(Inventory:GetPhrase("ConCommand.Destroy.Popup.No"), function() end)
    popup:MakePopup()
  end,
  [Inventory:GetPhrase("Inventory.Popup.Use")] = function(self, id, btn)
    local ply = LocalPlayer()
    local inv = ply:Inventory()
    local slot = inv:Get(id)
    if (!slot) then return end
    local item = Inventory:GetItem(slot.dropEnt)
    if (!item) then return end

    local canEquip, reason = item.Actions.Use.Pre(item, ply, slot, self)
    if (!canEquip) then
      XeninUI:Notify(reason, NOTIFY_ERROR, 4, XeninUI.Theme.Red)
      chat:AddText(XeninUI.Theme.Red, Inventory.Config.PrefixText .. " ", color_white, reason)

      return
    end

    if (inv:ReduceAmount(id, 1)) then
      item.Actions.Use:Action(item, ply, slot.ent, slot, self)
    end
    
    net.Start("Inventory.Use")
      net.WriteUInt(id, 10)
    net.SendToServer()
    
    self:SetItem(inv:Get(id))
  end,
  [Inventory:GetPhrase("Inventory.Popup.Drop Amount")] = function(self, id, btn)
    local ply = LocalPlayer()
    local inv = ply:Inventory()
    local slot = inv:Get(id)
    if (!slot) then return end
    local item = Inventory:GetItem(slot.dropEnt)
    if (!item) then return end
    local amount = slot.data.amount or slot.data.Amount or slot.amount

    local function err(msg)
      chat.AddText(Inventory.Config.PrefixCol, Inventory.Config.PrefixText .. " ", color_white, msg)
    end

    local popup = vgui.Create("Inventory.DropAmount")
    popup:SetSize(ScrW(), ScrH())
    popup:SetTitle(Inventory:GetPhrase("Inventory.Popup.Drop Amount"))
    popup.textentry.textentry:SetNumeric(true)
    popup.CheckFunction = function(pnl)
      local text = pnl.textentry:GetText()
      text = tonumber(text)
      if (!text) then err(Inventory:GetPhrase("Inventory.Popup.DropAmount.Error.Invalid")) return end
      if (text <= 0) then err(Inventory:GetPhrase("Inventory.Popup.DropAmount.Error.TooLow")) return end
      if (text > amount) then err(Inventory:GetPhrase("Inventory.Popup.DropAmount.Error.TooHigh")) return end

      return true
    end
    popup.PassedFunction = function(pnl)
      local text = pnl.textentry:GetText()
      text = tonumber(text)

      if (amount > slot.amount) then
        local newAmount = (slot.data.amount or slot.data.Amount) - text
        if (newAmount < 0) then return end

        slot.data.amount = slot.data.amount and newAmount
        slot.data.Amount = slot.data.Amount and newAmount

        net.Start("Inventory.DropAmount.Data")
          net.WriteUInt(id, 10)
          net.WriteUInt(text, 32)
        net.SendToServer()

        if (newAmount == 0) then
          inv:Set(id, nil)
        end
      else
        if (inv:ReduceAmount(id, text)) then
          net.Start("Inventory.DropAmount")
            net.WriteUInt(id, 10)
            net.WriteUInt(text, 32)
          net.SendToServer()
        end
      end

      pnl:Remove()
    end

    popup:MakePopup()
  end
}

local matGradient = Material("gui/gradient_down", "smooth")

function PANEL:Init()
  self:SetText("")
  self:SetBackgroundColor(Inventory.Config.SlotNameColor or XeninUI.Theme.Primary)
  self:SetNameColor(XeninUI.Theme.Primary)
  self:SetNameTextColor(Color(180, 180, 180))
  self:SetName(false)
  self:SetAmount(0)

  self.isInventoryField = true
  
  self.model = self:Add("DModelPanel")
  self.model:SetMouseInputEnabled(false)
  self.model:SetVisible(false)
  self.model.LayoutEntity = function() end
  local oldPaint = self.model.Paint
  self.model.Paint = function(pnl, w, h)
    oldPaint(pnl, w, h)

    local amount
    if (self.info and self.info.data) then
      amount = self.info.data.ammo or self.info.data.repair or self.info.data.health or self:GetAmount()
    else
      amount = self:GetAmount()
    end

    local visualAmount = self.item:GetVisualAmount(self.info) or 0
    if (amount > 1 or visualAmount > 1) then
      local bgColor = Color(0, 0, 0, 205)
      local max = 100
      if (self.cat) then
        bgColor = Inventory.Config.Categories[self.cat].amountBackgroundColor or bgColor
        max = Inventory.Config.Categories[self.cat].maxStack or max
      end

      local str = Inventory:GetPhrase("Inventory.Field.Amount", { amount = (visualAmount and (visualAmount == 0 and amount or visualAmount) or amount) or amount })
      if (self:GetAmount() >= max and max != 1) then
        str = Inventory:GetPhrase("Inventory.Field.MaxAmount", { amount = max })
      end
      surface.SetFont("Inventory.Field.Amount")
      local tw, th = surface.GetTextSize(str)
      local x = w - 10 - tw - 2
      local y = 10

      local bgColor = Color(0, 0, 0, 165)
      if (self.cat) then
        bgColor = Inventory.Config.Categories[self.cat].amountBackgroundColor or bgColor
      end

      draw.RoundedBox(6, x, y - 1, tw + 5, th + 1, bgColor)
      draw.SimpleText(str, "Inventory.Field.Amount", w - 9, 9, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    end
  end

  self.overlayAlpha = 0
end

function PANEL:DoClick()
  -- If it's bank, no option to do anything
  if (self:GetIsBank() and !self:GetIsAdmin()) then return end
  -- If not visible it's probably an empty field
  if (!self.model:IsVisible()) then return end

  if (self:GetIsAdmin()) then
    local x, y = gui.MouseX(), gui.MouseY()
    self.popup = XeninUI:DropdownPopup(x, y)
    local panel = self.popup
    panel:AddChoice("Remove Item", function(btn)
      local ply = player.GetBySteamID64(self:GetIsAdmin())
      local id = self:GetID()
      if (IsValid(ply)) then
        local inv = ply:Inventory()
        inv:Set(id, nil)
      end

      self:SetItem(nil)

      net.Start("Inventory.Admin.RemoveItem")
        net.WriteString(self:GetIsAdmin())
        net.WriteUInt(id, 16)
        net.WriteBool(self:GetIsBank())
      net.SendToServer()
    end)

    return
  end

  local func = function(btn)
    self.Popup[btn:GetText()](self, self:GetID(), btn)
  end

  local x, y = gui.MouseX(), gui.MouseY()
  self.popup = XeninUI:DropdownPopup(x, y)
  local panel = self.popup

  local item = Inventory:GetItem(self.dropEnt)
  local sorted = {}
  for i, v in pairs(item.Actions) do
    table.insert(sorted, {
      name = i,
      sortOrder = v.SortOrder
    })
  end
  table.sort(sorted, function(a, b)
    return a.sortOrder < b.sortOrder
  end)

  for i, v in ipairs(sorted) do
    if (v.name == Inventory:GetPhrase("Inventory.Popup.DropAll")) then 
      self.info = self.info or {}
      self.info.data = self.info.data or {}
      local amount = self.info.data.amount or self.info.data.Amount or self:GetAmount() or 0

      if (amount > 1) then
        panel:AddChoice(Inventory:GetPhrase("Inventory.Popup." .. v.name), func)
      end

      continue
    end
    
    panel:AddChoice(Inventory:GetPhrase("Inventory.Popup." .. v.name), func)
  end
  panel:AddChoice(Inventory:GetPhrase("Inventory.Popup.Destroy"), func, nil, nil, matDestroy)
end

function PANEL:OnRemove()
  if (IsValid(self.popup)) then
    self.popup:Remove()
  end

  if (IsValid(self.hover)) then
    self.hover:Remove()
  end
end

function PANEL:PaintFunction(pnl, w, h)
  local amount
  if (self.info and self.info.data) then
    amount = self.info.data.ammo or self.info.data.repair or self.info.data.health or self:GetAmount()
  else
    amount = self:GetAmount()
  end

  local visualAmount = self.item:GetVisualAmount(self.info) or 0
  if ((amount > 1 or visualAmount > 1) and self.displayAmount) then
    local bgColor = Color(0, 0, 0, 205)
    local max = 100
    if (self.cat) then
      bgColor = Inventory.Config.Categories[self.cat].amountBackgroundColor or bgColor
      max = Inventory.Config.Categories[self.cat].maxStack or max
    end

    local str = Inventory:GetPhrase("Inventory.Field.Amount", { amount = (visualAmount and (visualAmount == 0 and amount or visualAmount) or amount) or amount })
    if (self:GetAmount() >= max and max != 1) then
      str = Inventory:GetPhrase("Inventory.Field.MaxAmount", { amount = max })
    end
    surface.SetFont("Inventory.Field.Amount")
    local tw, th = surface.GetTextSize(str)
    local x = w - 10 - tw - 2
    local y = 10

    local bgColor = Color(0, 0, 0, 165)
    if (self.cat) then
      bgColor = Inventory.Config.Categories[self.cat].amountBackgroundColor or bgColor
    end

    draw.RoundedBox(6, x, y - 1, tw + 5, th + 1, bgColor)
    draw.SimpleText(str, "Inventory.Field.Amount", w - 9, 9, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
  end
end

function PANEL:RecreateModelPanel(image)
  self.model:Remove()
  
  if (image) then
    self.model = self:Add("DPanel")
    self.model:SetMouseInputEnabled(false)
    self.model:SetVisible(false)
    self.model.SetImage = function(pnl, img)
      pnl.mat = Material(img)
    end
    self.model.margin = 10
    self.model.Paint = function(pnl, w, h)
      local margin = pnl.margin
      surface.SetDrawColor(color_white)
      surface.SetMaterial(pnl.mat)
      surface.DrawTexturedRect(margin, margin, w - (margin * 2), h - (margin * 2))

      self:PaintFunction(pnl, w, h)
    end
  else
    self.model = self:Add("DModelPanel")
    self.model:SetMouseInputEnabled(false)
    self.model:SetVisible(false)
    self.model.LayoutEntity = function() end
    local oldPaint = self.model.Paint
    self.model.Paint = function(pnl, w, h)
      oldPaint(pnl, w, h)

      self:PaintFunction(pnl, w, h)
    end
  end
end

function PANEL:SetItem(tbl)
  tbl = tbl or {}
  local ply = LocalPlayer()
  local rarity = Inventory:GetRarity(tbl)
  local cat = Inventory.Config.Categories[rarity]
  -- If it doesn't exist, we just default it to 1 (worst)
  if (!cat and tbl.model) then
    rarity = 1
    cat = Inventory.Config.Categories[rarity]
  end
  self.cat = rarity
  local item = Inventory:GetItem(tbl.dropEnt)
  local name = item and item:GetName(tbl)
  local model = item and item:GetModel(tbl)
  local displayAmount = item and !item.DontDisplayAmount
  if (displayAmount == nil) then displayAmount = true end

  self:SetName(tbl.ent and name or false)
  self:SetNameColor(tbl.name and Color(0, 0, 0, 200) or Inventory.Config.SlotNameColor or XeninUI.Theme.Primary)
  self:SetNameTextColor(Inventory.Config.SlotNameTextColor or Color(225, 225, 225))
  self:SetBackgroundColor(model and cat.color or Inventory.Config.SlotColor or XeninUI.Theme.Primary)
  self:SetAmount(tbl.amount or 0)
  self.item = item
  self.ent = tbl.ent
  self.dropEnt = tbl.dropEnt
  self.info = tbl
  self.displayAmount = displayAmount

  if (model) then
    local isMat = model:find(".png")
    local isMdlPnl = IsValid(self.model) and self.model:GetName() == "DModelPanel"
    
    if (isMat and isMdlPnl) then
      self:RecreateModelPanel(true)
      self.model:SetImage(model)
      self.model:SetVisible(true)
    elseif (!isMat and isMdlPnl) then
      self:RecreateModelPanel()

      self.model:SetModel(model)
      self.model:SetVisible(true)
      if (IsValid(self.model.Entity)) then
        local mn, mx = self.model.Entity:GetRenderBounds()
        local size = 0
        size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
        size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
        size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
        self.model:SetFOV(item.FOV or 33)
        self.model:SetCamPos(Vector(size, size + 30, size - 30))
        self.model:SetLookAt((mn + mx) * 0.5)


        if (SH_EASYSKINS and Inventory.Config.EasySkinsEnabled and tbl.dropEnt == "spawned_weapon") then
          local skinTbl = SH_EASYSKINS.GetEnabledPurchasedSkinByClass(ply, tbl.ent)

          if (skinTbl) then 
            local skin = SH_EASYSKINS.GetSkin(skinTbl.skinID)
            
            if (skin) then
              SH_EASYSKINS.ApplySkinToModel(self.model.Entity, skin.material.path)
            end
          end
        end
      end
    end
  else
    self.model:SetVisible(false)
  end
  
  self:InvalidateLayout()
end

function PANEL:SetItemByID(id, bank)
  local inv = LocalPlayer():Inventory()
  local tbl = bank and inv:GetBank() or inv:GetInventory()

  self:SetItem(tbl[id])
  self:SetID(id)
  self:SetDroppable(tbl[id])
end

function PANEL:OnStartDragging()
  self:OnCursorEntered()
  
  if (IsValid(self.hover)) then
    self.hover:Remove()
  end
end

function PANEL:OnStopDragging()
  if (!self:IsHovered()) then
    self:OnCursorExited()
  end

  if (IsValid(self.hover)) then
    self.hover:Remove()
  end
end

function PANEL:SetDroppable(bool, bank)
  self.m_DragSlot = nil

  if (bool and self.model:IsVisible()) then
    self:Droppable("Inventory.Field")
  end

  self:Receiver("Inventory.Field", function(self, tbl, dropped)
    if (!dropped) then return end
    local droppedPnl = tbl[1]
    if (!droppedPnl) then return end

    local tempIsBank = droppedPnl:GetIsBank()
    local temp2IsBank = self:GetIsBank()
    local temp = droppedPnl:GetID()
    local temp2 = self:GetID()
  
    local inv = LocalPlayer():Inventory()
    if (tempIsBank and temp2IsBank) then
      inv:Swap(temp, temp2, true)

      droppedPnl:SetItemByID(temp, true)
      self:SetItemByID(temp2, true)
    elseif (tempIsBank and !temp2IsBank) then
      inv:SwapBank(temp2, temp)

      droppedPnl:SetItemByID(temp, true)
      self:SetItemByID(temp2)
    elseif (!tempIsBank and temp2IsBank) then
      inv:SwapBank(temp, temp2)

      droppedPnl:SetItemByID(temp)
      self:SetItemByID(temp2, true)
    elseif (!temp2IsBank and !tempIsBank) then
      inv:Swap(temp, temp2)

      droppedPnl:SetItemByID(temp)
      self:SetItemByID(temp2)
    end
  end)
  --[[
  self:Receiver("Suit.Piece", function(self, tbl, dropped)
    if (!dropped) then return end
    local droppedPnl = tbl[1]
    if (!droppedPnl) then return end
    local info = droppedPnl.info
    if (!info) then return end
    if (info.dropEnt != "suit_piece") then return end
    if (!info.data) then return end
    local data = info.data
    local stats = data.stats or {}
    local durability = data.durability or 0
    local itemType = data.itemType
    local index = data.index
    local cfg = Crafting.Suits.Config[itemType].Items[index]

    if (!cfg) then return end

    if (LocalPlayer():IsInCombat()) then
      XeninUI:Notify("You can't unequip suit pieces while in combat!", LocalPlayer(), 4, XeninUI.Theme.Red)

      return
    end

    data.rarity = cfg.Rarity

    net.Start("Crafting.Suits.Part.Dequip")
      net.WriteUInt(droppedPnl.info.data.itemType, 5)
      net.WriteUInt(self:GetID(), 8)
    net.SendToServer()

    local inv = LocalPlayer():Inventory()
    if (inv:Get(self:GetID())) then
      local temp = inv:Get(self:GetID())
      if (temp.dropEnt != "suit_piece") then return end
      if (temp.data.itemType != itemType) then return end

      inv:Set(self:GetID(), {
        id = self:GetID(),
        ent = "suit_piece",
        dropEnt = "suit_piece",
        model = cfg.Model,
        amount = 1,
        data = data
      })
      droppedPnl.info = temp
      LocalPlayer():Suit():SetPiece(temp.data.itemType, temp.data.index, temp.data.stats, temp.data.durability)
      droppedPnl:SetID(temp.data.itemType)
      self:SetItemByID(self:GetID())
    else
      droppedPnl.info = temp

      inv:Set(self:GetID(), {
        id = self:GetID(),
        ent = "suit_piece",
        dropEnt = "suit_piece",
        model = cfg.Model,
        amount = 1,
        data = data
      })
      self:SetItemByID(self:GetID())

      LocalPlayer():Suit():DeletePiece(itemType)
      droppedPnl:SetID(itemType)
    end
  end)
  --]]
end

function PANEL:PerformLayout(w, h)
  self.model:SetPos(1, 1)
  self.model:SetSize(w - 2, h - 2 - (self:GetName() and 24 or 0))
end

function PANEL:OnCursorEntered()
  self:Lerp("overlayAlpha", 140)
  if (!self.info) then return end

  self:CreateHover()
end

function PANEL:CreateHover()
  local item = Inventory:GetItem(self.info.dropEnt)
  if (!item) then return end
  if (!item.Hover) then return end

  local x, y = self:LocalToScreen(self:GetWide())

  self.hover = vgui.Create(item.Hover)
  self.hover:SetPos(x, y)
  self.hover:SetDrawOnTop(true)
  local oldThink = self.hover.Think or function() end
  self.hover.Think = function(pnl)
    oldThink(pnl)

    if (!self:IsHovered() and IsValid(pnl) or !IsValid(self)) then
      pnl:Remove()

      return
    end

    if (!IsValid(self)) then
      pnl:Remove()

      return
    end

    local w, h = pnl:GetSize()
    local x, y = pnl.x, pnl.y
    x = math.Clamp(x, 0, ScrW() - w)
    y = math.Clamp(y, 0, ScrH() - h)

    pnl:SetPos(x, y)
  end

  self.hover:SetInfo(self.info)
end

function PANEL:OnCursorExited()
  self:Lerp("overlayAlpha", 0)

  if (IsValid(self.hover)) then
    self.hover:Remove()
  end
end

function PANEL:Paint(w, h)
  if (self:GetName()) then
    -- The h - 1 fixes an rounding error with DrawRoundedBox which causes it to overlap
    XeninUI:Mask(function()
      XeninUI:DrawRoundedBox(6, 0, 0, w, h - 1, self:GetBackgroundColor())
    end, function()
      surface.SetDrawColor(self:GetBackgroundColor())
      surface.SetMaterial(matGradient)
      surface.DrawTexturedRect(0, 0, w, h + 6)
    end)
    
    draw.RoundedBoxEx(6, 0, h - 24, w, 24, self:GetNameColor(), false, false, true, true)
    local font = "Inventory.Field.Name"
    surface.SetFont(font)
    local tw, th = surface.GetTextSize(self:GetName())
    if (tw >= w) then
      surface.SetFont("Inventory.Field.Name.Small")
      local tw, th = surface.GetTextSize(self:GetName())
      if (tw >= w) then
        font = "Inventory.Field.Name.Smallest"
      else
        font = "Inventory.Field.Name.Small"
      end
    end
    draw.SimpleText(self:GetName(), font, w / 2, h - 24 / 2, self:GetNameTextColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  else
    draw.RoundedBox(6, 0, 0, w, h, self:GetBackgroundColor())
  end

  if (self.overlayAlpha > 0.1) then
    draw.RoundedBox(6, 0, 0, w, h, Color(0, 0, 0, self.overlayAlpha))
  end
end

vgui.Register("Inventory.Field", PANEL, "DButton")