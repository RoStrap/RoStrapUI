-- 2-step Choice Dialog ReplicatedPseudoInstance
-- @author Validark

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))

local Color = Resources:LoadLibrary("Color")
local Debug = Resources:LoadLibrary("Debug")
local Tween = Resources:LoadLibrary("Tween")
local Typer = Resources:LoadLibrary("Typer")
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
DialogBlur.Parent = Lighting

local BUTTON_WIDTH_PADDING = 8
local DISMISS_TIME = 75 / 1000 * 2
local ENTER_TIME = 150 / 1000 * 2

local Left = Enum.TextXAlignment.Left.Value
local SourceSansSemibold = Enum.Font.SourceSansSemibold.Value

local Flat = Enumeration.ButtonStyle.Flat.Value
local InBack = Enumeration.EasingFunction.InBack.Value
local OutBack = Enumeration.EasingFunction.OutBack.Value

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
	Header.Font = SourceSansSemibold
	Header.TextSize = 26
	Header.Size = UDim2.new(1, -24, 0, 64)
	Header.Position = UDim2.new(0, 24, 0, 1)
	Header.BackgroundTransparency = 1
	Header.TextXAlignment = Left
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
	if not self.Dismissed then
		self.OnConfirmed:Fire(LocalPlayer, false)
		self:Dismiss()
	end
end

local function OnConfirm(self)
	if not self.Dismissed then
		self.OnConfirmed:Fire(LocalPlayer, self.RadioGroup:GetSelection())
		self:Dismiss()
	end
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

	Internals = {"Object", "ConfirmButton", "DismissButton", "RadioGroup", "AssociatedRadioContainers", "Header", "UIScale", "Background", "Dismissed"};

	Events = {"OnConfirmed"};

	Methods = {
		Dismiss = function(self)
			-- Destroys Dialog when done
			if not self.Dismissed then
				self.Dismissed = true
				Tween(self.UIScale, "Scale", 0, InBack, DISMISS_TIME, true, self.Janitor)
				self.UIScale.Parent = Screen
				Tween(DialogBlur, "Size", 0, InBack, ENTER_TIME, true)
			end
		end;
	};

	Properties = {
		PrimaryColor3 = Typer.AssignSignature(2, Typer.Color3, function(self, PrimaryColor3)
			self.ConfirmButton.PrimaryColor3 = PrimaryColor3
			self.DismissButton.PrimaryColor3 = PrimaryColor3

			for Item, ItemContainer in next, self.AssociatedRadioContainers do
				Item.PrimaryColor3 = PrimaryColor3
				ItemContainer.PrimaryColor3 = PrimaryColor3
			end

			self:rawset("PrimaryColor3", PrimaryColor3)
		end);

		Options = Typer.AssignSignature(2, Typer.ArrayOfStrings, function(self, Options)
			local NumOptions = #Options
			self.Background.Size = UDim2.new(0, 280, 0, 117 + 48 * NumOptions)

			for Item, ItemContainer in next, self.AssociatedRadioContainers do
				Item:Destroy()
				ItemContainer:Destroy() -- ItemDescriptions are destroyed here
				self.AssociatedRadioContainers[Item] = nil
			end

			for i = 1, NumOptions do
				local ChoiceName = Options[i]

				local ItemContainer = PseudoInstance.new("RippleButton")
				ItemContainer.Position = UDim2.new(0, 0, 0, 64 + 48 * (i - 1))
				ItemContainer.Size = UDim2.new(1, 0, 0, 48)
				ItemContainer.BorderRadius = 0
				ItemContainer.ZIndex = 5
				ItemContainer.Style = Flat
				ItemContainer.Parent = self.Background

				local Item = PseudoInstance.new("Radio")
				Item.AnchorPoint = Vector2.new(0.5, 0.5)
				Item.Position = UDim2.new(0, 36, 0.5, 0)
				Item.ZIndex = 8
				Item.Parent = ItemContainer.Object

				ItemContainer.PrimaryColor3 = self.PrimaryColor3
				Item.PrimaryColor3 = self.PrimaryColor3

				self.AssociatedRadioContainers[Item] = ItemContainer
				self.RadioGroup:Add(Item, ChoiceName)
				ItemContainer.OnPressed:Connect(Item.SetChecked, Item)

				local ItemDescription = Instance.new("TextLabel")
				ItemDescription.BackgroundTransparency = 1
				ItemDescription.Position = UDim2.new(0, 48 + 32, 0.5, 0)
				ItemDescription.TextXAlignment = Left
				ItemDescription.Font = SourceSansSemibold
				ItemDescription.TextSize = 20
				ItemDescription.Text = ChoiceName
				ItemDescription.TextTransparency = 0.13
				ItemDescription.ZIndex = 8
				ItemDescription.Parent = ItemContainer.Object
			end

			self:rawset("Options", Options)
		end);

		HeaderText = Typer.AssignSignature(2, Typer.String, function(self, Text)
			self.Header.Text = Text
			self:rawset("HeaderText", self.Header.Text)
		end);

		DismissText = Typer.AssignSignature(2, Typer.String, function(self, Text)
			local DismissButton = self.DismissButton
			DismissButton.Text = Text
			DismissButton.Size = UDim2.new(0, DismissButton.TextBounds.X + BUTTON_WIDTH_PADDING * 2, 0, 36)
			self:rawset("DismissText", DismissButton.Text)
		end);

		ConfirmText = Typer.AssignSignature(2, Typer.String, function(self, Text)
			local ConfirmButton = self.ConfirmButton
			ConfirmButton.Text = Text
			ConfirmButton.Size = UDim2.new(0, ConfirmButton.TextBounds.X + BUTTON_WIDTH_PADDING * 2, 0, 36)
			self:rawset("ConfirmText", ConfirmButton.Text)
		end);

		Parent = function(self, Parent)
			if Parent and PlayerGui then
				Screen.Parent = PlayerGui

				self.UIScale.Parent = Screen
				self.Object.Parent = Screen
				self.DismissButton.Size = UDim2.new(0, self.DismissButton.TextBounds.X + BUTTON_WIDTH_PADDING * 2, 0, 36)
				self.ConfirmButton.Size = UDim2.new(0, self.ConfirmButton.TextBounds.X + BUTTON_WIDTH_PADDING * 2, 0, 36)
				Tween(self.UIScale, "Scale", 1, OutBack, ENTER_TIME, true, HideUIScale, self)
				Tween(DialogBlur, "Size", 56, OutBack, ENTER_TIME, true)
			end

			self:rawset("Parent", Parent)
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
		ConfirmButton.Style = Flat
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
