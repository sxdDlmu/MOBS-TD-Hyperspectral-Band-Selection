clc;clear;close all;
%{ 
    Reference: X. Sun, P. Lin, X. Shang, H. Pang and X. Fu, "MOBS-TD: Multiobjective 
               Band Selection With Ideal Solution Optimization Strategy for Hyperspectral 
               Target Detection,¡± IEEE Journal of Selected Topics in Applied Earth 
               Observations and Remote Sensing (IEEE JSTARS), DOI: 10.1109/JSTARS.2024.3402381.
%}
%% MO model for BS
CostFunction = @(x,h,d,m,t) BS_model(x,h,d,m,t);
nVar = 5;% number of bands

%% Parameters
MaxT = 50;            % Maximum number of iterations
nPop = 50;            % population size
nRep = 20;            % Candidate solution set size

w = 0.5;              % inertia factor
wdamp = 0.99;         % Attenuation factor of inertia
c1 = 1;               % Global learning factor
c2 = 1;               % Individual learning factor

nGrid = 4;            % Number of grids per dimension (nGrid+1)
mu = 0.1;             % mutation  probability regulator
maxrate = 0.2;        % Evolutionary speed control factor

%% load data
load hydice_urban_162.mat;
img_src = data;
img_gt = map;

%% pre-processing
[W, H, L]=size(img_src);
img_src = normalized(img_src);
img = reshape(img_src, W * H, L);
d = get_target(img,img_gt);

En = Entrop(img); 
D = spectral_spatial(img);

%% Initialization
VarSize = [1 nVar];                            % size of subset
VarMin = 1;                                    
VarMax = L;                                    % The upper and lower limits of the index
empty_particle.Position = [];                  % position vector
empty_particle.Velocity = [];                  % velocity vector
empty_particle.Cost = [];                      % fitness vector
empty_particle.Best.Position = [];             % Individual best position vector
empty_particle.Best.Cost = [];                 % Individual best fitness vector
empty_particle.IsDominated = [];               % dominance state
empty_particle.GridIndex = [];                 % Grid index
empty_particle.GridSubIndex = [];              % Grid subindex
pop = repmat(empty_particle, nPop, 1);         % population 

% 1st-generation population
for i = 1:nPop 
    pop(i).Position = sort(randperm(VarMax, nVar));
    pop(i).Velocity = zeros(VarSize);
    pop(i).Cost = CostFunction(pop(i).Position, En, D, img', d);

    pop(i).Best.Position = pop(i).Position;
    pop(i).Best.Cost = pop(i).Cost;
end

% Determine Domination
pop = DetermineDomination(pop);
rep = pop(~[pop.IsDominated]);

% grid
rep = GridIndex(rep, nGrid);


%% Main Loop
for it = 1:MaxT
    
    for i = 1:nPop
        % select the global leader
        leader = SelectLeader(rep);
        % Calculating speed
        pop(i).Velocity = w*pop(i).Velocity ...
            +c1*rand(VarSize).*(pop(i).Best.Position-pop(i).Position) ...
            +c2*rand(VarSize).*(leader.Position-pop(i).Position);
        % limitation
        pop(i).Velocity = max(pop(i).Velocity, (-1)*maxrate*VarMax);
        pop(i).Velocity = min(pop(i).Velocity, maxrate*VarMax);
        pop(i).Velocity = fix(pop(i).Velocity);
        % Update Location
        pop(i).Position = pop(i).Position + pop(i).Velocity;
        % regularization
        pop(i).Position = limitPositionVariables(pop(i).Position, VarMin, VarMax);
        % Update fitness
        pop(i).Cost = CostFunction(pop(i).Position, En, D, img', d);
        
        %% mutation
        pm = (1-(it-1)/(MaxT-1))^(1/mu);
        if rand<pm
            NewSol.Position = Mutate(pop(i).Position, pm, VarMin, VarMax);
            NewSol.Position = limitPositionVariables(NewSol.Position,VarMin,VarMax);
            NewSol.Cost = CostFunction(NewSol.Position, En, D, img', d);
            pop(i) = RoD(NewSol,pop(i));
        end
    end

    %% Update rep set
    pop = DetermineDomination(pop);
    rep = [rep
         pop(~[pop.IsDominated])];
    rep = DetermineDomination(rep);    
    rep = rep(~[rep.IsDominated]);
    
    %% crossover in rep set
    pc = (1-(it-1)/(MaxT-1))^(1/mu);
    num_rep = numel(rep);
    if rand<pc
        nCrossover=2*floor(pc*num_rep/2);
        popc=repmat(empty_particle,nCrossover/2,1);% childs
        cross_index = reshape(randperm(num_rep,nCrossover),nCrossover/2,2);
        for k=1:nCrossover/2
            p1=rep(cross_index(k,1));
            p2=rep(cross_index(k,2));
            popc(k).Position = Crossover(p1.Position,p2.Position,En);% Crossover
            popc(k).Velocity = ((p1.Velocity + p2.Velocity)*sqrt(dot(p1.Velocity,p1.Velocity))) ...
                /((sqrt(dot(p1.Velocity,p1.Velocity))+sqrt(dot(p2.Velocity,p2.Velocity)))+inf);
            popc(k).Velocity = max(popc(k).Velocity, (-1)*maxrate*VarMax);
            popc(k).Velocity = min(popc(k).Velocity, maxrate*VarMax);
            popc(k).Velocity = fix(popc(k).Velocity);
            popc(k).Cost=CostFunction(popc(k).Position, En, D, img', d);
        end
        rep = [rep
         popc];
        rep = DetermineDomination(rep);
        rep = rep(~[rep.IsDominated]);
    end
    
    % Update Grid
    rep = GridIndex(rep, nGrid);

    % Check if rep set is full
    if numel(rep)>nRep
        Extra = numel(rep)-nRep;
        seq = WSIS(rep);
        for e = 1:Extra
            rep = DeleteRepMemebr(rep, seq);
        end        
    else
        Extra = 0;
    end

    % Plot Costs
    figure(1);
    PlotCosts(pop, rep);
    pause(0.01);
    box on; 
    
    % Show Iteration Information
    disp(['Iteration ' num2str(it) ': Number of Rep Members = ' num2str(numel(rep)) ]);
    % Damping Inertia Weight
    w = w*wdamp;
    
end

%% MSR
repSet = {rep.Position};
detector_Name = 'CEM';
fSolution = MSR(repSet,detector_Name,img,W,H,d);

%%
detectmap = reshape(detector(img(:,fSolution), d(fSolution)',detector_Name),W,H);
figure,imagesc(detectmap);
[auc] = auc(detectmap,img_gt);
disp(['optimal band subset : (' num2str(fSolution),'), detection rate : ' num2str(auc)]);

