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
tf = t0 + 2500*t_step;

x = x0:x_step:xf;
y = y0:x_step:yf;
t = t0:t_step:tf;

eps_rel = ones(length(y), length(x)); 
mu_rel = ones(length(y), length(x));

%Perfectly conducting materials : theoretically infinite relative
%permittivity

eps_rel_iron = 10^6;
mu_rel_iron = 5000;

y0 = 200;
xr = 230;
xs = 170;
ys = y0+20;

%Conductive wall
eps_rel(y0:end,200) = ones(length(eps_rel(y0:end,1)), 1)*eps_rel_iron;
mu_rel(y0:end,200) = ones(length(mu_rel(y0:end,1)), 1)*mu_rel_iron;

%Definition of the sources
sources = {};
sources{1} = [xs, ys, 1, 0];


%Defining the simulation parameters (measuring the power over the y axis at
%x = 120)

mask = zeros(length(y)+1, length(x)+1);
mask(y0-100:y0+100,xr) = ones(201,1);
simParams.mask = mask;
simParams.startTime = 1500;
simParams.stopTime = 2500;

outputs = computeFDTD(x,y,t,eps_rel,mu_rel, 'sources', sources, 'movie', 'save',...
    'graphics', @myGraphics, 'special','measurepower','others',simParams);

%Power recovery
meas_power = outputs.power(2:end,xr);
meas_Emoddiff = sqrt(2)*sqrt(meas_power); %sqrt(2)*RMS


%Measuring the power without the wall

eps_rel = ones(length(y), length(x)); 
mu_rel = ones(length(y), length(x));
outputs = computeFDTD(x,y,t,eps_rel,mu_rel, 'sources', sources, 'movie', 'none',...
    'graphics', @myGraphics, 'special','measurepower','others',simParams);

%Power recovery
meas_power_incident = outputs.power(2:end,xr);
meas_Emod = sqrt(2)*sqrt(meas_power_incident); %sqrt(2)*RMS

Lke_lin = meas_Emoddiff./meas_Emod;
Lke = 20*log10(meas_Emoddiff./meas_Emod);

d1 = (200-xs)*x_step;
d2 = (xr-200)*x_step;

ys = ys*x_step;
xs = xs*x_step;
xr = xr*x_step;
y0 = y0*x_step;

yr = y;
y_inter = yr - d2*(yr-ys)/(d1+d2);

h = y_inter-y0;

nu = h*sqrt(2/lambda*(1/d1 + 1/d2));


subplot(2,1,1);
plot(nu,Lke);


%Theory
Lke_2_lin = abs((1+j)/2*(0.5 - 0.5*j - fresnelc(nu) + j*fresnels(nu)));
Lke_2 = 20*log10(abs(Lke_2_lin));

hold on
plot(nu(50:350),Lke_2(50:350));

%Error
subplot(2,1,2);
error = abs(Lke_2_lin - Lke_lin')./Lke_2_lin;

plot(nu,error);

% Custom graphics function to show the wall
function myGraphics(fig)
    figure(fig);
    line([200 200],[200 400]);
end