function [opts] = Parameter(fusedPenalty)
%fused lasso para
    opts=[];
    opts.init=2;        % starting from a zero point
    opts.tFlag=5;       % run .maxIter iterations
    opts.maxIter=500;   % maximum number of iterations
    opts.nFlag=0;       % 0:without normalization 
    opts.rFlag=1;       % the input parameter 'rho' is a ratio in (0, 1)
    opts.fusedPenalty=fusedPenalty;
    % line search
    opts.lFlag=0;
end