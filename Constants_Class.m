classdef Constants_Class < handle
    properties
        Frequency = 2.1e9      ;% Hz
        SatHeight = 36e6       ;% m
        ChannelSpacing = 5e9   ;% Hz
        Diameter = 4;
        normVSdB = "Normalised";
        Boltzmann = 1.38e-23;
        SystemNoiseSatellite = 290;
        NBIoTBandwidth = 15e6;
    end
    
    properties (Dependent)
        Wavelength
    end
    
    methods
        function val = get.Wavelength(obj)
            c = 299792458;
            val = c / obj.Frequency;
        end

        function obj = Constants(freq, height)
            if nargin > 0
                obj.Frequency = freq;
            end
            if nargin > 1
                obj.SatHeight = height;
            end
        end
    end
end