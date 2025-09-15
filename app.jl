module App
using Main.NetworkStuff
#include("NetworkStuff.jl")
using GenieFramework, Graphs, DataFrames, Statistics, CSV, GraphPlot, Serialization, PlotlyBase, HDF5
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
    
    
    @private adjacency_gs::Matrix{Int16} = Matrix(undef, 1,1)#deserialize("$FILE_PATH/adj_2_gs.sl")
    @private adjacency_estm::Matrix{Float16} = Matrix(undef, 1, 1)#deserialize("$FILE_PATH/adj_2_est.sl")
    @private prot_inds::Dict{String, Int} = Dict()#prot => i for (i, prot) in enumerate(prots))
    @out network_infos::String = "Nothing to report"
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
        h5open("$FILE_PATH/prot_exp_9.h5", "r") do f
            prots = read(f, "ids")
            adjacency_gs = read(f, "adj_gs")
            adjacency_estm = read(f, "adj_est")
        end
        println("start reading")
        #prots = deserialize("$FILE_PATH/ids.sl")
        println("ct reading")
        #adjacency_gs = deserialize("$FILE_PATH/adj_2_gs.sl")
        println("start reading")
        #adjacency_estm = deserialize("$FILE_PATH/adj_2_est.sl")
        println("start reading")
        options = copy(prots)
        prot_inds = Dict(prot => i for (i, prot) in enumerate(prots))
        println(Button_readfile)
        notify(__model__, "Read Data")
    end
   

    @onbutton ButtonProgress_process begin
    
        p_inds = prot_inds[selected]
        @info selected, p_inds, n_size
            
        g_gs = SimpleDiGraph(adjacency_gs)
        
        neighborhood_inds = neighborhood(g_gs, p_inds, n_size)
        @info neighborhood_inds
        
        adjacency_gs_small = adjacency_gs[neighborhood_inds, neighborhood_inds]
        adjacency_est_small = adjacency_estm[neighborhood_inds, neighborhood_inds] .> cf
        @info adjacency_gs_small
        network_infos="Node $(selected) has $(length(neighborhood_inds)) neighbours in the gold standard"
        
        g_gs_small = SimpleDiGraph(adjacency_gs_small)
        g_est_small = SimpleDiGraph(adjacency_est_small)
        nodes_g, edges_gs, edges_est = extract_plot_info(g_gs_small, g_est_small, prots, neighborhood_inds)
        @info nodes_g
        @info edges_gs
        network_gs = [edges_gs..., nodes_g]
        network_est = [edges_est..., nodes_g]
    
        notify(__model__, "Plotted successfully")
    end

    

end


function mycard(title, namevar)
    card(style="width:400px",
         [
          card_section([h4(title)]),
          card_section(textfield(namevar))
         ])
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


