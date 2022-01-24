% DataManager / DatabaseBackup
% v1.3.0.20220113.beta
%      1.�״μ���
function DatabaseRestore(obj, dir_bak)

% Ԥ����
folder_ins = 'INSTRUMENTS';
folder_cal = 'CALENDAR';


% ��ȡ�����ļ�
folders = dir(dir_bak);
for i = length(folders) : -1 : 1
    this = folders(i);
    if (strcmp(this.name, '.'))
        folders(i) = [];
    elseif (strcmp(this.name, '..'))
        folders(i) = [];
    elseif (~this.isdir)
        folders(i) = [];
    elseif (strcmp(this.name, folder_ins) || (strcmp(this.name, folder_cal)))
        continue;        
    else
        loc = strfind(this.name, '-');
        if (isempty(loc))
            folders(i) = [];
        else
            inv = this.name(1 : loc(1) - 1);
            try
                EnumType.Interval.ToEnum(inv);
            catch
                folders(i) = [];
            end
            continue;
        end
    end
end

% ��һ���
for i = 1 : length(folders)
    this = folders(i);
    switch this.name
        case folder_cal
            % �������
            continue;
            RestoreCalendar(obj, dir_bak);
            
        case folder_ins
            % ����Լ��
            continue;
            RestoreInstruments(obj, dir_bak, folder_ins);
            
            
        otherwise
            
            
            % �����ʲ�
            
            % ��ȡ����
            
            % ���

            continue;
    end
end
end

% �������
function RestoreCalendar(obj, dir_bak)
fprintf('Restoring [Calendar], please wait ...\r');
cal = obj.dr.LoadCalendar(dir_bak);
obj.db.SaveCalendar(cal);
end


% ����Լ��
function RestoreInstruments(obj, dir_bak, folder_ins)
% ��ȡ���к�Լ��
files = dir(fullfile(dir_bak, folder_ins));
files([files.isdir]) = [];

% ��һ��ȡ���
for i = 1 : length(files)
    this = files(i);
    loc_hyphen = strfind(this.name, '-');
    loc_dot = strfind(this.name, '.');
    try
        product = EnumType.Product.ToEnum(this.name(1 : loc_hyphen(1) - 1));
        variety = this.name(loc_hyphen(1) + 1 : loc_hyphen(2) - 1);
        exchange = EnumType.Exchange.ToEnum(this.name(loc_hyphen(2) + 1 : loc_dot(1) - 1));
        fprintf('Restoring [Instruments]-[%s], please wait ...\r', this.name(1 : loc_dot(1) - 1));
    catch
        fprintf(2, 'Restoring Error, can''t find information in [%s], please check !\r', fullfile(this.folder, this.name));
        continue;
    end
    
    ins = obj.dr.LoadChain(product, variety, exchange, dir_bak);
    obj.db.SaveChain(product, variety, exchange, ins);
end
end

