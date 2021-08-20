% 预处理
clear;
clc;
path = 'C:\Users\freakybridge\Desktop\20210818\market_data\';

% 设定头寸组合
portfolio = [];
portfolio = AddLeg(portfolio, '2002-p-2.700-10002282', -1, 1, '2020-02-04 09:30', '2020-02-26 15:00');
portfolio = AddLeg(portfolio, '2006-p-2.500-10002295', 1, 1, '2020-02-04 09:30', '2020-02-26 15:00');

% 对齐行情
[portfolio, time_axis] = AlignMarketData(path, portfolio);

% 计算模拟盈亏
[pnl, price] = Simulation(portfolio, time_axis);

% 作图
Draw(pnl);