exports.resetMap=function(map){
  google.maps.event.clearInstanceListeners(map);
  google.maps.event.clearInstanceListeners(map.data);
  map.data.revertStyle();
};

exports.copyFeatureToPath=function(feature,path){
  var g=feature.getGeometry();
  var ary=g.getArray();
  path.getPath().clear();
  for(var i=0,l=ary.length;i<l;i++){
    var p=ary[i];
    var point=new google.maps.LatLng(p.lat(),p.lng());
    path.getPath().push(point);
  }
};

exports.copyFeatureToMarker=function(feature,marker){
  var point=feature.getGeometry().get();
  marker.setPosition(new google.maps.LatLng(point.lat(), point.lng()));
};

// distances

exports.closestFeaturePoint=function(feature,point){
  var minDistance
    , minPoint
    ;
  var g=feature.getGeometry();
  var ary=g.getArray();
  for(var i=0,l=ary.length;i<l;i++){
    var p=ary[i];
    var x=new google.maps.LatLng(p.lat(),p.lng());
    var distance=google.maps.geometry.spherical.computeDistanceBetween(p,point);
    if(!minDistance || distance<minDistance){
      minDistance=distance;
      minPoint=p;
    }
  }
  return minPoint;
};

exports.calcFeatureDistance=function(map,feature){
  if(feature instanceof Array){
    var fullDistance=0;
    for(var p=0,q=feature.length;p<q;p++){
      fullDistance+=exports.calcFeatureDistance(map,feature[p]);
    }
    return fullDistance;
  }
  var g=feature.getGeometry()
    , dist=0
    , ary=g.getArray()
    , p0=ary[0]
    ;
  for(var i=0,l=ary.length;i<l;i++){
    var p=ary[i];
    dist+=google.maps.geometry.spherical.computeDistanceBetween(p0,p);
    p0=p;
  }
  return dist/1000;
};

// feature description

exports.TYPE_PATH='Objects::Path::Line';
exports.TYPE_LINE='Objects::Line';
exports.TYPE_TOWER='Objects::Tower';
exports.TYPE_OFFICE='Objects::Office';
exports.TYPE_SUBSTATION='Objects::Substation';

exports.getType=function(f){ return f.getProperty('class'); };

var typed=function(f, callback){
  var type;
  if(typeof f==='undefined'){ return f; }
  else if(typeof f==='string'){ type=f; }
  else{ type=exports.getType(f); }
  return callback(type);
};

exports.isLine=function(f){ return typed(f,function(type){ return exports.TYPE_LINE==type; }); }
exports.isPath=function(f){ return typed(f,function(type){ return exports.TYPE_PATH==type; }); }
exports.isTower=function(f){ return typed(f,function(type){ return exports.TYPE_TOWER==type; }); }
exports.isOffice=function(f){ return typed(f,function(type){ return exports.TYPE_OFFICE==type; }); }
exports.isSubstation=function(f){ return typed(f,function(type){ return exports.TYPE_SUBSTATION==type; }); }

exports.typeName=function(f){
  return typed(f,function(type){
    if(exports.TYPE_LINE===type){ return 'გადამცემი ხაზი'; }
    else if(exports.TYPE_PATH==type){ return 'მარშრუტი'; }
    else if(exports.TYPE_TOWER==type){ return 'ანძა'; }
    else if(exports.TYPE_OFFICE==type){ return 'ოფისი'; }
    else if(exports.TYPE_SUBSTATION==type){ return 'ქვესადგური'; }
    return type;
  });
};

var property=function(name,value){
  return [
    '<p><strong>',name,'</strong>: ',
    (value||'<span class="text-muted">(ცარიელი)</span>'),
    '</p>'
  ].join('');
};

var lineDescription=function(map,f){
  return [
    property('დასახელება',f.getProperty('name')),
    property('მიმართულება',f.getProperty('direction')),
    property('სიგრძე','<code>'+exports.calcFeatureDistance(map,f).toFixed(3)+'</code> კმ'),
    property('რეგიონი',f.getProperty('region')),
    property('შენიშვნა',f.getProperty('description')),
  ].join('');
};

