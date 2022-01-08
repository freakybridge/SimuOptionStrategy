% ת���Ա�excel
% v1.2.0.20220105.beta
%       �״����
function ret = TransferTaobaoExcel(dir_hm, dir_tb, dir_sav)
% ��ȡ���к�Լ��Ϣ
ret = false;
instrus = Utility.ReadSheet(dir_hm, 'instrument');

% ���·��
dir_tb = fullfile(dir_tb, 'dat');
if (~exist(dir_tb, 'dir'))
    warning('can''t find taobao dat directory, please check .');
    return;
end
Utility.CheckDirectory(dir_sav);
    
% ��ȡ�����ļ�
files = [];
tmp = dir(dir_tb);
for i = 1 : length(tmp)
    this = tmp(i);
    if (~strcmpi(this.name, '.') && ~strcmpi(this.name, '..') && this.isdir)
        files = [files; dir(fullfile(this.folder, this.name))];
    end
end
files([files.bytes] == 0) = [];


% ��һ��ȡ
symbols = cellfun(@(x) str2double(x), instrus(:, 1));
for i = 1 : length(files)
    % ��ȡ��Լ��Ϣ
    this = files(i);
    symb = sscanf(this.name, '%i.xlsx');
    info = instrus(symbols == symb, :);
    opt = BaseClass.Asset.Option("5M", info{1},  info{2},  info{3},  info{7}, [[930, 1130]; [1300, 1500]], info{4}, info{5}, info{6}, info{8}, info{9});
    fprintf('Transfer %s market data, %i/%i,, please wait ...\r', info{1}, i, length(files));
    
    % ��ȡexcel / ���nan
    [dat, ~, raw] = xlsread(fullfile(this.folder, this.name));
    raw = raw(1 : 1 + size(dat, 1), :);
    dat = raw(2 : end, :);
    header = raw(1, :);
    
    % ��������
    md = [FetchField(dat, header, '����ʱ��'), ...
        FetchField(dat, header, '���̼�'), ...
        FetchField(dat, header, '��߼�'), ...
        FetchField(dat, header, '��ͼ�'), ...
        FetchField(dat, header, '���̼�'), ...
        FetchField(dat, header, '�ɽ���'), ...
        FetchField(dat, header, '�ɽ���'), ...
        FetchField(dat, header, '�ֲ���'), ...
        FetchField(dat, header, '��Ȩ��') / 1000, ...
        FetchField(dat, header, '��Լ��λ'), ...
        FetchField(dat, header, '������̼�')];
    opt.MergeMarketData(md);
    
    % ����CSV
    Apps.DataManger.Md2Csv(dir_sav, opt);
end
ret = true;

end


% ��ȡ�ֶ�
function ret = FetchField(dat, header, field)
loc = ismember(header, field);
if (sum(loc))
    if (strcmpi(field, '����ʱ��'))
        ret = dat(:, loc);
        ret = datenum(ret);
    else
        ret = cell2mat(dat(:, loc));
    end
else
    ret = zeros(size(dat, 1), 1);
end
end