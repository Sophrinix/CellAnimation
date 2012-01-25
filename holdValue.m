function output_args=holdValue(input_args)
% Usage
% The only purpose for this module is to hold a value so that other modules may use it, for example by having the holdValue module at a higher level in the hierarchy, thereby preventing modules at lower levels from overwriting the value.
% Input Structure Members
% ValueToHold – The value to hold.
% Output Structure Members
% ValueToHold – The held value.

output_args.ValueToHold=input_args.ValueToHold.Value;

end