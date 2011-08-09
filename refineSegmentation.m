function output_args=refineSegmentation(input_args)
%Usage
%This module is used to retain only objects in a label matrix that are nearest to objects in another
%matrix.
%
%Input Structure Members
%CurrentLabel – The label matrix from which objects may be removed if they don’t have an object
%to which they are nearest in the PreviousLabel matrix.
%PreviousLabel – The objects in this label will determine the objects that will be retain in the
%current label.
%
%Output Structure Members
%LabelMatrix – The filtered label matrix.
%
%Example
%
%refine_segmentation_function.InstanceName='RefineSegmentation';
%refine_segmentation_function.FunctionHandle=@refineSegmentation;
%refine_segmentation_function.FunctionArgs.CurrentLabel.FunctionInstance='Segm
%entObjectsUsingMarkers';
%refine_segmentation_function.FunctionArgs.CurrentLabel.OutputArg='LabelMatrix
%';
%refine_segmentation_function.FunctionArgs.PreviousLabel.FunctionInstance='Res
%izePreviousLabel';
%refine_segmentation_function.FunctionArgs.PreviousLabel.OutputArg='Image';
%image_read_loop_functions=addToFunctionChain(image_read_loop_functions,refine
%_segmentation_function);
%
%…
%
%review_segmentation_function.FunctionArgs.ObjectsLabel.FunctionInstance='Refi
%neSegmentation';
%review_segmentation_function.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix
%';

prev_label=input_args.PreviousLabel.Value;
cur_label=input_args.CurrentLabel.Value;

if (isempty(prev_label))
    output_args.LabelMatrix=cur_label;
    return;
end

prev_centroids=getApproximateCentroids(prev_label);
cur_centroids=getApproximateCentroids(cur_label);
cur_triangulation=delaunay(cur_centroids(:,1),cur_centroids(:,2));

%get the indexes of the nearest centroids in the current label to the
%remaining centroids in the previous label
nearest_idx=dsearch(cur_centroids(:,1),cur_centroids(:,2),cur_triangulation,...
    prev_centroids(:,1),prev_centroids(:,2));
label_ids=unique(nearest_idx);
new_label=bwlabeln(ismember(cur_label,label_ids));
output_args.LabelMatrix=new_label;

%end refineSegmentation
end
