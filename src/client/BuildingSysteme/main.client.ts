import { Players, ReplicatedStorage, RunService, Workspace } from "@rbxts/services"
import { Plot } from "./Class/plot"
import { Building } from "./Class/Building"
import { ClassicBuilding } from "./Class/ClassicBuildings"

// Constants
const P = Players.LocalPlayer
const buildButton = P.WaitForChild("PlayerGui")?.WaitForChild("Interface")?.WaitForChild("TopBar")?.WaitForChild("BuildButton") as GuiButton
const buildGui = P.FindFirstChild("PlayerGui")?.FindFirstChild("BUILD GUI") as ScreenGui
const buildOnServerSide = ReplicatedStorage.FindFirstChild("RemoteFunctions")?.FindFirstChild("AskForBuildRequest") as RemoteFunction

if (!buildButton) throw "ERROR : Build button not finded"
if (!buildGui) throw "ERROR : No build gui finded"

// State variables
let inBuildMode = false

//Highlight Object
const highlight = new Instance("Highlight")
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.Enabled = false

//Building Pointer
const defaultConstruction: Model = ReplicatedStorage.FindFirstChild("Constructions")?.FindFirstChild("walls")?.FindFirstChild("Murs gris") as Model

if(!defaultConstruction)
    throw "ERROR : No default constructions finded"

const constructionValue = new Instance("ObjectValue")
constructionValue.Name = "SelectedBuilding"
constructionValue.Value = defaultConstruction
constructionValue.Parent = P

let buildingPointer: Building = new ClassicBuilding(defaultConstruction.Clone())
highlight.Parent = buildingPointer.Model()

// Update the object which the player is trying to build
function updateBuildingPointer(model: Model){
    const buildMode = model.GetAttributes().get("BuildMode")

    switch(buildMode){
        default:
            buildingPointer = new ClassicBuilding(model.Clone())
    }

    highlight.Parent = buildingPointer.Model()
}

// Hide / show the building pointer based on the build mode
function updatePointerVisibility(){
    if(inBuildMode){
        buildingPointer.Model().Parent = Workspace
    }else{
        buildingPointer.Model().Parent = script
    }
}

// Update the build gui visiblity based on the build mode
function updateGuiVisibility(){
    buildGui.Enabled = inBuildMode
}

function updateHighlightVisibility(){
    highlight.Enabled = inBuildMode
}

// Update the highliht color
function updateHighlightColor(){
    if(buildingPointer.canBePlacedHere(plot)){
        highlight.OutlineColor = Color3.fromRGB(5, 140, 5)
        highlight.FillColor = Color3.fromRGB(20, 64, 20)
    }else{
        highlight.OutlineColor = Color3.fromRGB(140, 5, 5)
        highlight.FillColor = Color3.fromRGB(64, 20, 20)
    }
}

function switchBuildMode(){
    inBuildMode = !inBuildMode

    updatePointerVisibility()
    updateGuiVisibility()
    updateHighlightVisibility()

    if(inBuildMode){
        // The player is now building
        RunService.BindToRenderStep("Build", 600, function(){
            buildingPointer.updateTickPosition(plot.getZeroHeight())
            updateHighlightColor()
        })
    }else{
        // The player is no longer building
        RunService.UnbindFromRenderStep("Build")
    }
}

function sendBuildRequest(){
    const toBuild = constructionValue.Value
    buildOnServerSide.InvokeServer(toBuild, buildingPointer.orientation.add(buildingPointer.position as Vector3))
}

// Plot constructor is already yeilding until the player chose a plot
const plot = new Plot(P)

//Connections 
buildButton.Activated.Connect(switchBuildMode)

P.GetMouse().Button1Down.Connect(sendBuildRequest)

constructionValue.Changed.Connect(function(newValue){
    if(!newValue?.IsA("Model")){
        throw "New construction value isnt a model."
    }

    updateBuildingPointer(newValue)
})