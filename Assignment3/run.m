Niters = 10;
Nvacs = 20;
pvacs = linspace(0, 1, Nvacs);
total_costs = zeros(Nvacs, 1);
iters = zeros(Niters, 1);
uncs = zeros(Nvacs, 1);
densities = [0.25, 0.35, 0.5];
min_costs = zeros(3, 1);
vacc_frac = zeros(3, 1);
figure(1);
for i_density = 1:length(densities)
    display('Computing Total Cost for density: ' + string(densities(i_density))); 
    for i_pvac = 1:length(pvacs)
        for i_iter = 1:Niters
            [nalive, V, M, ndeaths, iter, total_cost] = zombies(pvacs(i_pvac),...
                                                        densities(i_density));
            iters(i_iter) = total_cost;
        end
        uncs(i_pvac) = std(iters);
        total_costs(i_pvac) = mean(iters);
        iters = 0;
    end
    [min_costs(i_density), vacc_frac(i_density)] = min(total_costs);
    plot(pvacs, total_costs);
    errorbar(pvacs, total_costs, uncs);
    xlabel('Fraction of vaccinated population');
    ylabel('Total Cost in $');
    title('Total Cost vs. V / M');
    %legend(string(densities(i_density)));
    legendInfo{i_density} = ['Density = ' num2str(densities(i_density))]; 
    hold on;
end
vacc_frac = 0.1 * vacc_frac;
legend(legendInfo);
%legend('Density: 0.25', 'Density: 0.35', 'Density: 0.5');
hold off;
