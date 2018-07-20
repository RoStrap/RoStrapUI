-- Material Checkbox
-- @specs https://material.io/guidelines/components/selection-controls.html
-- @author Validark

local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Resources = require(ReplicatedStorage:WaitForChild("Resources"))
local Debug = Resources:LoadLibrary("Debug")
local Tween = Resources:LoadLibrary("Tween")
local Color = Resources:LoadLibrary("Color")
local Enumeration = Resources:LoadLibrary("Enumeration")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")
local SelectionController = Resources:LoadLibrary("SelectionController")

local CLICK_RIPPLE_TRANSPARENCY = 0.77 -- 0.88
local HOVER_RIPPLE_TRANSPARENCY = 0.93 -- 0.96

-- Images
local CHECKED_CHECKBOX_IMAGE = "rbxassetid://1990905054"
local UNCHECKED_CHECKBOX_IMAGE = "rbxassetid://1990916223"
local INDETERMINATE_CHECKBOX_IMAGE = "rbxassetid://1990919246"

-- Preload Images
ContentProvider:PreloadAsync{CHECKED_CHECKBOX_IMAGE, UNCHECKED_CHECKBOX_IMAGE}

-- Configuration
local ANIMATION_TIME = 0.125

-- Constants
local SHRINK_DURATION = ANIMATION_TIME --* 0.95
local DRAW_DURATION = ANIMATION_TIME * (1 / 0.7501)
local FILL_DURATION = ANIMATION_TIME * (1 / 0.9286)
local DEFAULT_CHECKBOX_COLOR3 = Color.Teal[500]
local CHECKBOX_SIZE = UDim2.new(0, 24, 0, 24)

local CHECKBOX_THEMES = {
	[Enumeration.MaterialTheme.Light.Value] = {
		ImageColor3 = Color.Black;
		ImageTransparency = 0.46;
		DisabledTransparency = 0.74;
	};

	[Enumeration.MaterialTheme.Dark.Value] = {
		ImageColor3 = Color.White;
		ImageTransparency = 0.3;
		DisabledTransparency = 0.7;
	};
};

-- Bezier Curves (defined in the `Easing` module)
local CHECKMARK_DRAW_BEZIER = "Deceleration"
local CHECKMARK_ERASE_BEZIER = "Deceleration"
local CENTER_FILL_BEZIER = "Deceleration"
local CENTER_EMPTY_BEZIER = "Deceleration"
local OUTSIDE_TRANSPARENCY_BEZIER = "Deceleration"

-- Import Math Functions
local ceil = math.ceil
local floor = math.floor

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

local function ExpandFrame(self, x)
	local Grid = self.Grid
	local ImageTransparency = self.ImageTransparency
	local ImageOpacity = 1 - ImageTransparency

	for Name, Start in next, SETS_GOALS do
		Start = ImageOpacity * Start + ImageTransparency
		local End = ImageOpacity * SETS[Name] + ImageTransparency - Start
		local Objects = Grid[Name]

		for a = 1, #Objects do
			Objects[a].BackgroundTransparency = Start + x * End
		end
	end
end

local function ShrinkFrame(self, x)
	local Grid = self.Grid
	local ImageTransparency = self.ImageTransparency
	local ImageOpacity = 1 - ImageTransparency

	for Name, Start in next, SETS do
		Start = ImageOpacity * Start + ImageTransparency
		local End = ImageOpacity * SETS_GOALS[Name] + ImageTransparency - Start
		local Objects = Grid[Name]

		for a = 1, #Objects do
			Objects[a].BackgroundTransparency = Start + x * End
		end
	end

	if x == 1 then
		self.OpenTween2 = Tween.new(SHRINK_DURATION, OUTSIDE_TRANSPARENCY_BEZIER, ExpandFrame, self)
	end
end

local function DrawCheckmark(self, x)
	local Grid = self.Grid

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

		if a == 2 then
			self.Button.Image = CHECKED_CHECKBOX_IMAGE
			self.Button.ImageTransparency = 0
			self.GridFrame.Visible = false
		end
	end
	Grid[160].BackgroundTransparency = 0.5 -- 12, 6
end

local function FillCenter(self, x)
	local Grid = self.Grid
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

	local OpenTween = self.OpenTween
	if CurrentSize == 7 and OpenTween then
		self.OpenTween:Stop()
		self.OpenTween = Tween.new(DRAW_DURATION, CHECKMARK_DRAW_BEZIER, DrawCheckmark, self)
	end
end

local function EmptyCenter(self, x)
	local Grid = self.Grid
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
			local BackgroundTransparency = 0.5 * (self.ImageTransparency + 1) -- CompoundTransparency
			Grid[14 * (Start - 1) + a].BackgroundTransparency = BackgroundTransparency
			Grid[14 * (a - 1) + Start].BackgroundTransparency = BackgroundTransparency
			Grid[14 * (End - 1) + a].BackgroundTransparency = BackgroundTransparency
			Grid[14 * (a - 1) + End].BackgroundTransparency = BackgroundTransparency
		end
	end

	if CurrentSize == 7 then
		self.Button.Image = UNCHECKED_CHECKBOX_IMAGE
		self.Button.ImageTransparency = CHECKBOX_THEMES[self.Theme.Value].ImageTransparency
		self.GridFrame.Visible = false
	end
