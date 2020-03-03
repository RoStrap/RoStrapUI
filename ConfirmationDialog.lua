local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")

local Resources = require(ReplicatedStorage:WaitForChild("Resources"))
local Color = Resources:LoadLibrary("Color")
local Tween = Resources:LoadLibrary("Tween")
local Typer = Resources:LoadLibrary("Typer")
local Enumeration = Resources:LoadLibrary("Enumeration")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")
local RoStrapPriorityUI = Resources:LoadLibrary("RoStrapPriorityUI")

Resources:LoadLibrary("ReplicatedPseudoInstance")
Resources:LoadLibrary("Shadow")
Resources:LoadLibrary("RippleButton")
Resources:LoadLibrary("EasingFunctions")

local BUTTON_WIDTH_PADDING = 8
local WIDTH = UserInputService.TouchEnabled and 460 or 560
local FRAME_SIZE = Vector2.new(WIDTH - 48, 1 / 0)
local NEW_SIZE = UDim2.new(0, WIDTH, 0, 182)

local Left = Enum.TextXAlignment.Left.Value
local SourceSans = Enum.Font.SourceSans.Value

local Flat = Enumeration.ButtonStyle.Flat.Value
local Acceleration = Enumeration.EasingFunction.Acceleration.Value
local Deceleration = Enumeration.EasingFunction.Deceleration.Value

local LocalPlayer, PlayerGui do
	if RunService:IsClient() then
		if RunService:IsServer() then
			PlayerGui = game:GetService("CoreGui")
		else
			repeat LocalPlayer = Players.LocalPlayer until LocalPlayer or not wait()
			repeat PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") until PlayerGui or not wait()
		end
	end
end

local Frame do
	Frame = Instance.new("Frame")
	Frame.BackgroundTransparency = 1
	Frame.BackgroundColor3 = Color3.new()
	Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	Frame.Size = UDim2.new(1, 0, 1, 0)
	Frame.Name = "ConfirmationDialog"

	local UIScale = Instance.new("UIScale")
	UIScale.Scale = 0
	UIScale.Name = "UIScale"
	UIScale.Parent = Frame

	local Background = Instance.new("ImageLabel")
	Background.BackgroundTransparency = 1
	Background.ScaleType = Enum.ScaleType.Slice
	Background.SliceCenter = Rect.new(4, 4, 256 - 4, 256 - 4)
	Background.Image = "rbxassetid://1934624205"
	Background.Size = NEW_SIZE
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
	Header.TextXAlignment = Left
	Header.TextTransparency = 0.13
	Header.TextColor3 = Color.Black
	Header.Name = "Header"
	Header.ZIndex = 3
	Header.Parent = Background

	local DialogText = Instance.new("TextLabel")
	DialogText.BackgroundTransparency = 1
	DialogText.Name = "PrimaryText"
	DialogText.Position = UDim2.new(0, 24, 0, 40)
	DialogText.Size = UDim2.new(1, -24, 0, 64)
	DialogText.ZIndex = 3
	DialogText.TextSize = 20
	DialogText.Font = SourceSans
	DialogText.TextXAlignment = Left
	DialogText.TextTransparency = 0.4
	DialogText.TextColor3 = Color.Black
	DialogText.TextWrapped = true
	DialogText.Parent = Background

	local Shadow = PseudoInstance.new("Shadow")
	Shadow.Elevation = 8
	Shadow.Parent = Background
end

local function OnDismiss(self)
	if not self.Dismissed then
		self:Dismiss()
		self.OnConfirmed:Fire(LocalPlayer, false)
	end
end

local function OnConfirm(self)
	if not self.Dismissed then
		self:Dismiss()
		self.OnConfirmed:Fire(LocalPlayer, true)
	end
end

local DialogsActive = 0

local function SubDialogsActive()
	DialogsActive = DialogsActive - 1
end

local function AdjustButtonSize(Button)
	Button.Size = UDim2.new(0, Button.TextBounds.X + BUTTON_WIDTH_PADDING * 2, 0, 36)
end

local function HideUIScale(self)
	self.UIScale.Parent = nil
end

