function output_args=loadAncestryLayout(input_args)
% Usage
% This module is used to load a structure containing the order of each column in the ancestry matrix from a MATLAB .mat file.
% Input Structure Members
% FileName – The name of the .mat file containing the ancestry layout structure.
% Output Structure Members
% AncestryLayout – Structure containing the order of each column in the ancestry matrix.

load(input_args.FileName.Value);
output_args.AncestryLayout=ancestry_layout;

end