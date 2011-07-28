function output_args=generateBinImgUsingLocAvg(input_args)
%Usage
%This module is used to convert a grayscale image to a binary image using local average values.
%
%Input Structure Members
%BrightnessThresholdPct – This value indicates what percentage of the local average value will
%be used to threshold the image. If the pixel intensity is higher than this value times the local
%average value the corresponding pixel in the binary image will be set to one.
%ClearBorder – If this value is set to true objects that are within ClearBorderDist of the image
%edges will be erased.
%ClearBorderDist – Objects that are within this distance from the edges of the image will be
%erased if ClearBorder is set to true.
%Image – Grayscale image to be converted.
%Strel – Filter type used to generate the local average image. Currently ‘circular’ is the only value
%supported.
%StrelSize – Size of the local neighborhood used to calculate the average for each pixel in the
%image.
%
%Output Structure Members
%Image – Resulting binary image.
%
%Example
%
%local_avg_filter_function.InstanceName='LocalAveragingFilter';
%local_avg_filter_function.FunctionHandle=@generateBinImgUsingLocAvg;
%local_avg_filter_function.FunctionArgs.Image.FunctionInstance='NegativeImage'
%;
%local_avg_filter_function.FunctionArgs.Image.OutputArg='Image';
%local_avg_filter_function.FunctionArgs.Strel.Value='disk';
%local_avg_filter_function.FunctionArgs.StrelSize.Value=10;
%local_avg_filter_function.FunctionArgs.BrightnessThresholdPct.Value=1.2;
%local_avg_filter_function.FunctionArgs.ClearBorder.Value=false;
%local_avg_filter_function.FunctionArgs.ClearBorderDist.Value=0;
%functions_list=addToFunctionChain(functions_list,local_avg_filter_function);
%
%…
%
%fill_holes_function.FunctionArgs.Image.FunctionInstance='LocalAveragingFilter
%';
%fill_holes_function.FunctionArgs.Image.OutputArg='Image';

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
