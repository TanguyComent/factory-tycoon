import { Players, RunService } from "@rbxts/services";
import { rotateDuration, rotateForce } from "../Settings";

export abstract class Building {
    protected model
    protected player
    protected isRotating = false
    protected isMoving = false
    abstract position: Vector3 | undefined

    constructor(model: Model){
        this.model = model
        this.player = Players.LocalPlayer;
        for(let child of this.model.GetChildren()){
            if(child.IsA("Part")) child.CanCollide = false
        }
    }

    Model(){
        return this.model;
    }

    Player(){
        return this.player;
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

    abstract updateTickPosition(): void
}