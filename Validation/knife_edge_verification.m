clear all;
close all;

addpath('..');

c=3e8;

x0 = 0;
y0 = 0;
xf = 3;
yf = 3;

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

eps_rel_iron = 10^12;
mu_rel_iron = 5000;

y0 = 190;

%Conductive wall
eps_rel(y0:end,100) = ones(length(eps_rel(y0:end,1)), 1)*eps_rel_iron;
mu_rel(y0:end,100) = ones(length(mu_rel(y0:end,1)), 1)*mu_rel_iron;



%Definition of the sources
sources = {};
sources{1} = [80, y0+10 , 1, 0];


%Defining the simulation parameters (measuring the power over the y axis at
%x = 120)

mask = zeros(length(y)+1, length(x)+1);
mask(100:250,110) = ones(151,1);
simParams.mask = mask;
simParams.startTime = 750;
simParams.stopTime = 2000;

outputs = computeFDTD(x,y,t,eps_rel,mu_rel, 'sources', sources, 'movie', 'save',...
    'graphics', @myGraphics, 'special','measurepower','others',simParams);



function myGraphics(fig)
    figure(fig);
    line([100 100],[190 300]);
end