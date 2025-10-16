-- DumpScrap.server.luau
local function path(i: Instance): string
	local t,cur={},i; while cur and cur ~= game do table.insert(t,1,cur.Name); cur=cur.Parent end
	return table.concat(t,".")
end
task.defer(function()
	local hits=0
	for _,d in ipairs(game:GetDescendants()) do
		local n=(d.Name and string.lower(d.Name)) or ""
		if n:find("scrap") then
			hits+=1
			print(string.format("[SERVER SCRAP] %s path=%s", d.ClassName, path(d)))
		end
	end
	print(string.format("[SERVER SCRAP] total=%d", hits))
end)
