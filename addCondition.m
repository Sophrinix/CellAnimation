function addCondition()
global al_gui_struct;

cell_properties=al_gui_struct.CellProperties;
logic_connectors=al_gui_struct.LogicConnectors;
operators=al_gui_struct.Operators;

condition_struct.ComboLogicConnector=logic_connectors{get(al_gui_struct.ComboLogicConnectorHandle,'Value')};
condition_struct.ComboCellProperty=cell_properties{get(al_gui_struct.ComboCellPropertyHandle,'Value')};
condition_struct.ComboOperator=operators{get(al_gui_struct.ComboOperatorHandle,'Value')};
condition_struct.EditValue=get(al_gui_struct.EditValueHandle,'String');
if (isempty(condition_struct.EditValue))
    warndlg('The value cannot be empty.');
    return;
end
status_text=get(al_gui_struct.TextConditionsHandle,'String');
if isempty(status_text)    
    status_text=[condition_struct.ComboCellProperty condition_struct.ComboOperator...
        num2str(condition_struct.EditValue)];
    condition_struct.ComboLogicConnector='AND';
    al_gui_struct.Conditions=condition_struct;
else
    status_text=[status_text ' ' condition_struct.ComboLogicConnector ' ' condition_struct.ComboCellProperty...
        condition_struct.ComboOperator num2str(condition_struct.EditValue)];
    al_gui_struct.Conditions=[al_gui_struct.Conditions; condition_struct];
end
set(al_gui_struct.TextConditionsHandle,'String',status_text);

%end addCondition
end