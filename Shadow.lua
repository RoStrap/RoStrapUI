-- Shadow / Elevation Renderer PseudoInstance
-- @documentation https://rostrap.github.io/Libraries/Material/Shadow/
-- @author Validark
-- @author AmaranthineCodices - Made the Shadow images and created the rendering framework
-- @original https://github.com/AmaranthineCodices/roact-material/blob/master/src/Components/Shadow.lua

local SHADOW_TWEEN_TIME = 0.175 --0.275

local Resources = require(game:GetService("ReplicatedStorage"):WaitForChild("Resources"))
local Debug = Resources:LoadLibrary("Debug")
local Tween = Resources:LoadLibrary("Tween")
local Enumeration = Resources:LoadLibrary("Enumeration")
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")

local ShadowImage = Instance.new("ImageLabel")
ShadowImage.Image = "rbxassetid://1316045217"
ShadowImage.ImageColor3 = Color3.fromRGB(0, 0, 0)
ShadowImage.AnchorPoint = Vector2.new(0.5, 0.5)
ShadowImage.BackgroundTransparency = 1
ShadowImage.ScaleType = Enum.ScaleType.Slice
ShadowImage.SliceCenter = Rect.new(10, 10, 118, 118)

Enumeration.ShadowElevation = {
	Elevation0 = 0;
	Elevation1 = 1;
	Elevation2 = 2;
	Elevation3 = 3;
	Elevation4 = 4;
	Elevation6 = 6;
	Elevation8 = 8;
	Elevation9 = 9;
	Elevation12 = 12;
	Elevation16 = 16;
}

local ShadowData = {
	[0] = {
		Ambient = {
			Opacity = 0;
			Blur = 0;
		};

		Penumbra = {
			Opacity = 0;
			Blur = 0;
		};

		Umbra = {
			Opacity = 0;
			Blur = 0;
		};
	};

	[1] = {
		Ambient = {
			Opacity = 0.2;
			Blur = 3;
			Offset = UDim2.new(0, 0, 0, 1);
		};

		Penumbra = {
			Opacity = 0.12;
			Blur = 2;
			Offset = UDim2.new(0, 0, 0, 2);
		};

		Umbra = {
			Opacity = 0.14;
			Blur = 2;
		};
	};

	[2] = {
		Ambient = {
			Opacity = 0.2;
			Blur = 5;
			Offset = UDim2.new(0, 0, 0, 1);
		};

		Penumbra = {
			Opacity = 0.12;
			Blur = 4;
			Offset = UDim2.new(0, 0, 0, 3);
		};

		Umbra = {
			Opacity = 0.14;
			Blur = 4;
		};
	};

	[3] = {
		Ambient = {
			Opacity = 0.2;
			Blur = 8;
			Offset = UDim2.new(0, 0, 0, 1);
		};

		Penumbra = {
			Opacity = 0.12;
			Blur = 4;
			Offset = UDim2.new(0, 0, 0, 3);
		};

		Umbra = {
			Opacity = 0.14;
			Blur = 3;
			Offset = UDim2.new(0, 0, 0, 3);
		};
	};

	[4] = {
		Ambient = {
			Opacity = 0.2;
			Blur = 10;
			Offset = UDim2.new(0, 0, 0, 1);
		};

		Penumbra = {
			Opacity = 0.12;
			Blur = 5;
			Offset = UDim2.new(0, 0, 0, 4);
		};

		Umbra = {
			Opacity = 0.14;
			Blur = 4;
			Offset = UDim2.new(0, 0, 0, 2);
		};
	};

	[6] = {
		Ambient = {
			Opacity = 0.2;
			Blur = 5;
			Offset = UDim2.new(0, 0, 0, 3);
		};

		Penumbra = {
			Opacity = 0.12;
			Blur = 18;
			Offset = UDim2.new(0, 0, 0, 1);
		};

		Umbra = {
			Opacity = 0.14;
			Blur = 10;
			Offset = UDim2.new(0, 0, 0, 6);
		};
	};

	[8] = {
		Ambient = {
			Opacity = 0.2;
			Blur = 15;
			Offset = UDim2.new(0, 0, 0, 4);
		};

		Penumbra = {
			Opacity = 0.12;
			Blur = 14;
			Offset = UDim2.new(0, 0, 0, 3);
		};

		Umbra = {
			Opacity = 0.14;
			Blur = 10;
			Offset = UDim2.new(0, 0, 0, 8);
		};
	};

	[9] = {
		Ambient = {
			Opacity = 0.2;
			Blur = 6;
			Offset = UDim2.new(0, 0, 0, 5);
		};

		Penumbra = {
			Opacity = 0.12;
			Blur = 16;
			Offset = UDim2.new(0, 0, 0, 3);
		};

		Umbra = {
			Opacity = 0.14;
			Blur = 12;
			Offset = UDim2.new(0, 0, 0, 9);
		};
	};

	[12] = {
		Ambient = {
			Opacity = 0.2;
			Blur = 8;
			Offset = UDim2.new(0, 0, 0, 7);
		};

		Penumbra = {
			Opacity = 0.12;
			Blur = 22;
			Offset = UDim2.new(0, 0, 0, 5);
		};

		Umbra = {
			Opacity = 0.14;
			Blur = 17;
			Offset = UDim2.new(0, 0, 0, 12);
		};
	};

	[16] = {
		Ambient = {
			Opacity = 0.2;
			Blur = 10;
			Offset = UDim2.new(0, 0, 0, 8);
		};

		Penumbra = {
			Opacity = 0.12;
			Blur = 30;
			Offset = UDim2.new(0, 0, 0, 6);
		};

		Umbra = {
			Opacity = 0.14;
			Blur = 24;
			Offset = UDim2.new(0, 0, 0, 16);
		};
	};
}

