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
  var saveAction=function(){
    // var form=getForm();
    // form.clearErrors();

    // var model=form.getModel()
    //   , position=marker.getPosition()
    //   ;

    // model.lat=position.lat();
    // model.lng=position.lng();

    // var callback=function(err,data){
    //   if(err){
    //     console.log(err);
    //   } else {
    //     marker.setMap(null);
    //     map.loadData({id:data.id, type:getType()});
    //     self.openPage('root');
    //   }
    // };

    // var sent=false;
    // if (geo.isTower(getType())){
    //   if(isNewMode()){ sent=api.tower.newTower(model, callback); }
    //   else { sent=api.tower.editTower(getId(), model, callback); }
    // } else if(geo.isOffice(getType())){
    //   if(isNewMode()){ sent=api.office.newOffice(model, callback); }
    //   else { sent=api.office.editOffice(getId(), model, callback); }
    // } else if(geo.isSubstation(getType())){
    //   if(isNewMode()){ sent=api.substation.newSubstation(model, callback); }
    //   else { sent=api.substation.editSubstation(getId(), model, callback); }
    // }

    // canEdit= !sent;
    // if(!sent){ form.setModel(model); }
  };

  var cancelAction=function(){
    // marker.setMap(null);
    // var feature=getFeature();
    // if(feature){ map.data.add(feature); }
    self.openPage('root');
  };

  var form=forms.task.form({ save_action:saveAction, cancel_action:cancelAction });

  layout=ui.layout.vertical({children: [titleElement, form] });
  uiInitialized=true;
};
