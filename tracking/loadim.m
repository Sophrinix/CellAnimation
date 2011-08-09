oldDir = cd('../segmentation/output');
disp('loading images into array "images"');

images = [];

for(i=2:71)
    
    numstr = int2str(i);
    while(length(numstr) < 2)
        numstr = ['0' numstr];
    end
    load(['DsRed - Confocal - n0000' numstr]);
    images(i-1).s = s;
    images(i-1).l = l;
    
end
cd(oldDir);
clear oldDir;
clear numstr;
clear s;
clear l;
clear i;