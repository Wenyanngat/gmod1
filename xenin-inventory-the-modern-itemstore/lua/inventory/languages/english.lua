--https://vk.com/gmodleak

local LANG = {
	["ConCommand.Drop"] = "Dropped 1x :item:",
	["ConCommand.DropAll"] = "Dropped :amount:x :item:",
	["ConCommand.Destroy"] = "Destroyed :amount:x :item:",
	["ConCommand.Destroy.Popup.Title"] = "Destroy :item:",
	["ConCommand.Destroy.Popup.Desc"] = "Are you sure you want to destroy :item:?",
	["ConCommand.Destroy.Popup.Yes"] = "Yes",
	["ConCommand.Destroy.Popup.No"] = "No",

	["ChatCommand.Holster.Unable"] = "You are unable to holster this weapon due to your limited inventory space",

	["Bank.Title"] = "Inventory - Bank",
	["Inventory.Title"] = "Inventory",

	-- Tabs
	["Inventory.Tabs.Inventory"] = "INVENTORY",

	-- Actions
	["Inventory.Popup.Equip"] = "Equip",
	["Inventory.Popup.Drop"] = "Drop",
	["Inventory.Popup.Drop All"] = "Drop All",
	["Inventory.Popup.Destroy"] = "Destroy",
	["Inventory.Popup.Use"] = "Use",
	["Inventory.Popup.Drop Amount"] = "Drop Amount",
	
	["Inventory.Popup.DropAmount.Error.Invalid"] = "Invalid number?",
	["Inventory.Popup.DropAmount.Error.TooLow"] = "Too low of a number",
	["Inventory.Popup.DropAmount.Error.TooHigh"] = "You can't have drop that many because you don't have that many!",

	-- Shown in the inventory field
	["Inventory.Field.Amount"] = "x:amount:",
	["Inventory.Field.MaxAmount"] = "max x:amount:",

	["Inventory.Inventory.Search"] = "Search for an item",
	-- Refers to sorting
	["Inventory.Inventory.Unsorted"] = "Unsorted",
	["Inventory.Inventory.Alphabetically"] = "Alphabetically",
	["Inventory.Inventory.WorstToBest"] = "Worst to best",
	["Inventory.Inventory.BestToWorst"] = "Best to worst",
	-- Hover for shipments
	["Inventory.Shipment.Desc"] = ":amount: weapons left",

	["Inventory.Pickup.Markup"] = ":font::color:Press :/color::rarityColor:ALT + :key::/color: to add :name: to your inventory:/color::/font:",
	["Inventory.Pickup"] = "Press ALT + :key: to add :name: to your inventory",
	["Inventory.Money"] = ":money:",

	["Admin.Title"] = "Inventory Admin",
	["Admin.Tabs.Management"] = "MANAGEMENT",
	["Admin.NotAdmin"] = "You need to be an inventory admin to open this!",

	["Admin.Management.Loading"] = "Loading",
	["Admin.Management.Search"] = "Search by name/SteamID(64)",
	["Admin.Management.Searching"] = "Searching",
	["Admin.Management.Online"] = "Online",
	["Admin.Management.Offline"] = "Offline",
	["Admin.Management.OpenInventory"] = "Open Inventory",
	
	["Admin.Player.Title"] = "Player Inventory",
	["Admin.Player.Tabs.Inventory"] = "INVENTORY",
	["Admin.Player.Tabs.Bank"] = "BANK",
	["Admin.Player.Items"] = ":items: items",
	["Admin.Player.Clear.Inventory"] = "Clear Inventory",
	["Admin.Player.Clear.Bank"] = "Clear Bank",
	["Admin.Player.Clear.Popup.Text"] = "Are you sure you want to clear this players :type:? This cannot be undone!",
	["Admin.Player.Clear.Popup.Yes"] = "Yes, clear",
	["Admin.Player.Clear.Popup.No"] = "No",

	["Admin.Clear.Slot"] = "Your :type: slot number :id: have been cleared by an admin",
	["Admin.Clear"] = "Your :type: have been cleared by an admin",
}

Inventory:CreateLanguage("English", LANG)