function rep = DeleteRepMemebr(rep, seq)

    GI = [rep.GridIndex];
    OC = unique(GI); 
    N = zeros(size(OC));
    for k = 1:numel(OC)
        N(k) = numel(find(GI == OC(k)));
    end
    gamma = 2;
    P = exp(gamma*N);
    P = P/sum(P);
    sci = RouletteWheelSelection(P);
    sc = OC(sci);
    SCM = find(GI == sc);
    
    I = zeros(size(SCM));
    for k = 1:numel(SCM)
        I(k) = find(seq == SCM(k));
    end
    [~,smi] = max(I);
    
    sm = SCM(smi);
    
    rep(sm) = [];

end