
fluidRow(
  column(width=3, 
         wellPanel(
           style = "overflow-y:scroll; max-height: 1000px",
           
           radioButtons("ht_col_cluster_type", "column cluster", c("auto", "semi_supervised", "false"), "auto", inline=T),
           sliderInput("ht_clusters", "split row clusters", 1, 10, 2, 1),
           sliderInput("ht_rownames_size", "rowname size", 0, 16, 4, 1),
           sliderInput("ht_color_map", "color map", 1, 6, 2, 1),
       #    sliderInput("ht_ mean_color_map", "heatmap mean color map thredhold", 1, 20, 8, 1),
           div(style="display:inline-block; width:90%; text-align:center;", 
               actionButton("ht_apply", "Heatmapping", icon("far fa-edit"))),
           hr(),
           br(),
           
           sliderInput("ht_plot_width", "heatmap width", 200, 1600, 800, 100),
           sliderInput("ht_plot_height", "heatmap height", 200, 1600, 800, 100),
           
           hr(),
           br(),
           div(style="display:inline-block; width:48%; text-align:center;", downloadButton("download_plot", "PDF")),
           div(style="display:inline-block; width:48%; text-align:center;", downloadButton("download_data", "Data"))
         )
  ), # end od left side bar column
  
  # main plot area
  column(width=9,
         uiOutput("ht_plot_ui")
  ) # end of column
)
