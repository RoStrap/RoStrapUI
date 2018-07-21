-- 2-step Choice Dialog ReplicatedPseudoInstance

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))

local Color = Resources:LoadLibrary("Color")
local Debug = Resources:LoadLibrary("Debug")
local Tween = Resources:LoadLibrary("Tween")
local Enumeration = Resources:LoadLibrary("Enumeration")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")
local ReplicatedPseudoInstance = Resources:LoadLibrary("ReplicatedPseudoInstance")

local Radio = Resources:LoadLibrary("Radio")
local Shadow = Resources:LoadLibrary("Shadow")
local RadioGroup = Resources:LoadLibrary("RadioGroup")
local RippleButton = Resources:LoadLibrary("RippleButton")

local Screen = Instance.new("ScreenGui")
Screen.Name = "RoStrapPriorityUIs"
Screen.DisplayOrder = 2^31 - 2

local DialogBlur = Instance.new("BlurEffect")
DialogBlur.Size = 0
DialogBlur.Name = "DialogBlur"
DialogBlur.Parent = game:GetService("Lighting")

local BUTTON_WIDTH_PADDING = 8
local DISMISS_TIME = 75 / 1000 * 2
local ENTER_TIME = 150 / 1000 * 2

local LocalPlayer, PlayerGui do
	if RunService:IsClient() then
		repeat LocalPlayer = Players.LocalPlayer until LocalPlayer or not wait()
		repeat PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") until PlayerGui or not wait()
	end
end

local Frame do
	Frame = Instance.new("Frame")
	Frame.BackgroundTransparency = 1
	Frame.Size = UDim2.new(1, 0, 1, 0)
	Frame.Name = "ChoiceDialog"

	local UIScale = Instance.new("UIScale")
	UIScale.Scale = 0
	UIScale.Name = "UIScale"
	UIScale.Parent = Frame

	local Background = Instance.new("ImageLabel")
	Background.BackgroundTransparency = 1
	Background.ScaleType = Enum.ScaleType.Slice
	Background.SliceCenter = Rect.new(4, 4, 256 - 4, 256 - 4)
	Background.Image = "rbxassetid://1934624205"
	Background.Size = UDim2.new(0, 280, 0, 117)
	Background.Position = UDim2.new(0.5, 0, 0.5, 0)
	Background.AnchorPoint = Vector2.new(0.5, 0.5)
	Background.Name = "Background"
	Background.ZIndex = 2
	Background.Parent = Frame

	local Header = Instance.new("TextLabel")
	Header.Font = Enum.Font.SourceSansSemibold
	Header.TextSize = 26
	Header.Size = UDim2.new(1, -24, 0, 64)
	Header.Position = UDim2.new(0, 24, 0, 1)
	Header.BackgroundTransparency = 1
	Header.TextXAlignment = Enum.TextXAlignment.Left
	Header.TextTransparency = 0.13
	Header.TextColor3 = Color.Black
	Header.Name = "Header"
	Header.ZIndex = 3
	Header.Parent = Background

	local Border = Instance.new("Frame")
	Border.BackgroundColor3 = Color.Black
	Border.BackgroundTransparency = 238 / 255
	Border.BorderSizePixel = 0
	Border.Position = UDim2.new(0, 0, 0, 64 - 2 + 1)
	Border.Size = UDim2.new(1, 0, 0, 1)
	Border.ZIndex = 3
	Border.Parent = Background

	local BottomBorder = Border:Clone()
	BottomBorder.Position = UDim2.new(0, 0, 1, -52 + 2 - 4 + 1)
	BottomBorder.Parent = Background

	local Shadow = PseudoInstance.new("Shadow")
	Shadow.Elevation = 8
	Shadow.Parent = Background
end

local function OnDismiss(self)
	self.OnConfirmed:Fire(LocalPlayer, false)
	self:Dismiss()
end

local function OnConfirm(self)
	self.OnConfirmed:Fire(LocalPlayer, self.RadioGroup:GetSelection())
	self:Dismiss()
end

local function ConfirmEnable(ConfirmButton)
	ConfirmButton.Disabled = false
end

local function HideUIScale(self)
	self.UIScale.Parent = nil
end

local DialogsActive = 0

local function SubDialogsActive()
	DialogsActive = DialogsActive - 1
end

