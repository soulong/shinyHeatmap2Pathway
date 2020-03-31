
ui <- navbarPage(
  title="shiny- from Data to Heatmap to Enrichment",
  id="navbar",
  selected="upload_page", 
  #shinythemes::themeSelector(), # To choose a theme, uncomment this
  theme=shinythemes::shinytheme("united"), 
  
  #====================================================#
  ## upload ####
  #====================================================#
  tabPanel(title="Data", value="upload_page",
           source(file.path("ui", "upload_ui.R"), local=T)$value
           ),  
  
  #====================================================#
  ## heatmap ####
  #====================================================#
  tabPanel(title="Heatmap", value="heatmap_page",
           source(file.path("ui", "heatmap_ui.R"), local=T)$value
           ),
  
  #====================================================#
  ## enrichment ####
  #====================================================#
  tabPanel(title="Enrichment", value="enrich_page",
           source(file.path("ui", "enrich_ui.R"), local=T)$value
           )
)
