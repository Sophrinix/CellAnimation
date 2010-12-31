function [blob_clusters linkage_clusters]=getBlobClusters(blob_coord, cluster_dist)
%helper function for cluster segmentation module. figure out what's the best nr of clusters for splitting
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