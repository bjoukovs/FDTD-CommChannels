clear all;
close all;

c=3e8;

x0 = 0;
y0 = 0;
xf = 2*1;
yf = 2*1;

x_step = c/1e9/30; %Accuracy 1Ghz
%en-dessous de x_step = lambda/14 ça ne se propage plus

t0 = 0;
t_step = x_step/c/10; %Stability (1D condition)
tf = t0 + 1000*t_step;

x = x0:x_step:xf;
y = y0:x_step:yf;
t = t0:t_step:tf;

eps_rel = ones(length(y), length(x)); 
mu_rel = ones(length(y), length(x));

eps_rel(1:50,90) = ones(50,1)*1; %iron wall on x=90, %ATTENTION PAS 10^6 car c'est eps RELATIF
mu_rel(1:50,90) = ones(50,1)*5000; %ici c'est bien la bonne valeur de mu relative



%Definition of the sources
sources = {};
sources{1} = [70, 40, 1, 0];

outputs = computeFDTD(x,y,t,eps_rel,mu_rel,'graphics', @knife_edge_graphics, 'sources', sources, 'movie', 'show');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Special function for the knife edge plot
function knife_edge_graphics(fig)
    figure(fig);
    line([50 50],[0 90]);
    title("Knife edge model"); 
end