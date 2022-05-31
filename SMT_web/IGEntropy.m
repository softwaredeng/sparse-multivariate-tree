
% entropy

function [e]=IGEntropy(set)
    %uni = unique(set);
    %N = size(set,1);
    %e0 = 0;
    %for i = uni'
    %    e0 = e0 - length(find(set==i))/N*log2(length(find(set==i))/N);        
    %end
    %e = e0;
    
    uni = unique(set);
    N = size(set,1);
    probSet=[];
    for i = uni'
        probSet = [probSet length(find(set==i))/N];        
    end
    e = -sum(probSet .* log2(probSet));
    debug=1;
end

%H = -sum(probSet .* log2(probSet));   