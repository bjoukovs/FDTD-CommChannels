clear all;
close all;

%% CONSTANTS

c = 3e8;
mu_0 = 4*pi*1e-7;
eps_0 = 8.85e-12;

lambda = c/1e9; %1 Ghz

x0 = 0;
y0 = 0;
xf = 1;
yf = 1;

x_step = lambda/20 %Accuracy

iterations = 10;

t0 = 0;
t_step = x_step/c/10; %Stability (1D condition)
tf = t0 + 1000*t_step;



%% Problem initialization
x = x0:x_step:xf;
y = y0:x_step:yf;
t = t0:t_step:tf;

%We take twice as long matrices because we need +1/2 spatial increments in
%the equations
%H(i,j) corresponds to H(j/2*delta_x, i/2*delta_y)
Hx = zeros(length(y)*2, length(x)*2);
Hy = zeros(length(y)*2, length(x)*2);
Ez = zeros(length(y)*2, length(x)*2);

alpha = t_step/mu_0/x_step;
beta = t_step/eps_0/x_step;



%% Problem solving

%Here we solve the problem with a sinusoidal source at 50,50
%(simple coulombian source)
%of the electric field


for i=t
   
   %source
   Ez(50,50) = sin(2*pi*1e9*i);
   Ez(50,50);
   
    %Update of Hx, Hy
    for j=1:length(x)*2
        for k=1:length(y)*2
            
            %Hx
            
            %Boundary conditions : Here I consider that the walls are void
            if k==1  
                Hx(k,j) = Hx(k,j) - alpha*(Ez(2,j));
                
            elseif k==length(y)*2     
                Hx(k,j) = Hx(k,j) + alpha*(Ez(length(y)*2-1,j));
                
            else
                %Not boundary condition case
                Hx(k,j) = Hx(k,j) - alpha*(Ez(k+1,j) - Ez(k-1,j));
                
            end
            
            
            %Hy
            
            if j==1
                Hy(k,j) = Hy(k,j) - alpha*(Ez(k,2));
                
            elseif j==length(x)*2
                Hy(k,j) = Hy(k,j) + alpha*(Ez(k,length(x)*2-1));
                
            else
                Hy(k,j) = Hy(k,j) - alpha*(Ez(k,j+1) - Ez(k,j-1));
                
            end
        end
    end
    
    %Update of Ez
    for j=1:length(x)*2
        for k=1:length(y)*2
            
            %Boundary conditions : left wall
            if j==1
                if k==1
                    %top left corner
                    Ez(k,j) = Ez(k,j) + beta*Hy(1,2) - beta*Hx(2,1);
                    
                elseif k==length(y)*2
                    %bottom left corner
                    Ez(k,j) = Ez(k,j) + beta*Hy(k,2) + beta*Hx(k-1,1);
                    
                else
                    Ez(k,j) = Ez(k,j) + beta*Hy(k,2) - beta*(Hx(k+1,j)-Hx(k-1,j));
                end
                
            %right wall
            elseif j==length(x)*2
                if k==1
                    %top right corner
                    Ez(k,j) = Ez(k,j) - beta*Hy(1,j-1) - beta*Hx(2,j);
                    
                elseif k==length(y)*2
                    %bottom right corner
                    Ez(k,j) = Ez(k,j) - beta*Hy(k,j-1) + beta*Hx(k-1,j);
                    
                else
                    Ez(k,j) = Ez(k,j) - beta*Hy(k,j-1) - beta*(Hx(k+1,j)-Hx(k-1,j));
                    
                end
                
            %top wall
            elseif k==1
                Ez(k,j) = Ez(k,j) + beta*(Hy(k,j+1) - Hy(k,j-1)) - beta*Hx(2,j);
            
                
            %bottom wall
            elseif k==length(y)*2
                Ez(k,j) = Ez(k,j) + beta*(Hy(k,j+1) - Hy(k,j-1)) + beta*Hx(k-1,j);
                
            %general case without boundary conditions
            else
                Ez(k,j) = Ez(k,j) + beta*(Hy(k,j+1) - Hy(k,j-1)) - beta*(Hx(k+1,j)-Hx(k-1,j));
            end
            
            
        end
    end

    %show movie
    %hold on;
    %surf(Ez(2:2:end,2:2:end))
    %pause(0.1);
end

%Remove +1/2 steps
Ez = Ez(2:2:end,2:2:end);

imagesc(Ez)
colormap hot; 


