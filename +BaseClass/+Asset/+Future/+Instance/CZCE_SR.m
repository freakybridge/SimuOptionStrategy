% SR FUTURE��
% v1.3.0.20220113.beta
%       �״����
classdef (Sealed) CZCE_SR < BaseClass.Asset.Future.Future
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.CZCE;
        variety char = 'SR';
        tradetimetable double = [[900, 1015]; [1030, 1130]; [1330, 1500]; [2100, 2300]];
        tick_size double = 1;
        date_ini char = '2006/01/06';
    end
    
    % ���캯��
    methods
        function obj = CZCE_SR(symb, snm, inv, sz, epdt, mgn, fety, f)
            obj = obj@BaseClass.Asset.Future.Future(symb, snm, inv, sz, epdt, mgn, fety, f);
        end
    end
end