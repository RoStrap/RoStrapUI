-- Material Selection Controls
-- @readme https://github.com/RoStrap/UI/blob/master/README.md
-- @specs https://material.io/guidelines/components/selection-controls.html#
-- @author Validark

--[[
	The Checkbox element animations are all fully scripted and contained within this module.
	However, there is now the question of timing and duration.

	Problem:
		The shrinking and expanding of the Checkbox Frame is not synced to the DrawCheckmark animation. This is because
		I am unsure whether it should be. Fixing that is the easy part, the hard part is figuring out what looks best.
		I don't know what looks best. We may just have to demo a bunch of different versions.
--]]

-- Load Libraries
local Resources = require(game:GetService("ReplicatedStorage"):WaitForChild("Resources"))
local Tween = Resources:LoadLibrary("Tween")
local Colors = Resources:LoadLibrary("Colors")

-- Import Math Functions
local ceil = math.ceil
local floor = math.floor

-- Configuration
local RIPPLE_TRANSPARENCY = 0.8

local ANIMATION_TIME = 0.1625
local RIPPLE_ENTER_TIME = 0.5
local RIPPLE_EXIT_TIME = 0.5

local CHECKBOX_THEMES = {
	Light = {
		ImageColor3 = Colors.Black;
		ImageTransparency = 0.46;
		DisabledTransparency = 0.74;
	};

	Dark = {
		ImageColor3 = Colors.White;
		ImageTransparency = 0.3;
		DisabledTransparency = 0.7;
	};
}

-- Bezier Curves (defined in the `Easing` module)
local CHECKMARK_DRAW_BEZIER = "Deceleration"
local CHECKMARK_ERASE_BEZIER = "Deceleration"

local CENTER_FILL_BEZIER = "Deceleration"
local CENTER_EMPTY_BEZIER = "Deceleration"

local OUTSIDE_TRANSPARENCY_BEZIER = "Deceleration"

-- Constants
local SHRINK_DURATION = ANIMATION_TIME --* 0.95
local DRAW_DURATION = ANIMATION_TIME * (1 / 0.7501)
local FILL_DURATION = ANIMATION_TIME * (1 / 0.9286)

local DEFAULT_CHECKBOX_COLOR = "Cyan"
local DEFAULT_CHECKBOX_COLOR3 = Colors[DEFAULT_CHECKBOX_COLOR][500]

local SETS = {
	Bars = 0;
	Corners = 0.69;
	Edges = 0.09;

	InnerBars = 0;
	InnerCorners = 0;
	InnerEdges = 0;
}

local SETS_GOALS = {
	Bars = 1;
	Corners = 1;
	Edges = 1;

	InnerBars = SETS.Bars;
	InnerCorners = SETS.Corners;
	InnerEdges = SETS.Edges;
}

-- Images
local RIPPLE_IMAGE = "rbxassetid://517259585"

-- Preload Images
game:GetService("ContentProvider"):Preload(RIPPLE_IMAGE)

-- Object Data
local NO_SIZE = UDim2.new(0, 0, 0, 0)
local PART_SIZE = UDim2.new(0.9, 0, 0.9, 0)
local FULL_SIZE = UDim2.new(1, 0, 1, 0)
local RIPPLE_TARGET_SIZE = UDim2.new(2, 0, 2, 0)

local CHECKBOX_SIZE = UDim2.new(0, 24, 0, 24)
local CHECKBOX_SHRINK_SIZE = UDim2.new(0, 22, 0, 22)

local MIDDLE_ANCHOR = Vector2.new(0.5, 0.5)
local MIDDLE_POSITION = UDim2.new(0.5, 0, 0.5, 0)

local function ExpandFrame(x, Grid)
	local ImageTransparency = Grid.ImageTransparency
	local ImageOpacity = 1 - ImageTransparency

	for Name, Start in next, SETS_GOALS do
		local Start = ImageOpacity * Start + ImageTransparency
		local End = ImageOpacity * SETS[Name] + ImageTransparency - Start
		local Objects = Grid[Name]

		for a = 1, #Objects do
			Objects[a].BackgroundTransparency = Start + x * End
		end
	end
end

