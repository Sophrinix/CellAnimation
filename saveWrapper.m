function output_args=saveWrapper(input_args)
%simple module to wrap the Matlab save function

saved_data=input_args.SaveData.Value;
save(input_args.FileName.Value,'saved_data');
output_args=[];

%end saveCellsLabel
end