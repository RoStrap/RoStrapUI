-- Material Design Button
-- @readme https://github.com/RoStrap/UI/blob/master/README.md
-- @author Validark

-- Import Tween Library
local Resources = require(game:GetService("ReplicatedStorage"):WaitForChild("Resources"))
local Tween = Resources:LoadLibrary("Tween")

-- Enums
local MouseMovement = Enum.UserInputType.MouseMovement

local ValidInputEnums = {
	[Enum.UserInputType.Touch] = true;
	[Enum.UserInputType.MouseButton1] = true;
	[Enum.UserInputType.MouseButton2] = true;
	[Enum.UserInputType.MouseButton3] = true;
}

-- Objects
local FlatButton = Instance.new("TextButton")
FlatButton.AutoButtonColor = false
FlatButton.BackgroundTransparency = 1
FlatButton.ClipsDescendants = true
FlatButton.Name = "FlatButton"

local Corner = Instance.new("ImageLabel")
Corner.BackgroundTransparency = 1
Corner.Image = "rbxassetid://550542844"
Corner.Name = "Corner"
Corner.ScaleType = Enum.ScaleType.Slice
Corner.SliceCenter = Rect.new(7, 7, 14, 14)
Corner.Size = UDim2.new(1, 0, 1, 0)
Corner.Parent = FlatButton

local Ripple = Instance.new("ImageLabel")
Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
Ripple.BackgroundTransparency = 1
Ripple.Size = UDim2.new(0, 4, 0, 4)
Ripple.Image = "rbxassetid://517259585"
Ripple.ImageTransparency = 0.8
Ripple.Name = "Ripple"
Ripple.ZIndex = 7

-- Preload Ink Ripple
game:GetService("ContentProvider"):Preload(Ripple.Image)

-- Metamethods
local function __newindex(self, i, v)
	local Button = self.Button
	local Corner = Button.Corner
	
	if v then
		if i == "Parent" and v:IsA("GuiObject") then
			Corner.ImageColor3 = v.BackgroundColor3
			Button.ZIndex = v.ZIndex + 1
			Corner.ZIndex = v.ZIndex + 3
			self.Connection[1]:Disconnect()
			self.Connection[1] = v:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
				Corner.ImageColor3 = v.BackgroundColor3
			end)
		elseif i == "TextColor3" then
			Corner.BackgroundColor3 = v
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

		return delay(0.15, self.Up)
	end

	return Button(Method, unpack(Arguments)) -- Button[Method](Button, unpack(Arguments))
end

-- API
local Button = {}

function Button.new(Type, Parent, Theme)
	-- Globals
	local Button, Corner, LastRipple, CornerBackgroundTransparency

	-- Pseudo Object
	local Interactable = newproxy(true)
	local Metatable = getmetatable(Interactable)
	Metatable.__newindex = __newindex
	Metatable.__namecall = __namecall
	Metatable.Connection = {{Disconnect = function() end}}

	function Metatable:__index(i)
		return Metatable[i] or Button[i]
	end

	if Type == "Flat" or Type == "Custom" then
		Button = FlatButton:Clone()
		Corner = Button.Corner

		Metatable.Button = Button

		Corner.BackgroundColor3 = Button.TextColor3
		Interactable.Parent = Parent

		if Theme then
			Interactable.TextColor3 = Theme.TextColor
		end
		
		CornerBackgroundTransparency = 0.88

		if Type == "Custom" then
			Corner.ImageTransparency = 1
		end
	elseif Type == "Raised" then
		CornerBackgroundTransparency = 0.6
		error("[Button] Invalid Button Type; not yet implemented")
	else
		error("[Button] Invalid Button Type; expected \"Flat\" or \"Custom\"")
	end

	function Metatable.Down(InputObject)
		if InputObject.UserInputType == MouseMovement then
			Tween(Corner, "BackgroundTransparency", CornerBackgroundTransparency, "Standard", 0.35, true)
		elseif ValidInputEnums[InputObject.UserInputType] then
			if PreviousCircle then
				Tween(PreviousCircle, "ImageTransparency", 1, "Deceleration", 1, false, true)
			end
			
			-- Find furthest Corner distance
			local X, Y = InputObject.Position.X - Button.AbsolutePosition.X, InputObject.Position.Y - Button.AbsolutePosition.Y -- Get near corners
			local V, W = X - Button.AbsoluteSize.X, Y - Button.AbsoluteSize.Y -- Get far corners
			local a, b, c, d = (X*X + Y*Y) ^ 0.5, (X*X + W*W) ^ 0.5, (V*V + Y*Y) ^ 0.5, (V*V + W*W) ^ 0.5 -- Calculate distance between mouse and corners
			local Diameter = 2*(a > b and a > c and a > d and a or b > c and b > d and b or c > d and c or d) + 2.5 -- Find longest distance between mouse and a corner

			local Ripple = Ripple:Clone()
			LastRipple = Ripple

			Ripple.ImageColor3 = Button.TextColor3
			Ripple.Position = UDim2.new(0, X, 0, Y)
			Ripple.ZIndex = Corner.ZIndex - 1
			Ripple.Parent = Button

			Tween(Ripple, "Size", UDim2.new(0, Diameter, 0, Diameter), "Deceleration", 0.5)
		end
	end

	function Metatable.Up(InputObject)
		if InputObject and InputObject.UserInputType == MouseMovement then
			Tween(Corner, "BackgroundTransparency", 1, "Standard", 0.35, true)
		end
		if LastRipple then
			Tween(LastRipple, "ImageTransparency", 1, "Deceleration", 1, false, true)
			LastRipple = nil
		end
	end

	Button.InputBegan:Connect(Metatable.Down)
	Button.InputEnded:Connect(Metatable.Up)

	return Interactable
end

return Button
