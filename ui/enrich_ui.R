
fluidRow(
  column(width=3, 
         wellPanel(
           style = "overflow-y:scroll; max-height: 1000px",
           
           selectInput("choose_cluster", "select cluster to enrich", 1, 1),
           checkboxGroupInput("enrich_db", "choose db", c("go", "kegg", "msigdb", "enrichr"), "go", inline=T),
           fluidRow(column(6, numericInput("enrich_pval_cutoff", "pval cutoff", 0.2, 0, 1)),
                    column(6, numericInput("enrich_qval_cutoff", "qval cutoff", 0.5, 0, 1))),
           div(style="display:inline-block; width:90%; text-align:center;", 
               actionButton("enrich_apply", "Enriching", icon("far fa-edit"))),
           hr(),
           br(),
           
           sliderInput("enrich_show_category", "show category number", 5, 50, 10, 5),
           sliderInput("enrich_plot_width", "plot width", 200, 1600, 800, 100),
           sliderInput("enrich_plot_height", "plot height", 200, 1600, 800, 100),
           
           hr(),
           br(),
           div(style="display:inline-block; width:48%; text-align:center;", downloadButton("enrich_plot", "PDF")),
           div(style="display:inline-block; width:48%; text-align:center;", downloadButton("enrich_data", "Data"))
         )
  ), # end od left side bar column
  
  # main plot area
  column(width=9, 
         uiOutput("enrichment_plot_ui")
       # plotOutput("enrichment_plot")
  ) # end of column
)
