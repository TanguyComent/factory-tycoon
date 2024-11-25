import { Players } from "@rbxts/services";

export abstract class Building {
    protected model
    protected player
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

    abstract updateTickPosition(): void;
}