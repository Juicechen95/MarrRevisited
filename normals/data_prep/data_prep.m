% --------------------------------------------------------------------------- %
% MarrRevisited - Surface Normal Estimation
% Copyright (c) 2016 Adobe Systems Incorporated and Carnegie Mellon University. 
% All rights reserved.[see LICENSE for details]

%prepare datalayer for caffe
%by chenzhi
% -------------------------------------------------------------------------- %

% Written by Aayush Bansal. Please contact ab.nsit@gmail.com
% demo code to use the surface normal mode --
clc; clear all;


conv_cache = ['/mnt/sh_flex_storage/chenzhij/data/marr_nyud/dataset/img_set/prep_data/test/'];
testname = '/mnt/sh_flex_storage/chenzhij/data/yindaz_surface_normal/torch_data/trainlist2.txt';
gt_lo = '/mnt/sh_flex_storage/chenzhij/data/marr_nyud/GT/nyu_v2_data/';
if(~isdir(conv_cache))
        mkdir(conv_cache);
end

cnn_input_size = 224;
crop_height = 224; crop_width = 224;
image_mean = cat(3,  103.9390*ones(cnn_input_size),...
		     116.7700*ones(cnn_input_size),...
		     123.6800*ones(cnn_input_size));
%% read the image set for NYU
% img_set = 'test';%train-381
% imgLabs = load(['/mnt/sh_flex_storage/chenzhij/data/marr_nyud/dataset/img_set/',img_set,'.mat'], 'img_set');
% imgLabs = imgLabs.img_set;% testlist

fid0 = fopen(testname);
for i = 0:794
    tline = fgetl(fid0);
    if ~ischar(tline)
        break;
    end

	display(['Image : ', int2str(i)]);
    imgname = sprintf('%s_color.png', tline);
	ith_Img = im2uint8(imread(imgname));
    ipos = strfind(tline, '_data');
    imgid = tline(ipos+6:ipos + 9);
        %save_file_name = [conv_cache, imgid];
        %if(exist([save_file_name, '.mat'], 'file'))
                %continue;
        %end
        j_ims = single(ith_Img(:,:,[3 2 1]));
        j_tmp = imresize(j_ims, [cnn_input_size, cnn_input_size], ...
                           'bilinear', 'antialiasing', false);
        j_tmp = j_tmp - image_mean;
        ims(:,:,:,1) = permute(j_tmp, [2 1 3]);	%duicheng,xuanzhuan

        
        gt_name = sprintf('%s%06d.mat', gt_lo, str2num(imgid)+1)
        gt_mat = load(gt_name);
        gt = cat(3,gt_mat.nx,gt_mat.ny,gt_mat.nz);
		mask = gt_mat.depthValid;
        gt_tmp = imresize(gt, [cnn_input_size, cnn_input_size], ...
                           'bilinear', 'antialiasing', false);
        mask_tmp = imresize(mask, [cnn_input_size, cnn_input_size], ...
                           'bilinear', 'antialiasing', false);                     
        snds(:,:,:,1) = permute(gt_tmp, [2 1 3]);
        depds(:,:,:,1) = permute(mask_tmp, [2 1 3]);
        
        snd = (1/sqrt(3))*ones(cnn_input_size+200, cnn_input_size+200,3);%gt each point is 1/genhao3
        depd = zeros(cnn_input_size+200, cnn_input_size+200);% mask
        snd(101:crop_width+100, 101:crop_width+100, :, 1) = snds;
        depd(101:crop_width+100, 101:crop_width+100, :, 1) = depds;

        input_data = zeros(crop_height+200,crop_width+200,3,1);
        input_data(101:crop_width+100, 101:crop_width+100, :, 1) = ims;

        data0(:,:,:,i+1) = input_data;
        data1(:,:,:,i+1) = snd;
        data2(:,:,:,i+1) = depd;
        
        %imwrite(predns_vis, [save_file_name, '.png']);
        %save([save_file_name, '.mat'], 'data0','data1','data2')
end

hdf5write('./data_prep/nyu_794train.h5', '/data0', single(data0));
hdf5write('./data_prep/nyu_794train.h5', '/data1', single(data1), 'WriteMode', 'append');
hdf5write('./data_prep/nyu_794train.h5', '/data2', single(data2), 'WriteMode', 'append');