return PseudoInstance:Register("ChoiceDialog", {
	Storage = {};

	Internals = {"Object", "ConfirmButton", "DismissButton", "RadioGroup", "AssociatedRadioContainers", "Header", "UIScale", "Background"};

	Events = {"OnConfirmed"};

	Methods = {
		Dismiss = function(self)
			-- Destroys Dialog when done
			self.UIScale.Parent = Screen
			Tween(self.UIScale, "Scale", 0, Enumeration.EasingFunction.InBack, DISMISS_TIME, true, self.Janitor)
			Tween(DialogBlur, "Size", 0, Enumeration.EasingFunction.InBack, ENTER_TIME, true)
		end;
	};

	Properties = {
		PrimaryColor3 = function(self, PrimaryColor3)
			self.ConfirmButton.PrimaryColor3 = PrimaryColor3
			self.DismissButton.PrimaryColor3 = PrimaryColor3

			for Item, ItemContainer in next, self.AssociatedRadioContainers do
				Item.PrimaryColor3 = PrimaryColor3
				ItemContainer.PrimaryColor3 = PrimaryColor3
			end

			return true
		end;

		Options = function(self, Options)
			local NumOptions = #Options
			self.Background.Size = UDim2.new(0, 280, 0, 117 + 48 * NumOptions)

			for Item, ItemContainer in next, self.AssociatedRadioContainers do
				Item:Destroy()
				ItemContainer:Destroy() -- ItemDescriptions are destroyed here
				self.AssociatedRadioContainers[Item] = nil
			end

			for i = 1, NumOptions do
				local Value = Options[i]

				if type(Value) == "string" then
					local ItemContainer = PseudoInstance.new("RippleButton")
					ItemContainer.Position = UDim2.new(0, 0, 0, 64 + 48 * (i - 1))
					ItemContainer.Size = UDim2.new(1, 0, 0, 48)
					ItemContainer.BorderRadius = 0
					ItemContainer.ZIndex = 5
					ItemContainer.Style = Enumeration.ButtonStyle.Flat
					ItemContainer.Parent = self.Background

					local Item = PseudoInstance.new("Radio")
					Item.AnchorPoint = Vector2.new(0.5, 0.5)
					Item.Position = UDim2.new(0, 36, 0.5, 0)
					Item.ZIndex = 8
					Item.Parent = ItemContainer.Object

					ItemContainer.PrimaryColor3 = self.PrimaryColor3
					Item.PrimaryColor3 = self.PrimaryColor3

					self.AssociatedRadioContainers[Item] = ItemContainer
					self.RadioGroup:Add(Item, Value)
					ItemContainer.OnPressed:Connect(Item.SetChecked, Item)

					local ItemDescription = Instance.new("TextLabel")
					ItemDescription.BackgroundTransparency = 1
					ItemDescription.Position = UDim2.new(0, 48 + 32, 0.5, 0)
					ItemDescription.TextXAlignment = Enum.TextXAlignment.Left
					ItemDescription.Font = Enum.Font.SourceSansSemibold
					ItemDescription.TextSize = 20
					ItemDescription.Text = Value
					ItemDescription.TextTransparency = 0.13
					ItemDescription.ZIndex = 8
					ItemDescription.Parent = ItemContainer.Object
				else
					Debug.Error("bad argument #3 to Options: Options must be an array of strings")
				end
			end

			return true
		end;

		HeaderText = function(self, HeaderText)
			self.Header.Text = HeaderText
			return true
		end;

		DismissText = function(self, Text)
			local DismissButton = self.DismissButton
			DismissButton.Text = Text
			DismissButton.Size = UDim2.new(0, DismissButton.TextBounds.X + BUTTON_WIDTH_PADDING * 2, 0, 36)
			return true
		end;

		ConfirmText = function(self, Text)
			local ConfirmButton = self.ConfirmButton
			ConfirmButton.Text = Text
			ConfirmButton.Size = UDim2.new(0, ConfirmButton.TextBounds.X + BUTTON_WIDTH_PADDING * 2, 0, 36)
			return true
		end;

		Parent = function(self, Parent)
			if Parent then
				Screen.Parent = PlayerGui

				self.UIScale.Parent = Screen
				self.Object.Parent = Screen
				self.DismissButton.Size = UDim2.new(0, self.DismissButton.TextBounds.X + BUTTON_WIDTH_PADDING * 2, 0, 36)
				self.ConfirmButton.Size = UDim2.new(0, self.ConfirmButton.TextBounds.X + BUTTON_WIDTH_PADDING * 2, 0, 36)
				Tween(self.UIScale, "Scale", 1, Enumeration.EasingFunction.OutBack, ENTER_TIME, true, HideUIScale, self)
				Tween(DialogBlur, "Size", 56, Enumeration.EasingFunction.OutBack, ENTER_TIME, true)
			end

			return true
		end;
	};

	Init = function(self, ...)
		self.Object = Frame:Clone()
		self.UIScale = self.Object.UIScale
		self.Background = self.Object.Background
		self.Header = self.Background.Header
		self.AssociatedRadioContainers = {}

		local ConfirmButton = PseudoInstance.new("RippleButton")
		ConfirmButton.AnchorPoint = Vector2.new(1, 1)
		ConfirmButton.Position = UDim2.new(1, -8, 1, -8)
		ConfirmButton.BorderRadius = 4
		ConfirmButton.ZIndex = 10
		ConfirmButton.TextSize = 16
		ConfirmButton.TextTransparency = 0.13
		ConfirmButton.Style = Enumeration.ButtonStyle.Flat
		ConfirmButton.Parent = self.Background

		local DismissButton = ConfirmButton:Clone()
		DismissButton.Position = UDim2.new(0, -8, 1, 0)
		DismissButton.Parent = ConfirmButton.Object

		ConfirmButton.Disabled = true

		self.ConfirmButton = ConfirmButton
		self.DismissButton = DismissButton
		self.RadioGroup = PseudoInstance.new("RadioGroup")

		self.Janitor:Add(self.RadioGroup.SelectionChanged:Connect(ConfirmEnable, ConfirmButton), "Disconnect")
		self.Janitor:Add(ConfirmButton.OnPressed:Connect(OnConfirm, self), "Disconnect")
		self.Janitor:Add(DismissButton.OnPressed:Connect(OnDismiss, self), "Disconnect")

		self.Janitor:Add(self.Object, "Destroy")
		self.Janitor:Add(self.UIScale, "Destroy")
		self.Janitor:Add(self.RadioGroup, "Destroy")
		self.Janitor:Add(SubDialogsActive, true)

		self.PrimaryColor3 = Color3.fromRGB(98, 0, 238)
		self:superinit(...)
	end;
}, ReplicatedPseudoInstance)
