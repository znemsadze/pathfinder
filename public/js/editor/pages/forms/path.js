var ui=require('../../ui')
  ;

exports.form=function(opts){
  var save_f=opts.save_action;
  var cancel_f=opts.cancel_action;

  var saveAction={label: 'გზის შენახვა', icon:'save', type:'success', action: save_f};
  var cancelAction={label:'გაუმება', icon:'times-circle', action: cancel_f};

  var typeCombo=ui.form.comboField('type_id', {label: 'გზის სახეობა', collection_url: '/geo/pathtype.json', text_property: 'name'});
  var surfaceCombo=ui.form.comboField('surface_id', {label: 'გზის საფარი', collection_url: '/geo/pathsurface.json', text_property: 'name', parent_combo: typeCombo, parent_key: 'type_id'});
  var detailsCombo=ui.form.comboField('detail_id', {label: 'საფარის დეტალები', collection_url: '/geo/pathdetail.json', text_property: 'name', parent_combo: surfaceCombo, parent_key: 'surface_id'});
  var descriptionText=ui.form.textArea('description', {label: 'შენიშვნები'});

  var fields=[typeCombo, surfaceCombo, detailsCombo,descriptionText];
  var actions=[saveAction,cancelAction];

  var form=ui.form.create(fields,{actions: actions, load_url:'/api/geo/path'});
  return form;
};