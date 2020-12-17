clc; clf; clear all; close all;
%% Incializacion 
addpath(genpath('TwIST_v2'));
fftnc = @(x) fftshift(fftn(fftshift(x)));
ifftnc = @(x) ifftshift(ifftn(ifftshift(x)));
n=79;
% data="TempCorrC1017";
%data="TempCorrC1025";
data="TempCorrC1032";
% data="TempCorrC1044";
load (data)
N=length(C02t)-1;
C02tN=zeros(79,79,N);
C13tN=C02tN;
C20tN=C02tN;
C31tN=C02tN;
for j1 = [1 : N] %Normalizamos todos los frames
    minimo=min(min(C02t{j1}));
    C02tN(:,:,j1)=(C02t{j1}-minimo)/(max(max(C02t{j1}))-minimo);
    minimo=min(min(C13t{j1}));
    C13tN(:,:,j1)=(C13t{j1}-minimo)/(max(max(C13t{j1}))-minimo);
    minimo=min(min(C20t{j1}));
    C20tN(:,:,j1)=(C20t{j1}-minimo)/(max(max(C20t{j1}))-minimo);
    minimo=min(min(C31t{j1}));
    C31tN(:,:,j1)=(C31t{j1}-minimo)/(max(max(C31t{j1}))-minimo);
end


% Filtrar imagen
xorg=C02tN(:,:,23);%aqui se ajustan la imagenes a observar, si desa una secuancia use un For
x=xorg;
xfilt=imnlmfilt(xorg,'ComparisonWindowSize',3,'SearchWindowSize',21,"DegreeOfSmoothing",0.02);
x=xfilt;
figure
imshow([xorg x],[],'InitialMagnification',1024)
C02tFILT=zeros(79,79,N);
for im=1:N %% filtramos identicamente a todas la imagenes
    C02tFILT(:,:,im)=imnlmfilt(C02tN(:,:,im),'ComparisonWindowSize',3,'SearchWindowSize',21,"DegreeOfSmoothing",0.02);
    C13tFILT(:,:,im)=imnlmfilt(C13tN(:,:,im),'ComparisonWindowSize',3,'SearchWindowSize',21,"DegreeOfSmoothing",0.02);
    C20tFILT(:,:,im)=imnlmfilt(C20tN(:,:,im),'ComparisonWindowSize',3,'SearchWindowSize',21,"DegreeOfSmoothing",0.02);
    C31tFILT(:,:,im)=imnlmfilt(C31tN(:,:,im),'ComparisonWindowSize',3,'SearchWindowSize',21,"DegreeOfSmoothing",0.02);
end
%% MIRANDO INFO

MINIMAL=min(min(C02t{3}));
MAXIMUN=max(max(C02t{3}));
C02tNN=(C02t{3}-MINIMAL)/(MAXIMUN-MINIMAL);
CN=(C02tNN<=(-MINIMAL/(MAXIMUN-MINIMAL))).*C02tNN;
CN2=(C02tNN>(-MINIMAL/(MAXIMUN-MINIMAL))).*C02tNN;
% CN2=(C02tNN>0.45).*C02tNN;
xfilt2=imnlmfilt(CN2,'ComparisonWindowSize',3,'SearchWindowSize',21,"DegreeOfSmoothing",0.02);
xfilt=imnlmfilt(CN,'ComparisonWindowSize',3,'SearchWindowSize',21,"DegreeOfSmoothing",0.02);
xfiltORG=imnlmfilt(C02tNN,'ComparisonWindowSize',3,'SearchWindowSize',21,"DegreeOfSmoothing",0.02);
imshow([C02tNN CN CN2; xfiltORG xfilt xfilt2],[],'InitialMagnification',1024)

%% Calculos de PSF basado en la imagen ON-line o Movil.
% imwrite(x,"Evidencias\x1.bmp")
[i, j] = find(ismember(x, max(x(:))));
xC=x(i-2:i+2,j-2:j+2);
minxC=min(xC(:));
PorBus=(1-minxC)/2; %porcentaje de buesqueda 33% podria variar respecto a la iluminacion generla de la imagen.
dist=zeros(1,4);
for iv=1:1:min((78-i),i-1)
    flag=0;
    if(x(i-iv,j)>=minxC*(1-PorBus)) %mirar arriba
     dist(1)=iv;
     flag=1;
    end
    if(x(i+iv,j)>=minxC*(1-PorBus)) %mirar abajo
     dist(2)=iv;
     flag=1;
    end
    if(x(i,j-iv)>=minxC*(1-PorBus)) %izquierda
     dist(3)=iv;
     flag=1;
    end
     if(x(i,j-iv)>=minxC*(1-PorBus)) %derecha
     dist(4)=iv;
     flag=1;
    end
    if (flag==0) %si no existe en ninguna direccion finalizamos
        break;
    end
