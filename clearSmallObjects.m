function output_args=clearSmallObjects(input_args)
%Usage
%This module is used to remove objects below a certain area from a binary image.
%
%Input Structure Members
%Image – Binary image from which objects will be removed.
%MinObjectArea – Objects with an area smaller than this value will be removed.
%
%Output Structure Members
%Image – Filtered binary image.
%
%Example
%
%clear_small_objects_function.InstanceName='ClearSmallObjects';
%clear_small_objects_function.FunctionHandle=@clearSmallObjects;
%clear_small_objects_function.FunctionArgs.Image.FunctionInstance='FillHolesIm
%age';
%clear_small_objects_function.FunctionArgs.Image.OutputArg='Image';
%clear_small_objects_function.FunctionArgs.MinObjectArea.Value=30;
%functions_list=addToFunctionChain(functions_list,clear_small_objects_function
%);
%
%…
%
%display_thresholded_image_function.FunctionArgs.Image.FunctionInstance='Clear
%SmallObjects';
%display_thresholded_image_function.FunctionArgs.Image.OutputArg='Image';

output_args.Image=bwareaopen(input_args.Image.Value,input_args.MinObjectArea.Value);

%end clearSmallObjects
end
