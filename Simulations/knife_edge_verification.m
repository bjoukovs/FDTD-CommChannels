clear all;
close all;

addpath('..');


mu_0 = 4*pi*1e-7;
eps_0 = 8.85e-12;
c = 1/sqrt(mu_0*eps_0);
f=1e9;
lambda = c/f; %1 Ghz

x0 = 0;
y0 = 0;
xf = 4;
yf = 4;

x_step = c/1e9/30; %Accuracy 1Ghz
%en-dessous de x_step = lambda/14 ça ne se propage plus

t0 = 0;
t_step = x_step/c/10; %Stability (1D condition)
tf = t0 + 2000*t_step;

x = x0:x_step:xf;
y = y0:x_step:yf;
t = t0:t_step:tf;

eps_rel = ones(length(y), length(x)); 
mu_rel = ones(length(y), length(x));

%Perfectly conducting materials : theoretically infinite relative
%permittivity

eps_rel_iron = 10^9;
mu_rel_iron = 5000;

y0 = 200;

%Conductive wall
eps_rel(y0:end,200) = ones(length(eps_rel(y0:end,1)), 1)*eps_rel_iron;
mu_rel(y0:end,200) = ones(length(mu_rel(y0:end,1)), 1)*mu_rel_iron;



%Definition of the sources
sources = {};
sources{1} = [180, y0+10 , 1, 0];


%Defining the simulation parameters (measuring the power over the y axis at
%x = 120)

mask = zeros(length(y)+1, length(x)+1);
mask(130:300,210) = ones(171,1);
simParams.mask = mask;
simParams.startTime = 1000;
simParams.stopTime = 2000;

outputs = computeFDTD(x,y,t,eps_rel,mu_rel, 'sources', sources, 'movie', 'none',...
    'graphics', @myGraphics, 'special','measurepower','others',simParams);

%Power recovery
meas_power = outputs.power(2:end,210);
meas_Emoddiff = sqrt(2)*sqrt(meas_power); %sqrt(2)*RMS


%Measuring the power without the wall

eps_rel = ones(length(y), length(x)); 
mu_rel = ones(length(y), length(x));
outputs = computeFDTD(x,y,t,eps_rel,mu_rel, 'sources', sources, 'movie', 'none',...
    'graphics', @myGraphics, 'special','measurepower','others',simParams);

%Power recovery
meas_power_incident = outputs.power(2:end,210);
meas_Emod = sqrt(2)*sqrt(meas_power_incident); %sqrt(2)*RMS

Lke = 20*log10(meas_Emoddiff./meas_Emod);

h = y-(y0+10)*x_step;
d1 = 0.2;
d2 = 0.1;
nu = h*sqrt(2/lambda*(1/d1 + 1/d2));

plot(nu,Lke);

% Custom graphics function to show the wall
function myGraphics(fig)
    figure(fig);
    line([200 200],[200 400]);
end