function Performance(po)
% 获取pnl
[pnl, lgds, tm_ax] = Instrument.GetPnL(po);

% 准备作图
pic_window = uiaxes;
pic_window.Title.String = 'Performance Graphic';
pic_window.Box = 'on';
%             Size_gui = get(Figure, 'Position');
%             Size_screen = get(0, 'screensize');
%             Figure.OuterPosition = [(Size_screen(3) - Size_gui(3)) / 2, (Size_screen(4) - Size_gui(4)) / 2, Size_gui(3), Size_gui(4)];
%             Figure.OuterPosition = [(Size_screen(3) - Size_gui(3)) / 2, (Size_screen(4) - Size_gui(4)) / 2, Size_gui(3), Size_gui(4)];
pic_window.OuterPosition = [0, 10, 550, 400];

dt_lst = tm_ax(:, 1);
plot(pic_window, 1 : length(dt_lst), pnl);
pic_window.XTick = 1 : length(dt_lst);
step = round(length(dt_lst) / 15);
loc = 1 : step : length(dt_lst);
pic_window.XTick = loc;
pic_window.XTickLabel = datestr(dt_lst(loc), 'mm/dd HH:MM');
pic_window.XTickLabelRotation = -60;

pic_window.YLabel.String = 'PnL';
axis(pic_window, 'tight');
grid(pic_window, 'on');
legend(pic_window, lgds, 'Location', 'best');

% 统计
curve_po = pnl(:, 1);
pnl_ori = pnl(:, 2 : end);
[~, loc] = max(sum(pnl_ori ~= 0));
curve_ori = pnl_ori(:, loc);
stats_po = Stats(curve_po);
stats_ori = Stats(curve_ori);

% 输出
str = ['---------------------------- PERFORMANCE -------------------------------------\n', ...
    '%12s%-16s%-16s%-16s%-8s\n', ...
    '%-12s%-16s%-16s%-16s%-8s\n', ...
    '%-12s%-16s%-16s%-16s%-8s\n', ...
    '------------------------------------------------------------------------------\n'];
fprintf(str, ...
    '', 'PNL', 'MAX LOSS', 'MAX DRAWDOWN', 'PLR', ...
    'ORIGINAL:', num2str(stats_ori.pnl, '%.02f'), num2str(stats_ori.max_loss, '%.02f'), [num2str(stats_ori.max_dd * 100, '%.02f'), '%'], num2str(stats_ori.plr, '%.02f'), ...
    'PORTFOLIO:', num2str(stats_po.pnl, '%.02f'), num2str(stats_po.max_loss, '%.02f'), [num2str(stats_po.max_dd * 100, '%.02f'), '%'], num2str(stats_po.plr, '%.02f') ...
    );
end


% 计算盈亏数值
function ret = Stats(curve)
% 计算盈亏
ret = struct;
ret.pnl = curve(end);

% 计算最大损失
ret.max_loss = min(curve);

% 计算最大回撤
[max_eq_h, loc_max_eq] = max(curve);
[max_eq_l, ~] = min(curve(loc_max_eq : end));
ret.max_dd = (max_eq_h - max_eq_l) / max_eq_l;

% 计算盈亏比
ret.plr = max_eq_h / abs(ret.max_loss);

end