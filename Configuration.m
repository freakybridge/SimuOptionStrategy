% 读取配置
function ret = Configuration(path)

% 读取操作目标合约 / 动作列表
move = Utility.ReadSheet(path, 'move');
symbols = unique(move(:, 1));

% 预处理合约信息
info = Utility.ReadSheet(path, 'instrument');
pool = info(:, 1);

% 定位目标合约信息
ret = containers.Map;
for i = 1 : size(symbols, 1)    
    [~, ~, loc] = intersect(symbols{i}, pool);
    if (~isempty(loc))
        this = info(loc, :);
        this = BaseClass.Instrument(this{1}, this{2}, this{3}, this{4}, this{5}, this{6}, this{7}, path);
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



