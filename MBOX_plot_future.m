% 加载模型结果 Load the results
load('model_results.mat');

% 获取磷和二氧化碳强迫的情景数量 
[num_P, num_CO2] = size(results);

% 定义海洋箱的标识符和名称
ocean_boxes = {'p', 'di', 's', 'h', 'd'}; % p: proximal, di: distal, s: surface, h: high-latitude, d: deep
box_labels = {'Proximal', 'Distal', 'Surface', 'High-lat', 'Deep'};

% 定义 CO₂ 情景名称
CO2_scenarios = {'ssp1-1.9', 'ssp2-4.5', 'ssp3-7.0', 'ssp5-8.5'};

% 定义 P 情景名称
% P_values = {'without P', 'with P', 'enhanced P (1e12 mol/yr)'};
P_values = {'without P', 'with P'};


% 定义线型：根据 P 情景定义线型
line_styles = {'-', '--', ':'}; % 'without P' 用实线，'with P' 用虚线，'enhanced P' 用点划线

% 定义颜色：CO₂ 情景对应指定的颜色
% CO₂ 情景 1：绿色，2：蓝色，3：土黄色，4：红色
color_map = [
    0, 1, 0;          % 绿色
    0, 0, 1;          % 蓝色
    0.96, 0.64, 0.38; % 土黄色
    1, 0, 0           % 红色
];


% 加载 CO₂ 和 P 输入数据
% 初始化 CO₂ 和 P 输入数据的存储
CO2_input_data = cell(num_CO2, 1);
P_input_data = cell(num_P, 1);

% 加载历史 CO₂ 排放数据
history_CO2_data = xlsread('anthro_CO2_history.xlsx');
history_time = history_CO2_data(:, 1); % 时间
history_CO2_values = history_CO2_data(:, 2); % CO₂ 排放值


% 加载 CO₂ 输入数据
for j = 1:num_CO2
    CO2_input_data{j} = xlsread(CO2_forcings{j});
end

% 加载 P 输入数据
for i = 1:num_P
    P_input_data{i} = csvread(P_forcings{i});
end

% 遍历每个海洋箱，生成对应的图形
for b = 1:length(ocean_boxes)
    box_code = ocean_boxes{b};
    box_name = box_labels{b};

    % 创建新的图形窗口
    figure('Color',[1 0.98 0.95], 'Name', box_name, 'Position', [100, 100, 800, 800]);
    tiledlayout(3, 2);
    plot_idx = 1;

    % 定义要绘制的变量和对应的标签
    variables = {'Atmospheric_CO2_ppm', 'T', 'O2_conc', 'pH', 'CO2_input', 'P_input'}; % **修改2：添加 'CO2_input' 和 'P_input'**
    var_labels = {'Atmospheric CO₂ (ppm)', 'Temperature (°C)', 'O₂ Concentration (mM)', 'pH', 'CO₂ Input (GtC/year)', 'P Input (TgP/year)'}; % **修改2**

    % 遍历每个变量，创建子图
    for v = 1:length(variables)
        % 选择当前子图
        nexttile(plot_idx);
        hold on;
        grid on;
        box on;

        % 设置子图标题和标签
        xlabel('Time (years)');
        ylabel(var_labels{v});
        title(var_labels{v});

        % 判断变量类型，分别处理
        if strcmp(variables{v}, 'CO2_input')
             % 绘制 CO2 输入数据
            for j = 1:num_CO2
            % for j = 4
                % 获取 CO₂ 输入数据
                CO2_input_time = CO2_input_data{j}(:, 1); % 时间
                CO2_input_values = CO2_input_data{j}(:, 2); % CO₂ 输入值

                  % 筛选 2015 年之后的数据
    idx_CO2 = CO2_input_time >= 2015;
    CO2_input_time = CO2_input_time(idx_CO2);
    CO2_input_values = CO2_input_values(idx_CO2);

                % 绘制 CO₂ 输入曲线，使用指定颜色和实线
                plot(history_time, history_CO2_values, 'k-', 'LineWidth', 1.5, 'DisplayName', 'History');
                plot(CO2_input_time, CO2_input_values, 'Color', color_map(j, :), 'LineStyle', '-', 'LineWidth', 1.5);
            end

        elseif strcmp(variables{v}, 'P_input')
            % 绘制 P 输入数据
            % for i = 2
            for i = 1:num_P

                % 获取 P 输入数据
                P_input_time = P_input_data{i}(:, 1); % 时间
                P_input_values = P_input_data{i}(:, 2); % P 输入值

                % 绘制 P 输入曲线，使用黑色和不同的线型
                plot(P_input_time, P_input_values, 'Color', 'k', 'LineStyle', line_styles{i}, 'LineWidth', 1.5);
            end

        else
            % 绘制模型输出数据
            % 绘制不同情景的数据
            for i = 1:num_P  % 遍历 P 情景
                for j = 1:num_CO2  % 遍历 CO₂ 情景
                    % 获取当前情景的状态变量
                    state = results{i, j}.state;
                    time = state.time_myr .* 1e6;  % 转换为年

                    % 获取变量值
                    if strcmp(variables{v}, 'Atmospheric_CO2_ppm')
                        % 大气 CO₂，无需区分海洋箱
                        data = state.Atmospheric_CO2_ppm;
                    elseif strcmp(variables{v}, 'T')
                        % 温度，需要转换为摄氏度
                        data = state.(['T_' box_code]) - 273.15;
                    else
                        % 其他变量，直接获取对应海洋箱的数据
                        data = state.([variables{v} '_' box_code]);
                    end

                    % 确定线型和颜色
                    line_style = line_styles{i};  % 根据 P 情景选择线型
                    color = color_map(j, :);      % CO₂ 情景对应的颜色

                    % 绘制曲线
                    plot(time, data, 'LineStyle', line_style, 'Color', color, 'LineWidth', 1.5);
                end
            end
        end

       % 根据变量名称设置 x 轴范围
if strcmp(variables{v}, 'CO2_input') || strcmp(variables{v}, 'Atmospheric_CO2_ppm')
    % 对于 CO₂ 输入和大气 CO₂ 浓度，设置 x 轴范围为 1990-2300
    xlim([1990 2300]);
else
    % 对于其他变量，设置 x 轴范围为 1900-5000
    xlim([1900 5000]);
end


        % 增加子图索引
        plot_idx = plot_idx + 1;

        % 在第四个子图中添加图例
        if v == 4
            % 创建图例条目
            legend_entries = cell(num_P * num_CO2, 1);
            idx = 1;
            for i = 1:num_P
                for j = 1:num_CO2
                    legend_entries{idx} = sprintf('%s, %s', P_values{i}, CO2_scenarios{j});
                    idx = idx + 1;
                end
            end
            % 添加图例
            legend(legend_entries, 'Location', 'bestoutside');
        end
    end

    % 调整子图之间的间距
    tight_layout = get(gcf, 'Children');
    set(tight_layout, 'TileSpacing', 'compact', 'Padding', 'compact');
% 
%    % 保存 figure 为 JPG 格式
% saveas(gcf, sprintf('%s_Box_Variables.jpg', box_name));
% 
% % 保存 figure 为 MATLAB 的 .fig 格式
% savefig(sprintf('%s_Box_Variables.fig', box_name));

end
