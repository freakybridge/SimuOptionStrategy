% ���Ա�excel��ȡ����
% v1.2.0.20220105.beta
%       �״����
function LoadMdViaTaobaoExcel(~, ast, dir_tb)

% Ѱ��Ŀ���ļ�
files = FetchFiles(dir_tb);
this = files(ismember({files.name}, [ast.symbol, '.xlsx']));
if (isempty(this))
    return;
end
  
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
    FetchField(dat, header, '�ֲ���')];

% ����ظ�ʱ���
md = ClearRepeatDatetime(md);

% д���ڴ�
ast.MergeMarketData(md);
end


% ��ȡ�ļ�Ŀ¼
function ret = FetchFiles(dir_tb)
persistent files_buffer;
if (~isempty(files_buffer))
    ret = files_buffer;
    return;
end

% ���·��
dir_tb = fullfile(dir_tb, 'dat');
if (~exist(dir_tb, 'dir'))
    error('can''t find taobao dat directory, please check .');
end

% ��ȡ�����ļ�
files_buffer = [];
tmp = dir(dir_tb);
for i = 1 : length(tmp)
    this = tmp(i);
    if (~strcmpi(this.name, '.') && ~strcmpi(this.name, '..') && this.isdir)
        files_buffer = [files_buffer; dir(fullfile(this.folder, this.name))];
    end
end
files_buffer([files_buffer.bytes] == 0) = [];
ret = files_buffer;
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

% ����ظ�ʱ���
function md = ClearRepeatDatetime(md)
% ȷ��ʱ���Ψһ��
loc = [-1; diff(md(:, 1))];
dt_repeat = unique(md(loc == 0, 1));
if (isempty(dt_repeat))
    return;
end

% �����޳ɽ�����������һ������
% �������ɽ�������һ������
for i = 1 : length(dt_repeat)
    this_dt = dt_repeat(i);
    head = md(md(:, 1) < this_dt, :);
    tail = md(md(:, 1) > this_dt, :);
    body = md(md(:, 1) == this_dt, :);
    
    if (all(body(:, 7) == 0))
        loc = 1;
    else
        [~, loc] = max(body(:, 7));
    end
    body = body(loc, :);
    
    md = [head; body; tail];
end
end