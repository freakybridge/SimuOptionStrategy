% DataManager / LoadMd 多种方式获取行情
% v1.2.0.20220105.beta
%      1.首次加入
function LoadMd(obj, ast, dir_csv, dir_tb)
% 读取数据库
obj.LoadMdViaDatabase(ast);

% 读取csv
if (obj.IsMdComplete(ast))
    return;
end
obj.LoadMdViaCsv(ast, dir_csv);

% 读取淘宝excel
if (obj.IsMdComplete(ast))
    obj.SaveMd2Database(ast);
    return;
end
obj.LoadMdViaTaobaoExcel(ast, dir_tb);

% 更新
if (~obj.IsMdComplete(ast))
    obj.LoadMdViaDataSource(ast);
end
obj.SaveMd2Database(ast);
obj.SaveMd2Csv(ast, dir_csv);
end

