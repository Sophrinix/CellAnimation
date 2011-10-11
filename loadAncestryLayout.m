function output_args=loadAncestryLayout(input_args)
%load the ancestry layout file
load(input_args.FileName.Value);
output_args.AncestryLayout=ancestry_layout;

end