var ui=require('../ui')
  , api=require('../api')
  , geo=require('./geo')
  ;

var map, selectedFeature
  , uiInitialized=false
  , layout
  , search
  , results
  ;

module.exports=function(){
  return {
    onEnter: function(){
      var self=this;

      if (!uiInitialized){
        initUI(self);
        displaySearchResults([]);
      }

      map=self.map;
      selectedFeature=null;

      return layout;
    },
    onExit: function() {
      geo.resetMap(map);
    },
    onStart: function(){
      search.requestFocus();
    },
  };
};

var initUI=function(self){
  var toolbar=ui.button.toolbar();
  var btnBack=ui.button.actionButton('უკან', function(){
    self.openPage('root',{selectedFeature: selectedFeature});
  }, {icon: 'arrow-circle-left'});

  toolbar.addButton(btnBack);
  toolbar.style.marginBottom='8px';

  search=ui.form.textField('search',{placeholder: 'ჩაწერეთ საკვანძო სიტყვა', autofocus: true});
  search.getTextField().onkeyup=function(){
    searching(search.getValue());
  };

  results=ui.html.el('div',{style: 'position:absolute; top:90px; bottom: 0; left:0; right: 0; padding: 4px 8px; overflow: auto; background: #fafafa;'});

  layout=ui.layout.vertical({children: [toolbar,search, results]});
  uiInitialized=true;
};

var searching=function(text){
  var selected=[];
  if(text){
    var words=text.split(' ');
    map.data.forEach(function(f){
      if(geo.searchHit(f,words)){
        selected.push(f);
      }
    });
  }
  displaySearchResults(selected);
};

var displaySearchResults=function(features){
  if(features.length==0){
    results.innerText='მონაცემი არაა';
  } else {
    results.innerText='';
    for(var i=0,l=features.length;i<l;i++){
      var f=features[i];
      var d=ui.html.el('div',{class:'search-result','data-id':f.getId()});
      d.innerHTML=geo.featureShortDescritpion(map,f);
      d.onclick=itemSelected;
      results.appendChild(d);
    }
  }
};

var itemSelected=function(){
  var f=map.data.getFeatureById(this.getAttribute('data-id'));
  // console.log(f);
  changeSelection(f);
};

var changeSelection=function(f){
  if(f!=selectedFeature){
    if(selectedFeature){
      selectedFeature.selected=false;
      map.data.revertStyle(selectedFeature);
    }
    selectedFeature=f;
    f.selected=true;
  }
  map.data.revertStyle(f);
  resetFeatureView();
};

var resetFeatureView=function(){
  if(selectedFeature){
    var f=selectedFeature;
    var bounds = new google.maps.LatLngBounds ();
    if(geo.isOffice(f)||geo.isTower(f)||geo.isSubstation(f)){
      bounds.extend(f.getGeometry().get());
    } else {
      var points=f.getGeometry().getArray();
       for(var i=0,l=points.length;i<l;i++){
        bounds.extend(points[i]);
      }
    }
    map.fitBounds(bounds);
  }
};