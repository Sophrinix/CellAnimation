function continuous_lbl=makeContinuousLabelMatrix(objects_lbl)
%make the label matrix ids sequential as a number of functions expect it
%that way

continuous_lbl=objects_lbl;
label_ids=unique(objects_lbl);
%remove 0 the background id
label_ids(1)=[];
ids_nr=length(label_ids);
if (ids_nr==label_ids(end))
    %object label matrix is continuous
    return;
end
skipped_ids_exist=false;
for i=1:ids_nr
    if (label_ids(i)~=i)
        skipped_ids_exist=true;
    end
    if (skipped_ids_exist)
        continuous_lbl(continuous_lbl==label_ids(i))=i;        
    else
        continue;
    end    
end

%end makeContinuousLabel
end