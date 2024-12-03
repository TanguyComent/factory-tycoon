import { RunService, Workspace } from "@rbxts/services";
import { Building } from "./Building";
import { floorSize, gridSize } from "../Settings";
import { currentFloor } from "../Params";

export class ClassicBuilding extends Building {
    
    public position: Vector3;
    private moveDuration = 0.1
    private rayParams: RaycastParams
    private mouse

    constructor(model: Model){
        super(model);
        this.mouse = this.Player().GetMouse()
        this.position = model.GetPivot().Position

        this.rayParams = new RaycastParams()
        this.rayParams.FilterType = Enum.RaycastFilterType.Exclude
        let filter: Instance[] = new Array()
        filter.push(this.model)
        filter.push(this.player.Character || this.player.CharacterAdded.Wait() as unknown as Instance)
        this.rayParams.FilterDescendantsInstances = filter
    }

    private startSmoothMovement(){
        this.isMoving = true

        let goal = this.position
        let start = this.model.GetPivot().Position
        let timeToSpend = this.moveDuration
        let alpha = 0

        while(timeToSpend > 0 && this.isMoving){
            timeToSpend -= RunService.RenderStepped.Wait() as unknown as number

            //Le goal a changé
            if(goal.X !== this.position.X || goal.Y !== this.position.Y || goal.Z !== this.position.Z){
                goal = this.position
                timeToSpend = this.moveDuration
                start = this.model.GetPivot().Position
                alpha = 0
            }

            alpha = 1 - timeToSpend / this.moveDuration
            this.model.MoveTo(start.Lerp(goal, alpha))
        }

        //Fin du mouvement, réalignement pour la précision.
        this.model.MoveTo(goal)
        this.isMoving = false
    }

    updateTickPosition(plotDefaultHeight: number): void {
        const result = Workspace.Raycast(this.mouse.UnitRay.Origin, this.mouse.UnitRay.Direction.mul(1000), this.rayParams)

        if(!result)
            return

        //Raycast result position
        const resPosition = result.Position

        //Calc of the rounded position
        const xCarry = resPosition.X % gridSize
        const rX = resPosition.X - xCarry

        const zCarry = resPosition.Z % gridSize
        const rZ = resPosition.Z - zCarry

        const rPos = new Vector3((xCarry < gridSize / 2) ? rX : rX + gridSize, plotDefaultHeight + currentFloor * floorSize, (zCarry < gridSize / 2) ? rZ : rZ + gridSize)

        if(rPos.X !== this.position.X || rPos.Y !== this.position.Y || rPos.Z !== this.position.Z){
            this.position = rPos
            if(!this.isMoving) this.startSmoothMovement()
        }
    }
}