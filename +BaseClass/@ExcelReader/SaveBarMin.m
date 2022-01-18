% 分钟行情写入csv
% v1.3.0.202201135.beta
%       首次添加
function ret = SaveBarMin(~, asset, dir_)
% 预处理
% 生成输出目录
dir_ = fullfile(dir_, BaseClass.Database.Database.GetDbName(asset));
Utility.CheckDirectory(dir_);

% 生成输出文件名
filename = fullfile(dir_, BaseClass.Database.Database.GetTableName(asset) +  ".csv");

% 写入表头 / 写入数据
id = fopen(filename, 'w');
fprintf(id, 'datetime,open,high,low,last,turnover,volume,oi\r');
for i = 1 : size(asset.md, 1)
    this = asset.md(i, :);
    fprintf(id, '%s,%.4f,%.4f,%.4f,%.4f,%i,%i,%i\r',...
        datestr(this(1), 'yyyy-mm-dd HH:MM'), ...
        this(4), this(5), this(6), this(7), ...
        this(8), this(9), this(10));      
end
fclose(id);
ret = true;

end