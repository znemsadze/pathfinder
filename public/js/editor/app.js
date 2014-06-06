var ui=require('./ui')
  , api=require('./api')
  , router=require('./router')
  , pages=require('./pages')
  , geo=require('./pages/geo')
  ;

var mapElement, sidebarElement, filterbarElement
  , defaultCenterLat, defaultCenterLng, defaultZoom
  , apikey, map
  , app
  ;

/**
 * Entry point for the application.
 */
exports.start=function(opts){
  sidebarElement=document.getElementById((opts&&opts.sidebarid)||'sidebar');
  filterbarElement=document.getElementById((opts&&opts.toolbarid)||'filterbar');
  mapElement=document.getElementById((opts&&opts.mapid)||'map');
  defaultCenterLat=(opts&&opts.centerLat)||42.3;
  defaultCenterLng=(opts&&opts.centerLat)||43.8;
  defaultZoom=(opts&&opts.startZoom)||7;
  window.onload=loadingGoogleMapsAsyncronously;
};

var loadingGoogleMapsAsyncronously=function(){
  var host='https://maps.googleapis.com/maps/api/js';
  var script = document.createElement('script');
  script.type = 'text/javascript';
  var baseUrl=host+'?v=3.ex&sensor=false&callback=onGoogleMapLoaded&libraries=geometry';
  if (apikey){ script.src = baseUrl+'&key='+apikey; }
  else{ script.src = baseUrl; }
  document.body.appendChild(script);
  window.onGoogleMapLoaded=onGoogleMapLoaded;
};

var onGoogleMapLoaded=function(){
  initMap();
  initFilterbar();
  initRouter();
};

var styleFunction=function(f) {
  var name=f.getProperty('name')
    , isSelected=f.selected
    , isHovered=f.hovered
    , visible=true
    ;

  if(regionCombo.getValue()){
    var selectedRegion=regionCombo.getText();
    if(f.getProperty('region') != selectedRegion){
      visible=false;
    }
  }

  if (geo.isLine(f)){
    var strokeColor, strokeWeight;
    if(isSelected){ strokeColor='#AA0000'; strokeWeight=10; }
    else if(isHovered){ strokeColor='#FF5555'; strokeWeight=10; }
    else{ strokeColor='#FF0000'; strokeWeight=1; }
    return {
      strokeColor: strokeColor,
      strokeWeight: strokeWeight,
      strokeOpacity: 0.5,
      title: name,
      visible: visible&&chkLine.isChecked(),
    };
  } else if (geo.isPath(f)) {
    var strokeColor, strokeWeight;
    if(isSelected){ strokeColor='#AA00AA'; strokeWeight=10; }
    else if(isHovered){ strokeColor='#FF55FF'; strokeWeight=10; }
    else{ strokeColor='#FF00FF'; strokeWeight=2; }
    return {
      strokeColor: strokeColor,
      strokeWeight: strokeWeight,
      strokeOpacity: 0.5,
      title: name,
      visible: visible&&chkPath.isChecked(),
    };
  } else if (geo.isTower(f)){
    var icon;
    if(isSelected){ icon='/map/tower-selected.png'; }
    else if(isHovered){ icon='/map/tower-hovered.png'; }
    else{ icon='/map/tower.png'; }
    return {
      icon: icon,
      visible: true,
      clickable: true,
      title: name,
      visible: visible&&chkTower.isChecked(),
    };
  } else if (geo.isOffice(f)){
    var icon;
    if(isSelected){ icon='/map/office-selected.png'; }
    else if(isHovered){ icon='/map/office-hovered.png'; }
    else{ icon='/map/office.png'; }
    return {
      icon: icon,
      visible: true,
      clickable: true,
      title: name,
      visible: visible&&chkOffice.isChecked(),
    };
  } else if (geo.isSubstation(f)){
    var icon;
    if(isSelected){ icon='/map/substation-selected.png'; }
    else if(isHovered){ icon='/map/substation-hovered.png'; }
    else{ icon='/map/substation.png'; }
    return {
      icon: icon,
      visible: true,
      clickable: true,
      title: name,
      visible: visible&&chkSubstation.isChecked(),
    };
  }
};

var initMap=function(){
  var mapOptions = {
    zoom: defaultZoom,
    center: new google.maps.LatLng(defaultCenterLat,defaultCenterLng),
    mapTypeId: google.maps.MapTypeId.ROADMAP,
  };

  map=new google.maps.Map(mapElement, mapOptions);

  map.loadData=function(opts){
    var url='/api/objects.json?';
    var query=[];
    if(typeof opts==='object'){
      if(opts.id){ query.push('id='+opts.id); }
      if(opts.type){ query.push('type='+opts.type); }
    }
    map.data.loadGeoJson(url+query.join('&'));
  };

  map.data.setStyle(styleFunction);

  map.loadData();

  window.map=map;
};

// router

var initRouter=function(){
  var filters={regionCombo:regionCombo, chkSubstation:chkSubstation, chkOffice:chkOffice, chkTower:chkTower, chkPath:chkPath, chkLine:chkLine};
  app=router.initApplication({map:map, filters:filters, sidebar:sidebarElement});

  app.addPage('root', pages.home());
  app.addPage('edit_path', pages.edit_path());
  app.addPage('edit_point', pages.edit_point());
  app.addPage('search', pages.search());

  app.openPage('root');
};

// filterbar

var regionCombo
  , chkSubstation
  , chkOffice
  , chkTower
  , chkPath
  , chkLine
  ;

var initFilterbar=function(){
  var mapReset=function(){
    map.data.setStyle(styleFunction);
    router.filterChanged();
  };

  regionCombo=ui.form.comboField('filter_region', {collection_url: '/regions.json', text_property: 'name', empty: '-- ყველა რეგიონი --'});
  regionCombo.addChangeListener(mapReset);

  chkOffice=filterCheckbox('ოფისი', mapReset);
  chkSubstation=filterCheckbox('ქვესადგური', mapReset);
  chkTower=filterCheckbox('ანძა', mapReset);
  chkLine=filterCheckbox('გადამცემი ხაზი', mapReset);
  chkPath=filterCheckbox('მარშუტი', mapReset);

  var d1=ui.html.el('div', [chkOffice, chkSubstation, chkTower]);
  var d2=ui.html.el('div', [chkLine, chkPath]);

  filterbarElement.appendChild(regionCombo);
  filterbarElement.appendChild(d1);
  filterbarElement.appendChild(d2);
};

var filterCheckbox=function(label,onchange){
  var input=ui.html.el('input', {type:'checkbox', checked: true});
  var field=ui.html.el('label', {style:'padding: 0 10px;'}, [input, ' '+label]);
  input.onchange=onchange;
  field.isChecked=function(){
    return input.checked;
  };
  return field;
};