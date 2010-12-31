function output_args=getParamsCoefficientOfVariation(input_args)
%module to get the coefficient of variation for tracking params
nr_params=input_args.SolidityCol.Value-input_args.AreaCol.Value+1;
shape_params=input_args.Params.Value;
params_means=mean(shape_params(:,1:nr_params));
params_sds=std(shape_params(:,1:nr_params));
output_args.CoefficientOfVariation=params_sds./params_means; %coefficient of variation of the params;

%end getParamsCoefficientOfVariation
end