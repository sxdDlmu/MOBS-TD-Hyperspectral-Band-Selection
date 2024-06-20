function x = limitPositionVariables(x, VarMin, VarMax)
    n = numel(x);
    lb = linspace(VarMin,VarMin,n);
    ub = linspace(VarMax,VarMax,n);
    
    lbExceed = x < lb;
    ubExceed = x > ub;
    
    x(lbExceed) = lb(lbExceed) - x(lbExceed);
    x(ubExceed) = 2*ub(ubExceed) - x(ubExceed);
    
    x = keepUnique(x,VarMax);
end

function out = keepUnique(x,VarMax)
    % keep unique
    out = x;
    n = numel(out);
    while n ~= numel(unique(out))
        out = [unique(out),randperm(VarMax,n-numel(unique(out)))];
    end
    out = sort(out);
end