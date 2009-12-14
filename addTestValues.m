function testVals=addTestValues(splitLine, concave_points)

[testVals.concavitiesA testVals.concavitiesB]=getConcaveNr(splitLine.polA, splitLine.polB, concave_points);
%length of split path
split_line_vec=splitLine.startPoint-splitLine.endPoint;
testVals.splitLen=hypot(split_line_vec(:,1),split_line_vec(:,2));
%relative length of split path
[testVals.relsplitLen testVals.splitLineLongestSide]=getRelativePathLen(splitLine,testVals.splitLen);


% switch(splitLine.startDegree)
%     case 4
%         switch(splitLine.endDegree)
%         case {3,4}
%             %record the minimum number of concave points left in the
%             %polygon pair - ideally it will be zero
%             testVals.concaveMin=getMinConcaveNr(splitLine.polA, splitLine.polB, concave_points);
%             %length of split path
%             split_line_vec=splitLine.startPoint-splitLine.endPoint;
%             testVals.splitLen=hypot(split_line_vec(:,1),split_line_vec(:,2));
%             %relative length of split path
%             testVals.relsplitLen=getRelativePathLen(splitLine,testVals.splitLen);
%         case {1,2}
%             testVals.concaveMin=getMinConcaveNr(splitLine.polA, splitLine.polB, concave_points);
%              %length of split path
%             split_line_vec=splitLine.startPoint-splitLine.endPoint;
%             testVals.splitLen=hypot(split_line_vec(:,1),split_line_vec(:,2));
%             %relative length of split path
%             testVals.relsplitLen=getRelativePathLen(splitLine,testVals.splitLen);
%         case 0
%             
%         end
%     
%     case 3
%         switch(splitLine.endDegree)
%         case {3}
%             %record the minimum number of concave points left in the
%             %polygon pair - ideally it will be zero
%             testVals.concaveMin=getMinConcaveNr(splitLine.polA, splitLine.polB, concave_points);
%             %length of split path
%             split_line_vec=splitLine.startPoint-splitLine.endPoint;
%             testVals.splitLen=hypot(split_line_vec(:,1),split_line_vec(:,2));
%             %relative length of split path
%             testVals.relsplitLen=getRelativePathLen(splitLine,testVals.splitLen);
%         case {1,2}
%             testVals.concaveMin=getMinConcaveNr(splitLine.polA, splitLine.polB, concave_points);
%              %length of split path
%             split_line_vec=splitLine.startPoint-splitLine.endPoint;
%             testVals.splitLen=hypot(split_line_vec(:,1),split_line_vec(:,2));
%             %relative length of split path
%             testVals.relsplitLen=getRelativePathLen(splitLine,testVals.splitLen);
%         case 0
%             
%         end
%     case 2
%         %only one possibility degree end==1
%         testVals.concaveMin=getMinConcaveNr(splitLine.polA, splitLine.polB, concave_points);
%         %length of split path
%         split_line_vec=splitLine.startPoint-splitLine.endPoint;
%         testVals.splitLen=hypot(split_line_vec(:,1),split_line_vec(:,2));
%         %relative length of split path
%         testVals.relsplitLen=getRelativePathLen(splitLine,testVals.splitLen);
%     case 1
%         %only one possibility degree end==1
%         testVals.concaveMin=getMinConcaveNr(splitLine.polA, splitLine.polB, concave_points);
%         %length of split path
%         split_line_vec=splitLine.startPoint-splitLine.endPoint;
%         testVals.splitLen=hypot(split_line_vec(:,1),split_line_vec(:,2));
%         %relative length of split path
%         testVals.relsplitLen=getRelativePathLen(splitLine,testVals.splitLen);
% end