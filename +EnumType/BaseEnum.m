classdef BaseEnum
    methods (Abstract, Hidden)
        ret = ToString(in_);
        ret = ToEnum(in_);
    end
end