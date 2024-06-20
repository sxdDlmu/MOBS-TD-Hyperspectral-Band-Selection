function result = MSR(bandSets, detector_Name,img,W,H,d)
setNo = length(bandSets);
map = reshape(detector(img, d',detector_Name),W,H);
[p,q] = find(map==max(max(map)));
p = p(1);
q = q(1);
pos = sub2ind(size(map),[p p-1 p+1 p p],[q q q q-1 q+1]);
K = round(0.05*W*H);
sr = zeros(setNo,1);

for i = 1:setNo
    band = bandSets{i};
    output = detector(img(:,band), d(band)',detector_Name);
    m = mean(output(pos));
    output(pos) = [];
    sm = sort(output(:),'descend');
    sr(i) = m/mean(sm(1:K));
end

msr = (sr==max(sr));
result = bandSets{msr};
end