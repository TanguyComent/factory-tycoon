-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local RunService = _services.RunService
local Workspace = _services.Workspace
local Building = TS.import(script, script.Parent, "Building").Building
local _Settings = TS.import(script, script.Parent.Parent, "Settings")
local floorSize = _Settings.floorSize
local gridSize = _Settings.gridSize
local plotDefaultHeight = _Settings.plotDefaultHeight
local currentFloor = TS.import(script, script.Parent.Parent, "Params").currentFloor
local ClassicBuilding
do
	local super = Building
	ClassicBuilding = setmetatable({}, {
		__tostring = function()
			return "ClassicBuilding"
		end,
		__index = super,
	})
	ClassicBuilding.__index = ClassicBuilding
	function ClassicBuilding.new(...)
		local self = setmetatable({}, ClassicBuilding)
		return self:constructor(...) or self
	end
	function ClassicBuilding:constructor(model)
		super.constructor(self, model)
		self.moveDuration = 0.1
		self.mouse = self:Player():GetMouse()
		self.position = model:GetPivot().Position
		self.rayParams = RaycastParams.new()
		self.rayParams.FilterType = Enum.RaycastFilterType.Exclude
		local filter = {}
		local _filter = filter
		local _model = self.model
		table.insert(_filter, _model)
		local _filter_1 = filter
		local _arg0 = self.player.Character or self.player.CharacterAdded:Wait()
		table.insert(_filter_1, _arg0)
		self.rayParams.FilterDescendantsInstances = filter
	end
	function ClassicBuilding:startSmoothMovement()
		self.isMoving = true
		local goal = self.position
		local start = self.model:GetPivot().Position
		local timeToSpend = self.moveDuration
		local alpha = 0
		while timeToSpend > 0 and self.isMoving do
			timeToSpend -= RunService.RenderStepped:Wait()
			--Le goal a changé
			if goal.X ~= self.position.X or goal.Y ~= self.position.Y or goal.Z ~= self.position.Z then
				goal = self.position
				timeToSpend = self.moveDuration
				start = self.model:GetPivot().Position
				alpha = 0
			end
			alpha = 1 - timeToSpend / self.moveDuration
			self.model:MoveTo(start:Lerp(goal, alpha))
		end
		--Fin du mouvement, réalignement pour la précision.
		self.model:MoveTo(goal)
		self.isMoving = false
	end
	function ClassicBuilding:updateTickPosition()
		local result = Workspace:Raycast(self.mouse.UnitRay.Origin, self.mouse.UnitRay.Direction * 1000, self.rayParams)
		if not result then
			return nil
		end
		--Raycast result position
		local resPosition = result.Position
		--Calc of the rounded position
		local xCarry = resPosition.X % gridSize
		local rX = resPosition.X - xCarry
		local zCarry = resPosition.Z % gridSize
		local rZ = resPosition.Z - zCarry
		local rPos = Vector3.new(if (xCarry < gridSize / 2) then rX else rX + gridSize, plotDefaultHeight + currentFloor * floorSize, if (zCarry < gridSize / 2) then rZ else rZ + gridSize)
		if rPos.X ~= self.position.X or rPos.Y ~= self.position.Y or rPos.Z ~= self.position.Z then
			self.position = rPos
			if not self.isMoving then
				self:startSmoothMovement()
			end
		end
	end
end
return {
	ClassicBuilding = ClassicBuilding,
}
