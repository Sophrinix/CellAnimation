function img_bw=generateBinImgUsingGlobInt(img_to_proc,filterParamsStruct)
max_pixel=max(img_to_proc(:));
min_pixel=min(img_to_proc(:));
brightnessPct=filterParamsStruct.IntensityThresholdPct;
threshold_intensity=brightnessPct*double(max_pixel-min_pixel)+min_pixel;
img_bw=img_to_proc>threshold_intensity;
% img_bw=im2bw(img_to_proc,brightnessPct*graythresh(img_to_proc));
clearBorderDist=filterParamsStruct.clearBorderDist;
if (filterParamsStruct.bClearBorder)
    if (clearBorderDist>1)
        img_bw(1:clearBorderDist-1,1:end)=1;
        img_bw(end-clearBorderDist+1:end,1:end)=1;
        img_bw(1:end,1:clearBorderDist-1)=1;
        img_bw(1:end,end-clearBorderDist+1:end)=1;
    end
    img_bw=imclearborder(img_bw);
end
end %end generateBinImgUsingGlobInt