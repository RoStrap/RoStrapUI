-- Simple Snackbar Generator
-- @readme https://github.com/RoStrap/UI/blob/master/README.md
-- @documentation https://rostrap.github.io/Libraries/Material/Snackbar/
-- @rostrap Snackbar
-- @author Validark

-- Snackbar.new(string Text, ScreenGui Screen)
--	Generates a SnackbarFrame with message Text
--	Expect more parameters in the future
-- @spec https://material.io/guidelines/components/snackbars-toasts.html

local HEIGHT = 48
local ENTER_TIME = 0.275
local DISPLAY_TIME = 2
local SMALLEST_WIDTH = 294

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))
local Enumeration = Resources:LoadLibrary("Enumeration")
local Maid = Resources:LoadLibrary("Maid")
local Tween = Resources:LoadLibrary("Tween")

Enumeration.SnackbarPositions = {"Left", "Right", "Center"}

local TweenCompleted = Enum.TweenStatus.Completed

HEIGHT = HEIGHT + 6
local OpenSnackbar, OpenTween

local DefaultSnackbar = Instance.new("ImageLabel")
DefaultSnackbar.BackgroundTransparency = 1
DefaultSnackbar.Image = "rbxasset://textures/ui/btn_newWhite.png"
DefaultSnackbar.ImageColor3 = Color3.fromRGB(50, 50, 50)
DefaultSnackbar.ScaleType = Enum.ScaleType.Slice
DefaultSnackbar.Size = UDim2.new(0, 288 + 6, 0, HEIGHT)
DefaultSnackbar.SliceCenter = Rect.new(7, 7, 13, 13)
DefaultSnackbar.ZIndex = 4

local SnackbarText = Instance.new("TextLabel")
SnackbarText.AnchorPoint = Vector2.new(0, 0.5)
SnackbarText.Font = Enum.Font.SourceSans
SnackbarText.Name = "Label"
SnackbarText.Position = UDim2.new(0, 27, 0.5, 0)
SnackbarText.TextSize = 20
SnackbarText.TextColor3 = Color3.fromRGB(255, 255, 255)
SnackbarText.TextXAlignment = Enum.TextXAlignment.Left
SnackbarText.ZIndex = 5
SnackbarText.Parent = DefaultSnackbar

local Snackbar = {}
local PositionEnums = Enumeration.SnackbarPositions:GetEnumerationItems()

function Snackbar.new(Text, Screen, Position)
	-- @param string Text the message you want to appear
	-- @param ScreenGui Screen the Parent of the Snackbar
	-- @param Enumeration Position the positioning of the Snackbar
	
	local ExitPosition
	local EnterPosition
	
	local PositionType = type(Position)
	if PositionType == "string" then
		Position = Enumeration.SnackbarPositions[Position].Name
	elseif PositionType == "number" then
		Position = PositionEnums[Position + 1].Name
	elseif PositionType == "userdata" then
		Position = Position.Name
	elseif PositionType == "nil" then
		Position = PositionEnums[2].Name
	end
	
	if Position == "Left" then
		DefaultSnackbar.Position = UDim2.new(0, 0, 1, 0)
		ExitPosition = UDim2.new(0, 0, 1, 0)
		EnterPosition = UDim2.new(0, 0, 1, -HEIGHT)
	elseif Position == "Right" then
		DefaultSnackbar.AnchorPoint = Vector2.new(1, 0)
		DefaultSnackbar.Position = UDim2.new(1, 0, 1, 0)
		ExitPosition = UDim2.new(1, 0, 1, 0)
		EnterPosition = UDim2.new(1, 0, 1, -HEIGHT)
	elseif Position == "Center" then
		DefaultSnackbar.AnchorPoint = Vector2.new(0.5, 0)
		DefaultSnackbar.Position = UDim2.new(0.5, 0, 1, 0)
		ExitPosition = UDim2.new(0.5, 0, 1, 0)
		EnterPosition = UDim2.new(0.5, 0, 1, -HEIGHT)
	end
	
	if OpenSnackbar then
		local PreviousSnackbar = OpenSnackbar
		local PreviousLabel = PreviousSnackbar:FindFirstChild("Label")

		if PreviousLabel then
			if PreviousLabel.Text == Text then
				return
			end
			PreviousLabel.ZIndex = 3
		end

		OpenTween:Stop()
		PreviousSnackbar.ZIndex = 2
		
		Tween(PreviousSnackbar, "Position", ExitPosition, 2, ENTER_TIME * 0.7, false, function(Completed)
			if Completed == TweenCompleted then
				PreviousSnackbar:Destroy()
				if OpenSnackbar == PreviousSnackbar then
					OpenSnackbar = nil
				end
			end
		end)
	end

	local SnackbarMaid = Maid.new()
	local SnackbarFrame = DefaultSnackbar:Clone()
	OpenSnackbar = SnackbarFrame
	local Label = SnackbarFrame:FindFirstChild("Label")

	if Label then
		Label.Text = Text
		SnackbarMaid:LinkToInstance(SnackbarFrame)
		SnackbarMaid:GiveTask(SnackbarFrame.Label:GetPropertyChangedSignal("TextBounds"):Connect(function()
			SnackbarFrame.Size = UDim2.new(0, Label.TextBounds.X + HEIGHT > SMALLEST_WIDTH and Label.TextBounds.X + HEIGHT or SMALLEST_WIDTH, 0, HEIGHT)
		end))
	end

	SnackbarFrame.Parent = Screen

	OpenTween = Tween(SnackbarFrame, "Position", EnterPosition, 1, ENTER_TIME, false, function(Completed)
		if Completed == TweenCompleted and wait(DISPLAY_TIME - ENTER_TIME) then
			Tween(SnackbarFrame, "Position", ExitPosition, 2, ENTER_TIME, false, function(Completed)
				if Completed == TweenCompleted then
					SnackbarFrame:Destroy()
					if OpenSnackbar == SnackbarFrame then
						OpenSnackbar = nil
					end
				end
			end)
		end
	end)

	return setmetatable({}, Snackbar)
end

return Snackbar
