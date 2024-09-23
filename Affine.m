function img = GetImage(filename)
% this function accepts the filename of an image and returns the image

% read an image in the workspace
img = imread(filename);

end 

function [l_inf] = GetLineInf(img)
%{ 
this function accepts vanishing points and calculates the coordintes 
for the line at ifinity
%}

% showing the image
imshow(img)
    
%{ 
finds two pairs of parallel lines by finding 2 consecutive points
on a line, then 2 points on the line parallel to it, then repeating 
for other set of parallel lines
%}
f = msgbox('Click on two points on any line in the image, then click on two points on a different line that is parallel to the previous line. Repeat these steps with two different parallel lines that are perpendicular to the previous pair of lines for a total of 4 lines and 8 clicks.');
points = ginput(8);
p1 = [points(1,1), points(1,2), 1];
p2 = [points(2,1), points(2,2), 1];
p3 = [points(3,1), points(3,2), 1];
p4 = [points(4,1), points(4,2), 1];
p5 = [points(5,1), points(5,2), 1];
p6 = [points(6,1), points(6,2), 1];
p7 = [points(7,1), points(7,2), 1];
p8 = [points(8,1), points(8,2), 1];
   
% computing the lines for the previously chosen points
l1 = cross(p1', p2');
l2 = cross(p3', p4');
l3 = cross(p5', p6');
l4 = cross(p7', p8');
    
% computing the vanishing points for each pair of parallel lines
v1 = cross(l1, l2);
v2 = cross(l3, l4);

% computing the coordinates for the line at infinity
l_inf = cross(v1, v2);
l_inf = l_inf./l_inf(3);

end 

function homography = ConstructHomography(l)
%{ 
accepts the coordinates for the line at infinity and constructs the
affinity homography and returns the inverse of it
%}

% computing the homography
homography = [1, 0, 0; 0, 1, 0; l(:)'];

end

function outim = TransformImage(im, H)
% This function takes as input an image im and a 3x3 homography H to return
% the transformed image outim
%

% Matlab function imtransform assumes transpose of H as input
tform = maketform('projective',H');
% Next line returns the x and y coordinates of the bounding box of the 
% transformed image through H
[boxx, boxy]=tformfwd(tform, [1 1 size(im,2) size(im,2)], [1 size(im,1) 1 size(im,1)]);
% Find the minimum and maximum x and y coordinates of the bounding box
minx=min(boxx); maxx=max(boxx);
miny=min(boxy); maxy=max(boxy);
% Transform the input image
outim =imtransform(im,tform,'XData',[minx maxx],'YData',[miny maxy],'Size',[size(im,1),round(size(im,1)*(maxx-minx)/(maxy-miny))]);

end

input = inputdlg('Enter the name of the image file. Ensure the file is already saved to either your local workspace your Matlab drive.');
% importing image into workspace
img = GetImage(input{1});
% calculating the line at infinity
l_inf = GetLineInf(img);
% constructing the inverse of the homography that transformed the image
homography = ConstructHomography(l_inf);
% rectifying the image
rect_img = TransformImage(img, homography);
% showing the rectified image
imshow(rect_img)