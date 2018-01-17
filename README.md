# UI
User Interface Modules for Roblox


## Colors
Colors taken from [Material Design Color Palette](https://material.io/guidelines/style/color.html#color-color-palette), compiled via our [Colors Generator](https://github.com/RoStrap/UI/blob/master/Colors%20Generator.md).

The `Colors` table is structured much like the webpage:
```lua
local Colors = Resources:LoadLibrary("Colors")
local Red = Colors.Red[500] -- Red 500: #F44336
local DarkRed = Colors.Red[900] -- Red 900: #B71C1C
```
Accent colors have their own table within colors
```lua
local PurpleAccent = Colors.Purple.Accent[700] -- Purple A700 #AA00FF
```

## Button
Material Design Buttons!

### API
Instantiate a new button with `userdata Button.new(string BUTTON_TYPE, RbxObject Parent)`. It returns a userdata that serves as a wrapper for the [TextButton](http://wiki.roblox.com/index.php?title=API:Class/TextButton) Object. Simply declare it and use it like you normally would!

Example:
```lua
local Resources = require(game:GetService("ReplicatedStorage"):WaitForChild("Resources"))
local Button = Resources:LoadLibrary("Button")

local Players = game:GetService("Players")
local LocalPlayer repeat LocalPlayer = Players.LocalPlayer until LocalPlayer or not wait()
local PlayerGui repeat PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") until PlayerGui or not wait()

local Screen = Instance.new("ScreenGui", PlayerGui)
local Frame = Instance.new("Frame", Screen)
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Size = UDim2.new(1, 0, 1, 0)

local Submit = Button.new("Custom", Frame)
Submit.TextSize = 18
Submit.TextColor3 = Color3.fromRGB(255, 255, 255)
Submit.Size = UDim2.new(0, 82, 0, 36)
Submit.Position = UDim2.new(0, 10, 0, 10)
Submit.Font = Enum.Font.SourceSansBold
Submit.Text = "SUBMIT"

Submit.MouseButton1Click:Connect(function()
	print("MouseButton1Click")
end)

wait(1)

Submit:Ripple()

wait(1)

Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Submit.TextColor3 = Color3.fromRGB(0, 0, 0)

wait(1)

Submit:Destroy()
```
There is also a `Ripple` method which just plays a Ripple.
```lua
Submit:Ripple() -- Ripples :D
```

### Button Types
The two button types are "Flat" and "Custom". There should also be a "Raised" type but I am not smart enough to figure out how to replicate the button-press effect accurately.

#### Flat
A `FlatButton` has one descendant by default, called `Corner`. This is the [ImageLabel](http://wiki.roblox.com/index.php?title=API:Class/ImageLabel) that overlays a 2dp corner image over your `FlatButton`. It's [ImageColor3](http://wiki.roblox.com/index.php?title=API:Class/GuiObject/ImageColor3) property is automatically set to `FlatButton.Parent.BackgroundColor3`. Whenever you set the `Parent` property, it will attempt to update to the aforementioned value. You can set it manually with the following:
```lua
FlatButton.Corner.ImageColor3 = Color3.fromRGB(255, 255, 255)
```

#### Custom
A `CustomButton` is exactly the same as a `FlatButton`, except its `Corner` object has its [ImageTransparency](http://wiki.roblox.com/index.php?title=API:Class/GuiObject/ImageTransparency) set to 0. Use this if you don't want visible corner overlays.
