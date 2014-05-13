var ui=require('../ui')
  , api=require('../api')
  , geo=require('./geo')
  ;

var map
  , marker
  , layout
  , uiInitialized=false
  , titleElement=ui.html.pageTitle('ახალი გზის დამატება')
  , toolbar=ui.button.toolbar([])
  , desriptionElement=ui.html.p('ახალი გზის გასავლებად გამოიყენეთ თქვენი მაუსი. რედაქტირების დასრულების შემდეგ დააჭირეთ შენახვის ღილაკს.',{style:'margin-top:8px;'})
  , canEdit=true
  , path
  , form
  ;

module.exports=function(){
  return {
    onEnter: function(){
      var self=this;

      if(!uiInitialized){ initUI(self); }

      canEdit=true;
      map=self.map;
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
    self.openPage('root');
  }, {icon:'arrow-left'});

  var btnSave=ui.button.actionButton('გზის შენახვა', function(){
    canEdit=!api.newPath(path.getPath(), function(data){
      path.setMap(null);
      map.loadData(data.id);
      self.openPage('root');
    });
  }, {icon:'save', type:'success'});

  toolbar.addButton(btnBack);
  toolbar.addButton(btnSave);

  var typeCombo=ui.form.comboField('type', {label: 'გზის სახეობა', collection_url: '/geo/pathtype.json', text_property:'name'});

  form=ui.form.create({}, [
    typeCombo,
  ]);

  layout=ui.layout.vertical({
    children: [
      titleElement,
      toolbar,
      desriptionElement,
      form
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

  map.data.addListener('mouseover', function(evt) {
    if(canEdit){
      map.data.overrideStyle(evt.feature,{strokeWeight:10,strokeColor:'#00FF00'});
      marker.setMap(map);
    }
  });

  map.data.addListener('mouseout', function(evt) {
    if(canEdit){
      map.data.revertStyle();
      marker.setMap(null);
    }
  });

  map.data.addListener('mousemove', function(evt){
    if(canEdit){
      marker.setPosition(geo.closestFeaturePoint(evt.feature,evt.latLng));
    }
  });
};