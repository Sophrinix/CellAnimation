function [s,l] = Resegment(im, properties, labels, objids)
  
%
%segments undersegmented objects into smaller objects
%
%INPUTS:
%im          -  the original image                  
%
%properties  -  the properties of the objects in the image
%
%labels      -  the matrix of labeled objects
%
%objids      -  a list of object ids (indexes in the properties struct) 
%				to be resegmented
%OUTPUTS:
%s           -  properties of all objects in the image after 
%				resegmentation, maintains prior classification of 
%				pre-existing objects
%
%l           -  label matrix of the image after resegmentation
%

  l = labels;
  s = properties;

  blankSlate = zeros(size(im));
    
  for(n=1:size(objids,2))
        
    %box region containing the object(s) to  be resegmented
    box = s(objids(n)).BoundingBox;
    %allocate space for smaller image of objects in question
    subImage = zeros(box(4), box(3));
        
    %copy relevant section of the image to smaller image
    m=1;
    k=1;
    for(i=1:(box(4)))
      for(j=1:(box(3)))
        subImage(k,m) = l(i+floor(box(2)),j+floor(box(1)));
        m = m + 1;
      end
      k = k + 1;
      m=1;
    end
        
    %perform distance transform
    distTransform = -bwdist(~subImage, 'cityblock');
    %calculate a watershed
    waterShed = watershed(distTransform);
    %use watershed to seperate objects
    bw = subImage & waterShed;

    %remove noise
    noise = imtophat(bw, strel('disk', 3));
    bw = bw - noise;
        
    %allocate an empty image the size of the original
    %this is used to find the properties of the new objects while
    %maintaining the correct position (centroid) in the old image
    %without affecting the properties of pre-existing objects
    m=1;
    k=1;
    for(i=1:(box(4)))
      for(j=1:(box(3)))
        l(i+floor(box(2)),j+floor(box(1))) = bw(k,m);
        blankSlate(i+floor(box(2)),j+floor(box(1))) = bw(k,m);
        m = m + 1;
      end
      k = k + 1;
      m=1;
    end    
        
  end        
    
  s(objids) = [];

  sNew = regionprops(logical(blankSlate), ...
                     'Area',            'Centroid',     'MajorAxisLength',...
                     'MinorAxisLength', 'Eccentricity', 'ConvexArea',     ...
                     'FilledArea',      'EulerNumber',  'EquivDiameter',  ...
                     'Solidity',        'Perimeter',    'PixelIdxList',   ...
                     'PixelList',       'BoundingBox');               

  % Compute intensities from background adjusted image, determine
  % edge condition (yes/no)
  bounds = bwboundaries(blankSlate);
  i = imtophat(im2double(im), strel('disk', 50));

  for(obj=1:size(sNew,1))

    sNew(obj).Intensity =  sum(i(sNew(obj).PixelIdxList));

    sNew(obj).bound = bounds{obj};

    sNew(obj).edge    = 0;
    if(find(sNew(obj).PixelList(:,1) == 1))
      sNew(obj).edge = 1;
    end
    if find(sNew(obj).PixelList(:,2) == 1)
      sNew(obj).edge = 1;
    end
    if find(sNew(obj).PixelList(:,1) == size(i,2) )
      sNew(obj).edge = 1;
    end
    if find(sNew(obj).PixelList(:,2) == size(i,1) )
      sNew(obj).edge = 1;
    end                 
  end

  sNew = ClassifyFirstPass(sNew);
    
  for(i=1:size(sNew,1))
    s(size(s,1)+1) = sNew(i); 
  end
    
  %relabel    
  l = bwlabel(l);    
  edges = [s(:).BoundingBox];
  [unused, order] = sort(edges(1:4:size(edges,2)));
  s = s(order);    
	
  for(obj = 1:size(s,1))
	s(obj).label = label;
  end	
    
end
