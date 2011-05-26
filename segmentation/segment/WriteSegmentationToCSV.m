function WriteSegmentationToCSV(properties, fileName)
	
	%create csv file for output
	fileID = fopen(fileName, 'w');

	props = [];	
	for i=1:size(properties)	
		temp = rmfield(properties(i,1), 'PixelList');
		temp = rmfield(temp, 'PixelIdxList');
		centroid = temp.Centroid;
		temp = rmfield(temp, 'Centroid');
		temp.X = centroid(1);
		temp.Y = centroid(2);
		props = [props temp];
	end

	topEdge = 0;
	bottomEdge = 1024;
	leftEdge = 0; 
	rightEdge = 672;

	%compute the cliassifications - binary values including:
	for i=1:numel(props)
		props(1,i).IsTopEdge = 0;
		props(1,i).IsBottomEdge = 0;
		props(1,i).IsLeftEdge = 0;
		props(1,i).IsRightEdge = 0;
		props(1,i).IsNucleus = 0;
		props(1,i).IsOverSeg = 0;
		props(1,i).IsUnderSeg = 0;
		%Edge/Not-Edge: whether or not an object is on the edge of the 
		%image
		if (props(1,i).Y - topEdge < 20)
			props(1,i).IsTopEdge = 1;
		end
		
		if (bottomEdge - props(1,i).Y < 20)
			props(1,i).IsBottomEdge = 1;
		end
		
		if (props(1,i).X - leftEdge < 20)
			props(1,i).IsLeftEdge = 1;
		end
		
		if (rightEdge - props(1,i).X < 20)
			props(1,i).IsRightEdge = 1;
		end

		%Nucleus/Not-Nucleus: whether or not the object is a nucleus
		if (props(1,i).Area > 5)
			props(1,i).IsNucleus = 1;
		end	
		%Over-Segmented/Not-Over-Segmented: whether or not the object is
		%Over-Segmented
		if (props(1,i).Area < 5)
			props(1,i).IsOverSeg = 1;
		end	

		%Under-Segmented/Not-Under-Segmented: whether or not the object
		%is Under-Segmented
		if (props(1,i).Area > 750)
			props(1,i).IsUnderSeg = 1;
		end	
	end
	
	%print properties and classifications of each object to csv file, aligning with correct headers
	names = fieldnames(props(1,1));
	for i=1:size(names)
		fprintf(fileID, '%s, ', names{i});
	end
	fprintf(fileID, '\n');	

	for i=1:numel(props)
		for j=1:size(names)	
			fprintf(fileID, '%d, ', ...
				getfield(props(1,i), names{j}));
		end
		fprintf(fileID, '\n');
	end	
	fclose(fileID);	
end
