clear all;
close all;

addpath('..');

c=3e8;

x0 = 0;
y0 = 0;
xf = 1;
yf = 1;

x_step = c/1e9/30; %Accuracy 1Ghz
%en-dessous de x_step = lambda/14 ça ne se propage plus

t0 = 0;
t_step = x_step/c/10; %Stability (1D condition)
tf = t0 + 1000*t_step;

x = x0:x_step:xf;
y = y0:x_step:yf;
t = t0:t_step:tf;

% BOROSILICATE GLASS http://www.kayelaby.npl.co.uk/general_physics/2_6/2_6_5.html

eps_rel = 5.3*ones(length(y), length(x)); 
mu_rel = ones(length(y), length(x));



%Definition of the sources
sources = {};
sources{1} = [round(length(x)/2), round(length(y)/2), 1, 0];

outputs = computeFDTD(x,y,t,eps_rel,mu_rel, 'sources', sources, 'movie', 'show');