function finalValveOK = dropcFinalValveOK_WM1(handles)
%Opens final valve, purge valve odor on and finds out whtehr the mouse stays in the
%odor sampling area

start_toc=toc;

noSamples=0;
noSamplesMouseOn=0;



%Otherwise, fvtime falls randomly between 1 and 1.5
fvtime = 0.666666*handles.dropcProg.fvtime +0.333333*handles.dropcProg.fvtime*rand(1);





%Notify draq, turn final valve and odor on, etc...


%Turn on (or not) opto stimulus during FV
opto_on=0;
handles.dropcData.allTrialOptoOn(handles.dropcData.allTrialIndex+1)=0;
if (handles.dropcProg.whenOptoOn==1)
    % if handles.dropcProg.odorValve==handles.dropcProg.splusOdorValve %for S+
    %if handles.dropcProg.odorValve==handles.dropcProg.sminusOdorValve %for S-
    %if you want to randomly send TTL opto uncomment this line
    %         if handles.dropcProg.randomOpto(handles.dropcData.fellowsNo)==1
    dataValue=uint8(0);
    putvalue(handles.dio.Line(9:12),dataValue);
    opto_on=1;
    handles.dropcData.allTrialOptoOn(handles.dropcData.allTrialIndex+1)=1;
end

%Notify draq
if opto_on==0
    handles.dropcDigOut.draqPortStatus=handles.dropcDraqOut.final_valve;
else
    handles.dropcDigOut.draqPortStatus=handles.dropcDraqOut.final_valve+handles.dropcDraqOut.opto_on;
end
dropcUpdateDraqPort(handles);

%Divert final valve towards the exhaust
%Divert purge valve towards the port
dataValue = handles.dropcDioOut.final_valve+handles.dropcDioOut.purge_valve;
dataValue=bitcmp(dataValue);
putvalue(handles.dio.Line(17:24),dataValue);


%Turn on odor valve
dataValue=handles.dropcProg.odorValve1;
dataValue=bitcmp(uint8(dataValue));

putvalue(handles.dio.Line(1:8),dataValue);




%if handles.dropcProg.skipIntervals==0
while (toc-start_toc<fvtime)
    noSamples=noSamples+1;
    if dropcNosePokeNow(handles)==1
        noSamplesMouseOn=noSamplesMouseOn+1;
    end
end
%end


%Turn on (or not) opto stimulus during odor delivery
opto_on=0;

%If this is not a short then give the light
if (noSamplesMouseOn/noSamples) > 0.2
    
    if handles.dropcProg.whenOptoOn==2
        if handles.dropcProg.odorValve==handles.dropcProg.splusOdorValve %for S+
            %if handles.dropcProg.odorValve==handles.dropcProg.sminusOdorValve %for S-
            %if you want to randomly send TTL opto uncomment this line
            %         if handles.dropcProg.randomOpto(handles.dropcData.fellowsNo)==1
            dataValue=uint8(0);
            putvalue(handles.dio.Line(9:12),dataValue);
            opto_on=1;
            handles.dropcData.allTrialOptoOn(handles.dropcData.allTrialIndex+1)=1;
            %         end
        end
    end
    
end

%Notify draq of odor 1
%Notify draq
if opto_on==0
    handles.dropcDigOut.draqPortStatus=handles.dropcDraqOut.odor1;
else
    handles.dropcDigOut.draqPortStatus=handles.dropcDraqOut.odor1+handles.dropcDraqOut.opto_on;
end


dropcUpdateDraqPort(handles);


%Turn FinalValve towards the odor port: turn on odor...)

dataValue=bitcmp(uint8(0));
putvalue(handles.dio.Line(17:24),dataValue);

%Turn opto TTL off
if (handles.dropcProg.whenOptoOn==1)
    dataValue=uint8(15);
    putvalue(handles.dio.Line(9:12),dataValue);
end



if (fvtime<0.3)
    finalValveOK=1;
else
    
    if (noSamplesMouseOn/noSamples) > 0.2
        finalValveOK=1;
    else
        finalValveOK=0;
    end
end

