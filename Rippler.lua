-- PseudoInstance to spawn Material Design Ripples inside its Parent (with rounded edge support!)
-- @author Validark

local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Resources = require(ReplicatedStorage:WaitForChild("Resources"))
local Debug = Resources:LoadLibrary("Debug")
local Tween = Resources:LoadLibrary("Tween")
local Color = Resources:LoadLibrary("Color")
local Typer = Resources:LoadLibrary("Typer")
local Janitor = Resources:LoadLibrary("Janitor")
local Enumeration = Resources:LoadLibrary("Enumeration")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")

local RIPPLE_START_DIAMETER = 0
local RIPPLE_OVERBITE = 1.05

local RippleContainer = Instance.new("Frame") -- Make sure ZIndex is higher than parent by 1
RippleContainer.AnchorPoint = Vector2.new(0.5, 0.5)
RippleContainer.BackgroundTransparency = 1
RippleContainer.BorderSizePixel = 0
RippleContainer.ClipsDescendants = true
RippleContainer.Name = "RippleContainer"
RippleContainer.Size = UDim2.new(1, 0, 1, 0)
RippleContainer.Position = UDim2.new(0.5, 0, 0.5, 0)

local RippleStartSize = UDim2.new(0, RIPPLE_START_DIAMETER, 0, RIPPLE_START_DIAMETER)

local Circle = Instance.new("ImageLabel")
Circle.AnchorPoint = Vector2.new(0.5, 0.5)
Circle.BackgroundTransparency = 1
Circle.Size = RippleStartSize
Circle.Image = "rbxassetid://517259585"
Circle.Name = "Ripple"

spawn(function()
	ContentProvider:PreloadAsync{Circle.Image}
end)

local Deceleration = Enumeration.EasingFunction.Deceleration.Value

Enumeration.RipplerStyle = {"Full", "Icon", "Round"}

local CornerData = {
	[2] = {
		0.380, 0.918,
		0.918, 1.000,
	};

	[4] = {
		0.000, 0.200, 0.690, 0.965,
		0.200, 0.965, 1.000, 1.000,
		0.690, 1.000, 1.000, 1.000,
		0.965, 1.000, 1.000, 1.000,
	};

	[8] = {
		0.000, 0.000, 0.000, 0.000, 0.224, 0.596, 0.851, 0.984,
		0.000, 0.000, 0.000, 0.596, 1.000, 1.000, 1.000, 1.000,
		0.000, 0.000, 0.722, 1.000, 1.000, 1.000, 1.000, 1.000,
		0.000, 0.596, 1.000, 1.000, 1.000, 1.000, 1.000, 1.000,
		0.224, 1.000, 1.000, 1.000, 1.000, 1.000, 1.000, 1.000,
		0.596, 1.000, 1.000, 1.000, 1.000, 1.000, 1.000, 1.000,
		0.851, 1.000, 1.000, 1.000, 1.000, 1.000, 1.000, 1.000,
		0.984, 1.000, 1.000, 1.000, 1.000, 1.000, 1.000, 1.000,
	};
}

do
	local t = {
		Radius0 = 0;
	}

	for BorderRadius, Data in next, CornerData do
		t["Radius" .. BorderRadius] = BorderRadius

		for i = 1, #Data do
			Data[i] = 1 - Data[i] -- Opacity -> Transparency
		end
	end

	Enumeration.BorderRadius = t
end

local function MakeContainer(GlobalContainer, Size, Position, ImageTransparency)
	local Container = Instance.new("ImageLabel")

	if ImageTransparency ~= nil and ImageTransparency ~= 0 then
		Container.ImageTransparency = ImageTransparency
	end

	Container.BackgroundTransparency = 1
	Container.ClipsDescendants = true
	Container.Position = Position
	Container.Size = Size
	Container.Parent = GlobalContainer
	return Container
end

local function MakeOuterBorders(RippleFrames, Container, X, Y) -- TODO: Optimize first two frames which can be eliminated
	local NumRippleFrames = #RippleFrames
	RippleFrames[NumRippleFrames + 1] = MakeContainer(Container, UDim2.new(1, -2*X, 0, 1), UDim2.new(0, X, 0, Y))
	RippleFrames[NumRippleFrames + 2] = MakeContainer(Container, UDim2.new(1, -2*X, 0, 1), UDim2.new(0, X, 1, -Y - 1))
	RippleFrames[NumRippleFrames + 3] = MakeContainer(Container, UDim2.new(0, 1, 1, -2*X), UDim2.new(0, Y, 0, X))
	RippleFrames[NumRippleFrames + 4] = MakeContainer(Container, UDim2.new(0, 1, 1, -2*X), UDim2.new(1, -Y - 1, 0, X))
end

local PixelSize = UDim2.new(0, 1, 0, 1)

local function DestroyRoundRipple(self)
	for i = 1, #self do
		local Object = self[i]
		self[i] = nil
		Object:Destroy()
	end
end;

