function output_args=loadCellsLabel(input_args)
% Usage
% This module is used to load cells/nuclei labels. It looks for a variable named cells_lbl in the .mat data file.
% Input Structure Members
% MatFileName – The name of the data file.
% 
% Output Structure Members
% LabelMatrix – The label matrix loaded from the file.


mat_file_name=input_args.FileName.Value;
try
    load_struct=load(mat_file_name);
catch
    warning(['Failed to load ' mat_file_name '! loadCellsLabel will return an empty image.']);
    output_args.LabelMatrix=[];
    return;
end
output_args.LabelMatrix=load_struct.cells_lbl;

%end loadCellsLabel
end
