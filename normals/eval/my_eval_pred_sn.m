% --------------------------------------------------------------------------- %
% MarrRevisited - Surface Normal Estimation
% Copyright (c) 2016 Adobe Systems Incorporated and Carnegie Mellon University. 
% All rights reserved.[see LICENSE for details]
% -------------------------------------------------------------------------- %

% Written by Aayush Bansal. Please contact ab.nsit@gmail.com
function[nums_e] = my_eval_pred_sn(cache_dir, cache_list)

	num_images = length(cache_list);
	cache_list = cache_list -1;
    
	for i = 1:num_images
	
		% load the file from cache
		display(['Loading image: ', num2str(i, '%04d'),'/',...
					    num2str(num_images, '%04d')]);

		% CHANGE THE NAME OF THE DATA FILE -- if 
		%pred = load([cache_dir, num2str(cache_list(i), '%04d'), '.png.mat'],  'predns');
	    pred = imread([cache_dir, num2str((cache_list(i)+1), '%06d'), '.png']); 
        %pred_lo = sprintf('%storch_data_%04d_normal_est.png',cache_dir,cache_list(i));%yindaz_pred
        %pred = imread(pred_lo); %yindaz_pred
        pred_1 = pred(:,:,[2 1 3]);%gt_ladicky
        %pred_1 = pred(:,:,[3 1 2]);%gt_yindaz
        %pred_1 = pred(:,:,[1 2 3]);%pred_yindaz & gt_yindaz
        gtd1 = load(['/home/chenzhij/project/MarrRevisited/normals/cachedir/GT_mat/gt_ladicky1/',...
					 num2str(cache_list(i),'%04d') '.mat']);
        gtd = load(['/mnt/sh_flex_storage/chenzhij/data/marr_nyud/GT/test_data/nm_',...
					 num2str((cache_list(i)+1),'%06d') '.mat']);
		NG = cat(3,gtd.nx,gtd.ny,gtd.nz);
		NV = imresize(gtd.depthValid,[224,224]);
		%
        
		NP = imresize(pred_1,...
                 [224, 224]);
        NG = double(NG);
        NP = double(NP);
		%normalize both to be sure
	        NG = bsxfun(@rdivide,NG,sum(NG.^2,3).^0.5);
                NP = bsxfun(@rdivide,NP,sum(NP.^2,3).^0.5);
		%compute the dot product, and keep on the valid
		DP = sum(NG.*NP,3);
		T = min(1,max(-1,DP));
		pixels{i} = T(find(NV));
	end

	E = acosd(cat(1,pixels{:}));
	nums_e = [mean(E(:)),median(E(:)),mean(E.^2).^0.5,mean(E < 11.25)*100,mean(E < 22.5)*100,mean(E < 30)*100]
	display('---------------------------------------');
	display(['Mean: ', num2str(mean(E(:)))]);
	display(['Median: ', num2str(median(E(:)))]);
	display(['RMSE: ', num2str(mean(E.^2).^0.5)]);
	display(['11.25: ', num2str(mean(E < 11.25)*100)]);
	display(['22.5: ', num2str(mean(E < 22.5)*100)]);
	display(['30: ', num2str(mean(E < 30)*100)]);
	display(['45: ', num2str(mean(E < 45)*100)]);
	display('---------------------------------------');
end
