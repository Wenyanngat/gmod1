--https://vk.com/gmodleak

Inventory.Languages = Inventory.Languages or {}

function Inventory:CreateLanguage(name, tbl)
	self.Languages[name] = tbl
end

function Inventory:GetPhrase(phrase, replacement)
	local str = self.Languages[Inventory.Config.Language][phrase] or "No Phrase"
	
	if (replacement) then
		for i, v in pairs(replacement) do
			str = str:Replace(":" .. i .. ":", v)
		end
	end

	return str
end