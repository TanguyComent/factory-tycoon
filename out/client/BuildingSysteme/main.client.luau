-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local Players = _services.Players
local ReplicatedStorage = _services.ReplicatedStorage
local Plot = TS.import(script, game:GetService("ReplicatedStorage"), "TS", "plot").Plot
local ClassicBuilding = TS.import(script, script.Parent, "ClassicBuildings").ClassicBuilding
-- Constants
local P = Players.LocalPlayer
--const buildButton = null
--Building Pointer
local _result = ReplicatedStorage:FindFirstChild("Constructions")
if _result ~= nil then
	_result = _result:FindFirstChild("walls")
	if _result ~= nil then
		_result = _result:FindFirstChild("Murs gris")
	end
end
local defaultConstruction = _result
if not defaultConstruction then
	error("No default constructions finded")
end
local constructionValue = Instance.new("ObjectValue")
constructionValue.Name = "SelectedBuilding"
constructionValue.Value = defaultConstruction
constructionValue.Parent = P
local buildingPointer = ClassicBuilding.new(defaultConstruction:Clone())
local function updateBuildingPointer(model)
	local buildMode = model:GetAttributes().BuildMode
	repeat
		buildingPointer = ClassicBuilding.new(model:Clone())
	until true
end
-- Plot constructor is already yeilding until the player chose a plot
local plot = Plot.new(P)
