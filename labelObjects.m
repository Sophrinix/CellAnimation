function output_args=labelObjects(input_args)
%simple wrapper module for bwlabeln function
output_args.LabelMatrix=bwlabeln(input_args.Image.Value);

%end labelObjects
end