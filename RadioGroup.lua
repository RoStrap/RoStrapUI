-- Simple PseudoInstance wrapper to manage Radio buttons
-- @author Validark

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Resources = require(ReplicatedStorage:WaitForChild("Resources"))
local PseudoInstance = Resources:LoadLibrary("PseudoInstance")

return PseudoInstance:Register("RadioGroup", {
	Internals = {"Radios", "Selection"};
	Events = {"SelectionChanged"};

	Methods = {
		Add = function(self, Item, Option)
			local Radios = self.Radios
			Radios[#Radios + 1] = Item

			self.Janitor:Add(Item.OnChecked:Connect(function(Checked)
				if Checked then
					for i = 1, #Radios do
						local Radio = Radios[i]
						if Radio ~= Item then
							Radio:SetChecked(false)
						end
					end

					self.Selection = Option
					self.SelectionChanged:Fire(Option)
				end
			end), "Disconnect")
		end;

		GetSelection = function(self) -- `Selection` is not directly accessible because you can neither clone a RadioGroup nor set a Selection
			return self.Selection or nil
		end;
	};

	Init = function(self)
		self.Radios = {}
	end;
})
