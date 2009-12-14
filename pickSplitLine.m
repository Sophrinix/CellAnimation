function splitLine=pickSplitLine(potSplitLines, bRemoveLongSplits)
%for now i'm accepting only split lines that have at least one high degree
%point
splitLine=[];

if (isempty(potSplitLines))
    return;
end
%eliminate lines where the longest side in both polygons is the split line
tests=[potSplitLines.tests];
concavitiesA=[tests.concavitiesA];
concavitiesB=[tests.concavitiesB];
if (bRemoveLongSplits)
    if ((concavitiesA+concavitiesB)<2)
        %long lines that split a mostly convex object in length tend to be
        %erroneous
        splitLineLongest=[tests.splitLineLongestSide];
        potSplitLines=potSplitLines(~splitLineLongest);
    end
end

if (isempty(potSplitLines))
    return;
end
start_points_degrees=[potSplitLines.startDegree];
end_points_degrees=[potSplitLines.endDegree];
degree_scores=start_points_degrees+end_points_degrees;
high_degree_start_points_idx=start_points_degrees>2;
high_degree_end_points_idx=end_points_degrees>2;
high_degree_lines_idx=high_degree_start_points_idx|high_degree_end_points_idx|(degree_scores>3);
high_degree_lines=potSplitLines(high_degree_lines_idx);

if (isempty(high_degree_lines))
    return;
end
high_degree_scores=degree_scores(high_degree_lines_idx);
%sort the high degree lines by score
[hd_sort hd_sort_idx]=sort(high_degree_scores);
high_degree_lines=high_degree_lines(hd_sort_idx);
tests=[high_degree_lines.tests];            
concavitiesA=[tests.concavitiesA];
concavitiesB=[tests.concavitiesB];
%i would like the split line to result in one completely
%convex polygon if possible
zero_concavities_idx=(concavitiesA==0)|(concavitiesB==0);
%eliminate those lines which don't result in at least one convex polygon
high_degree_lines=high_degree_lines(zero_concavities_idx);
%i would also like to eliminate unnecessarily long split lines
% tests=[high_degree_lines.tests];
% rel_path_len=[tests.relsplitLen];
% short_lines_idx=rel_path_len<0.35;
% high_degree_lines=high_degree_lines(short_lines_idx);

if (isempty(high_degree_lines))
    return;
end

% splitLine=getHighDegHighDeg(high_degree_lines);
splitLine=high_degree_lines(1);
return;
    
% switch(start_point_degree)
%     case {4,3}
%         %first see if we have a high degree end point
%         high_degree_points_idx=end_points_degrees>2;
%         high_degree_lines=potSplitLines(high_degree_points_idx);
%         if (~isempty(high_degree_lines))            
%             tests=[high_degree_lines.tests];            
%             concavitiesA=[tests.concavitiesA];
%             concavitiesB=[tests.concavitiesB];
%             %i would like the split line to result in one completely
%             %convex polygon if possible
%             zero_concavities_idx=(concavitiesA==0)|(concavitiesB==0);
%             if (max(zero_concavities_idx)==1)
%                 %this is an ideal point so return without checking for
%                 %other end points
%                 high_degree_lines=high_degree_lines(zero_concavities_idx);                
%                 splitLine=getHighDegHighDeg(high_degree_lines);
%                 return;
%             else
%                 %ignore low degree points for now
%                 return;
%                 %there is a point so save it but there might be a better
%                 %one keep checking for zero concavity split lines
% %                 high_degree_splitLine=getHighDegHighDeg(high_degree_lines);                            
%             end
%         end
%         
%         %check low degree end points
%         low_degree_points_idx=(end_points_degrees>0)&(~high_degree_points_idx);
%         low_degree_lines=potSplitLines(low_degree_points_idx);
%         if (~isempty(low_degree_lines))
%             tests=[low_degree_lines.tests];            
%             concavitiesA=[tests.concavitiesA];
%             concavitiesB=[tests.concavitiesB];
%             %i would like the split line to result in one completely
%             %convex polygon if possible
%             zero_concavities_idx=(concavitiesA==0)|(concavitiesB==0);
%             if (max(zero_concavities_idx)==1)
%                 %at least one such point exists                
%                 low_degree_lines=low_degree_lines(zero_concavities_idx);
%                 splitLine=getHighDegLowDeg(low_degree_lines);
%                 return;                
%             else
%                 %if there is a high degree end point return that
% %                 if (~isempty(high_degree_splitLine))
% %                     splitLine=high_degree_splitLine;
% %                 else
% %                     splitLine=getHighDegLowDeg(low_degree_lines);
% %                 end     
%             end
%         end
%         
%         %any high degree split line?
% %         if(~isempty(high_degree_splitLine))
% %             splitLine=high_degree_splitLine;
% %             return;
% %         end
%         %zero degree point - should only be one it means there is only one concave
%         %point in the original polygon
%         zero_degree_idx=end_points_degrees==0;
%         if (~isempty(zero_degree_idx))
%             %there is only one possible split line
%             splitLine=potSplitLines(1);
%         end
%             
%     case {2,1}
%         return
%         %first see if we have a high degree end point
%         high_degree_points_idx=end_points_degrees>2;
%         high_degree_lines=potSplitLines(high_degree_points_idx);
%         if (~isempty(high_degree_lines))            
%             tests=[high_degree_lines.tests];            
%             concavitiesA=[tests.concavitiesA];
%             concavitiesB=[tests.concavitiesB];
%             %i would like the split line to result in one completely
%             %convex polygon if possible
%             zero_concavities_idx=(concavitiesA==0)|(concavitiesB==0);          
%             if (max(zero_concavities_idx)==1)
%                 %at least one such point exists - return it
%                 high_degree_lines=high_degree_lines(zero_concavities_idx);
%                 splitLine=getHighDegLowDeg(high_degree_lines);
%                 return;
%             else
% %                 %a point exist but there might be a better match
% %                 high_degree_splitLine=getHighDegLowDeg(high_degree_lines);                
%             end
%         end
%         %check low degree end points
%         low_degree_points_idx=(end_points_degrees>0)&(~high_degree_points_idx);
%         low_degree_lines=potSplitLines(low_degree_points_idx);
%         if (~isempty(low_degree_lines))            
%             tests=[low_degree_lines.tests];            
%             concavitiesA=[tests.concavitiesA];
%             concavitiesB=[tests.concavitiesB];
%             %i would like the split line to result in one completely
%             %convex polygon if possible
%             zero_concavities_idx=(concavitiesA==0)|(concavitiesB==0);
%             if (max(zero_concavities_idx)==1)
%                 %at least one such point exists - return it
%                 low_degree_lines=low_degree_lines(zero_concavities_idx);
%                 splitLine=getLowDegLowDeg(low_degree_lines);
%                 return;
%             else
% %                 if (~isempty(high_degree_splitLine))
% %                     splitLine=high_degree_splitLine;
% %                 else
% %                     splitLine=getLowDegLowDeg(low_degree_lines);
% %                 end
% %                 return;
%             end
%         end
%         %any high degree split line?
% %         if(~isempty(high_degree_splitLine))
% %             splitLine=high_degree_splitLine;
% %             return;
% %         end
%         %zero degree point - should only be one it means there is only one concave
%         %point in the original polygon
%         zero_degree_idx=end_points_degrees==0;
%         if (~isempty(zero_degree_idx))
%             %there is only one possible split line
%             splitLine=potSplitLines(1);
%         end
% end

