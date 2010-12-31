function output_args=solidityFilter(input_args)
%module to remove objects below or above a threshold solidity from a binary
%image
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