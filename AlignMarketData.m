function AlignMarketData(port)

% ��ȡ����ʱ����
time_axis = Instrument.UnionTimeAxis(port);

% ��������
keys = port.keys;
for i = 1 : length(keys)
    this = port(keys{i});
    this.RepairData(time_axis);
end
end