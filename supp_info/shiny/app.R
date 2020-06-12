library(DT)
library(sf)
library(tmap)
library(rgdal)
library(smoothr)
library(leaflet)
library(tidyverse)
library(shinydashboard)

ui = dashboardPage(
  dashboardHeader(title = "Intactness Mapper"),
  dashboardSidebar(
    sidebarMenu(
        menuItem("Boreal Region", tabName = "fri", icon = icon("th"))
    ),
    selectInput("range", label = "Select range:", choices = c("CaribouMountains","Manouane"), selected="Manouane"),
    sliderInput("lineBuffer", "Linear buffer size (m):", min = 0, max = 1000, value = 0, step=100),
    sliderInput("polyBuffer", "Polygonal buffer size (m):", min = 0, max = 1000, value = 0, step=100),
    sliderInput("minSize", "Minimum patch size (ha):", min = 0, max = 50000, value = 0, step=5000),
    hr(),
    checkboxInput("intact", "Map intactness", FALSE)
    #actionButton("goButton", "Map intactness")
  ),
  dashboardBody(
    tabItems(
        tabItem(tabName="fri",
            fluidRow(
                tabBox(
                    id = "one", width="12",
                    tabPanel("Range map", leafletOutput("map1", height=800))
                )
            )
        )
    )
  )
)

