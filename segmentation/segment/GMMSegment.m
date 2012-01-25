function objSet = GMMSegment(im, OS, trainingset)

	objSet = OS;

	p = [];
	for(i=1:size(trainingset,2))
		p2 = [p; trainingset(i).props];
		clear p;
		p = p2;
		clear p2;
	end
	nuclei = p(find([p(:).nucleus]));
	avgArea = mean([nuclei.Area])
	stdArea = std([nuclei.Area])

	for(n=1:size(objSet.props,1))
		
		n
		
		for(i=1:size(objSet.props(n).PixelList,1))
			objSet.labels(	objSet.props(n).PixelList(i,2), ...
							objSet.props(n).PixelList(i,1)) = 0;
		end
		
		gmmIm = zeros(size(im));
		i = im2double(im);

		pl = objSet.props(n).PixelList;
		points = [];
		for(pt = 1:size(pl,1))
			numPts = i(pl(pt,2), pl(pt,1)) * 100 * 20;
			for(j=1:numPts)
				pts2 = [points; pl(pt,2), pl(pt,1)];
				clear points;
				points = pts2;
				clear pts2;
			end
		end

		maxlklhd = -Inf;
		finalNum = 0;

		for(numObj=1:10)
				
			options = statset('Display', 'off');
			gm = gmdistribution.fit(points, numObj,'Options',options);
			idx = cluster(gm, points);

			im2 = zeros(size(im));
			for(obj=1:numObj)
				for(pt=1:size(idx))
					if(idx(pt) == obj)
						im2(points(pt,1), points(pt,2)) = obj;
					end
				end
			end
			im2 = imfill(im2, 'holes');
			likelihood = 0;
			props = regionprops(im2, 'Area');
			for(obj=1:size(props,1))
				likelihood = likelihood + ...
								log(normpdf(props(obj).Area,...
											avgArea,...
											stdArea));
			end

			likelihood = likelihood - (obj * log(obj));
			if(likelihood > maxlklhd)
				maxlklhd = likelihood;
				clear gmmIm;
				gmmIm = im2;
				finalNum = numObj;
			end
			clear im2;
		end

		%place division between newly segmented objects
		%gmmIm is image with final segmentation
		for(obj=1:finalNum)
			tempIm = gmmIm == obj;
			bounds = bwboundaries(tempIm);
			for(i=1:size(bounds{1},1))
				gmmIm(bounds{1}(i,1), bounds{1}(i,2)) = 0;
			end
			clear tempIm;
		end	

		%insert new objects into labels
		objSet.labels = objSet.labels | gmmIm;
		clear gmmIm;
		
	end
	%relabel and find new object properties
	objSet.labels = bwlabel(objSet.labels);
	objSet.props = regionprops(logical(objSet.labels), 	...
								'Area',					...
								'Centroid', 			...
								'MajorAxisLength', 		...
								'MinorAxisLength',		...
								'Eccentricity',			...
								'ConvexArea',			...
								'FilledArea',			...
								'EulerNumber',			...
								'EquivDiameter',		...
								'Solidity',				...
								'Perimeter',			...
								'PixelIdxList',			...
								'PixelList',			...
								'BoundingBox');
	
	%compute intensities, store labels, determine edge condition,
	%first pass classification
	bounds = bwboundaries(objSet.labels);
	i = imtophat(im2double(im), strel('disk', 50));
	
	for(obj=1:size(objSet.props, 1))
		objSet.props(obj).label = obj;
		objSet.props(obj).Intensity = ...
			sum(i(objSet.props(obj).PixelIdxList));
		objSet.props(obj).bound = bounds{obj};
		objSet.props(obj).edge = 0;
		if(find(objSet.props(obj).PixelList(:,1) == 1))
			objSet.props(obj).edge = 1;
		end
		if(find(objSet.props(obj).PixelList(:,2) == 1))
			objSet.props(obj).edge = 1;
		end
		if(find(objSet.props(obj).PixelList(:,1) == size(i,2)))
			objSet.props(obj).edge = 1;
		end
		if(find(objSet.props(obj).PixelList(:,2) == size(i,1)))
			objSet.props(obj).edge = 1;
		end
		objSet.props = ClassifyFirstPass(objSet.props);
	end
	

end
