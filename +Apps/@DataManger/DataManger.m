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
        
        ret = Database2Md();
        ret = DataSource2Md();
        md = Csv2Md(dir_in, opt);
        
        ret = Md2Csv(dir_out, opt, md);
        ret = Md2Database(opt, db_);
    end
end

