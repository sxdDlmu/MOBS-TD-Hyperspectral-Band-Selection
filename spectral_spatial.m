function jointD = spectral_spatial(img)
% img:L*N
[~,no_bands] = size(img);
spectral_D = get_D(img);
spatial_D = zeros(no_bands);
k_para1 = repmat(((1/no_bands)*sum(spectral_D,2)),1,no_bands);
f1 = exp((-spectral_D.^2)./(2*k_para1.^2));
for i = 1:no_bands
    for j = 1:no_bands
        spatial_D(i,j) = abs(i-j);
    end
end
k_para2 = repmat(((1/no_bands)*sum(spatial_D,2)),1,no_bands);
f2 = exp((-spatial_D.^2)./(2*k_para2.^2));
jointD = f1.*f2;
end

%% func_get_D
function  S  = get_D(X)
    S = sqrt(L2_distance(X, X));
end

function d = L2_distance(a,b)
    if (size(a,1) == 1)
      a = [a; zeros(1,size(a,2))]; 
      b = [b; zeros(1,size(b,2))]; 
    end

    aa=sum(a.*a); bb=sum(b.*b); ab=a'*b; 
    d = repmat(aa',[1 size(bb,2)]) + repmat(bb,[size(aa,2) 1]) - 2*ab;

    d = real(d);
    d = max(d,0);
end