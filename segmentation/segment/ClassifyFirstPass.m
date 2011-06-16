function s = ClassifyFirstPass(properties)

    s = properties;

    % Naive Classification
    for obj=1:size(s,1)
        s(obj).debris  = 0;
        s(obj).nucleus = 0;
        s(obj).over    = 0;
        s(obj).under   = 0;
        s(obj).premitotic = 0;
        s(obj).postmitotic=0;
        s(obj).apoptotic=0;
        s(obj).newborn = 0;

        if s(obj).Area < 190
            s(obj).debris = 1;
        elseif s(obj).Area < 300
            s(obj).newborn = 1;
            s(obj).nucleus = 1;
        elseif s(obj).Area < 820
            s(obj).nucleus = 1;
        else
            s(obj).under = 1;
        end
    end
    
end