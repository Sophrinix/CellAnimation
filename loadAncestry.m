function output_args=loadAncestry(input_args)
%load the ancestry file
load(input_args.FileName.Value);
output_args.Ancestry=cells_ancestry;

end