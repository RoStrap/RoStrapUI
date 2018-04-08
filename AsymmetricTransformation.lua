-- Transform function for Paper
-- AsymmetricTransformation(GuiObject Button, UDim2 EndSize)
-- @specs https://material.io/guidelines/motion/transforming-material.html#
-- @author Validark

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))

local Bezier = Resources:LoadLibrary("Bezier")
local Standard = Bezier.new(0.4, 0.0, 0.2, 1)

local Heartbeat = RunService.Heartbeat

local function AsymmetricTransformation(Button, EndSize)
	Button.Visible = true -- Sorry, but we need to assume
	local StartX = Button.Size.X
	local StartY = Button.Size.Y
	local EndX = EndSize.X
	local EndY = EndSize.Y
	
	local XStartScale = StartX.Scale
	local XStartOffset = StartX.Offset
	local YStartScale = StartY.Scale
	local YStartOffset = StartY.Offset
	
	local XScaleChange = EndX.Scale - XStartScale
	local XOffsetChange = EndX.Offset - XStartOffset
	local YScaleChange = EndY.Scale - YStartScale
	local YOffsetChange = EndY.Offset - YStartOffset
	
	local ElapsedTime, Connection = 0

	local Clone = Button:Clone()
	Clone.Name = ""
	Clone.Size = EndSize
	Clone.Visible = false
	Clone.Parent = Button.Parent

	if Button.AbsoluteSize.X * Button.AbsoluteSize.Y < Clone.AbsoluteSize.X * Clone.AbsoluteSize.Y then
		-- Expanding
		Clone:Destroy()
		local Duration = 0.225
		local HeightStart = Duration*0.1
		local WidthDuration = Duration*0.75

		Connection = Heartbeat:Connect(function(Step)
			ElapsedTime = ElapsedTime + Step
			if Duration > ElapsedTime then
				local XScale, XOffset, YScale, YOffset

				if WidthDuration > ElapsedTime then
					local WidthAlpha = Standard(ElapsedTime, 0, 1, WidthDuration)
					XScale = XStartScale + WidthAlpha*XScaleChange
					XOffset = StartX.Offset + WidthAlpha*XOffsetChange
				else
					XScale = Button.Size.X.Scale
					XOffset = Button.Size.X.Offset
				end

				if ElapsedTime > HeightStart then
					local HeightAlpha = Standard(ElapsedTime - HeightStart, 0, 1, Duration)
					YScale = YStartScale + HeightAlpha*YScaleChange
					YOffset = YStartOffset + HeightAlpha*YOffsetChange
				else
					YScale = YStartScale
					YOffset = YStartOffset
				end

				Button.Size = UDim2.new(math.ceil(XScale), math.ceil(XOffset), math.ceil(YScale), math.ceil(YOffset))
			else
				Connection:Disconnect()
				Button.Size = EndSize
			end
		end)
	else
		-- Shrinking
		Clone:Destroy()
		local Duration = 0.225
		local WidthStart = Duration*0.15
		local HeightDuration = Duration*0.95

		Connection = Heartbeat:Connect(function(Step)
			ElapsedTime = ElapsedTime + Step
			if Duration > ElapsedTime then
				local XScale, XOffset, YScale, YOffset
	
				if HeightDuration > ElapsedTime then
					local HeightAlpha = Standard(ElapsedTime, 0, 1, HeightDuration)
					YScale = YStartScale + HeightAlpha*YScaleChange
					YOffset = YStartOffset + HeightAlpha*YOffsetChange
				else
					YScale = Button.Size.Y.Scale
					YOffset = Button.Size.Y.Offset
				end
	
				if ElapsedTime > WidthStart then
					local WidthAlpha = Standard(ElapsedTime - WidthStart, 0, 1, Duration)
					XScale = XStartScale + WidthAlpha*XScaleChange
					XOffset = XStartOffset + WidthAlpha*XOffsetChange
				else
					XScale = XStartScale
					XOffset = XStartOffset
				end
	
				Button.Size = UDim2.new(math.ceil(XScale), math.ceil(XOffset), math.ceil(YScale), math.ceil(YOffset))
			else
				Connection:Disconnect()
				Button.Size = EndSize
				if EndSize == UDim2.new() then
					Button.Visible = false
				end
			end
		end)
	end

	return Connection
end

return AsymmetricTransformation