end

distProm=int8(mean(dist));
PSF=zeros(n,n);
RecorPSF=x(i-distProm:i+distProm,j-distProm:j+distProm);
% RecorPSF=(RecorPSF-min(RecorPSF(:)))/(max(RecorPSF(:))-min(RecorPSF(:)));
RecorPSF=(RecorPSF-min(RecorPSF(:)));
PSF(40-distProm:40+distProm,40-distProm:40+distProm)=RecorPSF;
imshow([PSF],[],'InitialMagnification',1024)
%% Recortar PSF para generar border suaves
CiculoCorte = zeros(n, n); 
[xp, yp] = meshgrid(1:n, 1:n); 
CiculoCorte((xp - n/2).^2 + (yp - n/2).^2 <= (distProm).^2) = 1;
sigma = double((distProm*0.7));
gaussCirc = fspecial('gaussian', 79, sigma); 
gaussCirc=gaussCirc/max(max(gaussCirc));% normalizar
PSFmod=(gaussCirc.*(CiculoCorte-1)*-1)+(CiculoCorte.*PSF);
figure
imshow([xorg, x,CiculoCorte.*PSF],[],'InitialMagnification',1024)
PSFFinal= PSF.*CiculoCorte;
%% Twist Manual
alpha = 0.5;
beta = 0.25;
iterTWIST=300;
iteraTV=5;
lambdas=[0.98:-0.03:0.79];
% lambdas=0.75
for im=16%N-10
x=C02tFILT(:,:,im);
y=x;
IMGh=[y];
HH=0;
for j=lambdas
    HH=HH+1;
%     lambda = (4+(j*2))*2^(-j)
    lambda=j;
%     time0 = clock;
    x_twist = TWIST_manual(x,y,alpha,beta,iterTWIST,lambda,iteraTV);
%     disp(sprintf('Total elapsed time = %f secs\n', etime(clock,time0)));
    %mostrar imagenes
    tam=size(IMGh);
    if tam(2)==length(y)*4
        if HH==4
            IMG=IMGh;
        else
            IMG=[IMG;IMGh];
        end
        
        IMGh=x_twist/max(max(x_twist));
    else
        IMGh=[IMGh,x_twist/max(max(x_twist))];
    end   
end
IMG=[IMG;IMGh];
figure(3);
imshow(imresize(IMG,3,'box'));
title("Lambdas del "+lambdas(1)+" al "+ lambdas(end))
end

%% Metodo de Segmentacion de objetos
X0=x_twist/max(x_twist(:));
% X0=C02tFILT(:,:,23);
umbral=0.0032;
% umbral=0.6;
BinDetec=(X0>umbral).*1.0;%Binarizar los que identificamos como objetos
old=BinDetec;
figure(4)
imshow(imresize(BinDetec,3,'box'));
BinDetec2=BinDetec;
Incial=0;
ObjSeg=0;
BordesSeg=0;
ooo=0;
for i=(1:n) %eje X 
    for j=(1:n)% Eje Y
        if BinDetec(j,i)==1
            [BinDetec,ObjActu]=SegmentarPX2(BinDetec,X0,[j,i]);
            BordeActu=ObtenerBordes(ObjActu);
            BinDetec2=[BinDetec2 BinDetec];
           figure(11)
           imshow([X0 BinDetec2],[]);
            %% Guardar datos de objetos segmentados (Pixeles y Bordes)
            [Incial,ObjSeg,BordesSeg]=GuardarDatos(Incial,ObjSeg,ObjActu,BordesSeg,BordeActu);
            ooo=ooo+1;
        end
    end 
end
ooo
% Mostrar datos segmentados (sobre la imagen)

