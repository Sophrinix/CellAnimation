function [p,l] = NaiveSegment(image, varargin)

  % Defaults
  radius              = 50;  % Filter out background bigger than 50 pixel areas
  backgroundThreshold = 0.2; % 20% below normalized is off, 80% is real.
  fillholes           = 1;   % Please fill holes
  noiseThreshold      = 3;   % 3 pixel circles 
  
  nargs = size(varargin,2);
  
  if ~ (2*floor(nargs/2) == nargs)
    error('Improper Call to NaiveSegment');
  end
  
  nargs = floor(size(varargin,2)/2);
  
  % Decode arguments
  for a=1:nargs
    switch varargin{2*a-1}
      case 'TopHatRadius'
        v=varargin(2*a);
        radius = v{1};
      case 'NoiseThreshold'
        v=varargin(2*a);
        noiseThreshold = v{1};
      case 'BackgroundThreshold'
        v=varargin(2*a);
        backgroundThreshold=v{1};
      case 'FillHoles'
        if ~strcmpi(varargin(2*a), 'true')
          fillholes = 0;
        end
      otherwise
        error('Improper Argument in Call to NaiveSegment');
    end
  end

  % Subtract background, in pixel radius (default 50) tophat filter
  i      = imtophat(im2double(image), strel('disk', radius));
  
  
  % maps the intensity values such that 1% of data is saturated at low and high intensities 
  j      = imadjust(i);
  
  % To Binary Image (default 30% theshold)
  bw     = im2bw(j, backgroundThreshold);

  % Remove Noise
  if noiseThreshold > 0.0
    noise = imtophat(bw, strel('disk', noiseThreshold));
    bw = bw - noise;
  end
  
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
  bounds = bwboundaries(bw);
  for obj=1:size(p,1)

	p(obj).label = obj;    

	p(obj).Intensity =  sum(i(p(obj).PixelIdxList));
    
    p(obj).bound = bounds{obj};
    
    p(obj).edge    = 0;
    if find(p(obj).PixelList(:,1) == 1)
      p(obj).edge = 1;
    end

    if find(p(obj).PixelList(:,2) == 1)
      p(obj).edge = 1;
    end

    if find(p(obj).PixelList(:,1) == size(i,2) )
      p(obj).edge = 1;
    end

    if find(p(obj).PixelList(:,2) == size(i,1) )
      p(obj).edge = 1;
    end
    
  end
  
  p = ClassifyFirstPass(p);
  
end % NaiveSegment
