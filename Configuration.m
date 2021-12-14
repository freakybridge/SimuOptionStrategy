% 读取配置
function ret = Configuration(path)
% 预处理
ret = containers.Map;

% 读取所有合约信息
[~, ~, dat] = xlsread(path, 'instrument');
dat(1, :) = [];
for i = 1 : size(dat, 1)
    tmp = dat(i, :);
    this = Instrument(tmp{1}, tmp{2}, tmp{3}, tmp{4}, tmp{5}, tmp{6}, path);
    ret(this.symbol) = this;
end

% 读取交易动作清单
[~, ~, dat] = xlsread(path, 'move');
dat(1, :) = [];
for i = 1 : size(dat, 1)
    tmp = dat(i, :);
    this = ret(num2str(tmp{1}));
    this.AddMove(tmp{2}, tmp{3})
end
end