var ui=require('../ui')
  , api=require('../api')
  , geo=require('./geo')
  ;

var map
  , selectedFeature
  , filters
  , uiInitialized=false
  , layout
  , search
  , results
  , currText
  ;

module.exports=function(){
  return {
    onEnter: function(){
      var self=this;

      map=self.map;
      filters=self.filters;
      selectedFeature=null;

      if (!uiInitialized){
        initUI(self);
        displaySearchResults([]);
      }

      return layout;
    },
    onExit: function() {
      geo.resetMap(map);
    },
    onStart: function(){
      search.requestFocus();
    },
    filterChanged:function(){
      research();
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

  results=ui.html.el('div',{style: 'position:absolute; top:90px; bottom: 0; left:0; right: 0; overflow: auto; background: #fafafa;'});

  layout=ui.layout.vertical({children: [toolbar,search, results]});
  uiInitialized=true;
};

var research=function(){ // search again!
  searching(currText);
};

var searching=function(text){
  currText=text;
  var selected=[];
  if(text){
    var words=text.split(' ');
    map.data.forEach(function(f){
      if(isVisible(f)&&geo.searchHit(f,words)){
        selected.push(f);
      }
    });
  }
  displaySearchResults(selected);
};

var displaySearchResults=function(features){
  if(features.length>0){
    results.innerText='';
    for(var i=0,l=features.length;i<l;i++){
      var f=features[i];
        var d=ui.html.el('div',{class:'search-result','data-id':f.getId()});
        d.innerHTML=geo.featureShortDescritpion(map,f);
        d.onclick=itemSelected;
        results.appendChild(d);
    }
  } else {
    results.innerHTML='<div style="padding:8px;">მონაცემი არაა</div>';
  }
};

var itemSelected=function(){
  var f=map.data.getFeatureById(this.getAttribute('data-id'));
  changeSelection(f);

  // change selection class
  var children=this.parentElement.children;
  for(var i=0,l=children.length;i<l;i++){
    var child=children[i];
    if(child==this){
      child.className='search-result selected';
    } else{
      child.className='search-result';
    }
  }
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
    
    if(geo.isOffice(f)||geo.isTower(f)||geo.isSubstation(f)){
      var point=f.getGeometry().get();
      map.setCenter(point);
      if(map.getZoom()<12){ map.setZoom(12); }
    } else {
      var points=f.getGeometry().getArray();
      var bounds = new google.maps.LatLngBounds ();
      for(var i=0,l=points.length;i<l;i++){
        bounds.extend(points[i]);
      }
      map.fitBounds(bounds);
    }
  }
};

var isVisible=function(f){
  if(filters.regionCombo.getValue()){
    var selectedRegion=filters.regionCombo.getText();
    if(f.getProperty('region') != selectedRegion){ return false; }
  }
  if (geo.isLine(f)){ if(!filters.chkLine.isChecked()){ return false; } }
  if (geo.isPath(f)){ if(!filters.chkPath.isChecked()){ return false; } }
  if (geo.isTower(f)){ if(!filters.chkTower.isChecked()){ return false; } }
  if (geo.isOffice(f)){ if(!filters.chkOffice.isChecked()){ return false; } }
  if (geo.isSubstation(f)){ if(!filters.chkSubstation.isChecked()){ return false; } }
  return true;
};