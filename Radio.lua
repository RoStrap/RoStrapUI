-- Radio Button PseudoInstance
-- @author Validark

local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))

local Color = Resources:LoadLibrary("Color")
local Tween = Resources:LoadLibrary("Tween")
local Enumeration = Resources:LoadLibrary("Enumeration")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")
local SelectionController = Resources:LoadLibrary("SelectionController")

local CHECKED_IMAGE = "rbxassetid://2012883990"
local UNCHECKED_IMAGE = "rbxassetid://2012883770"
local DEFAULT_SIZE = UDim2.new(0, 24, 0, 24)

local RadioButton = Instance.new("ImageButton")
RadioButton.BackgroundTransparency = 1
RadioButton.Size = DEFAULT_SIZE
RadioButton.Image = UNCHECKED_IMAGE
RadioButton.ImageColor3 = Color.Black
RadioButton.ImageTransparency = 0.46

local CLICK_RIPPLE_TRANSPARENCY = 0.77
local HOVER_RIPPLE_TRANSPARENCY = 0.93
local ANIMATION_TIME = 0.125

local Circle = Instance.new("ImageLabel")
Circle.AnchorPoint = Vector2.new(0.5, 0.5)
Circle.BackgroundTransparency = 1
Circle.ImageTransparency = 1
Circle.Position = UDim2.new(0.5, 0, 0.5, 0)
Circle.Size = UDim2.new(1, 0, 1, 0)
Circle.Image = "rbxassetid://517259585"
Circle.Name = "InnerCircle"
Circle.Parent = RadioButton

local RippleCheckedSize = UDim2.new(10 / 24, 0, 10 / 24, 0)
local RippleUncheckedSize = UDim2.new(20 / 24, 0, 20 / 24, 0)

ContentProvider:PreloadAsync{CHECKED_IMAGE, UNCHECKED_IMAGE}

local Deceleration = Enumeration.EasingFunction.Deceleration.Value

return PseudoInstance:Register("Radio", {
	Internals = {
		"InnerCircle";

		RippleCheckedFinished = function(self, TweenStatus)
			if TweenStatus == Enum.TweenStatus.Completed then
				self.Button.Image = CHECKED_IMAGE
				self.InnerCircle.Visible = false
			end
		end;

		SetColorAndTransparency = function(self, Color3, Transparency)
			local Opacity = (1 - Transparency)

			self.HoverRippler.RippleColor3 = Color3
			self.ClickRippler.RippleColor3 = Color3

			self.HoverRippler.RippleTransparency = Opacity * HOVER_RIPPLE_TRANSPARENCY + Transparency
			self.ClickRippler.RippleTransparency = Opacity * CLICK_RIPPLE_TRANSPARENCY + Transparency

			self.Button.ImageTransparency = Transparency
			self.Button.ImageColor3 = Color3
		end;
	};

	Properties = {
		Checked = function(self, Checked)
			if type(Checked) == "boolean" then
				if Checked then
					self:SetColorAndTransparency(self.PrimaryColor3, 0)
					self.Button.Image = CHECKED_IMAGE
				else
					local MyTheme = self.Themes[self.Theme.Value]

					self:SetColorAndTransparency(MyTheme.ImageColor3, MyTheme.ImageTransparency)
					self.Button.Image = UNCHECKED_IMAGE
				end

				return true
			else
				return false
			end
		end;
	};

	Methods = {
		SetChecked = function(self, Value)
			if Value == nil then Value = true end
			self:rawset("Checked", Value)
			local Button = self.Button
			local InnerCircle = self.InnerCircle
			InnerCircle.ImageColor3 = self.PrimaryColor3
			InnerCircle.Visible = true

			if Value then
				self:SetColorAndTransparency(self.PrimaryColor3, 0)

				Tween(InnerCircle, "Size", RippleCheckedSize, Deceleration, ANIMATION_TIME, true)
				Tween(InnerCircle, "ImageTransparency", 0, Deceleration, ANIMATION_TIME, true, self.RippleCheckedFinished, self)
			else
				local MyTheme = self.Themes[self.Theme.Value]
				self:SetColorAndTransparency(MyTheme.ImageColor3, MyTheme.ImageTransparency)

				Button.Image = UNCHECKED_IMAGE
				Tween(InnerCircle, "Size", RippleUncheckedSize, Deceleration, ANIMATION_TIME, true)
				Tween(InnerCircle, "ImageTransparency", 1, Deceleration, ANIMATION_TIME, true)
			end
		end;
	};

	Init = function(self)
		self.Button = RadioButton:Clone()
		self.InnerCircle = self.Button.InnerCircle
		self:superinit()
	end;
}, SelectionController)
	:WrapProperties("Button", "AnchorPoint", "Name", "Parent", "Size", "Position", "LayoutOrder", "NextSelectionDown", "NextSelectionLeft", "NextSelectionRight", "NextSelectionUp")
