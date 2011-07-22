function output_args=storeValues(input_args)
%store values for use by other functions
field_names=fieldnames(input_args);
for i=1:length(field_names)
    cur_field_name=field_names{i};
    output_args.(cur_field_name)=input_args.(cur_field_name).Value;
end

%end storeValues
end