xSal=uint8(zeros(size(X0,1),size(X0,2),3));
X0_255=uint8(X0.*255);
xSal(:,:,1)=X0_255;
xSal(:,:,2)=X0_255;
xSal(:,:,3)=X0_255;
XI=xSal;
xSalF=uint8(zeros(size(X0,1),size(X0,2),3));
X_255=uint8(x.*255);
xSalF(:,:,1)=X_255;
xSalF(:,:,2)=X_255;
xSalF(:,:,3)=X_255;
xSalF=EncerrarObjetos(xSalF,BordesSeg,1,1,0);
xSal=EncerrarObjetos(XI,BordesSeg,1,1,0);
xSal2=EncerrarObjetos(XI,BordesSeg,0,1,1);

figure(13)
imshow([XI,xSalF,xSal,xSal2],[],'InitialMagnification',1024)
%% Buscar la mejor solucion de TwIST para aplicar sobre ella la Segmentacion ya probada
%datos TwIST
alpha = 0.75;
beta = 0.24;
iterTWIST=180;
iteraTV=1;
lambdas=[0.85:-0.04:0.65];
%datos Segmentacion
umbral=0.0005;
ObjCount=zeros(1,length(lambdas));
auxSal=0;
TObjSegment = cell(30,1);
TBordSegment = cell(30,1);
TbPos=zeros(6,2,30);
TbVel=zeros(6,3,30);
TbCruce=zeros(6,2,30);
ims=1:30;
for im=ims
% x=C02tFILT(20:55,20:55,im);
x=C02tFILT(:,:,im);
y=x;
salir=0;
im
    for L=1:length(lambdas)
        lambda=lambdas(L);
        x_twist = TWIST_manual(x,y,alpha,beta,iterTWIST,lambda,iteraTV);
        X0=x_twist/max(x_twist(:));
        BinDetec=(X0>umbral).*1.0;%Binarizar los que identificamos como objetos
        Incial=0;
        ObjSeg=0;
        BordesSeg=0;
        ObjActu=0;
        ObjActu=0;
        for i=(10:size(x,2)-5) %eje X 
            for j=(10:size(x,1)-5)% Eje Y
                if BinDetec(j,i)==1
                    [BinDetec,ObjActu]=SegmentarPX2(BinDetec,X0,[j,i]);
                    BordeActu=ObtenerBordes(ObjActu);
                %% Guardar datos de objetos segmentados (Pixeles y Bordes)
                    [Incial,ObjSeg,BordesSeg]=GuardarDatos(Incial,ObjSeg,ObjActu,BordesSeg,BordeActu);
                    ObjCount(L)=size(ObjSeg,3); 
                end
            end 
        end
        %% si se idnetifican menos objetos 3 veces seguidas se toma el mejor valor
        maxObj=max(ObjCount);
        if(maxObj>ObjCount(L))
            salir=salir+1;
            if salir>3
                X02=X0;
                break
            end
        end        
    end
    maxObj=max(ObjCount);
    posiciones=find(ismember(ObjCount, maxObj));
    if length(posiciones)>3
        posiciones=posiciones(1:4);
    end
    LambdaFinal=0;
    for posi=posiciones
        LambdaFinal=LambdaFinal+lambdas(posi);
    end
    %% Aplicar TwIST con mejor lambda
    LambdaFinal=LambdaFinal/length(posiciones);
    LambdaFinal
    x_twist = TWIST_manual(x,y,alpha,beta,iterTWIST,LambdaFinal,iteraTV);
    %% Aplicar metodo de Segmentacion
    X0=x_twist/max(x_twist(:));
    BinDetec=(X0>umbral).*1.0;%Binarizar los que identificamos como objetos
    BinDetec(39:40,40:41)=0.0;
