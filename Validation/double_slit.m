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

%Conductive wall
eps_rel(:,200) = ones(length(eps_rel(:,1)), 1)*eps_rel_iron;
mu_rel(:,200) = ones(length(mu_rel(:,1)), 1)*mu_rel_iron;

%holes
eps_rel(180:182,200) = [1 1 1];
mu_rel(180:182,200) = [1 1 1];
eps_rel(218:220,200) = [1 1 1];
mu_rel(218:220,200) = [1 1 1];



%Definition of the sources
sources = {};
sources{1} = [175, 200, 60, 0];


%Defining the simulation parameters (measuring the power over the y axis at
%x = 120)

outputs = computeFDTD(x,y,t,eps_rel,mu_rel, 'sources', sources, 'movie', 'save',...
    'graphics', @myGraphics);


% Custom graphics function to show the wall
function myGraphics(fig)
    figure(fig);
    line([200 200],[0 180]);
    line([200 200],[183 217]);
    line([200 200],[220 400]);
end