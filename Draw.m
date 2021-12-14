function Draw(po)
% 获取pnl
[pnl, lgds] = Instrument.GetPnL(po);

% 准备作图
pic_window = uiaxes;
pic_window.Title.String = 'Performance Graphic';
pic_window.Box = 'on';
%             Size_gui = get(Figure, 'Position');
%             Size_screen = get(0, 'screensize');
%             Figure.OuterPosition = [(Size_screen(3) - Size_gui(3)) / 2, (Size_screen(4) - Size_gui(4)) / 2, Size_gui(3), Size_gui(4)];
%             Figure.OuterPosition = [(Size_screen(3) - Size_gui(3)) / 2, (Size_screen(4) - Size_gui(4)) / 2, Size_gui(3), Size_gui(4)];
pic_window.OuterPosition = [0, 10, 550, 400];

date_list = pnl(:, 1);
plot(pic_window, 1 : length(date_list), pnl(:, [4 : end]));
pic_window.XTick = 1 : length(date_list);
step = round(length(date_list) / 15);
loc = 1 : step : length(date_list);
pic_window.XTick = loc;
pic_window.XTickLabel = datestr(date_list(loc), 'mm/dd HH:MM');
pic_window.XTickLabelRotation = -60;

pic_window.YLabel.String = 'PnL';
axis(pic_window, 'tight');
grid(pic_window, 'on');
legend(pic_window, lgds, 'Location', 'best');

end