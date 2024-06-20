function seq = WSIS(rep)
M = [rep.Cost]';
[n,~] = size(M);
X = M./repmat(sum(M.*M).^0.5,n,1);

[w,~] = dynamicWeright(X);
PIS = min(X);
NIS = max(X);
dominance = zeros(1,n);
for i = 1:n
	dp=sqrt(sum(w.*((X(i,:)-PIS).^2)));
    dn=sqrt(sum(w.*((X(i,:)-NIS).^2)));
    dominance(i) = dn/(dp+dn);
end
[~,seq] = sort(dominance,'descend');
end


%%
function [w,cr] = dynamicWeright(P)
[n,m] = size(P);
en = zeros(1,m);
P = P/sum(P(:));
for j = 1:m
    p = P(:,j);
    en(j) = -sum(p.*log(p+eps))/(log(n));
end
R = abs(corrcoef(P));
cc = m - sum(R,2);
cr = (1-en).*cc';
w = zeros(1,m);
for i = 1:m
    w(i) = cr(i)/sum(cr(:));
end
end