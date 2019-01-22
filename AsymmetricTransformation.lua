-- Transform function for Paper
-- @author Validark

-- AsymmetricTransformation(GuiObject Button, UDim2 EndSize)
-- @specs https://material.io/guidelines/motion/transforming-material.html#

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))

local Bezier = Resources:LoadLibrary("Bezier")
local Standard = Bezier.new(0.4, 0.0, 0.2, 1)

local CurrentCamera = Workspace.CurrentCamera
local RenderStepped = RunService.RenderStepped
local math_ceil = math.ceil

local function AsymmetricTransformation(Button, EndSize)
	Button.Size = UDim2_new(0, Button.AbsoluteSize.X, 0, Button.AbsoluteSize.Y)
	EndSize = UDim2_new(0, EndSize.X.Scale * CurrentCamera.ViewportSize.X, 0, EndSize.Y.Scale * CurrentCamera.ViewportSize.Y)
	
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
		local Duration = 0.375
		local HeightStart = Duration / 10
		local WidthDuration = Duration * 0.75

		Connection = RenderStepped:Connect(function(Step)
			ElapsedTime = ElapsedTime + Step
			if Duration > ElapsedTime then
				local XScale, XOffset, YScale, YOffset

				if WidthDuration > ElapsedTime then
					local WidthAlpha = Standard(ElapsedTime, 0, 1, WidthDuration)
					XScale = XStartScale + WidthAlpha * XScaleChange
					XOffset = StartX.Offset + WidthAlpha * XOffsetChange
				else
					XScale = Button.Size.X.Scale
					XOffset = Button.Size.X.Offset
				end

				if ElapsedTime > HeightStart then
					local HeightAlpha = Standard(ElapsedTime - HeightStart, 0, 1, Duration)
					YScale = YStartScale + HeightAlpha * YScaleChange
					YOffset = YStartOffset + HeightAlpha * YOffsetChange
				else
					YScale = YStartScale
					YOffset = YStartOffset
				end

				Button.Size = UDim2.new(math_ceil(XScale), math_ceil(XOffset), math_ceil(YScale), math_ceil(YOffset))
			else
				Connection:Disconnect()
				Button.Size = EndSize
			end
		end)
	else
		-- Shrinking
		Clone:Destroy()
		local Duration = 0.225
		local WidthStart = Duration * 0.15
		local HeightDuration = Duration * 0.95

		Connection = RenderStepped:Connect(function(Step)
			ElapsedTime = ElapsedTime + Step
			if Duration > ElapsedTime then
				local XScale, XOffset, YScale, YOffset
	
				if HeightDuration > ElapsedTime then
					local HeightAlpha = Standard(ElapsedTime, 0, 1, HeightDuration)
					YScale = YStartScale + HeightAlpha * YScaleChange
					YOffset = YStartOffset + HeightAlpha * YOffsetChange
				else
					YScale = Button.Size.Y.Scale
					YOffset = Button.Size.Y.Offset
				end
	
				if ElapsedTime > WidthStart then
					local WidthAlpha = Standard(ElapsedTime - WidthStart, 0, 1, Duration)
					XScale = XStartScale + WidthAlpha * XScaleChange
					XOffset = XStartOffset + WidthAlpha * XOffsetChange
				else
					XScale = XStartScale
					XOffset = XStartOffset
				end
	
				Button.Size = UDim2.new(math_ceil(XScale), math_ceil(XOffset), math_ceil(YScale), math_ceil(YOffset))
			else
				Connection:Disconnect()
				Button.Size = EndSize
			end
		end)
	end

	return Connection
end

return AsymmetricTransformation
