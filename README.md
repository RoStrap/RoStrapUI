# UI
User Interface Modules for Roblox


## Colors
Table format of [Material Design's official Color Specifications](https://material.io/guidelines/style/color.html#color-color-palette). This module is compiled via our [Colors Generator](https://github.com/RoStrap/UI/blob/master/Colors%20Generator.md)

The `Colors` table is structured much like the webpage:
```lua
local Colors = require("Colors")
local Red = Colors.Red[500] -- Red 500: #F44336
local DarkRed = Colors.Red[900] -- Red 900: #B71C1C
```
Accent colors have their own table within colors
```lua
local PurpleAccent = Colors.Purple.Accent[700] -- Purple A700 #AA00FF
```
