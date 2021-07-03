%SYED ALI ABBAS RIZVI 2017114
%ABHISHEKGUPTA 2017005
%% reading video
trafficObj=VideoReader("production ID_4261469.mp4");
vidObj = VideoWriter('new.avi');
open(vidObj);
get(trafficObj);
l=2160;
b=3840;
M=zeros(2,b,l);
% implay("production ID_4261469.mp4");

for i=2:trafficObj.NumFrames
    
    %% reading frame
    f1=read(trafficObj,i);
    f2=read(trafficObj,i-1);
    figure('visible','off'),imshow(f1,[]);
   
    %% forming mask and applying mask on frame   
    points=[6.45515543632992 1754.5769877349;966.5 1026.5;1706.45515543633 1018.5769877349;1878.55666459152 2146.85716235918;21.7440195533473 2135.09180560075];
    points1=[2738.5 2158.5;2079.58777994223 1115.92986521482;2546.5 1046.5;3775.23501083963 1830.54448628527;3835.36336056657 2127.82100125268];
    roi = images.roi.Freehand(gca,'Position',points);
    roi1 = images.roi.Freehand(gca,'Position',points1);
    mask = createMask(roi);
    mask1=createMask(roi1);
    cM = imbinarize(imadd(mask, mask1));
    f1 = bsxfun(@times, f1, cast(cM,class(f1)));
    f2 = bsxfun(@times, f2, cast(cM,class(f2)));

    
    %% preprocessing
    bgp=rgb2gray(f1);
    bgp = edge(bgp, 'sobel');
    fgp=rgb2gray(f2);
    fgp = edge(fgp, 'sobel');
    Gobj=bgp-fgp;

    Gtuned=Gobj;


    Gtuned = medfilt2(Gtuned,[2,2]);
   

    se=strel('square',16);
    Gmorph=imclose(Gtuned,se);

    Gfilled=imfill(Gmorph,18,'holes');
   
    T=graythresh(Gfilled);
    
    Gbin = imbinarize(Gfilled,T*0.8);

    sedisk=strel('square',16);
    Gbin=imopen(Gbin,sedisk);

    gdash=imfill(Gbin,18,'holes');
    st = regionprops(gdash, 'BoundingBox' );
    frame=read(trafficObj,i);
    %% inserting bounding box in original image
    for k = 1:length(st)
       thisBB = st(k).BoundingBox;
       if thisBB(3) *thisBB(4)>15000
            frame=insertShape(frame,'rectangle', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],'LineWidth',5 );
       end

    end
    base=sprintf("Image/Image%d.png",i);
    ful=fullfile(pwd,base);
    imwrite(frame,ful);

    
end
close(vidObj);
%%
%Syed Ali Abbas Rizvi 2017114
%Abhishek Gupta 2017005 For Counting
countl=0;% stores the vehicles on the left side
countr=0;% stores the vehicles on the right side
l=[];
r=[];
arl=[];
arr=[];
for j=2:538
    base=sprintf("BinaryImage/BinImage%d.png",j);
    f1=(imread(base));
    scen=regionprops(f1,'Centroid');%calculates the centroid of vehicles in binary image
    sbb=regionprops(f1,'BoundingBox');%Bounding Box calculation
    
    %The below loop checks for detected objects and sees if their areas are
    %greater than 15000. Then the objects are counted as vehicles if their
    %centroid's y coordinaates satisfy some criterias
    
    for i=1:size(scen,1)
        bb=sbb(i).BoundingBox;
        ar=bb(3)*bb(4);%area of bounding box, accept only if ar>15000
        centroid=scen(i).Centroid;%centroid of a region
        centx=centroid(1);
        centy=centroid(2);
        if centx<1920 && (centy>=1170 && centy<=1175) && ar>15000
            countl=countl+1;
            l=[l,j];
            arl=[arl,ar];
           
        end
        if centx>=1920 && (centy>=1248 && centy<=1256) && ar>15000
            r=[r,j];
            arr=[arr,ar];
            countr=countr+1;
        end
        
    end
    
end
count=countl+countr;
answ=sprintf("The number of vehicles is %d",count);
disp(answ);
        