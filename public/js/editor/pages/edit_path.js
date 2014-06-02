var ui=require('../ui')
  , forms=require('./forms')
  , api=require('../api')
  , geo=require('./geo')
  ;

var self, canEdit
  , map, marker, path
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

var resetLayout=function(){
  var type=getType();
  var prefix=isNewMode() ? 'ახალი: ' : 'შეცვლა: ';
  titleElement.setTitle(prefix+geo.typeName(type));
  formLayout.openType(type);
};

var initUI=function(self){
  var saveAction=function(){
    var form=getForm();
    form.clearErrors();

    var model=form.getModel();
    model.path=path.getPath();

    var callback=function(err,data){
      if(err){
        console.log(err);
      } else {
        path.setMap(null);
        map.loadData({id:data.id, type:getType()});
        self.openPage('root');
      }
    };

    var sent=false;
    if (geo.isLine(getType())){
      if(isNewMode()){ sent=api.line.newLine(model, callback); }
      else { sent=api.line.editLine(getId(), model, callback); }
    } else{
      if(isNewMode()){ sent=api.path.newPath(model, callback); }
      else { sent=api.path.editPath(getId(), model, callback); }
    }

    canEdit= !sent;
    if(!sent){ form.setModel(model); }
  };

  var cancelAction=function(){
    path.setMap(null);
    var feature=getFeature();
    if(feature){ map.data.add(feature); }
    self.openPage('root', {selectedFeature: getFeature()});
  };

  var form1=forms.path.form({save_action:saveAction, cancel_action:cancelAction});
  var form2=forms.line.form({save_action:saveAction, cancel_action:cancelAction});
  formLayout=ui.layout.card({children: [form1,form2]});
  formLayout.openType=function(type){
    if(geo.isPath(type)){
      formLayout.showAt(0);
    } else {
      formLayout.showAt(1);
    }
  };

  layout=ui.layout.vertical({children:[titleElement,formLayout]});
  uiInitialized=true;
};

var initMap=function(){
  if(!path) {
    path=new google.maps.Polyline({
      geodesic:true,
      strokeColor:'#0000FF',
      strokeOpacity:1.0,
      strokeWeight:1,
      editable:true,
    });
    marker = new google.maps.Marker({
      icon: {
        path:google.maps.SymbolPath.CIRCLE,
        fillOpacity:0,
        strokeOpacity:1,
        strokeColor:'#FF0000',
        strokeWeight:1,
        scale:10, //pixels
      }
    });
  }
  path.getPath().clear();
  path.setMap(map);

  var feature=getFeature();

  if(feature){
    geo.copyFeatureToPath(feature,path);
    map.data.remove(feature);
  }

  var extendPath=function(evt){
    if(canEdit){
      path.getPath().push(evt.latLng);
    }
  };

  google.maps.event.addListener(map, 'click', extendPath);
  google.maps.event.addListener(marker, 'click', extendPath);

  google.maps.event.addListener(path, 'dblclick', function(evt){
    if(canEdit){
      if(typeof evt.vertex==='number'){
        path.getPath().removeAt(evt.vertex);
      }
    }
  });

  if(geo.isPath(getType())){
    map.data.addListener('mouseover', function(evt) {
      if(canEdit){
        if(geo.isPath(evt.feature)){
          map.data.overrideStyle(evt.feature,{strokeWeight:10,strokeColor:'#00FF00'});
          marker.setMap(map);
        }
      }
    });

    map.data.addListener('mouseout', function(evt) {
      if(canEdit){
        if(geo.isPath(evt.feature)){
          map.data.revertStyle();
          marker.setMap(null);
        }
      }
    });

    map.data.addListener('mousemove', function(evt){
      if(canEdit){
        if(geo.isPath(evt.feature)){
          marker.setPosition(geo.closestFeaturePoint(evt.feature,evt.latLng));
        }
      }
    });
  }
};
