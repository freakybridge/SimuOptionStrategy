% 分钟行情写入csv
% v1.3.0.202201135.beta
%       首次添加
function ret = SaveBar(~, asset, dir_, header, dat_fmt)
% 预处理
% 生成输出目录
dir_ = fullfile(dir_, BaseClass.Database.Database.GetDbName(asset));
Utility.CheckDirectory(dir_);

% 生成输出文件名
filename = fullfile(dir_, BaseClass.Database.Database.GetTableName(asset) +  ".csv");

% 整列表头 / 数据格式
header = [header, '\r'];
dat_fmt = [dat_fmt, '\r'];

% 写入表头 / 写入数据
id = fopen(filename, 'w');
fprintf(id, header);
for i = 1 : size(asset.md, 1)
    this = asset.md(i, :);
    fprintf(id, dat_fmt, datestr(this(1), 'yyyy-mm-dd HH:MM'), this(4 : end));      
end
fclose(id);
ret = true;

end

