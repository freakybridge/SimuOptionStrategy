% Ԥ����
clear;
clc;
path = 'D:\OneDrive\hisdata\movelist.xlsx';

% ��ȡ����
portfolio = Configuration(path);

% ��ȡ��������
LoadMarketData(portfolio);

% ��������
AlignMarketData(portfolio);

% ����ģ��ӯ��
Simulation(portfolio);

% ��ͼ
Draw(portfolio);