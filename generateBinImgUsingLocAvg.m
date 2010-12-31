function output_args=generateBinImgUsingLocAvg(input_args)
%module to convert a grayscale image to a binary image using the local
%average values
avg_filter=fspecial(input_args.Strel.Value,input_args.StrelSize.Value);
img_avg=imfilter(input_args.Image.Value,avg_filter,'replicate');
img_bw=input_args.Image.Value>(input_args.BrightnessThresholdPct.Value*img_avg);
clear_border_dist=input_args.ClearBorderDist.Value;
if (input_args.ClearBorder.Value)
    if (clear_border_dist>1)
        img_bw(1:clear_border_dist-1,1:end)=1;
        img_bw(end-clear_border_dist+1:end,1:end)=1;
        img_bw(1:end,1:clear_border_dist-1)=1;
        img_bw(1:end,end-clear_border_dist+1:end)=1;
    end
    output_args.Image=imclearborder(img_bw);
else
    output_args.Image=img_bw;
end

%end generateBinImgUsingLocAvg
end