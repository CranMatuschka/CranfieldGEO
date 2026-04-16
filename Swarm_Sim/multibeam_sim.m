function satellite_sim_2d_ntn
    % --- 1. Physics & Constants ---
    close all;
    const = Constants_Class();    

    %% Start Values
    N = 20;                  
    D = 4.0;
    Gap = 500.0; 
    Long = [0.000 -0.003 0.003 -0.006 0.006 -0.009 0.009...
        -0.012 0.012 -0.015 0.015 -0.018 0.018 -0.021 ...
        0.021 -0.024 0.024 -0.027 0.027 -0.030 0.030...
        -0.033 0.033 -0.036 0.036 -0.039 0.039 -0.042 ...
        0.042 -0.045 0.045 -0.048 0.048 -0.051 0.051...
        -0.054 0.054 -0.057 0.057 -0.060 0.060 -0.063 ...
        0.063 -0.066 0.066 -0.069 0.069 -0.072 0.072 ...
        -0.075 0.075 -0.078 0.078 -0.081 0.081 -0.084...
        0.084 -0.087 0.087 -0.090 0.090 -0.093 0.093...
        -0.096 0.096 -0.099 0.099 -0.102 0.102 -0.105...
        0.105 -0.108 0.108 -0.111 0.111 -0.114 0.114...
        -0.117 0.117 -0.120 0.120 -0.123 0.123 -0.126...
        0.126 -0.129 0.129 -0.132 0.132 -0.135 0.135 ...
        -0.138 0.138 -0.141 0.141 -0.144 0.144 -0.147 ...
        0.147 -0.15];
    Lat = zeros(length((Long)));
    noBeams = 5;
    
    %% Setup Figure
    fig = figure('Name', ['NTN Analysis: Footprint ' ...
        'Diameter & Profile'],'Color', 'w', 'Position', [ ...
        50 50 1500 900]);
    g = uigridlayout(fig, [3, 3]);
    g.RowHeight = {'fit', '0.5x', '1.5x'}; 
    g.ColumnWidth = {'1x', '1.1x', '1x'};
    
    %% Controls Panel
    pnl_ctrl = uipanel(g, 'Title', 'System Parameters', ...
        'BackgroundColor', 'w');
    pnl_ctrl.Layout.Row = 1;
    pnl_ctrl.Layout.Column = [1 3];
    gl_ctrl = uigridlayout(pnl_ctrl, [2, 6]);
    gl_ctrl.RowHeight = {50,25};
    
    uilabel(gl_ctrl, 'Text', 'Satellites (N):','FontSize', 14, ...
        HorizontalAlignment='right');
    sld_N = uislider(gl_ctrl, 'Limits', [3 100], 'Value', N, ...
        'ValueChangedFcn', @(~,~) updatePlot(),'Step',2);
   
    uilabel(gl_ctrl, 'Text', 'Diameter (D):', 'FontSize', 14, ...
        HorizontalAlignment='right');
    sld_D = uislider(gl_ctrl, 'Limits', [0.5 10], 'Value', D, ...
        'ValueChangedFcn', @(~,~) updatePlot());

    uilabel(gl_ctrl, 'Text', 'Min Gap (m):', 'FontSize', 14, ...
        HorizontalAlignment='right'); 
    sld_Gap = uislider(gl_ctrl, 'Limits', [30 2000], 'Value', ...
        Gap, 'ValueChangedFcn', @(~,~) updatePlot(), 'Step',20);

    uilabel(gl_ctrl, 'Text', 'Starting Frequency:', 'FontSize', ...
        14, HorizontalAlignment='right');
    ef_Freq = uieditfield(gl_ctrl, "text" ,"ValueChangedFcn", ...
        @(~,~) updatePlot(),"Value", ...
        sprintf('%.1e', const.Frequency));
    uilabel(gl_ctrl, 'Text', 'Channel Spacing:', 'FontSize', ...
        14, HorizontalAlignment='right');
    ef_CS = uieditfield(gl_ctrl, "text" ,"ValueChangedFcn", ...
        @(~,~) updatePlot(),"Value", ...
        sprintf('%.1e', const.ChannelSpacing));
    uilabel(gl_ctrl, 'Text', 'Number of Beams', 'FontSize', ...
        14, HorizontalAlignment='right');
    ef_NB = uieditfield(gl_ctrl, "numeric" ,"Value",  noBeams);
    

    %% Stats/Positions Row
    ax_pos = axes(g); 
    ax_pos.Layout.Row = 3; 
    ax_pos.Layout.Column = 3;
    title(ax_pos, 'Array Geometry (m)');
    
    pnl_res = uipanel(g, 'Title', 'Link Stats', 'BackgroundColor', ...
        'w', FontSize= 14);
    pnl_res.Layout.Row = 2; 
    pnl_res.Layout.Column = [1 3];
    gl_res = uigridlayout(pnl_res, [4, 3]);
    lbl_N = uilabel(gl_res, 'Text', 'Number of Satellites: --', ...
        'FontSize', 14, 'FontWeight', 'bold');
    lbl_N.Layout.Row = 1;
    lbl_N.Layout.Column = 3;
    lbl_D = uilabel(gl_res, 'Text', 'Diameter of Satellites --', ...
        'FontSize', 14,'FontWeight', 'bold');
    lbl_D.Layout.Row = 2;
    lbl_D.Layout.Column = 3;
    lbl_HPBW = uilabel(gl_res, 'Text', 'HPBW Diam: -- deg', ...
        'FontSize', 14, 'FontWeight', 'bold');
    lbl_HPBW.Layout.Row = 3;
    lbl_HPBW.Layout.Column = 2;
    lbl_Diam = uilabel(gl_res, 'Text', 'Footprint Diam: -- km', ...
        'FontSize', 14, 'FontWeight', 'bold');
    lbl_Diam.Layout.Row = 4;
    lbl_Diam.Layout.Column = 2;
    lbl_Gap = uilabel(gl_res, 'Text', 'Minimum Gap -- m', ...
        'FontSize', 14, 'FontWeight', 'bold');
    lbl_Gap.Layout.Row = 3;
    lbl_Gap.Layout.Column = 3;
    lbl_Long = uilabel(gl_res, 'Text', 'X-Offset of Beam (deg)', ...
        'FontSize', 14, 'FontWeight', 'bold', ...
        HorizontalAlignment='right');
    lbl_Long.Layout.Row = 1;
    lbl_Long.Layout.Column = 1;
    ef_Long = uieditfield(gl_res, "text" ,"ValueChangedFcn", ...
        @(~,~) updatePlot(), "Value",num2str(Long(1:noBeams)));
    ef_Long.Layout.Row = 1;
    ef_Long.Layout.Column = 2;
    lbl_Lat = uilabel(gl_res, 'Text', 'Y-Offset of Beam (deg)', ...
        'FontSize', 14, 'FontWeight', 'bold', ...
        HorizontalAlignment='right');
    lbl_Lat.Layout.Row = 2;
    lbl_Lat.Layout.Column = 1;
    ef_Lat = uieditfield(gl_res, "text" ,"ValueChangedFcn", ...
        @(~,~) updatePlot(),"Value",num2str(Lat(1:noBeams)));
    ef_Lat.Layout.Row = 2;
    ef_Lat.Layout.Column = 2;
    dd_Side = uidropdown(gl_res, "Items",["Default Aggregated", ...
        "Default Envelope","MultiFreq Aggregated", ...
        "MultiFreq Envelope"], ...
        "ValueChangedFcn", @(~,~) updatePlot());
    dd_Side.Layout.Row = 3;
    dd_Side.Layout.Column = 1;
    dd_2D = uidropdown(gl_res, "Items",["Normalised", "dB", ...
        "SNR dB", "Spectral Efficiency"],"ValueChangedFcn", ...
        @(~,~) updatePlot());
    dd_2D.Layout.Row = 4;
    dd_2D.Layout.Column = 1;

    %% MAIN VISUALS
    ax_foot = axes(g); 
    ax_foot.Layout.Row = 3; 
    ax_foot.Layout.Column = 1;
    title(ax_foot, 'Ground Footprint');
    
    ax_side = axes(g); 
    ax_side.Layout.Row = 3; 
    ax_side.Layout.Column = 2;
    title(ax_side, 'Side Profile');
    
    updatePlot();

    %% 3. Update Logic
    function updatePlot()
        try
            %Updating Values
            curr_N = round(sld_N.Value);
            curr_D = sld_D.Value;
            curr_Gap = sld_Gap.Value;
            noBeams = ef_NB.Value;
            if strcmp(ef_Long.Value, 'beams')
                ef_Long.Value = num2str(Long(1:noBeams));
                ef_Lat.Value = num2str(Lat(1:noBeams));
            end
            if strcmp(ef_Long.Value, 'circ')
                radius = 0.004;
                temp_Long = zeros(1, noBeams);
                temp_Lat = zeros(1, noBeams);
                temp_Long(1) = 0;
                temp_Lat(1) = 0;
                for b = 2:noBeams
                    if rem(b,4) == 0
                        radius = radius*(b/4);
                    end
                    theta = (b - 2) * (pi / 2); 
                    temp_Long(b) = radius * cos(theta);
                    temp_Lat(b) = radius * sin(theta);
                end
                ef_Long.Value = num2str(temp_Long);
                ef_Lat.Value = num2str(temp_Lat);
            end
            curr_Long = str2num(ef_Long.Value);
            curr_Lat = str2num(ef_Lat.Value);
            curr_Mode = string(dd_Side.Value);
            const.normVSdB = string(dd_2D.Value);
            num_beams = min(length(curr_Long), length(curr_Lat));
            ef_NB.Value = num_beams;
            const.ChannelSpacing = str2double(ef_CS.Value);
            const.Frequency = str2double(ef_Freq.Value);
            lambda = const.Wavelength;             
            h_geo = const.SatHeight;  


            if length(curr_Long) < num_beams
                curr_Long(end+1:num_beams) = 0; 
            end
            if length(curr_Lat) < num_beams
                curr_Lat(end+1:num_beams) = 0; 
            end

            %% Calculate XY Positions of Constellation
            [p_x, p_y] = XYconstellationPositions(curr_N, ...
                curr_D, curr_Gap);
            %% Footprint Calculation
            mean_D_swarm = (((max(p_x) - min(p_x))+(max(p_y) ...
                - min(p_y)))/2); % km
            hpbw_deg = 70 * (lambda / mean_D_swarm);
            hpbw_rad = deg2rad(hpbw_deg);
            f_diam = (2 * h_geo * tan(hpbw_rad / 2)) / 1000;

            
            %%
            r_km = f_diam*20 ;
            res = 1500; %resolution of Plot
                

            %% Steering Vector + Weight Calculation
            
            if isscalar(curr_Long)
                curr_Long = curr_Long * ones(1, num_beams); 
            end
            if isscalar(curr_Lat)
                curr_Lat = curr_Lat * ones(1, num_beams); 
            end

            if max(curr_Long) == 0
                angles_res = 1;
            else
                angles_res = max(curr_Long)*2 + 7;
                %r_km = (h_geo*tand(mean(curr_Long))*1.3) /1000;
            end 

            kx = linspace(-r_km, r_km, res); %in km 
            ky = linspace(-r_km, r_km, res); %in km
            [KX, KY] = meshgrid(kx, ky);

            angles_deg = linspace(-angles_res, angles_res, ...
                180*10000)';
            freq_start = const.Frequency;
            if contains(curr_Mode, 'Default')
                input = 'Steered';
                const.Frequency = 2.1e9;
            elseif contains(curr_Mode, 'MultiFreq')
                input = 'MultiFreq';
            end

                
            P_2D_linear = zeros(size(KX));
            P_side_linear = zeros(size(angles_deg));

            for b = 1:num_beams
                target_x = curr_Long(b); 
                target_y = curr_Lat(b);  
                
                if contains(curr_Mode, 'MultiFreq')
                    const.Frequency = freq_start + ...
                        (b-1) * const.ChannelSpacing;
                end
                %Footprint
                AF_2D = arrayFactor(KX, KY, p_x, p_y,...
                    curr_N, target_x, target_y, input, const);
                EF_2D = elementFactor(KX, KY, curr_D, const);
                Total_Field_2D = AF_2D .* EF_2D;
                %Side Plot
                AF_side = arrayFactor(angles_deg, 0, p_x, p_y,...
                    curr_N, target_x,target_y,...
                    ['side', input], const);
                EF_side = elementFactor(angles_deg-target_x, ...
                    0, curr_D, const);
                Total_Field_side = AF_side .* EF_side;
                %Linear
                if contains(curr_Mode, 'Aggregated')
                    P_2D_linear = P_2D_linear + ...
                        (abs(Total_Field_2D)/curr_N).^2; 
                    P_side_linear = P_side_linear + ...
                        (abs(Total_Field_side)/curr_N).^2;
                elseif contains(curr_Mode, 'Envelope')
                    P_2D_linear = max(P_2D_linear, ...
                        (abs(Total_Field_2D)/curr_N).^2);
                    P_side_linear = max(P_side_linear, ...
                        (abs(Total_Field_side)/curr_N).^2);
                end
            end
            
            if strcmp(const.normVSdB, "Normalised")
                P_2D_total = P_2D_linear;
                %P_2D_total = min(P_2D_total);
                P_side_total = P_side_linear;
                hpbwLimits = [0.5 0.5]; % -3dB point in linear scale
            elseif strcmp(const.normVSdB, "SNR dB")
                N_dB = 10*log10(curr_N*...
                    const.Boltzmann*const.SystemNoiseSatellite ...
                    *const.NBIoTBandwidth);
                P_2D_total = 10 * log10(P_2D_linear + 1e-12) - N_dB;
                P_side_total = 10 * log10(P_side_linear + 1e-12)...
                    - N_dB;
                maxP = max(P_2D_total(:));
                hpbwLimits = [maxP-3, maxP-3];
            elseif strcmp(const.normVSdB, "Spectral Efficiency")
                N_linear = curr_N*const.Boltzmann*...
                    const.SystemNoiseSatellite*const.NBIoTBandwidth;
                P_2D_total = log2(1 + P_2D_linear./N_linear);
                P_side_total = log2(1 + P_side_linear./N_linear);
                maxP = max(P_2D_total(:));
                hpbwLimits = [maxP-3, maxP-3];
            else
                P_2D_total = 10 * log10(P_2D_linear + 1e-12);
                %P_2D_total = max(P_2D_total, 3);
                P_side_total = 10 * log10(P_side_linear + 1e-12);
                maxP = max(P_2D_total(:));
                hpbwLimits = [maxP-3, maxP-3]; 
            end


            %% Footprint
            cla(ax_foot); 
            hold(ax_foot, 'on');
            axis(ax_foot, 'square'); 
            grid(ax_foot, 'on');

            imagesc(ax_foot, kx, ky, P_2D_total);
            xtickformat(ax_foot, '%.4g') 
            ytickformat(ax_foot, '%.4g')
            ax_foot.XAxis.Exponent = 0;
            ax_foot.YAxis.Exponent = 0;
            ax_foot.XTickLabelRotation = 45;
            xlabel(ax_foot, 'Ground distance (km)'); 
            ylabel(ax_foot, 'Ground distance (km)');
            colormap(ax_foot, 'jet'); 

            cb = colorbar(ax_foot);
            c_min = quantile(P_2D_total(:),0.70);
            c_max = max(P_2D_total(:));
            ylabel(cb, const.normVSdB + ' Power Level');
            if c_max > c_min
                clim(ax_foot, [c_min c_max]); 
            end
            cb.Ticks = linspace(c_min, c_max, 15);
            
            
            h_geo = const.SatHeight; % in meters
            angles_deg = (h_geo * tand(angles_deg)) / 1000;

            cla(ax_side); 
            hold(ax_side, 'on');
            plot(ax_side, angles_deg, P_side_total, ...
                'LineWidth', 1.5, 'Color', [0 0.447 0.741]);
            yline(ax_side, hpbwLimits(1), 'r--', '-3dB');
            xlabel(ax_side,'Ground distance (km)' )
            ylabel(ax_side, const.normVSdB + ' Power');
            grid(ax_side, 'on');
            axis(ax_foot, 'image');
            set(ax_foot, 'YDir', 'normal'); 
            xlim(ax_side, [min(kx) max(kx)]);
            ylim(ax_side, [min(P_side_total) max(P_side_total)*1.1]);

            %% Update Labels
            lbl_HPBW.Text = sprintf('HPBW: %.5f deg', hpbw_deg);
            lbl_Diam.Text = sprintf('Footprint Diam: %.2f km',...
                f_diam);
            lbl_N.Text = sprintf('Number of Satellites %i', curr_N);
            lbl_D.Text = sprintf('Diameter of Satellites: %.2f',...
                curr_D);
            lbl_Gap.Text = sprintf('Minimum Gap: %.2f', curr_Gap);

            %% Positions Plot
            cla(ax_pos); 
            hold(ax_pos, 'on');
            n_available = min([length(p_x), length(p_y), curr_N]);
            for i=1:n_available
                rectangle(ax_pos, 'Position', [p_x(i)-curr_D/2, ...
                    p_y(i)-curr_D/2, curr_D*((mean_D_swarm)/100), ...
                    curr_D*((mean_D_swarm)/100)],...
                    'Curvature', [1 1],...
                    'FaceColor', [0 .45 .74 .3]);
            end
            axis(ax_pos, 'equal'); 
            grid(ax_pos, 'on');

        catch ME
            fprintf('Update Error: %s\n', ME.message);
        end
    end
end
