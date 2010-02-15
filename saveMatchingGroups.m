function output_args=saveMatchingGroups(input_args)

matching_groups=input_args.MatchingGroups.Value;
save(input_args.MatchingGroupsFileName.Value,'matching_groups');
output_args=[];

%end saveMatchingGroups
end