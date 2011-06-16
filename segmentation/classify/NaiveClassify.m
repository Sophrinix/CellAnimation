function classified_props = NaiveClassify(classification, props, classifier)

    %
    %classifies a set of objects by the label "classification" using a provided
    %classifier
    % 
    %INPUTS:
    %classification    -  the classification to be determined 
    %                     (e.g. nucleus: which of the objects can be labeled
    %                     nuclei)
    %
    %props             -  the properties of the objects to be classified
    %                     (e.g. area, eccentricity, ...)
    %
    %classifier        -  struct created by function CreateClassifier, 
    %                     used to perform a Naive Bayesian Classification on a set
    %                     of objects with similar properties
    %                     contains the probability that an object can be
    %                     labeled "classification" and, for each criterion:
    %                         yes mean, std: the mean and standard deviation of all
    %                                        objects that are labeled
    %                                        "classification"
    %                         no mean, std: the mean and standard deviation of all
    %                                       objects that are not labeled
    %                                       "classification"
    %
    %OUTPUTS:
    %classified_props  -  properties of the objects (from props) after they
    %                     have been classified according to classification
    %                     using classified_props
    %

    %copy props into output - props is unchanged during classification
    classified_props = props;

    names = fieldnames(classifier);
    num_fields = size(names,1);


    for(j=1:size(classified_props,1))
        %
        yes_posterior = classifier.('probability');
        no_posterior = 1 - classifier.('probability');

        for(i=2:num_fields)
            value = classified_props(j).(names{i});

            %calculate probability of value given category
            yes_mean = classifier.(names{i}).('yes_mean');
            yes_std = classifier.(names{i}).('yes_std');
            yes_prob = normpdf(value, yes_mean, yes_std);
            yes_posterior = yes_posterior * yes_prob;

            %calculate probability of value given not category
            no_mean = classifier.(names{i}).('no_mean');
            no_std = classifier.(names{i}).('no_std');
            no_prob = normpdf(value, no_mean, no_std);
            no_posterior = no_posterior * no_prob;

        end

        if(yes_posterior > no_posterior)
            classified_props(j).(classification) = 1;
        else
            classified_props(j).(classification) = 0;
        end

    end

end
