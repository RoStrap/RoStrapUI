-- Snackbar PseudoInstance
-- @documentation https://rostrap.github.io/Libraries/RoStrapUI/Snackbar/
-- @author Validark

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Resources = require(ReplicatedStorage:WaitForChild("Resources"))

local Color = Resources:LoadLibrary("Color")
local Debug = Resources:LoadLibrary("Debug")
local Tween = Resources:LoadLibrary("Tween")
local Typer = Resources:LoadLibrary("Typer")
local Enumeration = Resources:LoadLibrary("Enumeration")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")
local RoStrapPriorityUI = Resources:LoadLibrary("RoStrapPriorityUI")
local ReplicatedPseudoInstance = Resources:LoadLibrary("ReplicatedPseudoInstance")

local TEXT_SIZE = 20
local FONT = Enum.Font.SourceSans.Value
local BUTTON_FONT = Enum.Font.SourceSansSemibold.Value
local BUTTON_SIZE = 18
local CORNER_OFFSET = 8

local HEIGHT = 48
local SMALLEST_WIDTH = 294
local DISPLAY_TIME = 2

local TweenCompleted = Enum.TweenStatus.Completed
local Deceleration = Enumeration.EasingFunction.Deceleration.Value
local Acceleration = Enumeration.EasingFunction.Acceleration.Value

Enumeration.SnackbarPosition = { "Left", "Right", "Center" }

local StatePosition = {
	[Enumeration.SnackbarPosition.Left.Value] = {
		AnchorPoint = Vector2.new(0, 0);
		ExitPosition = UDim2.new(0.5, 0, 1, 0);
		EnterPosition = UDim2.new(0.5, 0, 1, -HEIGHT - CORNER_OFFSET);
	};

	[Enumeration.SnackbarPosition.Right.Value] = {
		AnchorPoint = Vector2.new(1, 0);
		ExitPosition = UDim2.new(0.5, 0, 1, 0);
		EnterPosition = UDim2.new(0.5, 0, 1, -HEIGHT - CORNER_OFFSET);
	};

	[Enumeration.SnackbarPosition.Center.Value] = {
		AnchorPoint = Vector2.new(0.5, 0);
		ExitPosition = UDim2.new(0.5, 0, 1, 0);
		EnterPosition = UDim2.new(0.5, 0, 1, -HEIGHT - CORNER_OFFSET);
	};
}

local SnackbarImage = Instance.new("ImageLabel")
SnackbarImage.BackgroundTransparency = 1
SnackbarImage.Name = "Snackbar"
SnackbarImage.ZIndex = 2
SnackbarImage.Image = "rbxassetid://1934624205"
SnackbarImage.ImageColor3 = Color3.fromRGB(50, 50, 50)
SnackbarImage.ScaleType = Enum.ScaleType.Slice.Value
SnackbarImage.SliceCenter = Rect.new(4, 4, 252, 252)
SnackbarImage.ZIndex = 3

local SnackbarText = Instance.new("TextLabel")
SnackbarText.AnchorPoint = Vector2.new(0, 0.5)
SnackbarText.BackgroundTransparency = 1
SnackbarText.Name = "SnackbarText"
SnackbarText.Position = UDim2.new(0, 16, 0.5, 0)
SnackbarText.Size = UDim2.new(1, 0, 1, -12)
SnackbarText.ZIndex = 3
SnackbarText.Font = FONT
SnackbarText.TextColor3 = Color3.fromRGB(255, 255, 255)
SnackbarText.TextSize = TEXT_SIZE
SnackbarText.TextXAlignment = Enum.TextXAlignment.Left.Value
SnackbarText.Parent = SnackbarImage

local Shadow = PseudoInstance.new("Shadow")
Shadow.Elevation = 6
Shadow.Parent = SnackbarImage

local LocalPlayer, PlayerGui do
	if RunService:IsClient() then
		repeat LocalPlayer = Players.LocalPlayer until LocalPlayer or not wait()
		repeat PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") until PlayerGui or not wait()
	end
end

local function OnActionPressed(self)
	if not self.Dismissed then
		self:Dismiss()
		self.OnAction:Fire(LocalPlayer)
	end
end

local LARGE_FRAME_SIZE = Vector2.new(32767, 32767)

local Storage = {}

local function IsInputting(CurrentlyInputting)
	for _, Bool in next, CurrentlyInputting do
		if Bool == true then
			return true
		end
	end
	return false
end

