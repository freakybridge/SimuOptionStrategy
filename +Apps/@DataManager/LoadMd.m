% DataManager / LoadMd ���ַ�ʽ��ȡ����
% v1.3.0.20220113.beta
%      1.�޸��߼�������Ч��
% v1.2.0.20220105.beta
%      1.�״μ���
function LoadMd(obj, ast, dir_csv, dir_tb)

% ��ȡ���ݿ� / csv
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
    
% ��ȡ�Ա�excel
obj.LoadMdViaTaobaoExcel(ast, dir_tb);
if (obj.IsMdComplete(ast))    
    obj.SaveMd2Database(ast);
    obj.SaveMd2Csv(ast, dir_csv);
end

% ����
obj.LoadMdViaDataSource(ast);
if (~isempty(ast.md))
    obj.SaveMd2Database(ast);
    obj.SaveMd2Csv(ast, dir_csv);
end

end

