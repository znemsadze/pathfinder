var ui=require('../../ui')
  ;

exports.form=function(opts){
  var save_f=opts.save_action;
  var cancel_f=opts.cancel_action;

  var saveAction = { label: 'დავალების შენახვა', icon:'save', type:'success', action: save_f };
  var cancelAction = { label:'გაუმება', icon:'times-circle', action: cancel_f };

  var assigneeCombo=ui.form.comboField('assignee_id', {label: 'შემსრულებელი', collection_url: '/api/users.json', text_property: 'username'});
  var noteText=ui.form.textArea('note', { label: 'შენიშვნა' });

  var fields = [assigneeCombo, noteText];
  var actions = [saveAction,cancelAction];

  var form = ui.form.create(fields, { actions: actions });
  return form;
};
