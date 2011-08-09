function stats = Validate(classifier, validatedSet, classifiedSet)
    
  stats = struct();
  truePos = 0;
  trueNeg = 0;
  falsePos = 0;
  falseNeg = 0;
    
  names = fieldnames(classifier);
  for(i=1:size(names))        
    validatedValues = [validatedSet(:).(names{i})];
    classifiedValues = [classifiedSet(:).(names{i})];
        
    for(j=1:size(validatedValues,2))          
      if(validatedValues(j) && classifiedValues(j))                
        truePos = truePos + 1; 
      elseif(~validatedValues(j) && ~classifiedValues(j))
        trueNeg = trueNeg + 1;
      elseif(~validatedValues(j) && classifiedValues(j))
        falsePos = falsePos + 1;
      elseif(validatedValues(j) && ~classifiedValues(j))
        falseNeg = falseNeg + 1;
      end        
    end
      
    stats.(names{i}).truePos = truePos / (truePos + falseNeg);
    stats.(names{i}).trueNeg = trueNeg / (trueNeg + falsePos);
    stats.(names{i}).falseNeg = falseNeg / (truePos + falseNeg);
    stats.(names{i}).falsePos = falsePos / (trueNeg + falsePos);   
  end

end
