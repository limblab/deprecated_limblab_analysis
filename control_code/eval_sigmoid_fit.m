function fOut = eval_sigmoid_fit(cOUT,param)

fOut = cOUT.Fm*(1./(1+exp(-cOUT.A*param + cOUT.B)));
