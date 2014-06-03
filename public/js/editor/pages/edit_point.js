var ui=require('../ui')
  , forms=require('./forms')
  , api=require('../api')
  , geo=require('./geo')
  ;

var self, canEdit
  , map, marker
  , layout, formLayout, uiInitialized=false
  , titleElement=ui.html.pageTitle('შეცვლა')
  ;

module.exports=function(){
  return {
    onEnter: function(){
      self=this;

      if (!uiInitialized){ initUI(self); }

      map=self.map;
      initMap();

      resetLayout();
      canEdit=true;
      getForm().loadModel(getId());

      return layout;
    },
    onExit: function() {
      geo.resetMap(map);
    },
  };
};

var initUI=function(){
  var saveAction=function(){
    var form=getForm();
    form.clearErrors();

    var model=form.getModel()
      , position=marker.getPosition()
      ;

    model.lat=position.lat();
    model.lng=position.lng();

    var callback=function(err,data){
      if(err){
        console.log(err);
      } else {
        marker.setMap(null);
        map.loadData({id:data.id, type:getType()});
        self.openPage('root');
      }
    };

    var sent=false;
    if (geo.isTower(getType())){
      if(isNewMode()){ sent=api.tower.newTower(model, callback); }
      else { sent=api.tower.editTower(getId(), model, callback); }
    } else if(geo.isOffice(getType())){
      if(isNewMode()){ sent=api.office.newOffice(model, callback); }
      else { sent=api.office.editOffice(getId(), model, callback); }
    } else if(geo.isSubstation(getType())){
      if(isNewMode()){ sent=api.substation.newSubstation(model, callback); }
      else { sent=api.substation.editSubstation(getId(), model, callback); }
    }

    canEdit= !sent;
    if(!sent){ form.setModel(model); }
  };

  var cancelAction=function(){
    marker.setMap(null);
    var feature=getFeature();
    if(feature){ map.data.add(feature); }
    self.openPage('root',{selectedFeature: feature});
  };

  var form1=forms.tower.form({save_action:saveAction, cancel_action:cancelAction});
  var form2=forms.office.form({save_action:saveAction, cancel_action:cancelAction});
  var form3=forms.substation.form({save_action:saveAction, cancel_action:cancelAction});
  formLayout=ui.layout.card({children: [form1, form2, form3]});
  formLayout.openType=function(type){
    if(geo.isTower(type)){ formLayout.showAt(0); }
    else if(geo.isOffice(type)){ formLayout.showAt(1); }
    else if(geo.isSubstation(type)){ formLayout.showAt(2); }
  };

  layout=ui.layout.vertical({children:[titleElement,formLayout]});
  uiInitialized=true;
};

var resetLayout=function(){
  var type=getType();
  var prefix=isNewMode() ? 'ახალი: ' : 'შეცვლა: ';
  titleElement.setTitle(prefix+geo.typeName(type));
  formLayout.openType(type);
};

var initMap=function(){
  if(!marker){
    marker=new google.maps.Marker({
      draggable:true,
      animation: google.maps.Animation.DROP,
    });
  }
  marker.setMap(map);

  var feature=getFeature();

  if(feature){
    geo.copyFeatureToMarker(feature, marker);
    map.data.remove(feature);
  } else{
    marker.setPosition(map.getCenter());
  }
};

var getFeature=function(){ return self.params.feature; }
var isNewMode=function(){ return !getFeature(); };
var getForm=function(){ return  formLayout.selected(); };

var getType=function(){
  var feature=getFeature();
  if(feature){
    return geo.getType(feature);
  } else{
    return self.params.type;
  }
};

var getId=function(){
  var feature=getFeature();
  return feature&&feature.getId();
};
