--https://vk.com/gmodleak

Inventory.Database = {}

function Inventory.Database:GetConnection()  
  return XInvMySQLite
end

function Inventory.Database:Drop()
  local conn = self:GetConnection()

  conn.query([[DROP TABLE IF EXISTS inventory_player]])
  conn.query([[DROP TABLE IF EXISTS inventory_bank]])
end

function Inventory.Database:Tables()
  local conn = self:GetConnection()

  conn.query([[
    CREATE TABLE IF NOT EXISTS inventory_player (
      sid64 VARCHAR(22) NOT NULL,
      slot INT(11) NOT NULL,
      ent TEXT NOT NULL,
      drop_ent TEXT NOT NULL,
      amount INT NOT NULL,
      data TEXT NOT NULL,
      PRIMARY KEY (sid64, slot)
    )
  ]])

  conn.query([[
    CREATE TABLE IF NOT EXISTS inventory_bank (
      sid64 VARCHAR(22) NOT NULL,
      slot INT(11) NOT NULL,
      ent TEXT NOT NULL,
      drop_ent TEXT NOT NULL,
      amount INT NOT NULL,
      data TEXT NOT NULL,
      PRIMARY KEY (sid64, slot)
    )
  ]])
end

hook.Add("Inventory.Database.Connected", "Inventory", function()
	Inventory.Database:Tables()
end)

