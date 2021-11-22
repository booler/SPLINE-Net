
clear;
num_lights = 10;

num_instance = 10;
total_lights = 96;
samplelist={'ballPNG','bearPNG','buddhaPNG','catPNG','cowPNG','gobletPNG','harvestPNG','pot1PNG','pot2PNG','readingPNG'};


outputdir = ['./diligent_test' num2str(num_lights) '/'];
mkdir(outputdir);


for i = 1 : 10
    mkdir([outputdir num2str(i)]);
    for j = 1 : size(samplelist,2)
%         if j == 2
%             temp = randperm(total_lights-20)+20;
%             test_ind = temp;
%         else
            temp = randperm(total_lights);
            test_ind = temp(1:num_lights);
%         end
        
        sample = samplelist{j};
        dlmwrite([outputdir num2str(i) '/' sample '.txt'], test_ind, 'delimiter', '\\','precision', 6);    
    end
end

close all;clear all;clc;
num_lights=10; % by zq


samplelist={'ballPNG','bearPNG','buddhaPNG','catPNG','cowPNG','gobletPNG','harvestPNG','pot1PNG','pot2PNG','readingPNG'};
D=[];

w=32;
main_dir = ['./dtest_lighting_1_' num2str(num_lights) '/'];
dataset_dir = 'D:\backup\photometric stereo\dataset\DiliGenT\DiLiGenT\pmsData\';
mkdir(main_dir);
for r=1:10
    mkdir([main_dir num2str(r)]);
    for k=1:10
        sample=samplelist{1,k};
        fid1=fopen([dataset_dir sample '/light_directions.txt'],'rt');
        fid2=fopen([dataset_dir sample  '/light_intensities.txt'],'rt');
        fid3=fopen([dataset_dir sample '/filenames.txt'],'rt');
        mkdir([main_dir num2str(r),'/' sample]);
        L=[];
        Li=[];
        imglist={};
        
        while feof(fid1)~=1
            line1=str2num(fgetl(fid1));
            %             delta = sin(pi/90).^2/2;
            %             out = Generate_Gaussian_Noise_for_Vector(line1, delta);
            L=[L;line1];
        end
        
        %         test_ind=randperm(96,10);
        %         if k==2
        %             test_ind=randperm(76,10)+20;
        %         end
        fid_ind=fopen(['./diligent_test' num2str(num_lights) '/' num2str(r) '/' sample '.txt'],'rt'); % by zq
        line_ind=fgetl(fid_ind);
        line_ind=strsplit(line_ind,'\');
        test_ind=[];
        for i=1:size(line_ind,2)
            test_ind=[test_ind str2num(line_ind{1,i})];
        end
        
        Ld=L(test_ind,:);
        
        x= 0.5*(Ld(:,1)+1)*(w-1);
        x=round(x);
        y= 0.5*(Ld(:,2)+1)*(w-1);
        y=round(y);
        mapind=y*w+x+1;
        
        dlmwrite([main_dir num2str(r) '/' sample '.txt'], test_ind, 'delimiter', '\\','precision', 6);
        
        while feof(fid2)~=1
            line2=str2num(fgetl(fid2));
            Li=[Li;line2];
        end
        Li=Li(test_ind,:);
        
        while feof(fid3)~=1
            line3=fgetl(fid3);
            imglist=[imglist;line3];
        end
        
        load([dataset_dir sample '/Normal_gt.mat' ]);
        mask=sum(Normal_gt.^2,3)>0;
        maskind=find(mask==1);
        normals=reshape(Normal_gt,[size(Normal_gt,1)*size(Normal_gt,2) 3]);
        normals=normals(maskind,:);
        
        imgall={};
%         if  k==2
%             for i=1:num_lights-20 % by zq
%                 img=imread([dataset_dir sample '/' imglist{test_ind(i)}]);
%                 img=im2double(img);
%                 img(:,:,1)=img(:,:,1)/Li(i,1);
%                 img(:,:,2)=img(:,:,2)/Li(i,2);
%                 img(:,:,3)=img(:,:,3)/Li(i,3);
%                 img=rgb2gray(img);
%                 %     img=mask.*img;
%                 imgall=[imgall;img];
%             end
%         else
            
            for i=1:num_lights % by zq
                img=imread([dataset_dir sample '/' imglist{test_ind(i)}]);
                img=im2double(img);
                img(:,:,1)=img(:,:,1)/Li(i,1);
                img(:,:,2)=img(:,:,2)/Li(i,2);
                img(:,:,3)=img(:,:,3)/Li(i,3);
                img=rgb2gray(img);
                %     img=mask.*img;
                imgall=[imgall;img];
            end
%         end
        delta=[];
        data=[];
        for i=1:size(normals,1)
            map=zeros(1,1024);
            Imap=[];
%             if k==2
%                 for j=1:num_lights-20 % by zq
%                     Imap=[Imap imgall{j}(maskind(i))];
%                     map(1,mapind(j))=imgall{j}(maskind(i));
%                 end
%             else
                for j=1:num_lights % by zq
                    Imap=[Imap imgall{j}(maskind(i))];
                    map(1,mapind(j))=imgall{j}(maskind(i));
                end
%             end
            
            M=Imap>1e-6;
            Imap=Imap.*M;
            
            nx=normals(i,1);
            ny=normals(i,2);
            nz=normals(i,3);
            data=[data; maskind(i) nx ny nz mapind' Imap];
            
        end
        dlmwrite([main_dir num2str(r) '/' sample '/' sample '.txt'], data, 'delimiter', '\\','precision', 6);
        disp([r,k]);
    end
end