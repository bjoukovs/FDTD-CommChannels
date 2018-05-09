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
tf = t0 + 2.5*1000*t_step;

x = x0:x_step:xf;
y = y0:x_step:yf;
t = t0:t_step:tf;

eps_rel = ones(length(y), length(x)); 
mu_rel = ones(length(y), length(x));



%Definition of the sources
sources = {};
sources{1} = [round(length(x)/2), round(length(y)/2), 1, 0];

simParams.tverif = tf/t_step/2;

outputs = computeFDTD(x,y,t,eps_rel,mu_rel, 'sources', sources, 'movie', 'none','special','attenuation','others',simParams);

verifE=(outputs.verifE).';
verifE=verifE(1:end-1);
figure;plot(linspace(0,length(verifE)*x_step,length(verifE)),verifE);

% fit=[0.001 0.85;0.252 0.1496;0.5645 0.104;0.8568 0.0858;1.159 0.08171];
% xfit=fit(:,1);yfit=fit(:,2);