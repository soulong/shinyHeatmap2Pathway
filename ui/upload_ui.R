
fluidRow(
  column(width=3, # left side bar column
         wellPanel(
           style = "overflow-y:scroll; max-height: 1000px",
           
           fileInput("expr", "expression file", accept=c(".xlsx")),
           fluidRow(column(4, radioButtons("expr_type", "expression type", c("tpm","counts"), "tpm")),
                    column(4, radioButtons("species", "gene name species", c("hs","mm"), "mm")),
                    column(4, numericInput("expr_anno_cols", "anno column numbers", 5, 1, 10))),
           hr(),
           br(),
           fileInput("sample_info", "sample info file", accept=c(".xlsx")),
           selectInput("sample_group_cols", "select grouping columns", NULL, multiple=T),
           hr(),
           br(),
           
           radioButtons("gene_filter_type", "filter type", c("pairwise","lrt", "goid", "genelist"), "goid", inline=T),
           uiOutput("gene_filter_ui"),
           fluidRow(column(5, checkboxInput("low_expr_filter", "filter low expression", T)),
                    column(7, numericInput("low_expr_thredhold", "low expression thredhold", 1, 0, NA))
                    ),
           hr(),
           
           div(style="display:inline-block; width:90%; text-align:center;", 
               actionButton("upload_apply", "Submit", icon("far fa-kiss-wink-heart")))

         )
  ), # end od left side bar column
  
  # main plot area
  column(width=9,
         DTOutput("filter_result")
  ) # end of column
)
