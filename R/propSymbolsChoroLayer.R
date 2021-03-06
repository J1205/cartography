#' @title Proportional and Choropleth Symbols Layer
#' @name propSymbolsChoroLayer
#' @description Plot a proportional symbols layer with colors based on a 
#' quantitative data classification 
#' @param x an sf object, a simple feature collection. If x is used then spdf, df, spdfid and dfid are not.
#' @param spdf SpatialPointsDataFrame or SpatialPolygonsDataFrame; if spdf 
#' is a SpatialPolygonsDataFrame symbols are plotted on centroids.
#' @param df a data frame that contains the values to plot. If df is missing 
#' spdf@data is used instead. 
#' @param spdfid identifier field in spdf, default to the first column 
#' of the spdf data frame. (optional)
#' @param dfid identifier field in df, default to the first column 
#' of df. (optional)
#' @param inches size of the biggest symbol (radius for circles, width for
#' squares, height for bars) in inches.
#' @param var name of the numeric field in df to plot the symbols sizes.
#' @param var2 name of the numeric field in df to plot the colors.
#' @param breaks break points in sorted order to indicate the intervals for assigning the colors. 
#' Note that if there are nlevel colors (classes) there should be (nlevel+1) 
#' breakpoints (see \link{choroLayer} Details).
#' @param col a vector of colors. Note that if breaks is specified there must be one less 
#' colors specified than the number of break. 
#' @param nclass a targeted number of classes. If null, the number of class is 
#' automatically defined (see \link{choroLayer} Details).
#' @param method a classification method; one of "sd", "equal", 
#' "quantile", "fisher-jenks", "q6" or "geom"  (see \link{choroLayer} Details).
#' @param symbols type of symbols, one of "circle", "square" or "bar".
#' @param fixmax value of the biggest symbol (see \link{propSymbolsLayer} Details).
#' @param border color of symbols borders.
#' @param lwd width of symbols borders.
#' @param legend.var.pos position of the legend, one of "topleft", "top", 
#' "topright", "right", "bottomright", "bottom", "bottomleft", "left" or a 
#' vector of two coordinates in map units (c(x, y)). If 
#' legend.var.pos is "n" then the legend is not plotted.
#' @param legend.var2.pos position of the legend, one of "topleft", "top", 
#' "topright", "right", "bottomright", "bottom", "bottomleft", "left" or a 
#' vector of two coordinates in map units (c(x, y)). If 
#' legend.var2.pos is "n" then the legend is not plotted.
#' @param legend.var.title.txt title of the legend (proportional symbols).
#' @param legend.var2.title.txt title of the legend (colors).
#' @param legend.title.cex size of the legend title.
#' @param legend.values.cex size of the values in the legend.
#' @param legend.var.values.rnd number of decimal places of the values in 
#' the legend.
#' @param legend.var2.values.rnd number of decimal places of the values in 
#' the legend.
#' @param legend.var.style either "c" or "e". The legend has two display 
#' styles.
#' @param legend.var.frame whether to add a frame to the legend (TRUE) or 
#' not (FALSE).
#' @param legend.var2.frame whether to add a frame to the legend (TRUE) or 
#' not (FALSE).
#' @param legend.var2.nodata text for "no data" values
#' @param legend.var2.border color of boxes borders in the legend.
#' @param legend.var2.horiz whether to display the legend horizontally (TRUE) or
#' not (FALSE).
#' @param colNA no data color. 
#' @param add whether to add the layer to an existing plot (TRUE) or 
#' not (FALSE).
#' @examples
#' library(sf)
#' mtq <- st_read(system.file("gpkg/mtq.gpkg", package="cartography"))
#' plot(st_geometry(mtq), col = "grey60",border = "white",
#'      lwd=0.4, bg = "lightsteelblue1")
#' propSymbolsChoroLayer(x = mtq, var = "POP", var2 = "MED",
#'                       col = carto.pal(pal1 = "blue.pal", n1 = 3,
#'                                       pal2 = "red.pal", n2 = 3),
#'                       inches = 0.2, method = "q6",
#'                       border = "grey50", lwd = 1,
#'                       legend.var.pos = "topright", 
#'                       legend.var2.pos = "left",
#'                       legend.var2.values.rnd = -2,
#'                       legend.var2.title.txt = "Median Income\n(in euros)",
#'                       legend.var.title.txt = "Total Population",
#'                       legend.var.style = "e")
#' # First layout
#' layoutLayer(title="Population and Wealth in Martinique, 2015")
#' @export
#' @seealso \link{legendBarsSymbols}, \link{legendChoro}, 
#' \link{legendCirclesSymbols}, \link{legendSquaresSymbols}, 
#' \link{choroLayer}, \link{propSymbolsLayer}
propSymbolsChoroLayer <- function(x, spdf, df, spdfid = NULL, dfid = NULL,
                                  var, 
                                  inches = 0.3, fixmax = NULL, 
                                  symbols = "circle", border = "grey20", 
                                  lwd = 1,
                                  var2, 
                                  breaks = NULL,  method="quantile",  
                                  nclass= NULL, 
                                  col = NULL,
                                  colNA = "white",
                                  legend.title.cex = 0.8, 
                                  legend.values.cex = 0.6,
                                  legend.var.pos = "right",
                                  legend.var.title.txt = var, 
                                  legend.var.values.rnd = 0, 
                                  legend.var.style = "c",
                                  legend.var.frame = FALSE, 
                                  legend.var2.pos = "topright", 
                                  legend.var2.title.txt = var2,
                                  legend.var2.values.rnd = 2,  
                                  legend.var2.nodata = "no data",
                                  legend.var2.frame = FALSE, 
                                  legend.var2.border = "black", 
                                  legend.var2.horiz = FALSE,
                                  add = TRUE){
  
  if (missing(x)){
    x <- convertToSf(spdf = spdf, df = df, spdfid = spdfid, dfid = dfid)
  }
  
  # check merge and order spdf & df
  dots <- checkMergeOrder(x = x, var = var)
  
  # Color Management
  layer <- choro(var = dots[[var2]], distr = breaks, col = col, 
                 nclass = nclass, method = method)
  
  mycols <- as.vector(layer$colMap)
  
  nodata <- FALSE
  if(max(is.na(dots[[var2]]) > 0)){
    nodata <- TRUE
    mycols[is.na(mycols)] <- colNA
  }
  
  if (is.null(fixmax)){
    fixmax <- max(dots[[var]])
  }
  
  # compute sizes
  sizes <- sizer(dots = dots, inches = inches, var = var, 
                 fixmax = fixmax, symbols = symbols)
  
  # size and values for legend, hollow circle (fixmax case)
  sizeMax <- max(sizes)
  if (inches <= sizeMax){
    sizevect <- xinch(seq(inches, min(sizes), length.out = 4))
    varvect <- seq(fixmax, 0, length.out = 4)
    inches <- sizeMax
  }else{
    mycols <- c(NA, mycols)
    border <- c(NA, rep(border, nrow(dots)))
    dots <- rbind(dots[1,],dots)
    dots[1,var] <- fixmax
    sizes <- c(inches, sizes)
    sizevect <- xinch(seq(inches, min(sizes), length.out = 4))
    varvect <- seq(fixmax, 0,length.out = 4 )
  }
  
  # plot
  if (add==FALSE){
    bbx <- sf::st_bbox(x)
    plot(0, type='n', axes = FALSE, ann = FALSE, asp = 1, 
         xlim = bbx[c(1,3)], ylim = bbx[c(2,4)])
  }
  
  
  switch(symbols, 
         circle = {
           symbols(dots[, 1:2, drop = TRUE], circles = sizes, 
                   bg = as.vector(mycols), 
                   fg = border, 
                   lwd = lwd, add = TRUE, inches = inches, asp = 1)
           legendCirclesSymbols(pos = legend.var.pos, 
                                title.txt = legend.var.title.txt,
                                title.cex = legend.title.cex,
                                values.cex = legend.values.cex,
                                var = c(min(dots[[var]]),max(dots[[var]])),
                                inches = inches,
                                col = "grey", lwd = lwd, 
                                frame = legend.var.frame,
                                values.rnd =  legend.var.values.rnd,
                                style = legend.var.style)
         }, 
         square = {
           symbols(dots[, 1:2, drop = TRUE], squares = sizes, 
                   bg = as.vector(mycols), 
                   fg = border, 
                   lwd = lwd, add = TRUE, inches = inches, asp = 1)
           legendSquaresSymbols(pos = legend.var.pos, 
                                title.txt = legend.var.title.txt,
                                title.cex = legend.title.cex,
                                values.cex = legend.values.cex,
                                var = c(min(dots[[var]]),max(dots[[var]])),
                                inches = inches,
                                col = "grey", lwd = lwd,
                                frame = legend.var.frame,
                                values.rnd =  legend.var.values.rnd,
                                style = legend.var.style)
         }, 
         bar = {
           tmp <- as.matrix(data.frame(width = inches/7, height = sizes))
           dots[[2]] <- dots[[2]] + yinch(sizes/2)
           symbols(dots[, 1:2, drop = TRUE], rectangles = tmp, add = TRUE, 
                   bg = as.vector(mycols),
                   fg = border, lwd = lwd, inches = inches, asp = 1)
           
           legendBarsSymbols(pos = legend.var.pos, 
                             title.txt = legend.var.title.txt,
                             title.cex = legend.title.cex,
                             values.cex = legend.values.cex,
                             var = c(min(dots[[var]]),max(dots[[var]])),
                             inches = inches,
                             col = "grey", lwd = lwd,
                             frame = legend.var.frame,
                             values.rnd =  legend.var.values.rnd,
                             style = legend.var.style)
         })
  
  
  legendChoro(pos = legend.var2.pos, 
              title.txt = legend.var2.title.txt,
              title.cex = legend.title.cex,
              values.cex = legend.values.cex,
              breaks = layer$distr, 
              col = layer$col, 
              values.rnd = legend.var2.values.rnd,
              frame = legend.var2.frame, 
              symbol="box", 
              nodata = nodata, nodata.col = colNA,
              nodata.txt = legend.var2.nodata, 
              border = legend.var2.border, horiz = legend.var2.horiz)
}