end

local function EraseCheckmark(self, x)
	local Grid = self.Grid
	local ImageTransparency = self.ImageTransparency
	local XOffset, YOffset = self.XOffset, self.YOffset
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

	self.XOffset, self.YOffset = NewXOffset, NewYOffset

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

	local OpenTween = self.OpenTween
	if a == 9 and OpenTween then
		self.OpenTween:Stop()
		for a = 1, 196 do
			Grid[a].BackgroundTransparency = ImageTransparency
		end
		self.OpenTween = Tween.new(FILL_DURATION, CENTER_EMPTY_BEZIER, EmptyCenter, self)
	end
end

local Checkbox do
	local MIDDLE_ANCHOR = Vector2.new(0.5, 0.5)
	local MIDDLE_POSITION = UDim2.new(0.5, 0, 0.5, 0)

	Checkbox = Instance.new("ImageButton")
	Checkbox.BackgroundTransparency = 1
	Checkbox.Size = CHECKBOX_SIZE
	Checkbox.Image = UNCHECKED_CHECKBOX_IMAGE

	local Pixel = Instance.new("Frame")
	Pixel.BackgroundTransparency = 1
	Pixel.BackgroundColor3 = Color.Black
	Pixel.BorderSizePixel = 0
	Pixel.Size = UDim2.new(0, 1, 0, 1)

	local GridFrame = Instance.new("Frame")
	GridFrame.AnchorPoint = MIDDLE_ANCHOR
	GridFrame.BackgroundTransparency = 1
	GridFrame.Name = "GridFrame"
	GridFrame.Position = MIDDLE_POSITION
	GridFrame.Size = CHECKBOX_SIZE
	GridFrame.Visible = false
	GridFrame.Parent = Checkbox

	for a = 1, 14 do
		local Existant = 14 * (a - 1)
		for b = 1, 14 do
			local Pixel = Pixel:Clone()
			Pixel.Name = Existant + b
			Pixel.Position = UDim2.new(0, b + 4, 0, a + 4)
			Pixel.Parent = GridFrame
		end
	end

	local BackgroundTransparency = CHECKBOX_THEMES[Enumeration.MaterialTheme.Light.Value].ImageTransparency

	local Bar = Instance.new("Frame")
	Bar.BackgroundColor3 = Color.Black
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

			Horizontal.Parent = GridFrame
			Vertical.Parent = GridFrame
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

		F1.Parent = GridFrame
		F2.Parent = GridFrame
	end

	Pixel.Name = "InnerCorners"

	for a = 4, 19, 15 do
		local F1 = Pixel:Clone()
		F1.BackgroundTransparency = BackgroundTransparency
		F1.Position = UDim2.new(0, a, 0, a)

		local F2 = Pixel:Clone()
		F2.BackgroundTransparency = BackgroundTransparency
		F2.Position = UDim2.new(0, a, 0, 23 - a)

		F1.Parent = GridFrame
		F2.Parent = GridFrame
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

			F1.Parent = GridFrame
			F2.Parent = GridFrame
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

			F1.Parent = GridFrame
			F2.Parent = GridFrame
		end
	end

	-- Destroy Clonable Templates
	Pixel:Destroy()
	Bar:Destroy()
end

