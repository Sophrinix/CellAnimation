function output_args=eccentricityFilterLabel(input_args)

cells_lbl=input_args.ObjectsLabel.Value;
cells_props=regionprops(cells_lbl,'Eccentricity');
field_names=fieldnames(input_args);
if (max(strcmp(field_names,'MinEccentricity')))
    b_min=true;
else
    b_min=false;
end
if (max(strcmp(field_names,'MaxEccentricity')))
    b_max=true;
else
    b_max=false;
end
cells_eccentricity=[cells_props.Eccentricity];
cells_nr=length(cells_eccentricity);
valid_eccentricities_idx=false(1,cells_nr);
if (b_min)
    valid_eccentricities_idx=valid_eccentricities_idx|(cells_eccentricity>=input_args.MinEccentricity.Value);
end
if (b_max)
    valid_eccentricities_idx=valid_eccentricities_idx|(cells_eccentricity<=input_args.MaxEccentricity.Value);
end
if (min(valid_eccentricities_idx)==1)
    %no invalid objects return the same label back
    output_args.LabelMatrix=cells_lbl;
else    
    valid_object_numbers=find(valid_eccentricities_idx);
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

%end eccentricityFilterLabel
end