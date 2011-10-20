function output_args=gcaWrapper(input_args)
%simple wrapper for gca MATLAB function
%Input Structure Members
%None
%Output Structure Members
%CurrentAxesHandle - The handle of the current figure.
output_args.CurrentAxesHandle=gca;

%end gcaWrapper
end