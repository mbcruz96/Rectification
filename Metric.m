function img = GetImage(filename)
% this function accepts the filename of an image and returns the image

% read an image in the workspace
img = imread(filename);

end 

function [v1, v2] = GetVanishingPoints(img)
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
v1 = v1./v1(3);
v2 = v2./v2(3);

end 

function points = GetConicPoints(img)
%{
 this function gets user input on 5 points around a conic and returns
 those points
%}
% showing image
imshow(img) 

% finding 5 points around a singular circle in an image
f = msgbox('Click on five points along any single circle in the image.');
points = ginput(5);
p1 = [points(1,1), points(1,2), 1];
p2 = [points(2,1), points(2,2), 1];
p3 = [points(3,1), points(3,2), 1];
p4 = [points(4,1), points(4,2), 1];
p5 = [points(5,1), points(5,2), 1];
points = [p1', p2', p3', p4', p5'];

end

function C = conicfit(pnts)       
%
% This function returns a conic fit to 5 points
%
% pnts should be in the following format
%           [x1  x2  x3  x4  x5]
%  pnts =   [y1  y2  y3  y4  y5]
%           [1   1   1   1   1 ]
%

A=[(pnts(1,:).^2)',(pnts(1,:).*pnts(2,:))',(pnts(2,:).^2)',pnts(1,:)',pnts(2,:)',pnts(3,:)'];
CC=null(A);
C=[CC(1),CC(2)/2,CC(4)/2;CC(2)/2,CC(3),CC(5)/2;CC(4)/2,CC(5)/2,CC(6)];
end

function cstar = CalculateDualConic(conic, v1, v2)
%{
this function accepts two vanishing points at the line at infinity
and calculates the circular points at the intersection of the vanishing 
points and a conic. Then calculates and returns the dual conic to those
points
%}

syms delt
% setting up systems of equations
eqn = power(delt, 2) * v2' * conic * v2 + 2 * delt * v2' * conic * v1 + v1' * conic * v1 == 0;
% solving for circular points
sol = solve(eqn, delt);
c1 = v1 + sol(1) * v2;
c2 = v1 + sol(2) * v2;
% constructing dual conic to circular points
cstar = c1*c2' + c2*c1';

end

function homography = ConstructHomography(cstar)
%{
this function accepts a dual conic at infinity and performs SVD on the
matrix. Then, by taking the square root of the singular value matrix, and
multiplying it by left multiplying it by the left nullspace of the dual
conic, the homography is constructed. The inverse of the homography is
returned
%}

% performing SVD on the dual conic
[U, D, V] = svd(cstar);
% constructing a new diagonal matrix that uses the square root of the diagonal 
% elements from the singular value matrix from SVD
D_new = diag(sqrt(diag(D)));
% constructing the similarity homography 
H = double(U*D_new);
% returning the homography that will perform metric rectification
homography = inv(H);

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
% finding the vanishing points
[v1, v2] = GetVanishingPoints(img);
% finding points on the conic
points = GetConicPoints(img);
% constructing the conic matrix
conic = conicfit(points);
% constructing the dual conic to the circular points
dual_conic = CalculateDualConic(conic, v1, v2);
% constructing the inverse homography
homography = ConstructHomography(dual_conic);
% displaying rectified image
rect_img = TransformImage(img, homography);
imshow(rect_img)