local function ShrinkFrame(x, Grid)
	local ImageTransparency = Grid.ImageTransparency
	local ImageOpacity = 1 - ImageTransparency

	for Name, Start in next, SETS do
		local Start = ImageOpacity * Start + ImageTransparency
		local End = ImageOpacity * SETS_GOALS[Name] + ImageTransparency - Start
		local Objects = Grid[Name]

		for a = 1, #Objects do
			Objects[a].BackgroundTransparency = Start + x * End
		end
	end

	if x == 1 then
		Grid.OpenTween2 = Tween.new(SHRINK_DURATION, OUTSIDE_TRANSPARENCY_BEZIER, ExpandFrame, Grid)
	end
end

local function SetCheckboxColorAndTransparency(Grid, Color, Transparency)
	local Opacity = (1 - Transparency)

	for Name, BackgroundTransparency in next, SETS do
		local Transparency = Opacity * BackgroundTransparency + Transparency
		local Objects = Grid[Name]

		for a = 1, #Objects do
			local Object = Objects[a]
			Object.BackgroundColor3 = Color
			Object.BackgroundTransparency = Transparency
		end
	end

	Grid.ImageTransparency = Transparency

	for a = 1, 196 do
		local Pixel = Grid[a]
		Pixel.BackgroundColor3 = Color
		Pixel.BackgroundTransparency = Opacity * Pixel.BackgroundTransparency + Transparency -- CompoundTransparency
	end
end

local function DrawCheckmark(x, Grid)
--	ChangeCheckboxSize(PART_SIZE:Lerp(FULL_SIZE, x))

	for c = 1, -1, -2 do
		local a = floor(11 + x * (4 - 2*c - 11)) -- Lerp(11, 4 - 2*c, x)
		local d = c == 1 and 15 or -4

		for a = a, 10 do
			local b = -c*a + d
			local e

			if a == 2 and b == 13 then
				e = 0.18
			elseif a == 3 and b == 12 or a == 4 and b == 11 or a == 5 and b == 10 or a == 9 and (b == 5 or b == 6) then
				e = 0.36
			elseif a == 6 then
				if b == 2 then
					e = 0.18
				elseif b == 9 then
					e = 0.36
				end
			elseif a == 7 then
				if b == 3 then
					e = 0.35
				elseif b == 8 then
					e = 0.36
				end
			elseif a == 8 then
				if b == 4 then
					e = 0.35
				elseif b == 7 then
					e = 0.36
				end
			elseif a == 10 then
				if b == 5 or b == 6 then
					e = 0.99
				end
			end

			Grid[14 * (a - 1) + b].BackgroundTransparency = e
			Grid[14 * a + b].BackgroundTransparency = 0.99
			Grid[14 * (a + 1) + b].BackgroundTransparency = 1
			Grid[14 * (a + 1) + b + c].BackgroundTransparency = 0.5
		end
		Grid[a * (14 - c) + c + d].BackgroundTransparency = c == 1 and 0.5 or 0.51 -- 14 * a + -c * a + d + c
	end
	Grid[160].BackgroundTransparency = 0.5 -- 12, 6
end

local function FillCenter(x, Grid)
--	ChangeCheckboxSize(FULL_SIZE:Lerp(PART_SIZE, x))

	local CurrentSize = 0.5 * floor(14*(2 - x)) -- Floor(Lerp(14, 7, x), 0.5)

	for i = 1, 14 - CurrentSize do
		for a = i, 15 - i do
			Grid[14 * (i - 1) + a].BackgroundTransparency = 0
			Grid[14 * (a - 1) + i].BackgroundTransparency = 0
			Grid[14 * ((15 - i) - 1) + a].BackgroundTransparency = 0
			Grid[14 * (a - 1) + 15 - i].BackgroundTransparency = 0
		end
	end

	if (CurrentSize + 0.5) % 1 == 0 then
		local i = 14.5 - CurrentSize
		for a = i, 15 - i do
			Grid[14 * (i - 1) + a].BackgroundTransparency = 0.5
			Grid[14 * (a - 1) + i].BackgroundTransparency = 0.5
			Grid[14 * ((15 - i) - 1) + a].BackgroundTransparency = 0.5
			Grid[14 * (a - 1) + 15 - i].BackgroundTransparency = 0.5
		end
	end

	local OpenTween = Grid.OpenTween
	if CurrentSize == 7 and OpenTween then
		Grid.OpenTween:Stop()
		Grid.OpenTween = Tween.new(DRAW_DURATION, CHECKMARK_DRAW_BEZIER, DrawCheckmark, Grid)
	end
