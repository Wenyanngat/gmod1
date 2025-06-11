--https://vk.com/gmodleak

-- YOU DON'T NEED TO TOUCH THIS IF YOU DON'T KNOW WHAT IT IS
RARITY_UNCOMMON = 1
RARITY_COMMON = 2
RARITY_RARE = 3
RARITY_EPIC = 4
RARITY_LEGENDARY = 5

Inventory.Config = Inventory.Config or {}
function Inventory.Config:AddRarity(entClass, rarity)
  self.Rarities[entClass] = rarity
end
Inventory.Config.Items = Inventory.Config.Items or {}
Inventory.Config.Rarities = {}
-- TOUCH BELOW HERE

-- Should you be able to use ALT + *key* to pick up items?
Inventory.Config.PickUpWithALT = true

-- What key should be used in combination with alt?
-- https://wiki.garrysmod.com/page/Enums/BUTTON_CODE
Inventory.Config.AltKey = KEY_E
-- Type the letter that ^ actually is.
Inventory.Config.AltKeyStr = "E"

-- What key should you open the inventory menu with?
-- https://wiki.garrysmod.com/page/Enums/BUTTON_CODE
-- If you want to disable this, set it to false instead of a key!
Inventory.Config.InventoryKey = KEY_I

-- Should users spawn with an inventory weapon allowing them to pick up items with the weapon?
Inventory.Config.SpawnWithInventorySWEP = true

-- What color should the standard chat messages prefix have?
Inventory.Config.PrefixCol = Color(46, 204, 113)
-- What should the prefix say?
Inventory.Config.PrefixText = "[INVENTORY]"

-- What language?
-- By default this only supports English, but you can add your own language
Inventory.Config.Language = "English"

-- The NPC's model?
Inventory.Config.NPCModel = "models/humans/group02/female_01.mdl"
-- The outline color of the NPC's overhead HUD.
Inventory.Config.NPCColor = Color(201, 176, 15)
-- The text on the NPC's overhead HUD
Inventory.Config.NPCText = "Bank"
-- The icon for the NPC's overhead HUD
Inventory.Config.NPCIcon = Material("xenin/inventory/icon.png", "smooth")

Inventory.Config.EasySkinsEnabled = true

-- How many items should there be in a row in the bank?
Inventory.Config.BankItemsPerRow = 6
-- Slots for the bank.
-- Free is for everyone that isn't in the paid list.
-- The paid list works by doing ["rank"] = amount_of_slots
Inventory.Config.BankSlots = {
  Free = 16,
  Paid = {
    ["admin"] = 30,
    ["superadmin"] = 45
  }
}

-- Same as above but for the inventory itself, not the bank
Inventory.Config.ItemsPerRow = 8
-- Same as above but for the inventory itself, not the bank
Inventory.Config.Slots = {
  Free = 24,
  Paid = {
    ["admin"] = 30,
    ["superadmin"] = 36
  }
}

Inventory.Config.Admins = {
  ["superadmin"] = true
}

-- The categories are defined here
-- [number] is the number the category will be known as.
-- name is obviously the name.
-- color represents the color used to visualise the category
-- maxStack is how many items can max be stacked if it's that category
-- amountBackgroundColor is an optional thing! Use this for colors where seeing the default amount text background color might be hard.
Inventory.Config.Categories = {
  [1] = { name = "Common", color = Color(125, 125, 125), maxStack = 50 }, -- grey
  [2] = { name = "Uncommon", color = Color(46, 204, 113), maxStack = 30 }, -- green
  [3] = { name = "Rare", color = Color(41, 128, 185), maxStack = 20 }, -- blue
  [4] = { name = "Epic", color = Color(142, 68, 173), maxStack = 10 }, -- purple
  [5] = { name = "Legendary", color = Color(251, 197, 49), maxStack = 5, amountBackgroundColor = Color(0, 0, 0, 225) }, -- orange
}

