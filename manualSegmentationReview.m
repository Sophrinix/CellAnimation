function output_args=manualSegmentationReview(input_args)
%Usage
%This module is used to manually correct errors in automatic segmentation. The module loads
%a GUI for each frame with all the available segmentation corrections. To start the user has to
%
%select between blob correction and object correction by clicking on the "Select Blob" or "Select
%Object" button. A blob is a contiguous region as defined by the background pixels and it may
%contain one or more objects. An object is the set of pixels with the same non-zero ID in the label
%matrix. An object may span multiple blobs.
%
%In general (with the exception of the "Restore Blob" operation), an object or blob must be
%selected before an operation can be performed on it. Selection is performed by clicking on the
%object or blob of interest. A selected item is indicated by a checkerboard pattern. If the "Select
%Multiple" box is checked clicking on an unselected item adds it to the selection.
%
%The types of operations that may be performed on a blob are resegmentation, deletion and
%restoration. To resegment a blob one needs to indicate how many objects the new blob will
%contain and their approximate boundaries. Clicking on the selected blob after the "Resegment
%Blob" button has been pressed indicates that the pixels at those locations belong to the first
%object in the blob. To move to the next object press the letter "n" on the keyboard and click
%within the blob to indicate rough boundaries. The boundaries do not have to be specified
%precisely and a blob may be separated into two objects in as few as two clicks. Once all
%the objects have been defined press the letter "d" on the keyboard and the blob will be
%resegmented. During resegmentaion all the pixels in the blob are assigned to objects using a
%nearest-neighbor classifier based on the pixels selected by the user. A blob may be deleted by
%selecting it and then clicking the "Remove Blob" button. To restore a blob removed by mistake
%click on the "Restore Blob" button. The GUI will display the "Raw Label" image which shows all
%the blobs present after thresholding before any removal by filters or manual deletions. Choose
%the blob to restore by clicking on it.
%
%Two types of operations can be performed on objects: joining and deletion. To join a number of
%objects into a single object click on the "Join Objects" button then select the objects you want to
%join by clicking on them. When you are done with object selection and want to join the objects
%press the "d" letter on the keyboard. To delete an object select it then click on the "Remove
%Object" button.
%
%Once all the corrections have been performed click on the "Save Changes & Continue" button to
%save your changes and move on to the next frame.
%
%Input Structure Members
%Image - The microscopy image for the current ObjectsLabel.
%ObjectsLabel - The label matrix containing the objects for which the automatic segmentation will
%be evaluated or corrected.
%PreviousLabel - The label matrix containing objects from the previous time step.
%RawLabel - The label matrix containing the objects before filtering.
%
%Output Structure Members
%LabelMatrix - The label matrix containing manual corrections if any.


global msr_gui_struct;

objects_lbl=input_args.ObjectsLabel.Value;
raw_lbl=input_args.RawLabel.Value;
previous_lbl=input_args.PreviousLabel.Value;
msr_gui_struct.ColorMap='colorcube';
msr_gui_struct.BkgColor=[0.7 0.7 0];
msr_gui_struct.ErrorTypes=[];
msr_gui_struct.ErrorBlobIDs=[];
msr_gui_struct.TotalErrors=0;
msr_gui_struct.CurrentAction='';
msr_gui_struct.ObjectsLabel=objects_lbl;
msr_gui_struct.BlobsLabel=bwlabeln(objects_lbl>0);
msr_gui_struct.OriginalObjectsLabel=raw_lbl;
msr_gui_struct.OriginalBlobsLabel=bwlabeln(raw_lbl>0);
msr_gui_struct.PreviousLabel=previous_lbl;
msr_gui_struct.Image=input_args.Image.Value;
msr_gui_struct.SelectMultiple=false;
msr_gui_struct.SelectedBlobID=[];
msr_gui_struct.SelectedObjectID=[];
msr_gui_struct.SnapToNearest=true;
%initialize the gui
field_names=fieldnames(msr_gui_struct);
gui_handle=findall(0,'Tag','ManualResegmentation');
if (~isempty(gui_handle))    
    close(gui_handle);    
end
if (max(strcmp('FigurePosition',field_names)))
    msr_gui_struct.GuiHandle=manualSegmentationReviewGUI('Position',msr_gui_struct.FigurePosition);
else
    msr_gui_struct.GuiHandle=manualSegmentationReviewGUI;    
end
gui_handle=msr_gui_struct.GuiHandle;
children_handles=get(gui_handle,'children');
objects_rgb=label2rgb(objects_lbl,msr_gui_struct.ColorMap,msr_gui_struct.BkgColor,'shuffle'); 
objects_axes_handle=findobj(children_handles,'tag','objectsAxes');
msr_gui_struct.AxesHandle=objects_axes_handle;
msr_gui_struct.SelectBlobButtonHandle=findobj(children_handles,'tag','selectBlobButton');
msr_gui_struct.SelectObjectButtonHandle=findobj(children_handles,'tag','selectObjectButton');
msr_gui_struct.ResegmentBlobButtonHandle=findobj(children_handles,'tag','resegmentBlobButton');
msr_gui_struct.RemoveBlobButtonHandle=findobj(children_handles,'tag','removeBlobButton');
msr_gui_struct.RestoreBlobButtonHandle=findobj(children_handles,'tag','restoreBlobButton');
msr_gui_struct.JoinObjectsButtonHandle=findobj(children_handles,'tag','joinObjectsButton');
msr_gui_struct.RemoveObjectButtonHandle=findobj(children_handles,'tag','removeObjectButton');
msr_gui_struct.StatusTextHandle=findobj(children_handles,'tag','statusText');
msr_gui_struct.CheckBoxPrevLabelHandle=findobj(children_handles,'tag','checkboxPrevLabel');
msr_gui_struct.CheckBoxOverlayPrevLabelHandle=findobj(children_handles,'tag','checkboxOverlayPrevLabel');
msr_gui_struct.CheckBoxSelectMultipleHandle=findobj(children_handles,'tag','checkboxSelectMultiple');
msr_gui_struct.CheckBoxSnapToNearestHandle=findobj(children_handles,'tag','checkboxSnapNearest');
if (isempty(previous_lbl))
    %disable show previous label checkbox
    set(msr_gui_struct.CheckBoxPrevLabelHandle,'Enable','off');
    msr_gui_struct.CheckBoxPrevLabelHandle=[];
    %disable overlay previous label checkbox
    set(msr_gui_struct.CheckBoxOverlayPrevLabelHandle,'Enable','off');
    msr_gui_struct.CheckBoxOverlayPrevLabelHandle=[];
end
msr_gui_struct.CheckBoxRawLabelHandle=findobj(children_handles,'tag','checkboxRawLabel');
msr_gui_struct.CheckBoxImageHandle=findobj(children_handles,'tag','checkboxImage');

%display objects image in the objectAxes
msr_gui_struct.ImageHandle=image(objects_rgb,'Parent',objects_axes_handle);
%set the function handle for a mouse click in the objects image
set(msr_gui_struct.ImageHandle,'buttondownfcn','mouseClickInLabel');
set(msr_gui_struct.GuiHandle,'KeyPressFcn','keyPressInManualSegmentationGUI');
%block execution until gui is closed
waitfor(gui_handle);
output_args.LabelMatrix=msr_gui_struct.ObjectsLabel;

%end manualSegmentationReview
end
