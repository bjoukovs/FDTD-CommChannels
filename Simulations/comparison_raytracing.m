clear all;
close all;

addpath('..');

c=3e8;

x0 = 0;
y0 = 0;
%etage 12mx12m: on fait une énorme pièce de 30x30 pour éviter les
%réflections sur murs conducteurs, et au milieu on met la vraie pièce
xf = 2.5;
yf = 2.5;

sizePiece=2;
xPiece=xf/2-sizePiece/2;
yPiece=yf/2-sizePiece/2;

f = 2.45e9; %to compare with raytracing project frequency

x_step = c/f/30; %Accuracy 1Ghz
%en-dessous de x_step = lambda/14 ça ne se propage plus

xPieceI=xPiece/x_step;
yPieceI=yPiece/x_step;


t0 = 0;
t_step = x_step/c/10; %Stability (1D condition)
tf = t0 + 15*1000*t_step; %TO AVOID REFLEXIONS, the multiplier of 1000t_step should be at least 2 times lower than xf (empirical constation)

x = x0:x_step:xf;
y = y0:x_step:yf;
t = t0:t_step:tf;

eps_rel = ones(length(y), length(x)); 
mu_rel = ones(length(y), length(x));

eps_brique = 4.6;
eps_beton = 6;
eps_cloison = 2.25;
epaisseur_brique = 0.1; %metres
epaisseur_brique_ind=floor(epaisseur_brique/x_step);
epaisseur_beton = 0.25;
epaisseur_beton_ind=floor(epaisseur_beton/x_step);
epaisseur_cloison = 0.05;
epaisseur_cloison_ind=floor(epaisseur_cloison/x_step);

stepRay=round(sizePiece/250/x_step); %indices
%stepRay_i=stepRay/x_step;

%carré murs brique
eps_rel(yPieceI-floor(epaisseur_brique_ind/2):yPieceI+floor(epaisseur_brique_ind/2),xPieceI:end-xPieceI)=eps_brique;
eps_rel(end-yPieceI-floor(epaisseur_brique_ind/2):end-yPieceI+floor(epaisseur_brique_ind/2),xPieceI:end-xPieceI)=eps_brique;
eps_rel(yPieceI:end-yPieceI,xPieceI-floor(epaisseur_brique_ind/2):xPieceI+floor(epaisseur_brique_ind/2))=eps_brique;
eps_rel(yPieceI:end-yPieceI,end-xPieceI-floor(epaisseur_brique_ind/2):end-xPieceI+floor(epaisseur_brique_ind/2))=eps_brique;

%murs verticaux rouge gauche
eps_rel(yPieceI:yPieceI +35*stepRay,xPieceI+80-floor(epaisseur_beton_ind/2):xPieceI+80+floor(epaisseur_beton_ind/2))=eps_beton;
eps_rel(yPieceI+50*stepRay:yPieceI+120*stepRay,xPieceI+80-floor(epaisseur_beton_ind/2):xPieceI+80+floor(epaisseur_beton_ind/2))=eps_beton;
eps_rel(yPieceI+130*stepRay:yPieceI+180*stepRay,xPieceI+80-floor(epaisseur_beton_ind/2):xPieceI+80+floor(epaisseur_beton_ind/2))=eps_beton;

%murs verticaux rouge droite
eps_rel(yPieceI:yPieceI+35*stepRay,xPieceI+150-floor(epaisseur_beton_ind/2):xPieceI+150+floor(epaisseur_beton_ind/2))=eps_beton;
eps_rel(yPieceI+50*stepRay:yPieceI+160*stepRay,xPieceI+150-floor(epaisseur_beton_ind/2):xPieceI+150+floor(epaisseur_beton_ind/2))=eps_beton;
eps_rel(yPieceI+180*stepRay:yPieceI+210*stepRay,xPieceI+150-floor(epaisseur_beton_ind/2):xPieceI+150+floor(epaisseur_beton_ind/2))=eps_beton;

%mur horizontal rouge
eps_rel(yPieceI+210*stepRay-floor(epaisseur_beton_ind/2):yPieceI+210*stepRay+floor(epaisseur_beton_ind/2),xPieceI:xPieceI+120*stepRay)=eps_beton;

%murs horizontaux bleus
eps_rel(yPieceI+65*stepRay-floor(epaisseur_beton_ind/2):yPieceI+65*stepRay+floor(epaisseur_beton_ind/2),xPieceI:xPieceI+80*stepRay)=eps_beton;
eps_rel(yPieceI+125*stepRay-floor(epaisseur_beton_ind/2):yPieceI+125*stepRay+floor(epaisseur_beton_ind/2),xPieceI+150*stepRay:end-xPieceI)=eps_beton;
eps_rel(yPieceI+180*stepRay-floor(epaisseur_beton_ind/2):yPieceI+180*stepRay+floor(epaisseur_beton_ind/2),xPieceI+150*stepRay:end-xPieceI)=eps_beton;

%facteur echelle = 83;



%Definition of the sources
sources = {};
%a = 2445; %yPieceI+20*stepRay
%sources{1} = [round(length(x)-xPieceI-20*stepRay), round(yPieceI+20*stepRay), 1, 0];
sources{1} = [round(xPieceI+150*stepRay), round(yPieceI+170*stepRay), 1, 0];
%simParams.tverif=1:50:length(t)+1; %attention indexes, not real times

outputs = computeFDTD(x,y,t,eps_rel,mu_rel, 'sources', sources, 'movie', 'save');



