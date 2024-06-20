function pop = RoD(p1,p2)
    % Determine the dominance relationship between the old and new individuals, and determine whether to renew or discard.
    if Dominates(p1, p2)
        p2.Position = p1.Position;
        p2.Cost = p1.Cost;
    
    elseif Dominates(p2, p1)
        % Do Nothing
    
    else
        if rand<0.5
            p2.Position = p1.Position;
            p2.Cost = p1.Cost;
        end
    end
    %
    if Dominates(p2, p2.Best)
        p2.Best.Position = p2.Position;
        p2.Best.Cost = p2.Cost;
    
    elseif Dominates(p2.Best, p2)
        % Do Nothing     
    else
        if rand<0.5 
            p2.Best.Position = p2.Position;
            p2.Best.Cost = p2.Cost;
        end
    end 
    pop = p2;
end