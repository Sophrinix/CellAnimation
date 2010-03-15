function output_args=areaOverPerimeterFilterLabel(input_args)

cells_lbl=input_args.ObjectsLabel.Value;
cells_props=regionprops(cells_lbl,'Area','Perimeter');
field_names=fieldnames(input_args);
if (max(strcmp(field_names,'MinAreaOverPerimeter')))
    b_min=true;
else
    b_min=false;
end
if (max(strcmp(field_names,'MaxAreaOverPerimeter')))
    b_max=true;
else
    b_max=false;
end
cells_area=[cells_props.Area];
cells_perimeter=[cells_props.Perimeter];
cells_nr=length(cells_area);
a_over_p=cells_area./cells_perimeter;
valid_aoverp_idx=false(1,cells_nr);
if (b_min)
    valid_aoverp_idx=valid_aoverp_idx|(a_over_p>=input_args.MinAreaOverPerimeter.Value);
end
if (b_max)
    valid_aoverp_idx=valid_aoverp_idx|(a_over_p<=input_args.MaxAreaOverPerimeter.Value);
end
if (min(valid_aoverp_idx)==1)
    %no invalid objects return the same label back
    output_args.LabelMatrix=cells_lbl;
else    
    valid_object_numbers=find(valid_aoverp_idx);
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

%end areaOverPerimeterFilterLabel
end