function output_args=combineImages(input_args)

switch (input_args.CombineOperation.Value)
    case 'AND'
        output_args.Image=input_args.Image1.Value&input_args.Image2.Value;
    case 'OR'
        output_args.Image=input_args.Image1.Value|input_args.Image2.Value;
end

%end combineImages
end