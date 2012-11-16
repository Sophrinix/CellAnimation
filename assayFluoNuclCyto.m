function []=assayFluoNuclCyto()

global functions_list;
functions_list=[];
%script variables
ImageFolder='~/qlabtransfer/Stephen_Hummel/Chengwei Test/';
NucleiImage=[ImageFolder 'nuclei.jpg'];
CytoImage=[ImageFolder 'S6.jpg'];
OutputFolder=ImageFolder;
CellOutlines=[ImageFolder 'outlines.jpg'];
CellIntensities=[OutputFolder 'intensity_data.mat'];
%end script variables

% base_name_1 = '20120322191339-';
% base_name_2 = '-R02-C07.jpg';
% number = 1488;
% x = 0;
% while x<1 
%     cnumber = number + x*3;
%     cNucleiImage = [NucleiImage base_name_1 num2str(cnumber) base_name_2];
%     cCytoImage = [NucleiImage base_name_1 num2str(cnumber+1) base_name_2];
%     cCellOutlines = [CellOutlines num2str(x) '.jpg'];
%     cCellIntensities = [CellIntensities num2str(x) '.mat'];
    
    readnuclei.InstanceName='ReadNuclei';
    readnuclei.FunctionHandle=@readImage;
    readnuclei.FunctionArgs.ImageChannel.Value='r';
    readnuclei.FunctionArgs.ImageName.Value=NucleiImage;
    functions_list=addToFunctionChain(functions_list,readnuclei);

    readcyto.InstanceName='ReadCyto';
    readcyto.FunctionHandle=@readImage;
    readcyto.FunctionArgs.ImageChannel.Value='r';
    readcyto.FunctionArgs.ImageName.Value=CytoImage;
    functions_list=addToFunctionChain(functions_list,readcyto);

    normalizenuclearimage.InstanceName='NormalizeNuclearImage';
    normalizenuclearimage.FunctionHandle=@imNorm;
    normalizenuclearimage.FunctionArgs.IntegerClass.Value='uint8'; 
    normalizenuclearimage.FunctionArgs.RawImage.FunctionInstance='ReadNuclei';
    normalizenuclearimage.FunctionArgs.RawImage.OutputArg='Image';
    functions_list=addToFunctionChain(functions_list,normalizenuclearimage);

    normalizecytoimage.InstanceName='NormalizeCytoImage';
    normalizecytoimage.FunctionHandle=@imNorm;
    normalizecytoimage.FunctionArgs.IntegerClass.Value='uint8';
    normalizecytoimage.FunctionArgs.RawImage.FunctionInstance='ReadCyto';
    normalizecytoimage.FunctionArgs.RawImage.OutputArg='Image';
    functions_list=addToFunctionChain(functions_list,normalizecytoimage);

    thresholdnuclei.InstanceName='ThresholdNuclei';
    thresholdnuclei.FunctionHandle=@generateBinImgUsingLocAvg;
    thresholdnuclei.FunctionArgs.ClearBorder.Value=true;
    thresholdnuclei.FunctionArgs.ClearBorderDist.Value=0;
    thresholdnuclei.FunctionArgs.Strel.Value='disk';
    thresholdnuclei.FunctionArgs.StrelSize.Value=15;
    thresholdnuclei.FunctionArgs.BrightnessThresholdPct.Value=1.15;
    thresholdnuclei.FunctionArgs.Image.FunctionInstance='ReadNuclei';
    thresholdnuclei.FunctionArgs.Image.OutputArg='Image';
    functions_list=addToFunctionChain(functions_list,thresholdnuclei);

    intensityfilter.InstanceName='IntensityFilter';
    intensityfilter.FunctionHandle=@generateBinImgUsingGlobInt;
    intensityfilter.FunctionArgs.ClearBorder.Value=false;
    intensityfilter.FunctionArgs.ClearBorderDist.Value=0;
    intensityfilter.FunctionArgs.IntensityThresholdPct.Value=0.10;
    intensityfilter.FunctionArgs.Image.FunctionInstance='NormalizeCytoImage';
    intensityfilter.FunctionArgs.Image.OutputArg='Image';
    functions_list=addToFunctionChain(functions_list,intensityfilter);

    clearnoisepixels.InstanceName='ClearNoisePixels';
    clearnoisepixels.FunctionHandle=@clearSmallObjects;
    clearnoisepixels.FunctionArgs.MinObjectArea.Value=60;
    clearnoisepixels.FunctionArgs.Image.FunctionInstance='ThresholdNuclei';
    clearnoisepixels.FunctionArgs.Image.OutputArg='Image';
    functions_list=addToFunctionChain(functions_list,clearnoisepixels);

    clearnoisepixelscyto.InstanceName='ClearNoisePixelsCyto';
    clearnoisepixelscyto.FunctionHandle=@clearSmallObjects;
    clearnoisepixelscyto.FunctionArgs.MinObjectArea.Value=60;
    clearnoisepixelscyto.FunctionArgs.Image.FunctionInstance='IntensityFilter';
    clearnoisepixelscyto.FunctionArgs.Image.OutputArg='Image';
    functions_list=addToFunctionChain(functions_list,clearnoisepixelscyto);

    fillnucleiholes.InstanceName='FillNucleiHoles';
    fillnucleiholes.FunctionHandle=@fillHoles;
    fillnucleiholes.FunctionArgs.Image.FunctionInstance='ClearNoisePixels';
    fillnucleiholes.FunctionArgs.Image.OutputArg='Image';
    functions_list=addToFunctionChain(functions_list,fillnucleiholes);

    labelnuclei.InstanceName='LabelNuclei';
    labelnuclei.FunctionHandle=@labelObjects;
    labelnuclei.FunctionArgs.Image.FunctionInstance='FillNucleiHoles';
    labelnuclei.FunctionArgs.Image.OutputArg='Image';
    functions_list=addToFunctionChain(functions_list,labelnuclei);

    segmentcyto.InstanceName='SegmentCyto';
    segmentcyto.FunctionHandle=@segmentCytoUsingNuclei;
    segmentcyto.FunctionArgs.CytoImage.FunctionInstance='ClearNoisePixelsCyto';
    segmentcyto.FunctionArgs.CytoImage.OutputArg='Image';
    segmentcyto.FunctionArgs.NuclearLabel.FunctionInstance='LabelNuclei';
    segmentcyto.FunctionArgs.NuclearLabel.OutputArg='LabelMatrix';
    functions_list=addToFunctionChain(functions_list,segmentcyto);

    getcytointensities.InstanceName='GetCytoIntensities';
    getcytointensities.FunctionHandle=@getObjectIntensities;
    getcytointensities.FunctionArgs.IntensityImage.FunctionInstance='ReadCyto';
    getcytointensities.FunctionArgs.IntensityImage.OutputArg='Image';
    getcytointensities.FunctionArgs.LabelMatrix.FunctionInstance='SegmentCyto';
    getcytointensities.FunctionArgs.LabelMatrix.OutputArg='LabelMatrix';
    functions_list=addToFunctionChain(functions_list,getcytointensities);

    savecelloutlines.InstanceName='SaveCellOutlines';
    savecelloutlines.FunctionHandle=@displayObjectOutlines;
    savecelloutlines.FunctionArgs.FileName.Value=CellOutlines;
    savecelloutlines.FunctionArgs.ShowIDs.Value=true;
    savecelloutlines.FunctionArgs.Image.FunctionInstance='NormalizeCytoImage';
    savecelloutlines.FunctionArgs.Image.OutputArg='Image';
    savecelloutlines.FunctionArgs.ObjectsLabel.FunctionInstance='SegmentCyto';
    savecelloutlines.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
    functions_list=addToFunctionChain(functions_list,savecelloutlines);

    saveintensities.InstanceName='SaveIntensities';
    saveintensities.FunctionHandle=@saveWrapper;
    saveintensities.FunctionArgs.FileName.Value=CellIntensities;
    saveintensities.FunctionArgs.SaveData.FunctionInstance='GetCytoIntensities';
    saveintensities.FunctionArgs.SaveData.OutputArg='MeanIntensities';
    functions_list=addToFunctionChain(functions_list,saveintensities);

    shownuclei.InstanceName='ShowNuclei';
    shownuclei.FunctionHandle=@displayImage;
    shownuclei.FunctionArgs.FigureNr.Value=1;
    shownuclei.FunctionArgs.Image.FunctionInstance='FillNucleiHoles';
    shownuclei.FunctionArgs.Image.OutputArg='Image';
    functions_list=addToFunctionChain(functions_list,shownuclei);

    showoriginal.InstanceName='ShowOriginal';
    showoriginal.FunctionHandle=@displayImage;
    showoriginal.FunctionArgs.FigureNr.Value=2;
    showoriginal.FunctionArgs.Image.FunctionInstance='NormalizeCytoImage';
    showoriginal.FunctionArgs.Image.OutputArg='Image';
    functions_list=addToFunctionChain(functions_list,showoriginal);

    showcyto.InstanceName='ShowCyto';
    showcyto.FunctionHandle=@displayImage;
    showcyto.FunctionArgs.FigureNr.Value=3;
    showcyto.FunctionArgs.Image.FunctionInstance='IntensityFilter';
    showcyto.FunctionArgs.Image.OutputArg='Image';
    functions_list=addToFunctionChain(functions_list,showcyto);

    showlabel.InstanceName='ShowLabel';
    showlabel.FunctionHandle=@showLabelMatrix;
    showlabel.FunctionArgs.FigureNr.Value=4;
    showlabel.FunctionArgs.LabelMatrix.FunctionInstance='SegmentCyto';
    showlabel.FunctionArgs.LabelMatrix.OutputArg='LabelMatrix';
    functions_list=addToFunctionChain(functions_list,showlabel);


    global dependencies_list;
    global dependencies_index;
    dependencies_list={};
    dependencies_index=java.util.Hashtable;
    makeDependencies([]);
    runFunctions();
%    x = x+1;
% end

end