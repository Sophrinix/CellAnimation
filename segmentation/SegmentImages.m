function SegmentImages(path, imageFileBase, fileExt, digitsForEnum, startIndex, endIndex)

clc
addpath('segment');
addpath('classify');

%create end of file name
imNum = startIndex;
imagefilename = makeImageFileName(imNum, digitsForEnum, path, imageFileBase, fileExt);

%load image
disp('Loading image for training set');
im = imread(imagefilename);

%NaiveSegment
disp('Segmenting image');
[s,l] = NaiveSegment(im);
save('output/trainingset.mat', 's', 'l');

%SegmentReview
disp('Manually classifying training set: trainingset.mat');
h = SegmentReview(1, imagefilename, 'output/trainingset.mat');
uiwait(h);


imNum = imNum + 1;
while(1)
  
    answer = input('Add to training set from other images (y/n)? ', 's');
    if(strcmp(answer, 'y'))

        disp('Adding desired objects to training set ');
        
        imagefilename = makeImageFileName(imNum, digitsForEnum, path, imageFileBase, fileExt);

        h = SegmentReview(1, imagefilename);
        uiwait(h);
        imNum = imNum + 1;

    else
      
        break;
    
    end

end

load('output/trainingset.mat', 's', 'l');
trainingset = s;

%train classifer
disp('Training classifier with training set: classifier');
classification_names = {'debris', 'nucleus', 'over', 'under', 'premitotic', 'postmitotic' 'apoptotic'};
for i=1:size(classification_names,2)

    classifier.(classification_names{1,i}) = CreateClassifier(classification_names{1,i},...
              trainingset, ...
              'Area',            'Eccentricity',  'MajorAxisLength', ...
              'MinorAxisLength', 'ConvexArea',    'FilledArea', ...
              'EquivDiameter',   'Solidity',      'Perimeter');
end
save('output/classifier.mat', 'classifier');

%validation
disp('Segmenting validation image');%create end of file name

imagefilename = makeImageFileName(imNum, digitsForEnum, path, imageFileBase, fileExt);

im = imread(imagefilename);
[s,l] = NaiveSegment(im);
testSet = s;

save('output/validationset.mat', 's', 'l');

disp('Manually classifying validation set: validationset.mat');

h = SegmentReview(1, imagefilename, 'output/validationset.mat');
uiwait(h);
load('output/validationset.mat', 's', 'l');
validationSet = s;

disp('Automatically classifying validated image for comparison');
classification_names = {'debris', 'nucleus', 'over', 'under', 'premitotic', 'postmitotic' 'apoptotic'};
for i=1:size(classification_names,2)

    testSet = NaiveClassify(classification_names{1,i}, testSet,...
                       classifier.(classification_names{1,i}));

end

disp('Determining accuracy of the classifier: stats');
validationStats = Validate(classifier, validationSet, testSet);
save('output/validationStats.mat', 'validationStats');

disp('Segmenting the rest of the image stack');

mkdir('output');
mkdir('output/resegmented');

SegmentImageStack('C:/Users/sam/work/walter_assay/movie2', ...
                  'DsRed - Confocal - n', ...
                  '.tif', ...
                  6, ...
                  imNum, ...
                  endIndex, ...
                  'C:/Users/sam/work/CellAnimation/segmentation/output');

ClassifyImageStack('C:/Users/sam/work/CellAnimation/segmentation/output', ...
                   'DsRed - Confocal - n', ...
                   6, ...
                   imNum, ...
                   endIndex, ...
                   'C:/Users/sam/work/CellAnimation/segmentation/output',...
                   classifier);

ResegmentImageStack('C:/Users/sam/work/walter_assay/movie2', ...
                    'C:/Users/sam/work/CellAnimation/segmentation/output', ...
                    'DsRed - Confocal - n', ...
                    '.tif', ...
                    6, ...
                    imNum, ...
                    endIndex, ...
                    'C:/Users/sam/work/CellAnimation/segmentation/output/resegmented');    

ClassifyImageStack('C:/Users/sam/work/CellAnimation/segmentation/output/resegmented', ...
                   'DsRed - Confocal - n', ...
                   6, ...
                   imNum, ...
                   endIndex, ...
                   'C:/Users/sam/work/CellAnimation/segmentation/output/resegmented',...
                   classifier);
                
rmpath('segment');
rmpath('classify');

disp('Finished');

end

function imageFileName = makeImageFileName(imNum, digitsForEnum, path, imageFileBase, fileExt)

    imNumStr = int2str(imNum);
    while(length(imNumStr) < digitsForEnum)
        imNumStr = ['0' imNumStr]; 
    end
    imageFileName = [path '\' imageFileBase imNumStr fileExt];

end