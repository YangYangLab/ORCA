function weightmap = glance_std(block)
%GLANCE_STD Ultra fast (yet simple) active components identification
%   MAP = GLANCE_STD(BLOCK) identifies active components in block and generates areas that
%   covers most active components.
%
%   See also GLANCE_FILTER.

%   Weihao Sheng, 2020-05-27
%   Yang Yang's Lab of Neural Basis of Learning and Memory
%   School of Life Sciences and Technology, ShanghaiTech University,
%   Shanghai, China

% the code below does not make much sense mathematically - but it kind of works.

    % First we normalise our data, by centralisation
    act = (double(block) - mean(block(:))) / std(double(block(:)));  

    % Now we have std(block) == 1. We calculate AUC of all pixels - in this case just sum
    % up all data in their temporal traces.
    sumact = sum(act,3); 
    % We are more interested in activities that goes beyond average
    sumact(sumact<0) = 0;
    
    % Finally, amplify differences by multiplying standard deviation. This step is
    % mathematically meaningless, yet it looks helpful.
    act = sumact .* std(act, [], 3); 
    
    % Arbitrarily use 0.1 as a threshold. But here leave this decision to the caller.
	weightmap = mat2gray(act);
    
end

    
    