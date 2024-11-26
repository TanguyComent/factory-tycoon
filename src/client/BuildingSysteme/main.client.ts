import { Players, ReplicatedStorage, RunService, Workspace } from "@rbxts/services"
import { Plot } from "../../shared/plot"
import { Building } from "./Class/Building"
import { ClassicBuilding } from "./Class/ClassicBuildings"

// Constants
const P = Players.LocalPlayer
const buildButton = P.FindFirstChild("PlayerGui")?.FindFirstChild("BUILD GUI")

//Building Pointer
const defaultConstruction: Model = ReplicatedStorage.FindFirstChild("Constructions")?.FindFirstChild("walls")?.FindFirstChild("Murs gris") as Model

if(!defaultConstruction)
    throw "No default constructions finded"

const constructionValue = new Instance("ObjectValue")
constructionValue.Name = "SelectedBuilding"
constructionValue.Value = defaultConstruction
constructionValue.Parent = P

let buildingPointer: Building = new ClassicBuilding(defaultConstruction.Clone())

function updateBuildingPointer(model: Model){
    const buildMode = model.GetAttributes().get("BuildMode")

    switch(buildMode){
        default:
            buildingPointer = new ClassicBuilding(model.Clone())
    }
}

// Plot constructor is already yeilding until the player chose a plot
const plot = new Plot(P)



//Connections
constructionValue.Changed.Connect(function(newValue){
    if(!newValue?.IsA("Model")){
        throw "New construction value isnt a model."
    }

    updateBuildingPointer(newValue)
})