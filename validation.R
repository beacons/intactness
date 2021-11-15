library(sf)
library(tmap)
library(tidyverse)
library(shinydashboard)

bead <- st_read('data/bead/_ranges.gpkg', quiet=T) # %>% st_zm(drop=T)
ranges = sort(bead$Herd_OS)
opts <- tmap_options(basemaps = c(Imagery="Esri.WorldImagery", Map="Esri.NatGeoWorldMap", OSM="OpenStreetMap.Mapnik"))
tmap_options(check.and.fix = TRUE)

ui = dashboardPage(
  dashboardHeader(title = "Intactness Validation"),
  dashboardSidebar(
    sidebarMenu(
        menuItem("View disturbances", tabName = "fri", icon = icon("th"))
    ),
    selectInput("range", label = "Caribou range:", choices = ranges, selected='CaribouMountains'),
    selectInput("intact", label = "Intactness map:", choices = c('HA2010','CIFL2013','GIFL2016','HFP2013','HFP2019','GHM2016','AB2015','VLIA2015'), selected='HA2010'),
    selectInput("type", label="Disturbance type:", choices=c('poly30','line30','poly15','line15'), selected='poly30')
  ),
  dashboardBody(
    tabItems(
        tabItem(tabName="fri",
            fluidRow(
                #box(title = "Intactness map", tmapOutput("map", height=600), width=12)
                tabBox(
                    id = "one", width="12",
                    tabPanel("Intactness map", tmapOutput("map", height=600))
                )
            )
        )
    )
  )
)

server = function(input, output) {

    #intact2 <- reactive({
    #    if (input$intact=='HFP2019') {
    #        v = st_read(paste0('data/bead/',input$range,'.gpkg'), 'hfp2019') %>% st_make_valid()
    #    }
    #})

    output$map <- renderTmap({
        cr = input$range
        if (input$range=="AtikakiBernes") {cr="Atikaki_Bernes"}
        if (input$range=="OwlFlinstone") {cr="Owl_Flinstone"}
        if (input$range=="SnakeSahtahneh") {cr="Snake_Sahtahneh"}
        range = filter(bead, Herd_OS==input$range)
        intact = st_read(paste0('data/bead/',cr,'.gpkg'), input$intact) %>% st_make_valid()
        type = st_read(paste0('data/bead/',cr,'.gpkg'), input$type) #%>% st_make_valid()
        tm = tm_shape(range) + tm_borders(col='yellow', lwd=2)
        if (input$type %in% c('poly30','poly15')) {
            tm = tm + tm_shape(type) + tm_borders(col='green', lwd=2) +
                tm_shape(intact) + tm_fill(col='red', alpha=0.5)
        } else {
            tm = tm + tm_shape(type) + tm_lines(col='green', lwd=2) +
                tm_shape(intact) + tm_fill(col='red', alpha=0.5)
        }
    })

}
shinyApp(ui, server)
