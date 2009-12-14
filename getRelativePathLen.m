function [rel_path_len splitLineLongestSide]=getRelativePathLen(splitLine, path_len)
%get relative path length dr(a)=d(a)/min(perimeterA,perimeterB)
polA=splitLine.polA;
polB=splitLine.polB;
polA_vec=polA(1:end-1,:)-polA(2:end,:);
polA_len=hypot(polA_vec(:,1),polA_vec(:,2));
polA_perim=sum(polA_len);
polB_vec=polB(1:end-1,:)-polB(2:end,:);
polB_len=hypot(polB_vec(:,1),polB_vec(:,2));
polB_perim=sum(polB_len);
splitLineLongestSideinA=min(path_len>=polA_len)==1;
splitLineLongestSideinB=min(path_len>=polB_len)==1;
min_perim=min([polA_perim polB_perim]);
rel_path_len=path_len/min_perim;
splitLineLongestSide=splitLineLongestSideinA&splitLineLongestSideinB;