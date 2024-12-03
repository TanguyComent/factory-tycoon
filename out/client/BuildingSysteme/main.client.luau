-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local Players = _services.Players
local ReplicatedStorage = _services.ReplicatedStorage
local RunService = _services.RunService
local Workspace = _services.Workspace
local Plot = TS.import(script, script.Parent, "Class", "plot").Plot
local ClassicBuilding = TS.import(script, script.Parent, "Class", "ClassicBuildings").ClassicBuilding
-- Constants
local P = Players.LocalPlayer
local _result = P:WaitForChild("PlayerGui")
if _result ~= nil then
	_result = _result:WaitForChild("Interface")
	if _result ~= nil then
		_result = _result:WaitForChild("TopBar")
		if _result ~= nil then
			_result = _result:WaitForChild("BuildButton")
		end
	end
end
local buildButton = _result
local _result_1 = P:FindFirstChild("PlayerGui")
if _result_1 ~= nil then
	_result_1 = _result_1:FindFirstChild("BUILD GUI")
end
local buildGui = _result_1
local _result_2 = ReplicatedStorage:FindFirstChild("RemoteFunctions")
if _result_2 ~= nil then
	_result_2 = _result_2:FindFirstChild("AskForBuildRequest")
end
local buildOnServerSide = _result_2
if not buildButton then
	error("ERROR : Build button not finded")
end
if not buildGui then
	error("ERROR : No build gui finded")
end
-- State variables
local inBuildMode = false
--Highlight Object
local highlight = Instance.new("Highlight")
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.Enabled = false
--Building Pointer
local _result_3 = ReplicatedStorage:FindFirstChild("Constructions")
if _result_3 ~= nil then
	_result_3 = _result_3:FindFirstChild("walls")
	if _result_3 ~= nil then
		_result_3 = _result_3:FindFirstChild("Murs gris")
	end
end
local defaultConstruction = _result_3
if not defaultConstruction then
	error("ERROR : No default constructions finded")
end
local constructionValue = Instance.new("ObjectValue")
constructionValue.Name = "SelectedBuilding"
constructionValue.Value = defaultConstruction
constructionValue.Parent = P
local buildingPointer = ClassicBuilding.new(defaultConstruction:Clone())
highlight.Parent = buildingPointer:Model()
-- Update the object which the player is trying to build
local function updateBuildingPointer(model)
	local buildMode = model:GetAttributes().BuildMode
	repeat
		buildingPointer = ClassicBuilding.new(model:Clone())
	until true
	highlight.Parent = buildingPointer:Model()
end
-- Hide / show the building pointer based on the build mode
local function updatePointerVisibility()
	if inBuildMode then
		buildingPointer:Model().Parent = Workspace
	else
		buildingPointer:Model().Parent = script
	end
end
-- Update the build gui visiblity based on the build mode
local function updateGuiVisibility()
	buildGui.Enabled = inBuildMode
end
local function updateHighlightVisibility()
	highlight.Enabled = inBuildMode
end
-- Update the highliht color
local plot
local function updateHighlightColor()
	if buildingPointer:canBePlacedHere(plot) then
		highlight.OutlineColor = Color3.fromRGB(5, 140, 5)
		highlight.FillColor = Color3.fromRGB(20, 64, 20)
	else
		highlight.OutlineColor = Color3.fromRGB(140, 5, 5)
		highlight.FillColor = Color3.fromRGB(64, 20, 20)
	end
end
local function switchBuildMode()
	inBuildMode = not inBuildMode
	updatePointerVisibility()
	updateGuiVisibility()
	updateHighlightVisibility()
	if inBuildMode then
		-- The player is now building
		RunService:BindToRenderStep("Build", 600, function()
			buildingPointer:updateTickPosition(plot:getZeroHeight())
			updateHighlightColor()
		end)
	else
		-- The player is no longer building
		RunService:UnbindFromRenderStep("Build")
	end
end
local function sendBuildRequest()
	local toBuild = constructionValue.Value
	local _orientation = buildingPointer.orientation
	local _position = buildingPointer.position
	buildOnServerSide:InvokeServer(toBuild, _orientation + _position)
end
-- Plot constructor is already yeilding until the player chose a plot
plot = Plot.new(P)
--Connections 
buildButton.Activated:Connect(switchBuildMode)
P:GetMouse().Button1Down:Connect(sendBuildRequest)
constructionValue.Changed:Connect(function(newValue)
	local _result_4 = newValue
	if _result_4 ~= nil then
		_result_4 = _result_4:IsA("Model")
	end
	if not _result_4 then
		error("New construction value isnt a model.")
	end
	updateBuildingPointer(newValue)
end)
