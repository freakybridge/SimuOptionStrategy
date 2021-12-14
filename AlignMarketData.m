function AlignMarketData(port)

% 获取完整时间轴
time_axis = Instrument.UnionTimeAxis(port);

% 对齐行情
keys = port.keys;
for i = 1 : length(keys)
    this = port(keys{i});
    this.RepairData(time_axis);
end
end