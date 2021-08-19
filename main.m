% 预处理
clear;
clc;
path = 'E:\Document\20210818\market_data\';

% 设定头寸组合
portfolio = [];
portfolio = AddLeg('10003318-2109-p-3.100', -1, 1, '2021-08-03 09:30', portfolio);
portfolio = AddLeg('10003470-2108-p-3.100', 1, 3, '2021-08-13 10:24', portfolio);
portfolio = AddLeg('10003318-2109-p-3.100', -1, 2, '2021-08-17 14:20', portfolio);
exit_timng = '2021-08-28 15:00';

% 对齐行情
portfolio = AlignMarketData(path, portfolio, exit_timng);

% 计算模拟盈亏
[pnl, price] = Simulation(portfolio);

% 作图
Draw(pnl);