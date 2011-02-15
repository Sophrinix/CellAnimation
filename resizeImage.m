function output_args=resizeImage(input_args)
%wrapper module for Matlab imresize
input_img=input_args.Image.Value;
if (isempty(input_img))
    warning 'Input image is empty. resizeImage will return an empty image!';
    output_args.Image=[];
else
    output_args.Image=imresize(input_args.Image.Value,input_args.Scale.Value,input_args.Method.Value);
end

%end resizeImage
end