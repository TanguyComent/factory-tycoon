-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local Players = _services.Players
local RunService = _services.RunService
local Workspace = _services.Workspace
local _Settings = TS.import(script, script.Parent.Parent, "Settings")
local rotateDuration = _Settings.rotateDuration
local rotateForce = _Settings.rotateForce
local Building
do
	Building = {}
	function Building:constructor(model)
		self.isMoving = false
		self.isRotating = false
		self.model = model
		self.player = Players.LocalPlayer
		for _, child in self.model:GetChildren() do
			if child:IsA("Part") then
				child.CanCollide = false
			end
		end
	end
	function Building:canBePlacedHere(plot)
		return not self:isInMovement() and plot:isModelInPlot(self.model) and plot:playerCanBuild(self.player) and self:isFree()
	end
	function Building:rotate()
		local start = self.model:GetPivot().Position
		local _vector3 = Vector3.new(0, rotateForce, 0)
		local goal = start * _vector3
		local timePassed = 0
		self.isRotating = true
		while timePassed < rotateDuration do
			timePassed += RunService.RenderStepped:Wait()
			local alpha = timePassed / rotateDuration
			self.model:MoveTo(start:Lerp(goal, alpha))
		end
		self.model:MoveTo(goal)
		self.isRotating = false
	end
	function Building:isInMovement()
		return self.isMoving or self.isRotating
	end
	function Building:isFree()
		local cf, size = self.model:GetBoundingBox()
		local _size = size
		local _vector3 = Vector3.new(0.01, 0.01, 0.01)
		size = _size - _vector3
		local params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params:AddToFilter(self.model)
		local res = Workspace:GetPartBoundsInBox(cf, size, params)
		return #res == 0
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
