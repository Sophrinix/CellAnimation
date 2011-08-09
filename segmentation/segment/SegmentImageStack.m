function SegmentImageStack(directory, wellName, imageNameBase, fileExt, ...
						   digitsForEnum, startIndex, endIndex)
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

  addpath(pwd);
  cd(directory);
  cd(wellName);
  mkdir('output')
  cd('output')
  
  if(fileExt(1) ~= '.')
    fileExt = ['.' fileExt];
  end
     
  digitsForEnum

  for(imNum=startIndex:endIndex) 
    imNumStr = int2str(10^(digitsForEnum-1) + imNum);
    imNumStr(1) = '0'

    %load image
	[im, objSet.wellName, objSet.imageName] = ...
		LoadImage([directory filesep ...
				   wellName filesep ...
				   imageNameBase imNumStr fileExt]);

    %segment
    [objSet.props, objSet.labels] = NaiveSegment(im);

    save([imageNameBase imNumStr '.mat'], 'objSet');

    clear objSet;
	clear im;
    clear imNumStr;
  end

end
