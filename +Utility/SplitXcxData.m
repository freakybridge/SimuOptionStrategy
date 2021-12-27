% 分解XCX OPTION DATA
function SplitXcxData(root_, pth_hm)
% 路径配置
dir_raw = fullfile(root_, 'raw');
dir_final = fullfile(root_, 'final');

% 读取所有所有原始文件
file_raw = dir(dir_raw);
file_raw = file_raw(~[file_raw.isdir]);

symb_dat_map = containers.Map;
loc_col = [1, 2, 4 : 9, 12];
for i = 1 : length(file_raw)
    % 读取数据
    this_file = file_raw(i);
    fprintf('Reading file %s, %i/%i, please wait ...\r', this_file.name, i, length(file_raw));
    [~, ~, dat] = xlsread(fullfile(this_file.folder, this_file.name));
    dat(1, :) = [];
    dat = dat(:, loc_col);
    
    % 存入缓存
    symbols = unique(dat(:, 1));
    for j = 1 : length(symbols)
        key = symbols{j};
        tmp_dat = dat(ismember(dat(:, 1), key), 2 : end);
        tmp_dat = [datenum(tmp_dat(:, 1)), cell2mat(tmp_dat(:, 2 : end))];
        tmp_dat = tmp_dat(:, [1 : 5, 7, 6, 8]);
        if (symb_dat_map.isKey(key))
            symb_dat_map(key) = [symb_dat_map(key); tmp_dat];
        else
            symb_dat_map(key) = tmp_dat;
        end
    end    
end

% 读取合约信息
instrus = Utility.ReadSheet(pth_hm, 'instrument');

% 按合约代码输出
symbols = symb_dat_map.keys;
for i = 1 : length(symbols)
    info = instrus(ismember(instrus(:, 1), symbols{i}(3 : end)), :);
    opt = BaseClass.Instrument(info{1}, info{2}, info{3}, info{4}, info{5}, info{6}, info{7}, info{8}, pth_hm); 
    md = symb_dat_map(symbols{i});
    
    % 输出
    opt.MergeMarketData(md);
    opt.NewBarMarketData(5);
    opt.OutputMarketData(dir_final);
    fprintf('%s data saved, progress %i/%i, please wait ...\n', opt.symbol, i, length(symbols));
end

end