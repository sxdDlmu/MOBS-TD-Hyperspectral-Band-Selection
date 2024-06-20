function rep = GridIndex(rep, nGrid)
Grid = CreateGrid(rep, nGrid); 
    for i = 1:numel(rep)
        rep(i) = FindGridIndex(rep(i), Grid);
    end
end

%% func_CreateGrid
function Grid = CreateGrid(pop, nGrid)
    alpha = 0.1;
    c = [pop.Cost];
   
    cmin = min(c, [], 2); 
    cmax = max(c, [], 2); 
    
    dc = cmax-cmin;          
    cmin = cmin-alpha*dc;
    cmax = cmax+alpha*dc;
    
    nObj = size(c, 1);
    
    empty_grid.LB = [];
    empty_grid.UB = [];
    Grid = repmat(empty_grid, nObj, 1);
    
    for j = 1:nObj
        
        cj = linspace(cmin(j), cmax(j), nGrid+1);
        
        Grid(j).LB = [-inf cj];
        Grid(j).UB = [cj +inf];
        
    end

end

%% func_FindGridIndex
function particle = FindGridIndex(particle, Grid)

    nObj = numel(particle.Cost);
    
    nGrid = numel(Grid(1).LB);
    
    particle.GridSubIndex = zeros(1, nObj); 
    
    for j = 1:nObj
        
        particle.GridSubIndex(j) = ...
            find(particle.Cost(j)<Grid(j).UB, 1, 'first');
    end

    particle.GridIndex = particle.GridSubIndex(1);
    for j = 2:nObj
        particle.GridIndex = particle.GridIndex-1;
        particle.GridIndex = nGrid*particle.GridIndex;
        particle.GridIndex = particle.GridIndex+particle.GridSubIndex(j);
    end
    
end