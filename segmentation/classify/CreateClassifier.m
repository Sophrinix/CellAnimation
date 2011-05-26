function classifier = CreateClassifier(category, props, varargin)
  
  classifier = struct();
   
  nargs = size(varargin, 2);
  for i=1:nargs
    yes_mean_name = ['yes_' varargin{i} '_mean'];
    yes_std_name = ['yes_' varargin{i} '_std'];
    no_mean_name = ['no_' varargin{i} '_mean'];
    no_std_name = ['no_' varargin{i} '_std'];

    [rows, cols] = size(props);  

    yes_values = [];
    no_values = [];

    for j=1:rows
      if(getfield(props(j), category) == 1)
        yes_values = [yes_values getfield(props(j), varargin{i})];
      else
        no_values = [no_values getfield(props(j), varargin{i})];
      end
    end
 
    if(~isfield(classifier, 'probability'))
      classifier = setfield(classifier, 'probability', ...
		size(yes_values, 2) / rows);
    end

    classifier = setfield(classifier, yes_mean_name, mean(yes_values));
    classifier = setfield(classifier, yes_std_name, std(yes_values));
    classifier = setfield(classifier, no_mean_name, mean(no_values));
    classifier = setfield(classifier, no_std_name, std(no_values));
  end
end
