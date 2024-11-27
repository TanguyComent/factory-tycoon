import { ReplicatedStorage, Workspace } from "@rbxts/services";

function findPlotIdByPlayer(player: Player): number{
    const R = ReplicatedStorage
    const plotOwners = R.FindFirstChild("PlotOwners")

    if(plotOwners && plotOwners.IsA("Folder")){
        for(let plot of plotOwners.GetChildren()){
            if(!plot.IsA("IntValue")) continue
            if(plot.Value === player.UserId){
                return plot.Name.sub(5) as unknown as number
            }
        }
    }

    return -1        
}

export function yeildUntilPlayerHasPlot(player: Player){
    const hasChoosePlot = player.WaitForChild("HasChoosePlot")

    if(hasChoosePlot && hasChoosePlot.IsA("BoolValue")){
    
        if(!hasChoosePlot.Value){
            hasChoosePlot.Changed.Wait()
        }
    
    }else{
        throw "An unexcpected error occured with plot selection"
    }
}

export class Plot{
    public static size = 600

    private id
    private centerVector
    private owner
    private floorZeroHeight

    constructor(owner: Player){
        this.owner = owner

        yeildUntilPlayerHasPlot(owner)
        this.id = findPlotIdByPlayer(owner)

        const centerValue = ReplicatedStorage.FindFirstChild("PlotsMiddles")?.WaitForChild("plot" + this.id)

        if(centerValue && centerValue.IsA("Vector3Value")){
            this.centerVector = centerValue.Value
        }else{
            throw "No plot center finded, error"
        }

        const plotModel = Workspace.FindFirstChild("plot" + this.id)

        if(plotModel && plotModel.IsA("Model")){
            this.floorZeroHeight = 0
        }else{
            throw "No plot model finded, error"
        }

    }

    public isVectorInPLot(vector: Vector3){
        const x = vector.X - this.centerVector.X
        const z = vector.Z - this.centerVector.Z

        return math.abs(x) <= Plot.size / 2 && math.abs(z) <= Plot.size / 2
    }

    public isModelInPlot(model: Model){
        const [cf, size] = model.GetBoundingBox()
        const position = cf.Position

        const half = size.div(2)

        // The y position doesn't matter
        const positiveCorner = position.add(new Vector3(half.X, 0, half.Z))
        const negativeCorner = position.add(new Vector3(-half.X, 0, -half.Z))

        // If both opposites corners are on the plot, the box is in the plot
        return this.isVectorInPLot(positiveCorner) && this.isVectorInPLot(negativeCorner)
    }   

    public playerCanBuild(player: Player){
        return this.owner === player
    }

    // Getters

    public getId(){
        return this.id
    }

    public getCenter(){
        return this.centerVector
    }

}