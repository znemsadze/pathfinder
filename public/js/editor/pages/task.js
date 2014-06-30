var ui=require('../ui')
  , forms=require('./forms')
  , api=require('../api')
  , geo=require('./geo')
  ;

var self, canEdit
  , map, marker
  , layout, formLayout, uiInitialized = false
  , titleElement = ui.html.pageTitle('ახალი დავალება')
  ;

module.exports=function(){
  return {
    onEnter: function(){
      self=this ; map=self.map ;
      if (!uiInitialized) { initUI(self); }
      return layout;
    },
  };
};

var initUI=function(){
  // var saveAction=function(){
  //   var form=getForm();
  //   form.clearErrors();

  //   var model=form.getModel()
  //     , position=marker.getPosition()
  //     ;

  //   model.lat=position.lat();
  //   model.lng=position.lng();

  //   var callback=function(err,data){
  //     if(err){
  //       console.log(err);
  //     } else {
  //       marker.setMap(null);
  //       map.loadData({id:data.id, type:getType()});
  //       self.openPage('root');
  //     }
  //   };

  //   var sent=false;
  //   if (geo.isTower(getType())){
  //     if(isNewMode()){ sent=api.tower.newTower(model, callback); }
  //     else { sent=api.tower.editTower(getId(), model, callback); }
  //   } else if(geo.isOffice(getType())){
  //     if(isNewMode()){ sent=api.office.newOffice(model, callback); }
  //     else { sent=api.office.editOffice(getId(), model, callback); }
  //   } else if(geo.isSubstation(getType())){
  //     if(isNewMode()){ sent=api.substation.newSubstation(model, callback); }
  //     else { sent=api.substation.editSubstation(getId(), model, callback); }
  //   }

  //   canEdit= !sent;
  //   if(!sent){ form.setModel(model); }
  // };

  // var cancelAction=function(){
  //   marker.setMap(null);
  //   var feature=getFeature();
  //   if(feature){ map.data.add(feature); }
  //   self.openPage('root',{selectedFeature: feature});
  // };

  // var form1=forms.tower.form({save_action:saveAction, cancel_action:cancelAction});
  // var form2=forms.office.form({save_action:saveAction, cancel_action:cancelAction});
  // var form3=forms.substation.form({save_action:saveAction, cancel_action:cancelAction});
  // formLayout=ui.layout.card({children: [form1, form2, form3]});
  // formLayout.openType=function(type){
  //   if(geo.isTower(type)){ formLayout.showAt(0); }
  //   else if(geo.isOffice(type)){ formLayout.showAt(1); }
  //   else if(geo.isSubstation(type)){ formLayout.showAt(2); }
  // };

  layout=ui.layout.vertical({children:[titleElement]});
  uiInitialized=true;
};
