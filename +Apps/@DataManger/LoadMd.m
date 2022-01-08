% DataManager / LoadMd
% v1.2.0.20220105.beta
%      1.�״μ���
function LoadMd(obj, ast, dir_csv)
% ��ȡ���ݿ�
obj.LoadMdViaDatabase(ast);

% �ж��Ƿ��ȡcsv
if (IsDataFinish(ast))
    return;
end
obj.LoadMdViaCsv(ast, dir_csv);

% �ж��Ƿ��ȡcsv
if (IsDataFinish(ast))
    obj.SaveMd2Database(ast);
    return;
end
obj.LoadMdViaDataSource(ast);

% ��������
obj.SaveMd2Database(ast);
obj.SaveMd2Csv(ast, dir_csv);

end

% �ж��Ƿ����ݳ���
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