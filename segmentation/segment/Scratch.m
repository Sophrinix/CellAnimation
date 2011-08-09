img = imread('../Well C04/DsRed - Confocal - n000001.tif');
p = NaiveSegment(img);

p = segment(imread('Well C04/DsRed - Confocal - n000001.tif'));


i=imread('Well C04/DsRed - Confocal - n000001.tif');
[x,y]=size(i);

i=im2double(i);

imagesc(i);
axis('image');

% Subtract background, 50 pixel tophat filter
j = imtophat(i, strel('disk', 50));
imagesc(j);
axis('image');


% maps the intensity values such that 1% of data is saturated at low and high intensities 
k = imadjust(j);
imagesc(k);
axis('image');

% To Binary
bw= im2bw(k, 0.3);
imshow(bw);

% Boundaries
bw_filled = imfill(bw, 'holes');
imshow(bw_filled);
bounds = bwboundaries(bw_filled);

% Segment properties
p = regionprops(bw_filled,'Area','Centroid','MajorAxisLength','MinorAxisLength','Eccentricity','ConvexArea','FilledArea','EulerNumber','EquivDiameter','Solidity','Perimeter','PixelIdxList','PixelList');



% Show some colors for the boundaries
%colors=pmkmp(10, 'IsoL'); % http://www.mathworks.com/matlabcentral/fileexchange/28982
%hold on;
%for b=1:size(bounds)
%   plot(bounds{b}(:,2), bounds{b}(:,1), 'Color', colors(mod(b, size(colors,1))+1, :), 'LineWidth',2);
%end

% Pull intensity from original raw

for segment=1:size(p,1)
  p(segment).Intensity =  sum(j(p(segment).PixelIdxList));
end

hist(arrayfun(@(x) x.Intensity, p))

% This looks almost normal (log doesnt)
hist(arrayfun(@(x) sqrt(x.Intensity), p))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%s
% Write spread sheet


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


%%%%%%%%%%%%%%%%%%%%%%%%
%
file = '/Volumes/Public/BD Pathway Data/Darren/Time Lapse/2009-10-07_000/Well D09/DsRed - Confocal - n000100.tif';
image = imread(file);
[s, l] = NaiveSegment(image);
croppedImage = imcrop(image, s(12).BoundingBox);

