clear; clear all;
cnn_input_size = 224;
testname = '/mnt/sh_flex_storage/chenzhij/data/yindaz_surface_normal/torch_data/testlist2.txt';
gt_location = '/mnt/sh_flex_storage/chenzhij/data/marr_nyud/dataset/GT_Normals/test/';
gt_yindaz = '/mnt/sh_flex_storage/chenzhij/data/yindaz_surface_normal/torch_data';
gt_silberman = '/mnt/sh_flex_storage/chenzhij/data/yindaz_surface_normal/gt3/normals_gt/normals/';
save_path = '/home/chenzhij/project/MarrRevisited/normals/cachedir/GT_mat/gt_silberman/';
fid0 = fopen(testname);
for i = 0:653
    tline = fgetl(fid0);
    if ~ischar(tline)
        break;
    end
    ipos = strfind(tline, '_data');
    imgid = tline(ipos+6:ipos + 9);
    imgid2 = str2num(imgid)+1;
    mask_lo = sprintf('%s_valid.png',tline);
    %gt_lo = sprintf('%s%05d.png', gt_location,imgid2);
    %gt_lo = sprintf('%s_norm_camera.png',tline);%yindaz
    gt_lo = sprintf('%s%s.png',gt_silberman,imgid);%silberman
    
    mask = im2uint8(imread(mask_lo));
%     gt = im2uint8(imread(gt_lo));
%     j_ims = single(gt(:,:,[3 2 1]));
%     j_tmp = imresize(j_ims, [cnn_input_size, cnn_input_size], ...
%                            'bilinear', 'antialiasing', false);
    gt = (imread(gt_lo));
    j_tmp = imresize(gt, [cnn_input_size, cnn_input_size], ...
                           'bilinear', 'antialiasing', false);
        %j_tmp = j_tmp - image_mean;
    %gt_ims(:,:,:,1) = permute(j_tmp, [2 1 3]);
    nx = j_tmp(:,:,1);
    ny = j_tmp(:,:,2);	
    nz = j_tmp(:,:,3);
    depthValid = imresize(mask, [cnn_input_size, cnn_input_size], ...
                           'bilinear', 'antialiasing', false);
    save_file_name = [save_path, imgid];
    if(exist([save_file_name, '.mat'], 'file'))
        %continue;
    end
    % imwrite(predns_vis, [save_file_name, '.png']);
    save([save_file_name, '.mat'], 'nx', 'ny','nz','depthValid');
end