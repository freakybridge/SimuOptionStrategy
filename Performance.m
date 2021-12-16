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

% 输出盈亏
pnl_po = pnl(end, 1);
pnl_ori = pnl(:, 2 : end);
[~, loc] = max(sum(pnl_ori ~= 0));
pnl_ori = pnl_ori(end, loc);
disp(['Portfolio''s pnl: ', num2str(pnl_po, '%.02f')]);
disp(['Original position''s pnl: ', num2str(pnl_ori, '%.02f')]);
end