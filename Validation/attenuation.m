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
tf = t0 + 1*1000*t_step; %TO AVOID REFLEXIONS, the multiplier of 1000t_step should be at least 2 times lower than xf

x = x0:x_step:xf;
y = y0:x_step:yf;
t = t0:t_step:tf;

eps_rel = ones(length(y), length(x)); 
mu_rel = ones(length(y), length(x));

%Definition of the sources
sources = {};
sources{1} = [round(length(x)/2), round(length(y)/2), 1, 0];

%simParams.tverif = round(tf/t_step/1);
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

% verifE=(outputs.verifE).';
% verifE=verifE(1:end-1);
% figure;plot(linspace(0,length(verifE)*x_step,length(verifE)),verifE);

% fit=[0.001 0.85;0.252 0.1496;0.5645 0.104;0.8568 0.0858;1.159 0.08171];
% xfit=fit(:,1);yfit=fit(:,2);

% xfit=[0.06048 0.373 0.6754 1.028];
% yfit=[0.2745 0.1245 0.09393 0.03358];

% xfit=[0.09036 0.4016 0.7028 0.994 1.305 1.586];
% yfit=[0.187 0.07904 0.05281 0.03965 0.02882 0.02315];