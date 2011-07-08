function mergedObj = MergeObjects(obj1, obj2, labels)
%merge two objects (e.g. potential mitosis candidates)

    centroid1 = obj1.Centroid;
    centroid2 = obj2.Centroid;
    minDist = DistanceBetweenPoints(centroid1, centroid2);
    pt1 = [0,0];
    pt2 = [0,0];
        
    for(i=1:size(obj1.bound))
        for(j=1:size(obj2.bound))
            dist = DistanceBetweenPoints(obj1.bound(i,:), obj2.bound(j,:));
            if(dist<minDist)
                minDist = dist;
                pt1 = obj1.bound(i,:);
                pt2 = obj2.bound(j,:);
            end
        end
    end
    
    if(pt1(1) > pt2(1))
        xStart = pt2(1);
        xEnd = pt1(1);
    else
        xStart = pt1(1);
        xEnd = pt2(1);
    end
    
    if(pt1(2) > pt2(2))
        yStart = pt2(2);
        yEnd = pt1(2);
    else
        yStart = pt2(2);
        yEnd = pt1(2);
    end
    
    x = xStart + 1;
    y = yStart + 1;
    while((x < xEnd) || (y < yEnd))
        
        labels(x,y) = 1;
        
        if(x < xEnd)
            x = x + 1;
        end
        
        if(y < yEnd)
            y = y + 1;
        end
      
    end
    
    ellipseProps = regionprops(labels, ...
                               'Centroid', ...
                               'MajorAxisLength', ...
                               'MinorAxisLength', ...
                               'Orientation')
    
    area = ellipseProps.MajorAxisLength / 2 * ...
           ellipseProps.MinorAxisLength / 2 * ...
           pi;
    eccentricity = sqrt(1 - ...
                        ((ellipseProps.MinorAxisLength / 2) / ...
                         (ellipseProps.MajorAxisLength / 2)) ^ 2);
                           
    mergedObj.Centroid = ellipseProps.Centroid;
    mergedObj.Area = area;
    mergedObj.Eccentricity = eccentricity;
    mergedObj.MajorAxisLength = ellipseProps.MajorAxisLength;
end

function dist = DistanceBetweenPoints(point1, point2)

    dist = sqrt((point1(1)-point2(1))^2 + (point1(2) - point2(2))^2);

end