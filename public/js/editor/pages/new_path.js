var ui=require('../ui')
  , api=require('../api')
  , geo=require('./geo')
  ;

var map
  , layout
  , uiInitialized=false
  , titleElement=ui.html.pageTitle('ახალი გზის დამატება')
  , toolbar=ui.button.toolbar([])
  , desriptionElement=ui.html.p('ახალი გზის გასავლებად გამოიყენეთ თქვენი მაუსი. რედაქტირების დასრულების შემდეგ დააჭირეთ შენახვის ღილაკს.',{style:'margin-top:8px;'})
  , canEdit=true
  , path
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
  };
};

var initUI=function(self){
  var btnBack=ui.button.actionButton('უკან', function(){
    self.openPage('root');
  }, {icon:'arrow-left'});

  var btnSave=ui.button.actionButton('გზის შენახვა', function(){
    canEdit=!api.newPath(path.getPath(), function(data){
      path.setMap(null);
      map.loadData(data.id);
      //self.openPage('root');
      //console.log(data);
    });
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
  path=new google.maps.Polyline({
    map:map,
    geodesic:true,
    strokeColor:'#0000FF',
    strokeOpacity:1.0,
    strokeWeight:1,
    editable:true,
  });

  // , marker = new google.maps.Marker({
  //   icon: {
  //     path: google.maps.SymbolPath.CIRCLE,
  //     fillOpacity: 0,
  //     strokeOpacity: 1,
  //     strokeColor: '#FF0000',
  //     strokeWeight: 1,
  //     scale: 10, //pixels
  //   }
  // })
  // ;

  google.maps.event.addListener(map, 'click', function(evt){
    if(canEdit){
      path.getPath().push(evt.latLng);
    }
  });

  google.maps.event.addListener(path, 'dblclick', function(evt){
    if(canEdit){
      if(typeof evt.vertex==='number'){
        path.getPath().removeAt(evt.vertex,1);
      }
    }
  });
};