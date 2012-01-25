function output_args=resizeImage(input_args)
%wrapper module for Matlab imresize
%Input Structure Members
%Image - The image to be processed.
%Method - The method by which the image will be resized (see imresize help)
%Scale - Integer indicating by what amount the image should be
%reduced/enlarged
%Output Structure Members
%Image - The resulting image.
input_img=input_args.Image.Value;
if (isempty(input_img))
    warning 'Input image is empty. resizeImage will return an empty image!';
    output_args.Image=[];
else
    output_args.Image=imresize(input_args.Image.Value,input_args.Scale.Value,input_args.Method.Value);
end

%end resizeImage
end