require("osmose")

#' Sample runModel function for Osmose. It writes the calibrated
#' parameters (\code{param} argument) into a CSV file that will
#' overwrite the OSMOSE forcing files.
#' @param Parameter array.
#' @param Parameter names
#' @return A list containing all the variables 
#' used in the calibration
runModel  = function(param, names, ...) {

    # set parameter names
    names(param) = names

    # writes the calibrated parameters into a CSV file
    # following Osmose format. The parameters in this file
    # will overwrite the Osmose parameter
    write.table(param, file="./calibration-parameters.csv", sep=";", 
                col.names=FALSE, quote=FALSE)

    # define the java and Osmose executables
    javaAp = 'java'
    osmJar = '/home/nbarrier/Modeles/osmose/svn-osmose/branches/stable-3/dist/osmose_stable_3.jar'

    # defines the user directory
    outdir = "output"

    # creates output directory if does not exist
    if(!file.exists(outdir)) dir.create(outdir)
    
    # run Osmose Model
    runOsmose(osmose=osmJar, java=javaAp, input="./config.csv", 
              output=outdir, options=NULL, log="osmose.log", 
              verbose=FALSE, clean=TRUE)   
    
    # read Osmose outputs 
    data = read_osmose(path=outdir, version="v3r2")
    print(data)

    # extract the biomass and yields variables (monthly data)
    osmose.biomass = data$biomass
    osmose.thresholds = data$biomass
    osmose.yields = data$yield
    print(osmose.biomass)

    # define a year factor for yearly integration of biomass
    # from monthly biomass
    biomassDim = dim(osmose.biomass)   # dims=(time, species, replic)
    ntime = biomassDim[1]    # nyears * 12
    nspecies = biomassDim[2]
    nyears = ntime / 12
    years = factor(rep(1:nyears, each=12))

    # Integration of monthly values into yearly values
    osmose.biomass = apply(osmose.biomass, c(2, 3), tapply, years, sum)
    osmose.yields = apply(osmose.yields, c(2, 3), tapply, years, sum)

    # average over replicates
    if(length(dim(osmose.biomass)) == 3) {
        osmose.biomass = apply(osmose.biomass, c(1, 2), mean)
        osmose.yields = apply(osmose.yields, c(1, 2), mean)
        osmose.thresholds = apply(osmose.thresholds, c(1, 2), mean)
    }

    output = list(# Biomass
                  OctopusVulgaris.biomass       = param["q.sp0"]*osmose.biomass[, "OctopusVulgaris"],
                  MelicertusKerathurus.biomass  = param["q.sp1"]*osmose.biomass[, "MelicertusKerathurus"],
                  MetapenaeusMonoceros.biomass  = param["q.sp2"]*osmose.biomass[, "MetapenaeusMonoceros"],
                  TrachurusTrachurus.biomass    = param["q.sp3"]*osmose.biomass[, "TrachurusTrachurus"],
                  SardinaPilchardus.biomass     = param["q.sp4"]*osmose.biomass[, "SardinaPilchardus"],
                  SardinellaAurita.biomass      = param["q.sp5"]*osmose.biomass[, "SardinellaAurita"],
                  EngraulisEncrasicolus.biomass = param["q.sp6"]*osmose.biomass[, "EngraulisEncrasicolus"],
                  DiplodusAnnularis.biomass     = param["q.sp7"]*osmose.biomass[, "DiplodusAnnularis"],
                  MustelusMustelus.biomass      = param["q.sp8"]*osmose.biomass[, "MustelusMustelus"],
                  MerlucciusMerluccius.biomass  = param["q.sp9"]*osmose.biomass[, "MerlucciusMerluccius"],
                  PagellusErythrinus.biomass    = param["q.sp10"]*osmose.biomass[, "PagellusErythrinus"],
                  # Landings
                  OctopusVulgaris.landings       = osmose.yields[, "OctopusVulgaris"],
                  MelicertusKerathurus.landings  = osmose.yields[, "MelicertusKerathurus"],
                  MetapenaeusMonoceros.landings  = osmose.yields[, "MetapenaeusMonoceros"], 
                  TrachurusTrachurus.landings    = osmose.yields[, "TrachurusTrachurus"], 
                  SardinaPilchardus.landings     = osmose.yields[, "SardinaPilchardus"], 
                  SardinellaAurita.landings      = osmose.yields[, "SardinellaAurita"], 
                  EngraulisEncrasicolus.landings = osmose.yields[, "EngraulisEncrasicolus"], 
                  DiplodusAnnularis.landings     = osmose.yields[, "DiplodusAnnularis"], 
                  MustelusMustelus.landings      = osmose.yields[, "MustelusMustelus"], 
                  MerlucciusMerluccius.landings  = osmose.yields[, "MerlucciusMerluccius"], 
                  PagellusErythrinus.landings    = osmose.yields[, "PagellusErythrinus"], 
                  # Thresholds
                  OctopusVulgaris.thr           = osmose.thresholds[, "OctopusVulgaris"], 
                  MelicertusKerathurus.thr      = osmose.thresholds[, "MelicertusKerathurus"], 
                  MetapenaeusMonoceros.thr      = osmose.thresholds[, "MetapenaeusMonoceros"], 
                  TrachurusTrachurus.thr        = osmose.thresholds[, "TrachurusTrachurus"], 
                  SardinaPilchardus.thr         = osmose.thresholds[, "SardinaPilchardus"], 
                  SardinellaAurita.thr          = osmose.thresholds[, "SardinellaAurita"], 
                  EngraulisEncrasicolus.thr     = osmose.thresholds[, "EngraulisEncrasicolus"], 
                  DiplodusAnnularis.thr         = osmose.thresholds[, "DiplodusAnnularis"], 
                  MustelusMustelus.thr          = osmose.thresholds[, "MustelusMustelus"], 
                  MerlucciusMerluccius.thr      = osmose.thresholds[, "MerlucciusMerluccius"], 
                  PagellusErythrinus.thr        = osmose.thresholds[, "PagellusErythrinus"]
                  )

    return(output)

}
