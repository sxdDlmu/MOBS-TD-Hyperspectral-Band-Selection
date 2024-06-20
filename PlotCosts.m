function PlotCosts(pop, rep)
    
    pop_costs = [pop.Cost];
    scatter3(pop_costs(1, :), pop_costs(2, :),pop_costs(3, :), 'ko');
    hold on;
    
    rep_costs = [rep.Cost];
    scatter3(rep_costs(1, :), rep_costs(2, :),rep_costs(3, :), 'r*');
    
    xlabel('Entropy Objective');
    ylabel('JSS Objective');
    zlabel('TBS Objective');
    
    grid on;
    
    hold off;

end