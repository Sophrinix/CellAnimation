function output_args = readImageOmero(function_args)

global g;

img_id = function_args.ImageId.Value;
img_channel = 0; %function_args.Channel.Value;
timepoint = function_args.CurFrame.Value;

%intialize omero connection
img_to_proc = getPlaneFromImageId(g, img_id, 0, img_channel, timepoint);

switch img_channel
    case 'r'
        img_to_proc=img_to_proc(:,:,1);
    case 'g'
        img_to_proc=img_to_proc(:,:,2);
    case 'b'
        img_to_proc=img_to_proc(:,:,3);
end

output_args.Image = img_to_proc;

%end readImageOmero
end
