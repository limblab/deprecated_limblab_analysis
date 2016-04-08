classdef (ConstructOnLoad) loggingListenerEventData < event.EventData
    %sub class of event allowing operation names and data to be passed out
    %to listners. 
    %loggingListnerEventData is configured to construct on the fly, rather
    %than requiring you to load the class before using. Intended usage is
    %as follows:
    %evtData=loggingListnerEventData('operationPath.m',operationDataStruct);
    %notify(obj,'listnerID',evtdata);
   properties
      operationData
      operationName
   end
   
   methods
      function data = loggingListnerEventData(opName,opData)
          data.operationName=opName;
          data.operationData = opData;
      end
   end
end

