import { Players, RunService, Workspace } from "@rbxts/services";
import { rotateDuration, rotateForce } from "../Settings";
import { Plot } from "shared/plot";

export abstract class Building {
    protected model
    protected player
    protected isMoving = false
    private isRotating = false
    abstract position: Vector3 | undefined

    constructor(model: Model){
        this.model = model
        this.player = Players.LocalPlayer;
        for(let child of this.model.GetChildren()){
            if(child.IsA("Part")) child.CanCollide = false
        }
    }

    canBePlacedHere(plot: Plot){
        return !this.isInMovement() && plot.isModelInPlot(this.model) && plot.playerCanBuild(this.player) && this.isFree()
    }

    rotate(){
        const start = this.model.GetPivot().Position
        const goal = start.mul(new Vector3(0, rotateForce, 0))
        let timePassed = 0
        this.isRotating = true

        while (timePassed < rotateDuration){
            timePassed += RunService.RenderStepped.Wait() as unknown as number
            const alpha = timePassed / rotateDuration
            this.model.MoveTo(start.Lerp(goal, alpha))
        }

        this.model.MoveTo(goal)
        this.isRotating = false
    }

    isInMovement(){
        return this.isMoving || this.isRotating
    }

    isFree(){
        let [cf, size] = this.model.GetBoundingBox()
        
        size = size.sub(new Vector3(0.01, 0.01, 0.01))

        const params = new OverlapParams()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.AddToFilter(this.model)
        const res = Workspace.GetPartBoundsInBox(cf, size, params)

        return res.size() === 0
    }

    // Abstracts methodes
    abstract updateTickPosition(): void

    // Getters
    Model(){
        return this.model;
    }

    Player(){
        return this.player;
    }
}