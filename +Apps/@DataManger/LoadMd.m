% DataManager / LoadMd
% v1.2.0.20220105.beta
%      1.首次加入
function LoadMd(obj, ast, dir_csv)
% 读取数据库
obj.LoadMdViaDatabase(ast);

% 判定是否读取csv
if (IsDataFinish(ast))
    return;
end
obj.LoadMdViaCsv(ast, dir_csv);

% 判定是否读取csv
if (IsDataFinish(ast))
    obj.SaveMd2Database(ast);
    return;
end
obj.LoadMdViaDataSource(ast);

% 保存数据
obj.SaveMd2Database(ast);
obj.SaveMd2Csv(ast, dir_csv);

end

% 判定是否数据充足
function ret = IsDataFinish(ast)
switch ast.product
    case EnumType.Product.Option
        if (datenum(ast.GetDateExpire) - ast.md(end, 1) <= 15 / (24 * 60))
            ret = true;
        else
            ret = false;
        end        
        
    otherwise
        error("Unexpected ""product"" for market data accomplished judgement, please check");
end
end