return PseudoInstance:Register("Checkbox", {
	Internals = {
		"OpenTween", "OpenTween2", "Grid", "", "", "GridFrame";

		ImageTransparency = 0;
		XOffset = 0;
		YOffset = 0;

		Template = Checkbox;

		SetColorAndTransparency = function(self, Color3, Transparency)
			local Grid = self.Grid
			local Opacity = (1 - Transparency)

			self.HoverRippler.RippleColor3 = Color3
			self.ClickRippler.RippleColor3 = Color3

			self.HoverRippler.RippleTransparency = Opacity * HOVER_RIPPLE_TRANSPARENCY + Transparency
			self.ClickRippler.RippleTransparency = Opacity * CLICK_RIPPLE_TRANSPARENCY + Transparency

			self.Button.ImageTransparency = Transparency
			self.Button.ImageColor3 = Color3

			for Name, BackgroundTransparency in next, SETS do
				local PixelTransparency = Opacity * BackgroundTransparency + Transparency
				local Objects = Grid[Name]

				for a = 1, #Objects do
					local Object = Objects[a]
					Object.BackgroundColor3 = Color3
					Object.BackgroundTransparency = PixelTransparency
				end
			end

			self.ImageTransparency = Transparency

			for a = 1, 196 do
				local Pixel = Grid[a]
				Pixel.BackgroundColor3 = Color3
				Pixel.BackgroundTransparency = Opacity * Pixel.BackgroundTransparency + Transparency -- CompoundTransparency
			end
		end;
	};

	WrappedProperties = {
		Button = {"AnchorPoint", "Name", "Parent", "Position", "LayoutOrder", "NextSelectionDown", "NextSelectionLeft", "NextSelectionRight", "NextSelectionUp"};
	};

	Properties = {
		Indeterminate = function(self, Indeterminate)
			if type(Indeterminate) ~= "boolean" then Debug.Error("Expected Indeterminate to be a boolean, got %s", Indeterminate) end

			if Indeterminate then
				if self.Checked then
					self:rawset("Checked", false)
				end
				self:SetColorAndTransparency(self.PrimaryColor3, 0)
				FillCenter(self, 1)
				self.Button.Image = INDETERMINATE_CHECKBOX_IMAGE
			end

			return true
		end;

		Checked = function(self, Value)
			if type(Value) ~= "boolean" then Debug.Error("Expected Value to be a boolean, got %s", Value) end
			self:rawset("Checked", Value)
			self.Indeterminate = false

			if self.OpenTween then
				self.OpenTween:Stop()
				self.OpenTween2:Stop()
				self.OpenTween = false
				self.OpenTween2 = false
			end

			if Value then
				self:SetColorAndTransparency(self.PrimaryColor3, 0)
				FillCenter(self, 1)
				DrawCheckmark(self, 1)
			else
				local Theme = CHECKBOX_THEMES[self.Theme.Value]
				self:SetColorAndTransparency(Theme.ImageColor3, Theme.ImageTransparency)
				EraseCheckmark(self, 1)
				EmptyCenter(self, 1)
			end

			self.OnChecked:Fire(Value)
			return true
		end;

		ZIndex = function(self, ZIndex)
			local Grid = self.Grid
			self.GridFrame.ZIndex = ZIndex

			for a = 1, 196 do
				Grid[a].ZIndex = ZIndex
			end

			for Name in next, SETS do
				local Set = Grid[Name]
				for a = 1, #Set do
					Set[a].ZIndex = ZIndex
				end
			end

			self.Button.ZIndex = ZIndex + 1
			return true
		end;
	};

	Events = {};

	Methods = {
		SetChecked = function(self, NewChecked)
			if NewChecked == nil then NewChecked = not self.Checked end
			if type(NewChecked) ~= "boolean" then Debug.Error("bad argument #2 to SetChecked: expected boolean, got %s", NewChecked) end
			local Button = self.Button

			if self.OpenTween then
				self.OpenTween:Stop()
				self.OpenTween2:Stop()
			end

			if NewChecked ~= self.Checked then
				self.GridFrame.Visible = true

				if Button.Size == CHECKBOX_SIZE then
					if NewChecked then
						self:SetColorAndTransparency(self.PrimaryColor3, 0)
						Button.ImageTransparency = 1
						self.OpenTween = self.Indeterminate and Tween.new(DRAW_DURATION, CHECKMARK_DRAW_BEZIER, DrawCheckmark, self) or Tween.new(FILL_DURATION, CENTER_FILL_BEZIER, FillCenter, self)
						self.OpenTween2 = Tween.new(SHRINK_DURATION, OUTSIDE_TRANSPARENCY_BEZIER, ShrinkFrame, self)
					else
						local Theme = CHECKBOX_THEMES[self.Theme.Value]

						self:SetColorAndTransparency(Theme.ImageColor3, Theme.ImageTransparency)
						Button.ImageTransparency = 1
						self.XOffset, self.YOffset = 0, 0
						self.OpenTween = Tween.new(DRAW_DURATION, CHECKMARK_ERASE_BEZIER, EraseCheckmark, self)
						self.OpenTween2 = Tween.new(SHRINK_DURATION, OUTSIDE_TRANSPARENCY_BEZIER, ShrinkFrame, self)
					end

					self:rawset("Checked", NewChecked)
					self.Indeterminate = false -- These two lines happen implicitly for the self.Checked = NewChecked statement
					self.OnChecked:Fire(NewChecked)
				else
					self.Checked = NewChecked
				end
			end
		end;
	};

	Init = function(self)
		self.Button = self.Template:Clone()
		local GridFrame = self.Button.GridFrame
		local Grid = {}

		-- Private
		self.Grid = Grid
		self.GridFrame = GridFrame

		for Name in next, SETS do
			local Count = 0
			local Objects = {}
			local Pixel = GridFrame:FindFirstChild(Name)

			while Pixel do
				Count = Count + 1
				Pixel.Name = ""
				Objects[Count] = Pixel
				Pixel = GridFrame:FindFirstChild(Name)
			end

			Grid[Name] = Objects
		end

		-- Track pixel grid
		for a = 1, 14*14 do
			Grid[a] = GridFrame[a]
		end

		local Mouse = Players.LocalPlayer:GetMouse()

		self.Button.MouseEnter:Connect(function()
			Mouse.Icon = "rbxassetid://1990755280"
		end)

		self.Button.MouseLeave:Connect(function()
			Mouse.Icon = ""
		end)

		self:superinit()

		-- Public
		self.ZIndex = 1
	end;
}, SelectionController)
