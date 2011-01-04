To use the software load one of the assay files in Matlab.
To run an assay that works on an image series at the Matlab prompt enter assayName('absolute_path_to_image_directory).
To run an assay that works on a single image at the Matlab prompt enter assayName('absolute_image_file_name').
Assay parameters such as root name of the image series or cell size or segmentation threshold may need to be adjusted to make the assay work for different cell types, stains or microscopes.
We have provided a couple of ready-to-run test assays along with an image series.
assayFluoNuclTestCA tracks and records ancestry for cells stained using a nuclear stain using our custom tracking algorithm.
assayFluoNuclTestNN is the same assay except the tracking module has been replaced with a nearest-neighbor tracking module.
assayFluoNuclTestCADir is the same as the first assay except optimized for direction instead of distance. This assay is used when tracking the undersampled movie where distance is no longer the best predictor.
