% DataManager / DatabaseBackup
% v1.3.0.20220113.beta
%      1.首次加入
function DatabaseRestore(obj, dir_rt, prefix)

% 读取所有文件
folders = dir(dir_rt);
for i = length(folders) : -1 : 1
    this = folders(i);
    if (strcmp(this.name, '.'))
        folders(i) = [];
    elseif (strcmp(this.name, '..'))
        folders(i) = [];
    elseif (~this.isdir)
        folders(i) = [];
    else
        loc = strfind(this.name, '-');
        if (isempty(loc))
            folders(i) = [];
        elseif (~strcmp(this.name(1 : loc(1) - 1), prefix))
            folders(i) = [];
        else
            continue;
        end
    end
end

% 逐一入库


% 生成资产

% 读取行情

% 入库


end