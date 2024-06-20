function [value] = normalized(map)
% normalized
map = double(map);
maxx=max(map(:));
minn=min(map(:));
value=(map-minn)/(maxx-minn);     
end