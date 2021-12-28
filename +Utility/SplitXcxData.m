% �ֽ�XCX OPTION DATA
function SplitXcxData(root_, pth_hm)
% Ԥ����
file_dat_buffer = cell(0, 9);
symb_dat_map = containers.Map;

% ·������
dir_raw = fullfile(root_, 'raw');
dir_final = fullfile(root_, 'final');

% ��ȡ��������ԭʼ�ļ�
file_raw = dir(dir_raw);
file_raw = file_raw(~[file_raw.isdir]);

% ��ȡ�����ļ�
for i = 1 : length(file_raw)
    this_file = file_raw(i);
    fprintf('Scanning file %s, %i/%i, please wait ...\r', this_file.name, i, length(file_raw));
    [~, ~, dat] = xlsread(fullfile(this_file.folder, this_file.name));
    dat(1, :) = [];
    dat = dat(:, [1, 2, 4 : 9, 12]);
    file_dat_buffer = [file_dat_buffer; dat];
end


% ��Ϣ��������뻺��
symbols = unique(file_dat_buffer(:, 1));
for i = 1 : length(symbols)
    key = symbols{i};
    fprintf('Extracting option %s data, %i/%i, please wait ...\r', key, i, length(symbols));    
    
    loc = ismember(file_dat_buffer(:, 1), key);
    tmp_dat = file_dat_buffer(loc, 2 : end);
    tmp_dat = [datenum(tmp_dat(:, 1)), cell2mat(tmp_dat(:, 2 : end))];
    tmp_dat = tmp_dat(:, [1 : 5, 7, 6, 8]);
    if (symb_dat_map.isKey(key))
        symb_dat_map(key) = [symb_dat_map(key); tmp_dat];
    else
        symb_dat_map(key) = tmp_dat;
    end
    
    file_dat_buffer(loc, :) = [];
end

% ��ȡ��Լ��Ϣ
instrus = Utility.ReadSheet(pth_hm, 'instrument');

% ����Լ�������
symbols = symb_dat_map.keys;
for i = 1 : length(symbols)
    info = instrus(ismember(instrus(:, 1), symbols{i}(3 : end)), :);
    opt = BaseClass.Instrument(info{1}, info{2}, info{3}, info{4}, info{5}, info{6}, info{7}, info{8}, pth_hm); 
    md = symb_dat_map(symbols{i});
    
    % ���
    opt.MergeMarketData(md);
    opt.NewBarMarketData(5);
    opt.OutputMarketData(dir_final);
    fprintf('%s data saved, progress %i/%i, please wait ...\n', opt.symbol, i, length(symbols));
end

end