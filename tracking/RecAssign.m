function trackMatrix = RecAssign(trackIndex, lklhdMatrix, trackMatrix, avoidMatrix)    
    
    %find the column of lklhdMatrix with the max lklhd in row trackIndex    
    maxCol = 0;
    maxLklhd = -1000000;
    for(col=1:size(lklhdMatrix,2))
        if((lklhdMatrix(trackIndex, col) > maxLklhd) && ...
               (~avoidMatrix(trackIndex, col)))            
            maxLklhd = lklhdMatrix(trackIndex, col);
            maxCol = col;
        end
    end
   
    if(maxCol)      
        otherIndex = trackMatrix(trackIndex, maxCol);
        if(otherIndex && (lklhdMatrix(trackIndex, maxCol) > ...
                            lklhdMatrix(otherIndex, maxCol)))            
            %this column has a higher likelihood than the one that
            %is currently associated with this track number
            %roll back the track matrix and start again from the
            %other index, avoid this column for that track number
            trackMatrix = (trackMatrix(:,:) < otherIndex) .* trackMatrix;
            avoidMatrix(trackIndex, maxCol) = 1;
            trackMatrix = AssignTrack(otherIndex, lklhdMatrix, trackMatrix, avoidMatrix);
        elseif(otherIndex && (lklhdMatrix(trackIndex, maxCol) < ...
                                lklhdMatrix(otherIndex, maxCol)))
            %the column already associated with this track number
            %has a higher likelihood
            %redo this column, avoid current max
            avoidMatrix(trackIndex, maxCol) = 1;            
            trackMatrix = AssignTrack(trackIndex, lklhdMatrix, trackMatrix, avoidMatrix);
        elseif(trackIndex < size(lklhdMatrix,1))   
            %unused track number, assign to this column
            trackMatrix(:,maxCol) = trackIndex;
            %repeat on next row
            trackMatrix = AssignTrack(trackIndex+1, lklhdMatrix, trackMatrix, avoidMatrix);
        else
            %last row, do not make new call
            trackMatrix(:,maxCol) = trackIndex;
        end
    elseif(trackIndex < size(lklhdMatrix,1))
        trackMatrix = AssignTrack(trackIndex+1, lklhdMatrix, trackMatrix, avoidMatrix);
    end
end