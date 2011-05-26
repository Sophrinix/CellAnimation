function classified_properties = CompleteClassify(properties)

  classification_names = {'debris', 'nucleus', 'over', 'under', 'premitotic', 'postmitotic'}; %, 'apoptotic'};

  classified_properties = properties;

  for i=1:size(classification_names)

    classifier = CreateClassifier(classification_names{1,i}, properties, ...
          'Area',            'Eccentricity',  'MajorAxisLength', ...
          'MinorAxisLength', 'ConvexArea',    'FilledArea', ...
          'EquivDiameter',   'Solidity',      'Perimeter');

    NaiveClassify(classifier, classified_properties, classification_names{1,i});

  end 

end
