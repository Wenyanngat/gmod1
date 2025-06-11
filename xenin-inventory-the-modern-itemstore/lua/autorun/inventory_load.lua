--https://vk.com/gmodleak

Inventory = Inventory or {}

-- Provide basic XeninUI stubs so the addon can run without the framework
if (not XeninUI) then
  XeninUI = {}
  XeninUI.Theme = {
    Navbar = Color(40, 40, 40),
    Primary = Color(52, 152, 219),
    Background = Color(20, 20, 20),
    Red = Color(231, 76, 60),
    Green = Color(46, 204, 113)
  }
  XeninUI.Frame = { Width = 600, Height = 400 }

  local noop = function() end
  setmetatable(XeninUI, { __index = function() return noop end })
end

function Inventory:IncludeClient(path)
	if (CLIENT) then
		include("inventory/" .. path .. ".lua")
	end

	if (SERVER) then
		AddCSLuaFile("inventory/" .. path .. ".lua")
	end
end

function Inventory:IncludeServer(path)
	if (SERVER) then
		include("inventory/" .. path .. ".lua")
	end
end

function Inventory:IncludeShared(path)
	self:IncludeServer(path)
	self:IncludeClient(path)
end

local function Load()
	Inventory:IncludeShared("configuration/config")
	Inventory:IncludeServer("configuration/database")

	Inventory:IncludeServer("database/mysqlite")

	Inventory:IncludeShared("classes/inventory")
	Inventory:IncludeShared("classes/item")
	Inventory:IncludeShared("essentials/helper")
	Inventory:IncludeClient("essentials/console_commands")
	Inventory:IncludeServer("essentials/player")

	for i, v in pairs(file.Find("inventory/configuration/items/*.lua", "LUA")) do
		Inventory:IncludeShared("configuration/items/" .. v:sub(1, v:len() - 4))
	end

	Inventory:IncludeShared("essentials/languages")
	for i, v in pairs(file.Find("inventory/languages/*.lua", "LUA")) do
		Inventory:IncludeShared("languages/" .. v:sub(1, v:len() - 4))
	end

	for i, v in pairs(file.Find("inventory/importers/*.lua", "LUA")) do
		Inventory:IncludeServer("importers/" .. v:sub(1, v:len() - 4))
	end

	Inventory:IncludeServer("networking/inventory_server")
	Inventory:IncludeClient("networking/inventory_client")

	Inventory:IncludeServer("database/database")

	-- UI
	Inventory:IncludeClient("ui/frame")
	-- Inventory part
	Inventory:IncludeClient("ui/inventory")
	Inventory:IncludeClient("ui/inventory_slots")
	Inventory:IncludeClient("ui/inventory_field")
	-- Context menu part
	Inventory:IncludeClient("ui/context_menu")
	-- Bank
	Inventory:IncludeClient("ui/bank")
	-- Admin
	Inventory:IncludeClient("ui/admin/frame")
	Inventory:IncludeClient("ui/admin/player")
	Inventory:IncludeClient("ui/admin/management")
	-- Trading

	if (SERVER) then
		hook.Add("Think", "Inventory.InitializeMySQL", function()
			timer.Simple(0, function()
				XInvMySQLite.initialize(Inventory.Config.Database)
			end)

			hook.Remove("Think", "Inventory.InitializeMySQL")
		end)
	end

	Inventory.FinishedLoading = true
end

Load()

if (SERVER) then
	resource.AddFile("resource/fonts/Montserrat-Bold.ttf")
	resource.AddFile("resource/fonts/Montserrat-Regular.ttf")

	resource.AddWorkshop("1900562881")
	resource.AddWorkshop("1902931848")
end
