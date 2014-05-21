var ui=require('../ui')
  , forms=require('./forms')
  , api=require('../api')
  , geo=require('./geo')
  ;

var self, canEdit
  , map, feature, featureType, marker, path
  , form, layout, uiInitialized=false
  , titleElement=ui.html.pageTitle('გზის შეცვლა')
  ;

var isNewMode=function(){ return !feature; };

var resetTitle=function(){
  var type=self.params.type;
  if(isNewMode()){
    titleElement.setTitle('ახალი: '+geo.typeName(type));
  } else{
    titleElement.setTitle('შეცვლა: '+geo.typeName(type));
  }
};

module.exports=function(){
  return {
    onEnter: function(){
      self=this;

      if (!uiInitialized){ initUI(self); }
      canEdit=true;
      // form.loadModel(id);

      map=self.map;
      feature=self.params.feature;
      initMap();
      resetTitle();

      return layout;
    },
    onExit: function() {
      geo.resetMap(map);
    },
  };
};

var initUI=function(self){
  var saveAction=function(){
    // form.clearErrors(); var model=form.getModel(); model.path=path.getPath();
    // var sent=api.editPath(feature.getId(), model, function(data){
    //   path.setMap(null);
    //   map.loadData(data.id);
    //   self.openPage('root');
    // });
    // canEdit= !sent;
    // if(!sent){ form.setModel(model); }
  };

  var cancelAction=function(){
    path.setMap(null);
    if(feature){ map.data.add(feature); }
    self.openPage('root');
  };

  form=forms.path.form({save_action:saveAction, cancel_action:cancelAction});

  layout=ui.layout.vertical({ children: [ titleElement, form ] });
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

  if(!isNewMode()){
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
        path.getPath().removeAt(evt.vertex,1);
      }
    }
  });

  var type=self.params.type;

  if('Objects::Path'===type){
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