end

local function EmptyCenter(x, Grid)
--	ChangeCheckboxSize(PART_SIZE:Lerp(FULL_SIZE, x))

	local CurrentSize = 0.5 * ceil(14 * x) -- Ceil(Lerp(0, 7, x), 0.5)

	for i = 1, CurrentSize do
		local Start = 8 - i
		local End = 7 + i

		for a = Start, End do
			Grid[14 * (Start - 1) + a].BackgroundTransparency = 1
			Grid[14 * (a - 1) + Start].BackgroundTransparency = 1
			Grid[14 * (End - 1) + a].BackgroundTransparency = 1
			Grid[14 * (a - 1) + End].BackgroundTransparency = 1
		end
	end

	if (CurrentSize + 0.5) % 1 == 0 then
		local i = 0.5 + CurrentSize
		local Start = 8 - i
		local End = 7 + i
		
		for a = Start, End do
			local BackgroundTransparency = 0.5 * (Grid.ImageTransparency + 1) -- CompoundTransparency
			Grid[14 * (Start - 1) + a].BackgroundTransparency = BackgroundTransparency
			Grid[14 * (a - 1) + Start].BackgroundTransparency = BackgroundTransparency
			Grid[14 * (End - 1) + a].BackgroundTransparency = BackgroundTransparency
			Grid[14 * (a - 1) + End].BackgroundTransparency = BackgroundTransparency
		end
	end
end

local function EraseCheckmark(x, Grid)
--	ChangeCheckboxSize(FULL_SIZE:Lerp(PART_SIZE, x))

	local ImageTransparency = Grid.ImageTransparency
	local XOffset, YOffset = Grid.XOffset, Grid.YOffset
	local HalfImageTransparency = 0.5 * (ImageTransparency + 1) -- CompoundTransparency
	local a = ceil(8*x + 1) -- ceil(Lerp(1, 9, x))

	for a = 2, a do
		local Object1 = 14 * (a + XOffset - 1) + 15 - a + YOffset
		local Object2 = Object1 + 14
		local Object3 = Object2 + 1

		if Object1 > 0 then Grid[Object1].BackgroundTransparency = ImageTransparency end
		if Object2 > 0 then Grid[Object2].BackgroundTransparency = ImageTransparency end
		if Object3 > 0 then Grid[Object3].BackgroundTransparency = ImageTransparency end

		Grid[Object2 + 14].BackgroundTransparency = HalfImageTransparency
		Grid[Object3 + 14].BackgroundTransparency = ImageTransparency
	end

	local c = ceil(4*x + 5) -- Lerp(5, 9, x)
	local d = c - 4

	for c = 6, c do
		local e = 14 * (c + XOffset - 1) + c - 4 + YOffset
		Grid[e].BackgroundTransparency = ImageTransparency
		Grid[e + 13].BackgroundTransparency = ImageTransparency
		Grid[e + 14].BackgroundTransparency = ImageTransparency
		Grid[e + 28].BackgroundTransparency = HalfImageTransparency
		Grid[e + 27].BackgroundTransparency = ImageTransparency
	end

	local NewXOffset = floor(-5*x + 1) -- Lerp(1, -3 - 1, x)
	local NewYOffset = ceil(3*x - 1) -- Lerp(-1, 2, x)

	local XOffsetChange = XOffset - NewXOffset
	local YOffsetChange = NewYOffset - YOffset

	Grid.XOffset, Grid.YOffset = NewXOffset, NewYOffset

	-- Shift according to XOffsetChange and YOffsetChange
	for a = 1, XOffsetChange do
		for b = 1, 14 do
			for f = 1, 13 do
				Grid[14 * (f - 1) + b].BackgroundTransparency = Grid[14 * f + b].BackgroundTransparency
			end
		end
	end

	for a = 1, YOffsetChange do
		for b = 1, 14 do
			for f = 14, 2, -1 do
				Grid[14 * (b - 1) + f].BackgroundTransparency = Grid[14 * (b - 1) + f - 1].BackgroundTransparency
			end
			Grid[14 * (b - 1) + 1].BackgroundTransparency = ImageTransparency
		end
	end

	local OpenTween = Grid.OpenTween
	if a == 9 and OpenTween then
		Grid.OpenTween:Stop()
		for a = 1, 196 do
			Grid[a].BackgroundTransparency = ImageTransparency
		end
		Grid.OpenTween = Tween.new(FILL_DURATION, CENTER_EMPTY_BEZIER, EmptyCenter, Grid)
	end
