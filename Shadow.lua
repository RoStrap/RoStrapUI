local Resources = require(game:GetService("ReplicatedStorage"):WaitForChild("Resources"))
local Tween = Resources:LoadLibrary("Tween")

local SHADOW_TWEEN_TIME = 0.275

local ShadowImage = Instance.new("ImageLabel")
ShadowImage.Image = "rbxassetid://1316045217"
ShadowImage.ImageColor3 = Color3.fromRGB(0, 0, 0)
ShadowImage.AnchorPoint = Vector2.new(0.5, 0.5)
ShadowImage.BackgroundTransparency = 1
ShadowImage.Position = UDim2.new(0.5, 0, 0.5, 0)
ShadowImage.ScaleType = Enum.ScaleType.Slice
ShadowImage.SliceCenter = Rect.new(10, 10, 118, 118)
ShadowImage.Size = UDim2.new(1, 0, 1, 0)

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
		Data.Size, Data.Blur = UDim2.new(1, Data.Blur, 1, Data.Blur)
		Data.Position, Data.Offset = UDim2.new(0.5, 0, 0.5, 0) + (Data.Offset or UDim2.new())
		Data.ImageTransparency, Data.Opacity = 1 - Data.Opacity
	end
end

local Shadow = {
	Elevation = 3;
}
Shadow.__index = Shadow

function Shadow:ChangeElevation(Elevation)
	if self.Elevation ~= Elevation then
		for Name, Data in next, (assert(ShadowData[Elevation], "[Shadow] Non-existant elevation")) do
			local Object = self[Name]
			for Property, EndValue in next, Data do
				Tween(Object, Property, EndValue, "Deceleration", SHADOW_TWEEN_TIME, true)
			end
		end
		self.Elevation = Elevation
	end
end

function Shadow.new(Elevation, Parent)
	local self = setmetatable({
		Elevation = Elevation;
	}, Shadow)

	for Name, Properties in next, ShadowData[self.Elevation] do
		local Shadow = ShadowImage:Clone()
		Shadow.Name = Name .. "Shadow"
		Shadow.Size = Properties.Size
		Shadow.Position = Properties.Position
		Shadow.ImageTransparency = Properties.ImageTransparency
		Shadow.Parent = Parent

		self[Name] = Shadow
	end

	return self
end

return Shadow
