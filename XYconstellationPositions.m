%% Random Satellite Positions 
function [p_x, p_y] = XYconstellationPositions(curr_N, curr_D,...
    curr_Gap)

    min_dist = curr_D + curr_Gap; 
    p_x = zeros(curr_N, 1);
    p_y = zeros(curr_N, 1);
    span = sqrt(curr_N) * (min_dist) * 1.5;
    for i = 1:curr_N
        v = false;
        while v == false
            tx = (rand()-0.5)*span; 
            ty = (rand()-0.5)*span;
            if i==1
                v=true; 
            else
                if all(sqrt((p_x(1:i-1)-tx).^2 + ...
                        (p_y(1:i-1)-ty).^2) > min_dist)
                    v=true; 
                end
            end
            p_x(i)=tx; p_y(i)=ty;
        end
    end
    return
end