The following code generates the "Colors" module.
```lua
local String = "local rgb = Color3.fromRGB\n\nreturn {"
for Group, Name in game:GetService("HttpService"):GetAsync("https://material.io/guidelines/style/color.html"):gmatch("(<section class=\"color%-group\">.-<span class=\"name.-\">([%w ]+)</span>.-</section>)") do
    Name = Name:gsub("%s", "")
    local List, Accent = "\n\n\t" .. Name .. " = {"
    for Hex1, Hex2, Hex3, Color in Group:gmatch("<li class=\"color.-style=\"background%-color: #(%w%w)(%w%w)(%w%w);?\"><span class=\"shade.-\">(%w+)</span><span class=\"hex\">#%w+</span></li>") do
        if type(tonumber(Color)) == "number" then
            List = ("%s\n\t\t[%s] = rgb(%u, %u, %u);"):format(List, Color, "0x" .. Hex1, "0x" .. Hex2, "0x" .. Hex3)
        else
            if not Accent then
                Accent = "\n\t\tAccent = {"
            end
            Accent = ("%s\n\t\t\t[%s] = rgb(%u, %u, %u);"):format(Accent, Color:sub(2), "0x" .. Hex1, "0x" .. Hex2, "0x" .. Hex3)
        end
    end
    String = String .. List .. (Accent and "\n" .. Accent .. "\n\t\t};" or "") .. "\n\t};"
end
print(((String .. "\n\n\tBlack = rgb(0, 0, 0);\n\tWhite = rgb(255, 255, 255);\n}\n"):gsub("return {\n", "return {")))
```

Note: This is a markdown file so no one mistakes this for a module
