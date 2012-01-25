function assays_list=getAssaysList()
%helper function for assayEditorGUI. build a list of assays in the current directory
%get alll the .m files

m_files=dir('*.m');
assays_list={};
%check which ones are modules
%modules are recognized by the presence of an input_args and an output_args
%structure
for i=1:length(m_files)
    %these files are not assays
    if strcmp(m_files(i).name,'getAssaysList.m')
        continue;
    end
    if strcmp(m_files(i).name,'addToFunctionChain.m')
        continue;
    end
    if strcmp(m_files(i).name,'aeMenuOpenAssay.m')
        continue;
    end
    if strcmp(m_files(i).name,'saveAssay.m')
        continue;
    end
    file_text=fileread(m_files(i).name);
    %remove comments since they may contain the strings we're searching for
    module_text= regexprep(file_text, '%[^%\n]*\n', '');
    if isempty(strfind(module_text,'addToFunctionChain'))
        continue;
    end    
    assays_list=[assays_list;m_files(i).name];  
end

%end getAssayList
end