-- Should users be able to sort by rarity quality?
Inventory.Config.EnableRaritySorting = true

-- **WARNING**
-- This is a whitelist for entities that should be allowed to pick up that DOES NOT have a template in configuration/items/
-- I can not be 100% certain that the entity will save and behave exactly as it should but it will try to find all the data it needs to save!
-- Please use this for generic things only, such as some weed seeds or something, not DarkRP money printers!!
-- If an item doesn't work you should either get your developer to make a template in configuration/items/ folder or create a support ticket!
-- Also please be aware that the way it saves data is inefficient the first time it saves that kind of entity after a restart.
--
-- The syntax is simple, just do ["ent_class_name"] = true,
-- Example:
-- ["bank_npc"] = true,
Inventory.Config.WhitelistEntities = {
  -- ["bank_npc"] = true,
}

-- A few theme options
-- Slot background
Inventory.Config.SlotColor = XeninUI.Theme.Navbar
-- The name bar background
Inventory.Config.SlotNameColor = XeninUI.Theme.Primary
-- The name bar's text
Inventory.Config.SlotNameTextColor = Color(225, 225, 225)


-- Input in pixels. They will automatically fit on any resolution, even if the resolution are lower than these numbers
Inventory.Config.ContextMenuSize = {
  Width = 1000,
  Height = 534
}

-- How many items on each row in the C menu?
Inventory.Config.ContextMenuColumns = 6

-- If you want a specific entity class to be a rarity.
-- Thanks to Rexxor for the default config
Inventory.Config:AddRarity("weapon_ak472", RARITY_LEGENDARY)
Inventory.Config:AddRarity("weapon_m42", RARITY_UNCOMMON)
Inventory.Config:AddRarity("weapon_mp52", RARITY_EPIC)
Inventory.Config:AddRarity("m9k_spas12", RARITY_LEGENDARY)
Inventory.Config:AddRarity("m9k_dbarrel", RARITY_LEGENDARY)
Inventory.Config:AddRarity("m9k_usas", RARITY_EPIC)
Inventory.Config:AddRarity("m9k_mossberg590", RARITY_UNCOMMON)
Inventory.Config:AddRarity("m9k_jackhammer", RARITY_RARE)
Inventory.Config:AddRarity("m9k_barret_m82", RARITY_LEGENDARY)
Inventory.Config:AddRarity("m9k_m24", RARITY_EPIC)
Inventory.Config:AddRarity("m9k_svu", RARITY_EPIC)
Inventory.Config:AddRarity("m9k_dragunov", RARITY_LEGENDARY)
Inventory.Config:AddRarity("m9k_remington7615p", RARITY_RARE)
Inventory.Config:AddRarity("m9k_aw50", RARITY_LEGENDARY)
Inventory.Config:AddRarity("m9k_sl8", RARITY_RARE)
Inventory.Config:AddRarity("m9k_intervention", RARITY_EPIC)
Inventory.Config:AddRarity("m9k_contender", RARITY_RARE)
Inventory.Config:AddRarity("m9k_psg1", RARITY_RARE)
Inventory.Config:AddRarity("m9k_ragingbull", RARITY_RARE)
Inventory.Config:AddRarity("m9k_deagle", RARITY_RARE)
Inventory.Config:AddRarity("m9k_ragingbull", RARITY_RARE)
Inventory.Config:AddRarity("m9k_usp", RARITY_RARE)
Inventory.Config:AddRarity("m9k_ares_shrike", RARITY_LEGENDARY)
Inventory.Config:AddRarity("m9k_fg42", RARITY_LEGENDARY)
Inventory.Config:AddRarity("m9k_m1918bar", RARITY_LEGENDARY)
Inventory.Config:AddRarity("m9k_m249lmg", RARITY_LEGENDARY)
Inventory.Config:AddRarity("m9k_m60", RARITY_LEGENDARY)
Inventory.Config:AddRarity("m9k_winchester73", RARITY_UNCOMMON)
Inventory.Config:AddRarity("m9k_amd65", RARITY_RARE)
Inventory.Config:AddRarity("m9k_m416", RARITY_EPIC)
Inventory.Config:AddRarity("m9k_m14sp", RARITY_UNCOMMON)
Inventory.Config:AddRarity("m9k_vikhr", RARITY_UNCOMMON)
Inventory.Config:AddRarity("m9k_g36", RARITY_UNCOMMON)
Inventory.Config:AddRarity("m9k_l85", RARITY_EPIC)
Inventory.Config:AddRarity("m9k_val", RARITY_LEGENDARY)
Inventory.Config:AddRarity("m9k_m60", RARITY_RARE)
Inventory.Config:AddRarity("m9k_tar21", RARITY_UNCOMMON)
Inventory.Config:AddRarity("m9k_f2000", RARITY_UNCOMMON)
Inventory.Config:AddRarity("m9k_m4a1", RARITY_UNCOMMON)
Inventory.Config:AddRarity("m9k_machete", RARITY_EPIC)
Inventory.Config:AddRarity("m9k_harpoon", RARITY_RARE)
Inventory.Config:AddRarity("m9k_damascus", RARITY_LEGENDARY)
Inventory.Config:AddRarity("m9k_m61_frag", RARITY_LEGENDARY)
Inventory.Config:AddRarity("m9k_honeybadger", RARITY_UNCOMMON)
Inventory.Config:AddRarity("m9k_mp7", RARITY_UNCOMMON)
Inventory.Config:AddRarity("m9k_bizonp19", RARITY_UNCOMMON)
Inventory.Config:AddRarity("m9k_mp5sd", RARITY_RARE)
Inventory.Config:AddRarity("m9k_mp40", RARITY_EPIC)
Inventory.Config:AddRarity("m9k_thompson", RARITY_LEGENDARY)
Inventory.Config:AddRarity("m9k_kac_pdw", RARITY_RARE)
Inventory.Config:AddRarity("m9k_tec9", RARITY_RARE)
Inventory.Config:AddRarity("m9k_usc", RARITY_UNCOMMON)


