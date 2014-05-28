var ui=require('../../ui')
  ;

exports.form=function(opts){
  var save_f=opts.save_action;
  var cancel_f=opts.cancel_action;

  var saveAction={label: 'ხაზის შენახვა', icon:'save', type:'success', action: save_f};
  var cancelAction={label:'გაუმება', icon:'times-circle', action: cancel_f};

  var nameText=ui.form.textField('name', {label: 'სახელი'});
  var descriptionText=ui.form.textArea('description', {label: 'შენიშვნა'});
  var regionsCombo=ui.form.comboField('region_id', {label: 'რეგიონი', collection_url: '/regions.json', text_property: 'name'});

  var fields=[nameText,descriptionText,regionsCombo];
  var actions=[saveAction,cancelAction];

  var form=ui.form.create(fields,{actions: actions, load_url:'/api/lines/show.json'});
  return form;
};