end

-- Objects
local Ripple = Instance.new("ImageLabel")
Ripple.AnchorPoint = MIDDLE_ANCHOR
Ripple.BackgroundTransparency = 1
Ripple.Image = RIPPLE_IMAGE
Ripple.ImageTransparency = RIPPLE_TRANSPARENCY
Ripple.Name = "Ripple"
Ripple.Position = MIDDLE_POSITION

local Checkbox do
	Checkbox = Instance.new("TextButton")
	Checkbox.BackgroundTransparency = 1
	Checkbox.Text = ""
	Checkbox.Size = CHECKBOX_SIZE

	local Pixel = Instance.new("Frame")
	Pixel.BackgroundTransparency = 1
	Pixel.BackgroundColor3 = Colors.Black
	Pixel.BorderSizePixel = 0
	Pixel.Size = UDim2.new(0, 1, 0, 1)

	for a = 1, 14 do
		local Existant = 14 * (a - 1)
		for b = 1, 14 do
			local Pixel = Pixel:Clone()
			Pixel.Name = Existant + b
			Pixel.Position = UDim2.new(0, b + 4, 0, a + 4)
			Pixel.Parent = Checkbox
		end
	end

	local BackgroundTransparency = CHECKBOX_THEMES.Light.ImageTransparency

	local Bar = Instance.new("Frame")
	Bar.BackgroundColor3 = Colors.Black
	Bar.BackgroundTransparency = BackgroundTransparency
	Bar.BorderSizePixel = 0
	Bar.Name = "Bars"

	local Count = 0
	for c = 0, 16, 16 do
		for b = 3, 4 do
			Count = Count + 1
			local d
			if Count > 1 and Count < 4 then
				d = 6
				Bar.Name = "InnerBars"
			else
				d = 5
				Bar.Name = "Bars"
			end
			local e = (12 - d)*2

			local Horizontal = Bar:Clone()
			Horizontal.Position = UDim2.new(0, d, 0, b + c)
			Horizontal.Size = UDim2.new(0, e, 0, 1)
			
			local Vertical = Bar:Clone()
			Vertical.Position = UDim2.new(0, b + c, 0, d)
			Vertical.Size = UDim2.new(0, 1, 0, e)

			Horizontal.Parent = Checkbox
			Vertical.Parent = Checkbox
		end
	end

	Pixel.Name = "Corners"
	local CornerTransparency = (1 - BackgroundTransparency) * SETS.Corners + BackgroundTransparency

	for a = 3, 20, 17 do
		local F1 = Pixel:Clone()
		F1.BackgroundTransparency = CornerTransparency
		F1.Position = UDim2.new(0, a, 0, a)

		local F2 = Pixel:Clone()
		F2.BackgroundTransparency = CornerTransparency
		F2.Position = UDim2.new(0, a, 0, 23 - a)

		F1.Parent = Checkbox
		F2.Parent = Checkbox
	end

	Pixel.Name = "InnerCorners"

	for a = 4, 19, 15 do
		local F1 = Pixel:Clone()
		F1.BackgroundTransparency = BackgroundTransparency
		F1.Position = UDim2.new(0, a, 0, a)

		local F2 = Pixel:Clone()
		F2.BackgroundTransparency = BackgroundTransparency
		F2.Position = UDim2.new(0, a, 0, 23 - a)

		F1.Parent = Checkbox
		F2.Parent = Checkbox
	end

	Pixel.Name = "Edges"
	local EdgeTransparency = (1 - BackgroundTransparency) * SETS.Edges + BackgroundTransparency

	for a = 3, 20, 17 do
		for b = 4, 19, 15 do
			local F1 = Pixel:Clone()
			F1.BackgroundTransparency = EdgeTransparency
			F1.Position = UDim2.new(0, a, 0, b)

			local F2 = Pixel:Clone()
			F2.BackgroundTransparency = EdgeTransparency
			F2.Position = UDim2.new(0, b, 0, a)

			F1.Parent = Checkbox
			F2.Parent = Checkbox
		end
	end

	Pixel.Name = "InnerEdges"

	for a = 4, 19, 15 do
		for b = 5, 18, 13 do
			local F1 = Pixel:Clone()
			F1.BackgroundTransparency = BackgroundTransparency
			F1.Position = UDim2.new(0, a, 0, b)

			local F2 = Pixel:Clone()
			F2.BackgroundTransparency = BackgroundTransparency
			F2.Position = UDim2.new(0, b, 0, a)

			F1.Parent = Checkbox
			F2.Parent = Checkbox
		end
	end
	
	-- Destroy Clonable Templates
	Pixel:Destroy()
	Bar:Destroy()
