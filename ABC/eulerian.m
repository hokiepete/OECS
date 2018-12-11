clear all
close all
clc
dimx=96;
dimy=96;
dimz=96;
x = linspace(0,2*pi,dimx);
dx = x(2)-x(1);
y = linspace(0,2*pi,dimy);
dy = y(2)-y(1);
z = linspace(0,2*pi,dimz);
dz = z(2)-z(1);;
[x,y,z] = meshgrid(x,y,z);
[u,v,w] = abc_flow(x,y,z,0);
[dudx,dudy,dudz] = gradient(u,dx,dy,dz);
[dvdx,dvdy,dvdz] = gradient(v,dx,dy,dz);
[dwdx,dwdy,dwdz] = gradient(w,dx,dy,dz);

for i = 1:dimy
    i
    for j=1:dimx
        for k =1:dimz
            %utemp =[u(i,j,k);v(i,j,k);w(i,j,k)];
            gradU = [dudx(i,j,k),dudy(i,j,k),dudz(i,j,k);dvdx(i,j,k),dvdy(i,j,k),dvdz(i,j,k);dwdx(i,j,k),dwdy(i,j,k),dwdz(i,j,k)];
            S = 0.5*(gradU + gradU');
            %s1(i,j,k) = min(eig(S));
            
            %s3(i,j,k) = max(eig(S));
            [V,D] = eig(S);
            if ~issorted(diag(D))
                [D,I] = sort(diag(D));
                V = V(:, I);
            end
            s1(i,j,k) = D(1,1);
            X1(i,j,k,:) = V(:,1);
            %s1(i,j,k) = median(eig(S));
        end
    end
end

[dsdx,dsdy,dsdz] = gradient(s1,dx,dy,dz);

[dsdxdx,dsdxdy,dsdxdz] = gradient(dsdx,dx,dy,dz);
[dsdydx,dsdydy,dsdydz] = gradient(dsdy,dx,dy,dz);
[dsdzdx,dsdzdy,dsdzdz] = gradient(dsdz,dx,dy,dz);


for i = 1:dimy
    i
    for j=1:dimx
        for k =1:dimz
            dirdiv(i,j,k) = dot([dsdx(i,j,k),dsdy(i,j,k),dsdz(i,j,k)],squeeze(X1(i,j,k,:)));
            concav(i,j,k) = dot([dsdxdx(i,j,k),dsdxdy(i,j,k),dsdxdz(i,j,k);dsdydx(i,j,k),dsdydy(i,j,k),dsdydz(i,j,k);dsdzdx(i,j,k),dsdzdy(i,j,k),dsdzdz(i,j,k)]*squeeze(X1(i,j,k,:)),squeeze(X1(i,j,k,:)));
            
            %if abs(dirdiv(i,j,k)) > 0.1
            %    dirdiv(i,j,k) = nan;
            %end
        end
    end
end

save OECS_DATA s1 X1 dirdiv concav x y z
%{
figure
model.cdata = s1
model.alpha = [];
model.xdata = [0,2*pi];
model.ydata = [0,2*pi];
model.zdata = [0,2*pi];
model.parent = [];
model.handles = [];
model.texture = '3D';
colormap(parula);
vol3d_v2(model)
colorbar
title('s1')
view(3)
%

%
%dirdiv = abs(dirdiv)<0.2;
figure
model.cdata = abs(dirdiv)
model.alpha = [];%1./abs(dirdiv);
model.xdata = [0,2*pi];
model.ydata = [0,2*pi];
model.zdata = [0,2*pi];
model.parent = [];
model.handles = [];
model.texture = '3D';
colormap(parula);
vol3d_v2(model)
colorbar
title('dirdiv')
view(3)
%

figure
isosurface(x,y,z,dirdiv,0)
view(3)

%}