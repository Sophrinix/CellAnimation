function [p,l] = NaiveSegment(image, varargin)

  % Defaults
  radius    = 50;
  threshold = 0.2;
  fillholes = 1;
  
  nargs = size(varargin,2);
  
  if ~ (2*floor(nargs/2) == nargs)
    error('Improper Call to NaiveSegment');
  end
  
  nargs = floor(size(varargin,2)/2);
  
  % Decode arguments
  for a=1:nargs
    switch varargin{2*a-1}
      case 'TopHatRadius'
        radius = varargin(2*a);
      case 'Threshold'
        threshold = varargin(2*a);
      case 'FillHoles'
        if ~strcmpi(varargin(2*a), 'true')
          fillholes = 0;
        end
      otherwise
        error('Improper Argument in Call to NaiveSegment');
    end
  end

  % Subtract background, in pixel radius (default 50) tophat filter
  i      = im2double(image);
  i      = imtophat(i, strel('disk', radius));
  
  % maps the intensity values such that 1% of data is saturated at low and high intensities 
  j      = imadjust(i);
  
  % To Binary Image (default 30% theshold)
  bw     = im2bw(j, threshold);
  
  % Fill Holes
  if fillholes
    bw     = imfill(bw, 'holes');
  end
  
  l = bwlabel(bw);
  
  % Segment properties (with holes filled)
  p = regionprops(l,...
                  'Area',            'Centroid',     'MajorAxisLength',...
                  'MinorAxisLength', 'Eccentricity', 'ConvexArea',     ...
                  'FilledArea',      'EulerNumber',  'EquivDiameter',  ...
                  'Solidity',        'Perimeter',    'PixelIdxList',   ...
                  'PixelList',       'BoundingBox');
  
  % Compute intensities from background adjusted image
  for obj=1:size(p,1)
    p(obj).Intensity =  sum(i(p(obj).PixelIdxList));
  end
  
  bounds = bwboundaries(bw);
  for obj=1:size(p,1)
    p(obj).bound = bounds{obj};
  end
  
  % Naive Classification
  for obj=1:size(p,1)
  
    p(obj).debris  = 0;
    p(obj).nucleus = 0;
    p(obj).over    = 0;
    p(obj).under   = 0;
    p(obj).newborn = 0;
    p(obj).left    = 0;
    p(obj).right   = 0;
    p(obj).top     = 0;
    p(obj).bottom  = 0;
    
    if p(obj).Area < 190
      p(obj).debris = 1;
    elseif p(obj).Area < 300
      p(obj).newborn = 1;
      p(obj).nucleus = 1;
    elseif p(obj).Area < 820
      p(obj).nucleus = 1;
    else
      p(obj).under = 1;
    end
    
    if find(p(obj).PixelList(:,1) == 1)
      p(obj).left = 1;
    end
    
    if find(p(obj).PixelList(:,2) == 1)
      p(obj).top = 1;
    end

    if find(p(obj).PixelList(:,1) == size(i,2) )
      p(obj).right = 1;
    end
    
    if find(p(obj).PixelList(:,2) == size(i,1) )
      p(obj).bottom = 1;
    end
    
  end
  
end % NaiveSegment