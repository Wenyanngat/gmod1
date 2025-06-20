--https://vk.com/gmodleak

local PANEL = {}
AccessorFunc(PANEL, "m_columns", "Columns")

function PANEL:Init()
  self.scroll = self:Add("XeninUI.Scrollpanel.Wyvern")
  self.scroll:Dock(FILL)

  self:SetColumns(Inventory.Config.ItemsPerRow)

  self.layout = self.scroll:Add("DIconLayout")
  self.layout:Dock(FILL)
  self.layout:DockMargin(0, 0, 8, 0)
  self.layout:SetSpaceY(8)
  self.layout:SetSpaceX(8)
  self.layout.PerformLayout = function(pnl, w, h)
    local children = pnl:GetChildren()
    local count = self:GetColumns()
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

  self.fields = {}
end

function PANEL:Clear()
  self.layout:Clear()
  
  for i, v in pairs(self.fields) do
    v:Remove()
    self.fields[i] = nil
  end
end

function PANEL:CreateFields(tbl, droppable, slots, bank, func)
  local ply = LocalPlayer()
  local inventory = ply:Inventory()
  slots = slots or inventory:GetSlots()

  for i = 1, slots do
    local slot = self.fields[i]

    if (!slot) then
      self.fields[i] = self.layout:Add("Inventory.Field")
    end

    self.fields[i]:SetItem(tbl and tbl[i])
    self.fields[i]:SetDroppable(droppable, bank)
    self.fields[i]:SetID(tbl[i] and tbl[i].id or i)
    self.fields[i]:SetIsBank(bank)
    if (func) then
      func(self, self.fields[i])
    end
  end
end

vgui.Register("Inventory.Slots", PANEL)