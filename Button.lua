-- Material Design Button
-- @author Validark

-- Import Tween Library
local Resources = require(game:GetService("ReplicatedStorage"):WaitForChild("Resources"))
local Tween = Resources:LoadLibrary("Tween")

-- Enums
local Completed = Enum.TweenStatus.Completed
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

local Circle = Instance.new("ImageLabel")
Circle.AnchorPoint = Vector2.new(0.5, 0.5)
Circle.BackgroundTransparency = 1
Circle.Size = UDim2.new(0, 4, 0, 4)
Circle.Image = "rbxassetid://517259585"
Circle.ImageTransparency = 0.8
Circle.Name = "Ripple"
Circle.ZIndex = 7

-- Preload Ink Ripple
game:GetService("ContentProvider"):Preload(Circle.Image)

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
	-- Not sure that this is the best way to do this
	local Button = self.Button
	local Arguments = {...}
	local Method = table.remove(Arguments) -- select(-1, ...)
	if Method == "Destroy" then
		-- Do cleanup operations here
		self.Connection[1] = self.Connection[1]:Disconnect()
	elseif Method == "Ripple" then
		self.Down{
			UserInputType = Enum.UserInputType.MouseButton1;
			Position = {
				X = 0.5*Button.AbsoluteSize.X + Button.AbsolutePosition.X;
				Y = 0.5*Button.AbsoluteSize.Y + Button.AbsolutePosition.Y;
			}
		}

		wait(0.15)

		return self.Up()
	end

	return Button(Method, unpack(Arguments)) -- Button[Method](Button, unpack(Arguments))
end

-- API
local Button = {}

function Button.new(Type, Parent, Theme)
	-- Globals
	local Button, Corner, CurrentCircle, Down, Up, CornerBackgroundTransparency
	local Connection = {{Disconnect = function() end}}

	-- Pseudo Object
	local Interactable = newproxy(true)
	local Metatable = getmetatable(Interactable)
	Metatable.__newindex = __newindex
	Metatable.__namecall = __namecall

	function Metatable:__index(i)
		if i == "Button" then
			return Button
		elseif i == "Down" then
			return Down
		elseif i == "Up" then
			return Up
		elseif i == "Connection" then
			return Connection
		else
			return Button[i]
		end
	end	

	if Type == "Flat" or Type == "Custom" then
		Button = FlatButton:Clone()
		Corner = Button.Corner

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

	function Down(InputObject)
		if InputObject.UserInputType == MouseMovement then
			Tween(Corner, "BackgroundTransparency", CornerBackgroundTransparency, "Standard", 0.35, true)
		elseif ValidInputEnums[InputObject.UserInputType] then
			local PreviousCircle = CurrentCircle
			if PreviousCircle then
				Tween(PreviousCircle, "ImageTransparency", 1, "Deceleration", 1, false, true)
			end
			
			-- Find furthest Corner distance
			local X, Y = InputObject.Position.X - Button.AbsolutePosition.X, InputObject.Position.Y - Button.AbsolutePosition.Y -- Get near corners
			local V, W = X - Button.AbsoluteSize.X, Y - Button.AbsoluteSize.Y -- Get far corners
			local a, b, c, d = (X*X + Y*Y) ^ 0.5, (X*X + W*W) ^ 0.5, (V*V + Y*Y) ^ 0.5, (V*V + W*W) ^ 0.5 -- Calculate distance between mouse and corners
			local Diameter = 2*(a > b and a > c and a > d and a or b > c and b > d and b or c > d and c or d) + 2.5 -- Find longest distance between mouse and a corner

			local Circle = Circle:Clone()
			CurrentCircle = Circle

			Circle.ImageColor3 = Button.TextColor3
			Circle.Position = UDim2.new(0, X, 0, Y)
			Circle.ZIndex = Corner.ZIndex - 1
			Circle.Parent = Button

			Tween(Circle, "Size", UDim2.new(0, Diameter, 0, Diameter), "Deceleration", 0.5)
		end
	end

	function Up(InputObject)
		if InputObject and InputObject.UserInputType == MouseMovement then
			Tween(Corner, "BackgroundTransparency", 1, "Standard", 0.35, true)
		end
		local CurrentCircle = CurrentCircle
		if CurrentCircle then
			Tween(CurrentCircle, "ImageTransparency", 1, "Deceleration", 1, false, true)
		end
	end

	Button.InputBegan:Connect(Down)
	Button.InputEnded:Connect(Up)

	return Interactable
end

return Button
