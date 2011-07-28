function output_args=negativeImage(input_args)
%Usage
%This module returns the negative of the image provided as an argument.
%
%Input Structure Members
%Image – Image to be processed.
%
%Output Structure Members
%Image – Negative image.
%
%Example
%
%negative_image_function.InstanceName='NegativeImage';
%negative_image_function.FunctionHandle=@negativeImage;
%negative_image_function.FunctionArgs.Image.FunctionInstance='ImageToBW';
%negative_image_function.FunctionArgs.Image.OutputArg='Image';
%functions_list=addToFunctionChain(functions_list,negative_image_function);
%
%…
%
%display_negative_image_function.FunctionArgs.Image.FunctionInstance='Negative
%Image';
%display_negative_image_function.FunctionArgs.Image.OutputArg='Image';

output_args.Image=~input_args.Image.Value;

end
