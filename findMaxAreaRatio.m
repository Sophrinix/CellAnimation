function [end_point polA polB]=findMaxAreaRatio(pol_original,start_point)
%i want to a line from start_point to end_point splitting the original polygon 
%into two parts of equal area
end_point=[]; 
polA=[];
polB=[];
pol_len=size(pol_original,1);
eps=0.01;
start_point_idx=find((pol_original(:,1)==start_point(:,1))&(pol_original(:,2)==start_point(:,2)));
start_split_seg_idx=-1;
direction_sign=-1;
%first find on each segment of the polygon our split point lies
%on that segment the ratio will go from below 1 to above 1
bSetDirection=true;
for i=start_point_idx+2:pol_len    
    [polA polB]=splitPolygon([start_point;pol_original(i,:)],pol_original);
    if (isempty(polA)||isempty(polB))
        continue;
    end
    areaA=polyarea(polA(:,1),polA(:,2));
    areaB=polyarea(polB(:,1),polB(:,2));
    if((areaA==0)||(areaB==0))
        continue;
    end
   
    if (bSetDirection)
        ratio=areaA/areaB;
        direction_sign=sign(ratio-1);        
        bSetDirection=false;
        continue;
    end
    
    newratio=areaA/areaB;


    cur_direction_sign=sign(newratio-1);

    if (direction_sign~=cur_direction_sign)
        if (cur_direction_sign==0)
            %perfect split newratio==1
            end_point=pol_original(i,:);
            return;
        end
        %found it        
        start_split_seg_idx=i-1;        
        break;
    end
    ratio=newratio;
end

if (start_split_seg_idx==-1)    
    bSetDirection=true;
    for i=1:start_point_idx-2
        [polA polB]=splitPolygon([start_point;pol_original(i,:)],pol_original);        
        if (isempty(polA)||isempty(polB))
            continue;
        end
        areaA=polyarea(polA(:,1),polA(:,2));
        areaB=polyarea(polB(:,1),polB(:,2));
        if((areaA==0)||(areaB==0))
            continue;
        end
        
        if (bSetDirection)
            ratio=areaA/areaB;
            direction_sign=sign(ratio-1);            
            bSetDirection=false;
            continue;
        end


        newratio=areaA/areaB;
       
        cur_direction_sign=sign(newratio-1);
        
        if (direction_sign~=cur_direction_sign)
            if (cur_direction_sign==0)
                %perfect split newratio==1
                end_point=pol_original(i,:);
                return;
            end
            %found it
            start_split_seg_idx=i-1;
            break;
        end
        ratio=newratio;
    end
end

if (start_split_seg_idx==-1)
    %from this start point the polygon can't be split into two equal halves
    end_point=[];
    polA=[];
    polB=[];
    return;
end

start_split_seg=pol_original(start_split_seg_idx,:);
if (start_split_seg==pol_len)    
    end_split_seg=pol_original(1,:);
else
    end_split_seg=pol_original(start_split_seg_idx+1,:);
end

%now find the best position on that segment for the split point
direction_sign=sign(ratio-1);
newratio=ratio;
while (abs(newratio-1)>eps)    
    end_point=(start_split_seg+end_split_seg)./2;    
    [polA polB]=splitPolygon([start_point;end_point],pol_original);
    
    if (isempty(polA)||isempty(polB))
        %from this start point the polygon can't be split into two equal halves
        end_point=[];
        polA=[];
        polB=[];
        return;
    end
    areaA=polyarea(polA(:,1),polA(:,2));
    areaB=polyarea(polB(:,1),polB(:,2));
    if((areaA==0)||(areaB==0))
        %from this start point the polygon can't be split into two equal halves
        end_point=[];
        polA=[];
        polB=[];
        return;
    end    
      
    newratio=areaA/areaB;
    
    cur_direction_sign=sign(newratio-1);
    if (direction_sign~=cur_direction_sign)
        if (cur_direction_sign==0)
            %perfect split
            return;
        end        
        %went past it - it must be in the first half        
        end_split_seg=end_point;        
    else
        %not in this half
        ratio=newratio;
        start_split_seg=end_point;        
    end
end