% ºÏÔ¼±àºÅ×ª×Ö·û´®
function ret = Trans2Str(in_)
if (isa(in_, 'double'))
    ret = num2str(in_);
else
    ret = in_;
end
end