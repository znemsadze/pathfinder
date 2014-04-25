(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var draw=require('./draw')
  , ui=require('./ui');

var mapElement;
var sidebarElement;
var toolbarElement;
var apikey;
var defaultCenterLat;
var defaultCenterLng;
var defaultZoom;
var map;

/**
 * This function is used to start the application.
 */
exports.start=function(opts){
  sidebarElement=document.getElementById((opts&&opts.sidebarid)||'sidebar');
  toolbarElement=document.getElementById((opts&&opts.toolbarid)||'toolbar');
  mapElement=document.getElementById((opts&&opts.mapid)||'map');
  defaultCenterLat=(opts&&opts.centerLat)||41.693328079546774;
  defaultCenterLng=(opts&&opts.centerLat)||44.801473617553710;
  defaultZoom=(opts&&opts.startZoom)||10;
  window.onload=loadingGoogleMapsAsyncronously;
};

var loadingGoogleMapsAsyncronously=function(){
  var host='https://maps.googleapis.com/maps/api/js';
  var script = document.createElement('script');
  script.type = 'text/javascript';
  if (apikey){ script.src = host+'?v=3.ex&key='+apikey+'&sensor=false&callback=onGoogleMapLoaded'; }
  else{ script.src = host+'?v=3.ex&sensor=false&callback=onGoogleMapLoaded'; }
  document.body.appendChild(script);
  window.onGoogleMapLoaded=onGoogleMapLoaded;
};

var onGoogleMapLoaded=function(){
  initMap();
};

var initMap=function(){
  var mapOptions = {
    zoom: defaultZoom,
    center: new google.maps.LatLng(defaultCenterLat,defaultCenterLng),
    mapTypeId: google.maps.MapTypeId.TERRAIN
  };
  map=new google.maps.Map(mapElement, mapOptions);

  map.data.loadGeoJson('/geo/map.json');
  map.data.setStyle({
    strokeColor:'red',
    strokeOpacity:0.5,
  });
  // map.data.addListener('mouseover', function(evt) {
  //   map.data.overrideStyle(evt.feature,{strokeWeight:10});
  // });
  // map.data.addListener('mouseout', function(evt) {
  //   map.data.revertStyle();
  // });

  var b1=ui.button.actionButton('გზის შენახვა', function(){
    var path=drawHandle.getPath();
    if(path.getLength()>1) {
      var points=[];
      path.forEach(function(element,index){
        points.push([element.lat(),element.lng()]);
      });
    }
    $.post('/api/geo/new_path',{points:points},function(data) {
      console.log(data);
    });
  });
  toolbarElement.appendChild(b1);

  // draw path
  var drawHandle=draw.drawPath(map);
};
},{"./draw":2,"./ui":6}],2:[function(require,module,exports){
exports.drawPath=function(map){
  var path = new google.maps.Polyline({
    map:map,
    geodesic:true,
    strokeColor:'#FF0000',
    strokeOpacity:1.0,
    strokeWeight:1,
    editable:true,
  });

  google.maps.event.addListener(map, 'click', function(evt){
    path.getPath().push(evt.latLng);
  });

  google.maps.event.addListener(path, 'dblclick', function(evt){
    if(typeof evt.vertex==='number'){
      path.getPath().removeAt(evt.vertex,1);
    }
  });

  return {
    getPath: function(){ return path.getPath(); },
  };
};
},{}],3:[function(require,module,exports){
var app=require('./app');

app.start();
},{"./app":1}],4:[function(require,module,exports){
var html=require('./html')
  , utils=require('./utils');

var btnClassNames=function(opts){
  var classNames;
  opts=opts || {};
  if(opts.type===false){ classNames=[]; }  
  else {
    opts.type=opts.type||'default';
    // var size=opts.size=='small'?'btn-xs':'btn-sm';
    // classNames=['btn','btn-'+opts.type,size];
    classNames=['btn','btn-sm','btn-'+opts.type]
  }
  return classNames;
};

exports.actionButton=function(text,action_f,opts){
  var el= html.el('a',{href:'#',class:btnClassNames(opts)},text);
  el.onclick=function(){
    if(action_f){ action_f(); }
    return false;
  }
  return el;
};

exports.actionLink=function(text,action_f,opts){
  opts=opts || {};
  opts.type=false; // disable button
  return this.actionButton(text,action_f,opts);
};

exports.buttonGroup=function(buttons){
  return html.el('div',{class:'btn-group'},buttons);
};

exports.toolbar=function(buttons){
  return html.el('div',{class:'btn-toolbar'},buttons);
};

exports.dropdown=function(text,buttons,opts){
  var classes=btnClassNames(opts).concat(['dropdown-toggle']);
  if(utils.isArray(text)){text=text.push(' ');} else{text=[text,' '];}
  text.push(html.el('span',{class:'caret'}));
  var btn=html.el('button',{class:classes,'data-toggle':'dropdown'},text);
  var dd=html.el('ul',{class:'dropdown-menu'},buttons.map(function(x){ return html.el('li',[x]); }));
  return html.el('div',{class:'btn-group'},[btn,dd]);
};
},{"./html":5,"./utils":7}],5:[function(require,module,exports){
var utils=require('./utils');

var dashedToCamelized=function(name){
  var firstToUpper=function(x){return [x.substring(0,1).toUpperCase(),x.substring(1)].join('');};
  var parts=name.split('-');
  return [parts[0]].concat(parts.slice(1).map(firstToUpper)).join('');
};

var applyAttribute=function(element,attrName,attrValue){
  if('class'===attrName){

    // class => className
    if(utils.isArray(attrValue)){ element.className=attrValue.join(' '); }
    else{ element.className=attrValue; }
  }
  else if('style'===attrName && attrValue){

    // styles

    var styles=attrValue.split(';');
    for(var i=0,l=styles.length;i<l;i++) {
      var styleInfo=styles[i];
      if(styleInfo && styleInfo.length>0){
        var colonIndex=styleInfo.indexOf(':');
        var styleName=dashedToCamelized(styleInfo.substring(0,colonIndex));
        var styleValue=styleInfo.substring(colonIndex+1);
        element.style[styleName]=styleValue;
      }
    }
  }
  else{ element.setAttribute(attrName,attrValue); }
};

var createElement=function(tag,attrs,children){
  var element = document.createElement(tag);
  if(attrs){ for(attrName in attrs){ applyAttribute(element,attrName,attrs[attrName]); } }
  if(children){
    for(var i=0,l=children.length;i<l;i++){
      var child=children[i];
      if(typeof child==='string'){ element.appendChild(document.createTextNode(child)); }
      else if(utils.isElement(child)){ element.appendChild(child); }
    }
  }
  return element;
};

/**
 * ```
 * el([parent],tag,[attributes],[children])
 * ```
 *
 * `parent`:Element parent for this element
 * `tag`:String tag name
 * `attributes`:Object tag attributes
 * `children`:{Element|Array|String}
 */
exports.el=function(){
  var parent,tag,attrs,children;
  var curr_index=0;

  // first argument may be a parent
  if(utils.isElement(arguments[curr_index])){ parent=arguments[curr_index]; curr_index+=1; }

  // argument[curr_index] is mandatory 
  tag=arguments[curr_index]; curr_index+=1;
  if(typeof tag !== 'string'){ throw "Tag not defined"; }

  // getting attributes
  if(!utils.isArray(arguments[curr_index]) && typeof arguments[curr_index]==='object'){ attrs=arguments[curr_index]; curr_index+=1; }

  // getting children
  if(typeof arguments[curr_index]==='string' || utils.isElement(arguments[curr_index])){
    children=[ arguments[curr_index] ]; curr_index+=1;
  } else if(utils.isArray(arguments[curr_index])){
    children=arguments[curr_index]; curr_index+=1;
  }

  // create element
  var element=createElement(tag,attrs,children);

  // if parent is given, then append this element to parent
  if (element && parent){ parent.appendChild(element); }

  return element;
};

exports.pageTitle=function(title,tag){
  return exports.el(tag||'h3',{class:'page-header'},title);
};

exports.p=function(text,opts){
  return exports.el('p',opts,text);
};
},{"./utils":7}],6:[function(require,module,exports){
var button=require('./button')
  ;

exports.button=button;
},{"./button":4}],7:[function(require,module,exports){
exports.isArray=function(x){ return x && (x instanceof Array); };
exports.isElement=function(x){ return x && ((x instanceof Element) || (x instanceof Document)); }
exports.fieldValue=function(object,name){ return object&&object[name]; };
},{}]},{},[3])