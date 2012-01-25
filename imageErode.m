function output_args=imageErode(input_args)
%simple wrapper for the Matlab imerode(im,se) function
%Input Structure Members
%Image - The grayscale image to be processed.
%Output Structure Members
%Image - The filtered image.
img=input_args.Image.Value;
se=input_args.StructuralElement.Value;
output_args.Image=imerode(img,se);

%end imageErode
end