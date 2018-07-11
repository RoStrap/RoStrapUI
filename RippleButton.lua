-- Material Design Button PseudoInstances
-- @author Validark

local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Resources = require(ReplicatedStorage:WaitForChild("Resources"))
local Debug = Resources:LoadLibrary("Debug")
local Tween = Resources:LoadLibrary("Tween")
local Color = Resources:LoadLibrary("Color")
local Shadow = Resources:LoadLibrary("Shadow")
local Rippler = Resources:LoadLibrary("Rippler")
local Enumeration = Resources:LoadLibrary("Enumeration")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")

-- Elevations
local RAISED_BASE_ELEVATION = 3
local RAISED_ELEVATION = 6

local ValidInputEnums = {
	[Enum.UserInputType.Touch.Value] = true;
	[Enum.UserInputType.MouseButton1.Value] = true;
	[Enum.UserInputType.MouseButton2.Value] = true;
	[Enum.UserInputType.MouseButton3.Value] = true;
}

Enumeration.ButtonStyle = {"Custom", "Flat", "Outlined", "Contained"}

local function GetLuminosity(PrimaryColor3)
	return PrimaryColor3.r * 0.299 + PrimaryColor3.g * 0.587 + PrimaryColor3.b * 0.114
end

local CLICK_RIPPLE_TRANSPARENCY = 0.77
local HOVER_RIPPLE_TRANSPARENCY = 0.93

local StateOpacity = { -- TODO: Derive these values based on the PrimaryColor3's luminosity
	-- Material Design specs have values which are more subtle, which I don't think look ideal
	[Enumeration.ButtonStyle.Flat.Value] = {
		Hover = 0.12;-- 0.08;
		Pressed = 0.265; --0.09;
	};

	[Enumeration.ButtonStyle.Outlined.Value] = {
		Hover = 0.12; -- 0.035;
		Pressed = 0.265; --0.125;
	};

	[Enumeration.ButtonStyle.Contained.Value] = {
		Hover = 0.12; --0.075;
		Pressed = 0.265;
	};
}

local RaisedImages = {
	[2] = "rbxassetid://1934672242";
	[4] = "rbxassetid://1934624205";
	[8] = "rbxassetid://1935044829";
}

local OutlinedImages = {
	[2] = "rbxassetid://1981015282";
	[4] = "rbxassetid://1981015668";
	[8] = "rbxassetid://1981285569";
}

local ImageButton = Instance.new("ImageButton")
ImageButton.BackgroundTransparency = 1
ImageButton.ScaleType = Enum.ScaleType.Slice

local TextLabel = Instance.new("TextLabel")
TextLabel.BackgroundTransparency = 1
TextLabel.Font = Enum.Font.SourceSansSemibold
TextLabel.Size = UDim2.new(1, 0, 1, 0)
TextLabel.Text = ""
TextLabel.TextSize = 16
TextLabel.Parent = ImageButton

local OutlineImage = Instance.new("ImageLabel")
OutlineImage.BackgroundTransparency = 1
OutlineImage.Size = UDim2.new(1, 0, 1, 0)
OutlineImage.ScaleType = Enum.ScaleType.Slice
OutlineImage.ImageTransparency = 0.88
OutlineImage.Name = "Outline"
OutlineImage.ImageColor3 = Color.Black

local TOOLTIP_BORDER_RADIUS = 4

local TooltipObject = Instance.new("ImageLabel")
TooltipObject.BackgroundTransparency = 1
TooltipObject.ScaleType = Enum.ScaleType.Slice
TooltipObject.ImageTransparency = 0.1
TooltipObject.ImageColor3 = Color3.fromRGB(97, 97, 97)
TooltipObject.Image = RaisedImages[TOOLTIP_BORDER_RADIUS]
TooltipObject.SliceCenter = Rect.new(TOOLTIP_BORDER_RADIUS, TOOLTIP_BORDER_RADIUS, 256 - TOOLTIP_BORDER_RADIUS, 256 - TOOLTIP_BORDER_RADIUS)
TooltipObject.Name = "Tooltip"
TooltipObject.Parent = ImageButton
TooltipObject.AnchorPoint = Vector2.new(0.5, 0)
TooltipObject.Position = UDim2.new(0.5, 0, 1, 8)

