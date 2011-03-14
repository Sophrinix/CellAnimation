function output_args=imwrite_Wrapper(input_args)
%basic wrapper for imwrite

img=input_args.Image.Value;
file_name=input_args.FileName.Value;
fmt=input_args.Format.Value;
imwrite(img,file_name,fmt,'Compression','none');

output_args=[];

%end saveImage
end