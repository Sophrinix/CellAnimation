function classified_props = NaiveClassify(classifier, props, category)

  classified_props = props;
  names = fieldnames(classifier);
  num_fields = size(names);

  [rows, cols] = size(classified_props);
  for j=1:rows

    yes_posterior = getfield(classifier, names{1});
    no_posterior = 1 - getfield(classifier, names{1});

    i = 2;
    while i < (num_fields + 1)
      value = getfield(classified_props(j), getfield(classifier, names{i}));
    
      %calculate probability of value given category
      yes_mean = getfield(classifier, names{i+1});
      yes_std = getfield(classifier, names{i+2});
      yes_prob = normpdf(value, yes_mean, yes_std);
      yes_posterior = yes_posterior * yes_prob;

      %calculate probability of value given not category
      no_mean = getfield(classifier, names{i+3});
      no_std = getfield(classifier, names{i+4});
      no_prob = normpdf(value, no_mean, no_std);
      no_posterior = no_posterior * no_prob;
    
      %advance i
      i = i + 5;
    end

    if(yes_posterior > no_posterior)
      classified_props(j) = setfield(classified_props(j), category, 1);
    else
      classified_props(j) = setfield(classified_props(j), category, 0);
    end
  end
end
