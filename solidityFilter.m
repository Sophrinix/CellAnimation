function output_args=solidityFilter(input_args)
%Usage
%This module is used to remove objects below or above a threshold solidity from a binary image.
%
%Input Structure Members
%Image – The binary image from which objects will be removed.
%MaxSolidity – Objects whose solidity is above this value will be removed from the image.
%MinSolidity - Objects whose solidity is below this value will be removed from the image.
%
%Output Structure Members
%Image – The filtered binary image.
%
%Example
%
%solidity_filter_function.InstanceName='SolidityFilter';
%solidity_filter_function.FunctionHandle=@solidityFilterLabel;
%solidity_filter_function.FunctionArgs.ObjectsLabel.FunctionInstance='AreaFilt
%er';
%solidity_filter_function.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
%solidity_filter_function.FunctionArgs.MinSolidity.Value=0.69;
%
%…
%
%ap_filter_function.FunctionArgs.ObjectsLabel.FunctionInstance='SolidityFilter
%';
%ap_filter_function.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';

cells_lbl=bwlabeln(input_args.Image.Value);
cells_props=regionprops(cells_lbl,'Solidity');
field_names=fieldnames(input_args);
if (max(strcmp(field_names,'MinSolidity')))
    b_min=true;
else
    b_min=false;
end
if (max(strcmp(field_names,'MaxSolidity')))
    b_max=true;
else
    b_max=false;
end
cells_solidity=[cells_props.Solidity];
cells_nr=length(cells_solidity);
valid_solidities_idx=false(1,cells_nr);
if (b_min)
    valid_solidities_idx=valid_solidities_idx|(cells_solidity>=input_args.MinSolidity.Value);
end
if (b_max)
    valid_solidities_idx=valid_solidities_idx|(cells_solidity<=input_args.MaxSolidity.Value);
end

output_args.Image=ismember(cells_lbl,find(valid_solidities_idx));

%end solidityFilter
end
