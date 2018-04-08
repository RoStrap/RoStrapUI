# Material
User Interface Modules for Roblox

## Snackbar
WIP

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

local Submit = Button.new("Flat", Frame) -- Use "Custom" to remove the rounded corners
Submit.TextSize = 18
Submit.TextColor3 = Color3.fromRGB(255, 255, 255)
Submit.Size = UDim2.new(0, 82, 0, 36)
Submit.Position = UDim2.new(0, 10, 0, 100)
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
The three button types are "Flat", "Custom", and "Raised". The "Raised" type isn't perfect, as it is difficult to faithfully render in Roblox.

#### Flat
A `FlatButton` has one descendant by default, called `Corner`. This is the [ImageLabel](http://wiki.roblox.com/index.php?title=API:Class/ImageLabel) that overlays a 2dp corner image over your `FlatButton`. It's [ImageColor3](http://wiki.roblox.com/index.php?title=API:Class/GuiObject/ImageColor3) property is automatically set to `FlatButton.Parent.BackgroundColor3`. Whenever you set the `Parent` property, it will attempt to update to the aforementioned value. You can set it manually with the following:
```lua
FlatButton.Corner.ImageColor3 = Color3.fromRGB(255, 255, 255)
```

#### Custom
A `CustomButton` is exactly the same as a `FlatButton`, except its `Corner` object has its [ImageTransparency](http://wiki.roblox.com/index.php?title=API:Class/GuiObject/ImageTransparency) set to 0. Use this if you don't want visible corner overlays.

#### Raised
For when you want your buttons to lift.

## SelectionControl
Material design selection controls based on [Material.io specifications](https://material.io/guidelines/components/selection-controls.html#). Will include Checkbox, Radio, and Switch elements. Currently, only Checkbox is available.

#### Checkbox
Checkboxes can be instantiated like so:
```lua
local Resources = require(game:GetService("ReplicatedStorage"):WaitForChild("Resources"))
local SelectionControl = Resources:LoadLibrary("SelectionControl")

local Checkbox = SelectionControl.new("Checkbox")
```
This returns a custom userdata which can be interfaced with like a `TextButton`. It also has some added functionality:
```lua
-- Properties
Checkbox.State
--	On is true, Off is false
Checkbox.EnabledColor
--	Should be a name of a Color from the `Colors` module
Checkbox.EnabledColor3
--	The true Color3 value of the EnabledColor

-- Methods
Checkbox:ChangeState()
--	Unlike simply setting the `State` property directly, this will animate and fire the StateChanged event

-- Events
Checkbox.StateChanged
--	Fires after a player clicked to change the state or `:ChangeState()` was called
```

Example:
```lua
local THEME_NAME = "Light"

local Resources = require(game:GetService("ReplicatedStorage"):WaitForChild("Resources"))
local Colors = Resources:LoadLibrary("Colors")
local SelectionControl = Resources:LoadLibrary("SelectionControl")

local Players = game:GetService("Players")
local LocalPlayer repeat LocalPlayer = Players.LocalPlayer until LocalPlayer or not wait()
local PlayerGui repeat PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") until PlayerGui or not wait()

local Screen = Instance.new("ScreenGui", PlayerGui)
local Frame = Instance.new("Frame", Screen) -- Color3.fromRGB(51, 51, 51)
Frame.BackgroundColor3 = THEME_NAME == "Dark" and Color3.fromRGB(51, 51, 51) or THEME_NAME == "Light" and Colors.Grey[200] or error("Invalid THEME_NAME")
Frame.BorderSizePixel = 0
Frame.Size = UDim2.new(1, 0, 1, 0)

local DisallowedColors = {
	White = true;
	Black = true;
	Grey = true;
	Brown = true;
	BlueGrey = true;
	Yellow = true;
	Amber = true;
	Lime = true;
}

local function NextColor(CurrentColor)
	repeat CurrentColor = next(Colors, CurrentColor)
	until CurrentColor and not DisallowedColors[CurrentColor]
	return CurrentColor
end

local CurrentColor = NextColor()

local ReceiveUpdates = SelectionControl.new("Checkbox")
ReceiveUpdates.EnabledColor = CurrentColor
ReceiveUpdates.State = false
ReceiveUpdates.StateChanged:Connect(function(On)
	if not On then
		CurrentColor = NextColor(CurrentColor)
		print(CurrentColor)
		ReceiveUpdates.EnabledColor = CurrentColor
	end
end)
ReceiveUpdates.AnchorPoint = Vector2.new(0.5, 0.5)
ReceiveUpdates.Position = UDim2.new(0.5, 0, 0.5, 0)
ReceiveUpdates.Theme = THEME_NAME
ReceiveUpdates.Parent = Frame
```
