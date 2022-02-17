% 分钟行情写入csv
% v1.3.0.202201135.beta
%       首次添加
function ret = SaveBar(~, asset, dir_, header, dat_fmt_in)
% 预处理
% 生成输出目录
dir_ = fullfile(dir_, BaseClass.Database.Database.GetDbName(asset));
Utility.CheckDirectory(dir_);

% 生成输出文件名
filename = fullfile(dir_, BaseClass.Database.Database.GetTableName(asset) +  ".csv");

% 整列表头 / 数据格式 / preprocess md
md = asset.md;
header = [header, '\r'];
dat_fmt = repmat([dat_fmt_in, '\r'], 1, size(md, 1));
md = [cellstr(datestr(md(:, 1), 'yyyy-mm-dd HH:MM')), num2cell(md(:, 4 : end))]';
md = sprintf(dat_fmt, md{:});

% write header / data
id = fopen(filename, 'w');
fprintf(id, header);
fprintf(id, md);
fclose(id);
ret = true;
end

