function [nalive, V, M, ndeaths, iter, total_cost] = zombie_apocalypse(pvac, density)

tic 
%% -----------------
%% Definitions
%% -----------------

N = 128;        % grid size: N*N
T = 15;         % hours remaining before death
Nitermax = 5000;    % max iterations

%density = 0.25;  % density of population
prob = 0.66;     % probability of infection
%pvac = 0.0;     % fraction of walkers who are immune to the zombie virus

M = floor(density*N^2);     % number of walkers
V = floor(pvac*M);          % number of vaccinated people

plot_flag = 1;

%% -----------------
%% Initialization
%% -----------------

infect = zeros(M,1);    
% infect takes the values: 0 (healthy); 1 (zombie); 2 (immunized); 3 (dead)
hours = T*ones(M,1);     % hours gets initialized to T upon infection and 
% decreases by 1 every iteration until hours==0, which implies death

% Initialize the walkers' starting positions randomly
x = randi(N,M,1);
y = randi(N,M,1);

% Vaccination campaign for V walkers
infect(randperm(M,V)) = 2;   % Randomly vaccinate V number of dudes

% Infect a random walker
z = randi(M); infect(z) = 1;   

ndeaths = 0;    % no deaths initially
nzombies = 100;   % first infected walker ???????????
iter = 1;       % about to start first iteration


%% -----------------
%% Random walk
%% -----------------

while nzombies > 0 && iter < Nitermax
    
    % Count infection countdowns and deaths before taking a random step
    hours(infect==1) = hours(infect==1) - 1;
    
    % Does the zombie die?
    %infect(hours==0) = 3;  changed to   
    infect(hours==0) = 2; 
    ndeaths = sum(infect==3);
    
    
    % Random walk
    
    rand_walk = rand(M,1);
    walk_x = rand_walk < 0.5;
    walk_y = rand_walk >= 0.5;
    
        % Walk in the x direction
        deltax = 2*floor(2*rand(size(x))) - 1;  % random directions
        deltax(infect==3) = 0;  % the dead don't move
        deltax(walk_y) = 0;     % don't walk in y!
        xold = x;
        xnew = x + deltax; 
        % Periodic boundary conditions
        xnew(xnew==0) = N;
        xnew(xnew==N+1) = 1;
        x = xnew;
        
        % Walk in the y direction
        deltay = 2*floor(2*rand(size(x))) - 1;  % random directions
        deltay(infect==3) = 0;  % the dead don't move
        deltay(walk_x) = 0;     % don't walk in x!
        yold = y;
        ynew = y + deltay;
        % Periodic boundary conditions
        ynew(ynew==0) = N;
        ynew(ynew==N+1) = 1;
        y = ynew;
    
    % Contamination step 
    H_coord = zeros(M,2);     % because we need to keep track of positions
    pos_H = infect==0;
    H_coord(pos_H,:) = [x(pos_H), y(pos_H)];  % positions of healthy people
    
    pos_I = infect==1;
    I_coord = [x(pos_I), y(pos_I); xold(pos_I), yold(pos_I)];  
    % positions of zombies, before and after random step
    
    indH = find( ismember(H_coord,I_coord,'rows') == 1);
    % indH are the "j-positions" of the healty walkers who are
    % getting infected (infect(j) = 0 -> 1 for j in indH)
    
    infection_status = (rand(size(indH)) < prob); % true = turns into zombie
    infect(indH) = infection_status;
    nzombies = sum(infect==1);
    
    % Increment
    iter = iter + 1;
    if iter == Nitermax
        display('Maximum number of iterations reached; increase Nitermax')
    end
    
    %{
    % Visualization in 2D
    if plot_flag == 1
        colorgrid = 4*ones(N);
        map = [ 0, 1, 0;    % healthy = green
                1, 0, 0;    % zombies = red
                0, 0, 1;    % immunized = blue
                0, 0, 0;    % dead = black
                1, 1, 1];   % empty = white
        for i=1:M
            colorgrid(x(i),y(i)) = infect(i);
        end
        g = pcolor(colorgrid); colormap(map); axis square; 
        set(g,'LineStyle','none'); 
        set(gca,'XDir','normal')
        drawnow
    end
    %}

end
Nimmunized = sum(infect==2);
total_cost = V * 30 + (Nimmunized - V) * 100;
                            
nalive = M - nzombies - ndeaths - V; % alive and not immunized

running_time = toc;
display(horzcat('Simulation for zombie apocalypse completed in ', ...
    num2str(running_time),' seconds.'));



end