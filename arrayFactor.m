function AF = arrayFactor(kx, ky, p_x, p_y, curr_N,...
    target_x, target_y, type, obj)
    h = obj.SatHeight;
    lambda = obj.Wavelength;
    k_val = 2*pi/lambda;
    AF = zeros(size(kx));
    if contains(type, 'side')
        U = sin(deg2rad(kx));
        V = 0;
    else
        U = (kx * 1000) / h;
        V = (ky * 1000) / h;
    end

    switch type
        case {'Steered','steeringDeg', 'sideSteered',...
                'MultiFreq', 'sideMultiFreq'}
            u_t = sin(deg2rad(target_x));
            v_t = sin(deg2rad(target_y));
            w = exp(1j * k_val * (p_x * u_t + p_y * v_t));
            phase = exp(1j * k_val * (reshape(p_x, 1, 1, []) ...
                .* U + reshape(p_y, 1, 1, []) .* V));
            AF = sum(conj(reshape(w, 1, 1, [])) .* phase, 3);
        case 'norm'
            phase = exp(1j * k_val * (reshape(p_x, 1, 1, [])...
                .* U + reshape(p_y, 1, 1, []) .* V));
            AF = sum(phase, 3);
        otherwise
            error('Unknown simulation type');
    end
end