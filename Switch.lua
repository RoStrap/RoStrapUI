-- Material Switches
-- @author Validark

-- Import Tween Library
local Resources = require(game:GetService("ReplicatedStorage"):WaitForChild("Resources"))
local Tween = Resources:LoadLibrary("Tween")

-- Objects
local Ripple = Instance.new("ImageLabel")
Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
Ripple.BackgroundTransparency = 1
Ripple.Image = "rbxassetid://517259585"
Ripple.ImageTransparency = 0.8
Ripple.Name = "Ripple"
Ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
Ripple.ZIndex = 7

-- Preload Ink Ripple
game:GetService("ContentProvider"):Preload(Ripple.Image)

-- Enums
local Completed = Enum.TweenStatus.Completed
local MouseMovement = Enum.UserInputType.MouseMovement

local ValidInputEnums = {
	[Enum.UserInputType.Touch] = true;
	[Enum.UserInputType.MouseButton1] = true;
}

local Switch = {}

local function __namecall(self, ...)
	local Button = self.Button
	local Arguments = {...}
	local Method = table.remove(Arguments)

	if Method == "Destroy" then
		self.Bindable:Destroy()
		local Metatable = getmetatable(self)
		for i in next, Metatable do
			Metatable[i] = nil
		end
	elseif Method == "ChangeState" then
		if #Arguments > 0 then
			self.State = Arguments[1]
		else
			self.State = not self.State
		end
	end

	return Button(Method, unpack(Arguments)) -- Button[Method](Button, unpack(Arguments))
end

local function __newindex(self, i, v)
	local Button = self.Button
	local Back = Button.Back
	local Checkmark = Button.Checkmark
	
	if v ~= nil then
		-- if i == "Parent" and v:IsA("GuiObject") then
		-- 	Corner.ImageColor3 = v.BackgroundColor3
		-- 	Button.ZIndex = v.ZIndex + 1
		-- 	Corner.ZIndex = v.ZIndex + 3
		-- 	self.Connection[1]:Disconnect()
		-- 	self.Connection[1] = v:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
		-- 		Corner.ImageColor3 = v.BackgroundColor3
		-- 	end)
		-- elseif i == "TextColor3" then
		-- 	Corner.BackgroundColor3 = v
		-- end

		if i == "State" then
			if self.State ~= v and Button.Parent then
				local InputObject = {UserInputType = Enum.UserInputType.MouseButton1}
				self.Down(InputObject)
				self.Up(InputObject)
			else
				getmetatable(self).State = v
			end
			return
		elseif i == "Parent" then
			if self.State then
				Back.ImageTransparency = 0
				Back.ImageColor3 = Checkmark.ImageColor3
				Back.Visible = false

				Checkmark.ImageTransparency = 0
				Checkmark.Size = UDim2.new(1, 0, 1, 0)
			else
				Back.ImageTransparency = 0.46
				Back.ImageColor3 = Color3.fromRGB(0, 0, 0)
				Back.Visible = true
				
				Checkmark.ImageTransparency = 1
			end
		end
	end

	Button[i] = v
end

-- API
-- boolean State
function Switch.new(Type, Parent)
	-- Types
	-- Checkbox, Radio, Toggle
	local LastRipple

	local Button = Instance.new("TextButton")
	Button.BackgroundTransparency = 1
	Button.Text = ""

	local Bindable = Instance.new("BindableEvent")
	local Interactable = newproxy(true)
	local Metatable = getmetatable(Interactable)
	Metatable.__newindex = __newindex
	Metatable.__namecall = __namecall

	Metatable.Button = Button
	Metatable.Bindable = Bindable
	Metatable.State = true
	Metatable.StateChanged = Bindable.Event
	Metatable.Disabled = false

	function Metatable:__index(i)
		local Value = Metatable[i]
		if Value == nil then
			return Button[i]
		else
			return Value
		end
	end

	local Back = Instance.new("ImageLabel")
	Back.AnchorPoint = Vector2.new(0.5, 0.5)
	Back.BackgroundTransparency = 1
	Back.Image = "rbxassetid://1330573609"
	Back.ImageColor3 = Color3.fromRGB(0, 0, 0)
	Back.ImageRectOffset = Vector2.new(940, 784)
	Back.ImageRectSize = Vector2.new(48, 48)
	Back.ImageTransparency = 0.46
	Back.Name = "Back"
	Back.Position = UDim2.new(0.5, 0, 0.5, 0)
	Back.Size = UDim2.new(1, 0, 1, 0)

	local Checkmark = Back:Clone()
	Checkmark.ImageColor3 = Color3.fromRGB(0, 188, 212)
	Checkmark.ImageRectOffset = Vector2.new(4, 836)
	Checkmark.ImageTransparency = 0
	Checkmark.Name = "Checkmark"

	Back.Parent = Button
	Checkmark.Parent = Button
	Button.Parent = Parent
	
	function Metatable.Down(InputObject)
		if ValidInputEnums[InputObject.UserInputType] then
			if LastRipple then
				Tween(LastRipple, "ImageTransparency", 1, "Deceleration", 0.75, false, true)
			end
			
			local Ripple = Ripple:Clone()
			Ripple.ImageColor3 = Metatable.State and Checkmark.ImageColor3 or Color3.fromRGB(117, 117, 117)
			Ripple.ZIndex = Back.ZIndex + 1
			Ripple.Parent = Button

			LastRipple = Ripple
			Tween(Ripple, "Size", UDim2.new(2, 0, 2, 0), "Deceleration", 0.5)
		end
	end

	function Metatable.Up(InputObject)
		if ValidInputEnums[InputObject.UserInputType] then
			if LastRipple then
				local Checked = not Metatable.State
				Metatable.State = Checked
				Bindable:Fire(Checked)

				if Checked then
					Checkmark.Size = UDim2.new(0, 0, 0, 0)

					Tween(Back, "ImageTransparency", 0, "Deceleration", 0.15, true)
					Tween(Back, "ImageColor3", Checkmark.ImageColor3, "Deceleration", 0.2, true, function(TweenStatus)
						if TweenStatus == Completed then
							Back.Visible = false
						end
					end)

					Tween(Checkmark, "ImageTransparency", 0, "Deceleration", 0.1, true)
					Tween(Checkmark, "Size", UDim2.new(1, 0, 1, 0), "Deceleration", 0.2, true)
				else
					Tween(Back, "ImageColor3", Checkmark.ImageColor3, "Deceleration", 0, true)
					Tween(Back, "ImageTransparency", 0.46, "Deceleration", 2, true)
					Tween(Back, "ImageColor3", Color3.fromRGB(0, 0, 0), "Deceleration", 2, true)

					Back.Visible = true

					Tween(Checkmark, "ImageTransparency", 1, "Deceleration", 0.35, true)
				end
			end
		end

		if LastRipple then
			Tween(LastRipple, "ImageTransparency", 1, "Deceleration", 0.75, false, true)
			LastRipple = nil
		end
	end

	Button.InputBegan:Connect(Metatable.Down)
	Button.InputEnded:Connect(Metatable.Up)

	return Interactable
end

return Switch
