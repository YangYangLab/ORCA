function online_updateSLM(varargin)
global ORCA
slmchoice = str2num(ORCA.Online.GObj.SLMChoice.String);
if ORCA.Experiment.SLMChoice ~= slmchoice
    ORCA.Experiment.SLMChoice = slmchoice;
    feval(ORCA.Device.SLMCallback, ORCA.Experiment.SLMTemplate, ORCA.Experiment.SLMChoice);
end
end