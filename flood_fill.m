img_path = 'C:/Users/Kristi/Documents/PSC/1K_test_img';
centers_path = 'C:/Users/Kristi/Documents/PSC/1K_test_centers';
images_dir = dir(img_path);
centers_dir = dir(centers_path);
save_path = 'C:/Users/Kristi/Documents/PSC/1K_test_floodfill';


skip = 2;	% skipping the first 2 referential files - '.' and '..'

for i = 1:length(images_dir)
	I = imread(strcat(img_path, '/', images_dir(i + skip).name)); % raw image

	centers = load(strcat(centers_path, '/', centers_dir(i + skip).name)); % (x,y) locations of the neuron centers

	if(~isempty(centers))
		I2 = rgb2gray(I); % 3 channel RGB to 1 channel

		I3 = imbinarize(I2, 0.65); % may need to change thresholding value
		I3 = ~I3;

		I4 = bwmorph(I3,'skel',Inf); % skeleton operation

		I5 = imclose(I4 , strel('disk', 3));  % increase the size of the structing element to prevent leaking

		I6 = imfill(I5,centers'); % flood-fill

		locations_out = find(I6 & ~I5);
		[x,y] = ind2sub([360,480],locations_out);

		new_pic = I;

		%floodfill = green
		for z=1:size(x,1)
		   new_pic(x(z),y(z),:) = [0,255,0];
		end

		% red x's to mark the neuron centers
% 		for j=1:size(centers,2)
% 		    new_pic(centers(1,j),centers(2,j),:) = [255,0,0];
% 		    new_pic(centers(1,j)+1,centers(2,j)-1,:) = [255,0,0];
% 		    new_pic(centers(1,j)+1,centers(2,j)+1,:) = [255,0,0];
% 		    new_pic(centers(1,j)-1,centers(2,j)-1,:) = [255,0,0];
% 		    new_pic(centers(1,j)-1,centers(2,j)+1,:) = [255,0,0];
% 		end
	else
		x = [];
    	y = [];
    	new_pic = I;
    end

	imwrite(new_pic, strcat(save_path, images_dir(i + skip).name))
end