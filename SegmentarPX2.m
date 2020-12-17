function [Bin,ObjActuPX]=SegmentarPX2(Bin,X0,ObjActu)

    [Bin,ObjActuPX]=SegmentarPXInter(Bin,ObjActu);
   %% maximos en objetos unidos
   if size(ObjActuPX,1)>1
       Jm=min(ObjActuPX(:,1));
       Im=min(ObjActuPX(:,2));
       JM=max(ObjActuPX(:,1));
       IM=max(ObjActuPX(:,2));
       X0p=X0(Jm:JM,Im:IM);
       X0pU=unique(X0p);
       X0pU=X0pU(2:length(X0pU)-1);
       tamp=length(X0pU);
       ObjActuPXp=[ObjActuPX(:,1)-Jm+1,ObjActuPX(:,2)-Im+1];
       ObjActuPXpOld=ObjActuPXp;
       Bin2pOld=Bin(Jm:JM,Im:IM);
       if tamp>=1
           Bin2p1=(X0p>=X0pU(1)).*1.0;
           BinDetec2=Bin2p1;
           for K1=1:1:tamp
               Bin2p=(X0p>=X0pU(K1)).*1.0;
               ObjCount=0;
                for i=(1:IM-Im)%eje X 
                     for j=(1:JM-Jm)% Eje Y
                         if Bin2p(j,i)==1
%                               [j, i] = find(ismember(X0p.*Bin2p, max(X0p(:).*Bin2p(:))));
                              BinDetec2=[BinDetec2 Bin2p];
                              Bin2pOld=Bin2p;
                              ObjActuPXpOld=ObjActuPXp;
                              [Bin2p,ObjActuPXp]=SegmentarPXInter(Bin2p,[j,i]);
                              ObjCount=ObjCount+1;
                         end
                     end
                end
                if ObjCount>1
                    break
                end
           end
           ObjActuPX=ObjActuPXpOld(:,1)+Jm-1;
           ObjActuPX=[ObjActuPX,ObjActuPXpOld(:,2)+Im-1];
           Bin(Jm:JM,Im:IM)=Bin2pOld;      
       end      
   end
end