function Inventory.Database:SaveSlot(sid64, slot, ent, dropEnt, amount, data)
  local conn = self:GetConnection()
  data = conn.SQLStr(util.TableToJSON(data))

  if (conn.isMySQL()) then
    local sql = [[
      INSERT INTO inventory_player (sid64, slot, ent, drop_ent, amount, data)
      VALUES (':sid64', :slot, ':ent', ':drop_ent', :amount, :data)
      ON DUPLICATE KEY
        UPDATE
          ent = ':ent',
          drop_ent = ':drop_ent',
          amount = :amount,
          data = :data
    ]]
    sql = sql:Replace(":sid64", sid64)
    sql = sql:Replace(":slot", slot)
    sql = sql:Replace(":ent", ent)
    sql = sql:Replace(":drop_ent", dropEnt)
    sql = sql:Replace(":amount", amount)
    sql = sql:Replace(":data", data)

    conn.query(sql)
  else
    -- I hate SQLite so much.. pain
    -- Doesn't support ON DUPLICATE KEY UPDATE

    local sql = [[
      SELECT * FROM inventory_player
      WHERE sid64 = ':sid64'
        AND slot = ':slot'
    ]]
    sql = sql:Replace(":sid64", sid64)
    sql = sql:Replace(":slot", slot)

    conn.query(sql, function(result)
      if (istable(result) and #result > 0) then
        -- Found it, update

        local sql = [[
          UPDATE inventory_player
          SET ent = ':ent',
              drop_ent = ':drop_ent',
              amount = :amount,
              data = :data
          WHERE sid64 = ':sid64'
            AND slot = ':slot'
        ]]
        sql = sql:Replace(":sid64", sid64)
        sql = sql:Replace(":slot", slot)
        sql = sql:Replace(":ent", ent)
        sql = sql:Replace(":drop_ent", dropEnt)
        sql = sql:Replace(":amount", amount)
        sql = sql:Replace(":data", data)

        conn.query(sql)
      else
        local sql = [[
          INSERT INTO inventory_player (sid64, slot, ent, drop_ent, amount, data)
          VALUES (':sid64', :slot, ':ent', ':drop_ent', :amount, :data)
        ]]
        sql = sql:Replace(":sid64", sid64)
        sql = sql:Replace(":slot", slot)
        sql = sql:Replace(":ent", ent)
        sql = sql:Replace(":drop_ent", dropEnt)
        sql = sql:Replace(":amount", amount)
        sql = sql:Replace(":data", data)

        conn.query(sql)
      end
    end)
  end
end

function Inventory.Database:DeleteSlot(sid64, slot)
  local conn = self:GetConnection()
  local sql = [[
    DELETE FROM inventory_player
    WHERE sid64 = ':sid64'
      AND slot = :slot
  ]]
  sql = sql:Replace(":sid64", sid64)
  sql = sql:Replace(":slot", slot)

  conn.query(sql)
end

function Inventory.Database:SaveBankSlot(sid64, slot, ent, dropEnt, amount, data)
  local conn = self:GetConnection()
  data = conn.SQLStr(util.TableToJSON(data))

  if (conn.isMySQL()) then
    local sql = [[
      INSERT INTO inventory_bank (sid64, slot, ent, drop_ent, amount, data)
      VALUES (':sid64', :slot, ':ent', ':drop_ent', :amount, :data)
      ON DUPLICATE KEY
        UPDATE
          ent = ':ent',
          drop_ent = ':drop_ent',
          amount = :amount,
          data = :data
    ]]
    sql = sql:Replace(":sid64", sid64)
    sql = sql:Replace(":slot", slot)
    sql = sql:Replace(":ent", ent)
    sql = sql:Replace(":drop_ent", dropEnt)
    sql = sql:Replace(":amount", amount)
    sql = sql:Replace(":data", data)

    conn.query(sql)
  else
    local sql = [[
      SELECT * FROM inventory_bank
      WHERE sid64 = ':sid64'
        AND slot = ':slot'
    ]]
    sql = sql:Replace(":sid64", sid64)
    sql = sql:Replace(":slot", slot)

    conn.query(sql, function(result)
      if (istable(result) and #result > 0) then
        -- Found it, update

        local sql = [[
          UPDATE inventory_bank
          SET ent = ':ent',
              drop_ent = ':drop_ent',
              amount = :amount,
              data = :data
          WHERE sid64 = ':sid64'
            AND slot = ':slot'
        ]]
        sql = sql:Replace(":sid64", sid64)
        sql = sql:Replace(":slot", slot)
        sql = sql:Replace(":ent", ent)
        sql = sql:Replace(":drop_ent", dropEnt)
        sql = sql:Replace(":amount", amount)
        sql = sql:Replace(":data", data)

        conn.query(sql)
      else
        local sql = [[
          INSERT INTO inventory_bank (sid64, slot, ent, drop_ent, amount, data)
          VALUES (':sid64', :slot, ':ent', ':drop_ent', :amount, :data)
        ]]
        sql = sql:Replace(":sid64", sid64)
        sql = sql:Replace(":slot", slot)
        sql = sql:Replace(":ent", ent)
        sql = sql:Replace(":drop_ent", dropEnt)
        sql = sql:Replace(":amount", amount)
        sql = sql:Replace(":data", data)

        conn.query(sql)
      end
    end)
  end
end

function Inventory.Database:DeleteBankSlot(sid64, slot)
  local conn = self:GetConnection()
  local sql = [[
    DELETE FROM inventory_bank
    WHERE sid64 = ':sid64'
      AND slot = :slot
  ]]
  sql = sql:Replace(":sid64", sid64)
  sql = sql:Replace(":slot", slot)

  conn.query(sql)
end

function Inventory.Database:Clear(sid64, bank)
  local conn = self:GetConnection()
  local sql = [[
    DELETE FROM inventory_]] .. (bank and "bank" or "player") .. [[
    WHERE sid64 = ':sid64'
  ]]
  sql = sql:Replace(":sid64", sid64)

  conn.query(sql)
end


function Inventory.Database:GetInventory(sid64, callback)
  local conn = self:GetConnection()
  local sql = [[
    SELECT slot, ent, drop_ent, amount, data 
    FROM inventory_player
    WHERE sid64 = ':sid64'
    ORDER BY slot ASC
  ]]
  sql = sql:Replace(":sid64", sid64)

  conn.query(sql, callback)
end

function Inventory.Database:GetBank(sid64, callback)
  local conn = self:GetConnection()
  local sql = [[
    SELECT slot, ent, drop_ent, amount, data 
    FROM inventory_bank
    WHERE sid64 = ':sid64'
    ORDER BY slot ASC
  ]]
  sql = sql:Replace(":sid64", sid64)

  conn.query(sql, callback)
end

--Inventory.Database:Tables()