function trackVector = AssignTracks(lklhdMatrix)

    %pre-allocate space for needed matrices
    avoidMatrix = zeros(size(lklhdMatrix));
    trackVector = avoidMatrix(1,:);
    trackIndex = 1;
    while(trackIndex <= size(lklhdMatrix,1)) 
        
        [trackIndex, trackVector, avoidMatrix] = ...
            Assign(trackIndex, ...
                   lklhdMatrix, ...
                   trackVector, ...
                   avoidMatrix);
        
    end
    
    %too many recursive calls (>600) requires set(0, 'RecursionLimit', N) n
    %~1000
    %trackMatrix = AssignTrack(trackIndex, lklhdMatrix, trackMatrix, avoidMatrix);
    
end