-- Chat commands
-- Code to holster weapons
local funcHolster = function(ply)
  if (!IsValid(ply)) then return end
  if (!ply:IsPlayer()) then return end
  if (!ply:Alive()) then return end
  local activeWep = ply:GetActiveWeapon()
  if (!IsValid(activeWep)) then return end
  local inv = ply:Inventory()
  local amt = table.Count(inv:GetInventory())
  local slots = inv:GetSlots()
  if (amt >= slots) then
    XeninUI:Notify(ply, Inventory:GetPhrase("ChatCommand.Holster.Unable"), 1, 4, XeninUI.Theme.Red)

    return
  end

  ply:dropDRPWeapon(activeWep, function(wep)
    ply:Inventory():Pickup(wep)
  end, false)
end

local openMenu = function(ply)
  ply:ConCommand("inventory")
end
local openAdmin = function(ply)
  ply:ConCommand("inventory_admin")
end

Inventory.Config.ChatCommands = {
  ["/holster"] = funcHolster,
  ["/holsterwep"] = funcHolster,
  ["/gunholster"] = funcHolster,
  ["/invholster"] = funcHolster,
  ["/drop"] = function(ply)
    if (!IsValid(ply)) then return end
    if (!ply:IsPlayer()) then return end
    if (!ply:Alive()) then return end
    local activeWep = ply:GetActiveWeapon()
    if (!IsValid(activeWep)) then return end
    
    ply:dropDRPWeapon(activeWep)
  end,
  ["/inventory"] = openMenu,
  ["!inventory"] = openMenu,
  ["/inv"] = openMenu,
  ["!inv"] = openMenu,
  ["/invadmin"] = openAdmin,
  ["!invadmin"] = openAdmin,
  ["/inventoryadmin"] = openAdmin,
  ["!inventoryadmin"] = openAdmin
}