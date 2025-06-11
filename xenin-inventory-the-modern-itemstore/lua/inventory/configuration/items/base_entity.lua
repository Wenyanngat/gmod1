--https://vk.com/gmodleak

local ITEM = Inventory:CreateItem()
ITEM.Hover = "Inventory.Weapon.Hover"
ITEM.NWData = {}

ITEM:AddAction("Drop", 2, function(self, ply, ent, tbl)
  local trace = {}
  trace.start = ply:EyePos()
  trace.endpos = trace.start + ply:GetAimVector() * 85
  trace.filter = ply

  local tr = util.TraceLine(trace)
  local weapon = ents.Create(ent)
  local model = self:GetModel(ent)
  weapon:SetModel(model)
  weapon:SetPos(tr.HitPos)
  weapon:Spawn()

  for i, v in pairs(tbl.data or {}) do
    if (i == "dt") then
      for k, dt in pairs(v) do
        weapon.dt[k] = v
      end
    elseif (i == "nw") then
      for k, nw in pairs(v) do
        if (weapon["Set" .. k]) then

          weapon["Set" .. k](weapon, nw)
        end
      end
    end
  end
end)

function ITEM:GetData(ent)
  local dt = {}
  for i, v in pairs(ent.dt or {}) do
    dt[i] = v
  end

  local tbl = {}
  local class = ent:GetClass()
  -- Apparently there's no easy way to get a list of NetworkVar's in Gmod...
  -- If you know a good way to find them please tell me... for now this is a solution
  if (ent.SetupDataTables and !self.NWData[class]) then
    local funcInfo = jit.util.funcinfo(ent.SetupDataTables)
    local startLine = funcInfo.linedefined
    local endLine = funcInfo.lastlinedefined
    local pathStartLine = funcInfo.source:find("/lua/")
    -- Because of the "/lua/"
    pathStartLine = pathStartLine + 5
    -- Find the "LUA" path
    local sourceFixed = funcInfo.source:sub(pathStartLine, #funcInfo.source)
    local fileRead = file.Read(sourceFixed, "LUA")
    local splitFile = string.Explode("\n", fileRead)

    -- Now scan the lines!
    for i = startLine, endLine do
      local str = splitFile[i]
      local networkVar = str:find("NetworkVar")
      if (!networkVar) then continue end
      local splitByComma = string.Explode(",", str)
      if (!splitByComma[3]) then continue end
      -- The third part is the juicy part! The name!
      local endStr = splitByComma[3]
      -- Remove what we don't need
      endStr = endStr:Replace("'", "")
      endStr = endStr:Replace("\"", "")
      endStr = endStr:Replace(")", "")
      endStr = endStr:Trim()

      -- Cache as this function is INCREDIBLY heavy. Luckily only run once ever cause of caching
      self.NWData[class] = self.NWData[class] or {}
      table.insert(self.NWData[class], endStr)
    end
  end

  if (self.NWData[class]) then
    for i, v in ipairs(self.NWData[class]) do
      tbl[v] = ent["Get" .. v](ent)
    end
  end

  return {
    model = ent:GetModel(),
    dt = dt,
    nw = tbl
  }
end

ITEM:Register("base_entity")