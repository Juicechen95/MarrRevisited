%addpath('/mnt/sh_flex_storage/chenzhij/data/nyud/data/')
clear;
E1 = {}; E2 = {};
gt3_location = '/mnt/sh_flex_storage/chenzhij/data/marr_nyud/dataset/GT_Normals/test';
%=====gt_path======
%1 data/yindaz_surface_normal/torch_data
%2 data/marr_nyud/GT/test/0
%3 data/yindaz_surface_normal/gt3/normals_gt/normals
pred_location = '/mnt/sh_flex_storage/chenzhij/data/marr_nyud/best_model/';%_physic_nyufinetune  _opengl
testname = '/mnt/sh_flex_storage/chenzhij/data/yindaz_surface_normal/torch_data/testlist2.txt';

fid0 = fopen(testname);
%% loop/654
for i = 0:653
    % load png
    tline = fgetl(fid0);
    if ~ischar(tline)
        break;
    end
    ipos = strfind(tline, '_data');
    imgid = tline(ipos+6:ipos + 9);
    imgid2 = str2num(imgid)+1;
    
    gt3_lo = sprintf('%s/%05d.png', gt3_location, imgid2)%gt3
    mask_lo = sprintf('%s_valid.png',tline);
    pred_lo = sprintf('%s%06d.png',pred_location,imgid2)
    
%     gt3 = im2double(imresize(imread(gt3_lo),0.5));
%     mask = im2double(imresize(imread(mask_lo), 0.5));
%     pred = im2double(imresize(imread(pred_lo), 0.5));
    gt2 = im2double(imresize(imread(gt3_lo),[224,224],'bilinear', 'antialiasing', false));
    %gt3 = gt2(:,:,[2 3 1]);
    mask = im2double(imresize(imread(mask_lo), [224,224],'bilinear', 'antialiasing', false));
    pred = im2double(imresize(imread(pred_lo), [224,224],'bilinear', 'antialiasing', false));
    
    
    % normalization
    gt3_n = bsxfun(@rdivide,gt3,sum(gt3.^2,3).^0.5+eps);
    pred_n = bsxfun(@rdivide,pred,sum(pred.^2,3).^0.5+eps);
    %error map
    theta3 = acosd(min(1,max(-1,sum(gt3_n.*pred_n,3))));
    alltheta = ones([size(gt3_n,1),size(gt3_n,2)]);
    
    E2{i+1} = theta3(find(alltheta));
    E4{i+1} = theta3(find(mask));
end
%accumulate them
A2 = cat(1,E2{:});%nomask
A4 = cat(1,E4{:});%gt3

fprintf('Without Mask:        %f %f %f %f %f %f\n', [mean(A2(:)),median(A2(:)),mean(A2.^2).^0.5,mean(A2<11.25),mean(A2<22.5),mean(A2<30)]);
fprintf('gt3 With Mask:           %f %f %f %f %f %f\n', [mean(A4(:)),median(A4(:)),mean(A4.^2).^0.5,mean(A4<11.25),mean(A4<22.5),mean(A4<30)]);

