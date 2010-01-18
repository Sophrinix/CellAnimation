function img_bw=generateBinImgUsingLocAvg(img_to_proc,filterParamsStruct)
avg_filter=fspecial(filterParamsStruct.strel,filterParamsStruct.strelSize);
img_avg=imfilter(img_to_proc,avg_filter,'replicate');
img_bw=img_to_proc>(filterParamsStruct.BrightnessThresholdPct*img_avg);
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
end %end generateBinImgUsingLocAvg