local function RescaleUI(self, Text)
	local PrimaryText = self.Object.Background.PrimaryText

	if Text then
		local TextSize = TextService:GetTextSize(Text, 20, SourceSans, FRAME_SIZE).Y
		local SizeY = TextSize + 4 < 64 and 64 or TextSize + 4
		self.Object.Background.Size = UDim2.new(0, WIDTH, 0, TextSize + 40 + 52 + 24)
		PrimaryText.Size = UDim2.new(1, -24, 0, SizeY)
		PrimaryText.Position = UDim2.new(0, 24, 0, SizeY == 64 and 40 or 40 + (SizeY - 64))
	else
		local TextSize = TextService:GetTextSize(PrimaryText.Text, 20, SourceSans, FRAME_SIZE).Y
		local SizeY = TextSize + 4 < 64 and 64 or TextSize + 4
		self.Object.Background.Size = UDim2.new(0, WIDTH, 0, TextSize + 40 + 52 + 24)
		PrimaryText.Size = UDim2.new(1, -24, 0, SizeY)
		PrimaryText.Position = UDim2.new(0, 24, 0, SizeY == 64 and 40 or 40 + (SizeY - 64))
	end
end

return PseudoInstance:Register("ConfirmationDialog", {
	Storage = {};

	Internals = {
		"ConfirmButton", "DismissButton", "UIScale";
		SHOULD_BLUR = true;
	};

	Events = {"OnConfirmed"};

	Methods = {
		Enter = function(self)
			RescaleUI(self)
			self.UIScale.Parent = self.Object
			self.Object.Parent = self.SCREEN
			AdjustButtonSize(self.DismissButton)
			AdjustButtonSize(self.ConfirmButton)

			Tween(self.UIScale, "Scale", 1, Deceleration, self.ENTER_TIME, true, HideUIScale, self)
		end;

		Dismiss = function(self)
			-- Destroys Dialog when done
			if not self.Dismissed then
				self.Dismissed = true
				Tween(self.UIScale, "Scale", 0, Acceleration, self.DISMISS_TIME, true, self.Janitor)
				self.UIScale.Parent = self.Object
				self:Unblur()
			end
		end;
	};

	Properties = {
		PrimaryColor3 = Typer.AssignSignature(2, Typer.Color3, function(self, PrimaryColor3)
			self.ConfirmButton.PrimaryColor3 = PrimaryColor3
			self.DismissButton.PrimaryColor3 = PrimaryColor3
			self:rawset("PrimaryColor3", PrimaryColor3)
		end);

		HeaderText = Typer.AssignSignature(2, Typer.String, function(self, Text)
			self.Object.Background.Header.Text = Text
			self:rawset("HeaderText", Text)
		end);

		DialogText = Typer.AssignSignature(2, Typer.String, function(self, Text)
			RescaleUI(self, Text)
			self.Object.Background.PrimaryText.Text = Text
			self:rawset("DialogText", Text)
		end);

		DismissText = Typer.AssignSignature(2, Typer.String, function(self, Text)
			self.DismissButton.Text = Text
			self:rawset("DismissText", Text)
		end);

		ConfirmText = Typer.AssignSignature(2, Typer.String, function(self, Text)
			self.ConfirmButton.Text = Text
			self:rawset("ConfirmText", Text)
		end);
	};

	Init = function(self, ...)
		self:rawset("Object", Frame:Clone())
		self.UIScale = self.Object.UIScale
		
		local ConfirmButton = PseudoInstance.new("RippleButton")
		ConfirmButton.AnchorPoint = Vector2.new(1, 1)
		ConfirmButton.Position = UDim2.new(1, -8, 1, -8)
		ConfirmButton.BorderRadius = 4
		ConfirmButton.ZIndex = 10
		ConfirmButton.TextSize = 16
		ConfirmButton.TextTransparency = 0.129
		ConfirmButton.Style = Flat
		ConfirmButton.Parent = self.Object.Background

		local DismissButton = ConfirmButton:Clone()
		DismissButton.Position = UDim2.new(0, -8, 1, 0)
		DismissButton.Parent = ConfirmButton.Object

		self.Janitor:Add(DismissButton:GetPropertyChangedSignal("TextBounds"):Connect(AdjustButtonSize, DismissButton), "Disconnect")
		self.Janitor:Add(ConfirmButton:GetPropertyChangedSignal("TextBounds"):Connect(AdjustButtonSize, ConfirmButton), "Disconnect")

		self.ConfirmButton = ConfirmButton
		self.DismissButton = DismissButton

		self.Janitor:Add(ConfirmButton.OnPressed:Connect(OnConfirm, self), "Disconnect")
		self.Janitor:Add(DismissButton.OnPressed:Connect(OnDismiss, self), "Disconnect")
		self.Janitor:Add(self.UIScale, "Destroy")
		self.Janitor:Add(self.Object, "Destroy")
		self.Janitor:Add(SubDialogsActive, true)

		self.PrimaryColor3 = Color3.fromRGB(98, 0, 238)
		self:superinit(...)
	end;
}, RoStrapPriorityUI)
