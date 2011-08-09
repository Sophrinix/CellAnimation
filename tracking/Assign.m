function [trackIndex, trackVector, avoidMatrix] = ...
            Assign(trackIndex, ...
                   lklhdMatrix, ...
                   trackVector, ...
                   avoidMatrix)

    %find the column of lklhdMatrix with the max lklhd in row trackIndex    
    maxCol = 0;
    maxLklhd = -100000;
    for(col=1:size(lklhdMatrix,2))
        if((lklhdMatrix(trackIndex, col) > maxLklhd) && ...
               (~avoidMatrix(trackIndex, col)))            
            maxLklhd = lklhdMatrix(trackIndex, col);
            maxCol = col;       
        end
    end
    
    if(maxCol)
        otherIndex = trackVector(maxCol);
        if(otherIndex && (lklhdMatrix(trackIndex, maxCol) > ...
                          lklhdMatrix(otherIndex, maxCol)))
            %this column has a higher likelihood than the one that
            %is currently associated with this track number
            %roll back the track vector
            %avoid this column for that track number
            trackVector = transpose(trackVector(:) < otherIndex) ...
                            .* trackVector;
            avoidMatrix(trackIndex, maxCol) = 1;    
            trackIndex = otherIndex;
        elseif(otherIndex && (lklhdMatrix(trackIndex, maxCol) < ...
                                lklhdMatrix(otherIndex, maxCol)))
            %the column already associated with this track number
            %has a higher likelihood
            avoidMatrix(trackIndex, maxCol) = 1;
        else   
            %unused track number, assign to this column
            trackVector(maxCol) = trackIndex;
            trackIndex = trackIndex + 1;
        end
    else
        %no match, advance track index
        trackIndex = trackIndex + 1;
    end
end