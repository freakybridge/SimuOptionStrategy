% DataManager / LoadMd 多种方式获取行情
% v1.3.0.20220113.beta
%      1.修改逻辑，提升效率
% v1.2.0.20220105.beta
%      1.首次加入
function LoadMd(obj, ast, dir_csv, dir_tb)

% 读取数据库 / csv
obj.LoadMdViaDatabase(ast);
if (isempty(ast.md))
    obj.LoadMdViaCsv(ast, dir_csv);
    if (obj.IsMdComplete(ast))
        obj.SaveMd2Database(ast);
        return;
    end
elseif (obj.IsMdComplete(ast))
    return;
end
    
% 读取淘宝excel
obj.LoadMdViaTaobaoExcel(ast, dir_tb);
if (obj.IsMdComplete(ast))    
    obj.SaveMd2Database(ast);
    obj.SaveMd2Csv(ast, dir_csv);
end

% 更新
obj.LoadMdViaDataSource(ast);
if (~isempty(ast.md))
    obj.SaveMd2Database(ast);
    obj.SaveMd2Csv(ast, dir_csv);
end

end

