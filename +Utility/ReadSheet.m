% ��ȡEXCEL���ݲ�����Լ���뱣���ַ������
function ret = ReadSheet(pth_hm, st)
[~, ~, ret] = xlsread(fullfile(pth_hm, 'movelist.xlsx'), st);
ret(1, :) = [];
for i = size(ret, 1) : -1 : 1
    if (~isnan(ret{i, end}))
        break;
    end
    ret(i, :) = [];
end
ret(:, 1) = cellfun(@(x) {Utility.Trans2Str(x)}, ret(:, 1));
end