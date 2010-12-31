function output_args=imNorm(input_args)
%module to normalize image so that lowest value is zero and highest value is the
%maximum allowed value for the specified intclass
int_class=input_args.IntegerClass.Value;
max_val=double(intmax(int_class));
img_raw=input_args.RawImage.Value;
img_dbl=floor(double((img_raw-min(img_raw(:))))*max_val./double(max(img_raw(:))-min(img_raw(:))));
switch(int_class)
    case 'uint8'
       output_args.Image=uint8(img_dbl);
    case 'uint16'
       output_args.Image=uint16(img_dbl);
    otherwise
        output_args.Image=[];
end

%end function
end