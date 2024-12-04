-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local ReplicatedStorage = _services.ReplicatedStorage
local Workspace = _services.Workspace
local function findPlotIdByPlayer(player)
	local R = ReplicatedStorage
	local plotOwners = R:FindFirstChild("PlotOwners")
	if plotOwners and plotOwners:IsA("Folder") then
		for _, plot in plotOwners:GetChildren() do
			if not plot:IsA("IntValue") then
				continue
			end
			if plot.Value == player.UserId then
				return string.sub(plot.Name, 5)
			end
		end
	end
	return -1
end
local function yeildUntilPlayerHasPlot(player)
	local hasChoosePlot = player:WaitForChild("HasChoosePlot")
	if hasChoosePlot and hasChoosePlot:IsA("BoolValue") then
		if not hasChoosePlot.Value then
			hasChoosePlot.Changed:Wait()
		end
	else
		error("An unexcpected error occured with plot selection")
	end
end
local Plot
do
	Plot = setmetatable({}, {
		__tostring = function()
			return "Plot"
		end,
	})
	Plot.__index = Plot
	function Plot.new(...)
		local self = setmetatable({}, Plot)
		return self:constructor(...) or self
	end
	function Plot:constructor(owner)
		self.owner = owner
		yeildUntilPlayerHasPlot(owner)
		self.id = findPlotIdByPlayer(owner)
		local _centerValue = ReplicatedStorage:FindFirstChild("PlotsMiddles")
		if _centerValue ~= nil then
			_centerValue = _centerValue:WaitForChild("plot" .. tostring(self.id))
		end
		local centerValue = _centerValue
		if centerValue and centerValue:IsA("Vector3Value") then
			self.centerVector = centerValue.Value
		else
			error("No plot center finded, error")
		end
		self.model = Workspace:FindFirstChild("plot" .. tostring(self.id))
		if not self.model then
			error("No plot model finded")
		end
		local _plotPart = self.model
		if _plotPart ~= nil then
			_plotPart = _plotPart:FindFirstChild("DefaultStuffs")
			if _plotPart ~= nil then
				_plotPart = _plotPart:FindFirstChild("Floors")
				if _plotPart ~= nil then
					_plotPart = _plotPart:FindFirstChild("00")
				end
			end
		end
		local plotPart = _plotPart
		if plotPart and plotPart:IsA("Part") then
			local plotDefaultY = plotPart.Position.Y
			local halfY = plotPart.Size.Y / 2
			self.floorZeroHeight = plotDefaultY + halfY
		else
			error("No plot part finded")
		end
	end
	function Plot:isVectorInPLot(vector)
		local x = vector.X - self.centerVector.X
		local z = vector.Z - self.centerVector.Z
		return math.abs(x) <= Plot.size / 2 and math.abs(z) <= Plot.size / 2
	end
	function Plot:isModelInPlot(model)
		local cf, size = model:GetBoundingBox()
		local position = cf.Position
		local half = size / 2
		-- The y position doesn't matter
		local _vector3 = Vector3.new(half.X, 0, half.Z)
		local positiveCorner = position + _vector3
		local _vector3_1 = Vector3.new(half.X, 0, half.Z)
		local negativeCorner = position - _vector3_1
		-- If both opposites corners are on the plot, the box is in the plot
		return self:isVectorInPLot(positiveCorner) and self:isVectorInPLot(negativeCorner)
	end
	function Plot:isModelInAvaiblePlot(model, player)
		if not self:playerCanBuild(player) then
			return false
		end
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Include
		local _result = self.model:FindFirstChild("DefaultStuffs")
		if _result ~= nil then
			_result = _result:FindFirstChild("Floors")
		end
		params.FilterDescendantsInstances = { _result }
		local origin, size = model:GetBoundingBox()
		local half = size / 2
		local _vector3 = Vector3.new(0, -1, 0)
		local _arg0 = size.Y * 2
		local direction = _vector3 * _arg0
		local _position = origin.Position
		local _vector3_1 = Vector3.new(half.X, 0, half.Z)
		local origin1 = _position + _vector3_1
		local _position_1 = origin.Position
		local _vector3_2 = Vector3.new(half.X, 0, half.Z)
		local origin2 = _position_1 - _vector3_2
		local _result1 = Workspace:Raycast(origin1, direction, params)
		if _result1 ~= nil then
			_result1 = _result1.Instance
		end
		local result1 = _result1
		local _result2 = Workspace:Raycast(origin2, direction, params)
		if _result2 ~= nil then
			_result2 = _result2.Instance
		end
		local result2 = _result2
		if not result1 or not result2 then
			return false
		end
		local resName1 = result1.Name
		local _resName2 = result2
		if _resName2 ~= nil then
			_resName2 = _resName2.Name
		end
		local resName2 = _resName2
		local _result_1 = player:FindFirstChild("unlockedZones")
		if _result_1 ~= nil then
			_result_1 = _result_1:FindFirstChild(resName1)
		end
		local val1 = _result_1
		local _result_2 = player:FindFirstChild("unlockedZones")
		if _result_2 ~= nil then
			_result_2 = _result_2:FindFirstChild(resName2)
		end
		local val2 = _result_2
		return val1 and val2 and val1.Value and val2.Value
	end
	function Plot:playerCanBuild(player)
		return self.owner.UserId == player.UserId
	end
	function Plot:getId()
		return self.id
	end
	function Plot:getCenter()
		return self.centerVector
	end
	function Plot:getZeroHeight()
		return self.floorZeroHeight
	end
	Plot.size = 600
end
return {
	yeildUntilPlayerHasPlot = yeildUntilPlayerHasPlot,
	Plot = Plot,
}
