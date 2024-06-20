%============================= 
% fitness function 
%============================= 
function z = BS_model(x,H,D,M,target)
    
    n = numel(x);
    d1 = 0;
    for i = 1: n  
        d1 = d1 + H(x(i));
    end
    f1 = n/d1;
    
    d = D(x, x);
    d2 = nonzeros(triu(d,1));
    f2 = sum(d2)/((n*(n-1))/2);
    
    f3 = TBS(M(x,:),target(x));
    
    z = [f1;f2;f3];
end

%% func_TBS
function tbs = TBS(M,d)
[~,N] = size(M);
R_hat = (M*M.')/N;
tmp = d/R_hat*d';
tbs = 1./tmp;
end
