function output_args=loadAncestry(input_args)
%load the ancestry data
%Input Structure Members
%FileName - The path to the ancestry .mat file.
%Output Structure Members
%Ancestry - Array containing the ancestry data.
load(input_args.FileName.Value);
output_args.Ancestry=cells_ancestry;

end