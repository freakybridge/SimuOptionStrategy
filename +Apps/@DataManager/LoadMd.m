% DataManager / LoadMd ���ַ�ʽ��ȡ����
% v1.2.0.20220105.beta
%      1.�״μ���
function LoadMd(obj, ast, dir_csv, dir_tb)
% ��ȡ���ݿ�
obj.LoadMdViaDatabase(ast);

% ��ȡcsv
if (obj.IsMdComplete(ast))
    return;
end
obj.LoadMdViaCsv(ast, dir_csv);

% ��ȡ�Ա�excel
if (obj.IsMdComplete(ast))
    obj.SaveMd2Database(ast);
    return;
end
obj.LoadMdViaTaobaoExcel(ast, dir_tb);

% ����
if (~obj.IsMdComplete(ast))
    obj.LoadMdViaDataSource(ast);
end
obj.SaveMd2Database(ast);
obj.SaveMd2Csv(ast, dir_csv);
end
