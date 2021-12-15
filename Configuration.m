% 读取配置
function ret = Configuration(path)

% 读取操作目标合约 / 动作列表
[~, ~, move] = xlsread(path, 'move');
move(1, :) = [];
move(:, 1) = cellfun(@(x) {Trans2Str(x)}, move(:, 1));
symbols = unique(move(:, 1));

% 预处理合约信息
ret = containers.Map;
[~, ~, info] = xlsread(path, 'instrument');
info(1, :) = [];
info(:, 1) = cellfun(@(x) {Trans2Str(x)}, info(:, 1));
pool = info(:, 1);

% 定位目标合约信息
for i = 1 : size(symbols, 1)    
    [~, ~, loc] = intersect(symbols{i}, pool);
    if (~isempty(loc))
        this = info(loc, :);
        this = Instrument(this{1}, this{2}, this{3}, this{4}, this{5}, this{6}, this{7}, path);
        ret(this.symbol) = this;
    else
        error(['Can''t find target instrument ',  symbols{i}, ' info, Please check'])
    end    
end

% 读取交易动作清单
for i = 1 : size(move, 1)
    this = move(i, :);
    instru = ret(this{1});
    instru.AddMove(this{2}, this{3})
end
end

% 合约编号转字符串
function ret = Trans2Str(in_)
if (isa(in_, 'double'))
    ret = num2str(in_);
else
    ret = in_;
end
end