var towerDescription=function(map,f){
  var point=f.getGeometry().get();
  return [
    property('ანძის#',f.getProperty('name')),
    property('ტიპი',f.getProperty('category')),
    property('რეგიონი',f.getProperty('region')),
    property('განედი','<code>'+point.lat()+'</code>'),
    property('გრძედი','<code>'+point.lng()+'</code>'),
    property('შენიშვნა',f.getProperty('description')),
  ].join('');
};

var officeDescription=function(map,f){
  var point=f.getGeometry().get();
  return [
    property('დასახელება',f.getProperty('name')),
    property('რეგიონი',f.getProperty('region')),
    property('მისამართი',f.getProperty('address')),
    property('განედი','<code>'+point.lat()+'</code>'),
    property('გრძედი','<code>'+point.lng()+'</code>'),
    property('შენიშვნა',f.getProperty('description')),
  ].join('');
};

var substationDescription=function(map,f){
  var point=f.getGeometry().get();
  return [
    property('დასახელება',f.getProperty('name')),
    property('რეგიონი',f.getProperty('region')),
    property('განედი','<code>'+point.lat()+'</code>'),
    property('გრძედი','<code>'+point.lng()+'</code>'),
    property('შენიშვნა',f.getProperty('description')),
  ].join('');
};

exports.featureDescription=function(map,f){
  var bodyDescription;

  var texts=['<div class="panel panel-default">'];
  texts.push('<div class="panel-heading"><h4 style="margin:0;padding:0;">',exports.typeName(f),'</h4></div>');
  if(exports.isLine(f)){ bodyDescription=lineDescription(map,f); }
  else if(exports.isPath(f)){ bodyDescription=lineDescription(map,f); }
  else if(exports.isTower(f)){ bodyDescription=towerDescription(map,f); }
  else if(exports.isOffice(f)){ bodyDescription=officeDescription(map,f); }
  else if(exports.isSubstation(f)){ bodyDescription=substationDescription(map,f); }
  texts.push('<div class="panel-body">',bodyDescription,'</div>');
  texts.push('</div>');
  return texts.join('');
};

// search support

exports.searchHit=function(f,words){
  for(var i=0,l=words.length;i<l;i++){
    var word=words[i];
    if(!searchSingleHit(f,word)){
      return false;
    }
  }
  return true;
};

var searchSingleHit=function(f,word){
  if(exports.isTower(f)){ return searchTowerHit(f, word); }
  else if(exports.isSubstation(f)){ return searchSubstationHit(f,word); }
  else if(exports.isOffice(f)){ return searchOfficeHit(f,word); }
  else if(exports.isLine(f)){ return searchPathHit(f,word); }
  else if(exports.isPath(f)){ return searchLineHit(f,word); }
  return false;
};

var searchTowerHit=function(f,word){
  var searchString=[
    f.getProperty('name'),
    f.getProperty('category'),
    f.getProperty('region'),
    f.getProperty('description')
  ].join(' ');
  return searchString.indexOf(word) != -1;
};

var searchSubstationHit=function(f,word){
  var searchString=[
    f.getProperty('name'),
    f.getProperty('region'),
    f.getProperty('description')
  ].join(' ');
  return searchString.indexOf(word) != -1;
};

var searchOfficeHit=function(f,word){
  var searchString=[
    f.getProperty('name'),
    f.getProperty('region'),
    f.getProperty('description'),
    f.getProperty('address'),
  ].join(' ');
  return searchString.indexOf(word) != -1;
};

var searchLineHit=function(f,word){
  var searchString=[
    f.getProperty('name'),
    f.getProperty('region'),
    f.getProperty('description'),
    f.getProperty('direction'),
  ].join(' ');
  return searchString.indexOf(word) != -1;
};

var searchPathHit=function(f,word){
  var searchString=[
    f.getProperty('name'),
    f.getProperty('region'),
    f.getProperty('description'),
  ].join(' ');
  return searchString.indexOf(word) != -1;
};