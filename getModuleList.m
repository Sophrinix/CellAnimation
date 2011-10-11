function modules_list=getModuleList()
%build a list of modules in the current directory
%get alll the .m files

m_files=dir('*.m');
modules_list={};
%check which ones are modules
%modules are recognized by the presence of an input_args and an output_args
%structure
for i=1:length(m_files)
    file_text=fileread(m_files(i).name);
    if strcmp(m_files(i).name,'getModuleList.m')
        continue;
    end
    if strcmp(m_files(i).name,'aeMenuOpenAssay.m')
        continue;
    end
    if strcmp(m_files(i).name,'wrapFunction.m')
        continue;
    end
    %remove comments since they may contain the strings we're searching for
    module_text= regexprep(file_text, '%[^%\n]*\n', '');
    if isempty(strfind(module_text,'input_args'))
        continue;
    end
    if isempty(strfind(module_text,'output_args'))
        continue;
    end    
    modules_list=[modules_list;m_files(i).name];  
end

%sort the module list alphabetically
[dummy sort_idx]=sort(lower(modules_list));
modules_list=modules_list(sort_idx);

%end getModuleList
end