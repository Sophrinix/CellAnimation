function offsetGenerationNumber(parent_id,offset_val)
global mtr_gui_struct;

ancestry_records=mtr_gui_struct.CellsAncestry;
ancestry_layout=mtr_gui_struct.AncestryLayout;
daughters_idx=ancestry_records(:,ancestry_layout.ParentIDCol)==parent_id;
daughter_ids=ancestry_records(daughters_idx,ancestry_layout.TrackIDCol);
if (isempty(daughter_ids))
    return;
end
ancestry_records(daughters_idx,ancestry_layout.GenerationCol)=...
    ancestry_records(daughters_idx,ancestry_layout.GenerationCol)+offset_val;
mtr_gui_struct.CellsAncestry=ancestry_records;
%recurse for all the daughters
for i=1:length(daughter_ids)
    offsetGenerationNumber(daughter_ids(i));
end

%end offsetGenerationNumber
end