%end function
end

function splitLine=getHighDegHighDeg(potSplitLines)
%both points in the line are either degree 3 or 4

if (size(potSplitLines,1)==1)
    %only one point exists
    splitLine=potSplitLines;
    return;
end

tests=[potSplitLines.tests];
%more than one line exists use path length to pick one
path_len=[tests.splitLen];
min_path_length=min(path_len);
path_idx=path_len==min_path_length;
potSplitLines=potSplitLines(path_idx,:);
if (sum(path_idx)==1)
    %one point has the shortest path length
    splitLine=potSplitLines;
    return;
end
%more than one line exists with the same path length use
%relative path length to separate them
rel_path_len=[tests.relsplitLen];
rel_path_len=rel_path_len(path_idx);
min_rel_path_len=min(rel_path_len);
rel_path_idx=rel_path_len==min_rel_path_len;
potSplitLines=potSplitLines(rel_path_idx,:);
splitLine=potSplitLines(1);

%end function
end

function splitLine=getHighDegLowDeg(potSplitLines)
%one points in the line is degree 3 or 4 the other is degree two or one

if (size(potSplitLines,1)==1)
    %only one point exists
    splitLine=potSplitLines;
    return;
end
tests=[potSplitLines.tests];
%more than one line exists use relative path length to pick one
rel_path_len=[tests.relsplitLen];
min_rel_path_len=min(rel_path_len);
rel_path_idx=rel_path_len==min_rel_path_len;
potSplitLines=potSplitLines(rel_path_idx,:);
if (sum(rel_path_idx)==1)
    %one point has the shortest path length
    splitLine=potSplitLines;
    return;
end
%more than one line exists with the same relative path length use
%path length to separate them
path_len=[tests.splitLen];
path_len=path_len(rel_path_idx);
min_path_length=min(path_len);
path_idx=path_len==min_path_length;
potSplitLines=potSplitLines(path_idx,:);
splitLine=potSplitLines(1);

%end function
end

function splitLine=getLowDegLowDeg(potSplitLines)
threshold_dr=0.5; %minimum value of dr for which we accept a cut point
tests=[potSplitLines.tests];
rel_path_len=[tests.relsplitLen];
greater_than_threshold_idx=rel_path_len>=threshold_dr;
if (max(greater_than_threshold_idx)==0)
    splitLine=[];
    return;
end

potSplitLines=potSplitLines(greater_than_threshold_idx);
if (size(potSplitLines,1)==1)
    %only one point exists
    splitLine=potSplitLines;
    return;
end
%from here the cost functions are the same as highdeglowdeg
%the wang paper has the additional constrain area>area_threshold only for
%this type of lines but i implement that constrain for all lines
splitLine=getHighDegLowDeg(potSplitLines);

%end function
end


