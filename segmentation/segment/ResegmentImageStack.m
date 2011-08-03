function ResegmentImageStack(directory, wellName, imageNameBase, fileExt, ...
							 digitsForEnum, startIndex, endIndex)
%
%Resegments all undersegmented objects in all images in the given object
%set
%
%INPUTS:
%
%
%OUTPUTS:
%
  for(imNum = startIndex:endIndex)
    imNumStr = int2str(10^(digitsForEnum-1) + imNum);
    imNumStr(1) = '0';
        
    %load objSet for image
    load([directory filesep wellName filesep 'output' filesep ...
		  imageNameBase imNumStr '.mat']);
	
	%load associated raw image    
	im = imread([directory filesep wellName filesep ...
				 imageNameBase imNumStr fileExt]);

    %find under-segmented objects
    underSegObjs = find([objSet.props(:).under])
    [objSet.props,objSet.labels] = ... 
		Resegment(im, objSet.props, objSet.labels, underSegObjs);
        
    %save props and labels to objSet
	save([directory filesep wellName filesep 'output' filesep ...
		  imageNameBase imNumStr '.mat'], 'objSet');
    clear im;
    clear imNumStr;
    clear underSegObjs;
  end
      
end
