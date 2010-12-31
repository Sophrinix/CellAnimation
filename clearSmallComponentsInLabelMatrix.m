function output_args=clearSmallComponentsInLabelMatrix(input_args)
%module to remove objects below a certain size from the label matrix

cyto_lbl=input_args.LabelMatrix.Value;
cyto_props=regionprops(cyto_lbl,'Area');
remove_idx=find([cyto_props.Area] >= input_args.MinComponentArea.Value);
img_cyto=ismember(cyto_lbl, remove_idx);
cells_nr=max(cyto_lbl(:));
k=0;
cyto_lbl=cyto_lbl.*img_cyto;
for i=1:cells_nr
    cyto_lin=find(cyto_lbl==i);
    if isempty(cyto_lin)
       k=k+1;
    else
       cyto_lbl(cyto_lin)=i-k;
    end    
end

output_args.LabelMatrix=cyto_lbl;
%end clearSmallComponentsInLabelMatrix
end