server = function(input, output) {

    #ntext <- eventReactive(input$goButton, {
        #if (input$id=="") {
        #    n = sample_n(eval(parse(text=input$inv)), 1)
        #} else {
        #    n = filter(eval(parse(text=input$inv)), eval(parse(text=input$id))) %>% sample_n(1)
        #}
    #})

    bndMap <- reactive({
        bnd = st_read(paste0(input$range,"/bnd.shp"), quiet=T)
    })

    lineMap <- reactive({
        if (input$lineBuffer==0) {
           line = st_read (paste0(input$range,"/line30.shp"), quiet=T) %>%
                st_buffer(1) %>% st_union()
        } else {   
            line = st_read (paste0(input$range,"/line30.shp"), quiet=T) %>%
                st_buffer(input$lineBuffer) %>%
                st_intersection(bndMap()) %>%
                st_union()
        }
    })

    polyMap <- reactive({
       if (input$polyBuffer==0) {
            poly = st_read (paste0(input$range,"/poly30.shp"), quiet=T)
        } else {   
            poly = st_read (paste0(input$range,"/poly30.shp"), quiet=T) %>%
                st_buffer(input$polyBuffer) %>%
                st_intersection(bndMap()) %>%
                st_union()
        }
    })

    #intactMap <- eventReactive(input$goButton, {
    intactMap <- reactive({
        if (input$intact==TRUE & (input$lineBuffer==0  & input$polyBuffer>0)) {
            line = st_buffer(lineMap(),1) %>% 
                st_intersection(bndMap()) %>% 
                st_union()
            polyline = st_union(polyMap(), line)
            intact = st_difference(bndMap(), polyline)
        } else if (input$intact==TRUE & (input$lineBuffer>0 & input$polyBuffer==0)) {
            polyline = st_union(polyMap(), lineMap())
            intact = st_difference(bndMap(), polyline)
        } else if (input$intact==TRUE & (input$lineBuffer>0 & input$polyBuffer>0)) {
            polyline = st_union(polyMap(), lineMap())
            intact = st_difference(bndMap(), polyline)
        } else {
            line = st_buffer(lineMap(),1) %>% 
                st_intersection(bndMap()) %>% 
                st_union()
            polyline = st_union(polyMap(), line)
            intact = st_difference(bndMap(), polyline)
        }
        if (input$minSize>0) {
            i = drop_crumbs(intact, input$minSize*10000)
        } else {
            i = intact
        }
    })

    output$map1 <- renderLeaflet({
            opa = 1 # fill opacity
            ha2010_col = '#ffff99'
            cifl2013_col = '#b2df8a'
            gifl2016_col= '#a6cee3'
            hfp2013_col = '#fb9a99'
            vlia2015_col = '#fdbf6f'
            ghm2016_col = '#ff7f00'
            ab2015_col = '#cab2d6'
            bnd = bndMap() %>% st_transform(CRS("+proj=longlat +datum=WGS84"))
            poly = st_read(paste0(input$range,"/poly30.shp"), quiet=T) %>% st_transform(CRS("+proj=longlat +datum=WGS84"))
            bPoly = polyMap() %>% st_transform(CRS("+proj=longlat +datum=WGS84"))
            line = st_read(paste0(input$range,"/line30.shp"), quiet=T) %>% st_buffer(1) %>% st_transform(CRS("+proj=longlat +datum=WGS84"))
            bLine = lineMap() %>% st_transform(CRS("+proj=longlat +datum=WGS84"))
            ha2010 = st_read(paste0(input$range,"/ha2010.shp"), quiet=T) %>% st_transform(CRS("+proj=longlat +datum=WGS84"))
            cifl2013 = st_read(paste0(input$range,"/cifl2013.shp"), quiet=T) %>% st_transform(CRS("+proj=longlat +datum=WGS84"))
            gifl2016 = st_read(paste0(input$range,"/gifl2016.shp"), quiet=T) %>% st_transform(CRS("+proj=longlat +datum=WGS84"))
            vlia2015 = st_read(paste0(input$range,"/vlia2015.shp"), quiet=T) %>% st_transform(CRS("+proj=longlat +datum=WGS84"))
            ghm2016 = st_read(paste0(input$range,"/ghm2016.shp"), quiet=T) %>% st_transform(CRS("+proj=longlat +datum=WGS84"))
            ab2015 = st_read(paste0(input$range,"/ab2015.shp"), quiet=T) %>% st_transform(CRS("+proj=longlat +datum=WGS84"))
            hfp2013 = st_read(paste0(input$range,"/hfp2013.shp"), quiet=T) %>% st_transform(CRS("+proj=longlat +datum=WGS84"))
            m = leaflet(bnd) %>%
                addProviderTiles("Esri.NatGeoWorldMap", group="Map") %>%
                addProviderTiles("Esri.WorldImagery", group="Imagery") %>%
                addPolygons(data=bnd, fill=F, weight=2, color="black", fillOpacity=1, group="Range")
            if (input$intact==TRUE) {
                intact = intactMap() %>% st_transform(CRS("+proj=longlat +datum=WGS84"))
                m = m %>% addPolygons(data=intact, fill=T, weight=1, color='#33a02c', fillOpacity=opa, group="Intact area")
            }
            m = m %>% 
                addPolygons(data=line, fill=T, weight=1, color="black", fillOpacity=1, group="Linear") %>%
                addPolygons(data=bLine, fill=T, weight=1, color="darkred", fillOpacity=0.5, group="Linear buffered") %>%
                addPolygons(data=poly, fill=T, weight=1, color="black", fillOpacity=1, group="Polygonal") %>%
                addPolygons(data=bPoly, fill=T, weight=1, color="darkred", fillOpacity=0.5, group="Polygonal buffered") %>%
                addPolygons(data=cifl2013, fill=T, weight=2, color=cifl2013_col, fillOpacity=opa, group="CIFL2013") %>%
                addPolygons(data=ha2010, fill=T, weight=2, color=ha2010_col, fillOpacity=opa, group="HA2010") %>%
                addPolygons(data=gifl2016, fill=T, weight=2, color=gifl2016_col, fillOpacity=opa, group="GIFL2016") %>%
                addPolygons(data=hfp2013, fill=T, weight=2, color=hfp2013_col, fillOpacity=opa, group="HFP2013") %>%
                addPolygons(data=vlia2015, fill=T, weight=2, color=vlia2015_col, fillOpacity=opa, group="VLIA2015") %>%
                addPolygons(data=ghm2016, fill=T, weight=2, color=ghm2016_col, fillOpacity=opa, group="GHM2016") %>%
                addPolygons(data=ab2015, fill=T, weight=2, color=ab2015_col, fillOpacity=opa, group="AB2015") %>%
                addLayersControl(position = "topright",
                    baseGroups=c("Map", "Imagery"),
                    overlayGroups = c("Range","Linear","Linear buffered","Polygonal","Polygonal buffered","Intact area","HA2010","CIFL2013","GIFL2016","HFP2013","VLIA2015","GHM2016","AB2015"),
                    options = layersControlOptions(collapsed = FALSE)) %>%
                    hideGroup(c("Linear","Linear buffered","Polygonal","Polygonal buffered","Intact area","HA2010","CIFL2013","GIFL2016","HFP2013","VLIA2015","GHM2016","AB2015"))
            m
    })
}
shinyApp(ui, server)