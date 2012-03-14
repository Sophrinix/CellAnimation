function output_args=generateBinImgUsingGradient3D(input_args)
% Usage
% This module is used to convert a 3-D grayscale image to a binary image using values of the image gradient by slices.
% Input Structure Members
% GradientThreshold – Areas in the gradient image where the gradient is higher than this value will be set to 1 in the binary image. 
% Image – Grayscale image to be converted.
% Output Structure Members
% Image – Resulting binary image.

img=input_args.Image.Value;
img_sz=size(img);
img_bw=zeros(img_sz);
grad_thresh=input_args.GradientThreshold.Value;
for i=1:img_sz(3)
    slice=img(:,:,i);
    [grad_x grad_y]=gradient(double(slice));
    grad_mag=sqrt(grad_x.^2+grad_y.^2);
    img_bw(:,:,i)=grad_mag>grad_thresh;
end

output_args.Image=img_bw;

end %end generateBinImgUsingGradient