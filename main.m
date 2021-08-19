% 预处理
clear;
clc;
path = 'E:\Document\20210818\market_data\';

% 设定头寸组合
portfolio = [];
portfolio = AddLeg('10003471-2108-p-3.200', -1, 1, '2021-07-27 09:30', portfolio);
portfolio = AddLeg('10003424-2107-p-3.200', 1, 1, '2021-07-27 09:30', portfolio);
exit_timng = '2021-07-28 15:00';

% 对齐行情
portfolio = AlignMarketData(path, portfolio, exit_timng);

% 计算模拟盈亏
pnl = Simulation(portfolio);

% 作图
Draw(pnl);