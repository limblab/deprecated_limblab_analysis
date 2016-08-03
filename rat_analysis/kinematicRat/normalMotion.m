clear all

walk = load('./data/bas_s10_d30_01.mat');
freq = walk.rat.f;

varNames = {'hip','knee','ankle','mtp','limbV_ang'};


%% Gain cycles of stereotypical walking

for j=1:length(varNames)

    varTmp = varNames{j};
    figure       
        
    var  = ['walk.rat_sg.' varTmp '_seg'];
    tmpd = eval(var);
    
    mBef = mean(tmpd,2,'omitnan');
    sBef = std(tmpd,0,2,'omitnan');

    plot(1:100, mBef,'linewidth',3)
    
    shadedErrorBar(1:100, mBef, sBef, ...
                          {'b','linewidth',3},1)
                       
    grid on
    xlabel('gait cycle [%]')
    ylabel([varTmp ' [deg]'])    
    
end

%% Sequence of strides during experiment (30s)

for j=1:length(varNames)

    varTmp = varNames{j};
    figure       
        
    if strcmp(varTmp,'limbV_ang')
       tmpd = eval(['walk.rat_sg.' varTmp]);
    else
      var  = ['walk.rat_sg.' varTmp '_ang'];
      tmpd = eval(var);
    end
    
    t = [linspace(0,length(tmpd)/freq,length(tmpd))]';
    
    plot(t, tmpd)
    
    axis tight
    grid on
    xlabel('time [s]')
    ylabel([varTmp ' [deg]'])    
    
end