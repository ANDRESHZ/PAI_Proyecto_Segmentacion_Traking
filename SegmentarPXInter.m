function [Bin,ObjActuPX]=SegmentarPXInter(Bin,ObjActu)
    pos=0;
    n=size(Bin,1);
    m=size(Bin,2);
    Bin2=zeros(size(Bin));
    while size(ObjActu,1)>pos
        pos=pos+1;             
        jv=ObjActu(pos,1);
        iv=ObjActu(pos,2);
        Bin(jv,iv)=0;
        izq=iv>1;
        der=iv<m;
        arr=jv>1;
        abj=jv<n;                
        if izq %izquierda
            if Bin(jv,iv-1)==1
                ObjActu=[ObjActu;[jv,iv-1]];
                Bin(jv,iv-1)=0;
                Bin2(jv,iv-1)=1;
            end                       
        end
        if izq&arr %izquierda arriba
            if Bin(jv-1,iv-1)==1
                ObjActu=[ObjActu;[jv-1,iv-1]];
                Bin(jv-1,iv-1)=0;
                Bin2(jv-1,iv-1)=1;
            end                       
        end
        if arr %arriba
            if Bin(jv-1,iv)==1
                ObjActu=[ObjActu;[jv-1,iv]];
                Bin(jv-1,iv)=0;
                Bin2(jv-1,iv)=1;
            end                       
        end
        if arr&der %derecha arriba
            if Bin(jv-1,iv+1)==1
                ObjActu=[ObjActu;[jv-1,iv+1]];
                Bin(jv-1,iv+1)=0;
                Bin2(jv-1,iv+1)=1;
            end                       
        end
        if der %derecha
            if Bin(jv,iv+1)==1
                ObjActu=[ObjActu;[jv,iv+1]];
                Bin(jv,iv+1)=0;
                Bin2(jv,iv+1)=1;
            end                       
        end
        if der&abj %derecha abajo
            if Bin(jv+1,iv+1)==1
                ObjActu=[ObjActu;[jv+1,iv+1]];
                Bin(jv+1,iv+1)=0;
                Bin2(jv+1,iv+1)=1;
            end                       
        end
        if abj %abajo
            if Bin(jv+1,iv)==1
                ObjActu=[ObjActu;[jv+1,iv]];
                Bin(jv+1,iv)=0;
                Bin2(jv+1,iv)=1;
            end                       
        end
        if izq&abj %izquierda abajo
            if Bin(jv+1,iv-1)==1
                ObjActu=[ObjActu;[jv+1,iv-1]];
                Bin(jv+1,iv-1)=0;
                Bin2(jv+1,iv-1)=1;
            end                       
        end
        %fin vecindad 8
    end
    ObjActuPX=ObjActu;
end