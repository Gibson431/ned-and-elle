clear 
close all
clc
robot = Ned(eye(4));
robot.model.animate([deg2rad(21.6) deg2rad(57.6) deg2rad(27.9) deg2rad(0) deg2rad(0) deg2rad(0)]);

PlaceObject("2_Flats.ply",[0.6,0.2,0.3]);
[faces, vertex,data] = plyread('2_Flats.ply', 'tri');
vertex(:,1) = vertex(:,1) + 0.6;
vertex(:,2) = vertex(:,2) + 0.2;
vertex(:,3) = vertex(:,3) + 0.3;


qmatrix = [21.6 57.6 27.9 0 0 0];
% robot.model.teach()
collision = 0;

objectPoints = vertex;

for a = 1:size(qmatrix,1)

    tr = zeros(4,4,robot.model.n+1);
    tr(:,:,1) = robot.model.base;
    q = qmatrix(a,:);

    L = robot.model.links;
    for j = 1 : robot.model.n
        tr(:,:,j+1) = tr(:,:,j) * trotz(q(j)) * transl(0,0,L(j).d) * transl(L(j).a,0,0) * trotx(L(j).alpha);
    end

    centrePoint = zeros(robot.model.n,3);
    radii = zeros(robot.model.n,3);
    for i = 1:robot.model.n
        x = abs(tr(1,4,i)-tr(1,4,i+1))/2 + 0.1;
        y = abs(tr(2,4,i)-tr(2,4,i+1))/2 + 0.1;
        z = abs(tr(3,4,i)-tr(3,4,i+1))/2 + 0.1;

        centrePoint(i,1) = -(tr(1,4,i+1)-tr(1,4,i))/2;
        centrePoint(i,2) = -(tr(2,4,i+1)-tr(2,4,i))/2;
        centrePoint(i,3) = (tr(3,4,i+1)-tr(3,4,i))/2;

        if x < 0.1
            x = 0.1;
        end
        if y < 0.1
            y = 0.1;
        end
        if z < 0.1
            z = 0.1;
        end
        radii(i,1) = x;
        radii(i,2) = y;
        radii(i,3) = z;
    end


    % Go through each ellipsoid
    for k = 1: size(tr,3)
        objectPointsAndOnes = [inv(tr(:,:,k)) * [objectPoints,ones(size(objectPoints,1),1)]']';
        updatedObjectPoints = objectPointsAndOnes(:,1:3);
        algebraicDist = GetAlgebraicDist(updatedObjectPoints, centrePoint, radii);
        pointsInside = find(algebraicDist < 1);
        if pointsInside > 0
            collision = 1;
            disp('COLLIDED')
            return
        else
            disp('CHILLIN')
        end
    end
end

function algebraicDist = GetAlgebraicDist(points, centerPoint, radii)
algebraicDist = ((points(:,1)-centerPoint(1))/radii(1)).^2 ...
    + ((points(:,2)-centerPoint(2))/radii(2)).^2 ...
    + ((points(:,3)-centerPoint(3))/radii(3)).^2;
end
