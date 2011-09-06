counts=[];
for(i=1:250)
  fileName = sprintf('DsRed - Confocal - n%06d', i);
  load(fileName);
  counts(i) = size(find([objSet.props.nucleus]),2);
end
