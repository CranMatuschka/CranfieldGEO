function random_pattern_sim
    f = 1e9;                % Frequency: 1 GHz
    c = 299792458; 
    lambda = c/f;           % Wavelength: ~0.3m
    N = 8;                  % Number of satellites
    D = 1.0;                % Diameter (meters)
    Gap = 0.5;              % Gap between satellites (meters)
    isRand = false;         % Start with Uniform spacing
    
    % --- 2. Setup Figure ---
    fig = figure('Name', 'Random Pattern Multiplication', ...
        'Color', 'w', ...
        'Position', [100 100 900 1600]);
    g = uigridlayout(fig, [3, 1]);
    g.RowHeight = {'fit', '8x', '1x'};
    
    % --- Controls Section ---
    pnl = uipanel(g, 'Title', 'Settings', 'BackgroundColor', 'w');
    gl_c = uigridlayout(pnl, [1, 4]);
    gl_c.RowHeight = {150,'3x', '1x'}
    
    % Diameter Slider
    subg1 = uigridlayout(gl_c, [2,1]);
    uilabel(subg1, 'Text', 'Diameter (D):');
    sld_D = uislider(subg1, 'Limits', [0.1 5], 'Value', D, ...
        'ValueChangedFcn', @updatePlot);
    
    % Gap Slider
    subg2 = uigridlayout(gl_c, [2,1]);
    uilabel(subg2, 'Text', 'Gap (m):');
    sld_Gap = uislider(subg2, 'Limits', [0 10], 'Value', Gap, ...
        'ValueChangedFcn', @updatePlot);
    
    % N Slider
    subg3 = uigridlayout(gl_c, [2,1]);
    uilabel(subg3, 'Text', 'Count (N):');
    sld_N = uislider(subg3, 'Limits', [1 200], 'Value', N, ...
        'ValueChangedFcn', @updatePlot);

    % Random Checkbox
    cb_Rand = uicheckbox(gl_c, 'Text', 'Random Spacing', 'Value', ...
        isRand, 'ValueChangedFcn', @updatePlot);

    % --- Plot Sections ---
    ax_pat = axes(g);
    title(ax_pat, ['Pattern Multiplication (Total = Array Factor ' ...
        'x Element Pattern)']);
    xlabel(ax_pat, 'Angle (deg)'); 
    ylabel(ax_pat, 'Normalized Magnitude');
    grid(ax_pat, 'on');
    
    ax_pos = axes(g);
    title(ax_pos, 'Satellite Positions');
    axis(ax_pos, 'off'); % We will draw custom shapes here
    
    % Initial Draw
    updatePlot();

    function updatePlot(~,~)
        % Get current UI values
        curr_D = sld_D.Value;
        curr_Gap = sld_Gap.Value;
        curr_N = round(sld_N.Value);
        curr_Rand = cb_Rand.Value;
        
        % --- A. Calculate Positions ---
        baseDist = curr_D + curr_Gap;
        pos = zeros(1, curr_N);
        
        if curr_Rand
            % Random Logic: Start at 0, add Base + Jitter
            pos(1) = 0;
            for i = 2:curr_N
                % Jitter is random between 0% and 80%
                jitter = rand() * (baseDist * 0.8); 
                pos(i) = pos(i-1) + baseDist + jitter;
            end
        else
            % Uniform Logic
            pos = (0:curr_N-1) * baseDist;
        end
      
        center_offset = (pos(end) - pos(1)) / 2;
        pos_centered = pos - center_offset;
        
        % --- B. Calculate Patterns ---
        theta = linspace(0, pi/2, 1000); % -90 to 90 deg
        u = sin(theta); %Formula 2.37
        k = 2*pi/lambda;

        [U, P] = meshgrid(u, pos_centered);
        psi = k * P .* U;
        AF = abs(sum(exp(1j*psi), 1)) ./ curr_N;
        radius = curr_D / 2;
        X = k * radius * u;
        
        EP = ones(size(X));
        idx = abs(X) > 1e-6;
        EP(idx) = abs(sin(X(idx)) ./ X(idx)); 
        % --- C. Plotting Pattern ---
        cla(ax_pat); hold(ax_pat, 'on');
        plot(ax_pat, rad2deg(theta), AF, ':', 'Color', 'green', ...
            'LineWidth', 1.5,'DisplayName', 'Array Factor');
        plot(ax_pat, rad2deg(theta), EP, '--', 'Color', ...
            [0.85 0.32 0.09], ...
            'LineWidth', 1.5, 'DisplayName', 'Element Pattern');
        area(ax_pat, rad2deg(theta), Total, 'FaceColor', ...
            [0 0.447 0.741], ...
            'FaceAlpha', 0.3, 'DisplayName', 'Total');
        
        legend(ax_pat, 'Location', 'northeast');
        ylim(ax_pat, [0 1.1]);
        xlim(ax_pat, [0 45]);
        
        % --- D. Plotting Positions ---
        cla(ax_pos); hold(ax_pos, 'on');
        
        % Draw floor line
        plot(ax_pos, [min(pos)-2, max(pos)+2], [0 0], ...
            'k-', 'LineWidth', 1);
        
        for i = 1:curr_N
            % Position: [x, y, width, height]
            rectangle(ax_pos, 'Position', [pos(i)-(curr_D/2), 0, ...
                curr_D, curr_D], ...
                'Curvature', [1 1], ... % Makes it a circle
                'FaceColor', [0.2 0.7 0.9]);
            
            % Add Text Label
            text(ax_pos, pos(i), -curr_D*0.5, num2str(i), ...
                'HorizontalAlignment', 'center', 'FontSize', 8);
        end
        axis(ax_pos, 'equal');
        
        xlim(ax_pos, [min(pos)-curr_D*2, max(pos)+curr_D*2]);
        ylim(ax_pos, [-curr_D, curr_D*2]);
    end
end