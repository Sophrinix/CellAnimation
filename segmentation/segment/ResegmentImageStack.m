function objSet = ResegmentImageStack(prevObjSet, directory)
%
%Resegments all undersegmented objects in all images in the given object
%set
%
%INPUTS:
%
%
%OUTPUTS:
%
  objSet = prevObjSet;
  for(imIdx = 1:size(objSet,2))
    wellName = objSet(imIdx).wellName;
    imageName = objSet(imIdx).imageName;
        
    %load image
    im = imread([directory filesep wellName filesep imageName]);
        
    %get the correct object list
    props = objSet(imIdx).props;
    labels = objSet(imIdx).labels;

    %find under-segmented objects
    underSegObjs = find([props(:).under])
    [props,labels] = Resegment(im, props, labels, underSegObjs);
        
    %save props and labels to objSet
    objSet(imIdx).props = props;
    objSet(imIdx).labels = labels;
  end
      
end
