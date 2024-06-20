%============================= 
% select the global leader, gbest
%============================= 
function leader = SelectLeader(rep)
    beta = 0.5;
    if rand<0.5
        seq = WSIS(rep);
        leader = rep(seq(1));
    else        
        % gird-based method
        GI = [rep.GridIndex];
        OC = unique(GI);
        N = zeros(size(OC));

        for k = 1:numel(OC)
            N(k) = numel(find(GI == OC(k)));  
        end

        % Selection Probabilities
        P = exp(-beta*N);  
        P = P/sum(P);

        sci = RouletteWheelSelection(P); 
        sc = OC(sci); 
        SCM = find(GI == sc);  
        smi = randi([1 numel(SCM)]);  
        sm = SCM(smi);  
        leader = rep(sm); 
    end
end