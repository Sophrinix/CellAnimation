function output_args=imageErode(input_args)
%module shell for the Matlab imerode(im,se) function
img=input_args.Image.Value;
se=input_args.StructuralElement.Value;
output_args.ErodedImage=imerode(img,se);

%end imageErode
end