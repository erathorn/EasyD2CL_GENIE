heading("D2CL Analysis")

row([
    # cell(
    #       class="st-module",
    #       [
    #        h6("File")
    #        Stipple.select(:selected_file; options=:upfiles, clearable=true,usechips=true)
    #       ]
    #      )
    cell(class="st-module",
    [
        btn(
            "Read File",
            @click(:Button_readfile), 
            color = "primary",
            class = "q-mr-sm",
        ),
    ]
    )
    cell(class="st-module", 
        [
         h6("Identifier")
         p("Please enter or select Protein/Gene")
         Stipple.select(:selected; 
                    options = :options,
                    usechips = true,
                    useinput=true,
                    clearable=true,
                    Stipple.@on(:filter, "filterFn"),
                    multiple=false
                    
         
                        )
        ])
])
row([
    cell(
        class="st-module",
        [      
         p("Specify cutoff")
            Stipple.Html.div(
                class = "q-pa-md",
                [
                    slider(0.1:0.01:1, :cf, labelalways=true)
                ],
            )
            
          ]
         ),
    cell(
          class="st-module",
          [
            p("Neighborhood")
            Stipple.Html.div(
                class = "q-pa-md",
                [
                    slider(1:1:3, :n_size, labelalways=true)
                ],
            )
          
          ]
         
    ),

    
    cell(class="st-module",
    [
        btn(
            "Analyze",
            @click(:ButtonProgress_process),
            loading = :ButtonProgress_process,
            percentage = :ButtonProgress_progress,
            color = "primary",
            class = "q-mr-sm",
        ),
    ]
)]
)


row([
    
    cell(
        h4("In Connections"),
        class="st-module",
        [mycard("Info", :network_infos)],   
    )
    cell(
        h4("Out Connections"),
        class="st-module",
        [mycard("Info", :network_infos_2)]
    )
])

row([
    
     cell(
          class="st-module",
          [
           h5("Network Gold Standard In connections")
           plot(:network_gs_in, layout=:Layout_Network)
          ]
         )
    cell(
          class="st-module",
          [
           h5("Network Estimated In connections")
           plot(:network_est_in, layout=:Layout_Network)
          ]
         )
      
    ])



row([
    
    
     cell(
          class="st-module",
          [
           h5("Network Gold Standard Out Connections")
           plot(:network_gs_out, layout=:Layout_Network)
          ]
         )
    cell(
          class="st-module",
          [
           h5("Network Estimated Out Connections")
           plot(:network_est_out, layout=:Layout_Network)
          ]
         )
      
    ])
