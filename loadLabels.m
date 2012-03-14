function output_args=loadLabels(input_args)

im_num_str=sprintf(input_args.num_format.Value, input_args.CurFrame.Value);
load([input_args.directory.Value filesep ...
	  input_args.image_name_base.Value im_num_str '.mat']);
output_args.Labels=objSet.labels;

end
