--https://vk.com/gmodleak

concommand.Add("inventory_equip", function(ply, cmd, args)
  local ent = args[1]
  local inv = ply:Inventory()
  local tbl = inv:GetInventory()

  for i, v in pairs(tbl) do
    if (v.ent != ent) then continue end
    local item = Inventory:GetItem(v.dropEnt)
    if (!item) then return end
    local canEquip, reason = item:CanEquip(ply, v.ent)

    if (!canEquip) then
      ply:ChatPrint(reason)
    end

    if (inv:ReduceAmount(i, 1)) then
      item:Equip(ply, v.ent)

      net.Start("Inventory.Equip")
        net.WriteUInt(i, 10)
      net.SendToServer()
    end
  end
end)

concommand.Add("inventory_drop", function(ply, cmd, args)
  local ent = args[1]
  local inv = ply:Inventory()
  local tbl = inv:GetInventory()

  for i, v in pairs(tbl) do
    if (v.ent != ent) then continue end
    local item = Inventory:GetItem(v.dropEnt)
    if (!item) then return end

    if (inv:ReduceAmount(i, 1)) then
      local str = Inventory:GetPhrase("ConCommand.Drop", { item = item:GetName(v) })
      XeninUI:Notify(str, NOTIFY_GENERIC, 4, XeninUI.Theme.Green)
      chat:AddText(Inventory.Config.PrefixCol, Inventory.Config.PrefixText .. " ", color_white, str)

      net.Start("Inventory.Drop")
        net.WriteUInt(i, 10)
      net.SendToServer()
    end
  end
end)
