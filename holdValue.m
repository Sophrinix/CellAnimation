function output_args=holdValue(input_args)
%the only purpose for this module is to hold a value so that other modules
%may use it. used for example by having the holdvalue module at a higher
%level in the hierarchy thereby preventing modules at lower levels from
%overwriting the value

output_args.ValueToHold=input_args.ValueToHold.Value;

end