end

-- Enums
local Touch = Enum.UserInputType.Touch
local MouseButton1 = Enum.UserInputType.MouseButton1

-- Interface Metamethods
local function __namecall(self, ...)
	local self = getmetatable(self).__index
	local Button = self.__index
	local Arguments = {...}
	local Method = table.remove(Arguments)

	if Method == "Destroy" then
		self._Bindable:Destroy()
	elseif Method == "ChangeState" then
		if Arguments[1] == nil or not Arguments[1] == self.State then
			local InputObject = {UserInputType = MouseButton1}
			self.Down(InputObject)
			delay(0.065, function()
				self.Up(InputObject)
			end)
		end
		return
	elseif Method == "TweenSize" or Method == "TweenSizeAndPosition" then
		return error("[SelectionControl] The \"Size\" property is locked")
	end

	return Button(Method, unpack(Arguments)) -- Button[Method](Button, unpack(Arguments))
end

local function __newindex(self, i, v)
	local self = getmetatable(self).__index
	local Button = self.__index
	
	if i == "State" then
		if self.State ~= v then
			self.State = v
			local Grid = self._Grid

			if Grid.OpenTween then
				Grid.OpenTween:Stop()
				Grid.OpenTween2:Stop()
				Grid.OpenTween = nil
				Grid.OpenTween2 = nil
			end

			if v then
				SetCheckboxColorAndTransparency(Grid, self.EnabledColor3, 0)
				FillCenter(1, Grid)
				DrawCheckmark(1, Grid)
			else
				SetCheckboxColorAndTransparency(Grid, self.Theme.ImageColor3, self.Theme.ImageTransparency)
				EraseCheckmark(1, Grid)
				EmptyCenter(1, Grid)
			end
		end
		return
	elseif i == "Size" then
		return error("[SelectionControl] The \"Size\" property is locked")
	elseif i == "Theme" then
		v = v or "Light"
		local Theme = CHECKBOX_THEMES[v]
		if Theme then
			self.Theme = Theme
			if not self.State then
				SetCheckboxColorAndTransparency(self._Grid, Theme.ImageColor3, Theme.ImageTransparency)
			end
		else
			error("[SelectionControl] Invalid theme")
		end
		return
	elseif i == "EnabledColor" then
		v = v or DEFAULT_CHECKBOX_COLOR
		local Color3Value = Colors[v]
		self.EnabledColor = v
		v = type(Color3Value) == "table" and Color3Value[500] or typeof(Color3Value) == "Color3" and Color3Value or error("[SelectionControl] Invalid Color", 2)
		self.EnabledColor3 = v
		if self.State then
			SetCheckboxColorAndTransparency(self._Grid, v, 0)
		end
		return
	elseif i == "EnabledColor3" then
		self.EnabledColor = "Unknown"
		self.EnabledColor3 = v
		if self.State then
			SetCheckboxColorAndTransparency(self._Grid, v, 0)
		end
		return
	end

	Button[i] = v
end

-- Instantiator
local SelectionControl = {}

