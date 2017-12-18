The following code generates the "Colors" module.
```lua
local String = "local rgb = Color3.fromRGB\n\nreturn {"
for Group in game:GetService("HttpService"):GetAsync("https://material.io/guidelines/style/color.html"):match("<div class=\"col%-list\"><section class=\"module%-module%-module col%-3\">(<div class=\"module\">.+)"):gmatch("(<div class=\"module\">.-</div>%s*</div>%s*</div>)") do
	local Name = Group:match("<span class=\"group\">([^<]+)")
	if Name then
		Name = Name:gsub("%s", "")
		local List, Accent = "\n\n\t" .. Name .. " = {"
		local Count = 0
		for Color, Hex1, Hex2, Hex3 in Group:gmatch("<span class=\"shade\">(%d+)</span>%s*<span class=\"hex\">#([ABCDEF%d][ABCDEF%d])([ABCDEF%d][ABCDEF%d])([ABCDEF%d][ABCDEF%d])</span>") do
			Count = Count + 1
			if Count ~= 1 then
				if type(tonumber(Color)) == "number" then
					List = ("%s\n\t\t[%s] = rgb(%u, %u, %u);"):format(List, Color, "0x" .. Hex1, "0x" .. Hex2, "0x" .. Hex3)
				else
					if not Accent then
						Accent = "\n\t\tAccent = {"
					end
					Accent = ("%s\n\t\t\t[%s] = rgb(%u, %u, %u);"):format(Accent, Color:sub(2), "0x" .. Hex1, "0x" .. Hex2, "0x" .. Hex3)
				end
			end
		end
		String = String .. List .. (Accent and "\n" .. Accent .. "\n\t\t};" or "") .. "\n\t};"
	end
end
Instance.new("Script", workspace).Source = (((String .. "\n\n\tBlack = rgb(0, 0, 0);\n\tWhite = rgb(255, 255, 255);\n}\n"):gsub("return {\n", "return {")))
```

Note: This is a markdown file so no one mistakes this for a module
