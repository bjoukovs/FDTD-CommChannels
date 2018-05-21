function [Ez,Fading_matrix1,Fading_matrix3, Path_loss, Fading_matrix1_begin, Fading_matrix2, Fading_matrix4] = FDTD_compute_forfastfading(x,y,t,x_source,y_source,eps_rel,mu_rel,show_movie,custom_display)

    

    colormapfile = matfile('hotcoldmap.mat');
    cm = colormapfile.cm;
    cm = cm/255;

    mu_0 = 4*pi*1e-7;
    eps_0 = 8.85e-12;
    c = 1/sqrt(mu_0*eps_0);

    lambda = c/2.45e9; %1 Ghz

    x_step = x(2)-x(1);
    y_step = y(2)-y(1);
    t_step = t(2)-t(1);
    Hx = zeros(length(y), length(x));
    Hy = zeros(length(y), length(x));
    Ez = zeros(length(y)+1, length(x)+1);
    alpha = (mu_rel).^-1 .*(t_step/mu_0/x_step);
    beta = (eps_rel).^-1 .*(t_step/eps_0/x_step);
    
    Fading_matrix1=zeros(30,30);
    Fading_matrix3=zeros(30,30);
    Path_loss=zeros(250,1);
    
    Fading_matrix1_begin=zeros(30,30);
    Fading_matrix2=zeros(30,30);
    Fading_matrix4=zeros(30,30);

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

        %Update of Ez
        for l=2:length(x)
            for m=2:length(y)

                 if l~=x_source || m~=y_source
                    Ez(m,l) = Ez(m,l) + beta(m-1,l-1)*(Hy(m,l) - Hy(m,l-1)) - beta(m-1,l-1)*(Hx(m,l)-Hx(m-1,l));
                 %else
                     %l,m
                 end

            end
        end

        
        if i>150 && i<=200
            %zone1
            Fading_matrix1_begin(:,:) = Fading_matrix1(:,:)+((Ez(250 + 25 : 250 + 25 + 30 -1,250 - 15 : 250 + 15 -1)).^2) * (0.5/500);
            
        end
        
        if i>450 && i<=550
            %zone2
            Fading_matrix2(:,:) = Fading_matrix1(:,:)+((Ez(500-50-15 : 500-50-15,250 - 15 : 250 + 15 -1)).^2) * (0.5/500);
            
        end
        
        if i>3000 && i<=4500
            Fading_matrix4(:,:) = Fading_matrix1(:,:)+((Ez(500-50-15 : 500-50-15,400 - 15 : 400 + 15 -1)).^2) * (0.5/500);
        end
       
        
        if i>1500 && i<=2000
            %zone1
            Fading_matrix1(:,:) = Fading_matrix1(:,:)+((Ez(250 + 25 : 250 + 25 + 30 -1,250 - 15 : 250 + 15 -1)).^2) * (0.5/500);
            %zone3
            Fading_matrix3(:,:) = Fading_matrix3(:,:)+((Ez(400 + 25 : 400 + 25 + 30 -1,50 - 15 : 50 + 15 -1)).^2) * (0.5/500);
            Path_loss(:,:) = Path_loss(:,:)+((Ez(251 : 500, 251)).^2) * (0.5/500);
        end

        if show_movie==1
            figure(2)
            colormap(cm);
            imagesc(Ez, [-1,1])
            hold on;
            %imagesc(eps_rel_draw);
            eval(custom_display);
            hold off;
            pause(0.001);
        end

        i

    end

    %surf(Fading_matrix3);
end
