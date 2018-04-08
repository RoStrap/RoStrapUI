-- Material Design Button
-- @readme https://github.com/RoStrap/UI/blob/master/README.md
-- @author Validark

-- Elevations
local RAISED_BASE_ELEVATION = 3
local RAISED_ELEVATION = 6

-- Import Tween Library
local Resources = require(game:GetService("ReplicatedStorage"):WaitForChild("Resources"))
local Tween = Resources:LoadLibrary("Tween")
local Shadow = Resources:LoadLibrary("Shadow")

-- Enums
local MouseMovement = Enum.UserInputType.MouseMovement

local ValidInputEnums = {
	[Enum.UserInputType.Touch] = true;
	[Enum.UserInputType.MouseButton1] = true;
	[Enum.UserInputType.MouseButton2] = true;
	[Enum.UserInputType.MouseButton3] = true;
}

-- Objects
local RaisedButtonImage = Instance.new("ImageLabel")
RaisedButtonImage.BackgroundTransparency = 1
RaisedButtonImage.ScaleType = Enum.ScaleType.Slice
RaisedButtonImage.Size = UDim2.new(1, 0, 1, 0)
RaisedButtonImage.SliceCenter = Rect.new(7, 7, 14, 14)
RaisedButtonImage.Image = "rbxassetid://1409279673"
RaisedButtonImage.Name = "Raised"
RaisedButtonImage.ZIndex = 4

local TextButton = Instance.new("TextButton")
TextButton.AutoButtonColor = false
TextButton.BackgroundTransparency = 1
TextButton.Name = "Button"
TextButton.ZIndex = 6

local Corner = RaisedButtonImage:Clone()
Corner.BorderSizePixel = 0
Corner.Image = "rbxassetid://550542844"
Corner.Name = "Corner"
Corner.ZIndex = 9
Corner.Parent = TextButton

local Rippler = Instance.new("Frame")
Rippler.BackgroundTransparency = 1
Rippler.BorderSizePixel = 0
Rippler.ClipsDescendants = true
Rippler.Name = "Rippler"
Rippler.Size = UDim2.new(1, 0, 1, 0)
Rippler.ZIndex = 7
Rippler.Parent = TextButton

local RaisedRippler = Rippler:Clone()
RaisedRippler.Position = UDim2.new(0, 2, 0, 0)
RaisedRippler.Size = UDim2.new(1, -4, 1, 0)

local RaisedRippler2 = Rippler:Clone()
RaisedRippler2.Position = UDim2.new(0, 0, 0, 2)
RaisedRippler2.Size = UDim2.new(0, 1, 1, -4)

local RaisedRippler3 = Rippler:Clone()
RaisedRippler3.Position = UDim2.new(0, 1, 0, 1)
RaisedRippler3.Size = UDim2.new(0, 1, 1, -2)

local RaisedRippler4 = RaisedRippler3:Clone()
RaisedRippler4.Position = UDim2.new(1, -2, 0, 1)

local RaisedRippler5 = RaisedRippler2:Clone()
RaisedRippler5.Position = UDim2.new(1, -1, 0, 2)

local Ripple = Instance.new("ImageLabel")
Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
Ripple.BackgroundTransparency = 1
Ripple.Size = UDim2.new(0, 4, 0, 4)
Ripple.Image = "rbxassetid://517259585"
Ripple.ImageTransparency = 0.8
Ripple.Name = "Ripple"
Ripple.ZIndex = 8

-- Preload Ink Ripple
game:GetService("ContentProvider"):Preload(Ripple.Image)

-- Metamethods
local function __newindex(self, i, v)
	local Button = self.Button
	local Corner = Button.Corner

	if v then
		if i == "Parent" and v:IsA("GuiObject") then
			Corner.ImageColor3 = v.BackgroundColor3
			-- Button.ZIndex = v.ZIndex + 1
			-- Corner.ZIndex = v.ZIndex + 3

			self.Connection[1]:Disconnect()
			self.Connection[1] = v:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				Corner.ImageColor3 = v.BackgroundColor3
			end)
		elseif i == "TextColor3" then
			Corner.BackgroundColor3 = v
		elseif i == "BackgroundColor3" then
			local Raised = Button:FindFirstChild("Raised")
			if Raised then
				Raised.ImageColor3 = v
			end
		end
	end
	Button[i] = v
end

local function __namecall(self, ...)
	local Button = self.Button
	local Arguments = {...}
	local Method = table.remove(Arguments)

	if Method == "Destroy" then
		self.Connection[1] = self.Connection[1]:Disconnect()
		local Metatable = getmetatable(self)
		for i in next, Metatable do
			Metatable[i] = nil
		end
	elseif Method == "Ripple" then
		self.Down{
			UserInputType = Enum.UserInputType.MouseButton1;
			Position = {
				X = 0.5*Button.AbsoluteSize.X + Button.AbsolutePosition.X;
				Y = 0.5*Button.AbsoluteSize.Y + Button.AbsolutePosition.Y;
			}
		}

		return delay(0.15, function()
			self.Up()
		end)
	end

	return Button(Method, unpack(Arguments)) -- Button[Method](Button, unpack(Arguments))
