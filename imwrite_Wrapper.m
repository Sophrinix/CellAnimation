function output_args=imwrite_Wrapper(input_args)
%basic wrapper for the MATLAB imwrite function
%Input Structure Members
%Image - The image to be saved.
%FileName - The path where the image will be saved.
%Format - The image format.
%Output Structure Members
%None

img=input_args.Image.Value;
file_name=input_args.FileName.Value;
fmt=input_args.Format.Value;
imwrite(img,file_name,fmt,'Compression','none');

output_args=[];

%end saveImage
end