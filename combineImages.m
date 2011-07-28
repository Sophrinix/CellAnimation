function output_args=combineImages(input_args)
%Usage
%This module is used to combine two binary images using logical operations.
%
%Input Structure Members
%CombineOperation – String value indicating the logical operation used to combine the images.
%Currently, only ‘AND’ and ‘OR’ are supported.
%Image1 – First binary image.
%Image2 – Second binary image.
%
%Output Structure Members
%Image – Binary image resulting from the logical operation.
%
%Example
%
%combine_nucl_plus_cyto_function.InstanceName='CombineNuclearAndCytoplasmImage
%s';
%combine_nucl_plus_cyto_function.FunctionHandle=@combineImages;
%combine_nucl_plus_cyto_function.FunctionArgs.Image1.FunctionInstance='ClearSm
%allNuclei';
%combine_nucl_plus_cyto_function.FunctionArgs.Image1.OutputArg='Image';
%combine_nucl_plus_cyto_function.FunctionArgs.Image2.FunctionInstance='ClearSm
%allCells';
%combine_nucl_plus_cyto_function.FunctionArgs.Image2.OutputArg='Image';
%combine_nucl_plus_cyto_function.FunctionArgs.CombineOperation.Value='AND';
%image_read_loop_functions=addToFunctionChain(image_read_loop_functions,combin
%e_nucl_plus_cyto_function);
%
%…
%
%reconstruct_cyto_function.FunctionArgs.GuideImage.FunctionInstance='CombineNu
%clearAndCytoplasmImages';
%reconstruct_cyto_function.FunctionArgs.GuideImage.OutputArg='Image';

switch (input_args.CombineOperation.Value)
    case 'AND'
        output_args.Image=input_args.Image1.Value&input_args.Image2.Value;
    case 'OR'
        output_args.Image=input_args.Image1.Value|input_args.Image2.Value;
end

%end combineImages
end
