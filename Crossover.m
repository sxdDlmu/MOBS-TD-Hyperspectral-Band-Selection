%% Crossover
function [y]=Crossover(x1,x2,H)
nVar = numel(x1);
AB = setdiff(x1,x2);
BA = setdiff(x2,x1);
h = min(numel(AB),numel(BA));
while h==nVar
    h = h-1;
end
y1 = sort([BA(randperm(numel(BA),h)) x1(randperm(nVar,nVar-h))]);
y2 = sort([AB(randperm(numel(AB),h)) x2(randperm(nVar,nVar-h))]);

H1 = sum(1./H(y1));
H2 = sum(1./H(y2));
if H1>=H2
    y = y2;
else
    y = y1;
end

end