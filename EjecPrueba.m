clc;
media=zeros(1,30);
for i=1:1:30
    media(i)=mean2(C02tFILT(:,:,i));
end
media