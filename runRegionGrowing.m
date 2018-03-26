img_path = 'C:/Users/Kristi/Documents/PSC/4K_train_img';
centers_path = 'C:/Users/Kristi/Documents/PSC/4K_train_centers';
images_dir = dir(img_path);
centers_dir = dir(centers_path);
save_path = 'C:/Users/Kristi/Desktop/4K_train_regiongrowing';


skip = 2;	% skipping the first 2 referential files - '.' and '..'

min_region_size = 30; % change these parameters based on the expected size segmented regions
max_region_size = 2500;


for i = 1:length(images_dir)        
    I3 = im2double(imread(strcat(img_path, '/', images_dir(i + skip).name)));
    I4 = imsharpen(I3);
    I2 = rgb2gray(I4);
    I = medfilt2(I2, [2,2]); % median filter = noise reduction without affecting borders
    flooded = I3;
    
    centers = load(strcat(centers_path, '/', centers_dir(i + skip).name));
    for clickpoint = 1:size(centers,2)
        flood = true;
        x = centers(1,clickpoint);
        y = centers(2,clickpoint);
        J = regiongrowing(I,x,y,0.2,min_region_size,max_region_size); 
        if sum(sum(sum(J))) > max_region_size %keep trying smaller max intensity differences if grown region is very large (most likely spilling over)
            J = regiongrowing(I,x,y,0.1,min_region_size,max_region_size);
            if sum(sum(sum(J))) > max_region_size
                J = regiongrowing(I,x,y,0.05,min_region_size,max_region_size);
                if sum(sum(sum(J))) > max_region_size
                    J= regiongrowing(I,x,y,0.01,min_region_size,max_region_size);
                    if sum(sum(sum(J))) > max_region_size    
                       flood = false;
                    end
                end
            end
        end

        if(flood)
            filledJ = imfill(J(:,:,1), 'holes');
            if(sum(sum(filledJ))>50) % dont mess with small neurons
                openedJ = imopen(filledJ, strel('disk',1)); % remove thin connections
                CC = bwconncomp(openedJ, 4);
                s = regionprops(CC,'Centroid');
                for cc = 1:CC.NumObjects
                    contains_center = sum(ismember(sub2ind([360, 480], x, y), CC.PixelIdxList{cc}, 'rows'));
                    if contains_center == 0 || abs(s(cc).Centroid(2)-x) > 18 || abs(s(cc).Centroid(1)-y) > 18
                        openedJ((CC.PixelIdxList{cc})) = 0; % delete connected component if doesnt contain clickpoint or clickpoint is offcenter (probably leaking)
                    end
                end
            else
                 openedJ = filledJ;
            end
            ind = find(openedJ==1);
            [x,y] = ind2sub([360,480],ind);
            for z=1:size(x,1)
               flooded(x(z),y(z),:) = [0,1,0];
            end
        end



        %centers = red x's
%         for c=1:size(centers,2)
%             flooded(centers(1,c),centers(2,c),:) = [255,0,0];
%             flooded(min(360,centers(1,c)+1),max(1,centers(2,c)-1),:) = [255,0,0];
%             flooded(min(360,centers(1,c)+1),min(480,centers(2,c)+1),:) = [255,0,0];
%             flooded(max(1,centers(1,c)-1),max(1,centers(2,c)-1),:) = [255,0,0];
%             flooded(max(1,centers(1,c)-1),min(480,centers(2,c)+1),:) = [255,0,0];
%         end
    end
%      figure, imshowpair(I3, flooded, 'montage');
    
	imwrite(flooded, strcat(save_path, '/', images_dir(i + skip).name))
end