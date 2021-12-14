% 预处理
clear;
clc;
path = 'D:\OneDrive\hisdata\movelist.xlsx';

% 读取配置
portfolio = Configuration(path);

% 读取行情数据
LoadMarketData(portfolio);

% 对齐行情
AlignMarketData(portfolio);

% 计算模拟盈亏
Simulation(portfolio);

% 作图
Draw(portfolio);