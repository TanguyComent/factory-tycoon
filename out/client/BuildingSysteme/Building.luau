-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local Players = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services").Players
local Building
do
	Building = {}
	function Building:constructor(model)
		self.model = model
		self.player = Players.LocalPlayer
		for _, child in self.model:GetChildren() do
			if child:IsA("Part") then
				child.CanCollide = false
			end
		end
	end
	function Building:Model()
		return self.model
	end
	function Building:Player()
		return self.player
	end
end
return {
	Building = Building,
}
