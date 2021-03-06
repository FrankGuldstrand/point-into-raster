pointtorasnter=function(df=df,shapeData=Lux_shapeData){
  spg = na.omit(df)
  # coerce to SpatialPixelsDataFrame
  coordinates(spg) = ~ x + y
  proj4string(spg) =  CRS("+proj=longlat +ellps=WGS84")
  #extend the SpatialPixelsDataFrame into the regular box
  spg@bbox=shapeData@bbox
  
  # Create an empty grid where n is the total number of cells
  grd              = as.data.frame(spsample(spg, "regular", n=50000))
  names(grd)       = c("X", "Y")
  coordinates(grd) = c("X", "Y")
  gridded(grd)     = TRUE  # Create SpatialPixel object
  fullgrid(grd)    = TRUE  # Create SpatialGrid object
  # Add P's projection information to the empty grid
  proj4string(grd) = CRS("+proj=longlat +ellps=WGS84")
  
  # Interpolate the grid cells using a power value of 2 (idp=2.0)
  P.idw = gstat::idw(num ~ 1, spg, newdata=grd, idp=2.0)
  # Convert to raster object then clip to shapefile
  r       = raster(P.idw)
  r.m     = mask(r, shapeData)
  #extend the SpatialPixelsDataFrame into the regular box
  extent(r.m)=extent(shapeData@bbox[1], shapeData@bbox[3], 
                     shapeData@bbox[2], shapeData@bbox[4])
  return(r.m)
}
