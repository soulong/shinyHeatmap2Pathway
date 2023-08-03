
library(shiny)
library(htmlwidgets)
library(shinyjs)
library(colourpicker)
library(readxl)
library(writexl)
library(DT)
library(cowplot)
library(tidyverse)
# library(annoHub) # devtools::install_github("soulong/annoHub")
# library(seqKit) # devtools::install_github("soulong/seqKit")
library(grid)

options(shiny.maxRequestSize=50*1024^2)


server <- shinyServer(function(input, output, session) {

  #====================================================#
  ## upload data ###
  #====================================================#
  expr <- reactive({
    infile <- input$expr
    if(is.null(input$expr)) return(NULL)
    file.rename(infile$datapath, paste(infile$datapath, ".xlsx", sep=""))
    return(read_xlsx(paste(infile$datapath, ".xlsx", sep=""), sheet=input$expr_type))
  })
  
  # read sample info
  sample_info <- reactive({
    infile <- input$sample_info
    if(is.null(input$sample_info)) return(NULL)
    file.rename(infile$datapath, paste(infile$datapath, ".xlsx", sep=""))
    return(read_xlsx(paste(infile$datapath, ".xlsx", sep=""), sheet=1))
  })
  
  # update sample_group_cols
  observe({ updateSelectInput(session, "sample_group_cols", "select grouping columns", colnames(sample_info())[-(1:4)]) })
  
  # sample_group_cols
  sample_group_cols <- reactive({
    if(is.null(input$sample_info)) return(NULL)
    return(input$sample_group_cols)
  })
  
  filter_ui <- reactive({
    switch(input$gene_filter_type,
           pairwise=tagList(fileInput("filter_pairwise", "pairwise result", accept=c(".xlsx")),
                            fluidRow(column(6, numericInput("filter_fc_thred", "foldchange thredhold", 2, 1, Inf, NA)),
                                     column(6, numericInput("filter_padj_thred", "padj thredhold", 0.05, 0, 1, NA)))),
           lrt=tagList(fileInput("filter_lrt", "lrt result", accept=c(".xlsx")),
                       numericInput("filter_padj_thred", "padj thredhold", 0.05, 0, 1, NA)),
           goid=tagList(textInput("filter_goid", "GO id", placeholder="GO:0007219")),
           genelist=tagList(textAreaInput("filter_genelist", "offical gene symbol", height=80))
           )
  })
  
  # render gene_filter_ui
  output$gene_filter_ui <- renderUI({ filter_ui() })

  
  # prepare filtered matrix
  matList <- eventReactive(input$upload_apply, {
    # prepare filter genes
    if(input$gene_filter_type=="pairwise") {
      infile <- input$filter_pairwise
      file.rename(infile$datapath, paste(infile$datapath, ".xlsx", sep=""))
      gene_filter_data <- read_xlsx(paste(infile$datapath, ".xlsx", sep=""), sheet="all")
    }
    if(input$gene_filter_type=="lrt") {
      infile <- input$filter_lrt
      file.rename(infile$datapath, paste(infile$datapath, ".xlsx", sep=""))
      gene_filter_data <- read_xlsx(paste(infile$datapath, ".xlsx", sep=""), sheet="all")
    }
    if(input$gene_filter_type=="goid") gene_filter_data <- str_trim(input$filter_goid)
    if(input$gene_filter_type=="genelist") gene_filter_data <- str_trim(unique(input$filter_genelist))
    
    # prepare matrix for heatmap
    matList <- seqKit::prepareHeatmap(expr(), 
                                      input$expr_anno_cols, 
                                      input$expr_type, 
                                      input$low_expr_filter, 
                                      input$low_expr_thredhold, 
                                      sample_info(), 
                                      sample_group_cols(), 
                                      gene_filter_data, 
                                      input$gene_filter_type, 
                                      input$species, 
                                      input$filter_padj_thred, 
                                      input$filter_fc_thred, 
                                      identifier="external_gene_name")
    
    print(str(matList))
    return(matList)
  })
  
  output$filter_result <- renderDT({ matList()[[1]] })
  
  
  
  
  #====================================================#
  ## heatmap ###
  #====================================================#
  heatmap <- eventReactive(input$ht_apply, {
    color_map <- as.numeric(c(-input$ht_color_map, 0, input$ht_color_map))
    heatmap <- seqKit::plotHeatmap(matList()[[1]], 
                                   matList()[[2]], 
                                   matList()[[3]],
                                   input$ht_clusters, 
                                   input$ht_col_cluster_type, 
                                   input$ht_rownames_size,
                                   color_map)
    
    return(heatmap)
  })
  
  # plot
  output$ht_plot <- renderPlot({ print(heatmap()[[1]]) })
  output$ht_plot_ui <- renderUI({
    plotOutput("ht_plot", width=paste0(input$ht_plot_width, "px"), height=paste0(input$ht_plot_height, "px"))
  })
  
  # download
  output$download_plot <- downloadHandler(filename=paste0(as.character(Sys.Date()), "_heatmap.pdf"), 
                                          content=function(file) {
                                            pdf(file, width=(input$ht_plot_width/50), height=(input$ht_plot_height/50))
                                            print(heatmap()[[1]])
                                            dev.off() })
  
  output$download_data <- downloadHandler(
    filename=paste0(as.character(Sys.Date()), "_heatmap_data.xlsx"),
    content=function(path) writexl::write_xlsx(heatmap()[[2]], path),
    contentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")

  
  
  
  #====================================================#
  ## enrichment ###
  #====================================================#
  # update cluster choices
  observe({ updateSelectInput(session, "choose_cluster", "select cluster to enrich", 1:as.numeric(input$ht_clusters), 1) })
  
  # enrich ORA
  enrichment <- eventReactive(input$enrich_apply, {
    genes <- heatmap()[[2]][[input$choose_cluster]]$ID
    print(head(genes))
    enrichment <- seqKit::enrich_ORA(genes,
                                     input$species,
                                     input$enrich_db,
                                     input$enrich_pval_cutoff,
                                     input$enrich_qval_cutoff
    )
    print("enrichment done")
    return(enrichment)
  })
  


  # plot
  output$enrichment_plot <- renderPlot({ 
    if(!is.null(enrichment())) 
      plot_grid(plotlist=seqKit::enrich_Dotplot(enrichment(), input$enrich_show_category, text_len=50), 
                labels=names(enrichment())) 
    })
  output$enrichment_plot_ui <- renderUI({
      plotOutput("enrichment_plot", width=paste0(input$enrich_plot_width, "px"), height=paste0(input$enrich_plot_height, "px"))
  })
  
  
})


