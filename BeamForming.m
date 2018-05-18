clear all;
%close all;
clc;
%% Beam forming

c=3e8;

x0 = 0;
y0 = 0;
xf = 1.5*1;
yf = 1.5*1;

f=1e9;
lambda=c/f;
x_step = c/f/30; %Accuracy 1Ghz
%en-dessous de x_step = lambda/14 ça ne se propage plus

t0 = 0;
t_step = x_step/c/10; %Stability (1D condition)
tf = t0 + 1000*t_step;

x = x0:x_step:xf;
y = y0:x_step:yf;
t = t0:t_step:tf;

eps_rel = ones(length(y), length(x));
mu_rel = ones(length(y), length(x));


spacing=floor((c/f)/4/x_step);
phi = 55;
delta = (2*pi/lambda)*spacing*cos(deg2rad(phi));
x1 = round(length(x)/2) - 2*spacing;
y1 = round(length(y)/2);
%sources
% y1 = 5;
% x1 = 40;

mu_rel(y1-floor(spacing/2),:) = ones(length(y),1)*5000;

nb_sources = 5;
sources = {}

% for i=1:nb_sources
    
%sourca=[y1,x1];

for i = 1: nb_sources
    sources{i} = [x1 + spacing*i, y1, 1, (i-1)*delta];
end

simulation_parameters = struct;
simulation_parameters.R = 0.5;
simulation_parameters.startTime = 50;
simulation_parameters.centerX = x1+ floor(nb_sources/2)*spacing;
simulation_parameters.centerY = y1;
simulation_parameters.delta = delta;


outputs = computeFDTD(x,y,t,eps_rel,mu_rel,'graphics', @bf_graphics, 'sources', sources, ...
    'movie', 'none', 'special','beamforming', 'others',simulation_parameters);


coupe_temps = outputs.coupe_temps;
coupe_circulaire = outputs.coupe_circulaire;


figure;plot(t,coupe_temps);
xlabel('Time [s]');ylabel('Received power [W]');
figure;stem(coupe_circulaire(:,2),coupe_circulaire(:,1)) %TO ANALYZE

vector_pi=linspace(-pi,pi,length(coupe_circulaire(:,2)));
figure;stem(vector_pi,coupe_circulaire(:,1)) %TO ANALYZE

function bf_graphics(fig)
    %figure(fig);
end

