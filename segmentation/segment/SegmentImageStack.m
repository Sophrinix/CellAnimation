function objSet = SegmentImageStack(startIndex, endIndex, directory, ...
									wellName, imageNameBase, fileExt, ...
									digitsForEnum)
%
%Does naive segmentation an entire image stack, adding results to a new
%object set
%
%INPUTS:
%
%
%OUTPUTS:
%
%
  
  if(fileExt(1) ~= '.')
    fileExt = ['.' fileExt];
  end
  
  objSet = [];
 
  for(imNum=startIndex:endIndex) 
    %create end of file name
    imNumStr = int2str(imNum);
    while(length(imNumStr) < digitsForEnum)
      imNumStr = ['0' imNumStr]; 
    end

    %load image
	[im, wellName, imageName] = LoadImage([directory filesep ...
										   wellName filesep ...
										   imageNameBase imNumStr fileExt]);
	index = size(objSet,2) + 1;
	objSet(index).wellName = wellName;
	objSet(index).imageName = imageName;

    %segment
    [objSet(index).props, objSet(index).labels] = NaiveSegment(im);
  end

end
