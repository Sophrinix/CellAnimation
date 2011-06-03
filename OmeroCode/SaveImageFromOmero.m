function SaveImageFromOmero(gateway, wellid, timepoint, imagefilename, fmt)

    %get the matrix representation of the image at time 0
    img = getPlaneFromImageId(gateway, wellid, 0, 0, timepoint);

    %save the image locally, for use by Segment Review
    imwrite(img, imagefilename, fmt);
    
end