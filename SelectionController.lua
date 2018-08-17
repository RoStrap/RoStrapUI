-- SelectionController Class from which Checkbox and Radio inherit
-- @author Validark

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))

local Color = Resources:LoadLibrary("Color")
local Debug = Resources:LoadLibrary("Debug")
local Typer = Resources:LoadLibrary("Typer")
local Enumeration = Resources:LoadLibrary("Enumeration")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")

local Rippler = Resources:LoadLibrary("Rippler")

Enumeration.MaterialTheme = {"Light", "Dark"}

local Touch = Enum.UserInputType.Touch
local MouseButton1 = Enum.UserInputType.MouseButton1
local MouseMovement = Enum.UserInputType.MouseMovement

local DEFAULT_COLOR3 = Color.Teal[500]

return PseudoInstance:Register("SelectionController", {
	Internals = {
		"Button", "Template", "ClickRippler", "HoverRippler", "Indeterminate";

		Themes = {
			[Enumeration.MaterialTheme.Light.Value] = {
				ImageColor3 = Color.Black;
				ImageTransparency = 0.46;
				DisabledTransparency = 0.74;
			};

			[Enumeration.MaterialTheme.Dark.Value] = {
				ImageColor3 = Color.White;
				ImageTransparency = 0.3;
				DisabledTransparency = 0.7;
			};
		};
	};

	Events = {"OnChecked"};

	Properties = {
		Checked = Typer.Boolean;
		Disabled = Typer.Boolean;

		PrimaryColor3 = Typer.AssignSignature(2, Typer.Color3, function(self, Value)
			if typeof(Value) ~= "Color3" then Debug.Error("PrimaryColor3 must be a Color3 value") end

			if (self.Checked or self.Indeterminate) and self.PrimaryColor3 ~= Value then
				self:SetColorAndTransparency(Value, 0)
			end

			self:rawset("PrimaryColor3", Value)
		end);

		Theme = Typer.AssignSignature(2, Typer.EnumerationOfTypeMaterialTheme, function(self, Theme)
			if not self.Checked then
				local Data = self.Themes[Theme.Value]
				self:SetColorAndTransparency(Data.ImageColor3, Data.ImageTransparency)
			end

			self:rawset("Theme", Theme)
		end);
	};

	Methods = {
		SetChecked = 0;
	};

	Init = function(self)
		local Button = self.Button

		local ClickRippler = PseudoInstance.new("Rippler", Button)
		ClickRippler.RippleExpandDuration = 0.45
		ClickRippler.Style = Enumeration.RipplerStyle.Icon

		local HoverRippler = PseudoInstance.new("Rippler", Button)
		HoverRippler.RippleExpandDuration = 0.1
		HoverRippler.RippleFadeDuration = 0.1
		HoverRippler.Style = Enumeration.RipplerStyle.Icon

		self.Janitor:Add(ClickRippler, "Destroy")
		self.Janitor:Add(HoverRippler, "Destroy")

		local CheckboxIsDown

		self.Janitor:Add(Button.InputBegan:Connect(function(InputObject)
			if InputObject.UserInputType == MouseButton1 or InputObject.UserInputType == Touch then
				CheckboxIsDown = true
				ClickRippler:Down()
			elseif InputObject.UserInputType == MouseMovement then
				HoverRippler:Down()
			end
		end), "Disconnect")

		self.Janitor:Add(Button.InputEnded:Connect(function(InputObject)
			ClickRippler:Up()
			local UserInputType = InputObject.UserInputType
			if CheckboxIsDown and UserInputType == MouseButton1 or UserInputType == Touch then
				self:SetChecked()
			elseif UserInputType == MouseMovement then
				CheckboxIsDown = false
				HoverRippler:Up()
			end
		end), "Disconnect")

		self.Button = Button
		self.ClickRippler = ClickRippler
		self.HoverRippler = HoverRippler

		self.Disabled = false
		self.Theme = 0
		self.PrimaryColor3 = DEFAULT_COLOR3
		self.Checked = false
		self:superinit()
	end;
})
