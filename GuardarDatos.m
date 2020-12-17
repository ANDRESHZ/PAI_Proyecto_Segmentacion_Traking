function [Inicial,ObjSeg,BordesSeg]=GuardarDatos(Inicial,ObjSeg,ObjActu,BordesSeg,BordeActu)
    if Inicial==0
                    ObjSeg=ObjActu;
                    BordesSeg=BordeActu;
                    Inicial=1;
    else
        intro=0;
        menosd=0;
        for iter2=1:1:size(ObjSeg,3)
               iter=iter2-menosd;
               ObjSegP=ObjSeg(:,:,iter2-menosd);
               ObjSegP = ObjSegP(any(ObjSegP,2),:);
               flagSI=size(ObjActu,1)>size(ObjSegP,1);
               if flagSI
                   bz=ObjSegP;
                   az=ObjActu;       
               else
                   az=ObjSegP;
                   bz=ObjActu;
               end
               YaEsta=mean2(ismember(bz,az,'rows').*1.0)>0.6;
               if YaEsta
                  if flagSI
                    if size(ObjSeg,3)==1
                        Inicial=0;
                    else
                        if iter>=2
                            ObjSeg3=zeros(size(ObjSeg,1),2,size(ObjSeg,3)-1);
                            ObjSeg3(:,:,1:iter-1)=ObjSeg(:,:,1:iter-1);
                            BordesSeg3=zeros(size(BordesSeg,1),2,size(BordesSeg,3)-1);
                            BordesSeg3(:,:,1:iter-1)=BordesSeg(:,:,1:iter-1);
                            if size(ObjSeg,3)>iter
                                ObjSeg3(:,:,iter:size(ObjSeg,3)-1)=ObjSeg(:,:,iter+1:size(ObjSeg,3));
                                BordesSeg3(:,:,iter:size(BordesSeg,3)-1)=BordesSeg(:,:,iter+1:size(BordesSeg,3));
                            end
                        else
                            ObjSeg3=ObjSeg(:,:,2:size(ObjSeg,3));
                            BordesSeg3=BordesSeg(:,:,2:size(BordesSeg,3));
                        end
                        ObjSeg=ObjSeg3;
                        BordesSeg=BordesSeg3;
                        menosd=menosd+1;
                        intro=1;
                    end
                  else
                    intro=0;
                  end
               else
                   intro=1;
               end
        end
        %ObjSeg     
        if intro==1 && Inicial==1
            tamObjs=size(ObjSeg,1);
            if(tamObjs>size(ObjActu,1))
                ObjActu=[ObjActu;zeros(tamObjs-size(ObjActu,1),2)];
            elseif (tamObjs<size(ObjActu,1))
                ObjSeg2=zeros(size(ObjActu,1),2,size(ObjSeg,3));
                ObjSeg2(1:tamObjs,:,:)=ObjSeg;
                ObjSeg=ObjSeg2;
    %             ObjSeg=[ObjSeg;zeros(size(ObjActu,1)-tamObjs,2)];
                tamObjs=size(ObjActu,1);
            end
            ObjSegAUX=zeros(tamObjs,2,size(ObjSeg,3)+1);
            ObjSegAUX(:,:,1:size(ObjSeg,3))=ObjSeg;
            ObjSegAUX(:,:,end)=ObjActu;
            ObjSeg=ObjSegAUX;

            %BordesSeg
            tamBord=size(BordesSeg,1);
            if(tamBord>size(BordeActu,1))
                BordeActu=[BordeActu;zeros(tamBord-size(BordeActu,1),2)];
            elseif (tamBord<size(BordeActu,1))
               BordesSeg2=zeros(size(BordeActu,1),2,size(BordesSeg,3));
               BordesSeg2(1:tamBord,:,:)=BordesSeg;
               BordesSeg=BordesSeg2;
    %             BordesSeg=[BordesSeg;zeros(size(BordeActu,1)-tamBord,2)];
                tamBord=size(BordeActu,1);        
            end
            BordesSegAUX=zeros(tamBord,2,size(BordesSeg,3)+1);
            BordesSegAUX(:,:,1:size(BordesSeg,3))=BordesSeg;
            BordesSegAUX(:,:,end)=BordeActu;
            BordesSeg=BordesSegAUX;
        else
            if Inicial==0
                    ObjSeg=ObjActu;
                    BordesSeg=BordeActu;
                    Inicial=1;
            end
        end
    end
end