for _, Elevation in next, ShadowData do
	for _, Data in next, Elevation do
		Data.Size = UDim2.new(1, Data.Blur, 1, Data.Blur)
		Data.Position = UDim2.new(0.5, 0, 0.5, 0) + (Data.Offset or UDim2.new())
		Data.ImageTransparency = 1 - Data.Opacity

		Data.Blur = nil
		Data.Offset = nil
		Data.Opacity = nil
	end
end

local ShadowNames = {"Ambient", "Penumbra", "Umbra"}

return PseudoInstance:Register("Shadow", {
	Properties = {
		Elevation = function(self, Elevation)
			Elevation = Enumeration.ShadowElevation:Cast(Elevation)

			if self.Elevation ~= Elevation then
				for Name, Data in next, ShadowData[Elevation.Value] do
					local Object = self[Name]

					for Property, EndValue in next, Data do
						Object[Property] = EndValue
					end
				end
				self:rawset("Elevation", Elevation)
			end
		end;

		Parent = function(self, Parent)
			local IsGuiObject = typeof(Parent) == "Instance" and Parent:IsA("GuiObject")

			if IsGuiObject then
				local function ZIndexChanged()
					local ParentZIndex = Parent.ZIndex

					for i = 1, 3 do
						self[ShadowNames[i]].ZIndex = ParentZIndex - 1
					end
				end

				self.Janitor:Add(Parent:GetPropertyChangedSignal("ZIndex"):Connect(ZIndexChanged), "Disconnect", "ZIndexChanged")
				ZIndexChanged()

				for i = 1, 3 do
					self[ShadowNames[i]].Parent = Parent
				end

				return true
			else
				Debug.Error("bad argument 3 to Parent, expected GuiObject, got %s", Parent)
			end
		end;
	};

	Events = {};

	Methods = {
		ChangeElevation = function(self, Elevation)
			Elevation = Enumeration.ShadowElevation:Cast(Elevation)

			if self.Elevation ~= Elevation then
				for Name, Data in next, ShadowData[Elevation.Value] do
					local Object = self[Name]

					for Property, EndValue in next, Data do
						Tween(Object, Property, EndValue, "Deceleration", SHADOW_TWEEN_TIME, true)
					end
				end

				self:rawset("Elevation", Elevation)
			end
		end;
	};

	Init = function(self)
		for i = 1, 3 do
			local Name = ShadowNames[i]
			local Shadow = ShadowImage:Clone()
			Shadow.Name = Name .. "Shadow"

			self:rawset(Name, Shadow)
			self.Janitor:Add(Shadow, "Destroy")
			self.Janitor:LinkToInstance(Shadow, true)
		end

		self:rawset("Elevation", Enumeration.ShadowElevation.Elevation0)
	end;
})
