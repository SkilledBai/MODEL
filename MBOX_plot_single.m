% 加载模型结果
load('model_results.mat'); % 请确保结果文件存在，并包含所需的情景数据

% 假设结果只包含一个情景，即 results{i, j}
% 您需要指定要绘制的情景索引，如果只有一个情景，则 i = 1, j = 1
i = 1;
j = 4;

% 获取指定情景的状态变量
state = results{i, j}.state;
time = state.time_myr .* 1e6;  % 将时间转换为年

% 定义海洋箱的标识符和名称
ocean_boxes = {'p', 'di', 's', 'h', 'd'}; % 海洋箱代码
box_labels = {'Proximal', 'Distal', 'Surface', 'High-lat', 'Deep'}; % 海洋箱名称
num_boxes = length(ocean_boxes);

% 创建新的图形窗口，并设置大小为 1000x1000 像素
figure('Color',[1 0.98 0.95], 'Name', 'Single Scenario Plots', 'Position', [100, 100, 1000, 1000]);

% 创建 3 行 2 列的子图布局
tiledlayout(3,2, 'TileSpacing', 'compact', 'Padding', 'compact');


        

% 子图 1：温度
nexttile;
hold on;
grid on;
box on;
xlabel('Time (years)');
ylabel('Temperature (°C)');
title('Temperature');
xlim([1800 3000]);

for b = 1:num_boxes
    box_code = ocean_boxes{b};
    box_name = box_labels{b};
    % 获取温度数据并转换为摄氏度
    T = state.(['T_' box_code]) - 273.15;
    plot(time, T, 'LineWidth', 1.5, 'DisplayName', box_name);
end

legend('Location', 'best');

% 子图 2：大气 CO₂
nexttile;
hold on;
grid on;
box on;
xlabel('Time (years)');
ylabel('Atmospheric CO₂ (ppm)');
title('Atmospheric CO₂');
xlim([1800 3000]);

% 获取大气 CO₂ 数据
Atmospheric_CO2_ppm = state.Atmospheric_CO2_ppm;
plot(time, Atmospheric_CO2_ppm, 'LineWidth', 1.5);

% 子图 3：pH 值
nexttile;
hold on;
grid on;
box on;
xlabel('Time (years)');
ylabel('pH');
title('pH');
xlim([1800 3000]);

for b = 1:num_boxes
    box_code = ocean_boxes{b};
    box_name = box_labels{b};
    pH = state.(['pH_' box_code]);
    plot(time, pH, 'LineWidth', 1.5, 'DisplayName', box_name);
end

legend('Location', 'best');

% 子图 4：海洋 O₂ 浓度
nexttile;
hold on;
grid on;
box on;
xlabel('Time (years)');
ylabel('O₂ Concentration (mM)');
title('Ocean O₂ Concentration');
xlim([1800 3000]);

for b = 1:num_boxes
    box_code = ocean_boxes{b};
    box_name = box_labels{b};
    O2_conc = state.(['O2_conc_' box_code]);
    plot(time, O2_conc, 'LineWidth', 1.5, 'DisplayName', box_name);
end

legend('Location', 'best');

% 加载 CO₂ 和 P 输入数据

% 加载 CO₂ 输入数据
CO2_input_data = xlsread(CO2_forcings{1});
CO2_input_time = CO2_input_data(:,1);
CO2_input_values = CO2_input_data(:,2);

% 加载 P 输入数据
P_input_data = csvread(P_forcings{1});
P_input_time = P_input_data(:,1);
P_input_values = P_input_data(:,2);


% 子图 5：P 输入
nexttile;
hold on;
grid on;
box on;
xlabel('Time (years)');
ylabel('P Input (mol/year)');
title('P Input');
xlim([1800 3000]);

plot(P_input_time, P_input_values, 'k-', 'LineWidth', 1.5);

% 子图 6：CO₂ 输入
nexttile;
hold on;
grid on;
box on;
xlabel('Time (years)');
ylabel('CO₂ Input (GtC/year)');
title('CO₂ Input');
xlim([1800 3000]);

plot(CO2_input_time, CO2_input_values, 'b-', 'LineWidth', 1.5);


% 调整布局和图形大小，使子图接近正方形
set(gcf, 'Position', [100, 100, 800, 800]);

% 保存图形为 JPG 和 MATLAB 的 .fig 格式
% saveas(gcf, 'Single_Scenario_Plots.jpg');
% savefig('Single_Scenario_Plots.fig');
