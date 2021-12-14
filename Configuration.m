% ��ȡ����
function ret = Configuration(path)
% Ԥ����
ret = containers.Map;

% ��ȡ���к�Լ��Ϣ
[~, ~, dat] = xlsread(path, 'instrument');
dat(1, :) = [];
for i = 1 : size(dat, 1)
    tmp = dat(i, :);
    this = Instrument(tmp{1}, tmp{2}, tmp{3}, tmp{4}, tmp{5}, tmp{6}, path);
    ret(this.symbol) = this;
end

% ��ȡ���׶����嵥
[~, ~, dat] = xlsread(path, 'move');
dat(1, :) = [];
for i = 1 : size(dat, 1)
    tmp = dat(i, :);
    this = ret(num2str(tmp{1}));
    this.AddMove(tmp{2}, tmp{3})
end
end