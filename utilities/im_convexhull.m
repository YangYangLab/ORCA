function [V,I] = im_convexhull(InputData)
%% IM_CONVEXHULL function gives the englobing convex hull of 2D data set.
% 
% [V,I] = IM_CONVEXHULL(InputData) gives the convex hull for a 2D points set.
% InputInputData is a coordinate matrix of size Nx2. The first column contains
% the xInputData and the second column contains the yInputData :
% InputData=[xInputData' yInputData']
%
% [V,I] = IM_CONVEXHULL(InputData) provides two types of elements :
%    V - The x-InputData and y-InputData values of the founded V
%    I - The position indexes of the founded V in the initial InputData. 
%
% 2D Example - Normal distribution
%    x = random('Normal',0,1,1,150);
%    y = random('Normal',0,1,1,150);
%    InputData = [x' y'];
%    [V,I] = ConvexHull(InputData);
%    plot(InputData(:,1),InputData(:,2),'.')
%    hold on
%    plot(V(:,1), V(:,2), '--')
%    xlabel('x-data');
%    ylabel('y-data');
%    legend('InputData' , 'Convex hull');
%
%   Developped by Foued Theljani (2013). See as references :
%    1. F. Theljani, K. Laabidi, S. Zidi and M. Ksouri. An efficient 
%       density-based algorithm for data clustering. Int. Journal on 
%       Artificial Intelligence Tools, Vol. 26, No. 4, 21 pages, August 2017. 
%    2. F. Theljani, K. Laabidi, S. Zidi & M. Ksouri. Convex hull based 
%       clustering algorithm. Int. Journal of Artificial Intelligence. 
%       Vol. 9, No. A12, Oct. 2012.

%% Begin of function
V = [InputData(1:3,:)]; I = [1:3]'; % Take first three points as initialization
for k=4:length(InputData)
    % Initialization
    pk = InputData(k,:); 
    sup_ver = [];
    ind = []; index = [];
    % End of initialization
    
    % Localization step
    for i=1:length(V)                       
        vi = V(i,:);O = [];
        for j=1:length(V)
            if i~=j
                vj = V(j,:);
                O(j) = det([1 pk;1 vi; 1 vj]);  % Calculate the orientation matrix
            end
        end
        O(O==0) = [];
        if (numel(unique(sign(O)))==1)==1    % if there is a supporting vertex
            sup_ver = [sup_ver;vi];          % accumulate supporting vertices
        end
    end
    % End of localization step
    
    % Restructure step
    if isempty(sup_ver)==0            % if the point is outside of the hull shape
        P1 = sup_ver(1,:); 
        P2 = sup_ver(2,:); 
        P3 = pk;
        s  = det([P1-P2;P3-P1]);
        n  = 1;
        
        % Resolving of the PIT problem 
        while n<=length(V)            
            P = V(n,:);
            if P~=P1 & P~=P2 & P~=pk & (s*det([P3-P;P2-P3])>=0 &  ...      % if the query point P inside the triangle (vi,pk,vj)
                    s*det([P1-P;P3-P1])>=0 & s*det([P2-P;P1-P2])>=0)==1
                V(n,:) = []; 
                I(n) = [];
                n = n-1;
            end
            n = n+1;
        end
        % End of resolving the �PIT problem
        
        ind(1) = find(V==P1(:,1));            % Find the position of the 1st supprting vertex
        ind(2) = find(V==P2(:,1));            % Find the position of the 2nd supprting vertex
        index  = find(InputData==pk(:,1));    % Finde the position of the new vertex
        
        % Updating V and I
        if ind(2)-ind(1)==1
            V = [V(1:ind(1),:);pk;V(ind(1)+1:end,:)];   % Insert the new vertex into V
            I = [I(1:ind(1)); index ;I(ind(1)+1:end)];  % Update indexes I
        else
            V = [pk;V];                                 % Insert the new vertex into V
            I = [index ; I];                            % Update indexes I
        end
        % End of updating V and I
    end
    % End of the Restructure step
 end
V = vertcat(V,V(1,:));
I = vertcat(I,I(1));