end

-- API
local Button = {}

function Button.new(Type, Parent, Theme)
	assert(Type == "Flat" or Type == "Custom" or Type == "Raised", "[Button] Invalid Button Type; expected \"Flat\", \"Custom\", or \"Raised\"")

	-- Globals
	local LastRipple, CornerBackgroundTransparency, DepthRenderer

	local Button = TextButton:Clone()
	local Corner = Button.Corner
	local Ripplers = {Button.Rippler}
	local PreviousRipples = {}
	local RipplerCount = 1

	Corner.BackgroundColor3 = Button.TextColor3

	local Interactable = newproxy(true)
	local Metatable = getmetatable(Interactable)
	Metatable.__newindex = __newindex
	Metatable.__namecall = __namecall
	Metatable.Connection = {{Disconnect = function() end}}

	function Metatable:__index(i)
		return Metatable[i] or Button[i]
	end

	CornerBackgroundTransparency = 0.88

	if Type ~= "Flat" then
		Corner.ImageTransparency = 1
	end

	if Type == "Raised" then
		local ButtonImage = RaisedButtonImage:Clone()
		ButtonImage.Parent = Button
		DepthRenderer = Shadow.new(RAISED_BASE_ELEVATION, ButtonImage)

		Ripplers[1]:Destroy()
		RipplerCount = 5
		Ripplers = {
			RaisedRippler:Clone();
			RaisedRippler2:Clone();
			RaisedRippler3:Clone();
			RaisedRippler4:Clone();
			RaisedRippler5:Clone();
		}

		for a = 1, RipplerCount do
			Ripplers[a].Parent = Button
		end

		CornerBackgroundTransparency = 0.6
	end

	function Metatable.Down(InputObject)
		if InputObject.UserInputType == MouseMovement then
			Tween(Corner, "BackgroundTransparency", CornerBackgroundTransparency, "Standard", 0.35, true)
			if DepthRenderer then
				DepthRenderer:ChangeElevation(RAISED_BASE_ELEVATION)
			end
		elseif ValidInputEnums[InputObject.UserInputType] then
			if PreviousRipples[1] then
				for a = 1, RipplerCount do
					Tween(PreviousRipples[a], "ImageTransparency", 1, "Deceleration", 1, false, true)
					PreviousRipples[a] = nil
				end
			end

			if DepthRenderer then
				DepthRenderer:ChangeElevation(RAISED_ELEVATION)
			end

			-- Find furthest Corner distance
			local X, Y = InputObject.Position.X - Button.AbsolutePosition.X, InputObject.Position.Y - Button.AbsolutePosition.Y -- Get near corners
			local V, W = X - Button.AbsoluteSize.X, Y - Button.AbsoluteSize.Y -- Get far corners
			local a, b, c, d = (X*X + Y*Y) ^ 0.5, (X*X + W*W) ^ 0.5, (V*V + Y*Y) ^ 0.5, (V*V + W*W) ^ 0.5 -- Calculate distance between mouse and corners
			local Diameter = 2*(a > b and a > c and a > d and a or b > c and b > d and b or c > d and c or d) + 2.5 -- Find longest distance between mouse and a corner

			for a = 1, RipplerCount do
				local Ripple = Ripple:Clone()
				PreviousRipples[a] = Ripple

				local CurrentRippler = Ripplers[a]

				Ripple.ImageColor3 = Button.TextColor3
				Ripple.Position = UDim2.new(0, X - CurrentRippler.AbsolutePosition.X + Button.AbsolutePosition.X, 0, Y - CurrentRippler.AbsolutePosition.Y + Button.AbsolutePosition.Y)
				-- Ripple.ZIndex = Corner.ZIndex - 1
				Ripple.Parent = Ripplers[a]

				Tween(Ripple, "Size", UDim2.new(0, Diameter, 0, Diameter), "Deceleration", 0.5)
			end
		end
	end

	function Metatable.Up(InputObject)
		if InputObject and InputObject.UserInputType == MouseMovement then
			Tween(Corner, "BackgroundTransparency", 1, "Standard", 0.35, true)
		end

		if PreviousRipples[1] then
			for a = 1, RipplerCount do
				Tween(PreviousRipples[a], "ImageTransparency", 1, "Deceleration", 1, false, true)
				PreviousRipples[a] = nil
			end
		end

		if DepthRenderer then
			DepthRenderer:ChangeElevation(RAISED_BASE_ELEVATION)
		end
	end

	Button.InputBegan:Connect(Metatable.Down)
	Button.InputEnded:Connect(Metatable.Up)

	Metatable.Button = Button
	__newindex(Metatable, "Parent", Parent)

	if Theme then
		__newindex(Metatable, "TextColor3", Theme.TextColor)
	end

	return Interactable
end

return Button
