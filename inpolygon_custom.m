function [in, on] = inpolygon(x,y,xv,yv)
%INPOLYGON True for points inside or on a polygonal region.
%   IN = INPOLYGON(X,Y,XV,YV) returns a matrix IN the size of X and Y.
%   IN(p,q) = 1 if the point (X(p,q), Y(p,q)) is either strictly inside or
%   on the edge of the polygonal region whose vertices are specified by the
%   vectors XV and YV; otherwise IN(p,q) = 0.
%
%   [IN ON] = INPOLYGON(X,Y,XV,YV) returns a second matrix, ON, which is 
%   the size of X and Y.  ON(p,q) = 1 if the point (X(p,q), Y(p,q)) is on 
%   the edge of the polygonal region; otherwise ON(p,q) = 0.
%
%   INPOLYGON supports non-convex and self-intersecting polygons.
%   The function also supports multiply-connected or disjoint polygons; 
%   however, the distinct edge loops should be separated by NaNs. In the
%   case of multiply-connected polygons, the external and internal loops
%   should have opposite orientations; for example, a counterclockwise 
%   outer loop and clockwise inner loops or vice versa.
%
%   Example 1:
%       % Self-intersecting polygon
%       xv = rand(6,1); yv = rand(6,1);
%       xv = [xv ; xv(1)]; yv = [yv ; yv(1)];
%       x = rand(1000,1); y = rand(1000,1);
%       in = inpolygon(x,y,xv,yv);
%       plot(xv,yv,x(in),y(in),'.r',x(~in),y(~in),'.b')
%
%   Example 2:
%       % Multiply-connected polygon - a square with a square hole.
%       % Counterclockwise outer loop, clockwise inner loop.
%       xv = [0 3 3 0 0 NaN 1 1 2 2 1];
%       yv = [0 0 3 3 0 NaN 1 2 2 1 1];
%       x = rand(1000,1)*3; y = rand(1000,1)*3;
%       in = inpolygon(x,y,xv,yv);
%       plot(xv,yv,x(in),y(in),'.r',x(~in),y(~in),'.b')
%
%   Class support for inputs X,Y,XV,YV:
%      float: double, single

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.14.4.4 $  $Date: 2007/12/10 21:40:10 $

% The algorithm is similar to that described in the following reference.
%
% @article{514556,
% author = {Kai Hormann and Alexander Agathos},
% title = {The point in polygon problem for arbitrary polygons},
% journal = {Comput. Geom. Theory Appl.},
% volume = {20},
% number = {3},
% year = {2001},
% issn = {0925-7721},
% pages = {131--144},
% doi = {http://dx.doi.org/10.1016/S0925-7721(01)00012-8},
% publisher = {Elsevier Science Publishers B. V.},
% address = {Amsterdam, The Netherlands, The Netherlands},
% }

% If (xv,yv) is a simply connected open polygon, close it.
% For multiply connected or disjoint polygons, distinct edge loops should 
% be separated by NaNs. The algorithm assumes each such loop is closed.
xv = xv(:);
yv = yv(:);
Nv = length(xv);
if ~any(isnan(xv) | isnan(yv))
    if ((xv(1) ~= xv(Nv)) || (yv(1) ~= yv(Nv)))
        xv = [xv ; xv(1)];
        yv = [yv ; yv(1)];
        Nv = Nv + 1;
    end
end

inputSize = size(x);

x = x(:).';
y = y(:).';

mask = (x >= min(xv)) & (x <= max(xv)) & (y>=min(yv)) & (y<=max(yv));
if ~any(mask)
    in = false(inputSize);
    on = in;
    return
end
inbounds = find(mask);
x = x(mask);
y = y(mask);


% Choose block_length to keep memory usage of vec_inpolygon around
% 10 Megabytes.
block_length = 1e5;

M = numel(x);

if M*Nv < block_length
    if nargout > 1
        [in on] = vec_inpolygon(Nv,x,y,xv,yv);
    else
        in = vec_inpolygon(Nv,x,y,xv,yv);
    end
else
    % Process at most N elements at a time
    N = ceil(block_length/Nv);
    in = false(1,M);
    if nargout > 1
        on = false(1,M);
    end
    n1 = 0;  n2 = 0;
    while n2 < M,
        n1 = n2+1;
        n2 = n1+N;
        if n2 > M,
            n2 = M;
        end
        if nargout > 1
            [in(n1:n2) on(n1:n2)] = vec_inpolygon(Nv,x(n1:n2),y(n1:n2),xv,yv);
        else
            in(n1:n2) = vec_inpolygon(Nv,x(n1:n2),y(n1:n2),xv,yv);
        end
    end
end

if nargout > 1
    onmask = mask;
    onmask(inbounds(~on)) = 0;
    on = reshape(onmask, inputSize);
end

mask(inbounds(~in)) = 0;
% Reshape output matrix.
in = reshape(mask, inputSize);


%----------------------------------------------
function [in, on] = vec_inpolygon(Nv,x,y,xv,yv)
% vectorize the computation.

% Translate the vertices so that the test points are
% at the origin.

Np = length(x);
x = x(ones(Nv,1),:);
y = y(ones(Nv,1),:);
xv = xv(:,ones(1,Np)) - x;
yv = yv(:,ones(1,Np)) - y;

% Compute the quadrant number for the vertices relative
% to the test points.
posX = xv > 0;
posY = yv > 0;
negX = ~posX;
negY = ~posY;
quad = (negX & posY) + 2*(negX & negY) + ...
    3*(posX & negY);
% Ignore crossings between distinct edge loops that are separated by NaNs
nanidx = find(isnan(xv) | isnan(yv));
quad(nanidx) = NaN;
% Compute the sign() of the cross product and dot product
% of adjacent vertices.
m = 1:Nv-1;
mp1 = 2:Nv;
theCrossProd = xv(m,:) .* yv(mp1,:) - xv(mp1,:) .* yv(m,:);
signCrossProduct = sign(theCrossProd);
% Adjust values that are within eps of the polygon boundary.
% Making eps larger will treat points close to the boundary as being "on"
% the boundary.
%wg eps doesn't catch a lot of the values so increasing it
idx = (abs(theCrossProd) < 1e4*eps);
signCrossProduct(idx) = 0;
dotProduct = xv(m,:) .* xv(mp1,:) + yv(m,:) .* yv(mp1,:);

% Compute the vertex quadrant changes for each test point.
diffQuad = diff(quad);

% Fix up the quadrant differences.  Replace 3 by -1 and -3 by 1.
% Any quadrant difference with an absolute value of 2 should have
% the same sign as the cross product.
idx = (abs(diffQuad) == 3);
diffQuad(idx) = -diffQuad(idx)/3;
idx = (abs(diffQuad) == 2);
diffQuad(idx) = 2*signCrossProduct(idx);

% Find the inside points.
% Ignore crossings between distinct loops that are separated by NaNs
nanidx = find(isnan(diffQuad));
diffQuad(nanidx) = 0;
in = (sum(diffQuad) ~= 0);

% Find the points on the polygon.  If the cross product is 0 and
% the dot product is nonpositive anywhere, then the corresponding
% point must be on the contour.
on = any((signCrossProduct == 0) & (dotProduct <= 0));

in = in | on;
