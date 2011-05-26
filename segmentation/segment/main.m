
%cd ~/Segmentation;


%image to be segmented
image = imread('DsRed - Confocal - n000000.tif');
	
%segmentation function
properties = NaiveSegment(image);

%save properties to disk
save('properties.mat', 'properties');

%names = fieldnames(properties(1,1))

%for i=1:size(properties)
  %temp = properties(1,1)
  %names = fieldnames(properties);
  %for j=1:size(names)
  %  name = names{j}
  %  getfield(temp, name)
  %end 
%end
	
%save segmentation output to a csv file
WriteSegmentationToCSV(properties, 'segmentationProps.csv');
	
%save regionprops as matlab object
	

%run GUI for checking and editing the segmentation
