clear all;
close all;

addpath('..');

c=3e8;

x0 = 0;
y0 = 0;
xf = 1*2.5;
yf = 1*2.5;

f = 1e9;

x_step = c/1e9/30; %Accuracy 1Ghz
%en-dessous de x_step = lambda/14 ça ne se propage plus

t0 = 0;
t_step = x_step/c/10; %Stability (1D condition)
tf = t0 + 1*1000*t_step; %TO AVOID REFLEXIONS, the multiplier of 1000t_step should be at least 2 times lower than xf (empirical constation)

x = x0:x_step:xf;
y = y0:x_step:yf;
t = t0:t_step:tf;

eps_rel = ones(length(y), length(x)); 
mu_rel = ones(length(y), length(x));

%Definition of the sources
sources = {};
sources{1} = [round(length(x)/2), round(length(y)/2), 1, 0];

simParams.tverif=1:50:length(t)+1; %attention indexes, not real times

outputs = computeFDTD(x,y,t,eps_rel,mu_rel, 'sources', sources, 'movie', 'none','special','attenuation','others',simParams);

verifE=outputs.verifE;
verifPoynting=outputs.verifPoynting;
posy_ls=outputs.posy_ls;
figure;stem(posy_ls,verifE);title('Decrease of E amplitude with distance')
xlabel('Distance (y) from the source [m]');
ylabel('Electric field amplitude [V/m]')
figure;stem(posy_ls,verifPoynting);title('Decrease of Power Density (S) with distance')
xlabel('Distance (y) from the source [m]');
ylabel('Norm of Poynting vector [W/m^2]')
