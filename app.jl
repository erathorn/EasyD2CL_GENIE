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
    @out network_infos_2::String = ""
    @out network_gs_in = [scatter()]
    @out network_est_in = [scatter()]
    @out network_gs_out = [scatter()]
    @out network_est_out = [scatter()]
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
        @info size(adjacency_gs)            
        g_gs = SimpleDiGraph(adjacency_gs)
        
        neighborhood_inds_in = neighborhood(g_gs, p_inds, n_size, dir=:in)
        neighborhood_inds_out = neighborhood(g_gs, p_inds, n_size, dir=:out)
        @info size(neighborhood_inds_in), size(neighborhood_inds_out)
        
        adjacency_gs_small_in = adjacency_gs[neighborhood_inds_in, neighborhood_inds_in]
        adjacency_est_small_in = adjacency_estm[neighborhood_inds_in, neighborhood_inds_in] .> cf
        adjacency_gs_small_out = adjacency_gs[neighborhood_inds_out, neighborhood_inds_out]
        adjacency_est_small_out = adjacency_estm[neighborhood_inds_out, neighborhood_inds_out] .> cf
        @info size(adjacency_gs_small_in), size(adjacency_gs_small_out)
        
        network_infos=
        "Node $(selected) has $(length(neighborhood_inds_in)) in-neighbours in the gold standard"
        network_infos_2 = "Node $(selected) has $(length(neighborhood_inds_out)) out-neighbours in the gold standard"
        @info network_infos, network_infos_2
        g_gs_small_in = SimpleDiGraph(adjacency_gs_small_in)
        g_est_small_in = SimpleDiGraph(adjacency_est_small_in)
        nodes_g_in, edges_gs_in, edges_est_in = extract_plot_info(g_gs_small_in, g_est_small_in, prots, neighborhood_inds_in)
        println("got in network")
        network_gs_in = [edges_gs_in..., nodes_g_in]
        network_est_in = [edges_est_in..., nodes_g_in]
        println("plotted in network")
        g_gs_small_out = SimpleDiGraph(adjacency_gs_small_out)
        g_est_small_out = SimpleDiGraph(adjacency_est_small_out)
        nodes_g_out, edges_gs_out, edges_est_out = extract_plot_info(g_gs_small_out, g_est_small_out, prots, neighborhood_inds_out)
        println("got out network")
        network_gs_out = [edges_gs_out..., nodes_g_out]
        network_est_out = [edges_est_out..., nodes_g_out]
    
        notify(__model__, "Plotted successfully")
    end

    

end


function mycard(title, nv1)
    card(style="width:400px",
         [
          card_section([h4(title)]),
          card_section(textfield(nv1))
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


