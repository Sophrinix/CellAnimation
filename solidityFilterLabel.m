function output_args=solidityFilterLabel(input_args)
% Usage
% This module is used to remove objects below or above a threshold solidity value from a MATLAB label matrix.
% Input Structure Members
% ObjectsLabel – The label matrix from which objects will be removed.
% MaxSolidity – Objects whose solidity is above this value will be removed from the image.
% MinSolidity - Objects whose solidity is below this value will be removed from the image.
% Output Structure Members
% LabelMatrix – The filtered label matrix.

cells_lbl=input_args.ObjectsLabel.Value;
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
if (min(valid_solidities_idx)==1)
    %no invalid objects return the same label back
    output_args.LabelMatrix=cells_lbl;
else    
    valid_object_numbers=find(valid_solidities_idx);
    new_object_numbers=1:length(valid_object_numbers);
    %we will replace valid numbers with new and everything else will be set to
    %zero
    object_idx=cells_lbl>0;
    new_object_index=zeros(max(cells_lbl(object_idx)),1);
    new_object_index(valid_object_numbers)=new_object_numbers;
    new_cells_lbl=cells_lbl;
    %replace the old object numbers to prevent skips in numbering    
    new_cells_lbl(object_idx)=new_object_index(cells_lbl(object_idx));
    output_args.LabelMatrix=new_cells_lbl;
end

%end solidityFilter
end
