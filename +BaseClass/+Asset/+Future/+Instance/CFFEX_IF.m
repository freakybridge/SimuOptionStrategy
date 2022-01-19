% IF FUTURE��
% v1.3.0.20220113.beta
%       �״����
classdef (Sealed) CFFEX_IF < BaseClass.Asset.Future.Future
    
    % ����Asset����
    properties (Constant)
        exchange EnumType.Exchange = EnumType.Exchange.CFFEX;
        variety char = 'IF';
        tradetimetable double = [[930, 1130]; [1300, 1500]];
        tick_size double = 0.2;
        date_ini char = '2010/04/16';
    end
    
    % ���캯��
    methods
        function obj = CFFEX_IF(symb, snm, inv, sz, ltdt, epdt, mgn, fety, f)
            obj = obj@BaseClass.Asset.Future.Future(symb, snm, inv, sz, ltdt, epdt, mgn, fety, f);
        end
    end
end