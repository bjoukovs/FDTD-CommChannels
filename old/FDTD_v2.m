%WORKING START VERSION

clear all;
close all;
format long

%% CONSTANTS

mu_0 = 4*pi*1e-7;
eps_0 = 8.85e-12;
c = 1/sqrt(mu_0*eps_0);

lambda = c/1e9; %1 Ghz

x0 = 0;
y0 = 0;
xf = 1;
yf = 1;

x_step = lambda/15; %Accuracy
%en-dessous de x_step = lambda/14 ça ne se propage plus

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
Hx = zeros(length(y), length(x));
Hy = zeros(length(y), length(x));
Ez = zeros(length(y)+1, length(x)+1);
alpha = t_step/mu_0/x_step;
beta = t_step/eps_0/x_step;



%% Problem solving

%Here we solve the problem with a sinusoidal source at 50,50
%(simple coulombian source)
%of the electric field


for i=1:length(t)
 
   %source
   Ez(50,50) = sin(2*pi*1e9*t(i));
   
    %Update of Hx, Hy
    for j=1:length(x)
        for k=1:length(y)
            
            %Hx
            
            Hx(k,j) = Hx(k,j) - alpha*(Ez(k+1,j) - Ez(k,j));

            
            
            %Hy
            
            Hy(k,j) = Hy(k,j) + alpha*(Ez(k,j+1) - Ez(k,j));
                
        end
    end
    
    %Update of Ez
    for l=2:length(x)
        for m=2:length(y)
            
             if l~=50 || m~=50
                Ez(m,l) = Ez(m,l) + beta*(Hy(m,l) - Hy(m,l-1)) - beta*(Hx(m,l)-Hx(m-1,l));
             else
                 l,m
             end
            
        end
    end

    %show movie
    %hold on;
    %plot(i,Ez(50,50));
    surf(Ez)
    pause(0.1);
end

imagesc(Ez)
colormap hot; 


