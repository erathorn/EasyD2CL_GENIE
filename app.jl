module App
using Main.NetworkStuff
#include("NetworkStuff.jl")
using GenieFramework, Graphs, DataFrames, Statistics, CSV, GraphPlot, Serialization, PlotlyBase
import Stipple: js_methods
@genietools

# Logic goes here
const FILE_PATH = joinpath("data")
mkpath(FILE_PATH)

@app begin
    @out upfiles = readdir(FILE_PATH)
    @in selected_file::String = ""
    @in cf::Float64 = 0.5
    @in n_size::Int = 2
    @in selected::String = ""
    @out options::Vector{String} = ["none"]
    @out prots_select::Vector{String} = ["none"]
    @private prots::Vector{String} = ["none"]
    @private g_gs::SimpleDiGraph = SimpleDiGraph()
    @out options::Vector{String} = []
    @in filter::String = ""
    @in ButtonProgress_process = false
    @in ButtonProgress_progress = 0.0
    @in Button_readfile = false
    
    
    @private adjacency_gs::Matrix{Int} = Matrix(undef, 1,1)#deserialize("$FILE_PATH/adj_2_gs.sl")
    @private adjacency_estm::Matrix{Float16} = Matrix(undef, 1, 1)#deserialize("$FILE_PATH/adj_2_est.sl")
    @private prot_inds::Dict{String, Int} = Dict()#prot => i for (i, prot) in enumerate(prots))
    @out network_gs = [scatter()]
    @out network_est = [scatter()]
    @out Layout_Network = PlotlyBase.Layout(yaxis_title_text="",xaxis_title_text="", showarrow=true, showlegend=false)

    # #reactive code goes here

    # @onchange fileuploads begin
    #     if ! isempty(fileuploads)
    #         @info "File was uploaded: " fileuploads
    #         filename = fileuploads["name"]

    #         try
    #             isdir(FILE_PATH) || mkpath(FILE_PATH)
    #             mv(fileuploads["path"], joinpath(FILE_PATH, filename), force=true)
    #         catch e
    #             @error "Error processing file: $e"
    #             notify(__model__,"Error processing file: $(fileuploads["name"])")
    #         end

    #         fileuploads = Dict{AbstractString,AbstractString}()
    #     end
    #     upfiles = readdir(FILE_PATH)
    # end
    

    @onchange filter begin
        if isempty(filter)
            options = prots
        elseif length(filter) >= 1 
            options = [i for i in prots if startswith(i, filter)]
        end
    end

    @onbutton Button_readfile  begin
        prots = deserialize("$FILE_PATH/ids.sl")
       
        adjacency_gs = deserialize("$FILE_PATH/adj_2_gs.sl")
       
        adjacency_estm = deserialize("$FILE_PATH/adj_2_est.sl")
       
        options = copy(prots)
        prot_inds = Dict(prot => i for (i, prot) in enumerate(prots))
        println(Button_readfile)
        notify(__model__, "Read Data")
    end
    #     if selected_file != ""
    #         println("selcted file")
    #         df = CSV.read(joinpath(FILE_PATH, selected_file), DataFrame, types=[Int, Float16, String, String])
    #         prots =  sort(unique(df.start))
    #         options = copy(prots)
    #         prot_inds = Dict(prot => i for (i, prot) in enumerate(prots))
    #         prot_rev_inds = Dict(i => prot for (i, prot) in enumerate(prots))
    #         println("did prots")
    #         adjacency_gs = zeros(Int, length(prots), length(prots))
    #         adjacency_estm = zeros(Float16, length(prots), length(prots))
    #         println("created mat")
    #         for row in eachrow(df)
    #             src = prot_inds[row.start]
    #             dst = prot_inds[row.end]
    #             adjacency_gs[src, dst] = row.labels
    #             adjacency_estm[src, dst] = row.Probability
    #         end
    #         println("done reading")
            
    #     end
    # end

    @onbutton ButtonProgress_process begin
    
        p_inds = prot_inds[selected]
        @info filter, selected, p_inds, n_size
            
        g_gs = SimpleDiGraph(adjacency_gs)
        
        neighborhood_inds = neighborhood(g_gs, p_inds, n_size)
        
        
        adjacency_gs_small = adjacency_gs[neighborhood_inds, neighborhood_inds]
        adjacency_est_small = adjacency_estm[neighborhood_inds, neighborhood_inds] .> cf
        
        g_gs_small = SimpleDiGraph(adjacency_gs_small)
        g_est_small = SimpleDiGraph(adjacency_est_small)
        nodes_g, edges_gs, edges_est = extract_plot_info(g_gs_small, g_est_small, prots, neighborhood_inds)
        network_gs = [edges_gs..., nodes_g]
        network_est = [edges_est..., nodes_g]
        
        notify(__model__, "Plotted successfully")
    end

    

end



@methods """
filterFn (val, update, abort) {
    console.log('Filtering started!')
    update(() => {
        this.filter = val
    })
}
"""

@page("/", "ui.jl")
end


