-- demo
I18N = I18N or {{}}

function I18N.GetText(txt)
    return TI18N(txt)
end

function TI18N(txt)
    return txt
end

function _T(txt)
    return txt
end