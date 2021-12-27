% ���ɱ�׼ʱ����
function [tm_axis, base_point] = GenStandardTimeAxis(timetable, datelst, inv)
% ����ʱ����
tm_axis = [];
inv = inv / 24 / 60;
for i = 1 : length(datelst)
    for j = 1 : size(timetable, 1)
        loc_s = datenum(sprintf('%i %i', datelst(i), timetable(j, 1)), 'yyyymmdd HHMM') + inv;
        loc_e = datenum(sprintf('%i %i', datelst(i), timetable(j, 2)), 'yyyymmdd HHMM');
        tm_axis = [tm_axis; (loc_s : inv : loc_e)'];
    end
end

% ���ɻ���
base_point = datenum(sprintf('%i %i', datelst(1), timetable(1, 1)), 'yyyymmdd HHMM');
end