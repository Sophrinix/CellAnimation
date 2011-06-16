function classifier = CreateClassifier(classification, props, varargin)

    %creates a classifier struct which can be used to classify a set of
    %objects by label "classification"
    %
    %INPUTS:
    %classification  -  the classification to be determined 
    %                   (e.g. nucleus: which of the objects can be labeled
    %                   nuclei)
    %
    %props           -  the properties of the objects to be classified
    %                   (e.g. area, eccentricity, ...)
    %
    %varargin        -  a list of the criteria (properties) by which to 
    %                   classify props (e.g. area)
    %
    %OUTPUTS:
    %classifier      -  a struct used to perform a Naive Bayesian
    %                   Classification on a set of objects with similar
    %                   properties
    %                   contains the probability that an object can be
    %                   labeled "classification" and, for each criterion:
    %                       yes mean, std: the mean and standard deviation of all
    %                                      objects that are labeled
    %                                      "classification"
    %                       no mean, std: the mean and standard deviation of all
    %                                     objects that are not labeled
    %                                     "classification"
    %

    %allocate a classifier struct
    classifier = struct();
    criteria = varargin;

    nargs = size(criteria, 2);
    for i=1:nargs

        %sub structure name to hold values relevant to this criteria
        subname = criteria{i};

        %field names for the means and standard deviations of the criteria
        %which describe those objects that are classified as "category" (yes)
        %and those that are not (no)
        yes_mean_name = 'yes_mean';
        yes_std_name = 'yes_std';
        no_mean_name = 'no_mean';
        no_std_name = 'no_std';

        %array of classification values for all objects (1 for yes, 0 for no)
        classificationvals = [props(:).(classification)];

        %indices of the objects that are labeled as "classification"
        yesindices = find(classificationvals);

        %indices of the objects that are not labeled as "classification"
        noindices = find(~classificationvals);

        %preallocate arrays to hold the values of the classification criteria
        yes_values = zeros(size(yesindices));
        no_values = zeros(size(noindices));

        %concatenate these arrays from props
        m = 1;
        n = 1;
        for j=1:size(props,1)
            if(props(j).(classification) == 1)
                yes_values(m) = props(j).(criteria{i});
                m = m + 1;
            else
                no_values(n) = props(j).(criteria{i});
                n = n + 1;
            end
        end

        %determine overall probability that an object is labeled as 
        %"classification" and store it into classifier struct
        if(~isfield(classifier, 'probability'))
            classifier.('probability') = size(yes_values, 2) / size(props,1);
        end

        %determine the means and standard deviations of criteria based on
        %classification
        classifier.(subname).(yes_mean_name) = mean(yes_values);
        classifier.(subname).(yes_std_name) = std(yes_values);
        classifier.(subname).(no_mean_name) = mean(no_values);
        classifier.(subname).(no_std_name) = std(no_values);
    end
  
end
