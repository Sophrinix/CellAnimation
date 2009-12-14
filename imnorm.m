function img_norm=imnorm(img_raw,intclass)
%normalize image so that lowest value is zero and highest value is the
%maximum allowed value for the specified intclass
max_val=double(intmax(intclass));
img_dbl=floor(double((img_raw-min(img_raw(:))))*max_val./double(max(img_raw(:))-min(img_raw(:))));
switch(intclass)
    case 'uint8'
       img_norm=uint8(img_dbl);
    case 'uint16'
       img_norm=uint16(img_dbl);
    otherwise
        img_norm=[];
end

%end function
end