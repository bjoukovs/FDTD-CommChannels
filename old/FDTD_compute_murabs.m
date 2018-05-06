%Mur abs V2
function Ez = FDTD_compute_murabs(x,y,t,x_source,y_source,eps_rel,mu_rel,show_movie,custom_display)
    
    colormapfile = matfile('hotcoldmap.mat');
    cm = colormapfile.cm;
    cm = cm/255;

    mu_0 = 4*pi*1e-7;
    eps_0 = 8.85e-12;
    c = 1/sqrt(mu_0*eps_0);

    lambda = c/1e9; %1 Ghz
    
    x_step = x(2)-x(1);
    y_step = y(2)-y(1);
    t_step = t(2)-t(1);
    Hx = zeros(length(y), length(x));
    Hy = zeros(length(y), length(x));
    Ez = zeros(length(y)+1, length(x)+1);
    alpha = (mu_rel).^-1 .*(t_step/mu_0/x_step);
    beta = (eps_rel).^-1 .*(t_step/eps_0/x_step);
    
    %show color bar only
    if show_movie==1
        fig1 = figure('Position',[0,0,200,500]);
        colormap(cm);
        cb = colorbar;
        cb.Limits = [-1 1]
        axis off;
        figure(2)
    end
    
    for i=1:length(t)

       %source
       Ez(y_source,x_source) = sin(2*pi*1e9*t(i));

        %Update of Hx, Hy
        for j=1:length(x)
            for k=1:length(y)
                

                %Hx

                Hx(k,j) = Hx(k,j) - alpha(k,j)*(Ez(k+1,j) - Ez(k,j));
                %Hy

                Hy(k,j) = Hy(k,j) + alpha(k,j)*(Ez(k,j+1) - Ez(k,j));

            end
        end
        
         Hx(:,1) = Hx(:,2);
         Hx(:,length(x)+1) = Hx(:,length(x)+1 - 1);
         Hx(1,:) = Hx(2,:);
         Hx(length(y)+1,:) = Hx(length(y)+1 - 1,:);
         
         Hy(:,1) = Hy(:,2);
         Hy(:,length(x)+1) = Hy(:,length(x)+1 - 1);
         Hy(1,:) = Hy(2,:);
         Hy(length(y)+1,:) = Hy(length(y)+1 - 1,:);
        %Update of Ez
        for l=2:length(x)
            for m=2:length(y)

                 if l~=x_source || m~=y_source
                    Ez(m,l) = Ez(m,l) + beta(m-1,l-1)*(Hy(m,l) - Hy(m,l-1)) - beta(m-1,l-1)*(Hx(m,l)-Hx(m-1,l));
                 else
                     l,m
                 end
            end
        end
        
         Ez(:,1) = Ez(:,2);
         Ez(:,length(x)+1) = Ez(:,length(x)+1 - 1);
         Ez(1,:) = Ez(2,:);
         Ez(length(y)+1,:) = Ez(length(y)+1 - 1,:);


        
        if show_movie==1
            figure(2)
            colormap(cm);
            imagesc(Ez, [-1,1])
            hold on;
            %imagesc(eps_rel_draw);
            eval(custom_display);
            hold off;
            pause(0.01);
        end
        
    end
end