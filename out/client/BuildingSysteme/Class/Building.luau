-- Compiled with roblox-ts v3.0.0
local TS = require(game:GetService("ReplicatedStorage"):WaitForChild("rbxts_include"):WaitForChild("RuntimeLib"))
local _services = TS.import(script, game:GetService("ReplicatedStorage"), "rbxts_include", "node_modules", "@rbxts", "services")
local Players = _services.Players
local RunService = _services.RunService
local _Settings = TS.import(script, script.Parent.Parent, "Settings")
local rotateDuration = _Settings.rotateDuration
local rotateForce = _Settings.rotateForce
local Building
do
	Building = {}
	function Building:constructor(model)
		self.isRotating = false
		self.isMoving = false
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
end
return {
	Building = Building,
}
