var ui=require('../ui')
  , api=require('../api')
  , geo=require('./geo')
  ;

var map
  , feature
  , path
  , layout
  , uiInitialized=false
  , toolbar=ui.button.toolbar([])
  , titleElement=ui.html.pageTitle('გზის შეცვლა')
  , desriptionElement=ui.html.p('გზის შესაცვლელად გამოიყენეთ თქვენი მაუსი. რედაქტირების დასრულების შემდეგ დააჭირეთ შენახვის ღილაკს.',{style:'margin-top:8px;'})
  , notLocked
  ;

module.exports=function(){
  return {
    onEnter: function(){
      var self=this;
      notLocked=true;

      if (!uiInitialized){ initUI(self); }

      map=self.map;
      feature=self.params.feature;
      initMap();

      return layout;
    },
    onExit: function() {
      geo.resetMap(map);
    },
  };
};

var initUI=function(self){
  var btnBack=ui.button.actionButton('უკან', function(){
    path.setMap(null);
    map.data.add(feature);
    self.openPage('root');
  }, {icon:'arrow-left'});

  var btnSave=ui.button.actionButton('გზის შენახვა', function(){
    notLocked=!api.editPath(feature.getId(),path.getPath(), function(data){
      path.setMap(null);
      map.loadData(data.id);
      self.openPage('root');
      btnSave.setWaiting(false);
    });
    btnSave.setWaiting(!notLocked);
  }, {icon:'save', type:'success'});

  toolbar.addButton(btnBack);
  toolbar.addButton(btnSave);

  layout=ui.layout.vertical({
    children: [
      titleElement,
      toolbar,
      desriptionElement,
    ]
  });

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
        path: google.maps.SymbolPath.CIRCLE,
        fillOpacity: 0,
        strokeOpacity: 1,
        strokeColor: '#FF0000',
        strokeWeight: 1,
        scale: 10, //pixels
      }
    });
  }
  path.getPath().clear();
  path.setMap(map);

  geo.copyFeatureToPath(feature,path);
  map.data.remove(feature);

  var extendPath=function(evt){
    if(notLocked){
      path.getPath().push(evt.latLng);
    }
  };

  google.maps.event.addListener(map, 'click', extendPath);
  google.maps.event.addListener(marker, 'click', extendPath);

  google.maps.event.addListener(path, 'dblclick', function(evt){
    if(notLocked){
      if(typeof evt.vertex==='number'){
        path.getPath().removeAt(evt.vertex,1);
      }
    }
  });

  map.data.addListener('mouseover', function(evt) {
    if(notLocked){
      map.data.overrideStyle(evt.feature,{strokeWeight:10,strokeColor:'#00FF00'});
      marker.setMap(map);
    }
  });

  map.data.addListener('mouseout', function(evt) {
    if(notLocked){
      map.data.revertStyle();
      marker.setMap(null);
    }
  });

  map.data.addListener('mousemove', function(evt){
    if(notLocked){
      marker.setPosition(geo.closestFeaturePoint(evt.feature,evt.latLng));
    }
  });
};
