clear all;
close all;
clc;
%% Beam forming

c=3e8;

x0 = 0;
y0 = 0;
xf = 1;
yf = 1;

x_step = c/(2.45e9)/30; %Accuracy 1Ghz
%en-dessous de x_step = lambda/14 ça ne se propage plus

t0 = 0;
t_step = x_step/c/10; %Stability (1D condition)
tf = t0 + 10000*t_step;

x = x0:x_step:xf;
y = y0:x_step:yf;
t = t0:t_step:tf;

eps_rel = ones(length(y), length(x));
mu_rel = ones(length(y), length(x));

%sources
yl = 10;
xl = 10;
nb_sources = 6;
sourca = zeros(nb_sources,2);
for i = 1: nb_sources
    sourca(i,:) = [yl, xl + 10*i];
end

E = FDTD_compute_beam_forming(x,y,t,sourca,eps_rel,mu_rel,1,'');

