function [image, wellName, imageName] = LoadImage(imageFileName)

	tempFileName = imageFileName;
	image = imread(imageFileName);
	
	%remove trailing filesep character
	if(tempFileName(size(tempFileName,2)) == filesep)
		tempFileName = tempFileName(1:size(tempFileName,2)-1);
	end

	%isolate image name
	filesepIdx = find(tempFileName == filesep);
	imageName = tempFileName(filesepIdx(size(filesepIdx,2))  + 1: ...
							 size(tempFileName,2));

	%isolate well name
	wellName = tempFileName(filesepIdx(size(filesepIdx,2)-1) + 1: ...
							filesepIdx(size(filesepIdx,2))   - 1);

end
