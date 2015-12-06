%helix
layers = 7;
t = 0:pi/200:pi;
%k = 0:pi/layers:pi;
X = sin(t);
Y = cos(t);

%% extract data from pointcloud

pointCloudsRaw = load('eight_objects.pcd');

numberOfPointsRaw = length(pointCloudsRaw);

indices = zeros(numberOfPointsRaw, 1);

pointClouds = zeros(numberOfPointsRaw, 3);

numberOfPoints = 0;
for i = 1 : numberOfPointsRaw
    
    if isfinite(pointCloudsRaw(i, 1)) && isfinite(pointCloudsRaw(i, 2)) && isfinite(pointCloudsRaw(i, 3))

        numberOfPoints = numberOfPoints + 1;

        indices(numberOfPoints, 1) = i;

        pointClouds(numberOfPoints, :) = pointCloudsRaw(i, :);

    end

end

indices = indices(1 : numberOfPoints, :);

pointClouds = pointClouds(1 : numberOfPoints, :);

%% sampling
numberOfNeighborhoodCentroids = 100;

[neighborhoodCentroids, neighborhoodCentroidsIndices] = datasample(pointClouds, numberOfNeighborhoodCentroids);
neighborhoodCentroidsIndices = neighborhoodCentroidsIndices';
neighborhoodCentroids = [neighborhoodCentroids neighborhoodCentroidsIndices];
neighborhoods = struct();

for i = 1 : numberOfNeighborhoodCentroids

    singleNeighborhoodPoints = zeros(numberOfPoints, 3);
    numberOfSingleNeighborhoodPoints = 0;
    
    for j = 1 : numberOfPoints
        
        xNormSquare = (neighborhoodCentroids(i, 1) - pointClouds(j, 1)) ^ 2;
        yNormSquare = (neighborhoodCentroids(i, 2) - pointClouds(j, 2)) ^ 2;
        zNormSquare = (neighborhoodCentroids(i, 3) - pointClouds(j, 3)) ^ 2;
        
        distance = sqrt(xNormSquare +  yNormSquare + zNormSquare);

        if  distance < 0.01
            
            numberOfSingleNeighborhoodPoints = numberOfSingleNeighborhoodPoints + 1;
            
            singleNeighborhoodPoints(numberOfSingleNeighborhoodPoints, :) = pointClouds(j, :);
            
        end
        
    end
    
    l = ['neighborhood' num2str(i)];
    
    singleNeighborhoodPoints = singleNeighborhoodPoints(1 : numberOfSingleNeighborhoodPoints, :);
    
    neighborhoods.(l) = singleNeighborhoodPoints;

end

%Accesing each neighborhood

%iterate through every sampledPointClouds

% for i = 1:1:length(idx)
    i = 2;
    neighborhood = neighborhoods.(['neighborhood' num2str(i)]);
    numberOfNeighborhoodPoints = length(neighborhood);

    plot3(neighborhoodCentroids(i, 1), neighborhoodCentroids(i, 2), neighborhoodCentroids(i, 3), 'ro')
    hold on;
    
    for j = 1 : numberOfNeighborhoodPoints
    
        plot3(neighborhood(j, 1), neighborhood(j, 2), neighborhood(j, 3), 'b.');
        hold on
        
    end

    %end

%numberOfPoints = layers * length(t);
% pointClouds = zeros(numberOfPoints, 3);
% 
% for i = 1 : 1 : layers
% 
%     for j = 1 : 1 : length(t)
%     
%         pointClouds((i - 1) * length(t) + j, 1) = X(j);
%         pointClouds((i - 1) * length(t) + j, 2) = Y(j);
%         pointClouds((i - 1) * length(t) + j, 3) = (i - 1) * 0.1;
%         
%         plot3(X(j), Y(j), (i - 1) * 0.1, 'r.');
%         hold on;
% 
%     end
% 
% end


%parameterVector = fitQuadric(neighborhood, numberOfNeighborhoodPoints);

% add output of median value to use if
[normal, principalAxis] = estimateMedianCurvature(neighborhoods, numberOfNeighborhoods, parameterVector);
%if median value >k
[circleCenterX, circleCenterY, circleRadius, centroid, extent] = fitCylinder(neighborhoods, numberOfNeighborhoods, normal, principalAxis);

% end