local ToolTipLabel = TextLabel:Clone()
ToolTipLabel.TextColor3 = Color.White
ToolTipLabel.TextSize = 12
ToolTipLabel.TextTransparency = 1
ToolTipLabel.Parent = TooltipObject

local Touch = Enum.UserInputType.Touch
local MouseButton1 = Enum.UserInputType.MouseButton1
local MouseMovement = Enum.UserInputType.MouseMovement

local Invisify = {UserInputType = MouseMovement}

return PseudoInstance:Register("RippleButton", {
	Internals = {
		"TextLabel", "Rippler", "OutlineImage", "OverlayOpacity", "Shadow", "TooltipObject", "InputBegan", "InputEnded";
	};

	Events = {};

	Properties = {
		Tooltip = Enumeration.ValueType.String;

		BorderRadius = function(self, BorderRadius)
			BorderRadius = Enumeration.BorderRadius:Cast(BorderRadius)

			local Value = BorderRadius.Value
			local SliceCenter = Rect.new(Value, Value, 256 - Value, 256 - Value)

			self.Object.Image = RaisedImages[Value]
			self.Object.SliceCenter = SliceCenter
			self.Rippler.BorderRadius = Value

			if self.Style == Enumeration.ButtonStyle.Outlined then
				self.OutlineImage.Image = OutlinedImages[Value]
				self.OutlineImage.SliceCenter = SliceCenter
			end

			self:rawset("BorderRadius", BorderRadius)
		end;

		Style = function(self, ButtonStyle)
			if ButtonStyle == "Raised" then -- Raised is a permissable alias for Contained
				ButtonStyle = Enumeration.ButtonStyle.Contained
			else
				ButtonStyle = Enumeration.ButtonStyle:Cast(ButtonStyle)
			end

			self:rawset("Style", ButtonStyle)

			local StateData = StateOpacity[ButtonStyle.Value]
			self.OverlayOpacity = StateData.Hover
			self.Rippler.RippleTransparency = 1 - StateData.Pressed

			local IsOutlined = ButtonStyle == Enumeration.ButtonStyle.Outlined

			if ButtonStyle == Enumeration.ButtonStyle.Flat or IsOutlined then
				self.Object.ImageTransparency = 1
				self.Object.ImageColor3 = self.PrimaryColor3

				if self.Shadow then
					self.Shadow:Destroy()
					self.Shadow = nil
				end

				self:rawset("Elevation", Enumeration.ShadowElevation.Elevation0)
			elseif ButtonStyle == Enumeration.ButtonStyle.Contained then
				self.Object.ImageTransparency = 0
				-- self.Object.ImageColor3 = self.PrimaryColor3
				self.PrimaryColor3 = self.PrimaryColor3

				self.Shadow = PseudoInstance.new("Shadow")
				self.Shadow.Parent = self.Object

				self.Elevation = 3
			end

			if IsOutlined then
				self.OutlineImage = OutlineImage:Clone()
				self.OutlineImage.Parent = self.Object
				local Value = self.BorderRadius.Value

				self.OutlineImage.Image = OutlinedImages[Value]
				self.OutlineImage.SliceCenter = Rect.new(Value, Value, 256 - Value, 256 - Value)
			elseif self.OutlineImage then
				self.OutlineImage:Destroy()
				self.OutlineImage = nil
			end
		end;

		PrimaryColor3 = function(self, PrimaryColor3)
			if typeof(PrimaryColor3) ~= "Color3" then Debug.Error("bad argument #3 to PrimaryColor3: expected Color3, got %s", PrimaryColor3) end

			if self.Style == Enumeration.ButtonStyle.Contained then
				local TextColor3 = 0.5 < PrimaryColor3.r * 0.299 + PrimaryColor3.g * 0.587 + PrimaryColor3.b * 0.114 and Color.Black or Color.White

				self.Rippler.RippleColor3 = TextColor3
				self.TextLabel.TextColor3 = TextColor3
				self.Object.ImageColor3 = PrimaryColor3
			else
				self.Rippler.RippleColor3 = PrimaryColor3
				self.TextLabel.TextColor3 = PrimaryColor3
				self.Object.ImageColor3 = PrimaryColor3
			end

			return true
		end;

		Visible = function(self, Visible)
			self.Object.Visible = Visible

			if Visible then
				-- self.InputBegan(Invisify)
			else
				self.InputEnded(Invisify)
			end

			return true
		end;

		ZIndex = function(self, ZIndex)
			self.Object.ZIndex = ZIndex + 1
			self.TextLabel.ZIndex = ZIndex + 3
			self.TooltipObject.ZIndex = ZIndex + 1
		end;
	};

	Methods = {};

	Init = function(self)
		self:rawset("Object", ImageButton:Clone())
		self.TextLabel = self.Object.TextLabel
		self.TooltipObject = self.Object.Tooltip

		self.Rippler = PseudoInstance.new("Rippler")
		self.Rippler.RippleTransparency = 0.68
		self.Rippler.Parent = self.Object

		self.PrimaryColor3 = Color.Black
		self.Style = Enumeration.ButtonStyle.Flat
		self.BorderRadius = 4
		self.Tooltip = ""
		self.ZIndex = 1

		local Int = 0
		local IsHovered = false

		function self.InputBegan(InputObject)
			if ValidInputEnums[InputObject.UserInputType.Value] then
				self.Rippler:Down(InputObject.Position.X, InputObject.Position.Y)
				if self.Style == Enumeration.ButtonStyle.Contained then
					self.Shadow:ChangeElevation(self.Elevation + 5)
				end
			elseif InputObject.UserInputType == MouseMovement then
				IsHovered = true

				if self.Style == Enumeration.ButtonStyle.Contained then
					Tween(self.Object, "ImageColor3", self.PrimaryColor3:Lerp(self.Rippler.RippleColor3, self.OverlayOpacity), Enumeration.EasingFunction.Deceleration, 0.1, true)
				else
					Tween(self.Object, "ImageTransparency", 1 - self.OverlayOpacity, Enumeration.EasingFunction.Deceleration, 0.1, true)
				end

				if self.Tooltip ~= "" then
					-- Over 150ms, tooltips fade in and scale up using the deceleration curve. They fade out over 75ms.
					local TooltipObj = self.TooltipObject
					TooltipObj.TextLabel.Text = self.Tooltip

					local NewInt = Int + 1
					Int = NewInt

					delay(0.5, function()
						if NewInt == Int then
							Tween(TooltipObj, "Size", UDim2.new(0, TooltipObj.TextLabel.TextBounds.X + 16, 0, 24), Enumeration.EasingFunction.Deceleration, 0.1, true)
							Tween(TooltipObj, "ImageTransparency", 0.1, Enumeration.EasingFunction.Deceleration, 0.1, true)
							Tween(TooltipObj.TextLabel, "TextTransparency", 0, Enumeration.EasingFunction.Deceleration, 0.1, true)
						end
					end)
				end
			end
		end

		function self.InputEnded(InputObject)
			self.Rippler:Up()

			if self.Style == Enumeration.ButtonStyle.Contained then
				self.Shadow:ChangeElevation(self.Elevation)
			end

			local UserInputType = InputObject.UserInputType

			if UserInputType == MouseMovement then
				if self.Style == Enumeration.ButtonStyle.Contained then
					Tween(self.Object, "ImageColor3", self.PrimaryColor3, Enumeration.EasingFunction.Deceleration, 0.1, true)
				else
					Tween(self.Object, "ImageTransparency", 1, Enumeration.EasingFunction.Deceleration, 0.1, true)
				end
				IsHovered = false
			end

			Int = Int + 1

			local TooltipObj = self.TooltipObject
			Tween(TooltipObj, "Size", UDim2.new(), Enumeration.EasingFunction.Deceleration, 0.075, true)
			Tween(TooltipObj, "ImageTransparency", 1, Enumeration.EasingFunction.Deceleration, 0.075, true)
			Tween(TooltipObj.TextLabel, "TextTransparency", 1, Enumeration.EasingFunction.Deceleration, 0.075, true)
		end

		self.Object.InputBegan:Connect(self.InputBegan)
		self.Object.InputEnded:Connect(self.InputEnded)

		self.Object.InputChanged:Connect(function(InputObject)
			if InputObject.UserInputType == MouseMovement and not IsHovered then
				IsHovered = true
				self.InputBegan(InputObject)
			end
		end)

		self:superinit()
	end;
})
	:WrapProperties("Object", "AnchorPoint", "Active", "Name", "Parent", "Size", "Position", "LayoutOrder", "NextSelectionDown", "NextSelectionLeft", "NextSelectionRight", "NextSelectionUp")
	:WrapProperties("TextLabel", "Font", "Text", "TextSize")
	:WrapProperties("Shadow", "Elevation")
