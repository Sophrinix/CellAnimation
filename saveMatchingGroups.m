function output_args=saveMatchingGroups(input_args)
%module to save matching group list
%Input Structure Members
%MatchingGroups - Matrix containing the matching groups.
%MatchingGroupsFileName - Path to the location where the matching groups
%data will be saved
%Output Structure Members
%None
matching_groups=input_args.MatchingGroups.Value;
save(input_args.MatchingGroupsFileName.Value,'matching_groups');
output_args=[];

%end saveMatchingGroups
end