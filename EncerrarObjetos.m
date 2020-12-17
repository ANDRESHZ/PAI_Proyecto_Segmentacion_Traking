function xSal=EncerrarObjetos(xSal,BordesSeg,Cuadros,Mas,Bordes)
%Cuadros: si es mayor a 0 hace recuadros sobre los objetos.
%  Mas: cunatos pixeles alrededor del recudaro se movera.
%Bordes: si es mayor a 0 Colorea los bordes del objeto.
Nbordes=size(BordesSeg,3);
    for Z=1:Nbordes
        minX=1000;
        minY=1000;
        maxX=-1;
        maxY=-1;
       for X=1:size(BordesSeg,1)
           if BordesSeg(X,1,Z)>0 & minX>BordesSeg(X,1,Z)-Mas
               minX=BordesSeg(X,1,Z)-Mas;
           end
           if BordesSeg(X,2,Z)>0 & minY>BordesSeg(X,2,Z)-Mas
               minY=BordesSeg(X,2,Z)-Mas;
           end
           if(BordesSeg(X,1,Z)>0 & BordesSeg(X,2,Z)>0)& Bordes>0%% marcar Bordes
               xSal(BordesSeg(X,1,Z),BordesSeg(X,2,Z),mod(Z,3)+1)=110;
               xSal(BordesSeg(X,1,Z),BordesSeg(X,2,Z),mod(Z+1,3)+1)=110;
               xSal(BordesSeg(X,1,Z),BordesSeg(X,2,Z),mod(Z+2,3)+1)=xSal(BordesSeg(X,1,Z),BordesSeg(X,2,Z),mod(Z+2,3)+1)*0.5;
           end
       end
       maxX=max(BordesSeg(:,1,Z))+Mas;
       maxY=max(BordesSeg(:,2,Z))+Mas;

       if Cuadros>0
           media=mean2(xSal(minX:maxX,minY,1));
           media=media+mean2(xSal(minX:maxX,maxY,1));
           media=media+mean2(xSal(minX,minY:maxY,1));
           media=media+mean2(xSal(maxX,minY:maxY,1));
           media=media/4;
           if media>100
               xSal(minX:maxX,minY,:)=xSal(minX:maxX,minY,:)-(media*0.5);
               xSal(minX:maxX,maxY,:)=xSal(minX:maxX,maxY,:)-(media*0.5);
               xSal(minX,minY:maxY,:)=xSal(minX,minY:maxY,:)-(media*0.5);
               xSal(maxX,minY:maxY,:)=xSal(maxX,minY:maxY,:)-(media*0.5);
           end   
            
           xSal(minX:maxX,minY,mod(Z,3)+1)=104*(Z/Nbordes)+150;
           xSal(minX:maxX,maxY,mod(Z,3)+1)=104*(Z/Nbordes)+150;
           xSal(minX,minY:maxY,mod(Z,3)+1)=104*(Z/Nbordes)+150;
           xSal(maxX,minY:maxY,mod(Z,3)+1)=104*(Z/Nbordes)+150;
       end
    end
end