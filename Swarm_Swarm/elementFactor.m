function EF = elementFactor(kx, ky, curr_D, obj)
    lambda = obj.Wavelength;
    h = obj.SatHeight;
    k_val = 2*pi/lambda;
    if isscalar(ky) && ky == 0
        u = sin(deg2rad(kx));
        v = 0;
    else
        u = (kx * 1000) / h;
        v = (ky * 1000) / h;
    end
    X = (curr_D / lambda) * u;
    Y = (curr_D / lambda) * v;
    EF = abs(sinc(X) .* sinc(Y));
end
