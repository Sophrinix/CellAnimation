function output_args=generateBinImgUsingGradient(input_args)
%module to convert a grayscale image to a binary image using values of the
%image gradient
[grad_x grad_y]=gradient(double(input_args.Image.Value));
grad_mag=sqrt(grad_x.^2+grad_y.^2);
img_bw=grad_mag>input_args.GradientThreshold.Value;
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

end %end generateBinImgUsingGradient