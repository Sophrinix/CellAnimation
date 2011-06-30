function output_args=getObjectIntensities(input_args)

objects_lbl=input_args.LabelMatrix.Value;
objects_idx=objects_lbl>0;
intensity_img=input_args.IntensityImage.Value;
objects_intensities=accumarray(objects_lbl(objects_idx),intensity_img(objects_idx));
object_areas=accumarray(objects_lbl(objects_idx),1);
output_args.MeanIntensities=objects_intensities./object_areas;

%end getCentroids3D
end