local RoundRippleMetatable = {
	__index = function(self, i)
		if i == "Size" then
			return RippleStartSize
		elseif i == "ImageTransparency" then
			return self.Transparency
		elseif i == "Destroy" then
			return DestroyRoundRipple
		end
	end;

	__newindex = function(self, i, v)
		if i == "Size" then
			for a = 1, #self do
				self[a].Size = v
			end
		elseif i == "ImageTransparency" then
			for a = 1, #self do
				local RippleFrame = self[a]
				local Parent = RippleFrame.Parent
				if Parent then
					RippleFrame.ImageTransparency = (1 - v) * Parent.ImageTransparency + v
				end
			end
		end
	end;
}

return PseudoInstance:Register("Rippler", {
	Internals = {
		"CurrentRipple", "RippleFrames";

		SetCurrentRipple = function(self, Ripple)
			if self.CurrentRipple then
				Tween(self.CurrentRipple, "ImageTransparency", 1, Deceleration, self.RippleFadeDuration, false, true)
			end

			self.CurrentRipple = Ripple
		end
	};

	Events = {};

	Properties = {
		Style = Typer.AssignSignature(2, Typer.EnumerationOfTypeRipplerStyle, function(self, Style)
			self:rawset("Style", Style)
		end);

		BorderRadius = Typer.AssignSignature(2, Typer.EnumerationOfTypeBorderRadius, function(self, Value)
			self:rawset("BorderRadius", Value)

			local BorderRadius = Value.Value
			local RippleFrames = self.RippleFrames

			if RippleFrames then
				DestroyRoundRipple(RippleFrames)
			end

			if BorderRadius == 0 then
				self.Style = Enumeration.RipplerStyle.Full
			else
				self.Style = Enumeration.RipplerStyle.Round
				local Data = CornerData[BorderRadius]

				if not RippleFrames then
					RippleFrames = {}
					self.RippleFrames = RippleFrames
				end

				local MiddleSquarePoint
				local Container = self.Container

				for j = 0, BorderRadius - 1 do
					if Data[BorderRadius * j + (j + 1)] == 0 then
						MiddleSquarePoint = j
						break
					end
				end

				MakeOuterBorders(RippleFrames, Container, BorderRadius, 0)

				-- Make large center frame
				RippleFrames[#RippleFrames + 1] = MakeContainer(Container, UDim2.new(1, -2 * MiddleSquarePoint, 1, -2 * MiddleSquarePoint), UDim2.new(0, MiddleSquarePoint, 0, MiddleSquarePoint))

				do -- Make other bars to fill
					local X = MiddleSquarePoint
					local Y = MiddleSquarePoint - 1

					while Data[BorderRadius * Y + (X + 1)] == 0 do
						MakeOuterBorders(RippleFrames, Container, X, Y)
						X = X + 1
						Y = Y - 1
					end
				end

				do
					local a = 0
					local amax = BorderRadius * BorderRadius
					local NumRippleFrames = #RippleFrames
					while a < amax do
						local PixelTransparency = Data[a + 1]

						if PixelTransparency ~= 1 then
							if PixelTransparency ~= 0 then
								local X = a % BorderRadius
								local Y = (a - X) / BorderRadius
								local V = -1 - X
								local W = -1 - Y

								RippleFrames[NumRippleFrames + 1] = MakeContainer(Container, PixelSize, UDim2.new(0, X, 0, Y), PixelTransparency)
								RippleFrames[NumRippleFrames + 2] = MakeContainer(Container, PixelSize, UDim2.new(0, X, 1, W), PixelTransparency)
								RippleFrames[NumRippleFrames + 3] = MakeContainer(Container, PixelSize, UDim2.new(1, V, 0, Y), PixelTransparency)
								RippleFrames[NumRippleFrames + 4] = MakeContainer(Container, PixelSize, UDim2.new(1, V, 1, W), PixelTransparency)
								NumRippleFrames = NumRippleFrames + 4
							end
						end

						a = a + 1
					end
				end
			end
		end);

		RippleFadeDuration = Typer.Number;
		MaxRippleDiameter = Typer.Number;
		RippleExpandDuration = Typer.Number;

		RippleColor3 = Typer.AssignSignature(2, Typer.Color3, function(self, RippleColor3)
			if self.CurrentRipple then
				self.CurrentRipple.ImageColor3 = RippleColor3
			end

			self:rawset("RippleColor3", RippleColor3)
		end);

		RippleTransparency = Typer.AssignSignature(2, Typer.Number, function(self, RippleTransparency)
			if self.CurrentRipple then
				self.CurrentRipple.ImageTransparency = RippleTransparency
			end

			self:rawset("RippleTransparency", RippleTransparency)
		end);

		Container = Typer.AssignSignature(2, Typer.InstanceWhichIsAGuiObject, function(self, Container)
			if self.BorderRadius.Value ~= 0 then Debug.Error("Can only set container when BorderRadius is 0") end

			self.Janitor:LinkToInstance(Container)
			self.Janitor:Add(Container, "Destroy", "Container")

			self:rawset("Container", Container)
		end);

		Parent = function(self, Parent) -- Manually check this one
			if Parent == nil then
				self.Janitor:Remove("ZIndexChanged")
				self.Container.Parent = nil
			else
				local ParentType = typeof(Parent)
				local IsGuiObject = ParentType == "Instance" and Parent:IsA("GuiObject") or ParentType == "userdata" and Parent.ClassName == "RoundedFrame"

				if IsGuiObject and self.Container ~= Parent then
					local function ZIndexChanged()
						self.Container.ZIndex = Parent.ZIndex + 1
					end

					self.Janitor:Add(Parent:GetPropertyChangedSignal("ZIndex"):Connect(ZIndexChanged), "Disconnect", "ZIndexChanged")
					ZIndexChanged()
					self.Container.Parent = Parent
				else
					Debug.Error("bad argument #2 to Parent, expected GuiObject, got %s", Parent)
				end
			end

			self:rawset("Parent", Parent)
		end;
	};

	Methods = {
		Down = Typer.AssignSignature(2, Typer.OptionalNumber, Typer.OptionalNumber, function(self, X, Y)
			local Container = self.Container
			local Diameter

			local ContainerAbsoluteSizeX = Container.AbsoluteSize.X
			local ContainerAbsoluteSizeY = Container.AbsoluteSize.Y

			-- Get near corners
			X = (X or (0.5 * ContainerAbsoluteSizeX + Container.AbsolutePosition.X)) - Container.AbsolutePosition.X
			Y = (Y or (0.5 * ContainerAbsoluteSizeY + Container.AbsolutePosition.Y)) - Container.AbsolutePosition.Y

			if self.Style == Enumeration.RipplerStyle.Icon then
				Diameter = 2 * Container.AbsoluteSize.Y
				self.Container.ClipsDescendants = false
			else
				-- Get far corners
				local V = X - ContainerAbsoluteSizeX
				local W = Y - ContainerAbsoluteSizeY

				-- Calculate distance between mouse and corners
				local a = (X*X + Y*Y) ^ 0.5
				local b = (X*X + W*W) ^ 0.5
				local c = (V*V + Y*Y) ^ 0.5
				local d = (V*V + W*W) ^ 0.5

				-- Find longest distance between mouse and a corner and decide Diameter
				Diameter = 2 * (a > b and a > c and a > d and a or b > c and b > d and b or c > d and c or d) * RIPPLE_OVERBITE

				-- Cap Diameter
				if self.MaxRippleDiameter < Diameter then
					Diameter = self.MaxRippleDiameter
				end
			end

			-- Create Ripple Object
			local Ripple = Circle:Clone()
			Ripple.ImageColor3 = self.RippleColor3
			Ripple.ImageTransparency = self.RippleTransparency
			Ripple.Position = UDim2.new(0, X, 0, Y)
			Ripple.ZIndex = Container.ZIndex + 1
			Ripple.Parent = Container

			if self.Style == Enumeration.RipplerStyle.Round and self.BorderRadius.Value ~= 0 then
				local Ripples = {Transparency = Ripple.ImageTransparency}
				local RippleFrames = self.RippleFrames
				local NumRipples = #RippleFrames

				for i = 1, NumRipples do
					local RippleFrame = RippleFrames[i]
					local NewRipple = Ripple:Clone()
					local AbsolutePosition = Ripple.AbsolutePosition - RippleFrame.AbsolutePosition + 0.5*Ripple.AbsoluteSize
					NewRipple.Position = UDim2.new(0, AbsolutePosition.X, 0, AbsolutePosition.Y)
					NewRipple.ImageTransparency = (1 - self.RippleTransparency) * RippleFrame.ImageTransparency + self.RippleTransparency
					NewRipple.Parent = RippleFrame

					Ripples[i] = NewRipple
				end
				Ripple:Destroy()
				Ripple = setmetatable(Ripples, RoundRippleMetatable)
			end

			self:SetCurrentRipple(Ripple)

			return Tween(Ripple, "Size", UDim2.new(0, Diameter, 0, Diameter), Deceleration, self.RippleExpandDuration)
		end);

		Up = function(self)
			self:SetCurrentRipple(false)
		end;

		Ripple = Typer.AssignSignature(2, Typer.OptionalNumber, Typer.OptionalNumber, Typer.OptionalNumber, function(self, X, Y, Duration)
			self:Down(X, Y)

			delay(Duration or 0.15, function()
				self:SetCurrentRipple(false)
			end)
		end);
	};

	Init = function(self, Container)
		self.Style = Enumeration.RipplerStyle.Full
		self.BorderRadius = 0
		self.Container = Container or RippleContainer:Clone()
		self.RippleTransparency = 0.84
		self.RippleColor3 = Color.White
		self.MaxRippleDiameter = math.huge
		self.RippleExpandDuration = 0.5
		self.RippleFadeDuration = 1
		self:superinit()
	end;
})
