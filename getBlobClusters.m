function [blob_clusters linkage_clusters]=getBlobClusters(blob_coord, cluster_dist)
%figure out what's the best nr of clusters for splitting
max_clusters=20;
blob_length=length(blob_coord);
if (length(blob_coord)<=max_clusters)
    blob_clusters=1;
    linkage_clusters=ones(blob_length,1);
    return;
end
% RMSSTD=zeros(max_clusters,1);
% nr_points=length(blob_coord);

blob_dist=pdist(blob_coord);
%tested all linkage params - this works best
blob_linkage=linkage(blob_dist,'average');
% linkage_clusters=cluster(blob_linkage,'criterion','distance','cutoff',12); %10x kam cells
linkage_clusters=cluster(blob_linkage,'criterion','distance','cutoff',cluster_dist); %20x ht1080 cells
max_clusters=max(linkage_clusters(:));
blob_clusters=max_clusters;
return;


RMSSTD_stop=0;
for i=1:max_clusters
    RMSSTD_stop=RMSSTD_stop-1;
    nr_clusters=i;
    [test_idx test_cnt]=kmeans(blob_coord,nr_clusters);
    SS=0;
    N=0;
    E=zeros(i,1);
    for j=1:i
        cur_coord=blob_coord(test_idx==j,:);        
        cur_points_nr=length(cur_coord);
        %sum of squares within cluster j
        diff_1=cur_coord(:,1)-test_cnt(j,1);
        diff_2=cur_coord(:,2)-test_cnt(j,2);
        SSW_1=sum(diff_1.^2);
        SSW_2=sum(diff_2.^2);
        SSW=SS+SSW_1+SSW_2;
        N=N+2*cur_points_nr;
        
        %distance or norm of points in cluster from centroid
        cent_norm=hypot(diff_1,diff_2);
        %Ek from PBM index in this case Ej
        E(j)=sum(cent_norm);        
    end
    
    %EK from PBM index 
    EK=sum(E);        
    %DK from PBM index
    if (i==1)
        E1=EK;
        DK=0;
    else
        %max distance bet centroids
        DK=max(pdist(test_cnt));
    end
    %original PBM is squared - no reason here since all values are positive
    PBM(i)=((1/i)*(E1/EK)*DK);
    
    %use RMSSTD (root-mean-square standard deviation) - (Sharma, 1996) also see (Halkidi et al., 2001)    
    RMSSTD(i)=sqrt(SSW/N);

    if (i==1)
        if ((RMSSTD(i)<5)&&(RMSSTD_stop<0))
            RMSSTD_clusters=1;
            RMSSTD_stop=2;            
        end
    else
        if ((RMSSTD(i)<2.7)&&(RMSSTD_stop<0))
            RMSSTD_clusters=i;
            RMSSTD_stop=2;
        end
    end
    if (RMSSTD_stop==0)
        break;
    end
end

[dummy PBM_clusters]=max(PBM);

% showmaxfigure(5),plot(RMSSTD,'-.or')
blob_clusters=median([linkage_clusters RMSSTD_clusters PBM_clusters]);

%end getBlobClusters
end