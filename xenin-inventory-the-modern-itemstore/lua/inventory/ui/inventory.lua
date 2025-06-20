--https://vk.com/gmodleak

local PANEL = {}

XeninUI:CreateFont("Inventory.Inventory.Filter", 18)
XeninUI:CreateFont("Inventory.Inventory.Helper", 18)

function PANEL:Init()
  local ply = LocalPlayer()

  self.inventory = self:GetInventory()

  self.search = self:Add("XeninUI.TextEntry")
  self.search:SetPlaceholder(Inventory:GetPhrase("Inventory.Inventory.Search"))
  self.search:SetIcon(XeninUI.Materials.Search)
  self.search.textentry:SetUpdateOnType(true)
  self.search.textentry.OnValueChange = function(pnl, text)
    self:Sort()
  end

  self.sort = self:Add("DButton")
  self.sort:SetText(Inventory:GetPhrase("Inventory.Inventory.Unsorted"))
  self.sort:SetFont("Inventory.Inventory.Filter")
  self.sort:SetTextColor(Color(190, 190, 190))
  self.sort:SetContentAlignment(5)
  self.sort.Paint = function(pnl, w, h)
    draw.RoundedBox(6, 0, 0, w, h, XeninUI.Theme.Navbar)
  end
  self.sort.SortChanged = function(pnl, text)
    pnl:SetText(text)
    self:Sort()
  end
  self.sort.DoClick = function(pnl)
    local func = function(btn)
      pnl:SortChanged(btn:GetText())
    end
    local hoverColor = Color(75, 75, 75)

    local panel = XeninUI:DropdownPopup(pnl:LocalToScreen(-12, -12 + pnl:GetTall()))
    panel:SetBackgroundColor(XeninUI.Theme.Navbar)
    panel:SetTextColor(Color(185, 185, 185))
    panel:AddChoice(Inventory:GetPhrase("Inventory.Inventory.Unsorted"), func, nil, hoverColor)
    panel:AddChoice(Inventory:GetPhrase("Inventory.Inventory.Alphabetically"), func, nil, hoverColor)
    if (Inventory.Config.EnableRaritySorting) then
      panel:AddChoice(Inventory:GetPhrase("Inventory.Inventory.WorstToBest"), func, nil, hoverColor)
      panel:AddChoice(Inventory:GetPhrase("Inventory.Inventory.BestToWorst"), func, nil, hoverColor)
    end
  end

  self.cats = {}
  self.categories = self:GetCategories()

  -- Reverse it because it's rendered right to left, but we display left to right
  local index = #self.categories
  for i, v in ipairs(self.categories) do
    self.cats[index] = vgui.Create("DButton", self)
    self.cats[index]:SetText("")
    self.cats[index].name = v.name
    self.cats[index].color = v.color
    self.cats[index].enabled = true
    self.cats[index].realIndex = i
    self.cats[index].alpha = 0
    self.cats[index].text = Color(220, 220, 220)
    self.cats[index].Paint = function(pnl, w, h)
      XeninUI:DrawCircle(h / 2, h / 2, h / 2, 90, pnl.color)
      XeninUI:DrawCircle(h / 2, h / 2, h / 2 - 1, 90, ColorAlpha(XeninUI.Theme.Background, pnl.alpha))

      draw.SimpleText(v.name, "Inventory.Inventory.Helper", h + 8, h / 2, pnl.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    self.cats[index].OnCursorEntered = function(pnl)
      pnl:LerpColor("text", color_white)
    end
    self.cats[index].OnCursorExited = function(pnl)
      pnl:LerpColor("text", Color(220, 220, 220))
    end
    self.cats[index].Disable = function(pnl)
      pnl:Lerp("alpha", 255)
      pnl.enabled = false
    end
    self.cats[index].Enable = function(pnl)
      pnl:LerpColor("text", Color(220, 220, 220))
      pnl:Lerp("alpha", 0)
      pnl.enabled = true
    end
    self.cats[index].DoClick = function(pnl)
      if (pnl.enabled) then
        pnl:Disable()
      else
        pnl:Enable()
      end

      self:Sort()
    end

    index = index - 1
  end

  self.slots = self:Add("Inventory.Slots")

  self:Sort()
end

function PANEL:Sort()
  local sorted, cats = self:SortByCategories(self.inventory)
  sorted = self:SortByFilter(sorted)
  sorted = self:SortByName(sorted)

  self.slots:CreateFields(sorted, 
    self.sort:GetText() == Inventory:GetPhrase("Inventory.Inventory.Unsorted") and 
    #self.search:GetText() == 0 and
    table.Count(cats) == #self.cats)
  self:InvalidateLayout()
end

function PANEL:SortByCategories(tbl)
  local temp = {}
  local enabledCategories = {}

  for i, v in pairs(self.cats) do
    if (v.enabled) then enabledCategories[v.realIndex] = true end
  end

  if (self.sort:GetText() != Inventory:GetPhrase("Inventory.Inventory.Unsorted")) then
    for i, v in pairs(tbl) do
      local rarity = Inventory:GetRarity(v)
      if (!enabledCategories[rarity]) then continue end

      table.insert(temp, v)
    end
  else
    for i, v in pairs(tbl) do
      local rarity = Inventory:GetRarity(v)
      if (!enabledCategories[rarity]) then continue end

      temp[i] = v
    end
  end

  return temp, enabledCategories
end

function PANEL:SortByFilter(tbl)
  local filteredText = self.sort:GetText()

  if (filteredText == Inventory:GetPhrase("Inventory.Inventory.Unsorted")) then
    return tbl
  elseif (filteredText == Inventory:GetPhrase("Inventory.Inventory.WorstToBest")) then
    table.sort(tbl, function(a, b)
      return Inventory:GetRarity(a) < Inventory:GetRarity(b)
    end)
    
    return tbl
  elseif (filteredText == Inventory:GetPhrase("Inventory.Inventory.BestToWorst")) then
    table.sort(tbl, function(a, b)
      return Inventory:GetRarity(a) > Inventory:GetRarity(b)
    end)
    
    return tbl
  elseif (filteredText == Inventory:GetPhrase("Inventory.Inventory.Alphabetically")) then
    table.sort(tbl, function(a, b)
      local aName = Inventory:GetItem(a.dropEnt):GetName(a)
      local bName = Inventory:GetItem(b.dropEnt):GetName(b)

      return aName < bName
    end)

    return tbl
  end
end

function PANEL:SortByName(tbl)
  local temp = {}
  local name = self.search:GetText():lower()

  if (#name > 0) then
    for i, v in pairs(tbl) do
      local entName = Inventory:GetItem(v.dropEnt):GetName(v)

      if (entName:lower():find(name)) then
        table.insert(temp, v)
      end
    end
    
    return temp
  else
    return tbl
  end
end

function PANEL:GetCategories()
  return Inventory.Config.Categories
end

function PANEL:GetSlots()
  return Inventory.Config.Slots.Free
end

function PANEL:GetInventory()
  return LocalPlayer():Inventory():GetInventory()
end

function PANEL:PerformLayout(w, h)
  self.search:SetSize(200, 32)
  self.search:SetPos(16, 16)

  self.sort:SizeToContentsX(32)
  self.sort:SetTall(32)
  self.sort:SetPos(16 + self.search:GetWide() + 8, 16)

  self.slots:SetPos(16, 64)
  self.slots:SetSize(w - 32, h - self.slots.y - 16)

  local x = w - 0
  local y = 16
  surface.SetFont("Inventory.Inventory.Helper")
  for i, v in ipairs(self.cats) do
    local tw = surface.GetTextSize(v.name)
    v:SetTall(24)
    v:SetWide(v:GetTall() + 16 + tw)
    v:SetPos(x - 16 - v:GetWide(), y + 4)

    x = x - 12 - v:GetWide()
  end
end

vgui.Register("Inventory.Inventory", PANEL)

XeninUI:CreateFont("Inventory.Pickup", 16)

hook.Add("HUDPaint", "Inventory.Pickup", function()
  local ply = LocalPlayer()
  ply.InventoryCache = ply.InventoryCache or { alpha = 0 }
  local tr = util.TraceLine({
    start = ply:EyePos(),
    endpos = ply:EyePos() + ply:EyeAngles():Forward() * 100,
    filter = ply
  })

  local ent = tr.Entity
  if (IsValid(ent) and (Inventory.Config.Items[ent:GetClass()] or Inventory.Config.WhitelistEntities[ent:GetClass()]) and !(ent.GetIgnoreInventory and ent:GetIgnoreInventory())) then
    local tbl = Inventory.Config.Items[ent:GetClass()] or (Inventory.Config.WhitelistEntities[ent:GetClass()] and Inventory.Config.Items["base_entity"])
    ply.InventoryCache.alpha = ply.InventoryCache.alpha + (1 - ply.InventoryCache.alpha) * 20 * FrameTime()

    local lastEnt = ply.InventoryCache.ent
    local name = ent.GetDisplayName and ent:GetDisplayName()
      or ((ent.GetWeaponClass and weapons.Get(ent:GetWeaponClass()) and weapons.Get(ent:GetWeaponClass()).PrintName))
      or tbl:GetName(ent) or "UNKNOWN NAME"

    if (lastEnt != ent) then
      local rarity = (ent.GetRarity and ent:GetRarity()) or (tbl.GetRarity and tbl:GetRarity(ent)) or Inventory:GetRarity(ent) or 1
      local col = Inventory.Config.Categories[rarity] and Inventory.Config.Categories[rarity].color or Inventory.Config.Categories[1].color
      local phrase = Inventory:GetPhrase("Inventory.Pickup.Markup", {
        font = "<font=Inventory.Pickup>",
        color = "<color=230, 230, 230>",
        rarityColor = "<color=" .. col.r .. ", " .. col.g ..  ", " .. col.b .. ">",
        name = isstring(name) and name or ("UNKNOWN DATA TYPE? " .. tostring(name)),
        ["/color"] = "</color>",
        ["/font"] = "</font>",
        key = Inventory.Config.AltKeyStr
      })
      ply.InventoryCache.markup = markup.Parse(phrase)
      /*
      ply.InventoryCache.markup = markup.Parse(
        [[<font=Inventory.Pickup><color=230,230,230>Press </color><color=]] 
        .. col.r .. "," 
        .. col.g 
        .. "," 
        .. col.b 
        .. [[>Alt + E</color><color=230,230,230> to add ]] 
        .. name
        .. [[ to your inventory</color></font>]])
      */
      ply.InventoryCache.ent = ent
    end
  
    local str = Inventory:GetPhrase("Inventory.Pickup", {
      key = Inventory.Config.AltKeyStr, 
      name = isstring(name) and name or ("UNKNOWN DATA TYPE? " .. tostring(name)),
    })--"Press Alt + E to add " .. name .. " to your inventory"
    surface.SetFont("Inventory.Pickup")
    local tw, th = surface.GetTextSize(str)
    local w = tw + 32
    local h = th + 16
    local x = ScrW() / 2 - w / 2
    local y = ScrH() / 2 - h / 2 + (ScrH() * 0.2)
    local alpha = ply.InventoryCache.alpha * 255
    local rarity = (ent.GetRarity and ent:GetRarity()) or (tbl.GetRarity and tbl:GetRarity(ent)) or Inventory:GetRarity(ent) or 1
    local col = Inventory.Config.Categories[rarity] and Inventory.Config.Categories[rarity].color or Inventory.Config.Categories[1].color

    XeninUI:DrawRoundedBox((h - 4) / 2, x + 2, y + 2, w - 4, h - 4, ColorAlpha(XeninUI.Theme.Primary, alpha))
    XeninUI:MaskInverse(function()
      XeninUI:DrawRoundedBox((h - 4) / 2, x + 2, y + 2, w - 4, h - 4, XeninUI.Theme.Primary)
    end, function()
      XeninUI:DrawRoundedBox(h / 2, x, y, w, h, ColorAlpha(col, alpha))
    end)
    --draw.RoundedBox(h / 2, x, y, w, h, ColorAlpha(col, alpha))
    --draw.RoundedBox((h - 4) / 2, x + 2, y + 2 , w - 4, h - 4, ColorAlpha(XeninUI.Theme.Primary, alpha))

    ply.InventoryCache.markup:Draw(x + w / 2, y + h / 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  else
    ply.InventoryCache.alpha = ply.InventoryCache.alpha + (0 - ply.InventoryCache.alpha) * 20 * FrameTime()
  end
end)