function makeHelpFile(filename)

  fid = fopen(filename, 'w');
  assayNames =         	   {'assayBrightFieldCytoTestNN',
							'assayBrightFieldCytoTestWG',
							'assayCellCoverage',
							'assayCellPropsSingleImage',
							'assayFlCytoLNCapManSegWG',
							'assayFlCytoLNCapTracksReviewWG',
							'assayFlCytoLNCapTrackWG',
							'assayFluoNuclLNCap',
							'assayFluoNuclTestCADir',
							'assayFluoNuclThresholding',
							'assayGetStageOffset',
							'assayOffsetFrames'};

  controlModuleNames =     {'forLoop',
							'if_statement',
							'whileLoop'};

  internalModuleNames =    {'addFunction',
							'areaFilterLabel',
							'areaOverPerimeterFilterLabel',
							'assignCellToTrackUsingAll',
							'assignCellToTrackUsingNN',
							'clearSmallObjects',
							'combineImages',
							'compareValues',
							'concatenateText',
							'cropImageWithOffset',
							'detectMergeCandidatesUsingDistance',
							'detectMitoticEvents',
							'displayAncestryData',
							'displayTracksData',
							'displayVariable',
							'distanceWatershed',
							'eccentricityFilterLabel',
							'generateBinImgUsingGlobInt',
							'generateBinImgUsingGradient',
							'generateBinImgUsingLocAvg',
							'getArrayVal',
							'getConvexObjects',
							'getCurrentTracks',
							'getFileInfo',
							'getMaxTrackID',
							'getObjectsMeanDisplacement',
							'getShapeParams',
							'getShapeParamsWithDisconnects',
							'getTrackIDs',
							'imNorm',
							'loadCellsLabel',
							'loadMatFile',
							'makeAncestryForCellsEnteringFrames',
							'makeAncestryForFirstFrameCells',
							'makeExcludedTracksList',
							'makeImgFileName',
							'makeUnassignedCellsList',
							'manualSegmentationReview',
							'manualTrackingReview',
							'mergeTracks',
							'negativeImage',
							'overlayAncestry',
							'percentageForeground',
							'polygonalAssistedWatershed',
							'refineSegmentation',
							'removeShortTracks',
							'saveAncestry',
							'saveAncestrySpreadsheets',
							'saveCellsLabel',
							'saveRegionPropsSpreadsheets',
							'saveTracks',
							'segmentObjectsUsingClusters',
							'segmentObjectsUsingMarkers',
							'setArrayVar',
							'showImageAndPause',
							'showLabelMatrixAndPause',
							'solidityFilter',
							'solidityFilterLabel',
							'startTracks'};

  fprintf(fid, 'Cell Animation\n');

  fprintf(fid, 'Introduction\n');
  fprintf(fid, 'CellAnimation is a framework for microscopy assays. To allow for fast assay creation and code reuse each assay is implemented as a modular pipeline. A CellAnimation assay is a chain of MATLAB structures. Each structure describes a module and its connectivity. We have provided a series of assays that we have developed for various microscopy tasks for our lab and others. The intended purpose for each of the assays is described in the “Assays” section. \n The CellAnimation core functions are responsible for reading the module chain, creating a dependency tree, populating the input values, executing each module and saving those output values required by modules further downstream (Supp. Fig. 1A). A module is a reusable set of functions that has a narrow specific use (image input-output, thresholding, segmentation, annotation, etc.). Each module we provide is documented in the “Internal Modules” section. In addition we have also included a set of control modules. These are special modules that operate on other modules. Through the use of control modules we can implement looping and branching at the pipeline level. The benefits to this approach are twofold. First, the assay logic becomes easier to follow and modify. Second, it allows us to use smaller, more reusable modules. Individual control modules are documented in the “Control Modules” section. \n In addition to our modules, a pipeline may include modules that are just simple wrappers for MATLAB functions or modules that encapsulate functions developed by others. For the MATLAB wrapper modules the documentation may be found in the in the MATLAB help file for that particular function. The caveat is that a particular wrapper may only provide access to some of the functionality of the MATLAB function. In general, MATLAB wrapper modules are named using the name of the MATLAB function concatenated with the string “Wrapper”, however there are some older wrapper modules that only use the name of the MATLAB function. For other external modules the documentation is provided by the original developers.\n');

  fprintf(fid, '\nAssays\n');
  for(i=1:size(assayNames,1))
    fprintf(fid, '%s\n', assayNames{i,1});
    fprintf(fid, '%s\n', help([assayNames{i,1} '.m']));
  end

  fprintf(fid, '\nControl Modules\n');
  for(i=1:size(controlModuleNames,1))
    fprintf(fid, '%s\n', controlModuleNames{i,1});
    fprintf(fid, '%s\n', help([controlModuleNames{i,1} '.m']));
  end

  fprintf(fid, '\nInernal Modules\n');
  for(i=1:size(internalModuleNames,1))
    fprintf(fid, '%s\n', internalModuleNames{i,1});
    fprintf(fid, '%s\n', help([internalModuleNames{i,1} '.m']));
  end	

  fclose(fid);

end
