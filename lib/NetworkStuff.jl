
module NetworkStuff
using Graphs
using PlotlyBase
using GraphPlot
export extract_plot_info


function get_edges_list(G, pos_x, pos_y)
    edges_list = []
     
    for edge in Graphs.edges(G)
        push!(edges_list, scatter(; x=[pos_x[src(edge)], pos_x[dst(edge)]],
                                y = [pos_y[src(edge)], pos_y[dst(edge)]],
                                line=attr(color="#888", backoff=10),marker=attr(size=10,
                                symbol= "arrow-bar-up", angleref="previous", standoff=10), name="", 
                                showlegend=false, hoverinfo="none"))
        
    end
    return edges_list
end
function extract_plot_info(G_gs, G_est, prots, neighborhood_inds)
    if length(neighborhood_inds) == 1
        nodes_g = scatter(;x=[0], y=[0], mode="markers",marker=attr(size=16), showlegend=false,
                        text = prots[neighborhood_inds], hoverinfo="text")
        edges_gs = []
        edges_est = []
        return nodes_g, edges_gs, edges_est
    else
        pos_x, pos_y = GraphPlot.spring_layout(G_gs)
                
        
        edges_gs = get_edges_list(G_gs, pos_x, pos_y)
        edges_est = get_edges_list(G_est, pos_x, pos_y)
        
        nodes_g = scatter(;x=pos_x, y=pos_y, mode="markers",marker=attr(size=16), showlegend=false,
                        text = prots[neighborhood_inds], hoverinfo="text")
        

        return nodes_g, edges_gs, edges_est
    end
end


end