return PseudoInstance:Register("Snackbar", {
	Storage = Storage;

	WrappedProperties = {
		Object = { "Active", "LayoutOrder", "NextSelectionDown", "NextSelectionLeft", "NextSelectionRight", "NextSelectionUp" },
	};

	Methods = {
		Enter = function(self)
			self.Dismissed = false
			local SnackbarFrame = self.Object
			SnackbarFrame.Parent = self.SCREEN
			SnackbarFrame.Position = self.ExitPosition

			if Storage.OpenSnackbar then
				Storage.OpenSnackbar:Dismiss()
			end

			Storage.OpenSnackbar = self

			local CurrentlyInputting = {}

			SnackbarFrame.InputBegan:Connect(function(InputObject)
				CurrentlyInputting[InputObject.UserInputType.Value] = true
			end)

			SnackbarFrame.InputEnded:Connect(function(InputObject)
				CurrentlyInputting[InputObject.UserInputType.Value] = false
			end)

			Tween(SnackbarFrame, "Position", self.EnterPosition, Deceleration, self.ENTER_TIME, false, function(Completed)
				if Completed == TweenCompleted and wait(DISPLAY_TIME) then
					while IsInputting(CurrentlyInputting) do
						repeat wait() until not IsInputting(CurrentlyInputting)
						wait(DISPLAY_TIME)
					end

					self:Dismiss()
				end
			end)
		end;

		Dismiss = function(self)
			if not self.Dismissed then
				self.Dismissed = true
				local SnackbarFrame = self.Object
				SnackbarFrame.ZIndex = SnackbarFrame.ZIndex - 1

				Tween(SnackbarFrame, "Position", self.ExitPosition, Acceleration, self.ENTER_TIME, true, function(Completed)
					if Completed == TweenCompleted then
						SnackbarFrame.Parent = nil
						if Storage.OpenSnackbar == self then
							Storage.OpenSnackbar = nil
						end
					end
				end)
			end
		end;
	};

	Events = {
		"OnAction";
	};

	Internals = {
		"SnackbarText", "SnackbarAction", "RegisteredRippleInputs", "EnterPosition", "ExitPosition";

		SHOULD_BLUR = false;

		ActionButtonWidth = 0;
		TextWidth = 0;
		ENTER_TIME = 0.275;

		AdjustSnackbarSize = function(self)
			local Width = self.ActionButtonWidth + self.TextWidth + 16*3
			self.Object.Size = UDim2.new(0, Width > SMALLEST_WIDTH and Width or SMALLEST_WIDTH, 0, HEIGHT)
		end;
	};

	Properties = {
		SnackbarPosition = Typer.AssignSignature(2, Typer.EnumerationOfTypeSnackbarPosition, function(self, Position)
			local State = StatePosition[Position.Value]

			self.Object.AnchorPoint = State.AnchorPoint
			self.ExitPosition = State.ExitPosition
			self.EnterPosition = State.EnterPosition

			self:rawset("SnackbarPosition", Position)
		end);

		ActionText = Typer.AssignSignature(2, Typer.String, function(self, ActionText)
			if ActionText == "" then
				self.SnackbarAction.Parent = nil
				self.ActionButtonWidth = 0
			else
				self.SnackbarAction.Text = ActionText
				local Width = TextService:GetTextSize(ActionText, BUTTON_SIZE, BUTTON_FONT, LARGE_FRAME_SIZE).X + 16
				self.SnackbarAction.Size = UDim2.new(0, Width, 1, -12)
				self.ActionButtonWidth = Width
				self.SnackbarAction.Parent = self.Object
				self:rawset("ActionText", ActionText)
			end

			self:AdjustSnackbarSize()
		end);

		Text = Typer.AssignSignature(2, Typer.String, function(self, Text)
			-- Assign Text to SnackbarText.Text
			-- Update Size according to TextBounds, which shouldn't be a property of Snackbar

			self.TextWidth = TextService:GetTextSize(Text, TEXT_SIZE, FONT, LARGE_FRAME_SIZE).X
			self.SnackbarText.Text = Text
			self:AdjustSnackbarSize()
			self:rawset("Text", Text)
		end);
	},

	Init = function(self, ...)
		self.Object = SnackbarImage:Clone()
		self.SnackbarText = self.Object.SnackbarText

		local SnackbarAction = PseudoInstance.new("RippleButton")
		SnackbarAction.AnchorPoint = Vector2.new(1, 0.5)
		SnackbarAction.Name = "SnackbarAction"
		SnackbarAction.Position = UDim2.new(1, -8, 0.5, 0)
		SnackbarAction.ZIndex = 4
		SnackbarAction.Font = BUTTON_FONT
		SnackbarAction.PrimaryColor3 = Color.Purple[300]
		SnackbarAction.TextSize = BUTTON_SIZE
		SnackbarAction.Style = Enumeration.ButtonStyle.Flat.Value
--		SnackbarAction.Disabled = true

		self.Janitor:Add(SnackbarAction.OnPressed:Connect(OnActionPressed, self), "Disconnect")

		self.SnackbarAction = SnackbarAction
		self.SnackbarPosition = Enumeration.SnackbarPosition.Center

		self.Janitor:Add(self.Object, "Destroy")
		self.Janitor:Add(self.SnackbarText, "Destroy")
		self.Janitor:Add(SnackbarAction, "Destroy")

		self:superinit(...)
	end;
}, RoStrapPriorityUI)
