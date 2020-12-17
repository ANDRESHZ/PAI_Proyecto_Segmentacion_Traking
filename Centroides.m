function centros=Centroides(TObjSeg)
    centros=cell(size(TObjSeg));
    for i=1:1:size(centros,1)
        if isempty(TObjSeg{i})
%             centros{i}=[];
        else
            Objs=TObjSeg{i};
            cent=zeros(size(Objs,3),2);
            for k=1:1:size(Objs,3)
                Objsp=Objs(:,:,k);
                Objsp = Objsp(any(Objsp,2),:);
                cent(k,1)=mean2(Objsp(:,1));
                cent(k,2)=mean2(Objsp(:,2));
            end
            centros{i}=cent;
        end
    end
end