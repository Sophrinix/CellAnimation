function output_args=setGroupIndex(input_args)

shape_parameters=input_args.ShapeParameters.Value;
shape_parameters(input_args.CellID.Value,input_args.GroupIDCol.Value-input_args.AreaCol.Value+1)=input_args.GroupIndex.Value;
output_args.ShapeParameters=shape_parameters;

%end setGroupIndex
end