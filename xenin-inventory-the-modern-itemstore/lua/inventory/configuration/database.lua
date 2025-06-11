--https://vk.com/gmodleak


Inventory.Config.Database = {}

Inventory.Config.Database.EnableMySQL = false
Inventory.Config.Database.Host = "127.0.0.1"
Inventory.Config.Database.Username = "root"
Inventory.Config.Database.Password = ""
Inventory.Config.Database.Database_name = "darkrp"
Inventory.Config.Database.Database_port = 3306
Inventory.Config.Database.module = "mysqloo"
Inventory.Config.Database.MultiStatements = false

if (Inventory.FinishedLoading) then
	XInvMySQLite.initialize(Inventory.Config.Database)
end