%     BinDetec(20:21,21:22)=0.0;
    Incial=1;
    ObjSeg=0;
    BordesSeg=0;
    ObjActu=0;
    ObjActu=0;
    ObjSeg=[39,40;39,41;40,40;40,41];
    BordesSeg=[39,40;39,41;40,40;40,41];
    for j=(1:size(x,2)-15) %eje X 
        for i=(1:size(x,1)-15)% Eje Y
            if BinDetec(j,i)==1
                [BinDetec,ObjActu]=SegmentarPX2(BinDetec,X0,[j,i]);
                BordeActu=ObtenerBordes(ObjActu);
                %% Guardar datos de objetos segmentados (Pixeles y Bordes)
                [Incial,ObjSeg,BordesSeg]=GuardarDatos(1,ObjSeg,ObjActu,BordesSeg,BordeActu);
            end
        end 
    end
    TObjSegment{im} = ObjSeg;
    BordSegment{im} = BordesSeg;
    Tcentros=Centroides(TObjSegment);
    DistActuJI=abs(Tcentros{im}-[39,40]).^2;
    Distobjs=abs(sqrt(DistActuJI(:,1)+DistActuJI(:,2)));
    orden=zeros(size(Distobjs));
    DistOrd=sort(-Distobjs);
    for iter=1:1:length(Distobjs)
        for it=1:1:length(DistOrd)
            if -DistOrd(it)==Distobjs(iter)
                orden(iter)=it;
            end
        end
    end
    if im>1
        for it=1:1:size(TbPos,1)
            TbPos(it,:,im)=TbPos(it,:,im-1);
            TbVel(it,:,im)=[0 0 0];
            TbCruce(it,:,im)=[0 0];
        end
    end
    for iter=1:1:length(Distobjs)
        TbPos(orden(iter),:,im)=Tcentros{im}(iter,:);%zeros(6,2,30);
        if im==1
            TbVel(orden(iter),:,im)=[0 0 0];
        else
            TbVel(orden(iter),1:2,im)=TbPos(orden(iter),:,im)-TbPos(orden(iter),:,im-1);% vector de velocidad con dirección
            TbVel(orden(iter),3,im)=norm(abs(TbVel(orden(iter),1:2,im)));%velocidad abs
        end
        if mean2(ismember([39,40,41],round(TbPos(orden(iter),1,im)))*1.0)>=0.3 && mean2(ismember([39,40,41],round(TbPos(orden(iter),2,im)))*1.0)>=0.3
            TbCruce(orden(iter),:,im)=TbPos(orden(iter),:,im);%zeros(6,2,30);
        else
            TbCruce(orden(iter),:,im)=[0 0];            
        end
    end
    
    %% Mostrar datos segmentados (sobre la imagen)
    xinit=uint8(zeros(size(x,1),size(x,2),3));
    X_255=uint8(x.*255);
    xinit(:,:,1)=X_255;
    xinit(:,:,2)=X_255;
    xinit(:,:,3)=X_255;
    
    xSal=uint8(zeros(size(x,1),size(x,2),3));
    X0_255=uint8(X0.*255);
    xSal(:,:,1)=X0_255;
    xSal(:,:,2)=X0_255;
    xSal(:,:,3)=X0_255;
    xSalF=uint8(zeros(size(X0,1),size(X0,2),3));
    X_255=uint8(x.*255);
    xSalF(:,:,1)=X_255;
    xSalF(:,:,2)=X_255;
    xSalF(:,:,3)=X_255;
    xSalF=EncerrarObjetos(xSalF,BordesSeg,1,1,0);
    XI=xSal;
    xSal=EncerrarObjetos(xSal,BordesSeg,1,1,1);
    figure(13)
    clf(13);
    imshow([xinit XI,xSal],[],'InitialMagnification',1024)
    if im==ims(end)
      for ob=1:1:size(TbPos,1)
          
          yval=0;
          xval=0;
          for it=1:1:im     
                if it==1
                    yval=[39,round(TbPos(ob,1,im)+1.1)];
                    xval=[40,round(TbPos(ob,2,im))-1.1];
                else
                    yval=[yval,[round(TbPos(ob,1,im-1)+1.1),round(TbPos(ob,2,im)+1.1)]];
                    xval=[xval,[round(TbPos(ob,2,im-1)-1.1),round(TbPos(ob,2,im)-1.1)]];
                end
            end
            switch ob
                    case 1
                        color='g';
                    case 2
                        color='y';
                    case 3
                        color='r';
                    case 4
                        color='b';
                    case 5
                        color='m';
                    case 6
                        color='y';
                    otherwise
                        color=[0.4940 0.1840 0.5560];
                end
                if sum(ismember([(-1:1:10)],xval).*1.0)==0 || sum(ismember([(-1:1:10)],yval).*1.0)==0
                 line(xval,yval,'Color',color,'LineStyle','--','LineWidth',1)
                 line(xval+size(X0,2)*2,yval,'Color',color,'LineStyle','--','LineWidth',1)
    %              pause(0.25);
                end
      end
    end
    sumaux=(im-1)*79;
    if auxSal==0
        Xs=[xSalF;XI;xSal];
    else
        Xs=[Xs,[xSalF;XI;xSal]];
    end
    auxSal=1;
end
 figure(30)
 imshow(Xs,[],'InitialMagnification',1024)