function SelectionControl.new(Type, Parent)
	-- Types
	-- Checkbox, Radio, Switch

	-- SelectionGained()
	-- Fired when the GuiObject is being focused on with the Gamepad selector.
	-- SelectionLost()
	-- Fired when the Gamepad selector stops focusing on the GuiObject.

	local LastRipple

	local Bindable = Instance.new("BindableEvent")
	local Button = Checkbox:Clone()
	Button.Parent = Parent

	-- Cache Pixel Grid
	local Grid = {
		XOffset = 0;
		YOffset = 0;
	}

	for Name in next, SETS do
		local Count = 0
		local Objects = {}
		local Object = Button:FindFirstChild(Name)

		while Object do
			Count = Count + 1
			Object.Name = ""
			Objects[Count] = Object
			Object = Button:FindFirstChild(Name)
		end
		
		Grid[Name] = Objects
	end
	
	-- Track pixel grid
	for a = 1, 14 do
		local Existant = 14 * (a - 1)
		for b = 1, 14 do
			Grid[Existant + b] = Button[Existant + b]
		end
	end

	local self = {
		-- Public
		Theme = CHECKBOX_THEMES.Light;
		State = false;
		Disabled = false;
		StateChanged = Bindable.Event;
		EnabledColor = DEFAULT_CHECKBOX_COLOR;
		EnabledColor3 = DEFAULT_CHECKBOX_COLOR3;
		
		-- Private
		_Grid = Grid;
		_Bindable = Bindable;

		-- Protected
		__index = Button;
	}
	
	
	Button.Parent = Parent
	
	function self.Down(InputObject)
		if InputObject.UserInputType == MouseButton1 or InputObject.UserInputType == Touch then
			if LastRipple then
				Tween(LastRipple, "ImageTransparency", 1, "Deceleration", RIPPLE_EXIT_TIME, false, true)
			end
			
			local Ripple = Ripple:Clone()

			if self.State then
				Ripple.ImageColor3 = self.EnabledColor3
			else
				Ripple.ImageColor3 = self.Theme.ImageColor3
				Ripple.ImageTransparency = (1 - RIPPLE_TRANSPARENCY) * self.Theme.ImageTransparency + RIPPLE_TRANSPARENCY
			end

			Ripple.ZIndex = Button.ZIndex + 1
			Ripple.Parent = Button

			LastRipple = Ripple
			Tween(Ripple, "Size", RIPPLE_TARGET_SIZE, "Deceleration", RIPPLE_ENTER_TIME)
		end
	end

	function self.Up(InputObject)
		if InputObject.UserInputType == MouseButton1 or InputObject.UserInputType == Touch then
			if LastRipple then
				local Checked = not self.State
				self.State = Checked
				Bindable:Fire(Checked)

				if Grid.OpenTween then
					Grid.OpenTween:Stop()
					Grid.OpenTween2:Stop()
				end

				if Checked then
					SetCheckboxColorAndTransparency(Grid, self.EnabledColor3, 0)
					Grid.OpenTween = Tween.new(FILL_DURATION, CENTER_FILL_BEZIER, FillCenter, Grid)
				else
					SetCheckboxColorAndTransparency(Grid, self.Theme.ImageColor3, self.Theme.ImageTransparency)
					Grid.XOffset, Grid.YOffset = 0, 0
					Grid.OpenTween = Tween.new(DRAW_DURATION, CHECKMARK_ERASE_BEZIER, EraseCheckmark, Grid)
				end

				Grid.OpenTween2 = Tween.new(SHRINK_DURATION, OUTSIDE_TRANSPARENCY_BEZIER, ShrinkFrame, Grid)
			end
		end

		if LastRipple then
			Tween(LastRipple, "ImageTransparency", 1, "Deceleration", RIPPLE_EXIT_TIME, false, true)
			LastRipple = nil
		end
	end

	Button.InputBegan:Connect(self.Down)
	Button.InputEnded:Connect(self.Up)

	Button:GetPropertyChangedSignal("ZIndex"):Connect(function()
		local ZIndex = Button.ZIndex
		for a = 1, 196 do
			Grid[a].ZIndex = ZIndex + 2
		end
	end)

	local Interactable = newproxy(true)
	local Metatable = getmetatable(Interactable)
	Metatable.__index = setmetatable(self, self)
	Metatable.__namecall = __namecall
	Metatable.__newindex = __newindex

	return Interactable
end

return SelectionControl
