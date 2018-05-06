clear all;
close all;
clc;
%% Beam forming

c=3e8;

x0 = 0;
y0 = 0;
xf = 1;
yf = 1;

f=2.45e9;
x_step = c/f/30; %Accuracy 1Ghz
%en-dessous de x_step = lambda/14 ça ne se propage plus

t0 = 0;
t_step = x_step/c/10; %Stability (1D condition)
tf = t0 + 100*t_step;

x = x0:x_step:xf;
y = y0:x_step:yf;
t = t0:t_step:tf;

eps_rel = ones(length(y), length(x));
mu_rel = ones(length(y), length(x));

%sources
y1 = 5;
x1 = 40;
nb_sources = 7;
sources = {}

spacing=floor((c/f)/4/x_step);

% for i=1:nb_sources
    
%sourca=[y1,x1];

for i = 1: nb_sources
    sources{i} = [y1, x1 + spacing*i, 1, 0];
end

simulation_parameters = struct;
simulation_parameters.R = 0.5;
simulation_parameters.startTime = 50;
simulation_parameters.centerX = x1+ nb_sources/2*spacing;
simulation_parameters.centerY = y1;


outputs = computeFDTD(x,y,t,eps_rel,mu_rel,'graphics', @bf_graphics, 'sources', sources, ...
    'movie', 'none', 'special','beamforming', 'others',simulation_parameters);


coupe_temps = outputs.coupe_temps;
coupe_circulaire = outputs.coupe_circulaire;


figure;plot(t,coupe_temps);
xlabel('Time [s]');ylabel('Received power [W]');
figure;plot(coupe_circulaire(:,2),coupe_circulaire(:,1)) %TO ANALYZE


function bf_graphics(fig)
    figure(fig);
end

