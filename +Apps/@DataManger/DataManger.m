classdef DataManger
    % FORMATTRANSFER �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        Property1
    end
    
    methods
        function obj = DataManger()
        end
        
    end
    
    methods (Static)
        ret = TransferTaobaoExcel(dir_hm, dir_tb, dir_sav);        
        ret = Excel2Database();
        ret = Database2Excel();
        ret = DataSource2Excel();
        ret = DataSource2Database();
    end
end

